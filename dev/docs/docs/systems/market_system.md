# Market System Documentation

## Last Updated
2025-06-23

## Purpose and Intent

The Market System is a core component of the game's economic simulation, responsible for managing all market-related functionality at the demesne level. It serves as the central mechanism for economic exchange, implementing the dynamic pricing, trading, and tax collection that drive the closed-loop economy.

The system's primary responsibilities include:
- Managing good prices based on supply and demand
- Processing trades between economic actors
- Handling tax collection on transactions
- Recording and analyzing market activity
- Providing economic metrics and indicators
- Emitting market-related signals to other systems

As a foundational element of the closed-loop economy, the Market System ensures that all goods produced within the demesne can be traded, consumed, and taxed according to realistic economic principles, creating emergent economic behaviors and challenges for the player.

---

## Design

### Core Components

The Market System is designed around several key components that work together to simulate a functioning economy:

1. **Market Class**: The central manager for all market operations within a demesne.
2. **Goods Manager**: Handles the loading and access of good definitions.
3. **Economic Metrics**: Tracks and reports on economic indicators.
4. **Economic Validator**: Ensures economic rules and constraints are maintained.
5. **Data Classes**: Represent market entities like goods, transactions, and trade orders.

### Design Principles

The Market System follows these key design principles:

- **Data-Driven**: All market entities and behaviors are defined through external data.
- **Decoupled Communication**: Uses event bus signals for cross-system communication.
- **Turn-Based Processing**: Market operations are processed once per game turn.
- **Randomized Trade Resolution**: Trades are processed in random order to prevent exploitation.
- **Transparent Analytics**: Provides clear metrics and indicators for player decision-making.

### Processing Patterns

The Market System uses several processing patterns:

```
+----------------+     +----------------+     +----------------+
|                |     |                |     |                |
| Gather Market  |---->| Process Trades |---->| Update Metrics |
|    State       |     |                |     |                |
|                |     |                |     |                |
+----------------+     +----------------+     +----------------+
```

1. **Gather Market State**: Collect all buy/sell orders from economic actors.
2. **Process Trades**: Match buyers and sellers, execute transactions.
3. **Update Metrics**: Calculate economic indicators based on market activity.
4. **Emit Signals**: Notify other systems of market changes.

---

## Architecture

### Component Diagram

```
+----------------+     +----------------+     +----------------+
|                |     |                |     |                |
|    Library     |---->| GoodsManager   |---->|    Market      |
|  (Data Source) |     | (Good Access)  |     | (Core System)  |
|                |     |                |     |                |
+----------------+     +----------------+     +----------------+
                                                      |
                                                      |
                       +----------------+     +-------v--------+
                       |                |     |                |
                       |  EventBusGame  |<----| EconomicMetrics|
                       | (Communication) |     | (Analytics)    |
                       |                |     |                |
                       +----------------+     +----------------+
```

### System Relationships

The Market System interacts with several other systems:

- **Economic System**: Provides economic actors who participate in the market.
- **Governance System**: Provides laws that affect market operations (e.g., taxes).
- **Production System**: Supplies goods that enter the market.
- **Population System**: Provides consumers who purchase goods.

### Data Flow

```
+----------------+     +----------------+     +----------------+
|                |     |                |     |                |
|  Production    |---->|    Market      |---->|  Population    |
|  (Suppliers)   |     | (Trade Engine) |     |  (Consumers)   |
|                |     |                |     |                |
+----------------+     +----------------+     +----------------+
      |                       |                      |
      v                       v                      v
+----------------+     +----------------+     +----------------+
| Goods Produced |     | Transactions   |     | Goods Consumed |
| - resources    |---->| - money flow   |---->| - needs met    |
| - products     |     | - good transfer|     | - utility      |
+----------------+     +----------------+     +----------------+
```

---

## Key Subsystems

### Price Management

The price management subsystem handles the determination and updating of good prices based on market forces.

**Key Features**:
- Base prices loaded from configuration
- Dynamic price adjustments based on supply and demand
- Price elasticity varies by good category
- Price history tracking for trend analysis
- Price floor and ceiling enforcement (when laws are enacted)

**Implementation Status**:
- Base price loading is implemented via GoodsManager
- Dynamic pricing is planned but not yet implemented
- Price history tracking is planned but not yet implemented

### Trade Processing

The trade processing subsystem handles the collection, matching, and execution of trade orders.

**Key Features**:
- Collection of buy and sell orders from economic actors
- Randomized processing to prevent exploitation
- Transaction validation and execution
- Money and goods transfer between actors
- Tax calculation and collection
- Transaction recording for history and analytics

**Processing Flow**:
```
1. Clear previous turn's transactions
2. Gather market state (collect all buy/sell orders)
3. Randomize seller order
4. For each seller:
   a. Randomize buyer order
   b. For each buyer:
      i. Calculate affordable amount
      ii. Calculate base cost
      iii. Apply sales tax
      iv. Transfer money and goods
      v. Record transaction
5. Update market metrics
```

**Implementation Status**:
- Core trade processing is designed but not yet implemented
- Transaction data structures are defined
- Test cases for market mechanics exist

### Tax Integration

The tax integration subsystem handles the calculation, collection, and distribution of taxes on market transactions.

**Key Features**:
- Sales tax calculation based on current tax laws
- Tax collection during trade execution
- Tax distribution to demesne treasury
- Tax reporting and analytics

**Implementation Status**:
- Tax calculation is designed but not yet implemented
- Test cases for sales tax exist

### Market Analytics

The market analytics subsystem tracks, analyzes, and reports on market activity and economic health.

**Key Features**:
- Tracking of key economic indicators:
  - Average price level
  - Trade volume
  - Money velocity
  - Unemployment rate
  - Production index
  - Wealth distribution (Gini coefficient)
  - Market activity
- Historical trend tracking
- Threshold monitoring and alerts
- Economic reporting

**Implementation Status**:
- EconomicMetrics class is implemented with comprehensive metrics
- Historical tracking is implemented
- Threshold monitoring and alerts are implemented
- Economic reporting is implemented

---

## Data Structures

### DataGood

Represents a static configuration for a good in the economy (not a runtime instance).

**Properties**:
- `id: String` - Unique identifier for the good
- `f_name: String` - Display name for the good
- `base_price: float` - The base price of the good
- `category: String` - The category of the good (e.g., basic, luxury)
- `icon: String` - The icon for the good (e.g., emoji or string)

**Example**:
```gdscript
var good = DataGood.new("food", "Food", 10.0, "basic", "🌾")
```

**Implementation Status**:
- Fully implemented and used in the system

### DataMarketTransaction

Represents a completed market transaction.

**Properties**:
- `good: String` - Traded good identifier
- `amount: int` - Quantity traded
- `price: float` - Price per unit
- `buyer_name: String` - Name of buyer
- `seller_name: String` - Name of seller
- `tax_amount: float` - Tax applied to transaction

**Implementation Status**:
- Designed but not yet implemented

### DataTradeOrder

Represents a trade order in the market.

**Properties**:
- `amount: int` - Amount to trade
- `money_made: float` - Money earned from trades

**Implementation Status**:
- Designed but not yet implemented

---

## Communication Patterns

### EventBus Signals

The Market System communicates with other systems primarily through the EventBusGame autoload:

**Signals Emitted**:
- `trade_completed(transaction_data)` - Emitted when a trade is successfully completed
- `market_price_changed(good_id, old_price, new_price)` - Emitted when a good's price changes
- `market_activity_recorded(activity_data)` - Emitted when market state is gathered

**Signals Received**:
- `turn_started` - Triggers market state gathering
- `turn_completed` - Triggers market analytics updates
- `law_enacted` - Updates market rules based on new laws

### Direct API Calls

The Market System provides several public methods for other systems to interact with it:

**Key Methods**:
- `get_price(good_id)` - Returns the current price of a good
- `get_price_history(good_id, periods)` - Returns historical prices
- `execute_trade(buyer, seller, good_id, amount)` - Executes a trade between actors
- `get_market_metrics()` - Returns current economic metrics

### UI Update Mechanisms

The Market System provides data for UI updates through:

- Direct API calls from UI components
- EventBusUI signals for real-time updates
- Economic reports for detailed analysis

---

## Usage Examples

### Querying Prices

```gdscript
# Get all good prices
var prices = GoodsManager.get_good_prices()

# Get price for a specific good
var grain_price = prices["grain"]
```

### Executing Trades

```gdscript
# Future implementation (not yet available)
var transaction = market.execute_trade(buyer, seller, "grain", 10)
```

### Accessing Market Analytics

```gdscript
# Create metrics tracker
var metrics = EconomicMetrics.new()

# Connect to signals
metrics.metric_updated.connect(_on_metric_updated)
metrics.threshold_crossed.connect(_on_threshold_crossed)

# Update metrics
metrics.update_metrics(sim_state)

# Generate report
var report = metrics.generate_report()
```

---

## Implementation Status

The Market System is currently partially implemented, with the following components in place:

**Implemented**:
- GoodsManager for accessing good definitions
- DataGood class for representing goods
- EconomicMetrics for tracking economic indicators
- Basic test cases for market mechanics and sales tax

**Planned/In Progress**:
- Core Market class implementation
- Trade processing system
- Dynamic pricing based on supply and demand
- Transaction history tracking
- Market UI components

**Future Enhancements**:
- Multiple market types (local, regional)
- Market regulations and restrictions
- Trade route implementation
- Market manipulation detection
- Advanced economic indicators

---

## Developer Notes

### Common Pitfalls

- **Transaction Validation**: Always validate transactions before execution to prevent economic exploits
- **Price Calculation**: Ensure price calculations handle edge cases (zero supply, infinite demand)
- **Tax Calculation**: Round tax amounts consistently to prevent floating-point errors
- **Signal Connections**: Properly disconnect signals when objects are freed

### Performance Considerations

- **Trade Processing**: Processing large numbers of trades can be CPU-intensive
- **History Tracking**: Limit history size to prevent memory bloat
- **Market Updates**: Consider batching market updates to reduce signal spam
- **Economic Calculations**: Cache complex economic calculations where possible

### Testing Approach

- **Unit Tests**: Test individual components in isolation
- **Integration Tests**: Test market interactions with other systems
- **Economic Validation**: Verify economic rules are maintained
- **Edge Cases**: Test with extreme market conditions
- **Performance Testing**: Test with large numbers of actors and transactions

---

## Documentation Maintenance

When updating this documentation as the Market System evolves, follow these guidelines to ensure consistency and completeness:

### Adding New Features

1. **Update the Implementation Status**: When a new feature is implemented, update the "Implementation Status" section to move it from "Planned/In Progress" to "Implemented".

2. **Add Feature Details**: Add detailed information about the new feature in the relevant subsystem section, including:
   - Feature description and purpose
   - Key components and data structures
   - Integration with other systems
   - Usage examples with code snippets

3. **Update Communication Patterns**: If the new feature introduces new signals or API methods, add them to the "Communication Patterns" section.

4. **Add Usage Examples**: Provide clear, concise examples of how to use the new feature in the "Usage Examples" section.

5. **Update References**: If the new feature is documented in other files, add references to those files in the "References" section.

### Documenting API Changes

1. **Deprecation Notices**: When deprecating an API method or signal, clearly mark it as deprecated and provide the recommended alternative.

2. **Version Information**: Include version information for new API methods or signals to help developers understand when they were introduced.

3. **Breaking Changes**: Clearly document any breaking changes to the API and provide migration guidance.

### Documentation Style Guidelines

1. **Consistency**: Maintain consistent formatting and structure with the rest of the documentation.

2. **Code Examples**: Always include practical code examples for new features or API methods.

3. **ASCII Diagrams**: Use ASCII diagrams to illustrate complex concepts or workflows.

4. **Last Updated**: Update the "Last Updated" date at the top of the document whenever significant changes are made.

## References

- [Economic System](../game_bible/01_economic_system.md) - Game bible entry on the economic system
- [System Interactions](systems_overview.md) - Overview of how the Market System interacts with other systems
- [Market System Design](../designs/market_system_design.md) - Detailed design document
- [Market System Implementation Guide](../designs/market_system_implementation_guide.md) - Implementation phases and guidelines
