struct GtakEntryBackend <: GtakBackend end
function Efus.mount!(_::GtakEntryBackend, comp::Component; _...)::GtakEntryMount
  variable = comp[:var]
  entry = GtkEntry()
  if !isnothing(comp.parent) && !isnothing(comp.parent.mount) && !isnothing(comp.parent.mount.outlet)
    push!(comp.parent.mount.outlet, entry)
  end
  comp.mount = GtakEntryMount(entry, variable)
end
function Efus.update!(_::GtakEntryBackend, comp::Component)
  evaluateargs!(comp)
  comp.mount === nothing && return
end

function Efus.unmount!(_::GtakEntryBackend, comp::Component)
  Efus.unmount!.(comp.children)
  if comp.mount !== nothing && comp.mount.widget !== nothing
    # comp.mount.widget === nothing || Gtk4.destroy(comp.mount.widget)
    comp.mount = nothing
  end
end

GtakEntry = Template(
  :Entry,
  GtakEntryBackend(),
  [
    :var! => Efus.EReactant,
  ]
)

#TODO: Actually set the parents
