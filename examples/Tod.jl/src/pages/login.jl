function LoginContent(onmount)
    name = Reactant("")
    password = Reactant("")
    error = Reactant("")
    # Happens before everything else
    @radical   error' = "" [name, password]
    data = nothing
    stores = nothing
    context = nothing
    onmount() do _, ctx
        stores = getstores(ctx)
        data = getdata(ctx)
        context = ctx
    end
    @ionic function signup()
        user = User(; name = name', password = password')
        data[:user] = user
        alter!(stores[:users]) do users
            push!(users, user)
        end
        errormonitor(Threads.@spawn push!(context, Home; replace = true))
        return
    end
    @ionic function signin()
        for user in stores[:users]'
            if user.name == name'
                if user.password == password'
                    data[:user] = user
                    errormonitor(Threads.@spawn push!(context, Home; replace = true))
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
    return efus"""
    Box margin=50 expand=true
      Frame
        Grid expand=true margin=20 spacing=10
          Label text="Your username: " lay:pos=(1,1)
          Entry text=name margin=(0,0,0,25) lay:pos=(1,2)
          Label text="Your password: " lay:pos=(2,1)
          Entry text=password margin=(0,0,0,25) lay:pos=(2,2)
        KeyBox deps=[error]
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
end


const Login = ReloadablePage(LoginContent)
