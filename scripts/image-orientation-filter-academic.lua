--[[
Debug Image Orientation Filter for Pandoc (Academic Format)

Extremely simplified and defensive version with extensive debug logging.
]]--

-- Enable debug mode
local DEBUG = true

-- Debug logging
local function debug(msg)
  if DEBUG then
    io.stderr:write("[DEBUG] " .. msg .. "\n")
  end
end

debug("Filter loaded - Pandoc version: " .. tostring(PANDOC_VERSION or "unknown"))

-- Super simple filtering function
-- Always returns unmodified image to avoid any metamethod issues
function Image(elem)
  debug("Image encountered: " .. (elem.src or "unknown source"))
  
  -- Just log information without modifying anything
  if elem.attributes and elem.attributes["orientation"] then
    debug("  Orientation: " .. elem.attributes["orientation"])
  else
    debug("  No orientation attribute")
  end
  
  if elem.identifier and elem.identifier ~= "" then
    debug("  ID: " .. elem.identifier)
  else
    debug("  No identifier")
  end
  
  -- Log caption info
  debug("  Caption type: " .. type(elem.caption))
  if type(elem.caption) == "table" then
    debug("  Caption table length: " .. #elem.caption)
  end
  
  -- Return the element unmodified - this should never cause issues
  return elem
end

-- Return the filter
return {
  { Image = Image }
}
