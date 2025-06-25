# Good

## Last Updated: 2025-06-25

## Table of Contents
- [Overview](#overview)
- [Class Hierarchy](#class-hierarchy)
- [Properties](#properties)
- [Signals](#signals)
- [Methods](#methods)
- [Usage Examples](#usage-examples)
- [See Also](#see-also)

## Overview
The `Good` class represents a tradeable good or resource in the economy. It stores basic information about a good including its identity and quantity, and provides methods for consuming and producing the good.

## Class Hierarchy
- **Extends:** Node
- **Extended by:** None
- **Used by:** Economic actors, Market system

## Properties
| Name | Type | Description |
|------|------|-------------|
| id | String | Unique identifier for the good |
| amount | int | Current quantity of the good |

## Signals
| Name | Parameters | Description |
|------|------------|-------------|
| amount_changed | new_amount: int | Emitted when the amount of the good changes |
| good_consumed | amount: int | Emitted when some amount of the good is consumed |
| good_produced | amount: int | Emitted when some amount of the good is produced |

## Methods
### consume(consume_amount: int) -> bool
Consumes a specified amount of the good.

**Parameters:**
- `consume_amount`: Amount to consume

**Returns:** Boolean indicating if consumption was successful

### produce(produce_amount: int) -> void
Produces a specified amount of the good.

**Parameters:**
- `produce_amount`: Amount to produce

## Usage Examples
```gdscript
# Create a new good
var grain = Good.new()
grain.id = "grain"
grain.amount = 10

# Connect to signals
grain.amount_changed.connect(_on_grain_amount_changed)
grain.good_consumed.connect(_on_grain_consumed)
grain.good_produced.connect(_on_grain_produced)

# Consume some of the good
if grain.consume(5):
    print("Successfully consumed 5 grain")
else:
    print("Not enough grain to consume")

# Produce more of the good
grain.produce(20)
print("Current grain amount: %d" % grain.amount)  # Should print 25
```

## See Also
- [DataGood](../../economic_actor/data_good.md)
- [GoodsManager](./goods_manager.md)
- [EconomicMetrics](./economic_metrics.md)
- [Market System](../../systems/market_system.md)
