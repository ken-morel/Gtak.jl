struct GtakBoxBackend <: GtakBackend end
function Efus.mount!(_::GtakBoxBackend, c::Component)::GtakMount
  box = (GtkBox ∘ Symbol ∘ first ∘ String)(c[:orient].orient)
  c.mount = GtakMount(box)
  for child ∈ c.children
    mount!(child)
  end
  if c.parent !== nothing && c.parent.mount !== nothing && c.parent.mount.outlet !== nothing
    push!(c.parent.mount.outlet, box)
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

GtakBox = Template(
  :Box,
  GtakBoxBackend(),
  [
    :orient! => EOrient,
  ]
)

