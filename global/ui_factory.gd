## UIFactory: Global factory for standardised UI element creation.
## Usage:
##  Use UIFactory to create standard UI elements for viewport panels, sidebars, and buttons.
##  Example: var btn = UIFactory.create_button("OK", _on_ok_pressed)
##
## Last Updated: 2025-05-13
##
extends Node

#region PUBLIC FUNCTIONS
## Creates a header label for the top of a viewport sidebar.
## @param text (String): The label text.
## @return Label: The configured header label.
static func create_viewport_sidebar_header_label(text: String) -> Label:
	var label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(0.8, 0.8, 1.0))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

## Creates a header label for the top of a viewport panel.
## @param text (String): The label text.
## @return Label: The configured header label.
static func create_viewport_panel_header_label(text: String) -> Label:
	var label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(1.0, 1.0, 0.8))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

## Creates a FlowContainer for holding sidebar buttons.
## @return FlowContainer: The configured container.
static func create_viewport_sidebar_button_container() -> FlowContainer:
	var flow = FlowContainer.new()
	flow.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	flow.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	flow.alignment = FlowContainer.ALIGNMENT_CENTER
	flow.custom_minimum_size = Vector2(0, 40)
	return flow

## Creates a standard button.
## @param text (String): The button text.
## @param pressed_func (Callable): Optional function to connect to the pressed signal.
## @return Button: The configured button.
static func create_button(text: String, pressed_func: Variant = null) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if typeof(pressed_func) == TYPE_CALLABLE:
		btn.pressed.connect(pressed_func)
	return btn

## Creates a standard progress bar for sidebar use.
## @param min_value (int): Minimum value of the bar.
## @param max_value (int): Maximum value of the bar.
## @param value (int): Current value of the bar.
## @param tooltip_text (String): Tooltip for the bar.
## @param width (int): Optional width (default 200).
## @param height (int): Optional height (default 24).
## @return ProgressBar: The configured progress bar.
static func create_sidebar_progress_bar(
	min_value: int,
	max_value: int,
	value: int,
	tooltip_text: String = "",
	width: int = 100,
	height: int = 24
	) -> ProgressBar:
	var bar = ProgressBar.new()
	bar.min_value = min_value
	bar.max_value = max_value
	bar.value = value
	bar.step = 1
	bar.size_flags_horizontal = Control.SIZE_FILL
	bar.custom_minimum_size = Vector2(width, height)
	bar.tooltip_text = tooltip_text
	return bar
#endregion
