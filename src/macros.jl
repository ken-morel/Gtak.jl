export @staticpage_str, @builder_str

macro staticpage_str(code::AbstractString, stylesheet = nothing)

    gen = generate(IonicEfus.parse_efus(code, "<staticpage macro at $(__source__.file):$(__source__.line)"))
    return esc(
        quote
            $(LineNumberNode(__source__.line, __source__.file))
            $StaticPage(content = $gen, stylesheet = $(Symbol(stylesheet)))
        end
    )
end
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
