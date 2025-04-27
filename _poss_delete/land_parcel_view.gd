## A UI component that displays a single land parcel and handles its interactions.
## This component visualizes terrain, resources, and improvements for a single parcel.
class_name LandParcelView
extends Control


#region CONSTANTS

const TERRAIN_COLORS := {
	"plains": Color(0.7, 0.9, 0.4),
	"forest": Color(0.2, 0.6, 0.3),
	"mountains": Color(0.6, 0.6, 0.6)
}

const HIGHLIGHT_COLOR := Color(1.0, 1.0, 0.0, 0.3)
const RESOURCE_ICON_SIZE := Vector2(16, 16)

#endregion


#region SIGNALS

## Emitted when this parcel is clicked
signal parcel_clicked(x: int, y: int)

#endregion


#region EXPORTS

## The coordinates of this parcel in the grid
@export var coordinates: Vector2i = Vector2i.ZERO

#endregion


#region ON READY

var _base_color: Color = Color.WHITE
var _is_highlighted: bool = false
var _current_parcel_data: DataLandParcel = null

#endregion


#region PUBLIC FUNCTIONS

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)


func update_display(parcel_data: DataLandParcel) -> void:
	_current_parcel_data = parcel_data
	_base_color = TERRAIN_COLORS.get(parcel_data.terrain_type, Color.WHITE)
	queue_redraw()


func set_highlighted(highlight: bool) -> void:
	_is_highlighted = highlight
	queue_redraw()

#endregion


#region PRIVATE FUNCTIONS

func _draw() -> void:
	if not _current_parcel_data:
		return

	# Draw base terrain
	draw_rect(Rect2(Vector2.ZERO, size), _base_color)

	# Draw pollution overlay
	if _current_parcel_data.pollution_level > 0:
		var pollution_color := Color(0.2, 0.2, 0.2, _current_parcel_data.pollution_level * 0.5)
		draw_rect(Rect2(Vector2.ZERO, size), pollution_color)

	# Draw resources if surveyed
	if _current_parcel_data.is_surveyed:
		var resource_pos := Vector2(4, 4)
		for resource_id in _current_parcel_data.resources:
			var resource = _current_parcel_data.resources[resource_id]
			if resource.discovered:
				# This is a placeholder - in a real implementation we would load proper resource icons
				draw_circle(resource_pos, 4, Color.YELLOW)
				resource_pos.x += 12

	# Draw building if present
	if _current_parcel_data.building_id:
		# This is a placeholder - in a real implementation we would load proper building sprites
		draw_rect(Rect2(Vector2(size.x/4, size.y/4), size/2), Color.BLUE)

	# Draw improvements
	for improvement_id in _current_parcel_data.improvements:
		var level = _current_parcel_data.improvements[improvement_id]
		# This is a placeholder - in a real implementation we would load proper improvement icons
		draw_circle(Vector2(size.x - 8, 8), 4 * level, Color.GREEN)

	# Draw highlight if selected
	if _is_highlighted:
		draw_rect(Rect2(Vector2.ZERO, size), HIGHLIGHT_COLOR)

	# Draw border
	draw_rect(Rect2(Vector2.ZERO, size), Color.BLACK, false)


func _on_mouse_entered() -> void:
	set_highlighted(true)


func _on_mouse_exited() -> void:
	set_highlighted(false)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			parcel_clicked.emit(coordinates.x, coordinates.y)

#endregion
