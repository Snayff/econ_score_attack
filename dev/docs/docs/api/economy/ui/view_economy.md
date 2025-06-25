# ViewEconomy

## Last Updated: 2025-06-25

## Table of Contents
- [Overview](#overview)
- [Class Hierarchy](#class-hierarchy)
- [Constants](#constants)
- [Properties](#properties)
- [Methods](#methods)
- [Usage Examples](#usage-examples)
- [See Also](#see-also)

## Overview
The `ViewEconomy` class is a UI component that displays economic metrics and trends for the demesne. It uses the standardized ABCView layout system to show economic data in a structured format, including alerts, current metrics, and historical trends.

## Class Hierarchy
- **Extends:** ABCView
- **Extended by:** None
- **Used by:** Main UI system

## Constants
| Name | Type | Description |
|------|------|-------------|
| TREND_INDICATORS | Dictionary | Symbols for positive, negative, and neutral trends |
| METRIC_LABELS | Dictionary | Human-readable labels for economic metrics |
| METRIC_DESCRIPTIONS | Dictionary | Descriptions of what each economic metric means |

## Properties
| Name | Type | Description |
|------|------|-------------|
| _sim | Sim | Reference to the simulation instance |

## Methods
### update_view() -> void
Updates the displayed information in the centre panel with economic metrics and trends.

**Overrides:** ABCView.update_view()

### _create_alerts_panel(alerts: Array) -> PanelContainer
Creates a panel displaying economic alerts.

**Parameters:**
- `alerts`: Array of alert data

**Returns:** A panel container with alert information

### _create_metrics_panel(metrics: Dictionary, trends: Dictionary) -> PanelContainer
Creates a panel displaying economic metrics and trends.

**Parameters:**
- `metrics`: Dictionary of current metric values
- `trends`: Dictionary of trend data for metrics

**Returns:** A panel container with metrics and trends

## Usage Examples
```gdscript
# ViewEconomy is typically instantiated by the UI system, not directly
# But here's how you might interact with it programmatically:

# Assuming we have a reference to the view
var economy_view = get_node("MainUI/ViewContainer/ViewEconomy")

# Manually update the view
economy_view.update_view()

# The view automatically updates when:
# 1. The Sim reference is set
# 2. A turn is completed (via EventBusGame.turn_complete signal)
```

## See Also
- [EconomicMetrics](../market/economic_metrics.md)
- [EconomicValidator](../market/economic_validator.md)
- [Market System](../../systems/market_system.md)
- [UI Layout System](../../systems/ui_layout.md)
