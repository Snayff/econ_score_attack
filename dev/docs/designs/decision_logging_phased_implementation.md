# Phased Implementation Plan: Decision Logging & Developer Insight System

## Last Updated: 2025-05-10

---

## Overview
This document outlines a phased, test-driven approach for implementing the decision logging and developer insight system. The plan is designed for incremental delivery, ensuring early visibility of decisions (including via UI), robust testing, and no regressions between phases. Each phase includes a detailed checklist for success.

---

## Existing Files Related to This Proposal
- `global/event_bus_game.gd` (signals)
- `global/library.gd` (data loading, externalisation)
- `global/constants.gd` (constants/enums)
- `feature/economic_actor/` (person logic, components)
- `shared/test/integration/` (integration tests)
- `dev/logs/` (log output location)

---

## Phase 1: Signal Emission for Decisions
**Goal:** Ensure all decision-making entities emit a structured signal when a decision is made.

### Tasks
- Define `person_decision_made` signal in `global/event_bus_game.gd` with full documentation.
- Update decision-making logic (e.g., in `feature/economic_actor/`) to emit this signal with all required arguments.
- Create a minimal `DataDecisionLogEntry` data class for structured data.
- Add unit tests to verify signal emission and data structure.
- Add integration tests to ensure signals are received by listeners.

### Checklist
- [ ] Signal defined and documented in `event_bus_game.gd`.
- [ ] All decision points emit the signal with correct data.
- [ ] Data class created and used.
- [ ] Unit tests for signal emission and data class.
- [ ] Integration tests for signal propagation.
- [ ] No regressions in existing decision logic.

---

## Phase 2: Basic Logging to File
**Goal:** Log all decision events to a structured file for developer review.

### Tasks
- Implement a logging component (e.g., `DecisionLoggerComponent.gd`) that listens to the signal and writes entries to a JSON file in `dev/logs/`.
- Ensure logging is configurable (on/off via debug flag or config).
- Add error handling and assertions for logging failures.
- Extend unit and integration tests to cover logging.

### Checklist
- [ ] Logging component implemented and attached.
- [ ] Log file created in correct location, with structured entries.
- [ ] Logging is configurable.
- [ ] Error handling and assertions in place.
- [ ] Unit and integration tests for logging.
- [ ] No regressions in signal emission or data structure.

---

## Phase 3: Minimal Debug UI for Decisions
**Goal:** Provide an in-game debug UI panel to view recent decisions as they occur.

### Tasks
- Create a new UI scene (e.g., `pnl_decision_log.tscn`) using Godot Control nodes, following naming conventions.
- UI listens to the `person_decision_made` signal via event bus.
- Display a list of recent decisions, with basic filtering (e.g., by person or type).
- Add toggle to enable/disable the panel in debug mode.
- Add unit tests for UI logic and integration tests for end-to-end flow.

### Checklist
- [ ] UI scene created and follows naming conventions.
- [ ] UI listens to event bus, not directly to logic.
- [ ] Recent decisions are displayed and filterable.
- [ ] Debug toggle implemented.
- [ ] Unit and integration tests for UI.
- [ ] No regressions in logging or signal emission.

---

## Phase 4: Externalisation & Localisation of Reason Strings
**Goal:** Ensure all explanation/reason text is externalised for localisation.

### Tasks
- Move all reason/explanation strings to external JSON files, loaded via `global/library.gd`.
- Update data class and UI to use reason keys, not raw strings.
- Add tests to verify correct loading and display of localised text.

### Checklist
- [ ] All reason strings externalised.
- [ ] Data class and UI use reason keys.
- [ ] Tests for localisation and fallback behaviour.
- [ ] No regressions in UI, logging, or signal emission.

---

## Phase 5: Advanced Features & Visualisation
**Goal:** Add advanced filtering, search, and visualisation to the debug UI.

### Tasks
- Implement advanced filters (by time, context, utility value, etc.).
- Add visualisation (e.g., utility breakdown charts, context tooltips).
- Expand integration tests to cover new features.
- Update documentation in `dev/docs/docs/systems/decision_logging.md` and API docs.

### Checklist
- [ ] Advanced filters and search implemented.
- [ ] Visualisation features added.
- [ ] Integration tests for new features.
- [ ] Documentation updated.
- [ ] No regressions in previous phases.

---

## Testing & Regression Strategy
- All phases require both unit and integration tests.
- No phase is complete until all checklists are satisfied and all tests pass.
- Regression tests must be run after each phase to ensure stability.

---

## Early UI Introduction Rationale
- UI is introduced in Phase 3 to provide immediate feedback and accessibility for developers and players.
- Even a minimal UI (list of decisions) is valuable for debugging and balancing from the earliest stages.

---

## Summary Table
| Phase | Deliverable | UI? | Testing? | Regression? |
|-------|-------------|-----|----------|-------------|
| 1     | Signal emission, data class | No  | Yes      | Yes         |
| 2     | File logging                | No  | Yes      | Yes         |
| 3     | Debug UI panel              | Yes | Yes      | Yes         |
| 4     | Localisation                | Yes | Yes      | Yes         |
| 5     | Advanced UI features        | Yes | Yes      | Yes         |

---

## Next Steps
- Begin with Phase 1, ensuring all checklist items are met before progressing.
- Update this document as the system evolves or requirements change. 