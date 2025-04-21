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

#endregion


#region FUNCS
func _ready() -> void:
	Logger.info("PeopleInfo: _ready called", "PeopleInfo")
	EventBus.turn_complete.connect(update_info)
	if sim:
		sim.sim_initialized.connect(update_info)
	update_info()

## Updates the displayed information
func update_info() -> void:
	Logger.info("PeopleInfo: update_info called", "PeopleInfo")

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
			info_text += str("  - ", good, ": ", person.stockpile[good], "\n")

		info_text += "\n"

	text = info_text
#endregion
