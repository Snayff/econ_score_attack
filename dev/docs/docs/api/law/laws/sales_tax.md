# SalesTax

## Last Updated: 2025-06-25

## Table of Contents
- [Overview](#overview)
- [Class Hierarchy](#class-hierarchy)
- [Constants](#constants)
- [Methods](#methods)
- [Usage Examples](#usage-examples)
- [Error Handling](#error-handling)
- [See Also](#see-also)

## Overview
The `SalesTax` class implements a percentage-based tax on all goods transactions in the demesne. It extends the base `Law` class and provides specific functionality for calculating tax amounts based on a configurable tax rate.

## Class Hierarchy
- **Extends:** [Law](../base/law.md)
- **Extended by:** None
- **Used by:** LawRegistry, Demesne

## Constants
| Name | Type | Description |
|------|------|-------------|
| MIN_TAX_RATE | float | Minimum allowed tax rate (0.0) |
| MAX_TAX_RATE | float | Maximum allowed tax rate (100.0) |
| PARAM_TAX_RATE | String | Parameter name for tax rate ("tax_rate") |

## Methods
### _init(name_: String, category_: String, subcategory_: String, tags_: Array[String], description_: String, parameters_: Dictionary) -> void
Creates a new sales tax law instance.

**Parameters:**
- `name_`: Human-readable name
- `category_`: Main category of the law
- `subcategory_`: Subcategory for more specific categorization
- `tags_`: Array of tags for searching and filtering
- `description_`: Detailed description
- `parameters_`: Initial parameter values

### validate_parameters() -> bool
Validates if tax rate is within acceptable bounds.

**Returns:** Boolean indicating if parameters are valid

### calculate_tax(base_price: int) -> int
Calculates tax amount for a transaction.

**Parameters:**
- `base_price`: Original price before tax

**Returns:** Tax amount to add

### calculate_final_price(base_price: int) -> int
Calculates final price including tax.

**Parameters:**
- `base_price`: Original price before tax

**Returns:** Final price with tax included

## Usage Examples
```gdscript
# Create a sales tax law through the law registry
var sales_tax = demesne.law_registry.create_law("sales_tax")

# Activate the law
sales_tax.activate()

# Set the tax rate to 7.5%
sales_tax.set_parameter("tax_rate", 7.5)

# Calculate tax for a transaction
var item_price = 100
var tax_amount = sales_tax.calculate_tax(item_price)
print("Tax amount: %d" % tax_amount)  # Should print "Tax amount: 8"

# Calculate final price including tax
var final_price = sales_tax.calculate_final_price(item_price)
print("Final price: %d" % final_price)  # Should print "Final price: 108"
```

## Error Handling
- If the tax rate is outside the allowed range (0.0 to 100.0), `validate_parameters()` returns `false`.
- If the law is not active, `calculate_tax()` returns 0.

## See Also
- [Law](../base/law.md)
- [LawRegistry](../base/law_registry.md)
- [DataLaw](../data_class/data_law.md)
