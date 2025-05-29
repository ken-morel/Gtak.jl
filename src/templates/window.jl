struct WindowBackend <: GtakBackend end
function Efus.update!(mount::GtakMount)
  while mount.parent !== nothing
    mount = mount.parent
  end
  if mount.widget isa GtkWindow
    showall(mount.widget)
  end
end
function Efus.mount!(_::WindowBackend, c::Component)::GtakMount
  args = Dict{Symbol,Any}()
  if c[:size] isa ESize
    args[:width] = c[:size].width
    args[:height] = c[:size].height
  end
  c[:resizable] isa Bool && (args[:resizable] = c[:resizable])
  c[:border_width] isa Int && (args[:border_width] = c[:border_width])
  outlet = window = GtkWindow(c[:title]; args...)
  if c[:box] isa EOrient
    outlet = (GtkBox ∘ Symbol ∘ first ∘ String)(c[:box].orient)
    push!(window, outlet)
  end
  c.mount = GtakMount(window; outlet)
  for child ∈ c.children
    mount!(child)
  end
  showall(window)
  c.mount
end
function Efus.update!(_::WindowBackend, comp::Component)
  if comp.dirty
    evaluateargs!(comp)
    set_gtk_property!(comp.mount.widget, :title, comp[:title])
  end
  update!.(comp.children)
end
function Efus.unmount!(_::WindowBackend, comp::Component)
  Efus.unmount!.(comp.children)
  if comp.mount !== nothing && comp.mount.widget !== nothing
    comp.mount.widget === nothing || destroy(comp.mount.widget)
    comp.mount = nothing
  end
end

GtakWindow = Template(
  :Window,
  WindowBackend(),
  [
    :title! => String,
    :box => EOrient,
    :size => ESize{Int,:px},
    :resizable => Bool,
    :border_width => Int,
  ]
)
registertemplate(:Gtak, GtakWindow)


mainloop(win::GtakMount) = mainloop(win.widget)

