# Economic System

## Executive Summary
The Economic System is the central gameplay mechanic that simulates a realistic, closed-loop economy where all resources must be produced within the demesne. It encompasses currency management, market dynamics, banking, and trade systems that interact to create emergent economic behaviors. Players must master these systems to extract maximum personal wealth while maintaining economic stability.

**Key Features:**
- Fully simulated closed-loop economy with no external resources
- Dynamic pricing based on supply and demand
- Banking system with loans, interest rates, and financial institutions
- Market manipulation mechanics with consequences
- Multiple wealth extraction methods
- Detailed economic indicators and analysis tools

## Overview
The economic system forms the core of gameplay, implementing a closed-loop economy where all resources and goods must be produced within the demesne. No external resources can enter the system, creating a carefully balanced economic ecosystem.

## Key Concepts

### Closed-Loop Economy
A self-contained economic system where all resources must be produced within the demesne. No external resources can enter the system, creating a carefully balanced ecosystem where every economic decision has ripple effects throughout the entire economy.

### Supply and Demand
The fundamental market force that determines prices based on resource availability and population needs. When supply exceeds demand, prices fall; when demand exceeds supply, prices rise. Different goods have different elasticity, affecting how dramatically prices change in response to supply/demand imbalances.

### Market Equilibrium
The theoretical point where supply and demand are balanced, resulting in stable prices. Market equilibrium is constantly shifting due to production changes, population needs, and player interventions.

### Monetary Policy
The set of tools available to control currency value, including interest rates, money supply, and banking regulations. Effective monetary policy maintains currency stability while enabling economic growth.

### Wealth Extraction
The primary player goal - converting the demesne's economic activity into personal wealth. This can be accomplished through taxation, market manipulation, ownership of production, banking profits, and resource licensing.

### Economic Indicators
Metrics that measure economic health and activity, including GDP, employment rates, price indices, and market stability. These indicators help players understand the current state of their economy and predict future trends.

## Core Components

## System Architecture

### Class Diagram
```
+----------------+       +----------------+
|    Currency    |<----->|     Market     |
+----------------+       +----------------+
| - baseValue    |       | - goods        |
| - inflation    |       | - transactions |
| - stability    |       | - prices       |
+----------------+       +----------------+
        ^                        ^
        |                        |
        v                        v
+----------------+       +----------------+
|     Banking    |<----->|     Trade      |
+----------------+       +----------------+
| - loans        |       | - routes       |
| - accounts     |       | - logistics    |
| - interest     |       | - costs        |
+----------------+       +----------------+
```

### Flow Diagram: Closed-Loop Economy
```
                 +-------------+
                 | Resources   |
                 +-------------+
                        |
                        v
+-----------+    +-------------+    +-----------+
| Labor     |--->| Production  |--->| Goods     |
+-----------+    +-------------+    +-----------+
      ^                                   |
      |                                   v
      |           +-------------+    +-----------+
      +-----------| Consumption |<---| Market    |
                  +-------------+    +-----------+
                        |                 ^
                        v                 |
                  +-------------+         |
                  | Currency    |---------+
                  +-------------+
```

### Sequence Diagram: Market Transaction
```
+--------+          +--------+          +--------+
| Buyer  |          | Market |          | Seller |
+--------+          +--------+          +--------+
    |                   |                   |
    |---Request Buy---->|                   |
    |                   |---Check Price---->|
    |                   |<--Confirm Price---|
    |<--Price Quote-----|                   |
    |---Confirm Buy---->|                   |
    |                   |---Transfer Item-->|
    |                   |---Transfer Money->|
    |<--Transaction-----|                   |
    |  Confirmation     |                   |
    |                   |                   |
```

### State Diagram: Market Conditions
```
+-------------+         +-------------+         +-------------+
|   Stable    |-------->|  Volatile   |-------->|  Collapsed  |
+-------------+         +-------------+         +-------------+
      ^                       |                        |
      |                       |                        |
      +-----------------------+------------------------+
                 Recovery Measures
```

### Currency System
- **Base Currency**: Demesne-specific currency used for all transactions
- **Monetary Policy**:
  - Interest rate controls
  - Money supply management
  - Inflation/deflation mechanics
  - Currency stability indicators

### Market Mechanics
1. **Supply and Demand**
   - Dynamic pricing based on availability and need
   - Price elasticity varies by good type
   - Market equilibrium calculations
   - Supply/demand graphs available to player

2. **Market Manipulation**
   - Price controls (minimum/maximum prices)
   - Strategic resource hoarding
   - Market cornering mechanics
   - Trade regulation options
   - Consequences of market manipulation:
     - Black markets
     - Smuggling
     - Social unrest

3. **Banking System**
   - Loans and interest rates
   - Business investment options
   - Savings accounts for population
   - Bank stability mechanics
   - Risk of bank runs

### Trade System
1. **Internal Trade**
   - Between different sectors of the demesne
   - Transport costs and logistics
   - Trade route optimization
   - Market access limitations

2. **Supply Chain**
   - Resource flow tracking
   - Bottleneck identification
   - Disruption risks:
     - Natural disasters
     - Social unrest
     - Infrastructure failure
     - Resource depletion

## Economic Indicators
- GDP tracking
- Employment rates
- Wage levels
- Price indices
- Production output
- Consumer confidence
- Market stability index

## Player Tools
1. **Market Analysis**
   - Price history
   - Supply/demand charts
   - Economic forecasting
   - Risk assessment tools

2. **Policy Controls**
   - Interest rate adjustment
   - Price control implementation
   - Trade regulation
   - Banking policy
   - Currency management

3. **Wealth Extraction Methods**
   - Direct taxation
   - Market manipulation profits
   - State enterprise ownership
   - Banking system profits
   - Resource rights licensing

## System Interactions

### With Population System
- Wages affect happiness
- Employment levels impact stability
- Consumer purchasing power
- Skill levels affect productivity
- Population wealth distribution

### With Production System
- Resource availability affects prices
- Production efficiency impacts supply
- Technology level influences output
- Infrastructure affects trade costs

### With Governance System
- Economic policies and laws
- Corruption impacts efficiency
- Regulation enforcement costs
- Tax collection effectiveness

### With Environmental System
- Resource depletion effects
- Natural disaster impacts
- Seasonal production variations
- Environmental damage costs

### With Technology System
- Production efficiency improvements
- New resource utilization methods
- Banking system modernization
- Market analysis tools

## Failure States
1. **Economic Collapse**
   - Hyperinflation
   - Banking system failure
   - Market crash
   - Trade network breakdown

2. **Social Consequences**
   - Population unrest from economic hardship
   - Migration due to poor conditions
   - Business failures and unemployment
   - Loss of essential services

## Generated Ideas

### Banking System Mechanics
1. **Bank Creation and Management**
   - Players can establish multiple banks with different specializations
   - Banks require physical buildings and staff
   - Each bank can set its own interest rates and lending policies
   - Banks compete for population deposits
   - Bank reputation system affects deposit attraction

2. **Lending Mechanics**
   - Different loan types (business, personal, construction)
   - Collateral requirements based on loan size
   - Credit rating system for population and businesses
   - Loan default mechanics with property seizure
   - Debt restructuring options

3. **Market Manipulation Examples**
   - Create artificial shortages by buying up essential goods
   - Establish monopolies in key industries
   - Use insider knowledge from government position
   - Manipulate currency value through policy
   - Control resource access points

4. **Black Market Dynamics**
   - Emerges automatically when price controls are too restrictive
   - Operates in physical locations that must be discovered
   - Can be raided by authorities (player choice)
   - Provides alternative revenue streams
   - Increases unrest if too prevalent

5. **Currency Management Mini-game**
   - Visual interface for money supply control
   - Real-time inflation/deflation effects
   - Currency stability indicators
   - Foreign exchange mechanics (within demesne regions)
   - Emergency currency controls

6. **Trade Route Strategy**
   - Physical route planning on the map
   - Transport cost optimization
   - Route security considerations
   - Weather and seasonal effects
   - Infrastructure requirements

## UI/UX Ideas

### Interface Layout
```
+------------------------------------------+
|   Market Overview    |    Trade Panel    |
| [Price Trends ↑↓→]  | [Quick Trade]     |
| [Supply/Demand]     | [Recent Orders]   |
| [Market Health]     |                   |
+--------------------+-------------------+
|   Resource List    |    Details       |
| * Food      [###]  | Selected Item:   |
| * Wood      [###]  | [Price Chart]    |
| * Stone     [###]  | [Trade Options]  |
| * Iron      [###]  | [Market Status]  |
+------------------------------------------+
```

### 1. Market Overview Dashboard
- **Core Display (Always Available)**
  - Simple price trend arrows (↑↓→)
  - Basic supply/demand bars (0-100%)
  - Color-coded market health indicator (Red/Yellow/Green)
  - Three most important resources highlighted
  - Emergency alerts for critical shortages

- **Advanced Features (Technology Unlocks)**
  - Historical trend graphs
  - Market prediction bands
  - Supply chain visualisation
  - Risk assessment indicators
  - AI-driven market analysis

### 2. Banking Interface
- **Basic Banking (Initial Access)**
  - Personal wealth indicator (progress bar)
  - Simple loan status cards
  - Basic interest rate display
  - Bank stability rating (★★★☆☆)
  - Quick action radial menu

- **Advanced Banking (Law/Tech Dependent)**
  - Multi-bank comparison tools
  - Loan portfolio management
  - Risk assessment heat maps
  - Automated banking alerts
  - Market manipulation tools

### 3. Resource Trading
- **Quick Trade Interface**
  - Radial menu for resource selection
  - Slider bar for quantity
  - Single-button confirmation
  - Immediate price feedback
  - Simple profit/loss indicator

- **Advanced Trading (Unlockable)**
  - Order scheduling system
  - Price threshold automation
  - Market depth visualization
  - Trade route optimization
  - Strategic stockpile management

### 4. Control Scheme
- **Resource Management**
  - D-pad/Arrows: Navigate resources
  - A/Left-click: Select resource
  - Triggers/Scroll: Adjust quantities
  - X/Middle-click: Quick buy/sell
  - Y/Shift-click: Resource details

- **Market Analysis**
  - Shoulder buttons: Switch market views
  - Start: Economic overview
  - Select: Context help
  - B/Right-click: Back/Cancel
  - Stick/Mouse: Pan market view

### 5. Emergency Controls
- **Crisis Management**
  - One-button price controls
  - Quick market interventions
  - Emergency loan access
  - Instant trade restrictions
  - Crisis response options

### 6. Information Access
- **Basic Information**
  - Three key economic indicators
  - Simple status cards
  - Basic trend information
  - Essential market data
  - Quick help system

- **Advanced Information (Progressive)**
  - Detailed economic reports
  - Custom data dashboards
  - Predictive modeling
  - Cross-system impact analysis
  - Economic advisor AI

## Implementation Notes
- Follow color scheme (Gold/Yellow for economic system)
- Maintain consistent control mapping
- Ensure all features work with all input methods
- Progressive complexity through unlocks
- Clear visual feedback for all actions
- Regular validation of information density
- Accessibility options for all features 

## Implementation Priorities

This section outlines the recommended implementation order for the Economic System, focusing on establishing core functionality first before adding complexity.

### Phase 1: Foundation (MVP)
1. **Basic Resource System**
   - Simple resource types with fixed properties
   - Manual resource production and consumption
   - Static pricing without dynamic market forces
   - Basic currency system with simple transactions

2. **Simple Market**
   - Supply and demand calculations for essential goods
   - Basic price fluctuation based on availability
   - Manual trading interface for player transactions
   - Simple economic indicators (prices, supply levels)

3. **Core Player Tools**
   - Basic wealth extraction through direct taxation
   - Simple market analysis showing current prices
   - Basic policy controls for essential resources

### Phase 2: Core Economic Simulation
1. **Dynamic Market System**
   - Full supply and demand calculations for all goods
   - Price elasticity implementation
   - Market equilibrium mechanics
   - Black market emergence for price-controlled goods

2. **Banking System**
   - Basic loans and interest rates
   - Population savings accounts
   - Simple banking interface
   - Bank stability mechanics

3. **Trade System**
   - Internal trade between regions
   - Basic transport costs and logistics
   - Simple trade route optimization
   - Market access limitations

### Phase 3: Advanced Features
1. **Complex Market Manipulation**
   - Strategic resource hoarding mechanics
   - Market cornering implementation
   - Advanced trade regulations
   - Detailed consequences for manipulation

2. **Advanced Banking**
   - Multiple bank types and specializations
   - Complex loan types and conditions
   - Credit rating system
   - Bank runs and financial crises

3. **Economic Forecasting**
   - Predictive modeling tools
   - Risk assessment systems
   - Long-term trend analysis
   - Economic advisor AI

### Phase 4: Integration and Polish
1. **Cross-System Integration**
   - Deep integration with Population System
   - Environmental impact on economy
   - Technology advancement effects
   - Governance system economic policies

2. **UI/UX Refinement**
   - Advanced visualization tools
   - Streamlined trading interfaces
   - Crisis management controls
   - Comprehensive economic dashboards

## Performance Considerations

### Optimization Strategies
- **Market Simulation Optimization**
  - Use batch processing for price updates rather than updating each good individually
  - Implement price update frequency based on good importance (essential goods update more frequently)
  - Cache market state calculations and only recalculate when significant changes occur
  - Use spatial partitioning for regional markets to limit calculation scope

### Memory Management
- **Transaction History**
  - Implement rolling history with aggregation of older data
  - Store only summary data for transactions older than a configurable threshold
  - Use compressed data structures for historical price data
  - Implement memory pools for frequently created/destroyed transaction objects

### Scaling Considerations
- **Population Scaling**
  - Design market algorithms to handle 100-10,000 economic actors efficiently
  - Use representative sampling for very large populations
  - Implement level-of-detail simulation based on player focus
  - Group similar transactions to reduce individual calculations

### Data Structure Selection
- **Price Calculation**
  - Use spatial hash tables for regional price variations
  - Implement quad-tree structures for geographic price distribution
  - Use specialized containers optimized for frequent insertions/removals for active markets
  - Consider lock-free concurrent data structures for market operations

### Update Frequency
- **Tiered Update System**
  - Critical economic indicators: Every turn
  - Market prices for essential goods: Every 1-3 turns
  - Secondary market prices: Every 5-10 turns
  - Long-term economic trends: Every 20+ turns
  - Adjust dynamically based on market volatility

### Bottleneck Identification
- **Common Performance Issues**
  - Market price recalculation with many goods
  - Actor decision-making with large populations
  - Supply chain calculations with complex production networks
  - Banking system with many loans and accounts
  - Trade route optimization with many possible paths


## Actor Generation System

### Overview
The Actor Generation System is responsible for creating the population of economic actors (people) at game start. Rather than storing a static list of people in configuration files, actors are generated dynamically at runtime using a data-driven approach. This ensures flexibility, scalability, and alignment with the closed-loop economic simulation.

### How It Works
- **Data-Driven:**
  - Actor generation is based on external JSON configuration files: `people.json`, `cultures.json`, and `ancestries.json`.
  - `people.json` defines the number of starting people and allocation percentages for jobs, cultures, and ancestries.
  - `cultures.json` and `ancestries.json` define possible names, savings rate ranges, decision profiles, and consumption rules for each group.

- **Factory Pattern:**
  - Actors are generated at runtime using the global `Factory` singleton (`Factory.generate_starting_people()`).
  - For each actor:
    - A culture and ancestry are assigned based on allocation percentages.
    - Names, decision profiles, and consumption rules are merged from both culture and ancestry, then randomly selected or deduplicated as appropriate.
    - The savings rate is randomly chosen between the lowest minimum and highest maximum from both culture and ancestry.
    - Each actor is assigned a globally unique string ID using the `IDGenerator` singleton (e.g., `ACT_123e4567-e89b-12d3-a456-426614174000`).

- **No Static List:**
  - There is no longer a static list of actors in the configuration files. All actors are generated at runtime, ensuring the system can scale and adapt to changes in configuration.

### Key Data Flows
- **people.json:**
  - `starting_num_people`: Number of actors to generate.
  - `job_allocation`, `culture_allocation`, `ancestry_allocation`: Percentages for assigning jobs, cultures, and ancestries.
- **cultures.json & ancestries.json:**
  - Define possible names, savings rate ranges, decision profiles, and consumption rules for each group.
- **ID Generation:**
  - All actors receive a unique string ID via `IDGenerator.generate_id("ACT")`.

### How to Use
- To generate the starting population, call:
  ```gdscript
  var people = Factory.generate_starting_people()
  ```
- All references to actors should use their string-based unique IDs.
- UI and systems should not assume a fixed order or integer-based indexing for actors.

### Extending the System
- To add new fields or logic to actor generation, update the factory logic in `global/factory.gd`.
- To add new cultures or ancestries, update the relevant JSON files.
- If you add new systems that reference actors, always use string IDs and the factory pattern for consistency.

### Save/Load Considerations
- When implementing save/load functionality, ensure that actor string IDs are serialised and deserialised correctly.
- Actor generation should be deterministic if you require reproducibility for consistent gameplay experiences.

### Documentation
- This system replaces the previous approach of loading a static list of actors from configuration files.
- All relevant UI and systems have been updated to use the new approach.

## Last Updated
2024-06-09
