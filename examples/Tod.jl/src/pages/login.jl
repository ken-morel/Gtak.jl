password = Reactant("")
error = Reactant("")
# Reset the error when name or password change
@radical error' = "" [username, password]
data = nothing
stores = nothing

context = nothing

function initlogin(_, ctx)
    global stores = getstores(ctx)
    global data = getdata(ctx)
    global context = ctx
    return
end

@ionic function signin()
    # atak.jl stores also support getvalue and setvalue!
    for user in stores[:users]'
        if user.name == username'
            if user.password == password'
                data[:user] = user
                push!(context, Home; replace = true)
                break
            else
                error' = "Wrong password"
                return
            end
        end
    end
    if isnothing(data[:user])
        error' = "User not found"
    end
    return
end
function signup()
    user = @ionic User(; name = username', password = password')
    data[:user] = user
    alter!(stores[:users]) do users
        push!(users, user)
    end
    errormonitor(Threads.@spawn push!(context, Home; replace = true))
    return
end

LoginContent = efus"""
Box expand=true align=A_C
  Box cssclasses=["login-box"]
    BoxFrame
      Grid expand=true margin=20 spacing=10
        Label text="Username: " lay:pos=(1,1)
        Entry text=username margin=(0,0,0,25) lay:pos=(1,2)
        Label text="Password: " lay:pos=(2,1)
        Entry text=password margin=(0,0,0,25) lay:pos=(2,2)
      Keyed deps=[error]
        builder()
          if error' != ""
            Label text="<b>ERROR:</b> $(error')"
          end
        end
      Separator
      HBox margin=5 expand=(false, true) homogeneous=true
        Button text="Signup" opacity=0.6 onclick=signup
        Button text="Signin" onclick=signin
"""

const Login = ReloadablePage((o) -> (o(initlogin); LoginContent))
