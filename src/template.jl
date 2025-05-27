struct GtakMount <: AbstractMount
  widget::GtkWidget
  outlet::GtkWidget
  GtakMount(w::GtkWidget; outlet::Union{GtkWidget,Nothing}=nothing) = new(w, outlet === nothing ? w : outlet)
end
abstract type GtakBackend <: TemplateBackend end
