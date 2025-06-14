struct GtakFrameBackend <: GtakBackend end
function Efus.mount!(c::Component{GtakFrameBackend})::GtakMount
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
function Efus.update!(comp::Component{GtakFrameBackend})
  comp.mount === nothing && return
  update!.(comp.children)
end
function Efus.unmount!(comp::Component{GtakFrameBackend})
  Efus.unmount!.(comp.children)
  if comp.mount !== nothing && comp.mount.widget !== nothing
    # comp.mount.widget === nothing || Gtk4.destroy(comp.mount.widget)
    comp.mount = nothing
  end
end
function childgeometry(
  parent::Component{GtakFrameBackend}, child::AbstractComponent
)
  parent.mount.outlet[] = inlet(child).mount.widget
end

GtakFrame = EfusTemplate(
  :Frame,
  GtakFrameBackend,
  TemplateParameter[
    COMMON_ATTRS...,
  ]
)

