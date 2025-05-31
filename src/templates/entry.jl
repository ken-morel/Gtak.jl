struct GtakEntryBackend <: GtakBackend end
function Efus.mount!(_::GtakEntryBackend, comp::Component)::GtakMount
  button = GtkEntry(comp[:text])
  if comp.parent !== nothing && comp.parent.mount !== nothing && comp.parent.mount.outlet !== nothing
    push!(comp.parent.mount.outlet, button)
  end
  _gtakbuttonconnectsignals(comp, button)
  comp.mount = GtakMount(button)
end
function Efus.update!(_::GtakButtonBackend, comp::Component)
  evaluateargs!(comp)
  comp.mount === nothing && return
  set_gtk_property!(comp.mount.widget, :label, comp[:text])
end

function Efus.unmount!(_::GtakButtonBackend, comp::Component)
  Efus.unmount!.(comp.children)
  if comp.mount !== nothing && comp.mount.widget !== nothing
    comp.mount.widget === nothing || destroy(comp.mount.widget)
    comp.mount = nothing
  end
end

GtakEntry = Template(
  :Button,
  GtakEntryBackend(),
  [
    :var! => Efus.EReactant,
  ]
)
registertemplate(:Gtak, GtakButton)
