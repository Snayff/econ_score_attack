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
@onready var vbx_people_details: VBoxContainer = %VBxPeopleDetails
@onready var demo_person_details_entry: PanelContainer = %PersonDetailsEntry


#endregion

#region VARS
var _selected_person_id: int = -1
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
	var first_person_id: int = -1
	for i in range(living_people.size()):
		var person = living_people[i]
		var entry = _create_person_details_entry(person)
		var btn_select: Button = entry.get_node("BtnSelect")
		btn_select.pressed.connect(_on_person_entry_pressed.bind(person.id))
		vbx_people_details.add_child(entry)
		_add_to_clear_list(entry)
		if i == 0:
			first_person_id = person.id

	# Automatically select the first person if any
	if first_person_id != -1:
		_select_person(first_person_id)

	set_centre_content([])

#endregion

#region PRIVATE FUNCTIONS
func _ready() -> void:
	super._ready()

	_add_to_clear_list(demo_person_details_entry)

func _create_person_details_entry(person: Person) -> PanelContainer:
	var entry = SCENE_PERSON_DETAILS.instantiate()

	# name
	var lbl_name: Label = entry.get_node("VBoxContainer/HBoxContainer/LblName")
	lbl_name.text = person.f_name

	# job
	var lbl_job: Label = entry.get_node("VBoxContainer/HBoxContainer/LblJob")
	lbl_job.text = person.job

	# health
	var lbl_health: Label = entry.get_node("VBoxContainer/HBoxContainer/LblHealth")
	lbl_health.text = str(person.health, "❤️")

	# happiness
	var lbl_happiness: Label = entry.get_node("VBoxContainer/HBoxContainer/LblHappiness")
	lbl_happiness.text = str(person.happiness, "🙂")

	# stockpile
	# grain
	var lbl_grain: Label = entry.get_node("VBoxContainer/HBoxContainer/Stockpile/LblGrain")
	lbl_grain.text = str(person.stockpile["grain"], Library.get_good_icon("grain"))

	# money
	var lbl_money: Label = entry.get_node("VBoxContainer/HBoxContainer/Stockpile/LblMoney")
	lbl_money.text = str(person.stockpile["money"], Library.get_good_icon("money"))

	# water
	var lbl_water: Label = entry.get_node("VBoxContainer/HBoxContainer/Stockpile/LblWater")
	lbl_water.text = str(person.stockpile["water"], Library.get_good_icon("water"))


	return entry

func _on_person_entry_pressed(person_id: int) -> void:
	_select_person(person_id)

func _select_person(person_id: int) -> void:
	if _selected_person_id == person_id:
		return
	_selected_person_id = person_id
	# (Visual indication and sidebar update will be handled in a later step)

#endregion
