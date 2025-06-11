struct GtakBoxBackend <: GtakBackend end
function Efus.mount!(_::GtakBoxBackend, c::Component)::GtakMount
  args = Pair[]
  addcommonargs!(args, c)
  orient = (Symbol ∘ first ∘ String)(c[:orient].orient)
  box = GtkBox(orient; args...)
  c.mount = GtakMount(box)
  for child ∈ c.children
    mount!(child)
  end
  if c.parent !== nothing
    childgeometry(c.parent, c)
  end
  c.mount
end
function Efus.update!(_::GtakBoxBackend, comp::Component)
  comp.mount === nothing && return
  update!.(comp.children)
end
function Efus.unmount!(_::GtakBoxBackend, comp::Component)
  Efus.unmount!.(comp.children)
  if comp.mount !== nothing && comp.mount.widget !== nothing
    # comp.mount.widget === nothing || Gtk4.destroy(comp.mount.widget)
    comp.mount = nothing
  end
end

GtakBox = EfusTemplate(
  :Box,
  GtakBoxBackend(),
  [
    :orient! => EOrient,
    COMMON_ATTRS...,
  ]
)

