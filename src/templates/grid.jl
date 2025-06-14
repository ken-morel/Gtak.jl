struct GtakGridBackend <: GtakBackend end
function Efus.mount!(c::Component{GtakGridBackend})::GtakMount
  args = Pair[]
  addcommonargs!(args, c)
  grid = GtkGrid(; args...)
  c.mount = GtakMount(grid)
  for child ∈ c.children
    mount!(child)
  end
  if c.parent !== nothing
    childgeometry(c.parent, c)
  end
  c.mount
end
function childgeometry(
  parent::Component{GtakGridBackend}, child::AbstractComponent
)
  attach = child[:attach]
  if attach isa ESquareGeometry
    parent.mount.outlet[
      abs(attach.pos[1]):abs(attach.pos[1] + attach.size[1] - 1),
      abs(attach.pos[2]):abs(attach.pos[2] + attach.size[2] - 1)
    ] = inlet(child).mount.widget
  end
end

GtakGrid = EfusTemplate(
  :Grid,
  GtakGridBackend,
  TemplateParameter[
    :spacing=>ESize,
    COMMON_ATTRS...,
  ]
)

