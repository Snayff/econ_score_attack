## ViewPeople: People view using the standardised ABCView layout system.
## Displays information about people in the simulation using the modular UI layout.
## Usage:
##  Inherit from ABCView. Implement update_view() to populate the centre panel and any other regions as needed, using set_centre_content, set_top_bar_content, etc. Call refresh() to update the view; this will clear all regions, call update_view(), and automatically show a standard message in any empty region.
##  All user actions in sidebars and top bar should emit the standard signals (left_action_selected, top_tab_selected, right_info_requested) where appropriate.
##  Error and empty state handling is managed by the base class.
##
## See: dev/docs/docs/systems/ui.md
## Last Updated: 2025-05-13
##
extends ABCSubView

#region CONSTANTS
#endregion

#region SIGNALS
#endregion

#region EXPORTS
#endregion

#region ON READY

#endregion

#region VARS
var _sim: Sim
#endregion

#region PUBLIC FUNCTIONS
## Updates the displayed information in the centre panel.
## Populates the centre panel with a list of living people and their details.
## @return void
func update_view() -> void:
	super.update_view()

	if not _sim:
		set_centre_content([])
		return
	if not _sim.demesne:
		set_centre_content([])
		return
	var living_people = []
	for person in _sim.demesne.get_people():
		if person.is_alive:
			living_people.append(person)
	if living_people.is_empty():
		set_centre_content([])
		return
	var vbox = VBoxContainer.new()
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	# Header row
	var header = _create_person_row(["Name", "Job", "Health", "Happiness", "Stockpile"], true)
	vbox.add_child(header)
	# Person rows
	for person in living_people:
		var row = _create_person_panel(person)
		vbox.add_child(row)
	set_centre_content([vbox])


#endregion

#region PRIVATE FUNCTIONS
## Called when the node is added to the scene tree.  connects signals.
## @return void
func _ready() -> void:

	ReferenceRegistry.reference_registered.connect(_on_reference_registered)
	if EventBusGame.has_signal("turn_complete"):
		EventBusGame.turn_complete.connect(update_view)

	# Attempt to get sim if already registered
	var sim_ref = ReferenceRegistry.get_reference(Constants.ReferenceKey.SIM)
	if sim_ref:
		_set_sim(sim_ref)

	# N.B. Do not call update_view immediately; wait for sim_initialised or turn_complete


## Handles updates from the ReferenceRegistry.
## @param key (int): The reference key.
## @param value (Object): The reference value.
## @return void
func _on_reference_registered(key: int, value: Object) -> void:
	if key == Constants.ReferenceKey.SIM:
		_set_sim(value)

## Sets the sim reference and updates info.
## @param sim_ref (Sim): The simulation reference.
## @return void
func _set_sim(sim_ref: Sim) -> void:
	_sim = sim_ref
	update_view()

## Handles Population button press to refresh the people list.
## @return void
func _on_population_pressed() -> void:
	update_view()

## Creates a row of labels for person data.
## @param values (Array): The values to display in the row.
## @param is_header (bool): Whether this row is a header row.
## @return HBoxContainer: The constructed row container.
func _create_person_row(values: Array, is_header: bool = false) -> HBoxContainer:
	var row = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for value in values:
		var label = Label.new()
		label.text = str(value)
		if is_header:
			label.add_theme_font_size_override("font_size", 16)
			label.add_theme_color_override("font_color", Color(0.7, 0.7, 1.0))
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row.add_child(label)
	return row

## Creates a panel displaying a person's details.
## @param person (Person): The person whose details to display.
## @return PanelContainer: The constructed panel container.
func _create_person_panel(person: Person) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	var row = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(row)
	# Name
	var name_label = Label.new()
	name_label.text = person.f_name
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(name_label)
	# Job
	var job_label = Label.new()
	job_label.text = person.job if person.is_alive and not person.job.is_empty() else ""
	job_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	job_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(job_label)
	# Health
	var health_label = Label.new()
	health_label.text = str(person.health) + "❤️" if person.is_alive else ""
	health_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	health_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(health_label)
	# Happiness
	var happiness_label = Label.new()
	happiness_label.text = str(person.happiness) + "🙂" if person.is_alive else ""
	happiness_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	happiness_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(happiness_label)
	# Stockpile
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
