# IDGenerator System Documentation

## Purpose and Intent

The `IDGenerator` system provides a centralised, robust, and debuggable way to generate, validate, and parse unique identifiers for all game objects in the project. Each identifier consists of a type prefix and a UUID (version 4), ensuring both uniqueness and human-readable context for debugging and analytics. This system is designed to be used across all features and game systems that require persistent, unique references to objects, such as people, buildings, jobs, and more.

## Design

- **Centralised Singleton:** Implemented as an autoload singleton (`globals/id_generator.gd`), ensuring a single authoritative source for ID generation.
- **Prefix + UUID Format:** IDs are generated in the format `{PREFIX}_{UUID}` (e.g., `ACT_123e4567-e89b-12d3-a456-426614174000`).
- **Prefix Constants:** All valid prefixes are defined as constants within the class, ensuring consistency and preventing typos.
- **UUID v4 Generation:** Uses a custom, cryptographically strong random UUID v4 generator implemented in GDScript, as Godot does not provide a built-in UUID class.
- **Validation and Parsing:** Includes static methods for validating ID format and extracting the prefix or UUID from an ID string.
- **No Counters:** The system does not use incrementing counters, relying solely on UUIDs for uniqueness.

## Usage

### Generating an ID
```gdscript
var id = IDGenerator.generate_id("ACT")
```

### Validating an ID
```gdscript
if IDGenerator.validate_id(id):
    # ID is valid
```

### Parsing an ID
```gdscript
var prefix = IDGenerator.get_prefix(id)
var uuid = IDGenerator.get_uuid(id)
```

## Data Schema

- **ID Format:** `{PREFIX}_{UUID}`
  - `PREFIX`: A three-letter string indicating the object type (e.g., `ACT`, `BLD`, `JOB`).
  - `UUID`: A version 4 UUID string in the format `xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx`.

## Extending the System

- To add a new object type, add a new entry to the `PREFIXES` constant in `id_generator.gd`.
- Always use the `generate_id` method to create new IDs to ensure uniqueness and correct format.

## Example
```gdscript
var building_id = IDGenerator.generate_id("BLD")
assert(IDGenerator.validate_id(building_id))
print(IDGenerator.get_prefix(building_id)) # "BLD"
print(IDGenerator.get_uuid(building_id))   # UUID part
```

## Developer Notes
- The system is designed to be stateless and requires no persistence or counter management.
- All IDs should be stored in data classes and persisted in external JSON files for save/load functionality.
- The system is fully decoupled and can be used by any feature or subsystem.

## Associated File
- `globals/id_generator.gd` (autoload singleton) 