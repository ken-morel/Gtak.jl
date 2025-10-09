export @staticpage_str, @builder_str

macro staticpage_str(code::AbstractString)

    gen = generate(IonicEfus.parse_efus(code, "<builder macro at $(__source__.file):$(__source__.line)"))
    return quote
        $(LineNumberNode(__source__.line, __source__.file))
        $StaticPage($(esc(gen)))
    end
end

macro builder_str(code::AbstractString)
    gen = generate(IonicEfus.parse_efus(code, "<builder macro at $(__source__.file):$(__source__.line)"))
    builder = quote
        $PageBuilder((ctx) -> $gen)
    end
    return quote
        $(LineNumberNode(__source__.line, __source__.file))
        $(esc(builder))
    end
end
