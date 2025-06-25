# Law System API

## Last Updated: 2025-06-25

## Overview
The Law System provides functionality for creating, managing, and enforcing laws within a demesne. Laws represent rules and regulations that affect the economy and society, such as taxation, inheritance, and other governance mechanisms.

## Core Components

### Base Classes
- [Law](./base/law.md) - Base class for all economic laws that can be enacted in a demesne
- [LawRegistry](./base/law_registry.md) - Registry for available law types within a demesne

### Data Classes
- [DataLaw](./data_class/data_law.md) - Data container for law information loaded from configuration files

### Law Implementations
- [SalesTax](./laws/sales_tax.md) - Implements a percentage-based tax on all goods transactions
- [DemesneInheritance](./laws/demesne_inheritance.md) - Implements inheritance rules for demesne succession

### UI Components
- [SubViewCodex](./ui/sub_view_codex.md) - Law codex view for displaying and managing laws

## Common Usage Patterns

### Creating and Enacting Laws
```gdscript
# Get a reference to the demesne's law registry
var law_registry = demesne.law_registry

# Create a new law instance
var sales_tax = law_registry.create_law("sales_tax")

# Configure the law
sales_tax.set_parameter("tax_rate", 7.5)

# Activate the law
sales_tax.activate()
```

### Querying Available Laws
```gdscript
# Get all available law IDs
var available_laws = demesne.law_registry.get_available_law_ids()

# Get all economic laws
var economic_laws = demesne.law_registry.get_laws_by_category("economic")

# Get all laws with the "tax" tag
var tax_laws = demesne.law_registry.get_laws_by_tag("tax")
```

### Checking Law Status
```gdscript
# Check if a specific law is active
if demesne.is_law_active("sales_tax"):
    print("Sales tax is active")
    
# Get the tax rate parameter
var tax_rate = demesne.get_active_law("sales_tax").get_parameter("tax_rate")
print("Current tax rate: %f%%" % tax_rate)
```

## Integration with Other Systems
The Law System integrates with several other systems:

- **Economy System**: Laws like SalesTax affect economic transactions
- **Demesne System**: Laws are managed at the demesne level
- **UI System**: The SubViewCodex provides a user interface for law management

## See Also
- [Demesne](../demesne/demesne.md)
- [Economy](../economy/index.md)
- [Library](../shared/library.md)
