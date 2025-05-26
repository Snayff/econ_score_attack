## SubViewDecisions: Shows all decisions made by people in the last turn.
## Displays a list of decision outputs in the centre panel. Selecting one shows details in the right sidebar.
## Usage: Inherits from ABCSubView. Populates centre panel with decision summaries, right sidebar with details.
## Last Updated: 2025-05-24
class_name  SubViewDecisions
extends ABCSubView

@onready var lbl_person: Label = %LblPerson
@onready var lbl_decision: Label = %LblDecision
@onready var lbl_rationale: Label = %LblRationale
@onready var lbl_input: Label = %LblInput
@onready var lbl_alternatives: Label = %LblAlternatives



#region VARS
var _decision_list: Array = []
var _decision_entry_nodes: Array = []
var _selected_index: int = -1
#endregion

#region PUBLIC FUNCTIONS
func update_view() -> void:
	_decision_list.clear()
	_decision_entry_nodes.clear()
	_selected_index = -1

	if not _sim or not _sim.demesne:
		set_centre_content([])
		set_right_sidebar_content([])
		return


	# Gather all decisions from all people
	for person in _sim.demesne.get_people():
		for decision in person.last_turn_decisions:
			# Attach person reference for display
			var entry = decision.duplicate()
			entry["person"] = person
			_decision_list.append(entry)

	if _decision_list.size() == 0:
		show_section_content("centre", false)
		show_section_content("right", false)

		set_empty_message("centre", "No decisions were made last turn.")
		set_empty_message("centre", "No decision details to show.")
		return


	show_section_content("centre", true)
	show_section_content("right", true)

	# create button per decision
	var centre_controls: Array[Control] = []
	var vbx = VBoxContainer.new()
	centre_panel.add_child(vbx)
	_add_to_clear_list(vbx, "centre")
	for i in range(_decision_list.size()):
		var decision = _decision_list[i]
		var btn = UIFactory.create_button("%s: %s" % [decision["person"].f_name, decision["action"]])

		# add to relevant places
		vbx.add_child(btn)
		btn.pressed.connect(_on_decision_entry_pressed.bind(i))
		centre_controls.append(btn)

		# list for clearing on refresh
		_add_to_clear_list(btn, "centre")

		_decision_entry_nodes.append(btn)

	_select_decision_by_index(0)

#endregion

#region PRIVATE FUNCTIONS
func _on_decision_entry_pressed(index: int) -> void:
	_select_decision_by_index(index)

func _select_decision_by_index(index: int) -> void:
	if index < 0 or index >= _decision_list.size():
		return
	_selected_index = index

	# Visual feedback (optional: highlight selected button)
	for i in range(_decision_entry_nodes.size()):
		var btn = _decision_entry_nodes[i]
		btn.disabled = (i == _selected_index)

	_update_right_sidebar()

func _update_right_sidebar() -> void:
	# Always clear the right sidebar before adding new content
	_free_section_from_clear_list("right")
	lbl_person.text = ""
	lbl_decision.text = ""
	lbl_input.text = ""
	lbl_alternatives.text = ""


	if _selected_index < 0 or _selected_index >= _decision_list.size():
		return
	var decision = _decision_list[_selected_index]
	var controls: Array[Control] = []


	# Person
	lbl_person.text = decision["person"].f_name

	# Decision
	lbl_decision.text = decision["action"]

	# Rationale
	lbl_rationale.text = decision["reasoning"]

	# Inputs
	for k in decision["inputs"]:
		lbl_input.text = "  %s: %s" % [k, str(decision["inputs"][k])]

	# Alternatives
	for alt in decision["alternatives"]:
		lbl_alternatives.text = "  %s (utility: %s)" % [alt.get("action", ""), str(alt.get("utility", ""))]

	set_right_sidebar_content(controls)
#endregion
