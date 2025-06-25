## SubViewDecisions: Shows all decisions made by people in the last turn.
## Displays a list of decision outputs in the centre panel using pre-built scene templates.
## Selecting one shows details in the right sidebar.
## Usage: Inherits from ABCSubView. Populates centre panel with decision summaries, right sidebar with details.
##
## Last Updated: 2025-01-27
##
class_name SubViewDecisionsCodexStyle
extends ABCSubView

#region CONSTANTS
const SCENE_DECISION_ENTRY: PackedScene = preload("res://feature/economic_actor/ui/sub_view/decisions/decision_entry.tscn")
#endregion

#region SIGNALS
#endregion

#region EXPORTS
#endregion

#region ON READY
@onready var vbx_decisions_container: VBoxContainer = %VBxDecisionsContainer
@onready var lbl_person: Label = %LblPerson
@onready var lbl_decision: Label = %LblDecision
@onready var lbl_rationale: Label = %LblRationale
@onready var lbl_input: Label = %LblInput
@onready var lbl_alternatives: Label = %LblAlternatives
@onready var demo_entry: PanelContainer = %DemoDecisionEntry ## used for design. delete on init.

#endregion

#region VARS
var _decision_list: Array = []
var _decision_entry_nodes: Array[PanelContainer] = []
var _selected_index: int = -1
var _selected_decision_id: String = ""
#endregion

#region PUBLIC FUNCTIONS
## Updates the displayed information in the centre panel.
## Populates the centre panel with a list of decisions made in the last turn.
## @return void
func update_view() -> void:
	super.update_view()

	_decision_list.clear()
	_decision_entry_nodes.clear()
	_selected_index = -1

	# Check we have sim ref
	if not _sim:
		set_centre_content([])
		return
	if not _sim.demesne:
		set_centre_content([])
		return

	# Gather all decisions from all people
	for person in _sim.demesne.get_people():
		for decision in person.last_turn_decisions:
			# Attach person reference for display
			var entry = decision.duplicate()
			entry["person"] = person
			entry["decision_id"] = person.id + "_" + str(decision.hash())  # Create unique ID
			_decision_list.append(entry)

	if _decision_list.is_empty():
		set_centre_content([])
		return

	# Create decision entries
	var select_index: int = 0
	if _selected_decision_id != "":
		for i in range(_decision_list.size()):
			if _decision_list[i]["decision_id"] == _selected_decision_id:
				select_index = i
				break

	for i in range(_decision_list.size()):
		var decision = _decision_list[i]
		var entry = _create_decision_entry(decision)
		var btn_select: Button = entry.get_node("VBoxContainer/HBoxContainer/BtnSelect")
		if btn_select:
			btn_select.pressed.connect(_on_decision_entry_pressed.bind(i))
		vbx_decisions_container.add_child(entry)
		_add_to_clear_list(entry, "centre")
		_decision_entry_nodes.append(entry)

	# Automatically select the correct decision (persisted or first)
	if _decision_list.size() > 0:
		_select_decision_by_index(select_index)

	set_centre_content([])
#endregion

#region PRIVATE FUNCTIONS
func _ready() -> void:
	super._ready()

	_add_to_clear_list(demo_entry, "centre")
	refresh()

## Creates a UI entry for a decision's details.
## @param decision The decision data to create an entry for
## @return The created panel container
func _create_decision_entry(decision: Dictionary) -> PanelContainer:
	var entry = SCENE_DECISION_ENTRY.instantiate()

	# Person name
	var lbl_person: Label = entry.get_node("VBoxContainer/HBoxContainer/LblPerson")
	lbl_person.text = decision["person"].f_name

	# Action
	var lbl_action: Label = entry.get_node("VBoxContainer/HBoxContainer/LblAction")
	lbl_action.text = decision["action"]

	return entry

## Handles when a decision entry is pressed.
## @param index The index of the pressed entry
## @return void
func _on_decision_entry_pressed(index: int) -> void:
	_select_decision_by_index(index)

## Selects a decision by their index in the decisions list.
## Updates visual feedback and the right sidebar.
## @param index The index of the decision to select
## @return void
func _select_decision_by_index(index: int) -> void:
	if index < 0 or index >= _decision_list.size():
		return
	if _selected_index == index:
		return
	_selected_index = index
	_selected_decision_id = _decision_list[index]["decision_id"]

	# Update visual feedback using _decision_entry_nodes
	var selected_style_box = preload("res://shared/resource/style_box_selected_button.tres")
	var unselected_style_box = preload("res://shared/resource/style_box_unselected_button.tres")
	for i in range(_decision_entry_nodes.size()):
		var entry = _decision_entry_nodes[i]
		if i == _selected_index:
			entry.add_theme_stylebox_override("panel", selected_style_box)
		else:
			entry.add_theme_stylebox_override("panel", unselected_style_box)

	# Update right sidebar
	_update_right_sidebar()

## Updates the right sidebar with the selected decision's details.
## @return void
func _update_right_sidebar() -> void:
	_free_section_from_clear_list("right")

	# Clear content
	lbl_person.text = ""
	lbl_decision.text = ""
	lbl_rationale.text = ""
	lbl_input.text = ""
	lbl_alternatives.text = ""

	if _selected_index < 0 or _selected_index >= _decision_list.size():
		set_right_sidebar_content([])
		return

	# Get decision data
	var decision = _decision_list[_selected_index]

	# Add content
	lbl_person.text = decision["person"].f_name
	lbl_decision.text = decision["action"]
	lbl_rationale.text = decision["reasoning"]

	# Format inputs
	var input_text: String = ""
	for k in decision["inputs"]:
		input_text += "  %s: %s\n" % [k, str(decision["inputs"][k])]
	lbl_input.text = input_text.strip_edges()

	# Format alternatives
	var alt_text: String = ""
	for alt in decision["alternatives"]:
		alt_text += "  %s (utility: %s)\n" % [alt.get("action", ""), str(alt.get("utility", ""))]
	lbl_alternatives.text = alt_text.strip_edges()

	set_right_sidebar_content([])
#endregion
