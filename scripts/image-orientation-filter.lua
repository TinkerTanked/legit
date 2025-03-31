-- image-orientation-filter.lua
-- A Pandoc Lua filter to handle image orientation in LaTeX output
-- with proper handling of hash-based filenames

-- Function to escape LaTeX special characters in filenames
function escape_latex(s)
  -- Replace backslashes first to avoid double-escaping
  s = s:gsub("\\", "\\textbackslash ")
  
  -- Escape other special LaTeX characters
  s = s:gsub("([#$%%&_{}^~])", "\\%1")
  
  -- Special handling for hashes in filenames
  s = s:gsub("%-", "\\-")
  
  return s
end

-- Function to extract just the filename from a path
function get_filename(path)
  return path:match("([^/\\]+)$") or path
end

-- Function to sanitize filenames to avoid LaTeX issues with hash-based names
function sanitize_filename(path)
  -- Extract the base filename (without directory path)
  local filename = get_filename(path)
  
  -- Check if it looks like a hash-based filename
  if filename:match("^[0-9a-f]+%.pdf$") or filename:match("^%.+[0-9a-f]+%.pdf$") then
    -- For hash-based names, use a simplified approach that avoids special characters
    return "{" .. escape_latex(filename) .. "}"
  else
    -- For normal filenames, just escape LaTeX special characters
    return "{" .. escape_latex(filename) .. "}"
  end
end

-- Function to generate a unique ID for an image if none is provided
function generate_id(src)
  -- Extract base filename without extension
  local base = get_filename(src):gsub("%.%w+$", "")
  -- Remove any special characters that might cause issues
  base = base:gsub("[^%w]", "_")
  return base
end

-- Main image processing function
function Image(img)
  -- Only apply this filter to LaTeX output
  if FORMAT ~= "latex" and FORMAT ~= "beamer" then
    return nil
  end
  
  -- Get the image attributes
  local src = img.src
  local caption = img.caption or {}
  local id = img.identifier or generate_id(src)
  local classes = img.classes or {}
  local width = img.attributes.width or "\\linewidth"
  local orientation = img.attributes.orientation or "portrait"
  
  -- Determine which template style is being used (academic or scientific)
  -- by checking for specific metadata or environment variables
  local is_scientific = false
  if PANDOC_WRITER_OPTIONS and PANDOC_WRITER_OPTIONS.variables then
    is_scientific = PANDOC_WRITER_OPTIONS.variables.documentclass == "article" or 
                    PANDOC_WRITER_OPTIONS.variables.template == "scientific-paper"
  end
  
  -- Convert caption to plain text
  local caption_text = ""
  for _, v in pairs(caption) do
    if v.text then
      caption_text = caption_text .. v.text
    end
  end
  
  -- Prepare the LaTeX code for the image
  local tex = ""
  
  -- Use sanitized filename to avoid issues with hash-based names
  local safe_src = sanitize_filename(src)
  
  -- Handle image orientation based on template
  if orientation == "landscape" then
    if is_scientific then
      -- Scientific template: \landscapefigure{label}{caption}{width}{path}
      tex = string.format("\\landscapefigure{%s}{%s}{%s}%s",
                          id, caption_text, width, safe_src)
    else
      -- Academic template: \landscapefigure{width}{label}{caption}{path}
      tex = string.format("\\landscapefigure{%s}{%s}{%s}%s",
                          width, id, caption_text, safe_src)
    end
  else
    -- Portrait orientation
    if is_scientific then
      -- Scientific template: \portraitfigure{label}{caption}{width}{path}
      tex = string.format("\\portraitfigure{%s}{%s}{%s}%s",
                          id, caption_text, width, safe_src)
    else
      -- Academic template: \portraitfigure{width}{label}{caption}{path}
      tex = string.format("\\portraitfigure{%s}{%s}{%s}%s",
                          width, id, caption_text, safe_src)
    end
  end
  
  -- Return a raw LaTeX code block
  return pandoc.RawInline('latex', tex)
end

-- Use a special handling for the Pandoc Meta element to detect template type
function Meta(meta)
  -- Store the template type in a global variable for later use
  if meta.template then
    local template = pandoc.utils.stringify(meta.template)
    if template:match("scientific") then
      is_scientific = true
    else
      is_scientific = false
    end
  end
  return nil
end

-- Return the filter
return {
  { Meta = Meta },
  { Image = Image }
}

-- Image Orientation filter for Pandoc
-- This filter detects images with 'landscape' or 'portrait' orientation attributes and
-- formats them appropriately for LaTeX output based on the template being used
-- It handles special commands for different templates with robust handling of temp filenames

-- Variable to track which template is being used
local template_type = "default"

-- Debug mode - set to true to see more information in the LaTeX log
local DEBUG = false

-- Function to print debug messages
function debug(message)
  if DEBUG then
    io.stderr:write("[Image Filter Debug] " .. message .. "\n")
  end
end

-- Function to strip hash-based filename patterns that Pandoc generates
-- These filenames can cause LaTeX to fail with "Missing \endcsname" errors
function clean_hash_filename(path)
  -- If the path contains suspicious hash patterns (like those Pandoc generates in temp files)
  -- Matches patterns like: image-name-67dfe07e4a59209bc647d03d3266362b08d.pdf
  if path:match("[a-f0-9]{32}%.") or path:match("[a-f0-9]{40}%.") then
    -- Extract the last part of the path (filename)
    local filename = path:match("([^/\\]+)$") or path
    
    -- If the filename has an extension at the end
    local base, ext = filename:match("(.+)%.([^%.]+)$")
    if base and ext then
      -- For academic template, use the landscapefigure command
      -- Expected format: \landscapefigure{width}{label}{caption}{path}
      local latex_code = "\\\\landscapefigure"
      
      -- Add the parameters in the correct order for academic template
      latex_code = latex_code .. "{" .. width .. "}"
      latex_code = latex_code .. "{" .. img_id .. "}"
      latex_code = latex_code .. "{" .. caption .. "}"
      latex_code = latex_code .. "{" .. escaped_filename .. "}"
      
      -- Return raw LaTeX block
      return pandoc.RawInline('latex', latex_code)
      
    elseif template_type == "scientific" then
      -- For scientific template, use the landscapefigure command
      -- Expected format: \landscapefigure{label}{caption}{width}{path}
      local latex_code = "\\\\landscapefigure"
      
      -- Add the parameters in the correct order for scientific template
      latex_code = latex_code .. "{" .. img_id .. "}"
      latex_code = latex_code .. "{" .. caption .. "}"
      latex_code = latex_code .. "{" .. width .. "}"
      latex_code = latex_code .. "{" .. escaped_filename .. "}"
      
      -- Return raw LaTeX block
      return pandoc.RawInline('latex', latex_code)
      
    else
      -- Default template - use standard figure environment with rotated content
      local latex_code = "\\\\begin{figure}[htbp]\n"
      latex_code = latex_code .. "  \\\\centering\n"
      latex_code = latex_code .. "  \\\\begin{sideways}\n"
      latex_code = latex_code .. "    \\\\includegraphics[width=" .. width .. "]{" .. escaped_filename .. "}\n"
      latex_code = latex_code .. "  \\\\end{sideways}\n"
      if caption ~= "" then
        latex_code = latex_code .. "  \\\\caption{" .. caption .. "}\n"
      end
      if img_id ~= "" then
        latex_code = latex_code .. "  \\\\label{" .. img_id .. "}\n"
      end
      latex_code = latex_code .. "\\\\end{figure}"
      
      -- Return raw LaTeX block
      return pandoc.RawInline('latex', latex_code)
    end
    
  elseif elem.attributes.orientation == "portrait" then
    debug("Detected portrait orientation")
    
    if template_type == "academic" then
      -- For academic template, use the portraitfigure command
      -- Expected format: \portraitfigure{width}{label}{caption}{path}
      local latex_code = "\\\\portraitfigure"
      
      -- Add the parameters in the correct order for academic template
      latex_code = latex_code .. "{" .. width .. "}"
      latex_code = latex_code .. "{" .. img_id .. "}"
      latex_code = latex_code .. "{" .. caption .. "}"
      latex_code = latex_code .. "{" .. escaped_filename .. "}"
      
      -- Return raw LaTeX block
      return pandoc.RawInline('latex', latex_code)
      
    elseif template_type == "scientific" then
      -- For scientific template, use the portraitfigure command
      -- Expected format: \portraitfigure{label}{caption}{width}{path}
      local latex_code = "\\\\portraitfigure"
      
      -- Add the parameters in the correct order for scientific template
      latex_code = latex_code .. "{" .. img_id .. "}"
      latex_code = latex_code .. "{" .. caption .. "}"
      latex_code = latex_code .. "{" .. width .. "}"
      latex_code = latex_code .. "{" .. escaped_filename .. "}"
      
      -- Return raw LaTeX block
      return pandoc.RawInline('latex', latex_code)
      
    else
      -- Default template - use standard figure environment
      local latex_code = "\\\\begin{figure}[htbp]\n"
      latex_code = latex_code .. "  \\\\centering\n"
      latex_code = latex_code .. "  \\\\includegraphics[width=" .. width .. "]{" .. escaped_filename .. "}\n"
      if caption ~= "" then
        latex_code = latex_code .. "  \\\\caption{" .. caption .. "}\n"
      end
      if img_id ~= "" then
        latex_code = latex_code .. "  \\\\label{" .. img_id .. "}\n"
      end
      latex_code = latex_code .. "\\\\end{figure}"
      
      -- Return raw LaTeX block
      return pandoc.RawInline('latex', latex_code)
    end
    
  else
    -- For images with no specified orientation, use a standard figure
    debug("No orientation specified, using default")
    
    if template_type == "academic" then
      -- For academic template, use the figure command
      -- Expected format: \figure{width}{label}{caption}{path}
      local latex_code = "\\\\figure"
      
      -- Add the parameters in the correct order for academic template
      latex_code = latex_code .. "{" .. width .. "}"
      latex_code = latex_code .. "{" .. img_id .. "}"
      latex_code = latex_code .. "{" .. caption .. "}"
      latex_code = latex_code .. "{" .. escaped_filename .. "}"
      
      -- Return raw LaTeX block
      return pandoc.RawInline('latex', latex_code)
      
    elseif template_type == "scientific" then
      -- For scientific template, use the figure command
      -- Expected format: \figure{label}{caption}{width}{path}
      local latex_code = "\\\\figure"
      
      -- Add the parameters in the correct order for scientific template
      latex_code = latex_code .. "{" .. img_id .. "}"
      latex_code = latex_code .. "{" .. caption .. "}"
      latex_code = latex_code .. "{" .. width .. "}"
      latex_code = latex_code .. "{" .. escaped_filename .. "}"
      
      -- Return raw LaTeX block
      return pandoc.RawInline('latex', latex_code)
      
    else
      -- Default template - use standard figure environment
      local latex_code = "\\\\begin{figure}[htbp]\n"
      latex_code = latex_code .. "  \\\\centering\n"
      latex_code = latex_code .. "  \\\\includegraphics[width=" .. width .. "]{" .. escaped_filename .. "}\n"
      if caption ~= "" then
        latex_code = latex_code .. "  \\\\caption{" .. caption .. "}\n"
      end
      if img_id ~= "" then
        latex_code = latex_code .. "  \\\\label{" .. img_id .. "}\n"
      end
      latex_code = latex_code .. "\\\\end{figure}"
      
      -- Return raw LaTeX block
      return pandoc.RawInline('latex', latex_code)
    end
  end
end

-- Return the filter functions
return {
  {
    Meta = determine_template,  -- Run first to determine template type
    Image = Image               -- Then process images
  }
}
      debug("Cleaned hash filename: " .. filename .. " -> " .. clean_base .. "." .. ext)
      return clean_base .. "." .. ext
    end
  end
  
  return path
end

-- Function to extract just the filename part of a path
function get_filename(path)
  -- Extract just the filename part without directory
  local filename = path:match("([^/\\]+)$") or path
  -- Clean any hash-based filenames
  return clean_hash_filename(filename)
end

-- Function to extract the base filename (without extension) from a path
function get_base_filename(path)
  -- Get the clean filename first
  local filename = get_filename(path)
  -- Remove extension
  local base_filename = filename:match("(.+)%..+$") or filename
  return base_filename
end

-- Function to escape special LaTeX characters in text
function escape_latex(text)
  -- LaTeX special characters that need escaping: # $ % & _ ^ ~ \ { }
  local escaped = text:gsub("([#$%%&_{}^~\\])", "\\%1")
  -- Additionally escape any hash-based paths more aggressively
  escaped = escaped:gsub("([a-f0-9])%-([a-f0-9])%-([a-f0-9])%-([a-f0-9])", "%1%2%3%4")
  return escaped
end

-- Function to determine the template from metadata
function determine_template(meta)
  if meta.template then
    local template_path = pandoc.utils.stringify(meta.template)
    debug("Template path: " .. template_path)
    
    if template_path:find("academic%-paper%.tex") then
      template_type = "academic"
    elseif template_path:find("scientific%-paper%.tex") then
      template_type = "scientific"
    else
      template_type = "default"
    end
    
    debug("Using template type: " .. template_type)
  end
  return meta
end

-- Function to process images based on orientation
function Image(elem)
  -- First, check if this is a LaTeX output format
  local format = pandoc.format()
  if not format:match("latex") and not format:match("pdf") then
    return nil  -- No need to process for non-LaTeX formats
  end

  -- Get the caption as string (properly escaped)
  local caption = ""
  if elem.caption then
    caption = pandoc.utils.stringify(elem.caption)
    caption = escape_latex(caption)
  end
  
  -- Get the image path
  local image_path = elem.src
  
  -- Extract and clean the filename for LaTeX
  local filename = get_filename(image_path)
  local escaped_filename = escape_latex(filename)
  
  debug("Processing image: " .. image_path)
  debug("Cleaned filename: " .. escaped_filename)
  
  -- Get the image ID for cross-references (from the #fig:xxx attribute)
  local img_id = ""
  if elem.identifier and elem.identifier ~= "" then
    img_id = elem.identifier
    debug("Image ID: " .. img_id)
  else
    -- Generate an ID from the filename if none exists
    img_id = "fig:" .. get_base_filename(image_path):gsub("[^a-zA-Z0-9]", "")
    debug("Generated ID: " .. img_id)
  end
  
  -- Handle width attribute
  local width = elem.attributes.width or 
                (elem.attributes.orientation == "landscape" and "100%" or "70%")
  
  -- Check if the image has orientation attributes
  if elem.attributes.orientation == "landscape" then
    debug("Detected landscape orientation")
    
    if template_type == "academic" then
      -- For academic template, use the landscapefigure command
      -- Expected format: \landscapefigure{width}{label}{caption}{path}
      local latex_code = "\\landscapefigure"
      
      -- Ad
