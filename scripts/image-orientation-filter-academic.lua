--[[
Image Orientation Filter for Pandoc (Academic Format)

This filter detects the orientation of images (landscape or portrait) from their attributes
and transforms them into the appropriate LaTeX commands for academic template.

The filter ONLY supports academic template format:
  \landscapefigure{width}{label}{caption}{path}
  \portraitfigure{width}{label}{caption}{path}

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

-- Function to handle academic template figures
local function format_academic_figure(id, caption, width, path, is_landscape)
  local latex_cmd = is_landscape and "\\landscapefigure" or "\\portraitfigure"
  local label = id and id or get_filename(path):gsub("%.%w+$", "")
  
  -- Academic template order: {width}{label}{caption}{path}
  local latex_code = string.format(
    "%s{%s}{%s}{%s}{%s}",
    latex_cmd,
    width,
    label,
    caption,
    escape_latex_path(path)
  )
  
  debug("Academic format: " .. latex_code)
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
  local caption = pandoc.utils.stringify(elem.caption)
  local width = elem.attributes.width or "\\linewidth"
  local id = elem.identifier ~= "" and elem.identifier or nil
  
  debug("Image path: " .. path)
  debug("Caption: " .. caption)
  debug("Width: " .. width)
  debug("ID: " .. (id or "none"))
  
  -- Academic format only
  local latex_code = format_academic_figure(id, caption, width, path, is_landscape)
  
  -- Return raw LaTeX
  if elem.parent and elem.parent.t == "Para" then
    -- Image is inline within a paragraph
    return pandoc.RawInline("latex", latex_code)
  else
    -- Image is a block element
    return pandoc.RawBlock("latex", latex_code)
  end
end

-- Return the filter
return {
  {
    Image = image_filter
  }
}

