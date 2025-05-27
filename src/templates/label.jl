struct GtakLabelBackend <: GtakBackend end
function Efus.mount!(_::GtakLabelBackend, c::Component)::GtakMount
  label = GtkLabel(c[:text])
  c[:selectable] !== nothing && GAccessor.selectable(label, c[:selectable])
  c[:linewrap] !== nothing && GAccessor.selectable(label, c[:linewrap])
  c.mount = GtakMount(label)
end
function Efus.update!(_::GtakLabelBackend, comp::Component)
  comp.mount === nothing && return
  GAccessor.text(comp.mount.widget, comp[:text])
end

GtakLabel = Template(
  :Label,
  GtakLabelBackend(),
  [
    :text! => String,
    :selectable => Bool,
    :justify => ESide,
    :linewrap => Bool,
  ]
)
registertemplate(:Gtak, GtakLabel)

