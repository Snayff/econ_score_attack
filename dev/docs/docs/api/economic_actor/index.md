# Economic Actor API

## Last Updated: 2025-06-25

## Overview
The Economic Actor API provides classes for representing and managing economic actors in the simulation. These actors can produce and consume goods, make economic decisions, and interact with the market system.

## Data Classes
- [DataPerson](./data_person.md) - Data class representing a person in the simulation
- [DataCulture](./data_culture.md) - Data class representing cultural characteristics
- [DataAncestry](./data_ancestry.md) - Data class representing hereditary characteristics
- [DataGood](./data_good.md) - Data class representing a good in the economy

## Core Classes
- [Person](./person.md) - Core class representing an individual actor in the simulation

## Components
- [ComponentConsumer](./component_consumer.md) - Component that handles consumption of goods
- [ComponentGoodUtility](./component_good_utility.md) - Component that calculates utility values for goods

## UI Components
- [SubViewPopulation](./sub_view_population.md) - UI component for displaying population information
- [SubViewDecisions](./sub_view_decisions.md) - UI component for displaying decision information

## Related Documentation
- [DataSubView](../shared/data_sub_view.md) - Data class for sub view metadata
- [Library](../shared/library.md) - Global singleton for managing data loading and access
- [Economic Actor Decision System](../systems/economic_actor_decision_system.md) - System documentation for economic actor decisions
