## ViewLaws2: Laws view using the standardised ABCView layout system.
## Displays information about laws in the simulation using the modular UI layout.
## Usage:
##  Inherit from ABCView. Implement update_view() to populate the centre panel and any other regions as needed, using set_centre_content, set_left_sidebar_content, etc. Call refresh() to update the view; this will clear all regions, call update_view(), and automatically show a standard message in any empty region.
##  All user actions in sidebars and top bar should emit the standard signals (left_action_selected, top_tab_selected, right_info_requested) where appropriate.
##  Error and empty state handling is managed by the base class.
##
## See: dev/docs/docs/systems/ui_layout.md
## Last Updated: 2025-05-13
##
extends ABCView

#region CONSTANTS
const PARAMETER_VALUES := {
	"tax_rate": [5.0, 10.0, 15.0, 20.0, 25.0]
}
#endregion

#region SIGNALS
#endregion

#region EXPORTS
#endregion

#region ON READY
#endregion

#region VARS
var _sim: Sim = null
var _selected_law_id: String = ""
var _law_panels: Dictionary = {}
#endregion

#region PUBLIC FUNCTIONS
## Updates the displayed information in the centre panel.
## Populates the centre panel with a list of laws grouped by category, and highlights the selected law.
## @return void
func update_info() -> void:
	_clear_all_children(centre_panel)
	_law_panels.clear()
	var first_law_id := ""
	if not _sim or not _sim.demesne:
		_add_error_message("No simulation data available")
		return
	var law_data: Dictionary = Library.get_laws_data()
	if not law_data:
		_add_error_message("No laws data available")
		return
	# Group laws by category
	var laws_by_category: Dictionary = {}
	for law in law_data.get("laws", []):
		var category: String = law.get("category", "Uncategorised")
		if not laws_by_category.has(category):
			laws_by_category[category] = []
		laws_by_category[category].append(law)
	# Create a VBoxContainer to hold all content
	var vbox := VBoxContainer.new()
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	# Display laws by category
	for category in laws_by_category.keys():
		# Add category header
		var category_label := Label.new()
		category_label.text = "%s Laws" % category
		category_label.add_theme_font_size_override("font_size", 20)
		vbox.add_child(category_label)
		# Add laws in this category
		for law in laws_by_category[category]:
			var law_id: String = law.get("id")
			if first_law_id == "":
				first_law_id = law_id
			var is_active: bool = _sim.demesne.is_law_active(law_id)
			var law_panel: Button = _create_law_panel(law, is_active, law_id)
			_law_panels[law_id] = law_panel
			vbox.add_child(law_panel)
	set_centre_content([vbox])
	# Select the first law by default if none selected
	if _selected_law_id == "" and first_law_id != "":
		_on_law_panel_selected(first_law_id)
	elif _selected_law_id in _law_panels:
		_highlight_selected_law()

## Updates the left sidebar with law details and actions.
## @param law_id (String): The law's ID.
## @return void
func _update_left_sidebar(law_id: String) -> void:
	var sidebar_content: Array[Control] = []
	if not _sim or not _sim.demesne:
		set_left_sidebar_content([])
		return
	var law = null
	var law_data = null
	var law_data_dict: Dictionary = Library.get_laws_data()
	for l in law_data_dict.get("laws", []):
		if l.get("id") == law_id:
			law_data = l
			break
	if not law_data:
		set_left_sidebar_content([])
		return
	if _sim.demesne.is_law_active(law_id):
		law = _sim.demesne.get_law(law_id)
	# Law name and description
	var name_label := Label.new()
	name_label.text = law_data.get("name")
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.add_theme_font_size_override("font_size", 18)
	sidebar_content.append(name_label)
	# Enact/Repeal buttons
	var actions_hbox := HBoxContainer.new()
	var enact_button := Button.new()
	enact_button.text = "Enact"
	enact_button.disabled = _sim.demesne.is_law_active(law_id)
	enact_button.pressed.connect(_on_law_button_pressed.bind(law_id, false))
	actions_hbox.add_child(enact_button)
	var repeal_button := Button.new()
	repeal_button.text = "Repeal"
	repeal_button.disabled = not _sim.demesne.is_law_active(law_id)
	repeal_button.pressed.connect(_on_law_button_pressed.bind(law_id, true))
	actions_hbox.add_child(repeal_button)
	sidebar_content.append(actions_hbox)
	# Parameters (if any)
	var parameters: Dictionary = law_data.get("parameters", {})
	if not parameters.is_empty():
		var param_vbox := VBoxContainer.new()
		for param_name in parameters:
			var param_info = parameters[param_name]
			var options = _sim.demesne.law_registry.get_parameter_options(law_id, param_name)
			if not options.is_empty():
				var current_value = param_info.default
				if law:
					current_value = law.get_parameter(param_name)
				var param_label := Label.new()
				param_label.text = param_info.name + ": "
				param_vbox.add_child(param_label)
				# Wrap FlowContainer in a Control to constrain width to sidebar_width
				var options_wrapper := Control.new()
				options_wrapper.custom_minimum_size.x = self.sidebar_width # Ensures fixed sidebar width
				var options_flow := FlowContainer.new()
				options_flow.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				# Add value buttons to the FlowContainer
				for value in options:
					var value_button := Button.new()
					value_button.text = str(value) + "%"
					value_button.toggle_mode = true
					value_button.button_pressed = (law and is_equal_approx(value, current_value))
					value_button.disabled = not law
					value_button.pressed.connect(_on_param_value_selected.bind(law_id, param_name, value))
					options_flow.add_child(value_button)
				# Add the FlowContainer to the wrapper
				options_wrapper.add_child(options_flow)
				param_vbox.add_child(options_wrapper)
			sidebar_content.append(param_vbox)
	set_left_sidebar_content(sidebar_content)

## Handles enact/repeal button presses for a law.
## @param law_id (String): The law's ID.
## @param is_active (bool): Whether the law is currently active.
## @return void
func _on_law_button_pressed(law_id: String, is_active: bool) -> void:
	if is_active:
		_sim.demesne.repeal_law(law_id)
	else:
		_sim.demesne.enact_law(law_id)
	update_info()

## Handles parameter value selection for a law.
## @param law_id (String): The law's ID.
## @param param_name (String): The parameter name.
## @param value (float): The selected value.
## @return void
func _on_param_value_selected(law_id: String, param_name: String, value: float) -> void:
	var law = _sim.demesne.get_law(law_id)
	if law:
		law.set_parameter(param_name, value)
		update_info()
#endregion

#region PRIVATE FUNCTIONS
## Called when the node is added to the scene tree. Sets up signals and initialises the view.
## @return void
func _ready() -> void:
	show_right_sidebar = true
	ReferenceRegistry.reference_registered.connect(_on_reference_registered)
	if EventBusGame.has_signal("turn_complete"):
		EventBusGame.turn_complete.connect(update_info)
	# Attempt to get sim if already registered
	var sim_ref = ReferenceRegistry.get_reference(Constants.ReferenceKey.SIM)
	if sim_ref:
		_set_sim(sim_ref)
	update_info()

## @null
## Adds an error message label to the centre panel.
## @param message (String): The error message to display.
## @return void
func _add_error_message(message: String) -> void:
	_clear_all_children(centre_panel)
	var label := Label.new()
	label.text = message
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	centre_panel.add_child(label)

## Handles updates from the ReferenceRegistry.
## @param key (int): The reference key.
## @param value (Object): The reference value.
## @return void
func _on_reference_registered(key: int, value: Object) -> void:
	if key == Constants.ReferenceKey.SIM:
		_set_sim(value)

## Sets the sim reference and connects law signals.
## @param sim_ref (Sim): The simulation reference.
## @return void
func _set_sim(sim_ref: Sim) -> void:
	_sim = sim_ref
	if _sim.demesne:
		_sim.demesne.law_enacted.connect(_on_law_enacted)
		_sim.demesne.law_repealed.connect(_on_law_repealed)
	update_info()

## Handles the law_enacted signal to refresh the view.
## @param law (Law): The enacted law.
## @return void
func _on_law_enacted(law: Law) -> void:
	update_info()

## Handles the law_repealed signal to refresh the view.
## @param law_id (String): The repealed law's ID.
## @return void
func _on_law_repealed(law_id: String) -> void:
	update_info()

## Creates a law panel button for a given law.
## @param law_data (Dictionary): The law's data.
## @param is_active (bool): Whether the law is currently active.
## @param law_id (String): The law's ID.
## @return Button: The constructed law panel button.
func _create_law_panel(law_data: Dictionary, is_active: bool, law_id: String) -> Button:
	var panel := Button.new()
	panel.name = law_id
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.toggle_mode = true
	panel.focus_mode = Control.FOCUS_ALL
	panel.text = law_data.get("name") + "\n" + law_data.get("description")
	panel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.pressed.connect(_on_law_panel_selected.bind(law_id))
	panel.mouse_entered.connect(panel.grab_focus)
	# Highlight if selected
	if law_id == _selected_law_id:
		panel.button_pressed = true
	else:
		panel.button_pressed = false
	return panel

## Highlights the currently selected law panel.
## @return void
func _highlight_selected_law() -> void:
	for law_id in _law_panels.keys():
		_law_panels[law_id].button_pressed = (law_id == _selected_law_id)

## Handles law panel selection and updates the left sidebar.
## @param law_id (String): The selected law's ID.
## @return void
func _on_law_panel_selected(law_id: String) -> void:
	_selected_law_id = law_id
	_highlight_selected_law()
	_update_left_sidebar(law_id)
#endregion
