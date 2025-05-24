## ViewLaws: Laws view using the standardised ABCView layout system.
## Displays information about laws in the simulation using the modular UI layout.
## Usage:
##  Inherit from ABCView. Implement update_view() to populate the centre panel and any other regions as needed, using set_centre_content, set_left_sidebar_content, etc. Call refresh() to update the view; this will clear all regions, call update_view(), and automatically show a standard message in any empty region.
##  All user actions in sidebars and top bar should emit the standard signals (left_action_selected, top_tab_selected, right_info_requested) where appropriate.
##  Error and empty state handling is managed by the base class.
##  Uses UIFactory (global autoload) for standard UI element creation.
##  UIFactory is available as a global autoload; if your linter complains, suppress or ignore the warning.
##
## See: dev/docs/docs/systems/ui.md
## Last Updated: 2025-05-13
extends ABCView


#region CONSTANTS
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
func update_view() -> void:
	_clear_all_children(centre_panel)
	_law_panels.clear()
	var first_law_id := ""
	if not _sim or not _sim.demesne:
		set_centre_content([])
		return
	var all_laws: Array[DataLaw] = Library.get_all_laws_data()
	if all_laws.is_empty():
		set_centre_content([])
		return
	# Group laws by category
	var laws_by_category: Dictionary = {}
	for law in all_laws:
		var category: String = law.category if law.category != "" else "Uncategorised"
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
			var law_id: String = law.id
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
	var law: DataLaw = null
	for l in Library.get_all_laws_data():
		if l.id == law_id:
			law = l
			break
	if law == null:
		set_left_sidebar_content([])
		return
	var is_active: bool = _sim.demesne.is_law_active(law_id)
	var law_instance = null
	if is_active:
		law_instance = _sim.demesne.get_law(law_id)
	# Law name and description
	var name_label: Label = UIFactory.create_viewport_sidebar_header_label(law.f_name)
	sidebar_content.append(name_label)
	# Enact/Repeal buttons
	var actions_hbox: HBoxContainer = HBoxContainer.new()
	var enact_button: Button = UIFactory.create_button("Enact", _on_law_button_pressed.bind(law_id, false))
	enact_button.disabled = is_active
	actions_hbox.add_child(enact_button)
	var repeal_button: Button = UIFactory.create_button("Repeal", _on_law_button_pressed.bind(law_id, true))
	repeal_button.disabled = not is_active
	actions_hbox.add_child(repeal_button)
	sidebar_content.append(actions_hbox)
	# Parameters (if any)
	var law_json: Dictionary = {}
	for entry in Library._get_data("laws").get("laws", []):
		if entry.get("id") == law_id:
			law_json = entry
			break
	var parameters: Dictionary = law_json.get("parameters", {})
	if not parameters.is_empty():
		var param_vbox: VBoxContainer = VBoxContainer.new()
		for param_name in parameters:
			var param_info = parameters[param_name]
			var options = _sim.demesne.law_registry.get_parameter_options(law_id, param_name)
			if not options.is_empty():
				var current_value = param_info.default
				if law_instance:
					current_value = law_instance.get_parameter(param_name)
				var param_label: Label = Label.new()
				param_label.text = param_info.name + ": "
				param_vbox.add_child(param_label)
				# Use UIFactory for sidebar button container
				var options_flow: FlowContainer = UIFactory.create_viewport_sidebar_button_container()
				# Add value buttons to the FlowContainer
				for value in options:
					var value_button: Button = UIFactory.create_button(str(value) + "%", _on_param_value_selected.bind(law_id, param_name, value))
					value_button.toggle_mode = true
					value_button.button_pressed = (law_instance and is_equal_approx(value, current_value))
					value_button.disabled = not law_instance
					options_flow.add_child(value_button)
				param_vbox.add_child(options_flow)
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
	update_view()

## Handles parameter value selection for a law.
## @param law_id (String): The law's ID.
## @param param_name (String): The parameter name.
## @param value (float): The selected value.
## @return void
func _on_param_value_selected(law_id: String, param_name: String, value: float) -> void:
	var law = _sim.demesne.get_law(law_id)
	if law:
		law.set_parameter(param_name, value)
		update_view()
#endregion

#region PRIVATE FUNCTIONS
## Called when the node is added to the scene tree. Sets up signals and initialises the view.
## @return void
func _ready() -> void:
	show_right_sidebar = true
	ReferenceRegistry.reference_registered.connect(_on_reference_registered)
	if EventBusGame.has_signal("turn_complete"):
		EventBusGame.turn_complete.connect(update_view)
	# Attempt to get sim if already registered
	var sim_ref = ReferenceRegistry.get_reference(Constants.ReferenceKey.SIM)
	if sim_ref:
		_set_sim(sim_ref)
	update_view()

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
	update_view()

## Handles the law_enacted signal to refresh the view.
## @return void
func _on_law_enacted() -> void:
	update_view()

## Handles the law_repealed signal to refresh the view.
## @return void
func _on_law_repealed() -> void:
	update_view()

## Creates a law panel button for a given law.
## @param law (DataLaw): The law's data.
## @param is_active (bool): Whether the law is currently active.
## @param law_id (String): The law's ID.
## @return Button: The constructed law panel button.
func _create_law_panel(law: DataLaw, is_active: bool, law_id: String) -> Button:
	var panel := Button.new()
	panel.name = law_id
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.toggle_mode = true
	panel.focus_mode = Control.FOCUS_ALL
	panel.text = law.f_name + "\n" + law.description
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
