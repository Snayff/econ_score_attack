# Docgen Tool Design

Last Updated: 2024-06-09

## Overview
The `docgen` tool is a modular, reusable, and testable Godot EditorPlugin designed to automate the generation of Markdown documentation from GDScript docstrings. It aligns with project rules for maintainability, extensibility, and robust error handling, and is intended to be portable across Godot projects.

## Rationale
Manual documentation is error-prone and quickly becomes outdated. Automating the extraction of class, function, and variable docstrings into Markdown ensures that API documentation is always up to date, improves onboarding, and supports scalable development.

## Key Features
- Modular, component-based architecture (one class per file)
- EditorPlugin integration for seamless use in the Godot Editor
- Configurable via external JSON file
- Output folder structure mirrors source folder structure
- User confirmation before deletions (with Cancel, Proceed, and Proceed without Deletions options)
- Robust logging of all actions
- Pure functions and data classes for testability
- Strict adherence to project naming, documentation, and architectural rules

## Architecture

### Core Modules
- `docgen_plugin.gd`: EditorPlugin, UI, entry point, user interaction
- `docgen_config.gd`: Loads and validates config
- `docgen_file_discovery.gd`: Finds `.gd` files and output `.md` files
- `docgen_parser.gd`: Parses GDScript files for docstrings and structure
- `docgen_markdown_generator.gd`: Generates markdown from parsed data
- `docgen_logger.gd`: Handles logging of actions and errors
- `docgen_constants.gd`: Holds constants (file extensions, etc.)
- `data_class_info.gd`: Data class for parsed class info
- `data_function_info.gd`: Data class for parsed function info
- `data_variable_info.gd`: Data class for parsed variable info
- `test_docgen.gd`: (Optional) Test harness for unit/integration tests

### Data Flow
1. Load config
2. Discover `.gd` files and intended `.md` outputs
3. Scan output folder for existing docs
4. Calculate delta (add, update, delete)
5. Present summary to user via modal dialogue
6. Execute actions based on user choice
7. Log all actions

## Project Rule Alignment
- One class per file, using snake_case
- Data classes for structured data
- Signals for UI/logic communication
- Comprehensive documentation and error handling
- Constants in a dedicated file
- No project-specific logic; fully configurable

## Extensibility & Reusability
- All behaviour is configurable via JSON
- No hardcoded project structure
- Modules can be replaced or extended independently
- Portable to any Godot project

## Testability
- Parsing and markdown generation are pure functions
- Each module is independently testable
- Test harness provided for automated regression testing

## Existing Related Files
- None yet; this proposal introduces a new tool and supporting modules.

## Example Usage
1. Place the tool in `dev_tool/docs/docgen/`
2. Configure via `docgen_config.json`
3. Enable the plugin in the Godot Editor
4. Run the tool from the editor, review proposed changes, and confirm
5. Review generated documentation and logs 