struct GtakBoxBackend <: GtakBackend end
function Efus.mount!(c::Component{GtakBoxBackend})::GtakMount
  args = Pair[]
  addcommonargs!(args, c)
  orient = (Symbol ∘ first ∘ String)(c[:orient].orient)
  box = GtkBox(orient; args...)
  c.mount = GtakMount(box)
  for child ∈ c.children
    mount!(child)
  end
  if !isnothing(c.parent)
    childgeometry(c.parent, c)
  end
  c.mount
end


GtakBox = EfusTemplate(
  :Box,
  GtakBoxBackend,
  TemplateParameter[
    :orient! => EOrient,
    COMMON_ATTRS...,
  ]
)

