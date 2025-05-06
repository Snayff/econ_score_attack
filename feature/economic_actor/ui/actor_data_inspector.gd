## ActorDataInspector
## Minimal debug UI for inspecting loaded DataActor and DataCulture data.
## Example usage:
## Add this Control node to a debug UI scene to view loaded actors and their preferences.
extends Control

#region CONSTANTS
#endregion


#region SIGNALS
#endregion


#region ON READY
@onready var lbl_actor_list: Label = %lbl_actor_list
@onready var lbl_culture_list: Label = %lbl_culture_list
#endregion


#region EXPORTS
#endregion


#region VARS
var _actors: Array = []
var _cultures: Array = []
#endregion


#region PUBLIC FUNCTIONS
func _ready() -> void:
	# Assert referenced nodes exist
	assert(lbl_actor_list != null)
	assert(lbl_culture_list != null)

	_actors = Library.get_all_actors_data()
	_cultures = Library.get_all_cultures_data()
	_update_ui()

## Updates the UI with loaded data
func _update_ui() -> void:
	var actor_text := "Actors:\n"
	for actor in _actors:
		actor_text += "ID: %s, Culture: %s, Needs: %s\n" % [str(actor.id), actor.culture_id, str(actor.needs)]
	lbl_actor_list.text = actor_text

	var culture_text := "Cultures:\n"
	for culture in _cultures:
		culture_text += "ID: %s, Prefs: %s\n" % [culture.id, str(culture.base_preferences)]
	lbl_culture_list.text = culture_text
#endregion


#region PRIVATE FUNCTIONS
#endregion
