# UI Viewport Layout System

## Last Updated: 2024-06-11

---

## Overview

The UI Viewport Layout System standardises the structure and presentation of all major views in the game, ensuring a consistent, modular, and accessible user experience. Each view is composed of a set of defined regions—sidebars, top bar, and centre panel—using reusable UI components. This approach supports keyboard-only, controller-only, and keyboard-and-mouse navigation, and is designed for scalability and maintainability.

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
| GlobalSidebar    | Navigation between Views       | btn_sidebar_button                | shared/ui/component/buttons/         |
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
 ├── GlobalSidebar (VBoxContainer)
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

### 3. View Implementation
- Each feature (e.g., Economy, Law, World) implements its own view scene, inheriting from `ViewportPanel`.
- Example: `feature/economy/ui/viewport_economy.tscn`, `feature/law/ui/viewport_laws.tscn`, `feature/world/ui/viewport_world_panel.tscn`.
- The ViewportContentPanel is populated with feature-specific content, while sidebars and top bar use shared components.

### 4. Main UI Integration
- The main UI scene (e.g., `main/ui/`) contains the global sidebar and a container for loading the current viewport.
- When the player selects a view, the corresponding scene is loaded into the container.
- Navigation and focus are managed to support keyboard and controller input, using Godot's focus system and `FocusNeighbour` properties.

### 5. Signals and Decoupling
- All communication between UI regions and the main UI is handled via signals, not direct node references.
- Example signals: `viewport_left_action_selected`, `viewport_top_tab_selected`, `viewport_right_info_requested`.
- Signals are connected in `_ready()` and disconnected on node removal.

### 6. Accessibility and Responsiveness
- Ensure all regions are accessible via keyboard/controller, with logical tab order and focus management.
- Avoid horizontal scroll; use size flags and anchors to fit content to the screen.
- Allow optional hiding of the right sidebar for viewports that do not require it.

### 7. Documentation and Maintenance
- This document is maintained in `dev/docs/docs/systems/ui_view_layout.md`.
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