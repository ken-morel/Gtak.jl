struct GtakLabelBackend <: GtakBackend end
function Efus.mount!(_::GtakLabelBackend, c::Component)::GtakMount
  label = GtkLabel(c[:text])
  println("adding label")
  if c.parent !== nothing
    parent = outlet(c.parent)
    println("outlet")
    println("mount: ", typeof(parent.mount))
    println("outlet: ", typeof(parent.mount.outlet))
    println("printed")
    if parent !== nothing && parent.mount !== nothing && parent.mount.outlet !== nothing
      push!(parent.mount.outlet, label)
    end
  end
  c[:selectable] !== nothing && GAccessor.selectable(label, c[:selectable])
  c[:linewrap] !== nothing && GAccessor.selectable(label, c[:linewrap])
  c.mount = GtakMount(label)
end
function Efus.update!(_::GtakLabelBackend, comp::Component)
  comp.mount === nothing && return
  GAccessor.text(comp.mount.widget, comp[:text])
end
function Efus.unmount!(_::GtakLabelBackend, comp::Component)
  Efus.unmount!.(comp.children)
  if comp.mount !== nothing && comp.mount.widget !== nothing
    comp.mount.widget === nothing || destroy(comp.mount.widget)
    comp.mount = nothing
  end
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

