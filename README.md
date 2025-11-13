# Gtak.jl

[![code style: runic](https://img.shields.io/badge/code_style-%E1%9A%B1%E1%9A%A2%E1%9B%81%E1%9A%B2-black)](https://github.com/fredrikekre/Runic.jl)

`Gtak.jl` is a reactive, component-based framework for building modern GTK4 applications in Julia. It provides a declarative and elegant way to create complex user interfaces by leveraging the power of `Efus.jl`'s templating engine and `Ionic.jl`'s reactivity.

## The Atak Ecosystem

Gtak.jl is a key part of a larger ecosystem of packages designed for building robust, high-performance applications:

-   **[Efus.jl](https://github.com/ken-morel/Efus.jl)**: The foundation of the ecosystem. It provides the core declarative UI templating language (Efus), a powerful reactivity model, and a component-based architecture.
-   **[Ionic.jl](https://github.com/ken-morel/Ionic.jl)**: The lightweight, powerful reactivity library that powers Efus.
-   **[Atak.jl](https://github.com/ken-morel/Atak.jl)**: Offers essential application-level services, including a file-system-based data persistence layer (`Store`) and a multi-threaded task `Scheduler`.
-   **Gtak.jl**: The bridge to the GTK4 toolkit. It provides a rich set of reactive UI components that wrap GTK widgets, making them available within the Efus templating language.

## Installation

To add Gtak.jl to your project, use the Julia package manager:

```julia
import Pkg
Pkg.add(url="https://github.com/ken-morel/Gtak.jl.git")
```
*Note: As Gtak.jl is under active development, you may prefer `Pkg.develop` to get the latest changes.*

## Getting Started: A "Hello, World!" App

Here is a complete, minimal application that demonstrates the core concepts of Gtak.jl.

```julia
using Gtak
using Gtak.Gtk4

function run_app()
    # Use spa() for a simple, single-window application
    app = Gtak.spa(id="com.example.helloworld") do _, _
        # The content of our window is a `StaticPage`.
        # We use the @staticpage_str macro with Efus syntax.
        @staticpage_str """
        Box orientation=:vertical spacing=10 margin=20
            Label text="Hello, World!"
            Button text="Click Me!" onclick=() -> println("Button was clicked!")
        """
    end

    # Run the application
    return run(app)
end

run_app()
```

This code creates a window with a label and a button. When the button is clicked, it prints a message to the console.

## Core Concepts

### 1. Application

The `Application` is the root of every Gtak.jl app. It manages windows, the application lifecycle, and can hold app-wide state.

-   `application(id) do ... end`: The standard way to create a multi-window application.
-   `Gtak.spa(id) do ... end`: A convenience function for creating a Single-Page Application with just one window.

### 2. Window

A `Window` represents a top-level window in your application. It contains a `Router` to manage its content and a `Scheduler` to handle UI updates.

### 3. Page

A `Page` represents the content displayed within a `Window`.

-   `@staticpage_str "..."`: Creates a `StaticPage` whose content is built only once. Ideal for simple, unchanging views.
-   `@reloadablepage_str "..."`: Creates a `ReloadablePage` that can be rebuilt on-the-fly, which is the key to enabling hot-reloading with `Revise.jl`.

### 4. Components and Widgets

The UI is built by composing `GtakComponent`s. These are defined using the Efus templating language. `Gtak.jl` provides a rich set of components that wrap GTK widgets, such as `Label`, `Button`, and `Box`.

## Reactivity and UI Updates

Gtak.jl makes it easy to build dynamic UIs that react to data changes.

1.  **Reactive State**: Store your application's state in `Reactant`s from `Ionic.jl`.
2.  **Reactive Templates**: In your Efus templates, use the `'` syntax to access reactive values (e.g., `Label text=my_reactant'`).
3.  **Automatic Updates**: When a `Reactant`'s value is changed (e.g., `my_reactant[] = "new value"`), Gtak.jl automatically detects which components are affected, marks them as "dirty", and schedules an update.
4.  **Efficient Rendering**: The `Scheduler` from `Atak.jl` processes these updates on a background thread and then applies the minimal necessary changes to the GTK widgets on the main UI thread, ensuring your application remains fast and responsive.

```julia
using Gtak, Gtak.Gtk4, Ionic

function reactive_example()
    # 1. Create a reactive state variable
    counter = Reactant(0)

    app = Gtak.spa(id="com.example.reactive") do _, _
        @staticpage_str """
        Box orientation=:vertical spacing=10 margin=20
            # 2. Bind the Label's text to the counter's value
            Label text="Current count: $(counter')"

            # 3. Modify the counter on button click
            Button text="Increment" onclick=() -> (counter[] += 1)
        """
    end
    run(app)
end

reactive_example()
```

## Hot-Reloading with `Revise.jl`

Gtak.jl is designed to work seamlessly with `Revise.jl` for an interactive development experience. By using `ReloadablePage`, you can see your UI changes instantly without restarting the application. Check out the `Tod.jl` example for a complete demonstration of how to set this up.

## Available Widgets

Gtak.jl provides a comprehensive set of reactive widgets. All widgets share a common set of properties like `margin`, `align`, `expand`, `cssclasses`, etc.

-   **Layout**: `Box`, `HBox`, `VBox`, `Grid`, `Paned`, `Frame`, `ScrolledWindow`, `Notebook`, `Separator`
-   **Buttons**: `Button`, `ToggleButton`, `CheckButton`, `LinkButton`, `Switch`
-   **Input**: `Entry`, `TextView`, `ComboBoxText`, `Scale`
-   **Display**: `Label`, `Image`, `ProgressBar`, `Spinner`
-   **Control Flow**: `For`, `Keyed`, `Switched` for building dynamic and conditional layouts.

For more detailed examples, please see the `Gtak.jl/examples` directory.