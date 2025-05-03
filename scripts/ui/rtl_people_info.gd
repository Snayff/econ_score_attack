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
@onready var header_container: VBoxContainer = $MarginContainer/VBoxContainer/HeaderContainer

func _ready() -> void:
	EventBusGame.turn_complete.connect(update_info)

	# Find the Sim node if not provided
	if not sim:
		sim = get_node("/root/Main/Sim")

	if sim:
		sim.sim_initialized.connect(update_info)

	update_info()


#endregion


#region PUBLIC FUNCTIONS

## Updates the displayed information
func update_info() -> void:
	# Clear existing content
	for child in people_container.get_children():
		child.queue_free()
	for child in header_container.get_children():
		child.queue_free()

	if not sim:
		Logger.log_validation("Sim reference", false, "sim is null", "PeopleInfo")
		_add_error_message("No simulation data available (sim is null)")
		return

	if not sim.demesne:
		Logger.log_validation("Demesne reference", false, "sim.demesne is null", "PeopleInfo")
		_add_error_message("No simulation data available (demesne is null)")
		return

	# Create the table header
	var header = _create_person_row(
		["Name", "Job", "Health", "Happiness", "Stockpile"],
		true
	)
	header_container.add_child(header)

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

	# Create the main row with columns
	var row = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(row)

	# Name column
	var name_label = Label.new()
	name_label.text = person.f_name
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(name_label)

	# Job column
	var job_label = Label.new()
	job_label.text = person.is_alive if person.job.is_empty() else person.job
	job_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	job_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(job_label)

	# Health column
	var health_label = Label.new()
	health_label.text = str(person.health) + "❤️" if person.is_alive else ""
	health_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	health_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(health_label)

	# Happiness column
	var happiness_label = Label.new()
	happiness_label.text = str(person.happiness) + "🙂" if person.is_alive else ""
	happiness_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	happiness_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(happiness_label)

	# Stockpile column
	var stockpile_container = VBoxContainer.new()
	stockpile_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(stockpile_container)

	if person.is_alive:
		for good in person.stockpile:
			var icon = Library.get_good_icon(good)
			var good_label = Label.new()
			good_label.text = str(icon, " ", good, ": ", person.stockpile[good])
			good_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			stockpile_container.add_child(good_label)

	return panel


#endregion
