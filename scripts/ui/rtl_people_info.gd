## PeopleInfo
## Displays information about people in the simulation
## Shows their health, happiness, and stockpile in a scrollable center panel
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
	Logger.debug("PeopleInfo: _ready called", "PeopleInfo")
	EventBus.turn_complete.connect(update_info)

	# Find the Sim node if not provided
	if not sim:
		sim = get_node("/root/Main/Sim")
		Logger.debug("PeopleInfo: Found Sim node: " + str(sim), "PeopleInfo")

	if sim:
		sim.sim_initialized.connect(update_info)

	# Set up the UI
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_TOP
	fit_content = true
	scroll_following = true

	update_info()

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
	info_text += "[table=5]\n"
	info_text += "[cell][b]Name[/b][/cell][cell][b]Job[/b][/cell][cell][b]Health[/b][/cell][cell][b]Happiness[/b][/cell][cell][b]Stockpile[/b][/cell]\n"

	for person in sim.demesne.get_people():
		if not person.is_alive:
			info_text += "[cell]" + person.f_name + "[/cell][cell]Dead[/cell][cell][/cell][cell][/cell][cell][/cell]\n"
			continue

		var stockpile_text: String = ""
		for good in person.stockpile:
			var icon = Library.get_good_icon(good)
			stockpile_text += str(icon, " ", good, ": ", person.stockpile[good], "\n")

		info_text += "[cell]" + person.f_name + "[/cell]" + \
			"[cell]" + person.job + "[/cell]" + \
			"[cell]" + str(person.health) + "❤️[/cell]" + \
			"[cell]" + str(person.happiness) + "🙂[/cell]" + \
			"[cell]" + stockpile_text + "[/cell]\n"

	info_text += "[/table]"
	text = info_text
#endregion
