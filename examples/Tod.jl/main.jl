@time using Revise
@time using Tod

@time const app = Tod.createapplication()

@time errormonitor(
    @async Revise.entr([], [Tod, Tod.Gtak, Tod.Gtak.IonicEfus]) do
        try
            @time Tod.Gtak.reload!(app; all = true)
        catch e
            showerror(stderr, e)
        end
    end
)

run(app)
