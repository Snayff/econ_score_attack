# Project Structure

## Overview
This document describes the folder structure and organisational principles for the project. The structure is designed for scalability, modularity, and ease of navigation, following best practices for Godot and simulation strategy games.

---

## Top-Level Folders

| Folder      | Purpose                                                      |
|-------------|--------------------------------------------------------------|
| features/   | All feature-specific code, scenes, data, and tests           |
| shared/     | Shared UI, data classes, utilities, assets, and shared tests |
| globals/    | Global scripts, autoloads, constants, event buses, library   |
| main/       | Main entry scene and script                                  |
| data/       | Global static data files                                     |
| dev_tools/tester/ | Test runner logic and configuration (test_suite.gd, test_runner.json) |

---

## Folder Details

### features/
- Contains all game features, grouped by domain.
- Each feature contains all scripts, scenes, data, and tests for that feature.
- Example:
  - `features/economic_actor/buildings/`
  - `features/economic_actor/people/`
  - `features/economy/market/`
  - `features/laws/`
  - `features/world/`

### shared/
- Contains all shared components, data classes, utilities, UI elements, and assets (art, audio, icons, etc.) used by multiple features.
- Also contains shared tests (integration, cross-feature, utility tests).
- Example:
  - `shared/ui/components/`
  - `shared/data_classes/`
  - `shared/utils/`
  - `shared/assets/`
  - `shared/tests/integration/`

### globals/
- Contains global scripts, autoloads, constants, event buses, and the library loader.
- Example:
  - `globals/constants.gd`
  - `globals/event_bus_game.gd`
  - `globals/event_bus_ui.gd`
  - `globals/library.gd`

### main/
- Contains only the main entry scene (`main.tscn`) and its script (`main.gd`).

### data/
- Contains external static data files (JSON, CSV, etc.) referenced by features or globals, unless only used by one feature.

---

## Tests
- **Feature-specific tests**: Located in `features/feature_name/tests/`.
- **Integration/cross-feature tests**: Located in `shared/tests/`.
- Only use `shared/tests/` for tests that are not specific to a single feature.

---

## Naming and Organisation Principles
- Everything feature-specific lives in its feature folder.
- Anything reused by multiple features goes in `shared/`.
- Anything global, stateless, or cross-cutting goes in `globals/`.
- The main entry scene and script are in `main/`.
- External data is in `data/` unless only used by one feature.
- Assets are always in `shared/assets/`.

---

## Migration Plan
1. Plan feature domains and groupings.
2. Create the new folder structure as above.
3. Move feature-specific files (scripts, scenes, data, tests) into their feature folders.
4. Move shared components and assets into `shared/`.
5. Move global scripts into `globals/`.
6. Move main entry scene and script into `main/`.
7. Move static data into `data/` (unless only used by one feature).
8. Update all resource paths and imports in scripts and scenes.
9. Test the project and fix any broken references.
10. Document the new structure in this file.

---

## Example Structure

```
features/
  economic_actor/
    buildings/
      building.gd
      building_data.json
      building_ui.tscn
      tests/
    people/
      person.gd
      person_data.json
      person_ui.tscn
      tests/
    jobs/
      job.gd
      job_data.json
      job_ui.tscn
      tests/
  economy/
    market/
      market.gd
      market_data.json
      market_ui.tscn
      tests/
    production/
      production.gd
      production_data.json
      production_ui.tscn
      tests/
  laws/
    law.gd
    law_data.json
    law_ui.tscn
    tests/
  world/
    tile.gd
    tile_data.json
    tile_ui.tscn
    tests/

shared/
  ui/
    components/
      btn_custom.gd
      lbl_money.gd
    scenes/
      popup_confirm.tscn
  data_classes/
    data_building.gd
    data_person.gd
    data_job.gd
  utils/
    math_utils.gd
    string_utils.gd
  assets/
    icons/
    audio/
  tests/
    integration/
    performance/

globals/
  constants.gd
  event_bus_game.gd
  event_bus_ui.gd
  library.gd

main/
  main.tscn
  main.gd

data/
  rules/
  configs/
```

---

## Rationale
This structure is designed to:
- Maximise modularity and scalability.
- Make navigation intuitive for both new and experienced developers.
- Support feature-driven development and testing.
- Keep shared and global resources discoverable and logically separated.
- Align with Godot and general game development best practices. 