export Spinner

@gtakcomponent Spinner <: GtakWidgetComponent begin
    spinning::MayBeReactive{Bool} = true
end

function IonicEfus.mount!(s::Spinner, p::GtakComponent)
    s.parent = p
    s.widget = GtkSpinner()
    s.widget.spinning = resolve(s.spinning)
    s.spinning isa AbstractReactive && catalyze!(s.catalyst, s.spinning) do _
        dirty!(s, :spinning)
    end
    return s.widget
end

function IonicEfus.update!(s::Spinner)
    return _updates(s) do key
        if key == :spinning
            s.widget.spinning = resolve(s.spinning)
        end
    end
end

function IonicEfus.unmount!(s::Spinner)
    return _gtakunmountwidget!(s)
end
