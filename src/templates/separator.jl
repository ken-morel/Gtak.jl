struct GtakSeparatorBackend <: GtakBackend end
function Efus.mount!(c::Component{GtakSeparatorBackend})::GtakMount
  args = Pair[]
  addcommonargs!(args, c)
  orient = (Symbol ∘ first ∘ String)(c[:orient].orient)
  box = GtkSeparator(orient; args...)
  c.mount = GtakMount(box)
  for child ∈ c.children
    mount!(child)
  end
  if !isnothing(c.parent)
    childgeometry(c.parent, c)
  end
  c.mount
end


GtakSeparator = EfusTemplate(
  :Separator,
  GtakSeparatorBackend,
  TemplateParameter[
    :orient! => EOrient,
    COMMON_ATTRS...,
  ]
)

