# Land Aspects System Design

## Overview
The Land Aspects system represents natural features, resources, and characteristics of land parcels within the demesne. This system replaces the previous resource-based approach with a more nuanced and flexible aspect-based system.

## Core Concepts

### Land Aspects
- Represent natural features or characteristics of a land parcel
- Can be finite (with a specific amount) or infinite
- Must be discovered through surveying
- Tied to specific extraction methods (buildings)
- Generated during world creation only

### Surveying
- Required to discover aspects in a parcel
- Reveals all aspects in a parcel when completed
- Can only be done once per parcel
- Progress is visible to the player

## Data Structures

### Aspect Data
```gdscript
{
    "aspect_id": String,       # Unique identifier
    "f_name": String,         # Display name
    "description": String,    # Descriptive text
    "generation_chance": float, # 0-1 chance of generation
    "max_instances": int,     # Maximum instances per parcel
    "extraction_methods": Array[Dictionary] # List of extraction methods
}
```

### Extraction Method
```gdscript
{
    "building": String,       # Required building type
    "is_finite": bool,       # Whether resource is finite
    "min_amount": int,       # Minimum amount (if finite)
    "max_amount": int,       # Maximum amount (if finite)
    "extracted_good": String # Type of good produced
}
```

### Parcel Aspect Storage
```gdscript
{
    "aspect_id": {
        "discovered": bool,   # Whether aspect has been discovered
        "amount": int        # Amount for finite aspects (0 for infinite)
    }
}
```

## Components

### AspectManager
- Handles aspect generation during world creation
- Manages aspect discovery through surveying
- Emits signals for UI updates
- Logs all aspect-related events

### UI Components
- TileInfoPanel: Displays discovered aspects and their details
- SurveyPanel: Shows survey progress and controls
- AspectDetailsPanel: Shows detailed aspect information

## Events and Signals

### Signals
- `aspect_discovered(x: int, y: int, aspect_id: String, aspect_data: Dictionary)`
- `survey_completed(x: int, y: int)`

### Logged Events
- `parcel_generated`: When a new parcel is created with aspects
- `aspect_discovered`: When an aspect is revealed through surveying
- `survey_started`: When a survey begins
- `survey_completed`: When a survey finishes

## Testing Strategy

### Unit Tests
- Aspect generation with controlled RNG
- Aspect discovery mechanics
- Data validation
- Event logging

### Integration Tests
- UI updates on aspect discovery
- Survey system integration
- Building placement requirements

## Error Handling
- Validate all aspect data on load
- Handle missing or invalid data gracefully
- Log errors with detailed context
- Provide user feedback for invalid operations

## Performance Considerations
- Aspect generation only occurs during world creation
- Minimal runtime overhead during gameplay
- Efficient storage of aspect data
- Optimized UI updates

## Future Considerations
- Support for dynamic aspect modification through events
- Additional extraction methods per aspect
- Aspect interactions and combinations
- Seasonal effects on aspects