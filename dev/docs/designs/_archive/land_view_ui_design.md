# Land View UI Design

## Overview
The Land View UI is a core part of the game's interface, allowing the player to interact with, visualise, and manage the demesne's land parcels. The design prioritises modularity, testability, and strict adherence to project rules and Godot best practices.

---

## Layout
- **Vertical split:**
  - **Column 1 (Tile Interaction):** Narrow, leftmost.
  - **Column 2 (World View):** Wide, centre.
  - **Column 3 (Tile Information):** Narrow, rightmost.
- **Node Structure:**
  - `HSplitContainer` (root of LandViewPanel)
    - `TileInteractionPanel` (`PanelContainer`, fixed min width)
    - `WorldViewPanel` (`PanelContainer`, expands)
    - `TileInfoPanel` (`PanelContainer`, fixed min width)

---

## World View (Scrolling & Tile Display)
- **Visible Tiles:** Always shows a 5x5 grid (25 tiles).
- **Scrolling:**
  - Player can scroll horizontally and vertically to change which 25 tiles are visible.
  - Scrolling controls: arrow buttons (up/down/left/right). Future: mini-map or drag-to-scroll.
- **Tile Representation:**
  - Each tile is a button or custom control.
  - Visual cues for surveyed/unsurveyed.
  - Only one tile can be selected at a time.

---

## Tile Interaction
- **Contents:**
  - Placeholder "Build" button.
  - (Future: context-sensitive actions.)

---

## Tile Information
- **Contents:**
  - If surveyed: terrain, building, resources.
  - If not: "Parcel not surveyed".

---

## Data Flow & Signals
- **WorldViewPanel** emits `tile_selected(tile_id: int)` when a tile is clicked.
- **LandViewPanel** listens and updates **TileInfoPanel**.
- **Scrolling:** WorldViewPanel maintains a "viewport" (top-left tile index); updates grid when scrolled.

---

## Modularity & Testability
- Each panel is a separate scene/component.
- All communication via signals.
- Data classes for tile/world state.
- UI logic separated from data/model logic.
- Use dependency injection for world/tile data (pass in mock data for tests).
- Expose methods to set/get scroll position and selected tile for automated UI tests.
- Decouple UI from game logic: UI emits intent signals (e.g., "build requested"), game logic handles them.
- Ensure all signals are disconnected on removal.
- Use unique IDs for tiles, not names.
- Document all classes and functions as per project rules.
- Use Godot's `GridContainer` for the tile grid, but wrap in a `PanelContainer` for scroll controls.
- Make grid and panels responsive to available space.
- All UI updates are driven by data changes, not hardcoded.

---

## Accessibility & Responsiveness
- Grid and panels should be responsive to available space.
- Allow for future enhancements (zoom, resize grid).

---

## Summary of Improvements
- Signals for all UI actions.
- Panels as independent, testable scenes.
- Data classes for all world/tile data.
- Dependency injection for data in panels.
- Expose methods for test automation (set scroll, select tile, etc.).
- Comprehensive documentation and code regions.
- Strict adherence to naming and architectural conventions.

---

## Next Steps
1. Confirm this design.
2. Draft a detailed implementation plan (scene tree, signals, data flow, class structure).
3. Begin with scaffolding: create empty panels, wire up signals, implement scrolling logic.
4. Iterate and test each component independently. 