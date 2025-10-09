function IonicEfus.remount!(c::GtakComponent)
    unmount!(c)
    return mount!(c)
end
