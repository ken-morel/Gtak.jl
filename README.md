# Gtak.jl

Gtak.jl is a reactive, component-based framework for building modern GTK4 applications in Julia. It provides a declarative and elegant way to create complex user interfaces by leveraging the power of Julia's metaprogramming and the reactive core of `IonicEfus.jl`.

## The Atak Ecosystem

Gtak.jl is a key part of a larger ecosystem of packages designed for building robust, high-performance applications:

- **IonicEfus.jl**: The foundation of the ecosystem. It provides the core declarative UI templating language (Efus), a powerful reactivity model, and a component-based architecture. For a deep dive into reactivity, components, and the Efus language, please refer to the [IonicEfus.jl](https://github.com/ken-morel/IonicEfus.jl).
- **Atak.jl**: Offers essential application-level services, including a file-system-based data persistence layer (`Store`) and, most notably, a multi-threaded task `Scheduler`.
- **Gtak.jl**: The bridge to the GTK4 toolkit. It provides a rich set of reactive UI components that wrap GTK widgets, making them available within the Efus templating language.

## Core Concepts

### Creating an Application

Gtak.jl offers two main ways to structure your application:

- `application()`: The standard way to create a multi-window application. It gives you an application object that you can add windows to.

  ```julia
  app = application("com.example.myapp") do app
      window(app, title="Window 1") do win
          # ... page for window 1
      end
      window(app, title="Window 2") do win
          # ... page for window 2
      end
  end
  run(app)
  ```

- `spa()`: A convenience function for creating a Single-Page Application. It creates an application and a single window in one call, it is not exported.

  ```julia
  app = Gtak.spa(id="com.example.spa") do _, _
      # ... return a page
  end
  run(app)
  ```

### Pages: The Views of Your Application

Pages represent a unit of ui which share the same sheduler and can be mounted to be integrated even in your gtk application, they are also the content of a window. They can be created in several ways:

- **Macros**: For quick and easy page creation using the Efus templating language.
  - `@staticpage_str`: Creates a `StaticPage` whose content is built only once.
  - `@reloadablepage_str`: Creates a `ReloadablePage` that can be reloaded.

```julia

staticpage"Label text=hello world"

reloadablepage"""
Label foo=bar
(onmount() do page, scheduler
  ...
end)
"""

@reloadablepage "Label ..." (p, s) -> ...


```

- **Methods**: For more programmatic control.
  - `StaticPage(components)`: Creates a static page from a list of components.
  - `ReloadablePage(builder_function)`: Creates a reloadable page from a function that returns a list of components. This is the key to enabling hot-reloading with `Revise.jl`.

Pages hold an optional(but usually important sheduler), which can be provided when it is mounted(and obviously removed when the page is unmounted), without the scheduler, you will have an almost completely unreactive page.

### Reactivity and UI Updates: The `dirty!` System

The UI automatically updates when your data changes. This is achieved through a collaboration between `IonicEfus.jl`'s reactivity and `Atak.jl`'s scheduler.

1. **Reactive State**: Your component's state is stored in `Reactant`s.
2. **Marking as Dirty**: When you change a reactive property (e.g., `my_reactant' = new_value`), the component that depends on it is marked as "dirty" by calling `dirty!(component, :property_name)`, if you want to edit a non-reactive, modifiable attribute, you can use `dirty!(component, :property, value)`.
3. **Scheduling**: This `dirty!` call automatically pushes a `ComponentUpdate` task onto the window's dedicated `Scheduler` (provided by `Atak.jl`), the component goes up the component hierarchy until it finds the container page, it queries it's sheduler and schedules the update on it. You can optionally specify a priority (`High`, `Normal`, `Low`) for the update.
4. **Updating**: The `Scheduler` runs on background threads, they are created per-window, and you can use a custom scheduler via the `scheduler` keyword argument when creating the window. It then executes the `update!(component)` method on the main GTK thread, which efficiently updates only the necessary parts of the GTK widget.

This architecture ensures that your UI remains fluid and responsive, as expensive computations(or compilation) don't block the main UI thread.

### Hot-Reloading with `Revise.jl`

Gtak.jl is designed to work seamlessly with `Revise.jl` for an interactive development experience. By using `ReloadablePage`, you can see your UI changes instantly without restarting the application.
And with julia 1.12, you can have your page and callbacks seamlessly working when reloading your application, thanks to calls wrapped in `@invokelatest`.

Here’s how you can set it up, based on the `Tod.jl` example:

1. **Create a `dev.jl` entry point**:

   ```julia
   # Gtak.jl/examples/Tod.jl/dev.jl
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
        [Tod];
        postpone=true,
     )
    )

   run(app)
   ```

   This script uses `Revise.entr` to monitor your project's files. When a file is saved, it calls `Gtak.reload!(app; all=true)`, which reloads all `ReloadablePage`s in your application.
   Notice that we are scheduling the reload, so that it happens on another thread, and not the same one where it is mounted as will normally be done with `@async`, and cause the locks not to prevent mounting(app startup) and unmounting(app reload) occuring at the same time, if `postpone` is ommited.

2. **Define your pages as `ReloadablePage`s**:

   ```julia
   # Gtak.jl/examples/Tod.jl/src/pages/login.jl
   function LoginContent(onmount)
       # ... component logic ...
       return efus"""
       Box expand=true align=A_C
         # ... efus template ...
       """
   end

   const Login = ReloadablePage(LoginContent)
   ```

   By defining your page's content in a function and passing that function to `ReloadablePage`, `Revise.jl` can update the function's definition, and `Gtak.reload!` can rebuild the page with the new content, if you used a do-call, the whole page will be redifined, and it would be showing a different page, than rebuilding the page content..

## Available Widgets

Gtak.jl provides a comprehensive set of reactive widgets. All widgets share a common set of properties like `margin`, `align`, `expand`, `cssclasses`, etc.

- **Layout**: `Box`, `HBox`, `VBox`, `Grid`, `Paned`, `Frame`, `ScrolledWindow`, `Notebook`, `Separator`
- **Buttons**: `Button`, `ToggleButton`, `CheckButton`, `LinkButton`, `Switch`
- **Input**: `Entry`, `TextView`, `ComboBoxText`, `Scale`
- **Display**: `Label`, `Image`, `ProgressBar`, `Spinner`, `Video`
- **Control Flow**: `For`, `Keyed`, `Switched` for building dynamic and conditional layouts.

## Installation

To add Gtak.jl to your project, use the Julia package manager:

```julia
import Pkg
Pkg.develop(url="https://github.com/ken-morel/Gtak.jl.git")
```

