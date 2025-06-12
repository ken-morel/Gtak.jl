struct GtakPasswordEntryBackend <: GtakBackend end
function Efus.mount!(::GtakPasswordEntryBackend, comp::Component; args...)::GtakEntryMount
  variable = comp[:var]
  args = Pair[]
  addcommonargs!(args, comp)
  entry = GtkPasswordEntry(;
    text=something(getvalue(variable), ""),
    args...,
  )
  comp.mount = mount = GtakEntryMount(entry, variable)
  signal_connect(entry, "changed") do entry
    !mount.gtkupdates && return
    value = get_gtk_property(entry, :text, String)
    if getvalue(variable) != value
      mount.jlupdates = false
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
        set_gtk_property!(entry, :text, value)
        mount.gtkupdates = true
      end
    end)
  end
  if !isnothing(comp.parent)
    childgeometry(comp.parent, comp)
  end
  comp.mount
end
function Efus.update!(::GtakPasswordEntryBackend, comp::Component; args...)
  evaluateargs!(comp)
  comp.mount === nothing && return
end

function Efus.unmount!(::GtakPasswordEntryBackend, comp::Component; args...)
  Efus.unmount!.(comp.children)
  if comp.mount !== nothing && comp.mount.widget !== nothing
    # comp.mount.widget === nothing || Gtk4.destroy(comp.mount.widget)
    comp.mount = nothing
  end
end

GtakPasswordEntry = EfusTemplate(
  :PasswordEntry,
  GtakPasswordEntryBackend(),
  [
    :var! => Efus.AbstractReactant,
    COMMON_ATTRS...,
  ]
)


