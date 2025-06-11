struct GtakWindow <: AbstractGtakWindow
  router::Router
  widget::GtkWindow
  observer::EObserver
end
function creategtakwindow(homepage::Union{Page,Nothing}=nothing; options...)
  window = GtkWindow(; options...)
  router = Router(homepage)
  observer = EObserver()
  gtakwindow = GtakWindow(
    router, window, observer
  )
  subscribe!(router, observer) do _
    println("updating window content")
    errormonitor(@async updatecontent!(gtakwindow))
  end
  gtakwindow
end
function updatecontent!(win::GtakWindow)
  win.widget[] = nothing
  page = Atak.getcurrentpage(win.router)
  isnothing(page) && return
  win.widget[] = render(page)
  # Gtk4.show(win.widget)
end
