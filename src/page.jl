export Page, PageContext, PageBuilder, PageOrBuilder

struct Page <: GtakComponent
    component::GtakComponent
end


struct PageContext
    window::AbstractGtakWindow
    app::AbstractGtakApplication
end


const PageBuilder = FunctionWrapper{Page, Tuple{PageContext}}

const PageOrBuilder = Union{Page, PageBuilder}

function mount!(p::Page)
    return mount!(p.component, p)
end


function remount!(p::Page)

    return remount!(p.component, p)
end

function unmount!(p::Page)
    return unmount!(p.component)
end
