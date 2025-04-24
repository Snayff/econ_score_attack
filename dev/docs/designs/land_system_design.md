# Land System Design

## Overview
The land system introduces spatial reality to the economic simulation, where buildings and resources exist in physical space. This document outlines the design of a grid-based land system that supports resource generation, environmental effects, and economic interactions.

## Core Components

### 1. Land Parcel Data Structure
- Coordinates (x, y) in 2D grid
- Terrain type (forest, plains, mountains)
- Resources (discovered and undiscovered)
- Building placement
- Land improvements (roads, irrigation)
- Environmental properties (fertility, pollution)
- Movement costs

### 2. Resource System
- Resource types with varying discovery chances
- Terrain-specific generation rates
- Seasonal modifiers
- Resource depletion and regeneration
- Discovery through surveying

### 3. Environmental System
- Seasonal changes affecting production
- Natural disasters with spreading effects
- Pollution tracking and spread
- Environmental effects on production

### 4. Movement and Pathfinding
- A* pathfinding implementation
- Terrain-based movement costs
- Road improvements reducing costs
- Support for diagonal movement

## Data Structure

### Land Parcel
```gdscript
class_name DataLandParcel
var x: int
var y: int
var terrain_type: String
var resources: Dictionary  # resource_id -> {amount: float, discovered: bool}
var building_id: String
var improvements: Dictionary  # improvement_id -> level
var fertility: float
var resource_generation_rate: float
var pollution_level: float
var is_surveyed: bool
```

### Configuration (land_config.json)
```json
{
    "terrain_types": {
        "plains": {
            "base_fertility": 1.0,
            "movement_cost": 1.0,
            "resource_modifiers": {
                "wood": 0.5,
                "stone": 0.3
            }
        }
    },
    "improvements": {
        "road": {
            "movement_cost_multiplier": 0.75,
            "max_level": 3
        }
    }
}
```

## Systems Integration

### Event Bus Signals
- resource_discovered(x, y, resource_id, amount)
- land_improved(x, y, improvement_id, level)
- environmental_effect_occurred(x, y, effect_id)
- natural_disaster_occurred(disaster_type, affected_coordinates)
- pollution_updated(x, y, new_level)

### Economic Integration
- Resource availability tied to location
- Transport costs affecting trade
- Land improvement costs and benefits
- Environmental impacts on production

## Component Architecture

### LandParcelComponent
- Handles parcel behaviour and logic
- Manages resource discovery
- Processes environmental effects
- Updates parcel properties

### ResourceGenerator
- Generates resources based on terrain
- Applies seasonal modifiers
- Handles resource discovery
- Manages resource depletion

### EnvironmentalSystem
- Manages seasonal changes
- Triggers natural disasters
- Handles pollution spread
- Applies environmental effects

### PathfindingSystem
- Implements A* pathfinding
- Calculates movement costs
- Handles road improvements
- Supports optimal path finding

## Performance Considerations

### Grid Operations
- Efficient neighbour calculations
- Optimized pathfinding
- Cached movement costs
- Batch updates for environmental effects

### Resource Management
- Lazy resource generation
- Efficient resource discovery
- Optimized pollution spread calculations
- Cached terrain modifiers

## Future Extensions

### Planned Features
- Advanced terrain types
- Complex resource interactions
- Weather systems
- Trade route optimization
- Advanced building placement rules

### Potential Improvements
- Multi-threaded pathfinding
- Dynamic resource generation
- Advanced disaster systems
- Complex economic interactions 