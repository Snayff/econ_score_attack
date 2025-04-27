# Land System

## Overview
The land system provides the spatial foundation for the game's economic simulation. It models the world as a grid of land parcels (tiles), each with unique properties, resources, and environmental factors. This system is central to the closed-loop economy, as all production, consumption, and player actions are grounded in physical space.

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

## UI Integration
- **LandGridView:** Displays the entire grid, handles user selection, and updates parcel views.
- **LandParcelView:** Visualises a single parcel, showing terrain, resources, improvements, and selection state.
- **LandControlPanel:** Provides controls for surveying, building, and improving parcels, and displays detailed parcel information.

UI components communicate with the core land system via signals and the event bus, ensuring decoupled, modular design.

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