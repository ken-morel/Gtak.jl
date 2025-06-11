const Router = Atak.Router{Page}
function render(page::Page)::GtkWidget
  mnt = mount!(page.component)
  if iserror(mnt)
    throw(mnt)
  else
    mnt.widget
  end
end

