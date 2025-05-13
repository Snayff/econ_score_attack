# UI Layout System

## Last Updated: 2025-05-13

---

## Overview

The UI Layout System standardises the structure and presentation of all major views in the game, ensuring a consistent, modular, and accessible user experience. Each view is composed of a set of defined regions—sidebars, top bar, and centre panel—using reusable UI components. This approach supports keyboard-only, controller-only, and keyboard-and-mouse navigation, and is designed for scalability and maintainability.

---

## Intent

- Provide a uniform structure for all main game views, improving usability and player orientation.
- Enable modular development by allowing each view to be developed and maintained independently, while sharing a common layout and component library.
- Facilitate accessibility and navigation by ensuring predictable placement of actions, navigation, and contextual information.
- Leverage Godot's UI system and the project's component-based architecture for maximum reusability and clarity.

---

## Layout Structure

### Main UI Regions

| Region           | Purpose                        | Example Components                | Folder Location                      |
|------------------|-------------------------------|-----------------------------------|--------------------------------------|
| GlobalTopBar     | Key demesne/player info        | Status indicators, labels         | main/ui/                             |
| GlobalSidebar    | Navigation between Views       | btn_sidebar_button, main_sidebar.tscn | main/ui/                        |
| TurnPanel        | Turn controls/info             | Buttons, labels                   | main/ui/                             |
| Viewport         | Hosts the current Viewport*    | ViewportPanel                     | main/ui/                             |

*The Viewport is the main content area where feature-specific views are loaded.

### Viewport Regions (within ViewportPanel)

| Region                | Purpose                        | Example Components                | Folder Location                      |
|-----------------------|--------------------------------|-----------------------------------|--------------------------------------|
| ViewportTopBar        | Sub View selection (tabs)      | HBoxContainer, custom buttons     | shared/ui/component/panels/          |
| ViewportSidebarLeft   | Contextual actions             | btn_sidebar_button                | shared/ui/component/buttons/         |
| ViewportSidebarRight  | Contextual info/details        | Info panels, labels               | shared/ui/component/labels/          |
| ViewportContentPanel  | Main content                   | Custom panels, feature views      | feature/*/ui/                        |

---

## Example Layout (Node Structure)

```
MainUI (Control)
 ├── GlobalTopBar (HBoxContainer)
 ├── GlobalSidebar (PanelContainer, instanced from main_sidebar.tscn)
 ├── TurnPanel (Panel)
 └── ViewportPanel (PanelContainer)
      ├── ViewportTopBar (HBoxContainer)
      ├── ViewportMainArea (HBoxContainer)
           ├── ViewportSidebarLeft (VBoxContainer)
           ├── ViewportContentPanel (PanelContainer)
           └── ViewportSidebarRight (VBoxContainer, optional)
```

---

## Tab Focus and Navigation

- All interactive elements are included in a logical tab order, starting from GlobalSidebar, then GlobalTopBar, TurnPanel, and finally the ViewportPanel and its children.
- Within the ViewportPanel, tab order proceeds: ViewportTopBar → ViewportSidebarLeft → ViewportContentPanel → ViewportSidebarRight (if present).
- Godot's `FocusNeighbour` properties are set to ensure predictable keyboard/controller navigation, supporting both vertical and horizontal movement.
- When switching Views or Sub Views, focus is automatically set to the most contextually relevant element (e.g., the first button in ViewportTopBar or the first actionable item in ViewportSidebarLeft).
- All regions are accessible via keyboard/controller, and focus is visually indicated.

---

## Optional Right Sidebar (ViewportSidebarRight)

- The ViewportSidebarRight is optional and can be shown or hidden based on the requirements of the current Sub View.
- When hidden, the ViewportContentPanel expands to use the available space, ensuring no wasted UI real estate.
- The presence or absence of ViewportSidebarRight is managed via a property or method in the ViewportPanel script, and the layout updates dynamically.

---

## Implementation Plan

### 1. ViewportPanel Scene and Script
- Create a `ViewportPanel.tscn` scene and `ViewportPanel.gd` script in `shared/ui/component/panels/`.
- Structure the scene as described above, using Godot containers for layout.
- Expose properties to show/hide the right sidebar as needed.
- Provide methods for setting the centre panel content and handling sidebar/topbar actions via signals.

### 2. Component Library
- Use and expand the existing component library in `shared/ui/component/` for buttons, panels, and labels.
- Reference: `btn_sidebar_button.gd` for sidebar actions.
- Add new reusable components as needed for top bar tabs, info panels, etc.

### UIFactory: Standardised UI Element Creation

The project provides a global autoload, `UIFactory`, to standardise the creation of common UI elements for viewport panels, sidebars, and buttons. This ensures a consistent look and feel across all views and reduces code duplication.

**Location:** `global/ui_factory.gd` (autoloaded as `UIFactory`)

#### Provided Functions

- `create_viewport_sidebar_header_label(text: String) -> Label`
  - Creates a header label for the top of a viewport sidebar.
- `create_viewport_panel_header_label(text: String) -> Label`
  - Creates a header label for the top of a viewport panel.
- `create_viewport_sidebar_button_container() -> FlowContainer`
  - Creates a FlowContainer for holding sidebar buttons.
- `create_button(text: String, pressed_func: Callable = null) -> Button`
  - Creates a standard button, optionally connecting a pressed signal.

#### Example Usage

```gdscript
# Add a header to a sidebar
var header = UIFactory.create_viewport_sidebar_header_label("Actions")
set_left_sidebar_content([header])

# Add a header to the main panel
var panel_header = UIFactory.create_viewport_panel_header_label("Population Overview")
set_centre_content([panel_header, ...])

# Create a sidebar button container and add buttons
var button_container = UIFactory.create_viewport_sidebar_button_container()
var btn1 = UIFactory.create_button("Enact", _on_enact_pressed)
var btn2 = UIFactory.create_button("Repeal", _on_repeal_pressed)
button_container.add_child(btn1)
button_container.add_child(btn2)
set_left_sidebar_content([header, button_container])

# Create a button for a top bar
var top_btn = UIFactory.create_button("Refresh", _on_refresh_pressed)
set_top_bar_content([top_btn])
```

**When to use:**
- Always use UIFactory for creating standard headers, buttons, and sidebar containers in viewport-related UI.
- This ensures visual consistency and makes it easy to update UI standards project-wide.

### 3. View Implementation
- Each feature (e.g., Economy, Law, World) implements its own view scene, inheriting from `ViewportPanel`.
- Example: `feature/economy/ui/viewport_economy.tscn`, `feature/law/ui/viewport_laws.tscn`, `feature/world/ui/viewport_world_panel.tscn`.
- The ViewportContentPanel is populated with feature-specific content, while sidebars and top bar use shared components.

### 4. Main UI Integration
- The main UI scene (e.g., `main/ui/`) contains the GlobalSidebar (instanced from `main_sidebar.tscn`) and a container for loading the current viewport.
- When the player selects a view, the corresponding scene is loaded into the container.
- Navigation and focus are managed to support keyboard and controller input, using Godot's focus system and `FocusNeighbour` properties.

### 5. Signals and Decoupling
- All communication between UI regions and the main UI is handled via signals, not direct node references.
- **Sidebar button presses are emitted as signals from `main_sidebar.gd` and relayed via the global `EventBusUI` autoload. The main UI listens for these signals to switch views.**
- Example signals: `sidebar_people_pressed`, `sidebar_laws_pressed`, etc.

### 6. Accessibility and Responsiveness
- Ensure all regions are accessible via keyboard/controller, with logical tab order and focus management.
- Avoid horizontal scroll; use size flags and anchors to fit content to the screen.
- Allow optional hiding of the right sidebar for viewports that do not require it.

### 7. Documentation and Maintenance
- This document is maintained in `dev/docs/docs/systems/ui_layout.md`.
- Update this document whenever the layout system or component library is changed.
- Each new viewport should include a class docstring referencing this system and describing its specific usage.

---

## How to Create a New Viewport

1. Inherit from `ViewportPanel` in your new viewport scene and script.
2. Populate the ViewportContentPanel with your feature's content.
3. Use shared components for sidebars and top bar.
4. Emit signals for actions and navigation; do not directly reference other nodes.
5. Register your viewport with the main UI for selection.

---

## Future Considerations

- Expand the component library with more reusable UI elements as needed.
- Consider supporting dynamic layouts for special cases (e.g., pop-out panels).
- Review accessibility and navigation regularly as new features are added.

--- 