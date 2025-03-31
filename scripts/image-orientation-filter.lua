-- Image Orientation Filter for Pandoc
-- This script processes images with orientation attributes and generates
-- appropriate LaTeX code for scientific and academic templates.

-- Debug mode - set to true for extra logging
local DEBUG = false

-- Helper function for debug logging
local function debug(msg)
  if DEBUG then
    io.stderr:write("[Image Filter Debug] " .. msg .. "\n")
  end
end

-- Helper function to escape LaTeX special characters
local function escape_latex(str)
  -- Escape backslashes first (to prevent double-escaping)
  str = str:gsub("\\", "\\textbackslash{}")
  
  -- Escape other special LaTeX characters
  str = str:gsub("([#$%%&_{}^~])", "\\%1")
  
  -- Handle special brackets and braces
  str = str:gsub("<", "\\textless{}")
  str = str:gsub(">", "\\textgreater{}")
  str = str:gsub("|", "\\textbar{}")
  
  return str
end

-- Helper function to safely handle file paths for LaTeX
local function safe_path(path)
  -- Extract just the filename from path (ignore directory)
  local filename = path:match("([^/\\]+)$") or path
  
  -- If the filename looks like a hash (common with Pandoc temp files),
  -- wrap it in braces to prevent LaTeX from interpreting it
  if filename:match("^[a-f0-9]+%.%w+$") then
    debug("Detected hash-based filename: " .. filename)
    return "{" .. escape_latex(filename) .. "}"
  end
  
  -- Otherwise just escape special characters
  return escape_latex(filename)
end

-- Detect template type based on meta information
local function detect_template(meta)
  -- Check for scientific template indicators
  if meta.documentclass and meta.documentclass == "article" then
    debug("Detected scientific template")
    return "scientific"
  end
  
  -- Check for academic template indicators
  if meta.documentclass and meta.documentclass == "report" then
    debug("Detected academic template")
    return "academic"
  end
  
  -- Default to scientific template
  debug("No specific template detected, using scientific as default")
  return "scientific"
end

-- Get a label from the image attributes or generate one from filename
local function get_label(img)
  -- Try to get label from identifier
  if img.identifier and img.identifier ~= "" then
    return img.identifier
  end
  
  -- Try to get label from attributes
  if img.attributes and img.attributes.id then
    return img.attributes.id
  end
  
  -- Generate label from filename
  local filename = img.src:match("([^/\\]+)%.[^.]+$") or "img"
  return "fig:" .. filename:gsub("%s+", "_"):lower()
end

-- Generate LaTeX figure code for scientific template
local function scientific_figure(img, orientation)
  local width = img.attributes.width or "0.8\\textwidth"
  local label = get_label(img)
  local caption = img.caption and pandoc.utils.stringify(img.caption) or ""
  local path = safe_path(img.src)
  
  debug("Scientific template figure: " .. orientation .. " orientation")
  
  if orientation == "landscape" then
    return string.format("\\landscapefigure{%s}{%s}{%s}{%s}",
                         escape_latex(label),
                         escape_latex(caption),
                         width,
                         path)
  else
    return string.format("\\portraitfigure{%s}{%s}{%s}{%s}",
                         escape_latex(label),
                         escape_latex(caption),
                         width,
                         path)
  end
end

-- Generate LaTeX figure code for academic template
local function academic_figure(img, orientation)
  local width = img.attributes.width or "0.8\\textwidth"
  local label = get_label(img)
  local caption = img.caption and pandoc.utils.stringify(img.caption) or ""
  local path = safe_path(img.src)
  
  debug("Academic template figure: " .. orientation .. " orientation")
  
  if orientation == "landscape" then
    return string.format("\\landscapefigure{%s}{%s}{%s}{%s}",
                         width,
                         escape_latex(label),
                         escape_latex(caption),
                         path)
  else
    return string.format("\\portraitfigure{%s}{%s}{%s}{%s}",
                         width,
                         escape_latex(label),
                         escape_latex(caption),
                         path)
  end
end

-- Main image processing function
local function process_image(img, meta)
  -- Skip processing if no orientation is specified
  if not img.attributes or not img.attributes.orientation then
    debug("No orientation specified for image: " .. img.src)
    return nil
  end

  debug("Processing image: " .. img.src)
  
  -- Get orientation from attributes
  local orientation = img.attributes.orientation:lower()
  if orientation ~= "landscape" and orientation ~= "portrait" then
    debug("Invalid orientation: " .. orientation .. ", defaulting to portrait")
    orientation = "portrait"
  end
  
  -- Detect template type
  local template_type = detect_template(meta)
  
  -- Generate appropriate LaTeX code based on template type
  local latex_code
  if template_type == "scientific" then
    latex_code = scientific_figure(img, orientation)
  else
    latex_code = academic_figure(img, orientation)
  end
  
  debug("Generated LaTeX code: " .. latex_code)
  
  -- Return as a raw block for block-level images or raw inline for inline images
  if img.attributes.placement and img.attributes.placement == "inline" then
    return pandoc.RawInline("latex", latex_code)
  else
    return pandoc.RawBlock("latex", latex_code)
  end
end

-- Register the filter
return {
  {
    Meta = function(meta)
      -- Store metadata for later template detection
      -- This is a closure that other functions can access
      _G.document_meta = meta
      return nil
    end
  },
  {
    Image = function(img)
      return process_image(img, _G.document_meta or {})
    end
  }
}

-- Image Orientation Filter for Pandoc
-- This filter handles image orientation (landscape/portrait) by generating direct LaTeX code
-- instead of relying on template macros and Pandoc's temporary files.

-- Debug function to print messages to stderr
function debug(msg)
  io.stderr:write("[DEBUG] Image-Orientation-Filter: " .. tostring(msg) .. "\n")
end

-- Extract filename from path
function get_filename(path)
  return path:match("([^/\\]+)$")
end

-- Extract extension from filename
function get_extension(filename)
  return filename:match("%.([^%.]+)$")
end

-- Generate a unique ID from the image filename if none is provided
function generate_id(filename)
  return filename:gsub("%.[^%.]+$", ""):gsub("[^%w]", "_")
end

-- Determine if we're using the academic or scientific template
function detect_template(meta)
  -- Check for template indicators in metadata
  if meta.documentclass and meta.documentclass == "article" then
    debug("Detected academic template")
    return "academic"
  else
    debug("Defaulting to scientific template")
    return "scientific"
  end
end

-- The main filter function
function Image(elem)
  -- Skip processing if we're not in LaTeX format
  if FORMAT ~= "latex" then
    return elem
  end

  -- Extract image attributes
  local src = elem.src
  local title = elem.title
  local caption = elem.caption
  local attr = elem.attr or {}
  local identifier = attr.identifier or ""
  local orientation = attr.attributes.orientation or "portrait"
  local width = attr.attributes.width or "0.8\\textwidth"
  
  -- Use the filename to generate an ID if none is provided
  if identifier == "" then
    identifier = generate_id(get_filename(src))
  end
  
  -- Get original filename without path
  local filename = get_filename(src)
  local extension = get_extension(filename)
  
  -- Convert SVG to PDF if needed
  if extension == "svg" then
    filename = filename:gsub("%.svg$", ".pdf")
  end
  
  debug("Processing image: " .. src)
  debug("  - Orientation: " .. orientation)
  debug("  - ID: " .. identifier)
  debug("  - Width: " .. width)
  debug("  - Original filename: " .. filename)
  
  -- Format caption as LaTeX
  local formatted_caption = ""
  if #caption > 0 then
    -- Walk through the caption and convert to string
    local caption_text = pandoc.utils.stringify(caption)
    formatted_caption = caption_text
  end
  
  -- Create direct LaTeX code based on orientation
  local latex_code = ""
  
  if orientation == "landscape" then
    debug("Generating landscape figure environment")
    latex_code = [[
\begin{figure}[htbp]
  \centering
  \begin{sidewaysfigure}
    \centering
    \includegraphics[width=]] .. width .. [[]{]] .. filename .. [[}
    \caption{]] .. formatted_caption .. [[}
    \label{fig:]] .. identifier .. [[}
  \end{sidewaysfigure}
\end{figure}
]]
  else -- portrait
    debug("Generating portrait figure environment")
    latex_code = [[
\begin{figure}[htbp]
  \centering
  \includegraphics[width=]] .. width .. [[]{]] .. filename .. [[}
  \caption{]] .. formatted_caption .. [[}
  \label{fig:]] .. identifier .. [[}
\end{figure}
]]
  end
  
  debug("Generated LaTeX code: \n" .. latex_code)
  
  -- Return a raw LaTeX block
  return pandoc.RawBlock("latex", latex_code)
end

-- Main filter
return {
  {
    Meta = function(meta)
      -- Store template type in global variable for later use
      TEMPLATE_TYPE = detect_template(meta)
      return meta
    end,
    Image = Image
  }
}

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
