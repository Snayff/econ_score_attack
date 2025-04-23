extends Control

## Displays information about all possible laws in the demesne.
## Shows laws grouped by category, with options to enact/repeal and modify parameters.
## in the format of:
## Law | Description | [enact] [repeal]
## 		Option Desc: [option1], [option2]
## Example:
## [Sales Tax]  [A percentage-based tax applied to all goods...]  [Enact] [Repeal]
##    Tax Rate: [5%] [10%] [15%] [20%] [25%]
##
## Example usage:
## var laws_info = rtl_laws_info.new()


#region EXPORTS

@export var sim: Sim

#endregion


#region CONSTANTS

const PARAMETER_VALUES = {
	"tax_rate": [5.0, 10.0, 15.0, 20.0, 25.0]
}

#endregion


#region SIGNALS


#endregion


#region ON READY

@onready var laws_container: VBoxContainer = %LawsContainer

func _ready() -> void:
	# Ensure we have our required nodes
	assert(laws_container != null, "LawsContainer node not found!")

	# Find the Sim node if not provided
	if not sim:
		sim = get_node("/root/Main/Sim")

	if sim:
		sim.sim_initialized.connect(_on_sim_initialized)
		EventBus.turn_complete.connect(update_info)

	update_info()


#endregion


#region PUBLIC FUNCTIONS

func update_info() -> void:
	_update_info()


#endregion


#region PRIVATE FUNCTIONS

func _on_sim_initialized() -> void:
	if sim and sim.demesne:
		sim.demesne.law_enacted.connect(_on_law_enacted)
		sim.demesne.law_repealed.connect(_on_law_repealed)
	update_info()


func _on_law_enacted(law: Law) -> void:
	update_info()


func _on_law_repealed(law_id: String) -> void:
	update_info()


func _update_info() -> void:
	# Safety check for our container
	if not laws_container:
		push_error("LawsContainer node not found!")
		return

	# Clear existing laws
	for child in laws_container.get_children():
		child.queue_free()

	if not sim or not sim.demesne:
		var label = Label.new()
		label.text = "No simulation data available"
		laws_container.add_child(label)
		return

	var law_config = Library.get_config("laws")
	if not law_config:
		var label = Label.new()
		label.text = "No laws configuration available"
		laws_container.add_child(label)
		return

	# Group laws by category
	var laws_by_category = {}
	for law_data in law_config.get("laws", []):
		var category = law_data.get("category", "Uncategorized")
		if not laws_by_category.has(category):
			laws_by_category[category] = []
		laws_by_category[category].append(law_data)

	# Display laws by category
	for category in laws_by_category.keys():
		# Add category header
		var category_label = Label.new()
		category_label.text = "%s Laws" % category
		category_label.add_theme_font_size_override("font_size", 20)
		laws_container.add_child(category_label)

		# Add laws in this category
		for law_data in laws_by_category[category]:
			var law_id = law_data.get("id")
			var is_active = sim.demesne.is_law_active(law_id)

			# Create law panel
			var law_panel = _create_law_panel(law_data, is_active)
			laws_container.add_child(law_panel)


func _create_law_panel(law_data: Dictionary, is_active: bool) -> PanelContainer:
	var law_id = law_data.get("id")

	# Create the panel
	var panel = PanelContainer.new()

	# Main VBox for law content
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)

	# Top row with name, description, and buttons
	var top_row = HBoxContainer.new()
	vbox.add_child(top_row)

	# Law name
	var name_label = Label.new()
	name_label.text = law_data.get("name")
	name_label.custom_minimum_size.x = 120
	top_row.add_child(name_label)

	# Description
	var description_label = Label.new()
	description_label.text = law_data.get("description")
	description_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	top_row.add_child(description_label)

	# Buttons
	var button_container = HBoxContainer.new()
	button_container.custom_minimum_size.x = 170
	top_row.add_child(button_container)

	var enact_button = Button.new()
	enact_button.text = "Enact"
	enact_button.custom_minimum_size = Vector2(80, 30)
	enact_button.disabled = is_active
	enact_button.pressed.connect(_on_law_button_pressed.bind(law_id, false))
	button_container.add_child(enact_button)

	var repeal_button = Button.new()
	repeal_button.text = "Repeal"
	repeal_button.custom_minimum_size = Vector2(80, 30)
	repeal_button.disabled = not is_active
	repeal_button.pressed.connect(_on_law_button_pressed.bind(law_id, true))
	button_container.add_child(repeal_button)

	# Add parameters if any
	var parameters = law_data.get("parameters", {})
	if not parameters.is_empty():
		var param_container = HBoxContainer.new()
		vbox.add_child(param_container)

		# Add indentation
		var spacer = Control.new()
		spacer.custom_minimum_size.x = 40
		param_container.add_child(spacer)

		# Add parameter controls
		for param_name in parameters:
			var param_info = parameters[param_name]
			var options = sim.demesne.law_registry.get_parameter_options(law_id, param_name)
			if not options.is_empty():
				var current_value = param_info.default
				if is_active:
					var law = sim.demesne.get_law(law_id)
					if law:
						current_value = law.get_parameter(param_name)

				# Parameter label
				var param_label = Label.new()
				param_label.text = param_info.name + ": "
				param_container.add_child(param_label)

				# Value buttons
				for value in options:
					var value_button = Button.new()
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
		sim.demesne.repeal_law(law_id)
	else:
		sim.demesne.enact_law(law_id)

	update_info()


func _on_parameter_button_pressed(law_id: String, param_name: String, value: float) -> void:
	var law = sim.demesne.get_law(law_id)
	if law:
		law.set_parameter(param_name, value)
		update_info()


#endregion
