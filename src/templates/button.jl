struct GtakButtonBackend <: GtakBackend end
function Efus.mount!(_::GtakButtonBackend, comp::Component)::GtakMount
  args = Pair[]
  addcommonargs!(args, comp)
  button = GtkButton(something(comp[:text], ":-("); args...)
  comp.mount = GtakMount(button)
  if comp.parent !== nothing
    childgeometry(comp.parent, comp)
  end
  _gtakbuttonconnectsignals(comp, button)
  comp.mount
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

GtakButton = EfusTemplate(
  :Button,
  GtakButtonBackend(),
  [
    :text! => String,
    :onclick => Function,
    COMMON_ATTRS...,
  ]
)

