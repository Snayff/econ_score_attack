# Constants System Documentation

## Purpose and Intent

The `constants.gd` global autoload provides a single, authoritative source for all constant values and enumerations that are shared across multiple systems and features in the game. This ensures consistency, reduces duplication, and makes it easy to update or reference shared values throughout the codebase.

## Design

- **Centralised Constants:** All values that are used in more than one file (such as enums, fixed values, and shared configuration) are defined in `constants.gd`.
- **Global Access:** Registered as an autoload singleton, so any script can access constants via the `Constants` global.
- **No Logic:** The file contains only constant definitions and (optionally) enums—no functions or logic.
- **Project-Wide Consistency:** By referencing constants from a single location, the risk of typos and mismatches is minimised.

## Architecture

The Constants autoload is referenced by any system, feature, or script that requires shared values. It does not depend on any other system and is purely a provider of static data.

```
+-------------------+
|   constants.gd    |
|   (autoload)      |
+-------------------+
        |      |      |      |
        v      v      v      v
   SystemA  SystemB  UI   FeatureX
```

All systems, features, and UI components can access shared values by referencing the Constants autoload.

## Usage

- Access any constant via the `Constants` autoload:
  - `Constants.SOME_ENUM_VALUE`
  - `Constants.MAX_GRID_SIZE`
- Add new constants or enums as needed for project-wide use.

Example:
```gdscript
if value > Constants.MAX_ALLOWED:
    print(Constants.ERROR_MESSAGE)
```

## Extending the System

- Add new constants or enums directly to `constants.gd` as the need for shared values arises.
- Remove unused constants to keep the file clean and relevant.
- Update documentation if new categories of constants are introduced.

## Developer Notes

- Only values used in more than one file should be placed here; feature-specific values should remain local to their feature.
- Avoid adding logic or functions to this file—keep it strictly for static values.
- Use descriptive names and group related constants for clarity.

## Associated File
- `global/constants.gd` (autoload singleton)

## Last Updated
2025-05-04