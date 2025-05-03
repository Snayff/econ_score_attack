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
- `terrain_type`: E.g., "plains", "forest", "mountains"
- `resources`: Dictionary of resources (with amount and discovery status)
- `building_id`: ID of building placed (if any)
- `improvements`: Dictionary of improvements and their levels
- `fertility`: Affects agricultural output
- `pollution_level`: Environmental degradation
- `is_surveyed`: Whether the parcel's resources are known
- `resource_generation_rate`: Base rate for resource production

**Key Methods:**
- `add_resource(resource_id, amount, discovered)`: Add a resource to the parcel
- `get_resource_amount(resource_id)`: Query resource amount
- `discover_resource(resource_id)`: Mark a resource as discovered
- `update_resources(delta)`: Update resource amounts over time

## Land Management
### LandManager
The `LandManager` class manages all land grids for all demesnes (player domains):
- Registers each demesne's land grid
- Provides access to parcels by coordinates
- Responds to data requests (e.g., for UI updates)
- Emits updates via the event bus

**Initialisation:**
- Upon initialisation, the demesne surveys the centre-most parcel (using integer division of grid width/height). This is performed in the demesne logic, ensuring the player always starts with a surveyed tile.

**Example Usage:**
```gdscript
var land_manager = LandManager.new()
land_manager.register_demesne("demesne_1", land_grid)
var parcel = land_manager.get_parcel("demesne_1", 2, 3)
```

## Resource and Environmental Systems
- **Resource Generation:** Each parcel can generate resources based on terrain, improvements, and environmental factors. Resources must be discovered (surveyed) before use.
- **Environmental Effects:** Fertility and pollution affect resource yields and can be modified by player actions or events.
- **Improvements:** Roads, irrigation, and other improvements can be built to enhance productivity or reduce movement costs.

## Event Bus and Signals
Key signals for land system communication include:
- `parcel_selected(x, y)`: Emitted when a parcel is selected in the UI
- `request_parcel_data(x, y)`: Requests data for a specific parcel
- `land_grid_updated(parcel_data)`: Emitted when a parcel's data changes
- Additional signals for resource discovery, improvements, and environmental effects as needed

## Usage Example
1. **Initialisation:** The demesne's land grid is created and registered with the `LandManager`.
2. **Interaction:** The player selects a parcel in the UI. The UI emits a signal to request parcel data.
3. **Update:** The `LandManager` retrieves the parcel and emits an update signal. The UI displays the latest parcel information.
4. **Action:** The player surveys, builds, or improves the parcel via the control panel, triggering further updates.

## Extensibility and Future Work
The land system is designed for extensibility:
- New terrain types, resources, and improvements can be added via configuration files.
- Environmental and pathfinding systems can be integrated for advanced simulation.
- The system supports future features such as weather, disasters, and complex trade routes.

## References
- **Core Scripts:**
  - `scripts/data/data_land_parcel.gd`
  - `scripts/core/land_manager.gd`
  - `scripts/ui/land_grid/land_grid_view.gd`
  - `