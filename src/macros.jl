export @staticpage_str, @builder_str

"""
    @staticpage_str(code::AbstractString, stylesheet = nothing)

Creates a `StaticPage` from an Efus template string.

This macro is used to define pages whose content is built once and does not change dynamically.

**Arguments**
- `code::AbstractString`: The Efus template string defining the page's UI.
- `stylesheet`: An optional stylesheet to apply to the page.
"""
macro staticpage_str(code::AbstractString, stylesheet = nothing)

    gen = generate(IonicEfus.parse_efus(code, "<staticpage macro at $(__source__.file):$(__source__.line)"))
    return esc(
        quote
            $(LineNumberNode(__source__.line, __source__.file))
            $StaticPage(content = $gen, stylesheet = $(Symbol(stylesheet)))
        end
    )
end

"""
    @reloadablepage(code::AbstractString, cb = nothing)

Creates a `ReloadablePage` from an Efus template string, with an optional callback.

This macro is used to define pages whose content can be hot-reloaded during development.

**Arguments**
- `code::AbstractString`: The Efus template string defining the page's UI.
- `cb`: An optional callback function to be executed when the page is mounted.
"""
macro reloadablepage(code::AbstractString, cb = nothing)
    gen = IonicEfus.parse_efus(
        code, "<reloadable macro at $(__source__.file):$(__source__.line)",
    ) |> generate |> esc
    onmount = gensym()
    cbcode = if !isnothing(cb)
        esc(:($onmount($cb)))
    end
    return quote
        $(LineNumberNode(__source__.line, __source__.file))
        $ReloadablePage() do $onmount
            $cbcode
            $gen
        end
    end
end

"""
    @reloadablepage_str(code::AbstractString)

Creates a `ReloadablePage` from an Efus template string.

This is a convenience macro for defining reloadable pages without an explicit mount callback.

**Arguments**
- `code::AbstractString`: The Efus template string defining the page's UI.
"""
macro reloadablepage_str(code::AbstractString)
    gen = IonicEfus.parse_efus(
        code, "<reloadable macro at $(__source__.file):$(__source__.line)",
    ) |> generate |> esc
    return quote
        $(LineNumberNode(__source__.line, __source__.file))
        $ReloadablePage() do onmount
            $gen
        end
    end
end
