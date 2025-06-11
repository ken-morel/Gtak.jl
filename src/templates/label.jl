struct GtakLabelBackend <: GtakBackend end
function Efus.mount!(_::GtakLabelBackend, c::Component)::GtakMount
  args = []
  label = GtkLabel(":-)"; args...)
  c[:text] isa String && Gtk4.text(label, c[:text])
  c[:markup] isa String && Gtk4.markup(label, c[:markup])
  c.mount = GtakMount(label)
  if c.parent !== nothing
    childgeometry(c.parent, c)
  end
  c.mount
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

GtakLabel = EfusTemplate(
  :Label,
  GtakLabelBackend(),
  [
    :text => String,
    :markup => String,
    COMMON_ATTRS...,
  ]
)

