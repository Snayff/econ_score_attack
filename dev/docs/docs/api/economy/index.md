# Economy API

## Last Updated: 2025-06-25

## Overview
The Economy API provides classes for managing the economic simulation, including market mechanics, economic metrics, validation, and UI components for displaying economic data. These components work together to create a closed-loop economy where goods are produced, traded, and consumed.

## Market Classes
- [Good](./market/good.md) - Represents a tradeable good or resource in the economy
- [GoodsManager](./market/goods_manager.md) - Manages all goods in the economy
- [EconomicMetrics](./market/economic_metrics.md) - Tracks and reports on economic metrics
- [EconomicValidator](./market/economic_validator.md) - Validates economic invariants in the simulation

## UI Components
- [ViewEconomy](./ui/view_economy.md) - UI component for displaying economic metrics and trends

## Related Documentation
- [DataGood](../economic_actor/data_good.md) - Data class for good configuration
- [Person](../economic_actor/person.md) - Economic actor that produces and consumes goods
- [Market System](../systems/market_system.md) - System documentation for market mechanics
