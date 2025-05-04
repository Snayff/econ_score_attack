# Land System

## Overview
The land system forms the physical and economic foundation of the game world. It defines the spatial structure, resource distribution, and the rules by which land is utilised, developed, and transformed. Land is represented as a grid of tiles, each with unique properties that influence production, population, environment, and player strategy. The management and exploitation of land are central to the closed-loop economy and the player's ability to extract wealth.

## Purpose & Intent
- To provide a tangible, finite resource base for all economic and social activity.
- To create meaningful spatial constraints and opportunities for player decision-making.
- To ensure all goods and services originate from, and are limited by, the land and its properties.
- To facilitate emergent gameplay through the interaction of land with other core systems.

## Tile Structure
- **Grid System:**
  - The world is divided into a grid of tiles, each representing a discrete unit of land.
  - Grid size and shape may vary by scenario or demesne.
- **Tile Properties:**
  - **Terrain Type:** (e.g., plains, forest, mountain, water, wetland)
  - **Natural Resources:** (e.g., soil fertility, minerals, timber, water access)
  - **Climate:** (e.g., rainfall, temperature, seasonal variation)
  - **Accessibility:** (e.g., proximity to roads, rivers, settlements)
  - **Ownership:** (player, population, unclaimed, communal)
  - **Development State:** (undeveloped, improved, built-up)
- **Tile Generation:**
  - Tiles are procedurally generated or scenario-defined at world creation.
  - Resource distribution and terrain are balanced for challenge and replayability.
- **Tile Referencing:**
  - Each tile has a unique ID for data management and scripting.

## Buildings & Placement
- **Building Placement:**
  - Buildings are placed on individual tiles, consuming space and modifying tile properties.
  - Some buildings may span multiple tiles (e.g., large farms, factories).
- **Tile-Building Interactions:**
  - Tile properties affect building efficiency, output, and available jobs.
  - Certain buildings require specific terrain or resources (e.g., mines on mineral tiles).
  - Buildings may permanently or temporarily alter tile properties (e.g., deforestation, pollution).
- **Job Creation:**
  - Buildings create jobs, which are filled by the population.
  - The number and type of jobs depend on building type and tile characteristics.

## Resource Extraction & Regeneration
- **Extraction Mechanics:**
  - Resources are extracted from tiles by buildings and jobs (e.g., farming, mining, logging).
  - Extraction rates depend on tile quality, technology, and management.
- **Regeneration & Depletion:**
  - Some resources regenerate over time (e.g., forests, soil fertility), while others are finite (e.g., minerals).
  - Over-extraction leads to depletion, reducing long-term productivity and possibly causing environmental crises.
- **Environmental Impact:**
  - Extraction and development can degrade tile properties (e.g., pollution, erosion).
  - Environmental laws and technologies can mitigate or reverse damage.

## Interactions with Other Systems
- **Population System:**
  - Population settles, works, and migrates based on land availability and quality.
  - Housing and amenities are tied to tile development.
- **Production System:**
  - All production chains begin with resource extraction from land.
  - Tile properties and improvements affect production efficiency and output.
- **Governance System:**
  - Laws regulate land ownership, use, and development (e.g., zoning, conservation).
  - The player can pass or repeal laws to influence land use and value.
- **Environmental System:**
  - Land use directly impacts environmental health (e.g., biodiversity, pollution).
  - Environmental events (e.g., floods, droughts) affect tile properties and usability.
- **Technology System:**
  - Technological advances unlock new land uses, improve extraction, and enable restoration.
  - Research can reveal hidden resources or improve land management.

## Player Actions
- **Acquisition:**
  - Buy, sell, or claim tiles through market, law, or direct action.
- **Development:**
  - Build, upgrade, or demolish structures.
  - Improve land (e.g., irrigation, fertilisation, afforestation).
- **Exploitation:**
  - Extract resources, assign jobs, and optimise output.
- **Conservation:**
  - Set aside land for environmental or social purposes.
- **Manipulation:**
  - Influence land value and use through policy, investment, or market manipulation.

## Data & Technical Schema
- **Data Structure:**
  - Each tile is represented as a data class (e.g., `DataTile`) with properties for terrain, resources, ownership, etc.
  - Tile data is stored externally in JSON files for modifiability and localisation.
- **Unique Identification:**
  - Tiles are referenced by unique IDs for scripting, saving, and cross-system interaction.
- **Example Data Schema:**
  ```json
  {
    "id": "tile_00123",
    "terrain_type": "forest",
    "resources": {"timber": 120, "wildlife": 30},
    "fertility": 0.7,
    "climate": {"rainfall": 800, "temperature": 16},
    "ownership": "player",
    "development_state": "improved",
    "buildings": ["farmhouse_001", "sawmill_002"]
  }
  ```
- **Integration:**
  - Tile data is loaded at runtime via the global library autoload and referenced by all relevant systems.

## Examples & Diagrams
- **Example Tile Layout:**
  - A 10x10 grid with mixed terrain, resources, and development states.
- **Building Placement Example:**
  - A farm placed on a fertile plain tile increases food output and creates agricultural jobs.
- **Resource Flow Diagram:**
  - [Land Tile] → [Building] → [Jobs] → [Resource Extraction] → [Production Chain]
- **Interaction Example:**
  - Over-extraction of timber on forest tiles leads to depletion, reducing future output and triggering environmental penalties.

## Future Expansion
- **Land Improvement Mini-games:**
  - Interactive systems for land reclamation, irrigation, or pollution cleanup.
- **Dynamic Land Events:**
  - Random or triggered events affecting tile properties (e.g., blight, discovery of rare minerals).
- **Advanced Visualisation:**
  - In-game overlays for tile fertility, resource levels, and environmental health.

---

This section should be updated as the land system is implemented and refined. For questions or contributions, contact the design lead or refer to the technical documentation in `dev/docs/docs/systems/` if available. 


## Last Updated
2025-05-04 