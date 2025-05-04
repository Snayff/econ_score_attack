## Main
## Entry point for game initialisation. Ensures all core systems are initialised in the correct order before gameplay or UI is shown.
## Example usage:
##   Attach to the root Main node in main.tscn.
extends Node

#region CONSTANTS
#endregion

#region SIGNALS
#endregion

#region ON READY
func _ready() -> void:
	# Initialise the world grid before anything else
	World.initialise_from_config(Library.get_config("land"))
	# Set up SurveyManager's parcel accessor to decouple it from the World global
	SurveyManager.set_parcel_accessor(World.get_parcel)
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
#endregion

#region PRIVATE FUNCTIONS
#endregion
