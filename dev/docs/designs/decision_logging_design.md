# Decision Logging & Developer Insight System

## Last Updated: 2025-05-10

---

## Overview
This document outlines the design for a robust, modular, and developer-friendly decision logging system for the simulation. The system is intended to provide deep insight into the decisions made by simulated people, including the reasoning and context behind each decision. This is essential for debugging, balancing, and understanding emergent behaviour in the game.

---

## Intent
- **Transparency:** Make all decision-making processes visible and traceable for developers (and optionally advanced players).
- **Debuggability:** Allow for rapid identification and resolution of unexpected or undesired behaviour.
- **Balance & Tuning:** Provide the data needed to adjust utility functions, costs, and preferences.
- **Modularity:** Ensure the system is decoupled, testable, and extensible.

---

## Key Principles
- **Component Pattern:** Decision logging is implemented as a component, attached to each decision-making entity.
- **Signals & Event Bus:** All cross-feature communication uses signals defined in `global/event_bus_game.gd`.
- **Data Classes:** All log entries use a `DataDecisionLogEntry` data class for structure and type safety.
- **Externalised Text:** All reason strings and explanations are externalised for localisation.
- **UI Decoupling:** Debug UI listens to signals, not directly to logic or data classes.
- **Configurable Logging:** Logging can be toggled via config or debug flag.
- **Structured Logging:** Log entries are written in JSON format for easy parsing and analysis.
- **Unique IDs:** All references use unique IDs, never names.
- **Testing:** Unit and integration tests are required at each stage.

---

## System Architecture

### 1. Data Class: `DataDecisionLogEntry.gd`
- Holds all relevant information for a decision log entry.
- Used for both logging and UI display.

### 2. Signal: `person_decision_made`
- Defined in `global/event_bus_game.gd`.
- Arguments: `person_id`, `decision_type`, `options`, `utilities`, `chosen_option`, `reason_key`, `context_data`.

### 3. Component: `DecisionLoggerComponent.gd`
- Attached to each decision-making entity.
- Emits the signal and optionally writes to log if enabled.

### 4. Debug UI: `pnl_decision_log.tscn`
- Listens to the event bus.
- Displays recent decisions, filterable by person, type, etc.

### 5. Logging
- Structured, JSON format.
- Configurable via debug flag.
- Errors are asserted and reported.

### 6. Documentation
- System doc in `dev/docs/docs/systems/decision_logging.md`.
- API doc for data class and public functions.

### 7. Testing
- Unit tests for the logger component in the relevant feature's `test/unit/` folder.
- Integration tests in `shared/test/integration/`.

---

## Existing Files Related to This Proposal
- `global/event_bus_game.gd` (signals)
- `global/library.gd` (data loading, externalisation)
- `global/constants.gd` (constants/enums)
- `feature/economic_actor/` (likely location for person logic and components)
- `shared/test/integration/` (integration tests)
- `dev/logs/` (log output location)

---

## Future Considerations
- Potential for player-facing decision logs or explanations.
- Expansion to other decision-making entities (e.g., businesses, AI agents).
- Advanced filtering and visualisation in the debug UI.

---

## Example Log Entry (JSON)
```json
{
  "person_id": 42,
  "decision_type": "job_selection",
  "options": ["Farm", "Mine", "Shop"],
  "utilities": {"Farm": 12.5, "Mine": 8.0, "Shop": 10.0},
  "chosen_option": "Farm",
  "reason_key": "reason_highest_utility",
  "context_data": {"hunger": 0.8, "wealth": 5.0}
}
``` 