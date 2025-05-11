# Economic Actor Decision-Making System

## Last Updated: 2025-05-11

## Overview
This document describes the system for economic actor decision-making in the simulation. It covers the data-driven, modular approach for representing actors, cultures, and goods, and outlines the loading and validation of external configuration data, as well as the debug UI for inspection.

---

## Phase 1: Foundations & Data Structures

### Data Classes
- **DataActor**: Represents an economic actor (person), including id, culture, ancestry, needs, savings rate, disposable income, and decision profile.
- **DataCulture**: Represents a culture, including base preferences, savings rate, and shock response.
- **DataGood**: Represents a static configuration for a good, including id, f_name, base price, and category.

### JSON Configs
- All static data is defined in external JSON files:
  - `feature/economic_actor/data/cultures.json`
  - `feature/economic_actor/data/ancestries.json`
  - `feature/economy/market/data/goods.json`

### Data Loading & Validation
- Data classes provide static loader functions to load and validate data from JSON using `global/library.gd`.
- Errors in loading or validation are logged and surfaced to the developer.

### Unit Tests
- Each data class has unit tests for construction, JSON parsing, and error handling, located in the relevant feature's `test/unit/` folder.

### Debug UI
- A minimal debug UI (`feature/economic_actor/ui/actor_data_inspector.tscn` and `.gd`) lists loaded actors and cultures for developer inspection.
- All referenced nodes are asserted in `_ready()`.

---

## How to Use
- Add or update data in the relevant JSON files.
- Use the debug UI to inspect loaded data and verify correct parsing and validation.
- Run unit tests to ensure data classes and loading logic are functioning as expected.

---

## Future Phases
- See `dev/docs/designs/economic_actor_decision_system_phased_implementation.md` for the full phased plan, including utility functions, decision logic, event triggers, and visualisation tools.

## Additional Details
- **Budget Constraint:** Actors can only purchase goods/services they can afford.
- **Savings Propensity:** Each actor has a "savings rate" (possibly influenced by culture, age, or recent events) that determines what portion of their income is reserved and not spent immediately.
- **Disposable Income:** Only income not allocated to savings is available for purchases. Disposable income is calculated as total_money * (1 - savings_rate) and is updated whenever an actor's money changes.
- **Optional Credit:** (Future extension) Some actors may take loans, introducing debt and risk.

## Debugging & Visualisation
- **Decision Logging:** Each actor logs their decision process (needs, evaluated goods, chosen purchases, savings, disposable income) for developer review.
- **Visualisation Tools:**
  - **Market Heatmap:** Shows demand and supply for goods across the demesne.
  - **Actor Inspector:** UI panel to select an actor and view their needs, preferences, current utility calculations, savings rate, disposable income, and recent decisions.
  - **Event Timeline:** Visualises economic shocks and their impact on actor behaviour.
- **Debug Overlays:** In-game overlays to highlight actors making decisions, their current state, and market activity.
- **Toggleable Tools:** All debugging and visualisation tools are toggleable and only active in development builds. 