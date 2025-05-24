# Sub View System Design

## Last Updated: 2025-05-24

---

## Overview

The Sub View System provides a modular, data-driven approach for managing sub views within each main view of the game UI. It enables dynamic switching between sub views (e.g., Population, Decisions) within a view (e.g., People), with each sub view controlling its own left sidebar, right sidebar, and centre panel. The system is designed for extensibility, accessibility, and maintainability, following the project's component-based and data-driven principles.

---

## Intent

- Decouple sub view selection logic from sub view content.
- Allow each main view to define its available sub views via external data (JSON), supporting easy extension and localisation.
- Ensure sub view switching is fast and robust, with all sub view nodes present in the scene tree and only the active one enabled.
- Support icons and tooltips for sub view selection buttons, defined in data.
- Maintain accessibility and logical focus order for keyboard/controller navigation.
- Ensure no state is persisted between game sessions (last selected sub view is per session only).

---

## Structure

### Main Components

- **Sub View Selector Scene** (`shared/ui/component/panels/templates/sub_view_selector.tscn`):
  - Manages the top bar for sub view selection.
  - Loads sub view definitions from data (via `Library`).
  - Instantiates all sub view scenes and manages their visibility/enabled state.
  - Handles switching logic and emits signals on sub view change.
  - Supports icons and tooltips for sub view buttons.

- **Sub View Base Scene** (`shared/ui/component/panels/templates/template_sub_view.tscn`):
  - Contains left sidebar, centre panel, and right sidebar.
  - Used as the base for all sub view scenes.

- **Sub View Base Script** (`shared/ui/component/panels/templates/abc_sub_view.gd`):
  - Provides API for populating sidebars and centre panel.
  - Emits signals for sidebar actions, info requests, etc.

- **Sub View Scenes** (`feature/*/ui/sub_view_*.tscn`):
  - Inherit from the sub view base scene and script.
  - Implement feature-specific content and logic.

- **Sub View Data** (`feature/*/data/*_sub_views.json`):
  - Defines available sub views for each main view, including id, label, icon, tooltip, and scene path.

---

## Data Example

```json
[
  { "id": "population", "label": "Population", "icon": "res://shared/asset/icons/population.svg", "tooltip": "View population details", "scene_path": "res://feature/people/ui/sub_view_population.tscn" },
  { "id": "decisions", "label": "Decisions", "icon": "res://shared/asset/icons/decisions.svg", "tooltip": "Make decisions", "scene_path": "res://feature/people/ui/sub_view_decisions.tscn" }
]
```

---

## Key Behaviours

- On view load, the sub view selector loads all sub view scenes and displays the last selected (or first, if none selected this session).
- Sub view selection buttons are created using UIFactory, with icons and tooltips.
- Only the active sub view is enabled; others are disabled but remain in the tree for fast switching.
- Focus is set to the first sub view button on load, and logical tab order is maintained.
- All sub view actions are signalled, not directly referenced.

---

## Accessibility & Testing

- All sub view buttons and content are accessible via keyboard/controller.
- Focus neighbours are set for predictable navigation.
- Core functionality is tested at each phase, with regression checks between stages.

---

## Related Existing Files

- `shared/ui/component/panels/templates/template_view.tscn`
- `shared/ui/component/panels/templates/abc_view.gd`
- `shared/ui/component/panels/templates/abc_view.gd.uid`
- `shared/ui/component/panels/abc_view.tscn`
- `main/ui/main_ui.gd`
- `shared/ui/data_class/data_sub_view.gd` (referenced, may need to be created)
- `feature/economic_actor/data/people.json`
- `feature/law/data/laws.json`
- `global/library.gd`
- `global/ui_factory.gd` 