struct GtakFrameBackend <: GtakBackend end
function Efus.mount!(_::GtakFrameBackend, c::Component)::GtakMount
  args = Pair[]
  addcommonargs!(args, c)
  frame = GtkFrame(; args...)
  c.mount = GtakMount(frame)
  for child ∈ c.children
    mount!(child)
  end
  if c.parent !== nothing
    childgeometry(c.parent, c)
  end
  c.mount
end
function Efus.update!(_::GtakFrameBackend, comp::Component)
  comp.mount === nothing && return
  update!.(comp.children)
end
function Efus.unmount!(_::GtakFrameBackend, comp::Component)
  Efus.unmount!.(comp.children)
  if comp.mount !== nothing && comp.mount.widget !== nothing
    # comp.mount.widget === nothing || Gtk4.destroy(comp.mount.widget)
    comp.mount = nothing
  end
end
function childgeometry(
  backend::GtakFrameBackend, parent::Component, child::AbstractComponent
)
  parent.mount.outlet[] = inlet(child).mount.widget
end

GtakFrame = EfusTemplate(
  :Frame,
  GtakFrameBackend(),
  [
    COMMON_ATTRS...,
  ]
)

