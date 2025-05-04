# Land System

## Overview
The Land System manages the demesne's 2D land grid, ensuring all parcels (tiles) are data-driven, modular, and updated in real time. It is foundational to the closed-loop economy, as all production and consumption are tied to parcels.

- The grid is initialised from external JSON config (`land_config.json`) via the `Library` autoload.
- The centre-most parcel is always surveyed on initialisation.
- All land data is encapsulated in `DataLandParcel` data classes.

---

## Core Concepts

- **Closed-Loop Economy:** All goods must be produced and consumed within the grid; nothing is created ex nihilo.
- **Dynamic Market:** Resource availability and land improvements affect economic activity and prices.
- **Physical Grid:** The world is a 2D array of parcels, each with unique coordinates and state.
- **Buildings and Jobs:** Buildings are placed on parcels, creating jobs and enabling production.
- **Laws and Environment:** Laws and environmental factors (fertility, pollution) influence parcel productivity.

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
- `WorldViewPanel.tile_selected(tile_id: int, tile_data: DataLandParcel)`: Emitted on tile selection in the UI.
- `parcel_selected(x: int, y: int)`: Emitted when a parcel is selected.
- `request_parcel_data(x: int, y: int)`: Requests data for a specific parcel.

All signals are connected/disconnected as per Godot best practice, and are never duplicated.

---

## Data Structures

### DataLandParcel

```gdscript
## Data class for a single land parcel.
## Example:
##   var parcel = DataLandParcel.new(x, y, "plains", {}, null, {}, 1.0, 0.0, false, 0.0)
class_name DataLandParcel
extends RefCounted

var x: int
var y: int
var terrain_type: String
var resources: Dictionary
var building_id: int
var improvements: Dictionary
var fertility: float
var pollution_level: float
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
- Each global/autoload should be stand-alone and not directly depend on other globals.
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

## Survey System

The Survey System is a core component of the Land System, responsible for managing the process of surveying land parcels to discover their resources and aspects. Surveying is handled by the `SurveyManager` autoload, which tracks survey progress, handles survey completion, and emits signals for UI and game logic updates. The Survey System is designed to be modular, decoupled, and easily extensible.

### Purpose and Integration

- **Survey Tracking:** SurveyManager maintains a dictionary of active surveys, tracking progress and turns remaining for each parcel being surveyed.
- **Turn-Based Progression:** Survey progress advances each turn, and surveys are completed after a set number of turns (configurable in `survey_manager.gd`).
- **Signal-Based Communication:** SurveyManager emits signals (via EventBusGame) for survey started, progress, and completion, enabling other systems and UI to react to survey events.
- **Decoupled Parcel Access:** SurveyManager does not reference the World global directly. Instead, it uses an injected callable to access parcels, supporting flexible integration and easier testing.
- **Error Handling:** Invalid or failed survey attempts are handled gracefully, ensuring robust operation.

### Architecture

SurveyManager is fully decoupled from the World global. Instead of referencing the world grid directly, it uses a dependency-injected callable for parcel access. This is set up at runtime, typically in `main.gd`, after all autoloads are initialised. SurveyManager coordinates with EventBusGame for signalling and uses the injected callable for parcel access. It does not depend directly on World or other systems.

```
+-------------------+
|   SurveyManager   |
|   (autoload)      |
+-------------------+
        |
        | (injects parcel accessor)
        v
+-------------------+
|   Parcel Access   |
+-------------------+
        |
        | (signals)
        v
+-------------------+
|  EventBusGame     |
+-------------------+
        |
        v
+-------------------+
|   UI / Systems    |
+-------------------+
```

The diagram above shows SurveyManager's decoupled access to parcels and its use of EventBusGame for signalling survey events to the rest of the game.

### Setup Example

```gdscript
# In main.gd, after World is initialised:
SurveyManager.set_parcel_accessor(World.get_parcel)
```

### Usage

- Set the parcel accessor:
  - `SurveyManager.set_parcel_accessor(World.get_parcel)`
- Start a survey:
  - `SurveyManager.start_survey(x, y)`
- Get survey progress:
  - `SurveyManager.get_survey_progress(x, y)`
- Process a turn:
  - `SurveyManager.process_turn()`
- Signals are emitted via EventBusGame for survey events.

Example:
```gdscript
# Inject parcel accessor after World is initialised
SurveyManager.set_parcel_accessor(World.get_parcel)

# Start a survey
SurveyManager.start_survey(2, 3)

# Process a turn (typically called on turn completion)
SurveyManager.process_turn()
```

### Benefits
- No tight coupling between SurveyManager and World.
- SurveyManager can be reused or tested in isolation.
- Follows best practices for Godot autoloads and modular system design.
- Survey duration and logic are easily configurable.

### Extending the Survey System
- Adjust survey duration or progress logic by modifying constants in `survey_manager.gd`.
- Add new signals or survey-related features as needed.
- Update documentation if new survey types or mechanics are introduced.

### Developer Notes
- Always inject the parcel accessor at runtime to maintain decoupling.
- SurveyManager should not reference World or other systems directly.
- Use EventBusGame for all survey-related signalling.
- Keep survey logic focused and modular for maintainability.
- SurveyManager is a key part of the Land System, and its documentation is maintained here for clarity and cohesion.

### Associated File
- `globals/survey_manager.gd` (autoload singleton)

---

## Aspect System

The Aspect System is responsible for defining, managing, and procedurally generating land aspects—properties or features such as resources, terrain features, or special characteristics that can be assigned to parcels within the simulation. This system is handled by the `AspectManager` autoload, which ensures all aspect data is consistent, up-to-date, and available for use throughout the land system.

### Purpose and Responsibilities
- **Centralised Aspect Management:** AspectManager acts as the single source of truth for all land aspect definitions in the game.
- **Data Loading and Validation:** Loads aspect definitions from an external data source (via the Library autoload or an injected loader), ensuring all aspect data is consistent and up-to-date.
- **Procedural Generation:** Provides logic to procedurally generate aspects for a given land parcel, based on definitions and randomised rules (such as generation chance, number of instances, and resource amounts). This supports dynamic and data-driven world-building.
- **Aspect Querying:** Offers static methods to retrieve all aspect definitions or a specific aspect definition by its unique ID, making it easy for other systems to access this data without duplicating logic.
- **Error Handling and Logging:** Includes error handling (e.g., warnings if no aspects are found) and logs events for debugging and monitoring.

### Decoupled Architecture

To ensure modularity and maintainability, `AspectManager` is fully decoupled from the `Library` global. Instead of referencing the data loader directly, it uses a dependency-injected callable for loading aspect definitions. This is set up at runtime, typically in `main.gd`, after all autoloads are initialised.

**Rationale:**
- Each global/autoload should be stand-alone and not directly depend on other globals.
- This approach improves testability, modularity, and future extensibility (e.g., supporting multiple data sources or test harnesses).

### Setup Example

```gdscript
# In main.gd, after World and SurveyManager are initialised:
AspectManager.set_aspect_loader(Library.get_land_aspects)
```

### Usage
- Generate aspects for a parcel:
  - `AspectManager.generate_aspects_for_parcel(parcel)`
- Retrieve all aspect definitions:
  - `var all_aspects = AspectManager.get_all_aspect_definitions()`
- Get a specific aspect definition by ID:
  - `var aspect_def = AspectManager.get_aspect_definition("fertile_soil")`

Example:
```gdscript
# Generate aspects for a parcel
AspectManager.generate_aspects_for_parcel(parcel)

# Retrieve all aspect definitions
var all_aspects = AspectManager.get_all_aspect_definitions()

# Get a specific aspect definition by ID
var aspect_def = AspectManager.get_aspect_definition("fertile_soil")
```

### Benefits
- No tight coupling between AspectManager and Library.
- AspectManager can be reused or tested in isolation.
- Follows best practices for Godot autoloads and modular system design.
- Supports dynamic, data-driven world-building.

### Developer Notes
- AspectManager is a key part of the Land System, and its documentation is maintained here for clarity and cohesion.
- All static aspect data should be defined externally and loaded via the injected loader.
- Use error handling and logging to monitor aspect loading and generation.
- The procedural generation logic can be extended to support new types of aspects or more complex rules as the game evolves.

### Associated File
- `globals/aspect_manager.gd` (autoload singleton)

---

## UI Integration

- The main UI injects the land grid into the `LandViewPanel` and updates it on signal.
- All UI updates are data-driven and respond to signals, not direct node calls.
- The UI supports keyboard and controller navigation, with all information selectable and no horizontal scrolling.

---

## Logging and Error Handling

- All key actions (initialisation, surveying, resource updates) are logged using `Logger.log_event()`.
- Errors are never silent; all failures are logged and surfaced for debugging.

---

## Best Practices

- Use signals for all cross-system communication.
- Never hardcode land data in the UI.
- Use unique IDs or coordinates for referencing tiles.
- Disconnect all signals on node removal.
- Keep all static data in external JSON files, loaded via the `Library` autoload.

---

## Usage Example

```gdscript
# In MainUI.gd
var sim_node: Node = get_node("/root/Main/Sim")
if sim_node and sim_node.demesne:
    var demesne = sim_node.demesne
    var land_grid = demesne.land_grid
    var grid_dims = demesne.get_grid_dimensions()
    _view_land.set_land_grid(land_grid, grid_dims.x, grid_dims.y)
# The centre-most parcel (grid_dims.x // 2, grid_dims.y // 2) is always surveyed on initialisation.
```

---

## Extensibility and Future Work

- Add new terrain types, resources, and improvements via config files.
- Support for dynamic grid resizing, mini-map, advanced overlays, and tooltips.
- Integration with weather, disasters, and trade systems.

---

## References

- `scripts/data/data_land_parcel.gd`
- `scripts/core/land_manager.gd`
- `scripts/ui/land_grid/land_grid_view.gd`
- `data/land_config.json`
- `globals/library.gd`
- `globals/event_bus_game.gd`

---

## Last Updated
2024-06-10

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