# Docgen Tool Phased Implementation

Last Updated: 2024-06-09

## Overview
This document outlines a phased approach for implementing the modular, EditorPlugin-based `docgen` tool for GDScript-to-Markdown documentation generation. The plan prioritises early testability, incremental UI introduction, and continuous user value, while ensuring no regressions between phases.

## Existing Related Files
- `dev/docs/designs/docgen_tool_design.md` (design document)

## Phase 1: Core Parsing and Markdown Generation (Headless)
- Implement `docgen_config.gd`, `docgen_parser.gd`, `docgen_markdown_generator.gd`, and data classes.
- Provide a CLI or scriptable entry point for running the tool outside the editor.
- Focus on pure functions and unit tests for parsing and markdown generation.
- Output markdown files to the specified output folder, mirroring the source structure.
- **Testing:** Unit tests for parsing and markdown generation. Integration test for end-to-end run on a sample folder.
- **User Value:** Immediate ability to generate up-to-date documentation from GDScript files.

**Phase 1 Checklist:**
- [ ] Design and document the data classes for parsed class, function, and variable info
- [ ] Implement `docgen_config.gd` for config loading and validation
- [ ] Implement `docgen_parser.gd` as a pure function module
- [ ] Implement `docgen_markdown_generator.gd` as a pure function module
- [ ] Create a CLI or scriptable entry point for headless execution
- [ ] Write unit tests for parsing and markdown generation
- [ ] Write integration test for end-to-end documentation generation
- [ ] Review code for adherence to project rules and documentation standards
- [ ] Document usage and limitations for this phase

## Phase 2: File Discovery, Delta Calculation, and Logging
- Implement `docgen_file_discovery.gd` and `docgen_logger.gd`.
- Add logic to scan for `.gd` files, calculate add/update/delete deltas, and log all actions.
- Ensure robust error handling and clear log output.
- **Testing:** Unit tests for file discovery and delta calculation. Regression tests to ensure no markdown is lost or overwritten incorrectly.
- **User Value:** Users can see what will be added, updated, or deleted, and have a log for auditability.

**Phase 2 Checklist:**
- [ ] Implement `docgen_file_discovery.gd` for recursive file scanning
- [ ] Implement delta calculation logic (add, update, delete)
- [ ] Implement `docgen_logger.gd` for action and error logging
- [ ] Integrate logging into the CLI/scriptable entry point
- [ ] Write unit tests for file discovery and delta calculation
- [ ] Write regression tests to ensure no markdown is lost or overwritten incorrectly
- [ ] Review error handling and log output for clarity
- [ ] Update documentation to reflect new features and usage

## Phase 3: Godot Editor Integration and UI (Minimal)
- Implement `docgen_plugin.gd` as a Godot EditorPlugin.
- Add a simple UI (e.g., toolbar button or menu item) to run the tool from the editor.
- Present a modal dialogue summarising proposed changes, with Cancel/Proceed/Proceed without Deletions options.
- Use signals for communication between UI and logic.
- **Testing:** UI tests for dialogue behaviour. Integration tests for plugin activation and user flow.
- **User Value:** Users can run the tool from within the Godot Editor and make informed decisions about documentation changes.

**Phase 3 Checklist:**
- [ ] Implement `docgen_plugin.gd` as an EditorPlugin
- [ ] Add UI element (toolbar button or menu item) for tool activation
- [ ] Implement modal dialogue for user confirmation (Cancel/Proceed/Proceed without Deletions)
- [ ] Connect UI and logic using signals
- [ ] Integrate file discovery, delta calculation, and logging with the plugin
- [ ] Write UI tests for dialogue and user flow
- [ ] Write integration tests for plugin activation and end-to-end usage
- [ ] Review UI for accessibility and usability
- [ ] Update documentation with editor usage instructions

## Phase 4: Extensibility, Robustness, and Regression Testing
- Refine all modules for extensibility (e.g., support for additional file types or output formats via config).
- Add `docgen_constants.gd` for all repeated values.
- Expand test harness (`test_docgen.gd`) for automated regression testing across all modules.
- Document the tool and its usage thoroughly.
- **Testing:** Full regression suite, including edge cases and error conditions.
- **User Value:** Highly robust, extensible, and maintainable documentation tool, with confidence in stability and correctness.

**Phase 4 Checklist:**
- [ ] Refactor modules for extensibility and configurability
- [ ] Implement support for additional file types/output formats as needed
- [ ] Add `docgen_constants.gd` for all repeated values
- [ ] Expand `test_docgen.gd` for comprehensive regression testing
- [ ] Write tests for edge cases and error conditions
- [ ] Review and update all module documentation
- [ ] Ensure backward compatibility and no regressions
- [ ] Update user documentation and usage examples

## Phase 5: Continuous Improvement and User Feedback
- Gather user feedback and iterate on UI/UX and feature set.
- Consider advanced features (e.g., live preview, integration with other tools, custom markdown templates).
- Maintain and update documentation and tests as the tool evolves.
- **Testing:** Ongoing, with new tests for each feature or bugfix.
- **User Value:** Continual improvement and alignment with user needs.

**Phase 5 Checklist:**
- [ ] Collect and review user feedback
- [ ] Prioritise and implement new features or improvements
- [ ] Add advanced features (live preview, integrations, custom templates) as needed
- [ ] Maintain and expand automated test coverage
- [ ] Regularly review and update documentation
- [ ] Monitor for regressions and address promptly
- [ ] Ensure ongoing alignment with project rules and user needs

## Regression Prevention
- Each phase introduces or expands automated tests.
- No phase removes or breaks existing functionality; all new features are additive and backward-compatible.
- Logs and user confirmation steps ensure transparency and prevent accidental data loss. 