struct WindowBackend <: GtakBackend end
function Efus.mount!(_::WindowBackend, c::Component)::GtakMount
  outlet = window = GtkWindow(c[:title])
  if c[:box] isa EOrient
    outlet = (GtkBox ∘ Symbol ∘ first ∘ String)(c[:box].orient)
    push!(window, outlet)
  end

  for child ∈ c.children
    m = mount!(child)
    m !== nothing && m.widget !== nothing && push!(outlet, m.widget)
  end
  showall(window)
  c.mount = GtakMount(window; outlet)
end
function Efus.update!(_::WindowBackend, comp::Component)
  if comp.dirty
    evaluateargs!(comp)
    set_gtk_property!(comp.mount.widget, :title, comp[:title])
  end
  update!.(comp.children)
end

GtakWindow = Template(
  :Window,
  WindowBackend(),
  [
    :title => String,
    :box => EOrient,
  ]
)
registertemplate(:Gtak, GtakWindow)


mainloop(win::GtakMount) = mainloop(win.widget)

