-- Image Orientation filter for Pandoc
-- This filter detects images with 'landscape' or 'portrait' orientation attributes and
-- formats them appropriately for LaTeX output based on the template being used
-- It handles special commands for the academic template and standard formatting for others

-- Variable to track which template is being used
local template_type = "default"

-- Function to extract the base filename (without extension) from a path
function get_base_filename(path)
  -- Extract just the filename part without directory
  local filename = path:match("([^/\\]+)$") or path
  
  -- Remove extension
  local base_filename = filename:match("(.+)%..+$") or filename
  
  return base_filename
end

-- Function to determine the template from metadata
function determine_template(meta)
  if meta.template then
    local template_path = pandoc.utils.stringify(meta.template)
    if template_path:find("academic%-paper%.tex") then
      template_type = "academic"
    elseif template_path:find("scientific%-paper%.tex") then
      template_type = "scientific"
    else
      template_type = "default"
    end
  end
  return meta
end

-- Function to process images based on orientation
function Image(elem)
  -- Get the caption as string
  local caption = elem.caption and pandoc.utils.stringify(elem.caption) or ""
  
  -- Get the image path
  local image_path = elem.src
  
  -- Get the image ID for cross-references (from the #fig:xxx attribute)
  local img_id = ""
  if elem.identifier and elem.identifier ~= "" then
    img_id = elem.identifier
  end
  
  -- Check if the image has the landscape orientation attribute
  if elem.attributes.orientation == "landscape" then
    -- Set width to 100% for landscape images if not already specified
    elem.attributes.width = elem.attributes.width or "100%"
    
    if template_type == "academic" then
      -- For academic template, use the \landscapefigure command
      local latex_code = "\\landscapefigure"
      if img_id ~= "" then
        -- Add label for cross-referencing
        latex_code = latex_code .. "[" .. img_id .. "]"
      end
      
      -- Extract base filename for label but use full path for the image
      local base_filename = get_base_filename(image_path)
      
      latex_code = latex_code .. "{" .. elem.attributes.width .. "}{" .. 
                   base_filename .. "}{" .. caption .. "}{" .. image_path .. "}"
      
      return pandoc.RawInline("latex", latex_code)
    else
      -- For scientific template or others, use the landscape environment
      local latex_figure = "\\begin{figure}[htbp]\\centering"
      if img_id ~= "" then
        -- Add label for cross-referencing
        latex_figure = latex_figure .. "\\label{" .. img_id .. "}"
      end
      
      -- Return a new Para element containing LaTeX code
      return pandoc.Para({
        pandoc.RawBlock("latex", "\\begin{landscape}"),
        pandoc.RawInline("latex", latex_figure),
        elem,
        pandoc.RawInline("latex", "\\caption{" .. caption .. "}\\end{figure}"),
        pandoc.RawBlock("latex", "\\end{landscape}")
      })
    end
  -- Check if the image has the portrait orientation attribute
  elseif elem.attributes.orientation == "portrait" then
    -- Set width for portrait images if not already specified
    elem.attributes.width = elem.attributes.width or "70%"
    
    if template_type == "academic" then
      -- For academic template, use the \portraitfigure command
      local latex_code = "\\portraitfigure"
      if img_id ~= "" then
        -- Add label for cross-referencing
        latex_code = latex_code .. "[" .. img_id .. "]"
      end
      
      -- Extract base filename for label but use full path for the image
      local base_filename = get_base_filename(image_path)
      
      latex_code = latex_code .. "{" .. elem.attributes.width .. "}{" .. 
                   base_filename .. "}{" .. caption .. "}{" .. image_path .. "}"
      
      return pandoc.RawInline("latex", latex_code)
    else
      -- For scientific template or others, use standard figure formatting
      local latex_figure = "\\begin{figure}[htbp]\\centering"
      if img_id ~= "" then
        -- Add label for cross-referencing
        latex_figure = latex_figure .. "\\label{" .. img_id .. "}"
      end
      
      -- Return a new Para element containing LaTeX code
      return pandoc.Para({
        pandoc.RawInline("latex", latex_figure),
        elem,
        pandoc.RawInline("latex", "\\caption{" .. caption .. "}\\end{figure}")
      })
    end
  end
  
  -- If no specific orientation, return nil to keep original processing
  return nil
end

-- Register the Meta filter to determine template type
return {
  { Meta = determine_template },
  { Image = Image }
}
