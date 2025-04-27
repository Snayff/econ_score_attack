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
signal tile_selected(tile_id: int)
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
var _tiles: Array = []
var _selected_tile_id: int = -1
#endregion


#region PUBLIC FUNCTIONS
## Sets the viewport origin and updates the grid.
## @param origin: Vector2i, new top-left tile index
func set_viewport_origin(origin: Vector2i) -> void:
	viewport_origin = origin
	_update_grid()

## Gets the current viewport origin.
## @return: Vector2i
func get_viewport_origin() -> Vector2i:
	return viewport_origin

## Sets the selected tile by ID (for test automation or programmatic selection).
## @param tile_id: int
func set_selected_tile(tile_id: int) -> void:
	_selected_tile_id = tile_id
	_update_grid()
#endregion


#region PRIVATE FUNCTIONS
func _ready() -> void:
	print("[WorldViewPanelUI] _ready() called")
	print("_grid_container: ", _grid_container)
	print("_btn_scroll_up: ", _btn_scroll_up)
	print("_btn_scroll_down: ", _btn_scroll_down)
	print("_btn_scroll_left: ", _btn_scroll_left)
	print("_btn_scroll_right: ", _btn_scroll_right)
	_generate_mock_tiles()
	_connect_scroll_buttons()
	_update_grid()

func _generate_mock_tiles() -> void:
	_tiles.clear()
	var DataLandParcel = preload("res://scripts/data/data_land_parcel.gd")
	for y in range(WORLD_HEIGHT):
		for x in range(WORLD_WIDTH):
			var idx = y * WORLD_WIDTH + x
			var parcel = DataLandParcel.new(x, y, "plains")
			_tiles.append(parcel)

func _connect_scroll_buttons() -> void:
	_btn_scroll_up.pressed.connect(func(): _on_scroll(Vector2i(0, -1)))
	_btn_scroll_down.pressed.connect(func(): _on_scroll(Vector2i(0, 1)))
	_btn_scroll_left.pressed.connect(func(): _on_scroll(Vector2i(-1, 0)))
	_btn_scroll_right.pressed.connect(func(): _on_scroll(Vector2i(1, 0)))

func _on_scroll(direction: Vector2i) -> void:
	var new_origin = viewport_origin + direction
	new_origin.x = clamp(new_origin.x, 0, WORLD_WIDTH - GRID_SIZE)
	new_origin.y = clamp(new_origin.y, 0, WORLD_HEIGHT - GRID_SIZE)
	if new_origin != viewport_origin:
		viewport_origin = new_origin
		_update_grid()

func _update_grid() -> void:
	for child in _grid_container.get_children():
		child.queue_free()
	for y in range(GRID_SIZE):
		for x in range(GRID_SIZE):
			var world_x = viewport_origin.x + x
			var world_y = viewport_origin.y + y
			var btn = Button.new()
			btn.custom_minimum_size = Vector2(48, 48)
			if world_x >= WORLD_WIDTH or world_y >= WORLD_HEIGHT:
				btn.text = ""
				btn.disabled = true
			else:
				var idx = world_y * WORLD_WIDTH + world_x
				btn.text = str(idx)
				btn.disabled = false
				btn.pressed.connect(_on_tile_pressed.bind(idx))
				if idx == _selected_tile_id:
					btn.add_theme_color_override("font_color", Color(1, 1, 0)) # Highlight selected
					btn.add_theme_color_override("bg_color", Color(0.8, 0.8, 0.2))
				else:
					btn.add_theme_color_override("font_color", Color(1, 1, 1))
					btn.add_theme_color_override("bg_color", Color(0.2, 0.2, 0.2))
			_grid_container.add_child(btn)
	print("Grid children count: ", _grid_container.get_child_count())

func _on_tile_pressed(tile_id: int) -> void:
	_selected_tile_id = tile_id
	emit_signal("tile_selected", tile_id)
	_update_grid()
#endregion
