# UI View Layout System

## Last Updated: 2024-06-09

---

## Overview

The UI View Layout System standardises the structure and presentation of all major views in the game, ensuring a consistent, modular, and accessible user experience. Each view is composed of a set of defined regions—sidebars, top bar, and centre panel—using reusable UI components. This approach supports keyboard-only, controller-only, and keyboard-and-mouse navigation, and is designed for scalability and maintainability.

---

## Intent

- Provide a uniform structure for all main game views, improving usability and player orientation.
- Enable modular development by allowing each view to be developed and maintained independently, while sharing a common layout and component library.
- Facilitate accessibility and navigation by ensuring predictable placement of actions, navigation, and contextual information.
- Leverage Godot's UI system and the project's component-based architecture for maximum reusability and clarity.

---

## Layout Structure

Each view consists of the following regions:

| Region           | Purpose                        | Example Components                | Folder Location                      |
|------------------|-------------------------------|-----------------------------------|--------------------------------------|
| Left Sidebar     | Contextual actions             | btn_sidebar_button                | shared/ui/component/buttons/         |
| Top Bar          | Sub-categories/tabs            | HBoxContainer, custom buttons     | shared/ui/component/panels/          |
| Right Sidebar    | Contextual info/details        | Info panels, labels               | shared/ui/component/labels/          |
| Centre Panel     | Main content                   | Custom panels, feature views      | feature/*/ui/                        |

- **Main UI**: Contains the global sidebar for switching between major views, and a ViewContainer for loading the current view.
- **View**: Each view is a scene that inherits from a BaseView, ensuring the standard layout.

---

## Example Layout (Node Structure)

```
BaseView (extends Control)
 ├── HBoxContainer
 │    ├── VBoxContainer (LeftSidebar)
 │    ├── VBoxContainer (MainArea)
 │    │    ├── TopBar (HBoxContainer)
 │    │    ├── CentrePanel (PanelContainer)
 │    ├── VBoxContainer (RightSidebar, optional)
```

---

## Implementation Plan

### 1. BaseView Scene and Script
- Create a `BaseView.tscn` scene and `BaseView.gd` script in `shared/ui/component/panels/`.
- Structure the scene as described above, using Godot containers for layout.
- Expose properties to show/hide the right sidebar as needed.
- Provide methods for setting the centre panel content and handling sidebar/topbar actions via signals.

### 2. Component Library
- Use and expand the existing component library in `shared/ui/component/` for buttons, panels, and labels.
- Reference: `btn_sidebar_button.gd` for sidebar actions.
- Add new reusable components as needed for top bar tabs, info panels, etc.

### 3. View Implementation
- Each feature (e.g., Economy, Law, World) implements its own view scene, inheriting from `BaseView`.
- Example: `feature/economy/ui/view_economy.tscn`, `feature/law/ui/view_laws.tscn`, `feature/world/ui/world_view_panel.tscn`.
- The centre panel is populated with feature-specific content, while sidebars and top bar use shared components.

### 4. Main UI Integration
- The main UI scene (e.g., `main/ui/`) contains the global sidebar and a container for loading the current view.
- When the player selects a view, the corresponding scene is loaded into the container.
- Navigation and focus are managed to support keyboard and controller input, using Godot's focus system and `FocusNeighbour` properties.

### 5. Signals and Decoupling
- All communication between UI regions and the main UI is handled via signals, not direct node references.
- Example signals: `left_action_selected`, `top_tab_selected`, `right_info_requested`.
- Signals are connected in `_ready()` and disconnected on node removal.

### 6. Accessibility and Responsiveness
- Ensure all regions are accessible via keyboard/controller, with logical tab order and focus management.
- Avoid horizontal scroll; use size flags and anchors to fit content to the screen.
- Allow optional hiding of the right sidebar for views that do not require it.

### 7. Documentation and Maintenance
- This document is maintained in `dev/docs/docs/systems/ui_view_layout.md`.
- Update this document whenever the layout system or component library is changed.
- Each new view should include a class docstring referencing this system and describing its specific usage.

---

## How to Create a New View

1. Inherit from `BaseView` in your new view scene and script.
2. Populate the centre panel with your feature's content.
3. Use shared components for sidebars and top bar.
4. Emit signals for actions and navigation; do not directly reference other nodes.
5. Register your view with the main UI for selection.

---

## Future Considerations

- Expand the component library with more reusable UI elements as needed.
- Consider supporting dynamic layouts for special cases (e.g., pop-out panels).
- Review accessibility and navigation regularly as new features are added.

--- 