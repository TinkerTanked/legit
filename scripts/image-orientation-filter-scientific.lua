--[[
Image Orientation Filter for Pandoc (Scientific Format)

This filter detects the orientation of images (landscape or portrait) from their attributes
and transforms them into the appropriate LaTeX commands for scientific template.

The filter ONLY supports scientific template format:
  \landscapefigure{label}{caption}{width}{path}
  \portraitfigure{label}{caption}{width}{path}

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

-- Function to extract just the filename from a path
local function get_filename(path)
  return path:match("([^/\\]+)$") or path
end

-- Function to escape special characters in LaTeX paths
local function escape_latex_path(path)
  -- Escape LaTeX special characters
  local escaped = path:gsub("([#$%%&_{}^~\\])", "\\%1")
  
  -- For hash-based filenames, add extra protection with braces
  if escaped:match("%x%x%x%x%x%x+") then
    escaped = "{" .. escaped .. "}"
  end
  
  return escaped
end

-- Function to handle scientific template figures
local function format_scientific_figure(id, caption, width, path, is_landscape)
  local latex_cmd = is_landscape and "\\landscapefigure" or "\\portraitfigure"
  local label = id and id or get_filename(path):gsub("%.%w+$", "")
  
  -- Scientific template order: {label}{caption}{width}{path}
  local latex_code = string.format(
    "%s{%s}{%s}{%s}{%s}",
    latex_cmd,
    label,
    caption,
    width,
    escape_latex_path(path)
  )
  
  debug("Scientific format: " .. latex_code)
  return latex_code
end

-- Main filter function for images
local function image_filter(elem)
  -- Check if image has orientation attribute
  local orientation = elem.attributes["orientation"]
  if not orientation then
    debug("No orientation specified for image: " .. elem.src)
    return nil -- No changes to image
  end
  
  -- Determine if landscape or portrait
  local is_landscape = orientation:lower() == "landscape"
  debug("Image orientation: " .. orientation)
  
  -- Extract image information
  local path = elem.src
  
  -- Safer caption extraction with multiple fallback methods
  local caption = ""
  if elem.caption then
    if type(elem.caption) == "string" then
      caption = elem.caption
    elseif pandoc.utils and pandoc.utils.stringify then
      -- Use pandoc.utils.stringify if available
      caption = pandoc.utils.stringify(elem.caption)
    else
      -- Fallback method - try to extract from a table
      if type(elem.caption) == "table" then
        if elem.caption[1] and elem.caption[1].text then
          caption = elem.caption[1].text
        end
      end
    end
  end
  
  local width = elem.attributes.width or "\\linewidth"
  local id = elem.identifier ~= "" and elem.identifier or nil
  
  debug("Image path: " .. path)
  debug("Caption: " .. caption)
  debug("Width: " .. width)
  debug("ID: " .. (id or "none"))
  
  -- Scientific format only
  local latex_code = format_scientific_figure(id, caption, width, path, is_landscape)
  
  -- Return raw LaTeX
  -- Check if image is inline or block
  local isInline = false
  
  -- Safer parent element check
  if elem.parent then
    if elem.parent.t == "Para" and #elem.parent.content == 1 then
      -- Single image in a paragraph - treat as block
      isInline = false
    elseif elem.parent.t == "Para" then
      -- Image within text in a paragraph - treat as inline
      isInline = true
    end
  end
  
  debug("Image is " .. (isInline and "inline" or "block"))
  
  if isInline then
    debug("Returning RawInline")
    return pandoc.RawInline("latex", latex_code)
  else
    debug("Returning RawBlock")
    return pandoc.RawBlock("latex", latex_code)
  end
end

-- Return the filter
return {
  {
    Image = image_filter
  }
}

