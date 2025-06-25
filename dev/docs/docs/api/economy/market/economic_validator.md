# EconomicValidator

## Last Updated: 2025-06-25

## Table of Contents
- [Overview](#overview)
- [Class Hierarchy](#class-hierarchy)
- [Constants](#constants)
- [Properties](#properties)
- [Signals](#signals)
- [Methods](#methods)
- [Usage Examples](#usage-examples)
- [See Also](#see-also)

## Overview
The `EconomicValidator` class tracks and validates economic invariants in the simulation. It ensures the economy follows core rules like conservation of money and closed-loop production, helping to maintain the integrity of the economic simulation.

## Class Hierarchy
- **Extends:** Node
- **Extended by:** None
- **Used by:** Sim, Market system

## Constants
| Name | Type | Description |
|------|------|-------------|
| FLOAT_EPSILON | float | Maximum allowed floating point difference for equality checks (0.0001) |
| MAX_TRANSACTION_HISTORY | int | Maximum transactions to keep in history (1000) |

## Properties
| Name | Type | Description |
|------|------|-------------|
| _total_resources | Dictionary | Tracks total resources in the economy |
| _transaction_history | Array[Dictionary] | Tracks all economic transactions |
| _initial_money | float | Initial money in the system |

## Signals
| Name | Parameters | Description |
|------|------------|-------------|
| invariant_violated | invariant_name: String, details: String | Emitted when an economic invariant is violated |

## Methods
### set_initial_money(amount: float) -> void
Sets the initial money in the system for validation.

**Parameters:**
- `amount`: The initial amount of money in the system

### record_transaction(transaction_type: String, good: String, amount: int, price: float, buyer: String, seller: String) -> void
Records a new transaction for validation.

**Parameters:**
- `transaction_type`: Type of transaction (e.g., "trade", "production", "consumption")
- `good`: The good being transacted
- `amount`: Quantity of the good
- `price`: Price of the transaction
- `buyer`: ID of the buyer
- `seller`: ID of the seller

### update_resource_totals(resource_totals: Dictionary) -> void
Updates the total resources tracking.

**Parameters:**
- `resource_totals`: Dictionary of current resource totals

### validate_money_conservation() -> bool
Validates that the total money in the system remains constant (except for explicitly tracked sources/sinks).

**Returns:** Boolean indicating if money conservation is maintained

### validate_closed_loop_economy() -> bool
Validates that all goods in the economy came from valid production.

**Returns:** Boolean indicating if closed-loop economy is maintained

### get_transaction_history() -> Array[Dictionary]
Gets the current transaction history.

**Returns:** Array of transaction dictionaries

### clear_transaction_history() -> void
Clears the transaction history.

## Usage Examples
```gdscript
# Create and initialize economic validator
var validator = EconomicValidator.new()

# Connect to signals
validator.invariant_violated.connect(_on_invariant_violated)

# Set initial money in the system
validator.set_initial_money(1000.0)

# Record transactions
validator.record_transaction("trade", "grain", 10, 5.0, "person_1", "person_2")
validator.record_transaction("production", "water", 20, 0.0, "", "person_3")
validator.record_transaction("consumption", "wood", 5, 0.0, "person_4", "")

# Update resource totals
var resource_totals = {
    "grain": 100,
    "water": 200,
    "wood": 150,
    "money": 1000.0
}
validator.update_resource_totals(resource_totals)

# Validate economic invariants
var money_conserved = validator.validate_money_conservation()
print("Money conservation: %s" % ("Valid" if money_conserved else "Violated"))

var closed_loop_valid = validator.validate_closed_loop_economy()
print("Closed-loop economy: %s" % ("Valid" if closed_loop_valid else "Violated"))

# Get transaction history
var history = validator.get_transaction_history()
print("Transaction count: %d" % history.size())

# Clear transaction history
validator.clear_transaction_history()
```

## See Also
- [EconomicMetrics](./economic_metrics.md)
- [Good](./good.md)
- [Market System](../../systems/market_system.md)
