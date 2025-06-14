struct GtakEntryBackend <: GtakBackend
end
function Efus.mount!(comp::Component{GtakEntryBackend})::GtakEntryMount
  args = Pair[]
  variable = comp[:var]
  addcommonargs!(args, comp)
  push!(args, :text => something(getvalue(variable), ""))
  entry = GtkEntry(; args...)
  mount = GtakEntryMount(entry, variable)
  comp.mount = mount
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
function Efus.update!(comp::Component{GtakEntryBackend})
  evaluateargs!(comp)
  comp.mount === nothing && return
end

function Efus.unmount!(comp::Component{GtakEntryBackend})
  Efus.unmount!.(comp.children)
  if comp.mount !== nothing && comp.mount.widget !== nothing
    # comp.mount.widget === nothing || Gtk4.destroy(comp.mount.widget)
    comp.mount = nothing
  end
end

GtakEntry = EfusTemplate(
  :Entry,
  GtakEntryBackend,
  TemplateParameter[
    :var! => Efus.AbstractReactant,
    COMMON_ATTRS...,
  ]
)

#TODO: Actually set the parents
