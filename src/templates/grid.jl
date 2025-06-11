struct GtakGridBackend <: GtakBackend end
function Efus.mount!(_::GtakGridBackend, c::Component)::GtakMount
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
function Efus.update!(_::GtakGridBackend, comp::Component)
  comp.mount === nothing && return
  update!.(comp.children)
end
function Efus.unmount!(_::GtakGridBackend, comp::Component)
  Efus.unmount!.(comp.children)
  if comp.mount !== nothing && comp.mount.widget !== nothing
    # comp.mount.widget === nothing || Gtk4.destroy(comp.mount.widget)
    comp.mount = nothing
  end
end
function childgeometry(
  backend::GtakGridBackend, parent::Component, child::AbstractComponent
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
  GtakGridBackend(),
  [
    :spacing => ESize,
    COMMON_ATTRS...,
  ]
)

