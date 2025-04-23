extends Control

## Displays information about people in the simulation.
## Shows their health, happiness, and stockpile in a scrollable panel.
##
## Example usage:
## var people_info = preload("res://scenes/ui/people_info.tscn").instantiate()


#region EXPORTS

@export var sim: Sim

#endregion


#region CONSTANTS


#endregion


#region SIGNALS


#endregion


#region ON READY

@onready var people_container: VBoxContainer = %PeopleContainer

func _ready() -> void:
	Logger.debug("PeopleInfo: _ready called", "PeopleInfo")
	EventBus.turn_complete.connect(update_info)

	# Find the Sim node if not provided
	if not sim:
		sim = get_node("/root/Main/Sim")
		Logger.debug("PeopleInfo: Found Sim node: " + str(sim), "PeopleInfo")

	if sim:
		sim.sim_initialized.connect(update_info)

	update_info()


#endregion


#region PUBLIC FUNCTIONS

## Updates the displayed information
func update_info() -> void:
	Logger.debug("PeopleInfo: update_info called", "PeopleInfo")

	# Clear existing people info
	for child in people_container.get_children():
		child.queue_free()

	if not sim:
		Logger.error("PeopleInfo: sim is null", "PeopleInfo")
		_add_error_message("No simulation data available (sim is null)")
		return

	if not sim.demesne:
		Logger.error("PeopleInfo: sim.demesne is null", "PeopleInfo")
		_add_error_message("No simulation data available (demesne is null)")
		return

	# Create the table header
	var header = _create_person_row(
		["Name", "Job", "Health", "Happiness", "Stockpile"],
		true
	)
	people_container.add_child(header)

	# Add person rows
	for person in sim.demesne.get_people():
		var row = _create_person_panel(person)
		people_container.add_child(row)


#endregion


#region PRIVATE FUNCTIONS

func _add_error_message(message: String) -> void:
	var label = Label.new()
	label.text = message
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	people_container.add_child(label)


func _create_person_row(values: Array, is_header: bool = false) -> HBoxContainer:
	var row = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	for value in values:
		var label = Label.new()
		label.text = str(value)  # Convert value to string to ensure compatibility
		if is_header:
			label.add_theme_font_size_override("font_size", 16)
			label.add_theme_color_override("font_color", Color(0.7, 0.7, 1.0))
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row.add_child(label)

	return row


func _create_person_panel(person: Person) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var vbox = VBoxContainer.new()
	panel.add_child(vbox)

	# Add main info row
	var values = [
		person.f_name,
		person.is_alive if person.job.is_empty() else person.job,  # Use job if available, otherwise show alive status
		str(person.health) + "❤️" if person.is_alive else "",
		str(person.happiness) + "🙂" if person.is_alive else "",
		"" # Stockpile will be added below if person is alive
	]

	var main_row = _create_person_row(values)
	vbox.add_child(main_row)

	# Add stockpile info if person is alive
	if person.is_alive:
		var stockpile_container = VBoxContainer.new()
		stockpile_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.add_child(stockpile_container)

		for good in person.stockpile:
			var icon = Library.get_good_icon(good)
			var good_label = Label.new()
			good_label.text = str(icon, " ", good, ": ", person.stockpile[good])
			good_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			stockpile_container.add_child(good_label)

	return panel


#endregion
