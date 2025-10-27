using Revise
using Tod

const app = Tod.createapplication()

errormonitor(
    @async Revise.entr([], [Tod]) do
        try
            println("Reloading in...")
            @time Tod.Gtak.reload!(app; all = true)
        catch e
            showerror(stderr, e)
        end
    end
)

run(app)
