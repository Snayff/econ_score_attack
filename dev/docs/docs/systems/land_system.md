# Land System

## Overview
The Land System manages the demesne's 2D land grid, ensuring all parcels are data-driven, modular, and updated in real time. It is foundational to the closed-loop economy, as all production and consumption are tied to parcels.

- The grid is initialised from external JSON config (`land_config.json`) via the `Library` autoload.
- The centre-most parcel is always surveyed on initialisation.
- All land data is encapsulated in `DataLandParcel` data classes.

---

## Core Concepts

- **Closed-Loop Economy:** All goods must be produced and consumed within the grid; nothing is created ex nihilo.
- **Dynamic Market:** Resource availability and land improvements affect economic activity and prices.
- **Physical Grid:** The world is a 2D array of parcels, each with unique coordinates and state.
- **Buildings and Jobs:** Buildings are placed on parcels, creating jobs and enabling production.
- **Laws and Parcel Properties:** Laws and static parcel properties (e.g., fertility) influence parcel productivity.

---

## Separation of World State and Demesne Knowledge

- The world state, including all parcels and their properties, is universal and shared by all demesnes.
- Any change to a parcel (e.g., adding a building, expending an aspect) is a world-level change and is reflected for all demesnes.
- Each demesne (player, AI, etc.) maintains its own record of which parcels have been surveyed. This knowledge is tracked per demesne and is not global.
- The true properties of a parcel are only revealed to a demesne once it has completed a survey on that parcel.
- The UI only displays information for parcels that have been surveyed by the player's demesne. Parcels that have not been surveyed remain hidden or display limited information.

---

## Data Flow

- The demesne owns the land grid (`Array<Array<DataLandParcel>>`).
- Grid dimensions and data are exposed via `get_grid_dimensions()` and `land_grid`.
- The `LandManager` registers and manages all demesne grids, providing access and updates.
- All changes are signalled via the event bus for UI and system updates.

### Data Flow Diagram

```text
+-------------------+         +-------------------+         +-------------------+
|   land_config.json|         |   Library (autoload)        |   DataLandParcel   |
+-------------------+         +-------------------+         +-------------------+
         |                              |                              |
         |  (loads config)              |  (creates grid)              |
         +----------------------------->|----------------------------->|
         |                              |                              |
         |                              v                              |
         |                    +-------------------+                   |
         |                    |   Demesne         |                   |
         |                    +-------------------+                   |
         |                              |                              |
         |  (owns grid, exposes         |                              |
         |   land_grid, dimensions)     |                              |
         |                              v                              |
         |                    +-------------------+                   |
         |                    |   LandManager     |                   |
         |                    +-------------------+                   |
         |                              |                              |
         |  (registers grid, provides   |                              |
         |   access, emits updates)     |                              |
         |                              v                              |
         |                    +-------------------+                   |
         |                    |   EventBusGame    |                   |
         |                    +-------------------+                   |
         |                              |                              |
         |  (signals updates)           |                              |
         |                              v                              |
         |                    +-------------------+                   |
         |                    |   UI Components   |                   |
         |                    +-------------------+                   |
```

**Explanation:**
- The land grid is initialised from `land_config.json` via the `Library` autoload.
- The demesne owns the grid and exposes it.
- The `LandManager` registers and manages the grid, emitting updates via the event bus.
- UI components listen for signals and update accordingly.

---

## Signals

- `EventBusGame.land_grid_updated(parcel_data: DataLandParcel)`: Emitted on any parcel update.
- `WorldViewPanel.parcel_selected(parcel_id: int, parcel_data: DataLandParcel)`: Emitted on parcel selection in the UI.
- `parcel_selected(x: int, y: int)`: Emitted when a parcel is selected.
- `request_parcel_data(x: int, y: int)`: Requests data for a specific parcel.

All signals are connected/disconnected as per Godot best practice, and are never duplicated.

---

## Data Structures

### DataLandParcel

```gdscript
## Data class for a single land parcel.
## Example:
##   var parcel = DataLandParcel.new(x, y, "plains", {}, null, {}, 1.0, false, 0.0)
class_name DataLandParcel
extends RefCounted

var x: int
var y: int
var terrain_type: String
var resources: Dictionary
var building_id: int
var improvements: Dictionary
var fertility: float
var is_surveyed: bool
var resource_generation_rate: float

func add_resource(resource_id: String, amount: float, discovered: bool) -> void:
    # Adds a resource to the parcel.
    pass

func get_resource_amount(resource_id: String) -> float:
    # Returns the amount of a resource.
    pass

func discover_resource(resource_id: String) -> void:
    # Marks a resource as discovered.
    pass

func update_resources(delta: float) -> void:
    # Updates resource amounts over time.
    pass
```

---

## Land Management

### LandManager

- Registers each demesne's land grid.
- Provides access to parcels by coordinates.
- Emits updates via the event bus.
- Handles all requests for parcel data and updates.

### Architecture Diagram

```text
+-------------------+         +-------------------+
|   Demesne         |<------->|   LandManager     |
+-------------------+         +-------------------+
         |                              |
         |  (owns grid)                 |  (registers, manages grid)
         v                              v
+-------------------+         +-------------------+
|   DataLandParcel  |         |   EventBusGame    |
+-------------------+         +-------------------+
         |                              |
         |  (parcel data)               |  (signals)
         v                              v
+-------------------+         +-------------------+
|   UI Components   |<--------|   WorldViewPanel  |
+-------------------+         +-------------------+
```

**Explanation:**
- The demesne owns the land grid and interacts with the `LandManager`.
- The `LandManager` manages all grids and emits updates via the event bus.
- `DataLandParcel` holds all parcel data.
- UI components receive updates and display parcel information.

---

## LandManager Event Bus Decoupling

The LandManager manages all land grids for all demesnes and responds to data requests via signals. To ensure modularity and maintainability, LandManager is now fully decoupled from the EventBusGame and EventBusUI globals. Instead of referencing these event buses directly, it uses dependency-injected callables for event bus access. This is set up at runtime, typically in main.gd, after all autoloads are initialised.

**Rationale:**
- Each global/autoload should be stand-alone and not directly depend on other global.
- This approach improves testability, modularity, and future extensibility (e.g., supporting multiple event buses or test harnesses).

### Setup Example

```gdscript
# In main.gd, after other autoloads are initialised:
var get_event_bus_game = func(): return EventBusGame
var get_event_bus_ui = func(): return EventBusUI
LandManager.set_event_buses(get_event_bus_game, get_event_bus_ui)
```

### LandManager Overview
- Manages all demesne land grids and parcel access.
- Responds to parcel data requests using the injected game event bus.
- Emits updates using the injected UI event bus.
- Never references EventBusGame or EventBusUI directly, only using the injected callables.
- Can be easily tested or extended by swapping out the event bus callables.

### Benefits
- No tight coupling between LandManager and event bus globals.
- LandManager can be reused or tested in isolation.
- Follows best practices for Godot autoloads and modular system design.

---

## Survey System (Updated)

The Survey System is a core component of the Land System, responsible for managing the process of surveying land parcels to discover their resources and aspects. **Surveying is now handled by a SurveyManager component attached to each demesne, not by a global autoload.**

### Purpose and Integration

- **Survey Tracking:** Each demesne's SurveyManager maintains a dictionary of active surveys, tracking progress and turns remaining for each parcel being surveyed, per demesne.
- **Turn-Based Progression:** Survey progress advances each turn, and surveys are completed after a set number of turns (configurable in `survey_manager.gd`).
- **Signal-Based Communication:** SurveyManager emits signals (`survey_started`, `survey_progress_updated`, `survey_completed`) for survey events. These are **instance signals** and must be connected to per-demesne.
- **Decoupled Parcel Access:** SurveyManager does not reference the world or demesne grid directly. Instead, it uses a dependency-injected callable (the "parcel accessor") to access parcels, supporting flexible integration and easier testing.
- **Error Handling:** Invalid or failed survey attempts are handled gracefully, ensuring robust operation.
- **No Parcel Data Duplication:** SurveyManager does not store or duplicate parcel data; it only tracks which parcels have been surveyed by the demesne.

### Architecture (Updated)

SurveyManager is now a component of each demesne. Instead of referencing the world grid directly, it uses a dependency-injected callable for parcel access, typically set to the demesne's `get_parcel` method. SurveyManager emits instance signals for survey events. There is no global survey state or global signals.

```
+-------------------+
|   Demesne         |
+-------------------+
        |
        | (owns grid)
        v
+-------------------+
|   SurveyManager   |  (per demesne)
+-------------------+
        |
        | (parcel accessor)
        v
+-------------------+
|   DataLandParcel  |
+-------------------+
        |
        | (signals)
        v
+-------------------+
|   UI Components   |
+-------------------+
```

**Explanation:**
- Each demesne owns its own SurveyManager component.
- The SurveyManager uses a parcel accessor to get parcels from the demesne.
- Survey events are signalled per demesne, not globally.
- UI components must connect to the current demesne's SurveyManager signals.

### Setup Example (Updated)

```gdscript
# In Demesne.gd, after initialisation:
survey_manager.set_parcel_accessor(self.get_parcel)
```

### Usage (Updated)
- Start a survey:
  - `survey_manager.start_survey(x, y)`
- Get survey progress:
  - `survey_manager.get_survey_progress(x, y)`
- Process a turn:
  - `survey_manager.advance_turn()`
- Connect to signals:
  - `survey_manager.survey_started.connect(...)`
  - `survey_manager.survey_progress_updated.connect(...)`
  - `survey_manager.survey_completed.connect(...)`

### Benefits
- No tight coupling between SurveyManager and demesne internals.
- SurveyManager can be reused or tested in isolation.
- Follows best practices for Godot component-based design.
- Survey duration and logic are easily configurable.
- Survey state is tracked per demesne, not globally.
- SurveyManager does not store or duplicate parcel data.

### Developer Notes
- Always inject the parcel accessor at runtime to maintain decoupling.
- SurveyManager should not reference the demesne's grid directly.
- Use instance signals for all survey-related signalling.
- Keep survey logic focused and modular for maintainability.
- SurveyManager is a key part of the Land System, and its documentation is maintained here for clarity and cohesion.

### Associated File
- `feature/demesne/component/survey_manager.gd` (per-demesne component)

---

## Last Updated
2025-05-18

## Core Concepts
- **Grid-Based World:** The world is a 2D grid of parcels. Each parcel represents a discrete unit of land with its own state.
- **Closed-Loop Economy:** All goods must be produced and consumed within the grid; nothing is created ex nihilo.
- **Dynamic Market Integration:** Resource availability and land improvements directly affect economic activity and prices.
- **Physical Placement:** Buildings, jobs, and improvements are tied to specific parcels, influencing gameplay and strategy.

## Data Structures
### DataLandParcel
The `DataLandParcel` class encapsulates all data for a single parcel:
- `x`, `y`: Grid coordinates
- `terrain_type`: The type of terrain (e.g., "plains", "mountain")
- `resources`: A dictionary of resources available on the parcel
- `building_id`: The ID of the building on the parcel
- `improvements`: A dictionary of improvements on the parcel
- `fertility`: The fertility level of the parcel
- `pollution_level`: The pollution level of the parcel
- `is_surveyed`: Whether the parcel has been surveyed
- `resource_generation_rate`: The rate at which resources are generated on the parcel