# Land System

## Overview
The land system forms the physical and economic foundation of the game world. It defines the spatial structure, resource distribution, and the rules by which land is utilised, developed, and transformed. Land is represented as a grid of parcels, each with unique properties that influence production, population, environment, and player strategy. The management and exploitation of land parcels are central to the closed-loop economy and the player's ability to extract wealth.

## Purpose & Intent
- To provide a tangible, finite resource base for all economic and social activity.
- To create meaningful spatial constraints and opportunities for player decision-making.
- To ensure all goods and services originate from, and are limited by, the land and its properties.
- To facilitate emergent gameplay through the interaction of land with other core systems.

## Parcel Structure
- **Grid System:**
  - The world is divided into a grid of parcels, each representing a discrete unit of land.
  - Grid size and shape may vary by scenario or demesne.
- **Parcel Properties:**
  - **Terrain Type:** (e.g., plains, forest, mountain, water, wetland)
  - **Natural Resources:** (e.g., soil fertility, minerals, timber, water access)
  - **Climate:** (e.g., rainfall, temperature, seasonal variation)
  - **Accessibility:** (e.g., proximity to roads, rivers, settlements)
  - **Ownership:** (player, population, unclaimed, communal)
  - **Development State:** (undeveloped, improved, built-up)
- **Parcel Generation:**
  - Parcels are procedurally generated or scenario-defined at world creation.
  - Resource distribution and terrain are balanced for challenge and replayability.
- **Parcel Referencing:**
  - Each parcel has a unique ID for data management and scripting.

## Separation of World State and Demesne Knowledge
- The world state, including all parcels and their properties, is universal and shared by all demesnes.
- Any change to a parcel (e.g., adding a building, expending an aspect) is a world-level change and is reflected for all demesnes.
- Each demesne (player, AI, etc.) maintains its own record of which parcels have been surveyed. This knowledge is tracked per demesne and is not global.
- The true properties of a parcel are only revealed to a demesne once it has completed a survey on that parcel.
- The UI only displays information for parcels that have been surveyed by the player's demesne. Parcels that have not been surveyed remain hidden or display limited information.

## Surveying & Discovery (Updated)
Surveying is a core mechanic for revealing the true potential of land parcels. By default, the resources and special aspects of a parcel are hidden until it is surveyed. Surveying is managed by a **SurveyManager component attached to each demesne** (not a global autoload). Survey progress and completion are tracked per demesne, and only the demesne that performed the survey gains knowledge of the parcel's true properties. Surveying is turn-based: each survey takes a set number of turns to complete, after which the parcel's hidden properties are revealed to the demesne that performed the survey. This mechanic adds strategic depth, as players must decide which parcels to survey and when, balancing exploration with resource management.

- **SurveyManager:**
  - Handles all surveying operations, progress, and completion **per demesne**.
  - Is fully decoupled from other systems via dependency injection and instance signals.
  - Survey progress is tracked per-parcel and per-demesne, and can be queried or advanced each turn.
  - Survey completion reveals new resources, aspects, or features on the parcel to the surveying demesne only.
  - UI and systems must connect to the current demesne's SurveyManager signals, not to global signals.
  - See technical documentation in `dev/docs/docs/systems/land_system.md` for implementation details.

### Updated Architecture

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

**Key Points:**
- SurveyManager is a per-demesne component, not a global autoload.
- Survey state and progress are tracked per demesne.
- All survey signals are instance signals, not global.
- UI and systems must connect to the current demesne's SurveyManager signals.

## Buildings & Placement
- **Building Placement:**
  - Buildings are placed on individual parcels, consuming space and modifying parcel properties.
  - Some buildings may span multiple parcels (e.g., large farms, factories).
- **Parcel-Building Interactions:**
  - Parcel properties affect building efficiency, output, and available jobs.
  - Certain buildings require specific terrain or resources (e.g., mines on mineral parcels).
  - Buildings may permanently or temporarily alter parcel properties (e.g., deforestation, pollution).
- **Job Creation:**
  - Buildings create jobs, which are filled by the population.
  - The number and type of jobs depend on building type and parcel characteristics.

## Resource Extraction & Regeneration
- **Extraction Mechanics:**
  - Resources are extracted from parcels by buildings and jobs (e.g., farming, mining, logging).
  - Extraction rates depend on parcel quality, technology, and management.
- **Regeneration & Depletion:**
  - Some resources regenerate over time (e.g., forests, soil fertility), while others are finite (e.g., minerals).
  - Over-extraction leads to depletion, reducing long-term productivity and possibly causing environmental crises.
- **Environmental Impact:**
  - Extraction and development can degrade parcel properties (e.g., pollution, erosion).
  - Environmental laws and technologies can mitigate or reverse damage.

## Interactions with Other Systems
- **Population System:**
  - Population settles, works, and migrates based on land availability and quality.
  - Housing and amenities are tied to parcel development.
- **Production System:**
  - All production chains begin with resource extraction from parcels.
  - Parcel properties and improvements affect production efficiency and output.
- **Governance System:**
  - Laws regulate parcel ownership, use, and development (e.g., zoning, conservation).
  - The player can pass or repeal laws to influence parcel use and value.
- **Environmental System:**
  - Parcel use directly impacts environmental health (e.g., biodiversity, pollution).
  - Environmental events (e.g., floods, droughts) affect parcel properties and usability.
- **Technology System:**
  - Technological advances unlock new parcel uses, improve extraction, and enable restoration.
  - Research can reveal hidden resources or improve parcel management.

## Player Actions
- **Acquisition:**
  - Buy, sell, or claim parcels through market, law, or direct action.
- **Surveying:**
  - Initiate surveys on parcels to reveal hidden resources and aspects. Survey progress is managed by the SurveyManager and is completed over several turns.
- **Development:**
  - Build, upgrade, or demolish structures.
  - Improve land (e.g., irrigation, fertilisation, afforestation).
- **Exploitation:**
  - Extract resources, assign jobs, and optimise output.
- **Conservation:**
  - Set aside parcels for environmental or social purposes.
- **Manipulation:**
  - Influence parcel value and use through policy, investment, or market manipulation.

## Data & Technical Schema
- **Data Structure:**
  - Each parcel is represented as a data class (e.g., `DataParcel`) with properties for terrain, resources, ownership, etc.
  - Parcel data is stored externally in JSON files for modifiability and localisation.
- **Unique Identification:**
  - Parcels are referenced by unique IDs for scripting, saving, and cross-system interaction.
- **Example Data Schema:**
  ```json
  {
    "id": "parcel_00123",
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
  - Parcel data is loaded at runtime via the global library autoload and referenced by all relevant systems.

## Examples & Diagrams
- **Example Parcel Layout:**
  - A 10x10 grid with mixed terrain, resources, and development states.
- **Building Placement Example:**
  - A farm placed on a fertile plain parcel increases food output and creates agricultural jobs.
- **Resource Flow Diagram:**
  - [Land Parcel] → [Building] → [Jobs] → [Resource Extraction] → [Production Chain]
- **Interaction Example:**
  - Over-extraction of timber on forest parcels leads to depletion, reducing future output and triggering environmental penalties.

## Future Expansion
- **Land Improvement Mini-games:**
  - Interactive systems for land reclamation, irrigation, or pollution cleanup.
- **Dynamic Land Events:**
  - Random or triggered events affecting parcel properties (e.g., blight, discovery of rare minerals).
- **Advanced Visualisation:**
  - In-game overlays for parcel fertility, resource levels, and environmental health.

---

This section should be updated as the land system is implemented and refined. For questions or contributions, contact the design lead or refer to the technical documentation in `dev/docs/docs/systems/` if available. 


## Last Updated
2025-05-18 