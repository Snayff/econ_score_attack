extends RichTextLabel

## Displays information about all possible laws in the demesne.
## in the format of
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

func _ready() -> void:
	bbcode_enabled = true
	fit_content = true

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
	if not sim or not sim.demesne:
		text = "No simulation data available"
		return

	var law_config = Library.get_config("laws")
	if not law_config:
		text = "No laws configuration available"
		return

	text = "[center][b]Available Laws[/b][/center]\n\n"

	# Group laws by category
	var laws_by_category = {}
	for law_data in law_config.get("laws", []):
		var category = law_data.get("category", "Uncategorized")
		if not laws_by_category.has(category):
			laws_by_category[category] = []
		laws_by_category[category].append(law_data)

	# Display laws by category
	for category in laws_by_category.keys():
		text += "[b]%s Laws[/b]\n" % category

		for law_data in laws_by_category[category]:
			var law_id = law_data.get("id")
			var is_active = sim.demesne.is_law_active(law_id)

			# Create a VBoxContainer for this law's info and controls
			var law_vbox = VBoxContainer.new()
			law_vbox.custom_minimum_size.y = 80
			add_child(law_vbox)

			# Top row: Law name, description, and buttons
			var top_row = HBoxContainer.new()
			top_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			law_vbox.add_child(top_row)

			# Add law name
			var name_label = Label.new()
			name_label.text = law_data.get("name")
			name_label.custom_minimum_size.x = 120
			top_row.add_child(name_label)

			# Add description
			var description_label = Label.new()
			description_label.text = law_data.get("description")
			description_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			top_row.add_child(description_label)

			# Add buttons container
			var button_container = HBoxContainer.new()
			button_container.custom_minimum_size.x = 170
			top_row.add_child(button_container)

			# Add enact button
			var enact_button = Button.new()
			enact_button.text = "Enact"
			enact_button.custom_minimum_size = Vector2(80, 30)
			enact_button.disabled = is_active
			enact_button.pressed.connect(_on_law_button_pressed.bind(law_id, false))
			button_container.add_child(enact_button)

			# Add repeal button
			var repeal_button = Button.new()
			repeal_button.text = "Repeal"
			repeal_button.custom_minimum_size = Vector2(80, 30)
			repeal_button.disabled = not is_active
			repeal_button.pressed.connect(_on_law_button_pressed.bind(law_id, true))
			button_container.add_child(repeal_button)

			# Add parameter controls if the law has parameters
			var parameters = law_data.get("parameters", {})
			if not parameters.is_empty():
				var param_container = HBoxContainer.new()
				param_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				law_vbox.add_child(param_container)

				# Add some indentation
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

						# Add parameter label
						var param_label = Label.new()
						param_label.text = param_info.name + ": "
						param_container.add_child(param_label)

						# Add value buttons
						for value in options:
							var value_button = Button.new()
							value_button.text = str(value) + "%"
							value_button.toggle_mode = true
							value_button.button_pressed = is_active and is_equal_approx(value, current_value)
							value_button.disabled = not is_active
							value_button.custom_minimum_size = Vector2(50, 30)
							value_button.pressed.connect(_on_parameter_button_pressed.bind(law_id, param_name, value))
							param_container.add_child(value_button)

			text += "\n\n"

		text += "\n"


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
