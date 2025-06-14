struct GtakButtonBackend <: GtakBackend end
function Efus.mount!(comp::Component{GtakButtonBackend})::GtakMount
  args = Pair[]
  addcommonargs!(args, comp)
  button = GtkButton(something(comp[:text], ":-("); args...)
  comp.mount = GtakMount(button)
  if !isnothing(comp.parent)
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
function _gtakbuttonconnectsignals(comp::Component{GtakButtonBackend}, button::GtkButton)
  signal_connect(button, "clicked") do _
    if comp[:onclick] !== nothing
      comp[:onclick](comp)
      if comp.dirty
        update!(Efus.master(comp))
      end
    end
  end
end


GtakButton = EfusTemplate(
  :Button,
  GtakButtonBackend,
  TemplateParameter[
    :text! => String,
    :onclick => Function,
    COMMON_ATTRS...,
  ]
)

