# DataLaw

## Last Updated: 2025-06-25

## Table of Contents
- [Overview](#overview)
- [Class Hierarchy](#class-hierarchy)
- [Properties](#properties)
- [Methods](#methods)
- [Usage Examples](#usage-examples)
- [See Also](#see-also)

## Overview
The `DataLaw` class represents a law in the simulation, including its id, display name, description, category, and any other relevant properties. It serves as a data container for law information loaded from configuration files.

## Class Hierarchy
- **Extends:** Resource
- **Extended by:** None
- **Used by:** LawRegistry, Library

## Properties
| Name | Type | Description |
|------|------|-------------|
| id | String | Unique string ID for the law |
| f_name | String | Display name for the law |
| description | String | Description of the law |
| category | String | Category of the law (e.g., economic, social) |

## Methods
### _init(id_: String, f_name_: String, description_: String, category_: String) -> void
Constructs a new DataLaw instance.

**Parameters:**
- `id_`: Unique string ID for the law
- `f_name_`: Display name for the law
- `description_`: Description of the law
- `category_`: Category of the law (e.g., economic, social)

## Usage Examples
```gdscript
# Create a new law data instance
var law_data = DataLaw.new(
    "sales_tax",
    "Sales Tax",
    "A tax applied to all sales transactions in the demesne.",
    "economic"
)

# Access law data properties
print("Law ID: %s" % law_data.id)
print("Law Name: %s" % law_data.f_name)
print("Law Description: %s" % law_data.description)
print("Law Category: %s" % law_data.category)

# Use with Library to load all laws
var all_laws = Library.get_all_laws_data()
for law in all_laws:
    print("Found law: %s (%s)" % [law.f_name, law.id])
```

## See Also
- [Law](../base/law.md)
- [LawRegistry](../base/law_registry.md)
- [Library](../../shared/library.md)
