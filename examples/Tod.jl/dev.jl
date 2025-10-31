using Revise
using Tod

const app = Tod.createapplication()

errormonitor(
    @async Revise.entr(
        () -> schedule(
            () -> Tod.Gtak.reload!(app; all = true),
            app,
        ),
        [],
        [Tod],
    )
)

run(app)

(@main)(_) = (Tod.createapplication(); 0)
