struct PageBuildContext
  using Gtk4: update_texture
  app::Atak.Application
  window::AbstractGtakWindow
  PageBuildContext(app::Atak.Application, win::AbstractGtakWindow) = new(app, win)
end
struct Page <: Atak.AbstractRouterPage
  component::AbstractComponent
  namespace::AbstractNamespace
end
struct PageRoute <: Atak.AbstractPageBuilder{Page}
  fn::Function
end

struct PageBuilder <: Atak.AbstractPageBuilder{Page}
  initializer::Function
  code::ECode
end
function Base.push!(ctx::PageBuildContext, builder::PageBuilder; args...)
  errormonitor(@async begin
    page = builder(ctx)
    println("pushing bulid page to push in")
    push!(ctx.window.router, page; args...)
    println("pushed in the browser")
  end)
end
function Base.pop!(ctx::PageBuildContext; args...)
  errormonitor(@async begin
    println("poping in the browser")
    pop!(ctx.window.router; args...)
    println("poped in the browser")
  end)
end




function (builder::PageBuilder)(ctx::PageBuildContext)::Page
  namespace = DictNamespace(ctx.app.namespace)
  onmount = builder.initializer(namespace, ctx)
  ctx = EfusEvalContext(namespace)
  component = eval!(ctx, builder.code)
  if iserror(component)
    throw(Efus.format(component))
  end
  if onmount isa Function
    onmount(component)
  end
  Page(component, namespace)
end
function (route::PageRoute)(ctx::PageBuildContext)::Page
  mnt = route.fn(ctx)
  if iserror(mnt)
    throw(mnt)
  else
    mnt
  end
end
