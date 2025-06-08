struct GtakButtonBackend <: GtakBackend end
function Efus.mount!(_::GtakButtonBackend, comp::Component)::GtakMount
  button = GtkButton(something(comp[:text], ":-("))
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
function _gtakbuttonconnectsignals(comp::Component, button::GtkButton)
  signal_connect(button, "clicked") do _
    if comp[:onclick] !== nothing
      comp[:onclick](comp)
      if comp.dirty
        update!(master(comp))
      end
    end
  end
end
function Efus.unmount!(_::GtakButtonBackend, comp::Component)
  Efus.unmount!.(comp.children)
  if comp.mount !== nothing && comp.mount.widget !== nothing
    # comp.mount.widget === nothing || Gtk4.destroy(comp.mount.widget)
    comp.mount = nothing
  end
end

GtakButton = Template(
  :Button,
  GtakButtonBackend(),
  [
    :text! => String,
    :onclick => Function
  ]
)

