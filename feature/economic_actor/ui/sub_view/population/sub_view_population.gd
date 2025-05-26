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
var _people_list: Array = []
var _person_entry_nodes: Array = []
var _selected_index: int = -1
var _selected_person_id: String = ""
#endregion

#region PUBLIC FUNCTIONS
## Updates the displayed information in the centre panel.
## Populates the centre panel with a list of living people and their details.
## @return void
func update_view() -> void:
	super.update_view()

	_people_list.clear()
	_person_entry_nodes.clear()
	_selected_index = -1

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

	_people_list = living_people.duplicate()

	# Person rows
	var select_index: int = 0
	if _selected_person_id != "":
		for i in range(_people_list.size()):
			if _people_list[i].id == _selected_person_id:
				select_index = i
				break

	for i in range(_people_list.size()):
		var person = _people_list[i]
		var entry = _create_person_details_entry(person)
		var btn_select: Button = entry.get_node("BtnSelect")
		btn_select.pressed.connect(_on_person_entry_pressed.bind(i))
		vbx_people_details.add_child(entry)
		_add_to_clear_list(entry)
		_person_entry_nodes.append(entry)

	# Automatically select the correct person (persisted or first)
	if _people_list.size() > 0:
		_select_person_by_index(select_index)

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

func _on_person_entry_pressed(index: int) -> void:
	_select_person_by_index(index)

func _select_person_by_index(index: int) -> void:
	if index < 0 or index >= _people_list.size():
		return
	if _selected_index == index:
		return
	_selected_index = index
	_selected_person_id = _people_list[index].id

	# Update visual feedback using _person_entry_nodes
	var selected_style_box = preload("res://shared/resource/style_box_selected_button.tres")
	var unselected_style_box = preload("res://shared/resource/style_box_unselected_button.tres")
	for i in range(_person_entry_nodes.size()):
		var entry = _person_entry_nodes[i]
		if i == _selected_index:
			entry.add_theme_stylebox_override("panel", selected_style_box)
		else:
			entry.add_theme_stylebox_override("panel", unselected_style_box)

	# Update right sidebar
	_update_right_sidebar()
	# (Sidebar update will be handled in a later step)

func _update_right_sidebar() -> void:
	if _selected_index < 0 or _selected_index >= _people_list.size():
		set_right_sidebar_content([])
		return
	var person = _people_list[_selected_index]
	var controls: Array[Control] = []

	# Culture
	var culture = Library.get_culture_by_id(person.culture_id)
	if culture:
		controls.append(UIFactory.create_viewport_sidebar_header_label("Culture") as Control)
		var lbl_culture: Label = Label.new()
		lbl_culture.text = culture.id.capitalize()
		controls.append(lbl_culture)

	# Ancestry
	var ancestry = Library.get_ancestry_by_id(person.ancestry_id)
	if ancestry:
		controls.append(UIFactory.create_viewport_sidebar_header_label("Ancestry") as Control)
		var lbl_ancestry: Label = Label.new()
		lbl_ancestry.text = ancestry.id.capitalize()
		controls.append(lbl_ancestry)

	# Stockpile
	controls.append(UIFactory.create_viewport_sidebar_header_label("Stockpile") as Control)
	for good in Library.get_all_goods_data():
		var hbox: HBoxContainer = HBoxContainer.new()
		var icon_lbl: Label = Label.new()
		icon_lbl.text = good.icon
		hbox.add_child(icon_lbl)
		var name_lbl: Label = Label.new()
		name_lbl.text = good.f_name.capitalize()
		hbox.add_child(name_lbl)
		var amount_lbl: Label = Label.new()
		amount_lbl.text = str(person.stockpile.get(good.id, 0))
		hbox.add_child(amount_lbl)
		controls.append(hbox)

	set_right_sidebar_content(controls)

#endregion
