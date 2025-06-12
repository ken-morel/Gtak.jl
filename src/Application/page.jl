struct PageBuildContext
  app::Atak.Application
  window::AbstractGtakWindow
  onmount::Union{Function,Nothing}
  PageBuildContext(app::Atak.Application, win::AbstractGtakWindow) = new(app, win, nothing)
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

function onmount(fn::Function, ctx::PageBuildContext)
  ctx.onmount = fn
end
function Base.push!(
  ctx::PageBuildContext, builder::Union{PageBuilder,Function};
  args...,  # just to be explicit, builder is also a Function
)
  errormonitor(@async begin
    page = builder(ctx)
    push!(ctx.window.router, page; args...)
  end)
end
Base.push!(builder::Function, ctx::PageBuildContext; args...) =
  push!(ctx, builder; args...)

function Base.push!(
  ctx::PageBuildContext, page::Page;
  args...,  # just to be explicit, builder is also a Function
)
  errormonitor(@async begin
    push!(ctx.window.router, page; args...)
  end)
end

function Base.pop!(ctx::PageBuildContext; args...)
  errormonitor(@async begin
    pop!(ctx.window.router; args...)
  end)
end




function (builder::PageBuilder)(ctx::PageBuildContext; args...)::Page
  namespace = DictNamespace(ctx.app.namespace)
  builder.initializer(namespace, ctx, args)
  evalctx = EfusEvalContext(namespace)
  component = eval!(evalctx, builder.code)
  if iserror(component)
    println(Efus.format(component))
    throw(component)
  end
  if ctx.onmount isa Function
    ctx.onmount(component)
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
