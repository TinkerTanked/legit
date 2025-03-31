-- Landscape filter for Pandoc
-- This filter detects images with a 'landscape' orientation attribute and
-- wraps them in a landscape environment for LaTeX output

function Image(elem)
  -- Check if the image has the landscape orientation attribute
  if elem.attributes.orientation == "landscape" then
    -- Set width to 100% for landscape images
    elem.attributes.width = "100%"
    
    -- Return a new Para element containing LaTeX code to start landscape environment,
    -- properly format the figure, include the image, add caption, and close the environment
    return pandoc.Para({
      pandoc.RawBlock("latex", "\\begin{landscape}"),
      pandoc.RawInline("latex", "\\begin{figure}[htbp]\\centering"),
      elem,
      pandoc.RawInline("latex", "\\caption{" .. (elem.caption and pandoc.utils.stringify(elem.caption) or "") .. "}\\end{figure}"),
      pandoc.RawBlock("latex", "\\end{landscape}")
    })
  end
  
  -- If not a landscape image, return nil to keep original processing
  return nil
end

