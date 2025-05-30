## Global event bus for game-related signals
## Handles communication between unrelated game systems
extends Node

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

## Emitted when a land aspect is discovered
@warning_ignore("unused_signal")
signal aspect_discovered(x: int, y: int, aspect_id: String, aspect_data: Dictionary)

## Emitted when a survey is completed, revealing all aspects
@warning_ignore("unused_signal")
signal survey_completed(x: int, y: int, discovered_aspects: Array)

## Emitted when a survey is started
@warning_ignore("unused_signal")
signal survey_started(x: int, y: int)

## Emitted when survey progress is updated
@warning_ignore("unused_signal")
signal survey_progress_updated(x: int, y: int, progress: float)

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

## Emitted when a path is found between two points
@warning_ignore("unused_signal")
signal path_found(demesne_id: String, start: Vector2i, end: Vector2i, path: Array[Vector2i])

## Emitted when path finding fails
@warning_ignore("unused_signal")
signal path_failed(demesne_id: String, start: Vector2i, end: Vector2i, reason: String)

## Emitted when a road improvement is added or upgraded
@warning_ignore("unused_signal")
signal road_improved(demesne_id: String, x: int, y: int, level: int)

## Emitted when movement costs are updated due to improvements
@warning_ignore("unused_signal")
signal movement_costs_updated(demesne_id: String, affected_coordinates: Array[Vector2i])

## Emitted when parcel data is requested
@warning_ignore("unused_signal")
signal request_parcel_data(demesne_id: String, x: int, y: int)

## Emitted when a parcel improvement is requested
@warning_ignore("unused_signal")
signal request_improvement(x: int, y: int, improvement_id: String)

## Emitted when a parcel survey is requested
@warning_ignore("unused_signal")
signal request_survey(x: int, y: int)

## Emitted when a building placement is requested
@warning_ignore("unused_signal")
signal request_build(x: int, y: int, building_id: String)

## Emitted when the land grid is updated (e.g., after surveying, building, etc.)
@warning_ignore("unused_signal")
signal land_grid_updated()

#endregion
