struct GtakImageBackend <: GtakBackend end
function Efus.mount!(c::Component{GtakImageBackend})::GtakMount
  args = Pair[]
  addcommonargs!(args, c)
  c[:file] isa String && push!(args, :file => c[:file])
  c[:pixelsize] isa Int && push!(args, :pixel_size => c[:pixelsize])
  image = GtkImage(; args...)
  c.mount = GtakMount(image)
  if c.parent !== nothing
    childgeometry(c.parent, c)
  end
  c.mount
end

GtakImage = EfusTemplate(
  :Image,
  GtakImageBackend,
  TemplateParameter[
    :file=>String,
    :pixelsize=>Int,
    COMMON_ATTRS...,
  ]
)

