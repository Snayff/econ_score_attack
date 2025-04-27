# Land System

## Overview
The Land System manages the demesne's land grid, including all parcels (tiles), their state, and their integration with the UI. It ensures that all land data is data-driven, modular, and updated in real time in response to game events.

---

## Data Flow
- The land grid is a 2D array of `DataLandParcel` objects, owned by the demesne (see `Sim` node).
- The grid is initialised using configuration from `land_config.json` via the `Library` autoload.
- The demesne exposes the grid and its dimensions via `land_grid` and `get_grid_dimensions()`.

---

## Signals
- `EventBusGame.land_grid_updated()`: Emitted whenever the land grid changes (e.g., after surveying, building, or resource updates). All UI components listen for this signal to refresh their data.
- `WorldViewPanel.tile_selected(tile_id: int, tile_data: DataLandParcel)`: Emitted when a tile is selected in the UI grid.

---

## UI Integration
- The main UI (`MainUI`) injects the real land grid into the `LandViewPanel` (node: `ViewLand`) on ready and whenever the grid is updated.
- `LandViewPanel` passes the grid to `WorldViewPanel`, which displays the 5x5 viewport and handles scrolling and selection.
- `TileInfoPanel` displays information for the selected tile, updating in response to selection and grid changes.
- All UI updates are data-driven and respond to signals, not direct node calls.

---

## Example Usage
```gdscript
# In MainUI.gd
var sim_node = get_node("/root/Main/Sim")
if sim_node and sim_node.demesne:
    var demesne = sim_node.demesne
    var land_grid = demesne.land_grid
    var grid_dims = demesne.get_grid_dimensions()
    _view_land.set_land_grid(land_grid, grid_dims.x, grid_dims.y)
```

---

## Best Practices
- Always use signals for communication between unrelated systems.
- Never hardcode land data in the UI; always inject from the demesne.
- Ensure all UI components disconnect from signals on removal.
- Use unique IDs or coordinates for referencing tiles, never names.

---

## Future Enhancements
- Support for dynamic grid resizing.
- Mini-map and advanced scrolling/zooming.
- More detailed tile overlays and tooltips.

---

## Last Updated
2024-06-09

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
  - `scripts/ui/land_grid/land_parcel_view.gd`
  - `scripts/ui/land_grid/land_control_panel.gd`
- **Scenes:**
  - `scenes/ui/land_grid/land_grid_view.tscn`
  - `scenes/ui/land_grid/land_parcel_view.tscn`
  - `scenes/ui/land_grid/land_control_panel.tscn`
- **Configuration:**
  - `data/land_config.json` (terrain, improvements, resource modifiers)
- **Design Archives:**
  - `dev/docs/designs/_archive/land_system_design.md`
  - `dev/docs/designs/_archive/land_system_implementation_phases.md`

For further details, consult the referenced scripts and archived design documents. 