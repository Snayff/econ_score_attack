# Ancestry and Culture System Design

## Overview
The ancestry and culture system introduces biological and social diversity into the population simulation. This system separates inherent biological traits (ancestry) from learned behaviours and social structures (culture), allowing for rich interactions between different groups whilst maintaining clear mechanical distinctions.

## Core Concepts

### Ancestry
Represents the biological and physiological aspects of a person:
- Demographic characteristics (life expectancy, fertility)
- Resource consumption patterns
- Reproductive compatibility between ancestries
- Natural aptitudes for specific tasks

### Culture
Represents learned behaviours and social structures:
- Job and trade preferences
- Social interaction patterns
- Traditional occupations and skills
- Cultural practices and values

## Data Structures

### DataPersonAncestry
Core data class representing biological traits:
```gdscript
class_name DataPersonAncestry
extends Resource

var f_name: String
var description: String

# Demographic Properties
var base_life_expectancy: float
var fertility_modifier: float
var growth_rate_modifier: float
var pregnancy_compatibility: Dictionary[String, float]  # ancestry_id -> compatibility_percentage

# Economic Specialisation
var gathering_efficiency: Dictionary[String, float]  # resource_type -> efficiency_modifier
var crafting_specialties: Dictionary[String, float]  # craft_type -> skill_modifier

# Resource Needs
var base_resource_needs: Dictionary[String, float]  # resource_type -> base_consumption_rate
```

### DataPersonCulture
Core data class representing social and learned traits:
```gdscript
class_name DataPersonCulture
extends Resource

var f_name: String
var description: String
var traditional_practices: Array[String]

# Social Properties
var job_preferences: Dictionary[String, float]  # job_type -> preference_score
var social_interaction_rules: Dictionary[String, float]  # culture_id -> interaction_modifier
var traditional_occupations: Array[String]

# Economic Properties
var trade_preferences: Dictionary[String, float]  # resource_type -> trade_value_modifier
var craft_traditions: Array[String]  # Types of crafts this culture excels at
```

## Components

### PersonAncestryComponent
Handles ancestry-related calculations and state for an individual person:
- Resource consumption calculations
- Gathering and crafting efficiency modifiers
- Reproductive compatibility checks

### PersonCultureComponent
Manages cultural influences on an individual's behaviour:
- Job and trade preference calculations
- Social interaction modifiers
- Cultural practice effects

## Data Storage
All ancestry and culture definitions are stored in `data/ancestries.json`, containing:
- Ancestry definitions
- Culture definitions
- Cross-ancestry compatibility data
- Cultural interaction rules

## System Integration

### Economic System
- Resource consumption rates modified by ancestry
- Job efficiency affected by both ancestry and cultural factors
- Trade values influenced by cultural preferences

### Social System
- Inter-cultural social interaction modifiers
- Cultural job preferences affect career choices
- Traditional occupations influence job satisfaction

### Demographic System
- Birth rates affected by ancestry compatibility
- Life expectancy variations by ancestry
- Cultural influences on family formation

## Event Communication
The system communicates through the event bus system:
- Ancestry-based resource consumption modifications
- Cultural interaction events
- Reproductive compatibility checks
- Job preference modifications

## Error Handling
- Validation of ancestry and culture data on load
- Graceful fallbacks for missing or invalid data
- Clear error reporting through event bus

## Performance Considerations
- Caching of frequently accessed calculations
- Efficient storage of ancestry and culture references
- Batch processing for population-wide calculations