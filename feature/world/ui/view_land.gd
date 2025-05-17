## ViewLand: Land view using the standardised ABCView layout system.
## Displays information about land tiles in the simulation using the modular UI layout.
## Usage:
##  Inherit from ABCView. Implements update_view() to populate the centre panel and any other regions as needed, using set_centre_content, set_left_sidebar_content, etc. Call refresh() to update the view; this will clear all regions, call update_view(), and automatically show a standard message in any empty region.
##  All user actions in sidebars and top bar should emit the standard signals (left_action_selected, top_tab_selected, right_info_requested) where appropriate.
##  Error and empty state handling is managed by the base class.
##  Uses UIFactory (global autoload) for standard UI element creation.
##
## See: dev/docs/docs/systems/ui.md
## Last Updated: 2025-05-17
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
var _demesne: Node = null
var _grid_dims: Vector2i = Vector2i.ZERO
var _selected_tile_coords: Vector2i = Vector2i.ZERO
var _tile_panels: Dictionary = {}
#endregion

#region PUBLIC FUNCTIONS
## Updates the displayed information in the centre panel.
## Populates the centre panel with a grid of land tiles. Selecting a tile updates the left sidebar.
## @return void
func update_view() -> void:
	_clear_all_children(centre_panel)
	_tile_panels.clear()
	if not _demesne or _grid_dims == Vector2i.ZERO:
		_add_error_message("No demesne or grid data available")
		return
	var grid_width: int = _grid_dims.x
	var grid_height: int = _grid_dims.y
	if grid_width == 0 or grid_height == 0:
		_add_error_message("No land grid available.")
		return
	# Create a grid container for tiles
	var grid = GridContainer.new()
	grid.columns = grid_width
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	# Add each tile as a button
	for y in range(grid_height):
		for x in range(grid_width):
			var tile_data = _demesne.get_parcel(x, y)
			var coords = Vector2i(x, y)
			var tile_btn = _create_tile_panel(tile_data, coords)
			_tile_panels[coords] = tile_btn
			grid.add_child(tile_btn)
	set_centre_content([grid])
	# Select the centre tile by default if none selected
	if _selected_tile_coords == Vector2i.ZERO:
		_selected_tile_coords = Vector2i(grid_width / 2, grid_height / 2)
		_on_tile_panel_selected(_selected_tile_coords)
	elif _selected_tile_coords in _tile_panels:
		_highlight_selected_tile()

#endregion

#region PRIVATE FUNCTIONS
## Called when the node is added to the scene tree. Sets up signals and initialises the view.
## @return void
func _ready() -> void:
	ReferenceRegistry.reference_registered.connect(_on_reference_registered)
	if EventBusGame.has_signal("land_grid_updated"):
		EventBusGame.land_grid_updated.connect(_on_land_grid_updated)
	if World.has_signal("world_grid_updated"):
		World.world_grid_updated.connect(_on_world_grid_updated)
	_grid_dims = World.get_grid_dimensions() if World.has_method("get_grid_dimensions") else Vector2i.ZERO
	_update_sim_and_demesne()
	update_view()

## @null
## Adds an error message label to the centre panel.
## @param message (String): The error message to display.
## @return void
func _add_error_message(message: String) -> void:
	_clear_all_children(centre_panel)
	var label = Label.new()
	label.text = message
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	centre_panel.add_child(label)

## Creates a tile panel button for a given tile.
## @param tile_data (DataLandParcel): The tile's data.
## @param coords (Vector2i): The tile's coordinates.
## @return Button: The constructed tile panel button.
func _create_tile_panel(tile_data: Variant, coords: Vector2i) -> Button:
	var btn = Button.new()
	btn.name = str(coords)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.toggle_mode = true
	btn.focus_mode = Control.FOCUS_ALL
	var surveyed = tile_data and tile_data.is_surveyed
	var label_text = "Tile (" + str(coords.x) + ", " + str(coords.y) + ")"
	if surveyed:
		label_text += "\nSurveyed"
	else:
		label_text += "\nUnsurveyed"
	btn.text = label_text
	btn.pressed.connect(_on_tile_panel_selected.bind(coords))
	btn.mouse_entered.connect(btn.grab_focus)
	# Highlight if selected
	if coords == _selected_tile_coords:
		btn.button_pressed = true
	else:
		btn.button_pressed = false
	return btn

## Highlights the currently selected tile panel.
## @return void
func _highlight_selected_tile() -> void:
	for coords in _tile_panels.keys():
		_tile_panels[coords].button_pressed = (coords == _selected_tile_coords)

## Handles tile panel selection and updates the left sidebar.
## @param coords (Vector2i): The selected tile's coordinates.
## @return void
func _on_tile_panel_selected(coords: Vector2i) -> void:
	_selected_tile_coords = coords
	_highlight_selected_tile()
	_update_left_sidebar(coords)

## Updates the left sidebar with tile details and actions.
## @param coords (Vector2i): The tile's coordinates.
## @return void
func _update_left_sidebar(coords: Vector2i) -> void:
	var sidebar_content: Array[Control] = []
	if not _sim or not _sim.demesne:
		set_left_sidebar_content([])
		return
	var tile_data = _sim.demesne.get_parcel(coords.x, coords.y)
	if not tile_data:
		set_left_sidebar_content([])
		return
	# Tile header
	var name_label: Label = UIFactory.create_viewport_sidebar_header_label("Tile (" + str(coords.x) + ", " + str(coords.y) + ")")
	sidebar_content.append(name_label)
	# Surveyed status
	var surveyed_label = Label.new()
	surveyed_label.text = "Surveyed" if tile_data.is_surveyed else "Unsurveyed"
	sidebar_content.append(surveyed_label)
	# Aspects/resources
	if tile_data.is_surveyed:
		var aspects = tile_data.get_discovered_aspects()
		if aspects.size() > 0:
			for aspect_id in aspects.keys():
				var amount = aspects[aspect_id]
				var aspect_meta = Library.get_land_aspect_by_id(aspect_id)
				var aspect_label = Label.new()
				aspect_label.text = str(aspect_meta.get("f_name", aspect_id)) + ": " + str(amount)
				sidebar_content.append(aspect_label)
		else:
			var no_aspects_label = Label.new()
			no_aspects_label.text = "No discovered aspects."
			sidebar_content.append(no_aspects_label)
	else:
		# Survey button
		var survey_btn = UIFactory.create_button("Survey", _on_survey_button_pressed.bind(coords))
		sidebar_content.append(survey_btn)
	set_left_sidebar_content(sidebar_content)

## Handles survey button press for a tile.
## @param coords (Vector2i): The tile's coordinates.
## @return void
func _on_survey_button_pressed(coords: Vector2i) -> void:
	if _sim and _sim.demesne:
		_sim.demesne.request_survey(coords.x, coords.y)

## Handles updates from the ReferenceRegistry.
## @param key (int): The reference key.
## @param value (Object): The reference value.
## @return void
func _on_reference_registered(key: int, value: Object) -> void:
	if key == Constants.ReferenceKey.SIM:
		_update_sim_and_demesne()
		update_view()

func _on_land_grid_updated() -> void:
	_grid_dims = World.get_grid_dimensions() if World.has_method("get_grid_dimensions") else Vector2i.ZERO
	update_view()

func _on_world_grid_updated() -> void:
	_grid_dims = World.get_grid_dimensions() if World.has_method("get_grid_dimensions") else Vector2i.ZERO
	update_view()

func _update_sim_and_demesne() -> void:
	var sim_ref = ReferenceRegistry.get_reference(Constants.ReferenceKey.SIM)
	if sim_ref:
		_sim = sim_ref
		_demesne = _sim.demesne
	else:
		_sim = null
		_demesne = null

## Handles parcel surveyed signal to refresh the view.
## @param x (int): The x coordinate.
## @param y (int): The y coordinate.
## @param _discovered_resources (Array): The discovered resources.
## @return void
func _on_parcel_surveyed(x: int, y: int, _discovered_resources: Array) -> void:
	update_view()
#endregion
