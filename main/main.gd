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
	# Additional initialisation (demesne, sim, etc.) can be added here
	# The UI will listen for World.world_grid_updated before showing the grid
#endregion

#region EXPORTS
#endregion

#region PUBLIC FUNCTIONS
#endregion

#region PRIVATE FUNCTIONS
#endregion 