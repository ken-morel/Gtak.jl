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
