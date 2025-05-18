## Main
## Entry point for game initialisation. Ensures all core systems are initialised in the correct order before gameplay or UI is shown.
## Example usage:
##   Attach to the root Main node in main.tscn.
extends Node

#region CONSTANTS
const GOOD_UTILITY_DEBUG_PANEL_SCENE: String = "res://feature/economic_actor/ui/good_utility_debug_panel.tscn"
const GOOD_UTILITY_DEBUG_PANEL_NODE_NAME: String = "GoodUtilityDebugPanel"
#endregion

#region SIGNALS
#endregion

#region ON READY
func _ready() -> void:
	# Initialise the world grid before anything else
	World.initialise_from_config(Library.get_land_data())
	# Set up AspectManager's aspect loader to decouple it from the Library global
	AspectManager.set_aspect_loader(Library.get_land_aspects)
	# Set up LandManager's event buses to decouple it from EventBusGame and EventBusUI globals
	var get_event_bus_game = func(): return EventBusGame
	var get_event_bus_ui = func(): return EventBusUI
	LandManager.set_event_buses(get_event_bus_game, get_event_bus_ui)
	# Additional initialisation (demesne, sim, etc.) can be added here
	# The UI will listen for World.world_grid_updated before showing the grid
#endregion

#region EXPORTS
#endregion

#region PUBLIC FUNCTIONS
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		# Backtick (`) key is keycode 96 on most keyboards
		if event.keycode == 96:
			_toggle_good_utility_debug_panel()
#endregion

#region PRIVATE FUNCTIONS
func _toggle_good_utility_debug_panel() -> void:
	var panel = get_node_or_null(GOOD_UTILITY_DEBUG_PANEL_NODE_NAME)
	if panel:
		panel.queue_free()
	else:
		var panel_scene = load(GOOD_UTILITY_DEBUG_PANEL_SCENE)
		var instance = panel_scene.instantiate()
		instance.name = GOOD_UTILITY_DEBUG_PANEL_NODE_NAME
		add_child(instance)
#endregion
