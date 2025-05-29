struct GtakMount <: AbstractMount
  parent::Union{GtkWidget,Nothing}
  widget::GtkWidget
  outlet::GtkWidget
  GtakMount(widget::GtkWidget; outlet::Union{GtkWidget,Nothing}=nothing, parent::Union{GtkWidget,Nothing}=nothing) = new(parent, widget, outlet === nothing ? widget : outlet)
end
abstract type GtakBackend <: TemplateBackend end
