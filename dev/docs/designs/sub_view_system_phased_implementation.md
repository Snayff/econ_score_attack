 # Sub View System: Phased Implementation

## Last Updated: 2025-05-24

---

## Overview

This document outlines a phased approach for implementing the Sub View System, ensuring robust, testable, and non-regressive integration into the existing UI architecture. Each phase includes a checklist of deliverables, required tests, and regression checks. The plan is written for clarity and precision, suitable for execution by an LLM/AI agent.

---

## Phase 1: Foundation & Refactor

### Objectives
- Refactor existing template and abstract view files to support the new sub view system.
- Prepare the codebase for modular sub view selection and content.

### Checklist
- [ ] Rename `template_view.tscn` to `sub_view_selector.tscn` (or similar universal name).
- [ ] Refactor the scene to only manage the sub view top bar and sub view container.
- [ ] Remove left/right sidebar and centre panel from this scene.
- [ ] Create a new script (e.g., `SubViewSelector.gd`) to:
  - [ ] Load sub view definitions from data (via `Library`).
  - [ ] Instantiate all sub view scenes and manage their enabled/visible state.
  - [ ] Handle switching logic and emit signals on sub view change.
  - [ ] Create sub view selection buttons with icons and tooltips (using UIFactory).
  - [ ] Remember last selected sub view for the session.
- [ ] Update documentation to reflect these changes.

### Testing
- [ ] Unit test: Sub view selector loads and displays correct sub view on selection.
- [ ] Regression: Ensure main view switching (via global sidebar) is unaffected.

---

## Phase 2: Sub View Base & Template

### Objectives
- Establish a standard template and base script for all sub views.

### Checklist
- [ ] Create `template_sub_view.tscn` with left sidebar, centre panel, and right sidebar.
- [ ] Create `abc_sub_view.gd` (from refactored `abc_view.gd`) to manage these regions.
- [ ] Update all existing sub view scenes/scripts to inherit from this template and script.
- [ ] Remove top bar logic from sub view scripts.
- [ ] Update documentation and usage examples.

### Testing
- [ ] Unit test: Sub view base correctly populates and clears all regions.
- [ ] Regression: Ensure no orphaned nodes or UI artefacts after switching sub views.

---

## Phase 3: Data-Driven Sub View Definitions

### Objectives
- Move sub view definitions to external JSON files for each feature.

### Checklist
- [ ] Create JSON files (e.g., `feature/economic_actor/data/people_sub_views.json`) defining sub views (id, label, icon, tooltip, scene path).
- [ ] Update `Library` to load these definitions.
- [ ] Update `SubViewSelector.gd` to use data-driven definitions.
- [ ] Add support for icons and tooltips in sub view buttons.
- [ ] Ensure all labels are localisable.
- [ ] Update documentation and data schema.

### Testing
- [ ] Unit test: Sub view selector loads definitions from JSON and displays correct buttons.
- [ ] Regression: Ensure fallback to first sub view if data is missing or malformed.

---

## Phase 4: Integration & Accessibility

### Objectives
- Integrate the new sub view system into all main views and ensure accessibility.

### Checklist
- [ ] Update all main view scenes to use the sub view selector.
- [ ] Remove direct sidebar/centre management from main views.
- [ ] Ensure focus and tab order are logical and accessible.
- [ ] Add tooltips and visual focus indicators to sub view buttons.
- [ ] Update system documentation and usage guides.

### Testing
- [ ] Integration test: Full navigation from global sidebar to sub view content.
- [ ] Accessibility test: All sub view buttons and content are keyboard/controller accessible.
- [ ] Regression: No loss of functionality in main UI or sub view content.

---

## Phase 5: Final Testing & Regression Suite

### Objectives
- Ensure system stability, performance, and maintainability.

### Checklist
- [ ] Comprehensive regression suite for all sub view and main view interactions.
- [ ] Performance test: Sub view switching is fast and does not leak memory.
- [ ] Code review: All signals, data access, and UI updates follow project conventions.
- [ ] Documentation: All changes reflected in system and API docs.

### Testing
- [ ] Run full regression and integration test suite.
- [ ] Manual playtest for edge cases and UI polish.

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
