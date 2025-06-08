struct GtakEntryBackend <: GtakBackend end
function Efus.mount!(::GtakEntryBackend, comp::Component; args...)::GtakEntryMount
  variable = comp[:var]
  entry = GtkEntry()
  mount = GtakEntryMount(entry, variable)
  signal_connect(entry, "changed") do entry
    !mount.gtkupdates && return
    value = get_gtk_property(entry, :text, String)
    if getvalue(variable) != value
      mount.jlupdates = false
      println("Gtk change to $value, but jl was $(getvalue(variable))")
      notify!(variable, value)
      mount.jlupdates = true
    end
  end
  subscribe!(variable, nothing) do _, value
    !mount.jlupdates && return
    errormonitor(@async begin
      sleep(0.001)  # slow ui updates but prevent gtk errors
      if value != get_gtk_property(entry, :text, String)
        mount.gtkupdates = false  #inhibit gtk -> ereactive updates
        println("jl change to $value, but Gtk was $(get_gtk_property(entry, :text, String))")
        set_gtk_property!(entry, :text, value)
        mount.gtkupdates = true
      end
    end)
  end
  if !isnothing(comp.parent) && !isnothing(comp.parent.mount) && !isnothing(comp.parent.mount.outlet)
    push!(comp.parent.mount.outlet, entry)
  end
  comp.mount = mount
end
function Efus.update!(::GtakEntryBackend, comp::Component; args...)
  evaluateargs!(comp)
  comp.mount === nothing && return
end

function Efus.unmount!(::GtakEntryBackend, comp::Component; args...)
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
