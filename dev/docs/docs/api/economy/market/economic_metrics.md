# EconomicMetrics

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
The `EconomicMetrics` class tracks and reports on economic metrics in the simulation. It provides real-time monitoring of economic indicators and historical trends, including price levels, trade volume, money velocity, unemployment, production, wealth distribution, and market activity.

## Class Hierarchy
- **Extends:** Node
- **Extended by:** None
- **Used by:** Sim, ViewEconomy

## Constants
| Name | Type | Description |
|------|------|-------------|
| MAX_HISTORY_PERIODS | int | Maximum periods to keep in history (100) |
| BASE_PERIOD | int | Base period for calculating rates (10) |

## Properties
| Name | Type | Description |
|------|------|-------------|
| _metrics | Dictionary | Current metric values |
| _metric_history | Dictionary | Historical metric values |
| _metric_thresholds | Dictionary | Alert thresholds for metrics |

## Signals
| Name | Parameters | Description |
|------|------------|-------------|
| metric_updated | metric_name: String, new_value: float | Emitted when a metric is updated |
| threshold_crossed | metric_name: String, threshold: float, current_value: float | Emitted when a metric crosses its defined threshold |

## Methods
### update_metrics(sim_state: Dictionary) -> void
Updates metrics based on new economic data.

**Parameters:**
- `sim_state`: Dictionary containing current simulation state

### get_metric(metric_name: String) -> float
Gets a specific metric value.

**Parameters:**
- `metric_name`: Name of the metric to retrieve

**Returns:** Current value of the metric

### get_metric_history(metric_name: String, periods: int = 10) -> Array
Gets historical values for a metric.

**Parameters:**
- `metric_name`: Name of the metric to retrieve history for
- `periods`: Number of historical periods to retrieve (default: 10)

**Returns:** Array of historical values

### generate_report() -> Dictionary
Generates a comprehensive economic report.

**Returns:** Dictionary containing current metrics, trends, and alerts

### set_threshold(metric_name: String, threshold: float) -> void
Sets a threshold for a metric.

**Parameters:**
- `metric_name`: Name of the metric
- `threshold`: New threshold value

## Usage Examples
```gdscript
# Create and initialize economic metrics
var metrics = EconomicMetrics.new()

# Connect to signals
metrics.metric_updated.connect(_on_metric_updated)
metrics.threshold_crossed.connect(_on_threshold_crossed)

# Update metrics with current simulation state
var sim_state = {
    "market_prices": {"grain": 10.0, "water": 5.0, "wood": 15.0},
    "transactions": [
        {"buyer": "person_1", "seller": "person_2", "good": "grain", "amount": 5, "price": 10.0},
        {"buyer": "person_3", "seller": "person_4", "good": "water", "amount": 10, "price": 5.0}
    ],
    "total_money": 1000.0,
    "people": [
        {"job": "farmer", "stockpile": {"money": 100}},
        {"job": "miner", "stockpile": {"money": 200}},
        {"job": "none", "stockpile": {"money": 50}}
    ],
    "production": {"grain": 50, "water": 100, "wood": 30}
}
metrics.update_metrics(sim_state)

# Get a specific metric
var unemployment = metrics.get_metric("unemployment_rate")
print("Unemployment rate: %.2f" % unemployment)

# Get historical data for a metric
var price_history = metrics.get_metric_history("average_price_level", 5)
print("Price level history: %s" % price_history)

# Generate a comprehensive report
var report = metrics.generate_report()
print("Current metrics: %s" % report.current_metrics)
print("Trends: %s" % report.historical_trends)
print("Alerts: %s" % report.alerts)

# Set a custom threshold
metrics.set_threshold("unemployment_rate", 0.15)  # Alert if unemployment > 15%
```

## See Also
- [EconomicValidator](./economic_validator.md)
- [ViewEconomy](../ui/view_economy.md)
- [Market System](../../systems/market_system.md)
