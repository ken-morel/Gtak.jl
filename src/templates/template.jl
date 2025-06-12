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
  reactant::Efus.AbstractReactant
  jlupdates::Bool
  gtkupdates::Bool
  GtakEntryMount(
    widget::GtkWidget,
    reactant::Efus.AbstractReactant;
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


function childgeometry(parent::Component, child::AbstractComponent)
  childgeometry(
    outlet(parent).template.backend,
    outlet(parent),
    child,
  )
end

function childgeometry(
  backend::GtakBackend, parent::Component, child::AbstractComponent
)
  push!(parent.mount.outlet, inlet(child).mount.widget)
end



"""
Align_FILL = 0
Align_START = 1
Align_END = 2
Align_CENTER = 3
Align_BASELINE_FILL = 4
Align_BASELINE = 4
Align_BASELINE_CENTER = 5
"""
const ALIGNS = Dict{Symbol,Gtk4.Align}(
  :fill => Gtk4.Align_FILL,
  :start => Gtk4.Align_START,
  :left => Gtk4.Align_START,
  :top => Gtk4.Align_START,
  :end => Gtk4.Align_END,
  :bottom => Gtk4.Align_END,
  :right => Gtk4.Align_END,
  :center => Gtk4.Align_CENTER,
  :bfill => Gtk4.Align_BASELINE_FILL,
  :bcenter => Gtk4.Align_BASELINE_CENTER,
  :baseline => Gtk4.Align_BASELINE,
)
function addcommonargs!(args::Vector{Pair}, c::Component)
  c[:valign] isa Symbol && push!(args, :valign => ALIGNS[c[:valign]])
  c[:halign] isa Symbol && push!(args, :halign => ALIGNS[c[:halign]])
  c[:spacing] isa Bool && push!(args, :spacing => ALIGNS[c[:spacing]])
  c[:hexpand] isa Symbol && push!(args, :hexpand => ALIGNS[c[:hexpand]])
  c[:vexpand] isa Symbol && push!(args, :vexpand => ALIGNS[c[:vexpand]])
  if c[:spacing] isa ESize
    push!(args, :row_spacing => c[:spacing].height)
    push!(args, :column_spacing => c[:spacing].width)
  end
  if c[:margin] isa EEdgeInsets
    push!(args, :margin_top => c[:margin].top)
    push!(args, :margin_bottom => c[:margin].bottom)
    push!(args, :margin_start => c[:margin].left)
    push!(args, :margin_end => c[:margin].right)
  end
end
COMMON_ATTRS = [
  :halign => Symbol,
  :valign => Symbol,
  :margin => EEdgeInsets{Int,Any},
  :attach => ESquareGeometry{Int,Any},
  :hexpand => Bool,
  :vexpand => Bool,
]
