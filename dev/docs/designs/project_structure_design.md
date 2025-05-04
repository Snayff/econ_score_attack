# Project Structure Design

## Overview
This document outlines the architectural design decisions for organising the project's codebase. The structure emphasises modularity, scalability, and developer ergonomics, while supporting feature-driven development and testing.

## Design Goals
- **Modularity**: Each feature is self-contained with clear boundaries
- **Scalability**: Easy addition of new features without restructuring
- **Discoverability**: Intuitive navigation for new and experienced developers
- **Testability**: Support for unit, integration, and cross-feature testing
- **Maintainability**: Clear separation of concerns and minimal coupling

## Architecture

### Core Principles
1. **Feature-First Organisation**
   - Features are the primary organisational unit
   - All code, scenes, data, and tests for a feature are stored under `features/<feature_name>/`, with relevant subfolders (e.g., `ui/`, `data/`, `tests/`)
   - Features can be grouped into domains for better navigation
   - Each feature contains all its specific code, scenes, data, and tests

2. **Shared Resource Management**
   - Common components live in a central shared location
   - Assets are treated as shared resources by default
   - Cross-feature tests are considered shared resources

3. **Global State Management**
   - Global scripts are strictly limited and clearly separated
   - Autoloads are used only for truly global concerns
   - Event buses handle cross-feature communication

4. **Data Management**
   - Feature-specific data lives with the feature
   - Global data is centralised
   - External data files are version controlled

## Folder Structure

### Top-Level Organisation
```
features/     # Feature-specific code, scenes, data, and tests
shared/       # Shared components and resources
globals/      # Global scripts and autoloads
main/         # Entry point scene and script
data/         # Global data files (if not feature-specific)
```

### Feature Structure
Each feature is self-contained and may include subfolders for UI, data, and tests:
```
features/
  world/
    ui/                # UI scenes and scripts for the feature
    data/              # Feature-specific data files (optional)
    tests/             # Unit and integration tests for the feature
    ...                # Other subfolders as needed (e.g., logic/, components/)
    <feature_code>.gd  # Main script(s) for the feature
```

#### Example: World Map Feature
```
features/
  world/
    ui/
      land_view_panel.tscn
      land_view_panel.gd
      ...
    data/
      land_config.json
      ...
    tests/
      test_land_system.gd
      ...
```

### Shared Resources
```
shared/
  ui/
    components/      # Reusable UI elements
    scenes/         # Shared UI scenes
  data_classes/     # Common data structures
  utils/           # Utility functions
  assets/          # Art, audio, icons
  tests/           # Cross-feature tests
```

### Global Scripts
```
globals/
  constants.gd       # Global constants
  event_bus_game.gd  # Game event communication
  event_bus_ui.gd    # UI event communication
  library.gd         # Resource loading
```

## Design Decisions

### Why Feature-First?
- Supports domain-driven design
- Makes feature boundaries explicit
- Reduces cognitive load when working on a feature
- Simplifies feature addition and removal
- Keeps all relevant code, data, and tests together

### Why Shared Resources?
- Prevents code duplication
- Centralises common functionality
- Makes updates to shared components easier
- Encourages reuse over recreation

### Why Separate Globals?
- Makes global state explicit and visible
- Reduces temptation to add new globals
- Centralises cross-cutting concerns

### Why Tests with Features?
- Keeps tests close to implementation
- Makes test maintenance easier
- Encourages comprehensive testing
- Cross-feature tests in shared/ highlight integration points

## Constraints and Guidelines

### Feature Guidelines
- Features should be self-contained
- Cross-feature communication via event buses
- Feature-specific data stays with feature
- Each feature has its own tests
- Use subfolders (e.g., `ui/`, `data/`, `tests/`) for clarity and organisation

### Shared Resource Guidelines
- Must be used by multiple features
- Should be generic and reusable
- Must be well-documented
- Should have comprehensive tests

### Global Guidelines
- Minimal use of globals
- Must serve cross-cutting concern
- Must be stateless where possible
- Should use event-based communication

## Migration Considerations
- Gradual migration path possible
- Can move features one at a time
- Need to update resource paths
- Should maintain working state throughout 