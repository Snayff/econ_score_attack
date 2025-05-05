# World System Documentation

## Purpose and Intent

The `World` system is a global autoload singleton responsible for managing the main world grid, including all parcels (tiles), their terrain, and resource data. It provides centralised access to the grid, supports parcel queries, and coordinates the initialisation and updating of the world state. The World system is foundational to the simulation, ensuring that all spatial and resource-based logic is consistent and accessible across the game.

## Design

- **Central Grid Management:** The World holds the authoritative 2D array of land parcels, each represented by a `DataLandParcel` data class.
- **Parcel Access:** Provides methods to query parcels by coordinates and to retrieve grid dimensions.
- **Initialisation:** Loads and initialises the grid from configuration data (typically via the Library autoload), supporting dynamic grid sizing and terrain setup.
- **Survey Coordination:** Tracks surveys in progress and manages survey completion, emitting signals for UI and system updates.
- **Signal-Based Updates:** Emits signals when the grid is updated, ensuring all dependent systems and UI components can react to changes.
- **Error Handling:** Logs and signals errors for out-of-bounds access or failed operations, supporting robust debugging and monitoring.

## Architecture

The World system acts as the central manager for the game grid, coordinating with other systems such as the Library (for config), Logger (for event logging), and EventBusGame (for signalling updates). All parcel and grid queries should go through the World autoload.

```
+-------------------+
|   land.json       |
+-------------------+
        |
        |  (loads config)
        v
+-------------------+
|     Library       |
+-------------------+
        |
        |  (provides config)
        v
+-------------------+
|      World        |
|   (autoload)      |
+-------------------+
        |
        |  (signals, queries)
        v
+-------------------+     +-------------------+
|   LandManager     |     |   UI Systems      |
+-------------------+     +-------------------+
        |
        v
+-------------------+
| DataLandParcel(s) |
+-------------------+
```

The diagram above shows how the World system loads its configuration via the Library, manages the grid, and provides access and updates to other systems and the UI.

## Usage

- Access the World via the autoload singleton `World`.
- Query parcels:
  - `World.get_parcel(x: int, y: int) -> DataLandParcel`
- Get grid dimensions:
  - `World.get_grid_dimensions() -> Vector2i`
- Initialise the grid:
  - `World.initialise_from_config(config: Dictionary) -> void`
- Listen for signals:
  - `world_grid_updated()` — Emitted when the grid is updated.

Example:
```gdscript
var grid_size = World.get_grid_dimensions()
var parcel = World.get_parcel(2, 3)
```

## Data Schema

- **Grid:**
  - 2D array of `DataLandParcel` objects, indexed by [x][y].
- **Grid Dimensions:**
  - `grid_width: int`, `grid_height: int`
- **Surveys in Progress:**
  - Dictionary mapping `Vector2i` coordinates to survey state.

## Extending the System

- To support new parcel types or grid features, update the initialisation logic and data schema in `world.gd`.
- Integrate with new systems by connecting to the `world_grid_updated` signal or by querying parcels as needed.
- For new resource or terrain types, ensure the configuration is updated in the relevant JSON files and loaded via the Library.

## Developer Notes

- All parcel and grid access should go through the World autoload to ensure consistency.
- The World system is designed to be stateless beyond its grid and survey tracking; it does not persist data between sessions.
- Errors and important events are logged using the Logger system.
- The World system is extensible and can be adapted for future features such as dynamic world resizing, advanced terrain, or multi-world support.

## Associated File
- `global/world.gd` (autoload singleton)

## Last Updated
2025-05-04 