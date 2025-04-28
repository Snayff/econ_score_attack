"""
WorldViewPanelUI

Panel for displaying the world tile grid with scrollable viewport.
Usage: Attach to WorldViewPanel.tscn root node.

- Shows a 5x5 grid of tile buttons, each displaying its tile index.
- Arrow buttons scroll the visible viewport.
- Uses DataLandParcel for mock data.

Example:
var panel = WorldViewPanelUI.new()
add_child(panel)
"""

class_name WorldViewPanelUI
extends PanelContainer

#region CONSTANTS
const GRID_SIZE: int = 5
const WORLD_WIDTH: int = 10
const WORLD_HEIGHT: int = 10
#endregion


#region SIGNALS
## Emitted when a tile is selected in the grid.
## @param tile_id: int, the selected tile's id
## @param tile_data: DataLandParcel, the selected tile's data
signal tile_selected(tile_id: int, tile_data: DataLandParcel)
#endregion


#region ON READY
@onready var _grid_container: GridContainer = $HBoxContainer/GridContainer
@onready var _btn_scroll_up: Button = $HBoxContainer/VBoxContainer/HBoxContainer_Top/btn_scroll_up
@onready var _btn_scroll_down: Button = $HBoxContainer/VBoxContainer/HBoxContainer_Bottom/btn_scroll_down
@onready var _btn_scroll_left: Button = $HBoxContainer/VBoxContainer/HBoxContainer_Middle/btn_scroll_left
@onready var _btn_scroll_right: Button = $HBoxContainer/VBoxContainer/HBoxContainer_Middle/btn_scroll_right
#endregion


#region EXPORTS
#endregion


#region VARS
var viewport_origin: Vector2i = Vector2i(0, 0)
var _grid_width: int = 0
var _grid_height: int = 0
var _selected_tile_coords: Vector2i = Vector2i(-1, -1)
var _demesne: Node = null
#endregion


#region PUBLIC FUNCTIONS
## Sets the grid dimensions and demesne reference, then updates the grid display.
## @param width: int
## @param height: int
## @param demesne: Node
func set_grid_and_demesne(width: int, height: int, demesne: Node) -> void:
	_grid_width = width
	_grid_height = height
	_demesne = demesne
	# Centre viewport
	viewport_origin = Vector2i((_grid_width - GRID_SIZE) / 2, (_grid_height - GRID_SIZE) / 2)
	viewport_origin.x = clamp(viewport_origin.x, 0, _grid_width - GRID_SIZE)
	viewport_origin.y = clamp(viewport_origin.y, 0, _grid_height - GRID_SIZE)
	_update_grid()

## Gets the current viewport origin.
## @return: Vector2i
func get_viewport_origin() -> Vector2i:
	return viewport_origin

## Sets the selected tile by coordinates.
## @param coords: Vector2i
func set_selected_tile(coords: Vector2i) -> void:
	_selected_tile_coords = coords
	_update_grid()
#endregion


#region PRIVATE FUNCTIONS
func _ready() -> void:
	_connect_scroll_buttons()
	EventBusGame.land_grid_updated.connect(_on_land_grid_updated)
	_update_grid()

func _on_land_grid_updated() -> void:
	_update_grid()

func _connect_scroll_buttons() -> void:
	_btn_scroll_up.pressed.connect(func(): _on_scroll(Vector2i(0, -1)))
	_btn_scroll_down.pressed.connect(func(): _on_scroll(Vector2i(0, 1)))
	_btn_scroll_left.pressed.connect(func(): _on_scroll(Vector2i(-1, 0)))
	_btn_scroll_right.pressed.connect(func(): _on_scroll(Vector2i(1, 0)))

func _on_scroll(direction: Vector2i) -> void:
	if _grid_width == 0 or _grid_height == 0:
		return
	var new_origin = viewport_origin + direction
	new_origin.x = clamp(new_origin.x, 0, _grid_width - GRID_SIZE)
	new_origin.y = clamp(new_origin.y, 0, _grid_height - GRID_SIZE)
	if new_origin != viewport_origin:
		viewport_origin = new_origin
		_update_grid()

## Updates the grid display based on the current viewport and selection.
func _update_grid() -> void:
	for child in _grid_container.get_children():
		child.queue_free()
	if _grid_width == 0 or _grid_height == 0 or _demesne == null:
		return
	for y in range(GRID_SIZE):
		for x in range(GRID_SIZE):
			var world_x = viewport_origin.x + x
			var world_y = viewport_origin.y + y
			var btn = Button.new()
			btn.custom_minimum_size = Vector2(48, 48)
			if world_x >= _grid_width or world_y >= _grid_height:
				btn.text = ""
				btn.disabled = true
			else:
				var parcel = get_node("/root/World").get_parcel(world_x, world_y)
				btn.text = "%d,%d" % [world_x, world_y]
				btn.disabled = false
				btn.pressed.connect(_on_tile_pressed.bind(world_x, world_y))
				# Visual cues for surveyed/unsurveyed (demesne-specific)
				if _demesne.is_parcel_surveyed(world_x, world_y):
					btn.add_theme_color_override("bg_color", Color(0.4, 0.7, 0.4))
				else:
					btn.add_theme_color_override("bg_color", Color(0.2, 0.2, 0.2))
				if _selected_tile_coords == Vector2i(world_x, world_y):
					btn.add_theme_color_override("font_color", Color(1, 1, 0))
					btn.add_theme_color_override("outline_color", Color(1, 1, 0))
					btn.add_theme_constant_override("outline_size", 2)
				else:
					btn.add_theme_color_override("font_color", Color(1, 1, 1))
			_grid_container.add_child(btn)

func _on_tile_pressed(x: int, y: int) -> void:
	_selected_tile_coords = Vector2i(x, y)
	var tile_data = get_node("/root/World").get_parcel(x, y)
	emit_signal("tile_selected", y * _grid_width + x, tile_data)
	_update_grid()
#endregion
