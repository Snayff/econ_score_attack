## ViewLaws2: Updated laws view using ABCView layout.
## Displays information about laws in the simulation using the standardised UI layout system.
## Usage: Add this scene to a parent UI node. Populates the centre panel of ABCView with laws info.
## See: dev/docs/docs/systems/ui_layout.md
## Last Updated: 2024-06-10
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
#endregion

#region PUBLIC FUNCTIONS
## Updates the displayed information in the centre panel.
func update_info() -> void:
	for child in centre_panel.get_children():
		child.queue_free()
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
	# Display laws by category
	for category in laws_by_category.keys():
		# Add category header
		var category_label := Label.new()
		category_label.text = "%s Laws" % category
		category_label.add_theme_font_size_override("font_size", 20)
		centre_panel.add_child(category_label)
		# Add laws in this category
		for law in laws_by_category[category]:
			var law_id: String = law.get("id")
			var is_active: bool = _sim.demesne.is_law_active(law_id)
			var law_panel: PanelContainer = _create_law_panel(law, is_active)
			centre_panel.add_child(law_panel)
#endregion

#region PRIVATE FUNCTIONS
func _ready() -> void:
	ReferenceRegistry.reference_registered.connect(_on_reference_registered)
	if EventBusGame.has_signal("turn_complete"):
		EventBusGame.turn_complete.connect(update_info)
	# Attempt to get sim if already registered
	var sim_ref = ReferenceRegistry.get_reference(Constants.ReferenceKey.SIM)
	if sim_ref:
		_set_sim(sim_ref)
	update_info()

func _add_error_message(message: String) -> void:
	var label := Label.new()
	label.text = message
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	centre_panel.add_child(label)

func _on_reference_registered(key: int, value: Object) -> void:
	if key == Constants.ReferenceKey.SIM:
		_set_sim(value)

func _set_sim(sim_ref: Sim) -> void:
	_sim = sim_ref
	if _sim.demesne:
		_sim.demesne.law_enacted.connect(_on_law_enacted)
		_sim.demesne.law_repealed.connect(_on_law_repealed)
	update_info()

func _on_law_enacted(law: Law) -> void:
	update_info()

func _on_law_repealed(law_id: String) -> void:
	update_info()

func _create_law_panel(law_data: Dictionary, is_active: bool) -> PanelContainer:
	var law_id: String = law_data.get("id")
	var panel := PanelContainer.new()
	var vbox := VBoxContainer.new()
	panel.add_child(vbox)
	# Top row with name, description, and buttons
	var top_row := HBoxContainer.new()
	vbox.add_child(top_row)
	# Law name
	var name_label := Label.new()
	name_label.text = law_data.get("name")
	name_label.custom_minimum_size.x = 120
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(name_label)
	# Description
	var description_label := Label.new()
	description_label.text = law_data.get("description")
	description_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	top_row.add_child(description_label)
	# Buttons
	var button_container := HBoxContainer.new()
	button_container.custom_minimum_size.x = 170
	top_row.add_child(button_container)
	var enact_button := Button.new()
	enact_button.text = "Enact"
	enact_button.custom_minimum_size = Vector2(80, 30)
	enact_button.disabled = is_active
	enact_button.pressed.connect(_on_law_button_pressed.bind(law_id, false))
	button_container.add_child(enact_button)
	var repeal_button := Button.new()
	repeal_button.text = "Repeal"
	repeal_button.custom_minimum_size = Vector2(80, 30)
	repeal_button.disabled = not is_active
	repeal_button.pressed.connect(_on_law_button_pressed.bind(law_id, true))
	button_container.add_child(repeal_button)
	# Add parameters if any
	var parameters: Dictionary = law_data.get("parameters", {})
	if not parameters.is_empty():
		var param_container := HBoxContainer.new()
		vbox.add_child(param_container)
		# Add indentation
		var spacer := Control.new()
		spacer.custom_minimum_size.x = 40
		param_container.add_child(spacer)
		# Add parameter controls
		for param_name in parameters:
			var param_info = parameters[param_name]
			var options = _sim.demesne.law_registry.get_parameter_options(law_id, param_name)
			if not options.is_empty():
				var current_value = param_info.default
				if is_active:
					var law = _sim.demesne.get_law(law_id)
					if law:
						current_value = law.get_parameter(param_name)
				# Parameter label
				var param_label := Label.new()
				param_label.text = param_info.name + ": "
				param_container.add_child(param_label)
				# Value buttons
				for value in options:
					var value_button := Button.new()
					value_button.text = str(value) + "%"
					value_button.toggle_mode = true
					value_button.button_pressed = is_active and is_equal_approx(value, current_value)
					value_button.disabled = not is_active
					value_button.custom_minimum_size = Vector2(50, 30)
					value_button.pressed.connect(_on_parameter_button_pressed.bind(law_id, param_name, value))
					param_container.add_child(value_button)
	return panel

func _on_law_button_pressed(law_id: String, is_active: bool) -> void:
	if is_active:
		_sim.demesne.repeal_law(law_id)
	else:
		_sim.demesne.enact_law(law_id)
	update_info()

func _on_parameter_button_pressed(law_id: String, param_name: String, value: float) -> void:
	var law = _sim.demesne.get_law(law_id)
	if law:
		law.set_parameter(param_name, value)
		update_info()
#endregion
