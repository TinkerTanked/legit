--[[
Image Orientation Filter for Pandoc

This filter detects the orientation of images (landscape or portrait) from their attributes
and transforms them into appropriate LaTeX commands based on the template being used.

The filter supports two template types:
1. Scientific template: \landscapefigure{label}{caption}{width}{path}
2. Academic template: \landscapefigure{width}{label}{caption}{path}

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

-- Function to determine if we're using the scientific template
local function is_scientific_template(meta)
  -- Check metadata for template type
  if meta.template then
    local template = pandoc.utils.stringify(meta.template)
    debug("Template: " .. template)
    return template:match("scientific") ~= nil
  end
  
  -- Default to scientific if not specified
  debug("No template specified, defaulting to scientific")
  return true
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
function Image(elem)
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
  
  -- Always use scientific format for this file
  local latex_code = format_scientific_figure(id, caption, width, path, is_landscape)
  
  -- Return raw LaTeX
  if elem.parent and elem.parent.t == "Para" then
    -- Image is inline within a paragraph
    return pandoc.RawInline("latex", latex_code)
  else
    -- Image is a block element
    return pandoc.RawBlock("latex", latex_code)
  end
end

-- Function to handle metadata (kept for compatibility, not used in this version)
function Meta(meta)
  -- For scientific format, we don't need to check the metadata
  return nil
end

-- Return the filter
return {
  {
    Meta = Meta,
    Image = Image
  }
}

