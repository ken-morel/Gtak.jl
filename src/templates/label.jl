struct GtakLabelBackend <: GtakBackend end
function Efus.mount!(_::GtakLabelBackend, c::Component)::GtakMount
  label = GtkLabel(":-)")
  c[:text] isa String && Gtk4.text(label, c[:text])
  c[:markup] isa String && Gtk4.markup(label, c[:markup])
  if c.parent !== nothing
    parent = outlet(c.parent)
    if parent !== nothing && parent.mount !== nothing && parent.mount.outlet !== nothing
      push!(parent.mount.outlet, label)
    end
  end
  c.mount = GtakMount(label)
end
function Efus.update!(_::GtakLabelBackend, c::Component)
  isnothing(c.mount) && return
  isnothing(c.mount.widget) && return
  c[:text] isa String && Gtk4.text(c.mount.widget, c[:text])
  c[:markup] isa String && Gtk4.markup(c.mount.widget, c[:markup])

end
function Efus.unmount!(_::GtakLabelBackend, comp::Component)
  Efus.unmount!.(comp.children)
  if comp.mount !== nothing && comp.mount.widget !== nothing
    # comp.mount.widget === nothing || destroy(comp.mount.widget)
    comp.mount = nothing
  end
end

GtakLabel = Template(
  :Label,
  GtakLabelBackend(),
  [
    :text => String,
    :markup => String,
  ]
)

