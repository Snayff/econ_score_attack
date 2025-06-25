# Law

## Last Updated: 2025-06-25

## Table of Contents
- [Overview](#overview)
- [Class Hierarchy](#class-hierarchy)
- [Properties](#properties)
- [Signals](#signals)
- [Methods](#methods)
- [Usage Examples](#usage-examples)
- [Error Handling](#error-handling)
- [See Also](#see-also)

## Overview
The `Law` class is the base class for all economic laws that can be enacted in a demesne. It provides core functionality for law management and parameter handling. Laws represent rules and regulations that affect the economy and society within a demesne.

## Class Hierarchy
- **Extends:** RefCounted
- **Extended by:** SalesTax, DemesneInheritance
- **Used by:** LawRegistry, Demesne

## Properties
| Name | Type | Description |
|------|------|-------------|
| id | String | Unique identifier for this law type |
| name | String | Human-readable name of the law |
| category | String | Main category of the law |
| subcategory | String | Subcategory for more specific categorization |
| tags | Array[String] | Tags for searching and filtering |
| description | String | Detailed description of the law's effects |
| parameters | Dictionary | Current parameter values for this law instance |
| active | bool | Whether the law is currently in effect |

## Signals
| Name | Parameters | Description |
|------|------------|-------------|
| parameters_changed | parameter_name: String, new_value: float | Emitted when a parameter value is changed |

## Methods
### _init(id_: String, name_: String, category_: String, subcategory_: String, tags_: Array[String], description_: String, parameters_: Dictionary) -> void
Creates a new law instance.

**Parameters:**
- `id_`: Unique identifier for the law type
- `name_`: Human-readable name
- `category_`: Main category of the law
- `subcategory_`: Subcategory for more specific categorization
- `tags_`: Array of tags for searching and filtering
- `description_`: Detailed description
- `parameters_`: Initial parameter values

### activate() -> void
Activates this law instance.

### deactivate() -> void
Deactivates this law instance.

### set_parameter(parameter_name: String, value: float) -> bool
Updates a parameter value.

**Parameters:**
- `parameter_name`: Name of parameter to update
- `value`: New parameter value

**Returns:** Boolean indicating if update was successful

### get_parameter(parameter_name: String) -> float
Retrieves a parameter value.

**Parameters:**
- `parameter_name`: Name of parameter to retrieve

**Returns:** Parameter value or 0.0 if not found

### validate_parameters() -> bool
Validates if all required parameters are present and valid.

**Returns:** Boolean indicating if parameters are valid

### get_tags() -> Array[String]
Gets all tags for this law.

**Returns:** Array of tags

### has_tag(tag: String) -> bool
Checks if the law has a specific tag.

**Parameters:**
- `tag`: Tag to check for

**Returns:** Boolean indicating if the law has the tag

## Usage Examples
```gdscript
# Create a new law instance
var law = Law.new(
    "sales_tax",
    "Sales Tax",
    "economic",
    "taxation",
    ["tax", "economy"],
    "A tax on all sales transactions in the demesne.",
    {"tax_rate": 5.0}
)

# Activate the law
law.activate()

# Update a parameter
if law.set_parameter("tax_rate", 7.5):
    print("Tax rate updated to: %f" % law.get_parameter("tax_rate"))
else:
    print("Failed to update tax rate")

# Check if the law has a specific tag
if law.has_tag("tax"):
    print("This is a tax-related law")
```

## Error Handling
- If a parameter doesn't exist when calling `set_parameter()`, the method returns `false`.
- The `validate_parameters()` method should be overridden by subclasses to provide specific validation logic.

## See Also
- [LawRegistry](./law_registry.md)
- [DataLaw](../data_class/data_law.md)
- [SalesTax](../laws/sales_tax.md)
- [DemesneInheritance](../laws/demesne_inheritance.md)
