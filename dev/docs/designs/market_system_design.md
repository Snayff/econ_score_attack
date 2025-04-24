# Market System Design

## Overview
The market system handles all market-related functionality at the demesne level, including trading, pricing, and tax collection. This design document outlines the structure and implementation of a modular market system.

## Core Components

### Market Class
The central class managing all market operations within a demesne.

#### Responsibilities
- Managing good prices
- Processing trades between actors
- Handling tax collection
- Recording market transactions
- Emitting market activity signals
- Logging market activity

#### Key Features
- Turn-based trade resolution
- Random order trade processing
- Tax law integration
- Transaction history tracking
- Market activity monitoring

### Data Classes

#### DataMarketTransaction
Represents a completed market transaction.

**Properties:**
- `good: String` - Traded good identifier
- `amount: int` - Quantity traded
- `price: float` - Price per unit
- `buyer_name: String` - Name of buyer
- `seller_name: String` - Name of seller
- `tax_amount: float` - Tax applied to transaction

#### DataTradeOrder
Represents a trade order in the market.

**Properties:**
- `amount: int` - Amount to trade
- `money_made: float` - Money earned from trades

## System Flow

### Trade Processing Flow
1. Clear previous turn's transactions
2. Gather market state
   - Collect sell orders
   - Collect buy orders
3. Record market activity
4. Process trades for each good
   - Randomize seller order
   - For each seller:
     - Randomize buyer order
     - Process trades until stock depleted or no buyers remain
5. Log trade results

### Trade Execution Flow
1. Calculate trade details
   - Determine affordable amount
   - Calculate base cost
   - Apply sales tax
2. Transfer money
   - Deduct from buyer
   - Add to seller
   - Collect tax for demesne
3. Transfer goods
4. Record transaction
5. Update trade records
6. Emit trade signals
7. Log trade details

## Integration Points

### Demesne Integration
- Market is initialized with a demesne reference
- Accesses demesne's people for trade processing
- Interacts with demesne's tax laws
- Contributes to demesne's resources through tax collection

### Economic Systems Integration
- Provides transaction data for economic metrics
- Supports economic validation
- Contributes to economic reporting

## Configuration

### Constants
- `MIN_TRANSACTION_AMOUNT: int` - Minimum allowed transaction size
- `MAX_TRANSACTIONS_PER_TURN: int` - Transaction history limit

### Signals
- `trade_completed` - Emitted on successful trade
- `market_activity_recorded` - Emitted when market state is gathered

## Error Handling
- Transaction validation
- Tax calculation safety
- Resource transfer verification
- Transaction limit enforcement

## Logging
- Market initialization
- Trade execution details
- Tax collection
- Market activity summary
- Final trade results

## Future Considerations
- Dynamic pricing based on supply/demand
- Multiple market types (local, regional)
- Market regulations and restrictions
- Trade route implementation
- Market manipulation detection
- Advanced economic indicators 