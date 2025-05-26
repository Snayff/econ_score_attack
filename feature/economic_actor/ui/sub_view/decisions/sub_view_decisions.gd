## SubViewDecisions: Shows all decisions made by people in the last turn.
## Displays a list of decision outputs in the centre panel. Selecting one shows details in the right sidebar.
## Usage: Inherits from ABCSubView. Populates centre panel with decision summaries, right sidebar with details.
## Last Updated: 2025-05-24
class_name  SubViewDecisions
extends ABCSubView

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

	var centre_controls: Array[Control] = []
	for i in range(_decision_list.size()):
		var decision = _decision_list[i]
		var btn = UIFactory.create_button("%s: %s" % [decision["person"].f_name, decision["action"]])
		btn.pressed.connect(_on_decision_entry_pressed.bind(i))
		centre_controls.append(btn)
		_add_to_clear_list(btn, "centre")
		_decision_entry_nodes.append(btn)

	# Wrap buttons in a VBoxContainer
	var vbox = VBoxContainer.new()
	for btn in centre_controls:
		vbox.add_child(btn)
	_add_to_clear_list(vbox, "centre")
	set_centre_content([vbox])

	# Auto-select first if any
	if _decision_list.size() > 0:
		_select_decision_by_index(0)
	else:
		set_right_sidebar_content([])
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
	set_right_sidebar_content([])
	if _selected_index < 0 or _selected_index >= _decision_list.size():
		return
	var decision = _decision_list[_selected_index]
	var controls: Array[Control] = []

	# Header
	controls.append(UIFactory.create_viewport_sidebar_header_label("Decision Details"))

	# Person
	var lbl_person = Label.new()
	lbl_person.text = "Person: %s" % decision["person"].f_name
	controls.append(lbl_person)
	var lbl_action = Label.new()
	lbl_action.text = "Action: %s" % decision["action"]
	controls.append(lbl_action)

	# Inputs
	var lbl_inputs = Label.new()
	lbl_inputs.text = "Inputs:"
	controls.append(lbl_inputs)
	for k in decision["inputs"]:
		var lbl_input = Label.new()
		lbl_input.text = "  %s: %s" % [k, str(decision["inputs"][k])]
		controls.append(lbl_input)

	# Reasoning
	var lbl_reasoning = Label.new()
	lbl_reasoning.text = "Reasoning: %s" % decision["reasoning"]
	controls.append(lbl_reasoning)

	# Alternatives
	var lbl_alts = Label.new()
	lbl_alts.text = "Alternatives considered:"
	controls.append(lbl_alts)
	for alt in decision["alternatives"]:
		var lbl_alt = Label.new()
		lbl_alt.text = "  %s (utility: %s)" % [alt.get("action", ""), str(alt.get("utility", ""))]
		controls.append(lbl_alt)

	for c in controls:
		_add_to_clear_list(c, "right")

	set_right_sidebar_content(controls)
#endregion
