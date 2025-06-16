struct PageBuildContext
  app::Atak.Application
  window::AbstractGtakWindow
  onmount::Union{Function,Nothing}
  PageBuildContext(app::Atak.Application, win::AbstractGtakWindow) = new(app, win, nothing)
end
mutable struct Page <: Atak.AbstractRouterPage
  component::AbstractComponent
  namespace::AbstractNamespace
  builder::Union{Function,Nothing}
  rebuildable::Bool
  Page(comp::AbstractComponent, nmsp::AbstractNamespace) = new(comp, nmsp, nothing, false)
  Page(comp::AbstractComponent, nmsp::AbstractNamespace, builder::Function) =
    new(comp, nmsp, builder, true)
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
    if isnothing(page.builder)
      page.builder = builder
      page.rebuildable = true
    end
    if !Efus.iserror(page)
      push!(ctx.window.router, page; args...)
    else
      Efus.display(page)
      throw(page)
    end
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
  Page(component, namespace, (newctx) -> builder(newctx; args...))
end
function (route::PageRoute)(ctx::PageBuildContext)::Page
  mnt = route.fn(ctx)
  if iserror(mnt)
    throw(mnt)
  else
    if isnothing(mnt.builder)
      mnt.builder = route
      mnt.rebuildable = true
    end
    mnt
  end
end
