struct GtakButtonBackend <: GtakBackend end
function Efus.mount!(_::GtakButtonBackend, comp::Component)::GtakMount
  button = GtkButton(comp[:text])

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


GtakButton = Template(
  :Button,
  GtakButtonBackend(),
  [
    :text! => String,
    :onclick => Function
  ]
)
registertemplate(:Gtak, GtakButton)

