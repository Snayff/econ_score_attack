# System Interactions Overview

## Last Updated
2025-06-23

## Purpose

This document provides a comprehensive overview of how the game's core systems interact with each other. Rather than describing individual systems in detail (which is covered in their respective documentation), this document focuses on:

1. The connections and interfaces between systems
2. Communication patterns and data flow across system boundaries
3. Key integration points and dependencies
4. Common cross-system workflows

Use this document as a map to understand how systems work together to create the game's emergent gameplay.

---

## System Interaction Map

The following diagram shows the primary connections between the game's core systems:

```
                    +----------------+
                    |                |
                    |    Library     |
                    |   (Data Hub)   |
                    |                |
                    +-------+--------+
                            |
                            | (provides data)
                            v
+----------------+   +------+-------+   +----------------+
|                |   |              |   |                |
|  Governance    +<->+   Economic   +<->+  Population    |
|    System      |   |    System    |   |    System      |
|                |   |              |   |                |
+--------+-------+   +------+-------+   +--------+-------+
         ^                  ^                    ^
         |                  |                    |
         v                  v                    v
+--------+-------+   +------+-------+   +--------+-------+
|                |   |              |   |                |
|  Environmental +<->+  Production  +<->+  Technology    |
|    System      |   |    System    |   |    System      |
|                |   |              |   |                |
+--------+-------+   +------+-------+   +----------------+
         ^                  ^
         |                  |
         v                  v
+--------+-------+   +------+-------+
|                |   |              |
|  Land System   +<->+  Building    |
|                |   |   System     |
|                |   |              |
+----------------+   +--------------+
```

### Communication Channels

Systems communicate with each other through three primary channels:

1. **Event Bus Signals**: Decoupled communication via `EventBusGame` and `EventBusUI`
2. **Direct API Calls**: Direct method calls between systems that have references to each other
3. **Shared Data Objects**: Systems operating on the same data objects (e.g., `DataLandParcel`)

---

## Communication Patterns

### Event-Driven Communication

The primary pattern for cross-system communication is event-driven messaging through the `EventBusGame` and `EventBusUI` autoloads. This approach decouples systems and allows them to interact without direct references.

```
+----------------+                    +----------------+
|                |                    |                |
|  System A      |                    |  System B      |
|                |                    |                |
+-------+--------+                    +-------+--------+
        |                                     |
        | emit_signal("event_name", data)     | connect("event_name", callback)
        v                                     v
+-------+-------------------------------------+--------+
|                                                      |
|                    EventBusGame                      |
|                                                      |
+------------------------------------------------------+
```

**Key Event Bus Signals**:

| Signal | Emitter | Listeners | Purpose |
|--------|---------|-----------|---------|
| `turn_complete` | Sim | Multiple | Notifies all systems that a turn has completed |
| `land_grid_updated` | LandManager | UI, Economic | Notifies when a land parcel has been updated |
| `market_price_changed` | Market | Economic, UI | Notifies when a good's price changes |
| `law_enacted` | Governance | Multiple | Notifies when a new law is enacted |
| `survey_completed` | SurveyManager | Land, UI | Notifies when a survey is completed |

### Dependency Injection

For components that need to interact with multiple systems, dependency injection is used to maintain decoupling. For example, the `SurveyManager` uses a dependency-injected callable for parcel access:

```
+-------------------+
|   Demesne         |
+-------------------+
        |
        | set_parcel_accessor(self.get_parcel)
        v
+-------------------+
|   SurveyManager   |
+-------------------+
        |
        | parcel_accessor(x, y)
        v
+-------------------+
|   DataLandParcel  |
+-------------------+
```

### Direct API Calls

Some systems have direct references to others when there's a clear ownership or dependency relationship. These are used sparingly to maintain modularity:

```
+----------------+                    +----------------+
|                |  get_market_price  |                |
|  Economic      +-------------------->  Market        |
|  System        |                    |  System        |
|                <--------------------+                |
+----------------+  price_data        +----------------+
```

---

## Key Integration Points

### Economic System ↔ Market System

**Interface Points**:
- Market provides price information to Economic Actors
- Economic Actors' purchase decisions affect Market supply/demand
- Market price changes trigger Economic Actor recalculations

**Key Data Objects**:
- `DataGood` - Shared between systems
- Price information - Passed from Market to Economic
- Purchase decisions - Passed from Economic to Market

**Events**:
- `market_price_changed` - Market → Economic
- `good_purchased` - Economic → Market
- `good_produced` - Production → Market

### Land System ↔ Production System

**Interface Points**:
- Land parcels provide resources for Production
- Production activities affect Land parcel properties
- Building placement on Land creates Production opportunities

**Key Data Objects**:
- `DataLandParcel` - Owned by Land, referenced by Production
- `DataResource` - Shared between systems
- `DataBuilding` - Links Land parcels to Production facilities

**Events**:
- `resource_extracted` - Production → Land
- `land_improved` - Land → Production
- `building_constructed` - Building → Land, Production

### Population System ↔ Governance System

**Interface Points**:
- Laws affect Population behavior and happiness
- Population unrest influences Governance options
- Tax collection flows from Population to Governance

**Key Data Objects**:
- `DataLaw` - Created by Governance, affects Population
- `DataPerson` - Owned by Population, affected by Governance
- Happiness and unrest metrics - Flow from Population to Governance

**Events**:
- `law_enacted` - Governance → Population
- `unrest_level_changed` - Population → Governance
- `tax_collected` - Governance → Population, Economic

---

## Data Flow Across Systems

### Resource Production Flow

```
+----------------+     +----------------+     +----------------+
|                |     |                |     |                |
|  Land System   |---->|  Production    |---->|  Market        |
|                |     |  System        |     |  System        |
|                |     |                |     |                |
+----------------+     +----------------+     +----------------+
      |                       |                      |
      v                       v                      v
+----------------+     +----------------+     +----------------+
| DataLandParcel |     | DataResource   |     | DataGood       |
| - resources    |---->| - amount       |---->| - price        |
| - fertility    |     | - quality      |     | - availability |
+----------------+     +----------------+     +----------------+
```

1. Land System provides resources from parcels
2. Production System transforms resources into goods
3. Market System receives goods and determines prices
4. Economic Actors purchase goods based on prices and needs

### Law Enactment Flow

```
+----------------+     +----------------+     +----------------+
|                |     |                |     |                |
|  Governance    |---->|  Multiple      |---->|  UI System     |
|  System        |     |  Systems       |     |                |
|                |     |                |     |                |
+----------------+     +----------------+     +----------------+
      |                       |                      |
      v                       v                      v
+----------------+     +----------------+     +----------------+
| DataLaw        |     | System-specific|     | UI Updates     |
| - effects      |---->| changes        |---->| - notifications|
| - requirements |     | - modifiers    |     | - visual cues  |
+----------------+     +----------------+     +----------------+
```

1. Governance System creates and enacts a law
2. EventBusGame broadcasts `law_enacted` signal
3. Multiple systems receive the signal and apply effects
4. UI System updates to reflect changes

### Population Decision Flow

```
+----------------+     +----------------+     +----------------+
|                |     |                |     |                |
|  Population    |---->|  Economic      |---->|  Production    |
|  System        |     |  System        |     |  System        |
|                |     |                |     |                |
+----------------+     +----------------+     +----------------+
      |                       |                      |
      v                       v                      v
+----------------+     +----------------+     +----------------+
| DataPerson     |     | Purchase       |     | Job Assignment |
| - needs        |---->| Decisions      |---->| - productivity |
| - preferences  |     | - consumption  |     | - output       |
+----------------+     +----------------+     +----------------+
```

1. Population System determines person's needs and preferences
2. Economic System processes purchase decisions
3. Production System assigns jobs based on skills and needs
4. Market System adjusts prices based on supply and demand

---

## System Update Sequence

The game operates on a turn-based system, with each turn triggering updates across all systems in a specific sequence:

```
1. Sim.advance_turn()
   |
2. EventBusGame.emit_signal("turn_started")
   |
3. World.update()  // Updates land parcels and resources
   |
4. Production.update()  // Processes resource extraction and goods production
   |
5. Market.update()  // Updates prices based on supply and demand
   |
6. Population.update()  // Updates person needs, decisions, and happiness
   |
7. Governance.update()  // Processes laws and policies
   |
8. EventBusGame.emit_signal("turn_completed")
   |
9. UI updates based on new state
```

**Critical Dependencies**:
- Production depends on World (land resources)
- Market depends on Production (goods supply)
- Population depends on Market (goods availability and prices)
- All systems depend on Library for data access

---

## Common Cross-System Workflows

### Survey and Resource Extraction

```
1. Player initiates survey on a parcel
   |
2. Demesne.survey_manager.start_survey(x, y)
   |
3. SurveyManager tracks progress over multiple turns
   |
4. On completion: SurveyManager.emit_signal("survey_completed", x, y)
   |
5. Land System marks parcel as surveyed for this demesne
   |
6. UI updates to show discovered resources
   |
7. Player can now build resource extraction buildings
   |
8. Building System places building on parcel
   |
9. Production System begins resource extraction
   |
10. Market System receives new resources
```

### Law Enactment and Economic Impact

```
1. Player creates and enacts a new tax law
   |
2. Governance.enact_law(law_data)
   |
3. EventBusGame.emit_signal("law_enacted", law_data)
   |
4. Economic System applies tax effects to transactions
   |
5. Population System updates happiness based on tax burden
   |
6. Market System adjusts for changed economic conditions
   |
7. Production System may change output based on new incentives
   |
8. UI updates to show economic indicators and population response
```

### Building Construction and Job Creation

```
1. Player initiates building construction
   |
2. Building System creates building on land parcel
   |
3. EventBusGame.emit_signal("building_constructed", building_data)
   |
4. Land System updates parcel to reference new building
   |
5. Production System creates jobs associated with building
   |
6. Population System assigns people to new jobs
   |
7. Economic System updates income and spending patterns
   |
8. UI updates to show new building and economic changes
```

---

## Cross-System Debugging

When debugging issues that span multiple systems, focus on these key integration points:

1. **Event Bus Signals**: Check if signals are being emitted and received correctly
   - Use `Logger.debug("Signal emitted: " + signal_name, "EventBusGame")`
   - Verify signal connections in `_ready()` functions

2. **Data Consistency**: Ensure shared data objects maintain consistency
   - Check if IDs match across systems
   - Verify that references point to valid objects

3. **Update Sequence**: Confirm systems are updating in the correct order
   - Use logging to trace the update sequence
   - Check for race conditions or dependency issues

4. **Common Integration Issues**:
   - Market prices not updating after production changes
   - Population not responding to new laws
   - Resources not appearing after surveys
   - Buildings not creating expected jobs

---

## Missing System Documentation

The following core systems currently lack dedicated documentation and should be prioritized for documentation:

1. **Building System**: How buildings are created, placed, and interact with land and production
2. **Job System**: How jobs are created, assigned, and affect production and population
3. **Law System**: How laws are created, enacted, and affect other systems

---

## References

For detailed information on individual systems, refer to:

- [Constants System](constants.md)
- [Economic Actor Decision System](economic_actor_decision_system.md)
- [Event Buses](event_buses.md)
- [ID Generator](id_generator.md)
- [Land System](land_system.md)
- [Library](library.md)
- [Logger](logger.md)
- [Market System](market_system.md)
- [Tester](tester.md)
- [UI Layout](ui_layout.md)
- [World](world.md)

For guidance on maintaining system documentation, refer to:

- [System Documentation Guide](systems_documentation_guide.md)
