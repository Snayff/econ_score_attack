## Global event bus for game-related signals
## Handles communication between unrelated game systems
extends Node

const EnvironmentalSystem = preload("../core/environmental_system.gd")

#region SIGNALS

## Emitted when a turn is completed
@warning_ignore("unused_signal")
signal turn_complete

## Emitted when an economic invariant is violated
@warning_ignore("unused_signal")
signal economic_error(invariant_name: String, details: String)

## Emitted when an economic threshold is crossed
@warning_ignore("unused_signal")
signal economic_alert(metric_name: String, threshold: float, current_value: float)

## Emitted when a resource is discovered in a land parcel
@warning_ignore("unused_signal")
signal resource_discovered(x: int, y: int, resource_id: String, amount: float)

## Emitted when resource amounts are updated in a land parcel
@warning_ignore("unused_signal")
signal resources_updated(x: int, y: int, resources: Dictionary)

## Emitted when a parcel is surveyed
@warning_ignore("unused_signal")
signal parcel_surveyed(x: int, y: int, discovered_resources: Array[String])

## Emitted when a season changes
@warning_ignore("unused_signal")
signal season_changed(new_season: EnvironmentalSystem.Season)

## Emitted when a natural disaster occurs
@warning_ignore("unused_signal")
signal disaster_occurred(disaster_type: EnvironmentalSystem.DisasterType, origin: Vector2i, affected_coords: Array[Vector2i])

## Emitted when pollution levels are updated
@warning_ignore("unused_signal")
signal pollution_updated(coords: Vector2i, new_level: float)

## Emitted when an environmental effect is applied
@warning_ignore("unused_signal")
signal effect_applied(effect_id: String, coords: Vector2i, duration: float)

#endregion 