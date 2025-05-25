## SubViewPopulation: People view using the standardised ABCView layout system.
## Displays information about people in the simulation using the modular UI layout.
## Usage:
##  Inherit from ABCView. Implement update_view() to populate the centre panel and any other regions as needed, using set_centre_content, set_top_bar_content, etc. Call refresh() to update the view; this will clear all regions, call update_view(), and automatically show a standard message in any empty region.
##  All user actions in sidebars and top bar should emit the standard signals (left_action_selected, top_tab_selected, right_info_requested) where appropriate.
##  Error and empty state handling is managed by the base class.
##
## See: dev/docs/docs/systems/ui.md
## Last Updated: 2025-05-13
##
class_name  SubViewPopulation
extends ABCSubView

#region CONSTANTS
const SCENE_PERSON_DETAILS: PackedScene = preload("res://feature/economic_actor/ui/sub_view/population/person_details_entry.tscn")
#endregion

#region SIGNALS
#endregion

#region EXPORTS
#endregion

#region ON READY
@onready var v_bx_people_details: VBoxContainer = %VBxPeopleDetails

#endregion

#region VARS
## the person details entry used when creating the scene in the editor.
## to be deleted on game start.
@onready var demo_person_details_entry: PanelContainer = %PersonDetailsEntry

#endregion

#region PUBLIC FUNCTIONS
## Updates the displayed information in the centre panel.
## Populates the centre panel with a list of living people and their details.
## @return void
func update_view() -> void:
	super.update_view()

	# check we have sim ref
	if not _sim:
		set_centre_content([])
		return
	if not _sim.demesne:
		set_centre_content([])
		return

	# get living people to show
	var living_people: Array[Person] = []
	for person in _sim.demesne.get_people():
		if person.is_alive:
			living_people.append(person)
	if living_people.is_empty():
		set_centre_content([])
		return


	# Person rows
	for person in living_people:
		var entry = _create_person_details_entry(person)
	set_centre_content([])


#endregion

#region PRIVATE FUNCTIONS
func _ready() -> void:
	super._ready()

	#################
	# TODO - remove
	# DEBUG
	var timer: Timer = Timer.new()
	add_child(timer)
	timer.start(2)
	timer.timeout.connect(update_view)
	###############

	# clear down the demo scenes
	# demo_person_details_entry.queue_free()  # FIXME: errors as null
	pass

func _create_person_details_entry(person: Person) -> PanelContainer:
	var entry = SCENE_PERSON_DETAILS.instantiate()

	# refs
	var lbl_name: Label = entry.get_node("VBoxContainer/HBoxContainer/LblName")
	assert(lbl_name != null, "lbl_name node not found in panel instance!")

	# add info from person


	return entry


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
