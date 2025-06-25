# LawRegistry

## Last Updated: 2025-06-25

## Table of Contents
- [Overview](#overview)
- [Class Hierarchy](#class-hierarchy)
- [Properties](#properties)
- [Methods](#methods)
- [Usage Examples](#usage-examples)
- [Error Handling](#error-handling)
- [See Also](#see-also)

## Overview
The `LawRegistry` class serves as a registry for available law types within a demesne. It handles law creation, validation, and provides methods for querying available laws by various criteria. This registry is responsible for instantiating specific law classes based on their IDs and configuration data.

## Class Hierarchy
- **Extends:** RefCounted
- **Extended by:** None
- **Used by:** Demesne

## Properties
| Name | Type | Description |
|------|------|-------------|
| _law_types | Dictionary | Mapping of law IDs to their class types |
| _demesne | Demesne | Reference to the owning demesne |

## Methods
### _init(demesne: Demesne) -> void
Initializes the registry for a specific demesne.

**Parameters:**
- `demesne`: The demesne this registry belongs to

### _register_default_laws() -> void
Registers built-in law types.

### register_law_type(law_id: String, law_class: GDScript) -> void
Registers a new law type.

**Parameters:**
- `law_id`: Unique identifier for the law type
- `law_class`: Class to use for instantiation

### get_available_law_ids() -> Array[String]
Gets all available law IDs in this registry.

**Returns:** Array of law IDs that can be created by this registry

### create_law(law_id: String) -> Law
Creates a new law instance.

**Parameters:**
- `law_id`: ID of the law type to create

**Returns:** New law instance or null if creation failed

### get_parameter_options(law_id: String, parameter_name: String) -> Array
Gets the available parameter options for a law type.

**Parameters:**
- `law_id`: ID of the law type
- `parameter_name`: Name of the parameter

**Returns:** Array of available options or empty array if not found

### get_laws_by_tag(tag: String) -> Array[String]
Gets all laws with a specific tag.

**Parameters:**
- `tag`: Tag to search for

**Returns:** Array of law IDs that have the tag

### get_laws_by_category(category: String, subcategory: String = "") -> Array[String]
Gets all laws in a specific category and subcategory.

**Parameters:**
- `category`: Category to search for
- `subcategory`: Optional subcategory to filter by

**Returns:** Array of law IDs that match the criteria

## Usage Examples
```gdscript
# Get a reference to the demesne's law registry
var law_registry = demesne.law_registry

# Get all available law IDs
var available_laws = law_registry.get_available_law_ids()
print("Available laws: ", available_laws)

# Create a new law instance
var sales_tax = law_registry.create_law("sales_tax")
if sales_tax:
    print("Created sales tax law: ", sales_tax.name)
    
# Get all economic laws
var economic_laws = law_registry.get_laws_by_category("economic")
print("Economic laws: ", economic_laws)

# Get all laws with the "tax" tag
var tax_laws = law_registry.get_laws_by_tag("tax")
print("Tax laws: ", tax_laws)

# Register a custom law type
law_registry.register_law_type("custom_law", CustomLaw)
```

## Error Handling
- If a law ID is not found in the registry, `create_law()` returns `null`.
- If law data is not found in the Library, `create_law()` returns `null`.
- If parameter options are not found, `get_parameter_options()` returns an empty array.

## See Also
- [Law](./law.md)
- [DataLaw](../data_class/data_law.md)
- [SalesTax](../laws/sales_tax.md)
- [DemesneInheritance](../laws/demesne_inheritance.md)
- [Library](../../shared/library.md)
