## ActorDataInspector
## Minimal debug UI for inspecting loaded DataPerson and DataCulture data.
## Example usage:
## Add this Control node to a debug UI scene to view loaded actors and their preferences.
# Requires Factory to be set as an autoload (singleton)
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
var _last_purchases: Dictionary = {}
#endregion


#region PUBLIC FUNCTIONS
func _ready() -> void:
	# Assert referenced nodes exist
	assert(lbl_actor_list != null)
	assert(lbl_culture_list != null)

	_actors = Factory.generate_starting_people()
	_cultures = Library.get_all_cultures_data()
	_update_ui()

## Updates the UI with loaded data
func _update_ui() -> void:
	var actor_text := "Actors:\n"
	for actor in _actors:
		actor_text += "ID: %s, Culture: %s, Needs: %s, Savings Rate: %.2f, Disposable Income: %.2f" % [str(actor.id), actor.culture_id, str(actor.needs), actor.savings_rate, actor.disposable_income]
		# Show last purchase if available
		if _last_purchases.has(actor.id):
			actor_text += ", Last Purchase: %s" % _last_purchases[actor.id]
		actor_text += "\n"
	lbl_actor_list.text = actor_text

	var culture_text := "Cultures:\n"
	for culture in _cultures:
		culture_text += "ID: %s, Prefs: %s\n" % [culture.id, str(culture.base_preferences)]
	lbl_culture_list.text = culture_text

## Call this to record a purchase for an actor (for debug display)
## @param actor_id: String, @param purchase: String
func record_purchase(actor_id: String, purchase: String) -> void:
	_last_purchases[actor_id] = purchase
#endregion


#region PRIVATE FUNCTIONS
#endregion
