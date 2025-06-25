## SubViewCodex: Law codex view using the standardised ABCView layout system.
## Displays information about available laws in the simulation and allows enactment/repeal.
## Usage:
##  Inherit from ABCView. Implement update_view() to populate the centre panel and any other regions as needed, using set_centre_content, set_top_bar_content, etc. Call refresh() to update the view; this will clear all regions, call update_view(), and automatically show a standard message in any empty region.
##  All user actions in sidebars and top bar should emit the standard signals (left_action_selected, top_tab_selected, right_info_requested) where appropriate.
##  Error and empty state handling is managed by the base class.
##
## See: dev/docs/docs/systems/ui.md
##
## Last Updated: 2025-01-27
##
class_name SubViewCodex
extends ABCSubView

#region CONSTANTS
const SCENE_CODEX_ENTRY: PackedScene = preload("res://feature/law/ui/sub_view/codex/codex_entry.tscn")
#endregion

#region SIGNALS
#endregion

#region EXPORTS
#endregion

#region ON READY
@onready var vbx_laws_container: VBoxContainer = %VBxLawsContainer
@onready var lbl_law_name: Label = %LblLawName
@onready var actions_container: HBoxContainer = %ActionsContainer
@onready var parameters_container: VBoxContainer = %ParametersContainer
@onready var demo_entry: PanelContainer = %DemoLawEntry ## used for design. delete on init.
#endregion

#region VARS
var _laws_list: Array[DataLaw] = []
var _law_entry_nodes: Array[PanelContainer] = []
var _selected_index: int = -1
var _selected_law_id: String = ""
#endregion

#region PUBLIC FUNCTIONS
## Updates the displayed information in the centre panel.
## Populates the centre panel with a list of available laws and their details.
## @return void
func update_view() -> void:
	super.update_view()

	_laws_list.clear()
	_law_entry_nodes.clear()
	_selected_index = -1

	# Check we have sim ref
	if not _sim:
		set_centre_content([])
		return
	if not _sim.demesne:
		set_centre_content([])
		return

	# Get available law IDs from the demesne's law registry
	var available_law_ids: Array[String] = _sim.demesne.law_registry.get_available_law_ids()
	if available_law_ids.is_empty():
		set_centre_content([])
		return

	# Filter Library data to only include laws available in this demesne's registry
	var all_laws_data: Array[DataLaw] = Library.get_all_laws_data()
	_laws_list = all_laws_data.filter(func(law): return available_law_ids.has(law.id))

	if _laws_list.is_empty():
		set_centre_content([])
		return

	# Create law entries
	var select_index: int = 0
	if _selected_law_id != "":
		for i in range(_laws_list.size()):
			if _laws_list[i].id == _selected_law_id:
				select_index = i
				break

	for i in range(_laws_list.size()):
		var law_data = _laws_list[i]
		var entry = _create_law_entry(law_data)
		var btn_select: Button = entry.get_node("VBoxContainer/HBoxContainer/BtnSelect")
		if btn_select:
			btn_select.pressed.connect(_on_law_entry_pressed.bind(i))
		vbx_laws_container.add_child(entry)
		_add_to_clear_list(entry, "centre")
		_law_entry_nodes.append(entry)

	# Automatically select the correct law (persisted or first)
	if _laws_list.size() > 0:
		_select_law_by_index(select_index)

	set_centre_content([])
#endregion

#region PRIVATE FUNCTIONS
func _ready() -> void:
	super._ready()

	_add_to_clear_list(demo_entry, "centre")
	refresh()

## Creates a UI entry for a law's details.
## @param law_data The law data to create an entry for
## @return The created panel container
func _create_law_entry(law_data: DataLaw) -> PanelContainer:
	var entry = SCENE_CODEX_ENTRY.instantiate()

	# Name
	var lbl_name: Label = entry.get_node("VBoxContainer/HBoxContainer/LblName")
	lbl_name.text = law_data.f_name

	# Category
	var lbl_category: Label = entry.get_node("VBoxContainer/HBoxContainer/LblCategory")
	lbl_category.text = law_data.category

	# Status (Active/Inactive)
	var lbl_status: Label = entry.get_node("VBoxContainer/HBoxContainer/LblStatus")
	var is_active: bool = _sim.demesne.is_law_active(law_data.id)
	if is_active:
		lbl_status.text = "Active"
		lbl_status.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))
	else:
		lbl_status.text = "Inactive"
		lbl_status.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2))

	return entry

## Handles when a law entry is pressed.
## @param index The index of the pressed entry
## @return void
func _on_law_entry_pressed(index: int) -> void:
	_select_law_by_index(index)

## Selects a law by their index in the laws list.
## Updates visual feedback and the right sidebar.
## @param index The index of the law to select
## @return void
func _select_law_by_index(index: int) -> void:
	if index < 0 or index >= _laws_list.size():
		return
	if _selected_index == index:
		return
	_selected_index = index
	_selected_law_id = _laws_list[index].id

	# Update visual feedback using _law_entry_nodes
	var selected_style_box = preload("res://shared/resource/style_box_selected_button.tres")
	var unselected_style_box = preload("res://shared/resource/style_box_unselected_button.tres")
	for i in range(_law_entry_nodes.size()):
		var entry = _law_entry_nodes[i]
		if i == _selected_index:
			entry.add_theme_stylebox_override("panel", selected_style_box)
		else:
			entry.add_theme_stylebox_override("panel", unselected_style_box)

	# Update right sidebar
	_update_right_sidebar()

## Updates the right sidebar with the selected law's details.
## @return void
func _update_right_sidebar() -> void:
	_free_section_from_clear_list("right")

	if _selected_index < 0 or _selected_index >= _laws_list.size():
		set_right_sidebar_content([])
		return

	var law_data: DataLaw = _laws_list[_selected_index]
	var controls: Array[Control] = []

	# Law name
	lbl_law_name.text = law_data.f_name

	# Clear existing action buttons
	for child in actions_container.get_children():
		child.queue_free()

	# Create action buttons based on law status
	var is_active: bool = _sim.demesne.is_law_active(law_data.id)
	if is_active:
		var btn_repeal = UIFactory.create_button("Repeal Law", _on_repeal_law_pressed)
		btn_repeal.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2))
		actions_container.add_child(btn_repeal)
		_add_to_clear_list(btn_repeal, "right")
	else:
		var btn_enact = UIFactory.create_button("Enact Law", _on_enact_law_pressed)
		btn_enact.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))
		actions_container.add_child(btn_enact)
		_add_to_clear_list(btn_enact, "right")

	# Clear existing parameters
	for child in parameters_container.get_children():
		child.queue_free()

	# Add law details
	var lbl_description = Label.new()
	lbl_description.text = law_data.description
	lbl_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_description.custom_minimum_size = Vector2(0, 60)
	controls.append(lbl_description)
	_add_to_clear_list(lbl_description, "right")

	# Add category info
	var lbl_category_info = Label.new()
	lbl_category_info.text = "Category: " + law_data.category
	controls.append(lbl_category_info)
	_add_to_clear_list(lbl_category_info, "right")

	# Add parameters if the law has any
	var law_json: Dictionary = {}
	for entry in Library._get_data("laws").get("laws", []):
		if entry.get("id") == law_data.id:
			law_json = entry
			break

	if law_json.has("parameters") and not law_json.parameters.is_empty():
		var lbl_params_header = Label.new()
		lbl_params_header.text = "Parameters:"
		lbl_params_header.add_theme_font_size_override("font_size", 14)
		lbl_params_header.add_theme_color_override("font_color", Color(0.8, 0.8, 1.0))
		controls.append(lbl_params_header)
		_add_to_clear_list(lbl_params_header, "right")

		for param_name in law_json.parameters:
			var param_data = law_json.parameters[param_name]
			var lbl_param = Label.new()
			lbl_param.text = param_data.name + ": " + str(param_data.default)
			controls.append(lbl_param)
			_add_to_clear_list(lbl_param, "right")

	# Add tags if the law has any
	if law_json.has("tags") and not law_json.tags.is_empty():
		var lbl_tags_header = Label.new()
		lbl_tags_header.text = "Tags:"
		lbl_tags_header.add_theme_font_size_override("font_size", 14)
		lbl_tags_header.add_theme_color_override("font_color", Color(0.8, 0.8, 1.0))
		controls.append(lbl_tags_header)
		_add_to_clear_list(lbl_tags_header, "right")

		var lbl_tags = Label.new()
		lbl_tags.text = ", ".join(law_json.tags)
		controls.append(lbl_tags)
		_add_to_clear_list(lbl_tags, "right")

	set_right_sidebar_content(controls)

## Handles enacting a law.
## @return void
func _on_enact_law_pressed() -> void:
	if _selected_index < 0 or _selected_index >= _laws_list.size():
		return

	var law_data: DataLaw = _laws_list[_selected_index]
	var law: Law = _sim.demesne.enact_law(law_data.id)

	if law:
		refresh()

## Handles repealing a law.
## @return void
func _on_repeal_law_pressed() -> void:
	if _selected_index < 0 or _selected_index >= _laws_list.size():
		return

	var law_data: DataLaw = _laws_list[_selected_index]
	var success: bool = _sim.demesne.repeal_law(law_data.id)

	if success:
		refresh()
#endregion
