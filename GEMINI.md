# Gtak.jl Internals

This document provides an overview of the internal architecture of `Gtak.jl`, a reactive component-based framework for building GTK4 applications in Julia.

## Core Concepts

The framework is built around a few core concepts that work together to create a declarative and reactive UI layer on top of `Gtk4.jl`.

### 1. Application

The `Application` is the root of a `Gtak.jl` application. It is responsible for:

-   Managing the GTK application lifecycle.
-   Holding a collection of `Window`s.
-   Providing a central store for application-wide data and state.

An application is created using the `application` function, which takes an initialization function and an application ID.

```julia
using Gtak

app = application("com.example.myapp") do app
    # Initialize windows and other resources here
end

run(app)
```

### 2. Window

A `Window` represents a top-level window in the application. Each window has:

-   A `Router` to manage its content (pages).
-   A `Scheduler` for managing UI updates.
-   A title and other window properties.

Windows are created with the `window` function and are associated with an `Application`.

```julia
window(app) do win
    # Define the content of the window here
    # This can return a Page or a PageBuilder
end
```

### 3. Router and Pages

The `Router` manages the navigation within a `Window`. It maintains a history of `Page`s and a `current_page` reactant.

-   `push!(router, page)`: Navigates to a new page.
-   `pop!(router)`: Goes back to the previous page in the history.

A `Page` is a `GtakComponent` that represents a view within a `Window`. There are two main types of pages:

-   `StaticPage`: The content is built once and does not change.
-   `ReloadablePage`: The content can be rebuilt by calling `reload!(page)`. This is useful for development and for views that need to be completely reconstructed.

Pages are typically created using the `@staticpage_str` or `@reloadablepage` macros, which use the Efus templating language.

### 4. Components and Widgets

The UI is built by composing `GtakComponent`s. A `GtakComponent` is a struct that holds the state and logic for a part of the UI.

`GtakWidgetComponent`s are a special type of component that wrap a `Gtk4.jl` widget. They provide a reactive interface to the underlying GTK widgets. All widget components share a set of common properties like `margin`, `align`, `expand`, etc.

New widget components are defined using the `@gtakwidgetcomponent` macro.

```julia
@gtakwidgetcomponent MyWidget begin
    # component-specific properties here
end

function mount!(c::MyWidget, p::GtakComponent)
    # Create the Gtk widget and set up event handlers
end

function update!(c::MyWidget)
    # Update the Gtk widget when properties change
end
```

### 5. Reactivity and Scheduling

`Gtak.jl` leverages the reactivity model from `Efus.jl`. Component properties can be `Reactant`s or `Reactor`s. When a reactive property changes, the component is marked as "dirty".

The `Scheduler` is responsible for updating dirty components. It runs on a separate thread and processes UI updates in a prioritized queue. This ensures that the UI remains responsive even when background tasks are running.

When a component property is changed, `dirty!(component, :property_name)` is called. This pushes an update task to the scheduler, which will then call the `update!` method for that component.

## Available Widgets

`Gtak.jl` provides a growing set of reactive widgets, including:

-   `Box`, `HBox`, `VBox`
-   `Button`
-   `CheckButton`
-   `ComboBoxText`
-   `Entry`
-   `Frame`
-   `Grid`
-   `Image`
-   `Label`
-   `LinkButton`
-   `Notebook`
-   `Paned`, `HPaned`, `VPaned`
-   `ProgressBar`
-   `Scale`
-   `ScrolledWindow`
-   `Separator`
-   `Spinner`
-   `Switch`
-   `TextView`
-   `ToggleButton`
