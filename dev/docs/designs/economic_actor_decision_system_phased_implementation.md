# Phased Implementation Plan: Economic Actor Decision System

## Overview
This document outlines a step-by-step, test-driven approach to implementing the economic actor decision-making system. The plan is designed for modularity, early player feedback via UI, and robust testing to prevent regressions at each stage.

---

## Phase 1: Foundations & Data Structures

**Goals:**
- Define all core data classes (e.g., `DataActor`, `DataCulture`, `DataGood`).
- Set up external JSON configs for cultures, ancestries, and goods.
- Implement loading and validation of data via `globals/library.gd`.

**Testing:**
- Unit tests for data class construction and JSON parsing.
- Validation tests for required fields and error handling.

**UI:**
- Minimal debug UI to inspect loaded data (e.g., list of actors and their preferences).

---

## Phase 2: Utility Function & Basic Decision Logic

**Goals:**
- Implement the core utility function as a pure function.
- Allow actors to evaluate available goods and select the highest-utility affordable item.
- Integrate cultural/ancestral influence on preferences.

**Testing:**
- Unit tests for utility calculation under various needs and cultural settings.
- Test cases for edge conditions (e.g., no affordable goods, zero needs).

**UI:**
- Expand debug UI to show utility calculations for selected actors.
- Allow player to trigger a decision evaluation for an actor and view the result.

---

## Phase 3: Budget Constraint & Savings Propensity

**Goals:**
- Implement savings rate and disposable income logic.
- Actors now reserve a portion of their money and only spend disposable income.

**Testing:**
- Unit tests for savings and spending logic.
- Regression tests to ensure previous decision logic still works with new constraints.

**UI:**
- Show actor's savings, disposable income, and purchase decisions in the debug UI.

---

## Phase 4: Event-Driven Triggers & Batch Processing

**Goals:**
- Implement event-driven triggers (needs threshold, market events) for decision evaluation.
- Add batch processing to spread actor evaluations over multiple frames.

**Testing:**
- Tests for event triggers and correct batch scheduling.
- Performance profiling to ensure smooth frame times.
- Regression tests for all previous logic.

**UI:**
- Visualise which actors are being processed each frame.
- Allow player to simulate events (e.g., price change, need spike) and observe actor responses.

---

## Phase 5: Economic Shocks & Adaptive Behaviour

**Goals:**
- Implement economic shock events (e.g., supply shortages, disasters).
- Actors adapt their behaviour (utility weights, savings rate, etc.) in response to shocks, with cultural variation.

**Testing:**
- Unit and integration tests for shock event handling and adaptation logic.
- Regression tests for all previous phases.

**UI:**
- Event timeline visualisation showing shocks and actor adaptation.
- Actor inspector shows current adaptation state and history.

---

## Phase 6: Debugging & Visualisation Tools

**Goals:**
- Implement comprehensive logging of actor decisions.
- Add visualisation overlays: market heatmap, actor inspector, event timeline.
- Ensure all tools are toggleable and dev-only.

**Testing:**
- Tests for logging output and UI toggle functionality.
- Usability tests for visualisation clarity.
- Regression tests for all gameplay logic.

**UI:**
- Full suite of developer tools for inspecting and understanding the simulation.

---

## Continuous Testing & Regression Prevention
- At each phase, all new features are covered by unit and integration tests.
- Regression tests are run to ensure no previous functionality is broken.
- Mock data and test harnesses are used to simulate edge cases and market conditions.
- All debugging/visualisation tools are tested for performance and usability.

---

## Early UI Introduction Rationale
- UI is introduced from the first phase to provide immediate feedback and facilitate debugging.
- Early UI allows for player and developer insight into system behaviour, making balancing and tuning easier.
- Visualisation tools are expanded in parallel with system complexity, ensuring transparency and accessibility throughout development.

---

## Summary Table
| Phase | Focus | UI/Debug | Testing |
|-------|-------|----------|---------|
| 1 | Data structures, loading | Data inspector | Unit, validation |
| 2 | Utility & decision logic | Utility viewer | Unit, edge cases |
| 3 | Budget & savings | Savings display | Unit, regression |
| 4 | Event triggers, batching | Batch visualiser | Event, perf, regression |
| 5 | Shocks & adaptation | Event timeline | Unit, integration, regression |
| 6 | Debug/visualisation tools | Full suite | Logging, usability, regression |

---

## Final Notes
- This phased approach ensures modular, testable, and player-accessible development.
- Each phase builds on the last, with continuous testing and UI feedback to catch issues early and support iterative improvement. 