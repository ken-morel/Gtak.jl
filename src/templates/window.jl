struct GtakGtkWindowBackend <: GtakBackend end

function Efus.mount!(c::Component{GtakGtkWindowBackend})::GtakMount
  args = Dict{Symbol,Any}()
  if c[:size] isa ESize
    args[:width] = c[:size].width
    args[:height] = c[:size].height
  end
  c[:resizable] isa Bool && (args[:resizable] = c[:resizable])
  c[:border_width] isa Int && (args[:border_width] = c[:border_width])
  # c[:visible] isa Bool && (args[:visible] = c[:visible])
  outlet = window = GtkWindow(c[:title]; args...)
  if c[:box] isa EOrient
    outlet = (GtkBox ∘ Symbol ∘ first ∘ String)(c[:box].orient)
    window[] = outlet
  end
  c.mount = GtakMount(window; outlet)
  for child ∈ c.children
    err = mount!(child)
    if iserror(err)
      @warn("Error mounting child component $(println(format(err)))\n")
    end
    if !isnothing(err.widget)
      window[] = err.widget
    end
  end
  show(window)
  c.mount
end
function Efus.update!(comp::Component{GtakGtkWindowBackend})
  if comp.dirty
    evaluateargs!(comp)
    set_gtk_property!(comp.mount.widget, :title, comp[:title])
  end
  update!.(comp.children)
end
function Efus.unmount!(comp::Component{GtakGtkWindowBackend})
  Efus.unmount!.(comp.children)
  if comp.mount !== nothing && comp.mount.widget !== nothing
    comp.mount.widget === nothing || Gtk4.destroy(comp.mount.widget)
    comp.mount = nothing
  end
end

GtakGtkWindow = EfusTemplate(
  :GtkWindow,
  GtakGtkWindowBackend,
  TemplateParameter[
    :title! => String,
    :box => EOrient,
    :size => ESize{Int,:px},
    :resizable => Bool,
    :border_width => Int,
  ]
)

mainloop(win::GtakMount) = Application.mainloop(win.widget)

