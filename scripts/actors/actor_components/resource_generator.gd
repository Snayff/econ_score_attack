## ResourceGenerator
## Component that handles resource generation and discovery for land parcels
## Example:
## ```gdscript
## var generator = ResourceGenerator.new()
## generator.initialise_resources(parcel)
## generator.update(delta)
## ```
class_name ResourceGenerator
extends Node


#region CONSTANTS
## Base chance for resource discovery when surveying
const BASE_DISCOVERY_CHANCE: float = 0.2

## Minimum time between resource updates in seconds
const MIN_UPDATE_INTERVAL: float = 1.0
#endregion


#region SIGNALS
## Emitted when a resource is discovered
signal resource_discovered(x: int, y: int, resource_id: String, amount: float)

## Emitted when resource amounts are updated
signal resources_updated(x: int, y: int, resources: Dictionary)
#endregion


#region ON READY
func _ready() -> void:
    # Connect to event bus for global events if needed
    pass
#endregion


#region EXPORTS
#endregion


#region PUBLIC FUNCTIONS
## Initialises resources for a land parcel based on terrain type
## @param parcel: The land parcel to initialise resources for
func initialise_resources(parcel: DataLandParcel) -> void:
    var land_config = Library.get_config("land")
    var terrain_type = land_config.terrain_types[parcel.terrain_type]
    var resource_modifiers = terrain_type.resource_modifiers

    # Load land aspects from Library (add a helper if needed)
    var land_aspects = Library.get_land_aspects()

    for aspect in land_aspects:
        for method in aspect.extraction_methods:
            var good = method.extracted_good
            if resource_modifiers.has(good) and resource_modifiers[good] > 0:
                # Use min_amount if finite, else default
                var amount = method.is_finite and method.min_amount or DataLandParcel.DEFAULT_RESOURCE_AMOUNT
                parcel.add_resource(good, amount, false)


## Attempts to discover resources in a parcel through surveying
## @param parcel: The land parcel to survey
## @return: Array of discovered resource IDs
func survey_parcel(parcel: DataLandParcel) -> Array[String]:
    if parcel.is_surveyed:
        return []
        
    parcel.is_surveyed = true
    var discovered_resources: Array[String] = []
    
    for resource_id in parcel.resources:
        if parcel.is_resource_discovered(resource_id):
            continue
            
        var discovery_chance = _calculate_discovery_chance(parcel, resource_id)
        if randf() < discovery_chance:
            parcel.discover_resource(resource_id)
            discovered_resources.append(resource_id)
            emit_signal("resource_discovered", parcel.x, parcel.y, resource_id, parcel.get_resource_amount(resource_id))
    
    return discovered_resources


## Updates resource generation for a parcel
## @param parcel: The land parcel to update
## @param delta: Time elapsed since last update
func update(parcel: DataLandParcel, delta: float) -> void:
    if delta < MIN_UPDATE_INTERVAL:
        return
        
    var initial_resources = parcel.resources.duplicate()
    parcel.update_resources(delta)
    
    # Only emit signal if resources have changed
    if initial_resources != parcel.resources:
        emit_signal("resources_updated", parcel.x, parcel.y, parcel.resources)
#endregion


#region PRIVATE FUNCTIONS
## Calculates the chance of discovering a specific resource
## @param parcel: The land parcel being surveyed
## @param resource_id: The resource being checked
## @return: Float between 0 and 1 representing discovery chance
func _calculate_discovery_chance(parcel: DataLandParcel, resource_id: String) -> float:
    var land_config = Library.get_config("land")
    var terrain_type = land_config.terrain_types[parcel.terrain_type]
    var terrain_modifier = terrain_type.resource_modifiers.get(resource_id, 0.0)
    
    # Higher terrain modifiers increase discovery chance
    return BASE_DISCOVERY_CHANCE * terrain_modifier
#endregion 