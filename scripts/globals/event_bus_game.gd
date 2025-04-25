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

#endregion 