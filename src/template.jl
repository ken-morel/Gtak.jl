abstract type AbstractGtakMount <: AbstractMount end
struct GtakMount <: AbstractGtakMount
  parent::Union{GtkWidget,Nothing}
  widget::GtkWidget
  outlet::GtkWidget
  GtakMount(
    widget::GtkWidget;
    outlet::Union{GtkWidget,Nothing}=nothing,
    parent::Union{GtkWidget,Nothing}=nothing,
  ) = new(
    parent,
    widget,
    outlet === nothing ? widget : outlet,
  )
end
mutable struct GtakEntryMount <: AbstractGtakMount
  parent::Union{GtkWidget,Nothing}
  widget::GtkWidget
  outlet::GtkWidget
  reactant::EReactant
  jlupdates::Bool
  gtkupdates::Bool
  GtakEntryMount(
    widget::GtkWidget,
    reactant::EReactant;
    outlet::Union{GtkWidget,Nothing}=nothing,
    parent::Union{GtkWidget,Nothing}=nothing,
  ) = new(
    parent,
    widget,
    outlet === nothing ? widget : outlet,
    reactant,
    true,
    true,
  )
end
abstract type GtakBackend <: TemplateBackend end
