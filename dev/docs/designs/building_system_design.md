# Building System Design Proposal

## Overview
The building system introduces the concept of buildings as core economic actors in the simulation. Buildings can produce and consume goods, provide jobs, and are subject to construction requirements. This system is designed to be modular, data-driven, and extensible, supporting future features such as upgrades and decay.

---

## 1. Core Design Principles
- **Component-based**: Buildings, jobs, and production logic are modular and follow the component pattern.
- **Data-driven**: All static data (building types, job types, requirements, etc.) is defined in external JSON files.
- **Separation of concerns**: UI, simulation logic, and data models are decoupled, using signals for communication.
- **Scalability**: Designed for future expansion (e.g., upgrades, actor-owned buildings).
- **Event logging**: All major building events are logged for debugging and analytics.

---

## 2. Feature Breakdown

### A. Data Model
- **DataBuilding**: Represents a building instance, with unique ID, type, owner, tile, jobs, stockpile, production state, and upgrade level.
- **Static Building Type Data**: Defines consumed/produced goods, job types, build cost, build requirements, base productivity, and upgrade paths.
- **DataJob**: Represents a job slot in a building, with job type, occupant, productivity weight, and happiness modifier.

### B. Building Construction Logic
- **Resource Cost**: Paid from the demesne's stockpile at build time.
- **Tile Requirements**: Tile must have required resource(s) (e.g., forest, river).
- **Construction Flow**:
    1. Player selects tile and building type via Land View UI.
    2. System checks demesne resources and tile requirements.
    3. If valid, resources are deducted and the building is instantiated.
    4. If invalid, construction fails with a logged reason.

### C. Production Logic (End of Turn)
- For each building:
    - Check if all required input goods are present in the building's stockpile.
    - Calculate productivity based on job fill, weights, and worker happiness.
    - If requirements are met, consume goods and produce output, scaled by productivity.
    - Log production success or failure.

### D. Job Assignment
- Jobs are slots within buildings, each with a productivity weight.
- Actors can be assigned to jobs, affecting productivity and happiness.

### E. Event Logging
- Construction, production, job assignment, and upgrades are all logged.

### F. UI Integration
- Land View UI for building selection, placement, and requirements display.
- Building Info Panel for stockpile, jobs, production status, and event log.

---

## 3. Additional Core Functionality
- **Building Upgrades**: Noted for future implementation.
- **Extensible Requirements**: Designed for future requirements (e.g., adjacency, population).

---

## 4. Challenges & Solutions

### A. Refactoring Production from Jobs to Buildings
- **Solution**: Move production logic to buildings. Jobs become productivity modifiers. Update all references and ensure backwards compatibility during transition.

### B. Productivity Calculation
- **Solution**: Use a clear, tunable formula:
  
  `Productivity = Base Productivity × (Σ(Job Weight × Happiness Modifier) / Total Job Weights)`
  
  Expose all parameters in JSON for easy balancing.

### C. Data Synchronisation
- **Solution**: Use signals for job assignment changes. Assert and log on inconsistencies. Centralise job assignment logic.

### D. UI Complexity
- **Solution**: Modular UI panels, context-sensitive info, progressive disclosure. Use signals for UI updates.

### E. Performance
- **Solution**: Batch process buildings at end of turn. Only update active/visible buildings in UI. Profile regularly.

### F. Ownership & Permissions
- **Solution**: Abstract ownership logic in data model. Use composition for owner behaviour.

### G. Building Requirements
- **Solution**: Validate requirements before construction. Use a requirements-checking function that is data-driven and extensible.

### H. Event Logging
- **Solution**: Use a centralised logger. Log only significant events, with clear categories and details.

---

## 5. Next Steps
1. Confirm data model and JSON schema.
2. Refactor production logic.
3. Implement construction logic.
4. Integrate with simulation.
5. UI integration.
6. Test and balance.
7. Document in `dev/docs/docs/systems/buildings.md`.

---

## 6. Future Considerations
- Building upgrades and decay.
- Event logging for analytics.
- Extensible requirements for new gameplay features. 