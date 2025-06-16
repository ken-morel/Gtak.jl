const Router = Atak.Router{Page}
function render(page::Page)::GtkWidget
  mnt = mount!(page.component)
  if iserror(mnt)
    throw(mnt)
  else
    mnt.widget
  end
end

function rebuildpage(router::Router, index::Int, ctx::PageBuildContext; shouldnotify::Bool=false)
  page = router.pagestack[index]
  if page.rebuildable
    router.pagestack[index] = page.builder(ctx)
  end
  shouldnotify && Efus.notify(router)
end

function reload!(router::Router, ctx::PageBuildContext; all::Bool=false)
  if all
    rebuildpage.((router,), 1:length(router.pagestack), (ctx,))
  else
    length(router.pagestack) == 0 && return
    rebuildpage(router, length(router.pagestack), ctx)
  end
  Efus.notify(router)
end
function reload!(ctx::PageBuildContext; all::Bool=false)
  reload!(ctx.window.router, ctx; all)
end
