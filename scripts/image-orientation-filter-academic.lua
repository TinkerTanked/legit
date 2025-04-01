--[[
Simplified Image Orientation Filter for Pandoc (Academic Format)

This filter detects the orientation of images (landscape or portrait) from their attributes
and transforms them into the appropriate LaTeX commands for academic template.

The filter ONLY supports academic template format:
  \begin{landscape}\includegraphics...\end{landscape}
  \includegraphics...

This simplified version ALWAYS returns a block element for any image with an orientation attribute.

Usage: Add orientation="landscape" or orientation="portrait" to your image attributes.
Example: ![Caption](image.png){#fig:id orientation="landscape"}
]]--

-- Configuration
local DEBUG = false -- Set to true to enable debug output

-- Helper function for debug logging
local function debug(msg)
  if DEBUG then
    io.stderr:write("[DEBUG] " .. msg .. "\n")
  end
end

-- Function to escape special characters in LaTeX paths
local function escape_latex_path(path)
  -- Escape LaTeX special characters
  local escaped = path:gsub("([#$%&_{}^~\\])", "\\%1")
  return escaped
end

-- Extract text from a caption (simplified approach)
local function extract_caption_text(caption)
  if caption == nil then
    return ""
  end
  
  if type(caption) == "string" then
    return caption
  end
  
  -- Try to extract from Pandoc's Inlines
  if type(caption) == "table" then
    -- Simple approach: just join any text we find
    local texts = {}
    local traverse
    traverse = function(tbl)
      if tbl.text then
        table.insert(texts, tbl.text)
      elseif type(tbl) == "table" then
        for _, v in ipairs(tbl) do
          if type(v) == "table" then
            traverse(v)
          elseif type(v) == "string" then
            table.insert(texts, v)
          end
        end
      end
    end
    traverse(caption)
    return table.concat(texts, " ")
  end
  
  return ""
end

-- Function to format academic figures
local function format_academic_figure(id, caption, width, path, is_landscape)
  local label = id and ("\\label{" .. id .. "}") or ""
  local figure_env = "\\begin{figure}[htbp]\n\\centering\n"
  local end_env = "\\caption{" .. caption .. "}" .. label .. "\n\\end{figure}"
  
  local graphics_cmd = "\\includegraphics[width=" .. width .. "]{" .. escape_latex_path(path) .. "}"
  
  local latex_code
  if is_landscape then
    latex_code = figure_env .. "\\begin{landscape}\n" .. graphics_cmd .. "\n\\end{landscape}\n" .. end_env
  else
    latex_code = figure_env .. graphics_cmd .. "\n" .. end_env
  end
  
  debug("Academic format: " .. latex_code)
  return latex_code
end

-- Main filter function for images
local function image_filter(elem)
  -- Only process images that have an orientation attribute
  local orientation = elem.attributes and elem.attributes["orientation"]
  if not orientation then
    debug("No orientation specified for image: " .. elem.src)
    return nil -- No changes to image
  end
  
  -- Determine if landscape or portrait
  local is_landscape = orientation:lower() == "landscape"
  debug("Image orientation: " .. orientation)
  
  -- Extract image information
  local path = elem.src
  local caption_text = extract_caption_text(elem.caption)
  local width = elem.attributes.width or "\\linewidth"
  local id = elem.identifier ~= "" and elem.identifier or nil
  
  debug("Image path: " .. path)
  debug("Caption: " .. caption_text)
  debug("Width: " .. width)
  debug("ID: " .. (id or "none"))
  
  -- Format academic figure
  local latex_code = format_academic_figure(id, caption_text, width, path, is_landscape)
  
  -- ALWAYS return as a block element, never inline
  return pandoc.RawBlock("latex", latex_code)
end

-- Return the filter
return {
  {
    Image = image_filter
  }
}
