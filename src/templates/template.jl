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
Base.convert(::Type{Gtk4.Align}, val::Efus.ESymbol) = ALIGNS[val.value]
const JUSTIFIES = Dict{Symbol,Gtk4.Justification}(
  :left => Gtk4.Justification_LEFT,
  :right => Gtk4.Justification_RIGHT,
  :center => Gtk4.Justification_CENTER,
  :fill => Gtk4.Justification_FILL,
)
Base.convert(::Type{Gtk4.Justification}, val::Efus.ESymbol) = JUSTIFIES[val.value]
function addcommonargs!(args::Vector{Pair}, c::Component)
  c[:valign] isa Gtk4.Align && push!(args, :valign => c[:valign])
  c[:halign] isa Gtk4.Align && push!(args, :halign => c[:halign])
  c[:hexpand] isa Bool && push!(args, :hexpand => c[:hexpand])
  c[:vexpand] isa Bool && push!(args, :vexpand => c[:vexpand])
  c[:hastooltip] isa Bool && push!(args, :has_tooltip => c[:hastooltip])
  c[:tooltip_markup] isa Bool && push!(args, :tooltip_markup => c[:tooltip_markup])
  c[:tooltip_text] isa String && push!(args, :tooltip_text => c[:tooltip_text])
  c[:visible] isa Bool && push!(args, :visible => c[:visible])

  if c[:margin] isa EEdgeInsets
    push!(args, :margin_top => c[:margin].top)
    push!(args, :margin_bottom => c[:margin].bottom)
    push!(args, :margin_start => c[:margin].left)
    push!(args, :margin_end => c[:margin].right)
  end
end
COMMON_ATTRS = [
  :halign => Gtk4.Align,
  :valign => Gtk4.Align,
  :margin => EEdgeInsets{Int,Any},
  :attach => ESquareGeometry{Int,Any},
  :hexpand => Bool,
  :vexpand => Bool,
  :hastooltip => Bool,
  :tooltip_markup => String,
  :tooltip_text => String,
  :visible => Bool,
]
function childgeometry(
  parent::Component{<:GtakBackend}, child::AbstractComponent
)
  push!(parent.mount.outlet, inlet(child).mount.widget)
end


function Efus.update!(comp::Component{<:GtakBackend})
  comp.mount === nothing && return
  update!.(comp.children)
end
function Efus.unmount!(comp::Component{<:GtakBackend})
  Efus.unmount!.(comp.children)
  if comp.mount !== nothing && comp.mount.widget !== nothing
    # comp.mount.widget === nothing || Gtk4.destroy(comp.mount.widget)
    comp.mount = nothing
  end
end
