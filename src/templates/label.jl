struct GtakLabelBackend <: GtakBackend end
function Efus.mount!(c::Component{GtakLabelBackend})::GtakMount
  args = Pair[]
  addcommonargs!(args, c)
  label = GtkLabel(":-)"; args...)
  c[:text] isa String && Gtk4.text(label, c[:text])
  c[:markup] isa String && Gtk4.markup(label, c[:markup])
  c.mount = GtakMount(label)
  if c.parent !== nothing
    childgeometry(c.parent, c)
  end
  c.mount
end
function Efus.update!(c::Component{GtakLabelBackend})
  isnothing(c.mount) && return
  isnothing(c.mount.widget) && return
  c[:text] isa String && Gtk4.text(c.mount.widget, c[:text])
  c[:markup] isa String && Gtk4.markup(c.mount.widget, c[:markup])

end
GtakLabel = EfusTemplate(
  :Label,
  GtakLabelBackend,
  TemplateParameter[
    :text=>String,
    :markup=>String,
    COMMON_ATTRS...,
  ]
)

