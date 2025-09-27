export @page_str

macro page_str(code::AbstractString)
    gen = Efus.parseandgenerate(code)
    return quote
        $(LineNumberNode(__source__.line, __source__.file))
        $Page($(esc(gen)))
    end
end
