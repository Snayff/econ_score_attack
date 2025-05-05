# Building System: Phased Implementation Plan

## Overview
This document outlines a phased approach for implementing the building system, optimised for incremental delivery, early player feedback, and robust testing. Each phase is designed to be self-contained, with clear goals, deliverables, and test coverage. UI integration is introduced early to ensure features are accessible and testable by players and developers.

---

## Phase 1: Data Model & Static Data

### Goals
- Define and implement the core data classes: `DataBuilding`, `DataJob`.
- Create JSON schemas for building types, job types, and requirements.
- Integrate static data loading via `global/library.gd`.

### Deliverables
- Data classes with docstrings and validation.
- Example JSON files for buildings and jobs.
- Unit tests for data loading and validation.

### Testing
- Test loading and parsing of building/job data.
- Validate error handling for malformed data.

---

## Phase 2: Building Placement & Construction Requirements

### Goals
- Implement logic for constructing buildings, including resource and tile requirements.
- Deduct build costs from the demesne's stockpile.
- Enforce tile requirements (e.g., resource presence).
- Log all construction events.

### Deliverables
- Construction logic in simulation and UI.
- Event logging for construction attempts and outcomes.
- Unit and integration tests for construction logic.

### UI Integration
- Add basic Land View UI for selecting tiles and building types.
- Display requirements and construction feedback to the player.

### Testing
- Test valid and invalid construction attempts.
- Regression tests to ensure no unauthorised construction.

---

## Phase 3: Building Stockpiles & Job Assignment

### Goals
- Implement per-building stockpiles for input/output goods.
- Add job slots to buildings and allow actors to be assigned.
- Log job assignment events.

### Deliverables
- Stockpile management in building data class.
- Job assignment logic and UI.
- Event logging for job changes.
- Unit tests for stockpile and job assignment.

### UI Integration
- Expand Building Info Panel to show stockpile and job slots.
- Allow job assignment via UI (manual or automated).

### Testing
- Test stockpile updates and job assignment edge cases.
- Regression tests for construction and data loading.

---

## Phase 4: Production & Consumption Logic

### Goals
- Move production logic from jobs to buildings.
- Implement end-of-turn production/consumption, using building stockpiles.
- Scale output by job fill and worker happiness.
- Log all production events.

### Deliverables
- Production/consumption logic in simulation.
- Event logging for production outcomes.
- Unit and integration tests for production.

### UI Integration
- Update Building Info Panel to show production status and recent events.

### Testing
- Test production with full, partial, and empty job fill.
- Regression tests for construction, stockpiles, and job assignment.

---

## Phase 5: Market Integration & Economic Loop

### Goals
- Integrate building output with the market and demesne stockpile.
- Ensure goods flow from buildings to market/actors as appropriate.
- Log all relevant economic events.

### Deliverables
- Logic for transferring goods from buildings to market.
- Event logging for market transactions.
- Integration tests for economic loop.

### UI Integration
- Show marketable goods and transactions in UI.

### Testing
- Test end-to-end economic flow.
- Regression tests for all previous phases.

---

## Phase 6: Balancing, Playtesting, and Documentation

### Goals
- Balance parameters for fun and challenge.
- Conduct playtesting and gather feedback.
- Update documentation and in-game help.

### Deliverables
- Tuned JSON data for buildings, jobs, and requirements.
- Updated design and system documentation.
- Playtest reports and bug fixes.

### Testing
- Automated regression suite for all features.
- Manual playtesting for usability and balance.

---

## Continuous Testing & Regression Prevention
- Each phase includes unit and integration tests.
- Regression tests are run after each phase to ensure no breakage.
- Event logging is used to trace and debug issues.
- UI is updated incrementally to expose new features for testing and feedback.

---

## Early UI Integration Rationale
- Early UI ensures features are accessible and testable by players and developers.
- Allows for rapid feedback and iterative improvement.
- Reduces risk of late-stage integration issues.

---

## Summary
This phased approach ensures a robust, testable, and player-accessible building system, with clear milestones and continuous validation. Each phase builds on the last, with a focus on maintainability, extensibility, and player experience. 