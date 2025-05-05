# Project Structure Implementation Plan

## Overview
This document outlines the phased approach for implementing the new project structure. Each phase is designed to maintain a working game state while progressively introducing new organisation patterns. The plan emphasises early UI access and comprehensive testing.

## Phase 0: Preparation
**Goal**: Set up the foundation for the new structure while maintaining the current game state.

### Tasks
1. Create new top-level directories
   - `features/`
   - `shared/`
   - `global/`
   - `main/`
   - `data/`


### Testing Focus
- Test harness setup
- Basic UI navigation
- Resource loading

## Phase 1: Global Infrastructure
**Goal**: Establish core systems and shared resources.

### Tasks
1. Move global scripts to `global/`
   - Event buses
   - Constants
   - Library loader

2. Set up shared resources in `shared/`
   - UI components
   - Data classes
   - Utility functions
   - Move assets

3. Create basic UI components
   - Buttons
   - Labels
   - Panels
   - Common dialogs

### Testing Focus
- Event bus communication
- Resource loading/unloading
- UI component behaviour
- Cross-feature integration tests

## Phase 2: First Feature Migration
**Goal**: Move one complete feature to demonstrate the new structure.

### Tasks
1. Choose a relatively independent feature
   - Suggest starting with `world`
   - Include all related scripts, scenes, and data
   - Set up feature-specific tests

2. Create feature UI
   - Main feature interface
   - Feature-specific components
   - Integration with global UI

3. Document the migration process
   - Update templates
   - Note common issues
   - Create checklist

### Testing Focus
- Feature functionality
- UI integration
- Performance impact
- Resource management

## Phase 3: Domain-Based Migration
**Goal**: Group related features into domains and migrate them together.

### Tasks
1. Migrate `economy` domain
	- economic actors
   - Market system
   - Production system
   - Economy UI components

2. Update cross-feature communication
   - Event bus connections
   - Shared state management
   - UI updates

### Testing Focus
- Domain integration
- Cross-domain communication
- UI responsiveness
- Resource usage

## Phase 4: Shared Systems Enhancement
**Goal**: Optimise shared resources and cross-feature interactions.

### Tasks
1. Refine shared components
   - Identify common patterns
   - Create new shared components
   - Optimise existing ones

2. Enhance UI framework
   - Add advanced UI features
   - Improve performance
   - Add animations/transitions

3. Implement comprehensive logging
   - Feature usage
   - Performance metrics
   - Error tracking

### Testing Focus
- Component reusability
- UI performance
- System integration
- Error handling

## Phase 5: Final Migration and Optimization
**Goal**: Complete the migration and optimise the entire system.

### Tasks
1. Migrate remaining features
   - Laws system
   - Any remaining subsystems
   - Clean up old structure

2. Performance optimization
   - Resource loading
   - Scene management
   - Memory usage

3. Documentation update
   - Architecture guide
   - Feature documentation
   - Testing guide

### Testing Focus
- Full system integration
- Performance benchmarks
- Regression testing
- User acceptance testing

## UI Accessibility Throughout Phases

### Phase 0-1
- Basic menu system
- Feature placeholders
- Loading screens
- Settings interface

### Phase 2
- First feature fully playable
- Basic interaction model
- Feedback system

### Phase 3
- Domain-specific interfaces
- Cross-feature interaction
- Enhanced feedback

### Phase 4-5
- Full feature set
- Polished interactions
- Complete UI system

## Testing Strategy

### Continuous Testing
- Unit tests with each feature
- Integration tests in shared
- Performance benchmarks
- UI/UX testing

### Regression Prevention
- Automated test suite
- Feature comparison tests
- Performance monitoring
- UI consistency checks

### Test Types
1. **Unit Tests**
   - Feature-specific functionality
   - Shared components
   - UI elements

2. **Integration Tests**
   - Cross-feature communication
   - UI integration
   - Resource management

3. **Performance Tests**
   - Resource usage
   - Loading times
   - UI responsiveness

4. **User Acceptance Tests**
   - Feature completeness
   - UI usability
   - Game flow

## Success Criteria
- All features migrated
- No functionality loss
- Improved performance
- Better developer experience
- Comprehensive test coverage
- Clear documentation
- Maintainable structure

## Rollback Plan
- Each phase has a rollback point
- Feature toggles for new structure
- Parallel systems during migration
- Data backup strategy

## Migration Checklist and Audit

### Migration Checklist
- [ ] All scripts are in `feature/`, `shared/`, or `global/`
- [ ] All scenes are co-located with their scripts (feature, shared, or main)
- [ ] All assets are in `feature/` or `shared/`
- [ ] All data files are in `feature/`, `shared/`, or `data/`
- [ ] All tests are in `feature/` or `shared/`
- [ ] All documentation is up to date and references new paths
- [ ] All templates are in `feature/` or `shared/`
- [ ] All configs are in `config/`, `dev_tools/`, or feature folders
- [ ] Only necessary autoloads exist in `global/`
- [ ] All cross-feature communication uses event buses

### Audit of Remaining Items to Migrate

#### 1. `scripts/` Directory
- Contains subfolders: `ui/`, `resources/`, `laws/`, `data/`, `core/`, `actors/`, `economic_analysis/`, `global/`
- **Action:** Review each subfolder and migrate scripts to the appropriate `feature/`, `shared/`, or `global/` location. Remove or archive the `scripts/` directory once empty.

#### 4. `tests/` Directory
- Contains: `core/`, `unit/`, `integration/`.
- **Action:** Move feature-specific tests to `feature/<feature_name>/tests/`. Move cross-feature/integration tests to `shared/tests/`. Remove or archive the `tests/` directory once empty.

#### 5. `scenes/` Directory
- Contains: `main/`, `ui/`.
- **Action:** Move feature-specific scenes to `feature/<feature_name>/ui/`. Move shared scenes to `shared/ui/scenes/`. Main entry scene should be in `main/`.

#### 6. `dev_tools/` Directory
- Contains: `logger/` (with `ui/components/`, `ui/scenes/`, `config/`).
- **Action:** Ensure only dev-related tools/scripts are present. If any UI components or scenes are reusable, consider moving to `shared/ui/components/` or `shared/ui/scenes/`.

#### 7. `config/` Directory
- Contains: `dev_tools/tester/test_runner.json` (test runner config and logic now reside in dev_tools/tester/).
- **Action:** Ensure only configuration files are present. Move feature-specific configs to the relevant feature folder if needed.

#### 11. Documentation
- **Action:** Update all documentation to reference new paths and structure. Place feature-specific docs in `feature/<feature_name>/docs/` if needed. System-level docs should be in `dev/docs/docs/systems/`.

#### 12. Event Buses
- **Action:** Ensure all cross-feature signals are in `global/event_bus_game.gd` or `global/event_bus_ui.gd`. Remove any direct node-to-node communication that crosses feature boundaries.

---

This checklist and audit should be reviewed and updated regularly throughout the migration process to ensure a complete and maintainable transition to the new project structure. 