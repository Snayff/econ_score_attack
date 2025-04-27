## A view that displays and manages the land grid system
class_name ViewLand
extends Control


#region CONSTANTS

#endregion


#region SIGNALS

#endregion


#region EXPORTS

@export var sim: Node

#endregion


#region ON READY

@onready var _land_grid_view: LandGridView = $MarginContainer/VBoxContainer/LandGridView

#endregion


#region PUBLIC FUNCTIONS

func _ready() -> void:
	assert(_land_grid_view != null, "Land grid view not found")
	assert(sim != null, "Sim node not set")

	# Connect to relevant signals
	EventBusGame.resource_discovered.connect(_on_resource_discovered)
	EventBusGame.resources_updated.connect(_on_resources_updated)
	EventBusGame.parcel_surveyed.connect(_on_parcel_surveyed)
	EventBusGame.pollution_updated.connect(_on_pollution_updated)

#endregion


#region PRIVATE FUNCTIONS

func _on_resource_discovered(x: int, y: int, resource_id: String, amount: float) -> void:
	EventBusUI.show_notification.emit("Discovered %s in parcel (%d, %d)" % [resource_id, x, y], "success")


func _on_resources_updated(x: int, y: int, resources: Dictionary) -> void:
	# Update the grid view when resources change
	EventBusGame.request_parcel_data.emit(x, y)


func _on_parcel_surveyed(x: int, y: int, discovered_resources: Array[String]) -> void:
	if discovered_resources.is_empty():
		EventBusUI.show_notification.emit("No resources found in parcel (%d, %d)" % [x, y], "info")
	else:
		var resources_text := ", ".join(discovered_resources)
		EventBusUI.show_notification.emit("Survey complete! Found: %s" % resources_text, "success")


func _on_pollution_updated(coords: Vector2i, new_level: float) -> void:
	if new_level > 0.5:
		EventBusUI.show_notification.emit("High pollution in parcel (%d, %d)" % [coords.x, coords.y], "warning")
	EventBusGame.request_parcel_data.emit(coords.x, coords.y)

#endregion
