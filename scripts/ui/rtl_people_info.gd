## PeopleInfo
## Displays information about people in the simulation
## Shows their health, happiness, and stockpile
#@icon("")
class_name RTLPeopleInfo
extends RichTextLabel


#region EXPORTS
@export var sim: Sim
#endregion


#region VARS
var goods_config: Dictionary
#endregion


#region FUNCS
func _ready() -> void:
	Logger.debug("PeopleInfo: _ready called", "PeopleInfo")
	EventBus.turn_complete.connect(update_info)
	if sim:
		sim.sim_initialized.connect(update_info)
	_load_goods_config()
	update_info()

func _load_goods_config() -> void:
	var config_file = FileAccess.open("res://data/goods_config.json", FileAccess.READ)
	if config_file:
		var json = JSON.parse_string(config_file.get_as_text())
		goods_config = json.get("goods", {})
	else:
		Logger.error("Failed to load goods config", "PeopleInfo")

## Updates the displayed information
func update_info() -> void:
	Logger.debug("PeopleInfo: update_info called", "PeopleInfo")

	if not sim:
		Logger.error("PeopleInfo: sim is null", "PeopleInfo")
		text = "No simulation data available (sim is null)"
		return

	if not sim.demesne:
		Logger.error("PeopleInfo: sim.demesne is null", "PeopleInfo")
		text = "No simulation data available (demesne is null)"
		return

	var info_text: String = "[b]People Information[/b]\n\n"

	for person in sim.demesne.get_people():
		if not person.is_alive:
			info_text += str(person.f_name, " is dead.\n")
			continue

		info_text += str(
			"[b]", person.f_name, "[/b] (", person.job, ")\n",
			"Health: ", person.health, "❤️  Happiness: ", person.happiness, "🙂\n",
			"Stockpile:\n"
		)

		for good in person.stockpile:
			var icon = Library.get_good_icon(good)
			info_text += str("  - ", icon, " ", good, ": ", person.stockpile[good], "\n")

		info_text += "\n"

	text = info_text
#endregion
