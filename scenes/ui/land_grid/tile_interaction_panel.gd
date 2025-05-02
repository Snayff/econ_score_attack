"""
TileInteractionPanelUI

Panel for tile interaction actions (e.g., build button, survey progress).
Usage: Attach to TileInteractionPanel.tscn root node.
"""

class_name TileInteractionPanelUI
extends PanelContainer

#region CONSTANTS
#endregion


#region SIGNALS
#endregion


#region ON READY
@onready var _progress_bar: ProgressBar = %ProgressBar
@onready var _survey_button: Button = %btn_survey

func _ready() -> void:
	_connect_signals()
	_setup_ui()
#endregion


#region EXPORTS
#endregion


#region VARS
var _current_x: int = -1
var _current_y: int = -1
#endregion


#region PUBLIC FUNCTIONS
func update_for_tile(tile_data, demesne = null) -> void:
	if tile_data:
		_current_x = tile_data.x
		_current_y = tile_data.y
	else:
		_current_x = -1
		_current_y = -1

	_update_ui_state()
#endregion


#region PRIVATE FUNCTIONS
func _connect_signals() -> void:
	if _survey_button:
		_survey_button.pressed.connect(_on_survey_pressed)

	EventBusGame.survey_started.connect(_on_survey_started)
	EventBusGame.survey_progress_updated.connect(_on_survey_progress_updated)
	EventBusGame.survey_completed.connect(_on_survey_completed)


func _setup_ui() -> void:
	if _progress_bar:
		_progress_bar.min_value = 0.0
		_progress_bar.max_value = 1.0
		_progress_bar.value = 0.0
		_progress_bar.hide()

	if _survey_button:
		_survey_button.tooltip_text = "Survey this parcel to reveal its details."


func _update_ui_state() -> void:
	if _current_x < 0 or _current_y < 0:
		if _survey_button:
			_survey_button.hide()
		if _progress_bar:
			_progress_bar.hide()
		return

	var progress: float = SurveyManager.get_survey_progress(_current_x, _current_y)
	var parcel := World.get_parcel(_current_x, _current_y)
	var discovered_aspects: Array[String] = []
	if parcel != null:
		discovered_aspects.assign(parcel.get_aspect_storage().get_discovered_aspect_ids())

	# If already surveyed
	if not discovered_aspects.is_empty():
		if _survey_button:
			_survey_button.hide()
		if _progress_bar:
			_progress_bar.hide()
		return

	# If survey in progress
	if progress >= 0:
		if _survey_button:
			_survey_button.hide()
		if _progress_bar:
			_progress_bar.value = progress
			_progress_bar.show()
		return

	# Ready for survey
	if _survey_button:
		_survey_button.show()
		_survey_button.disabled = false
	if _progress_bar:
		_progress_bar.value = 0.0
		_progress_bar.hide()


func _on_survey_pressed() -> void:
	if _current_x < 0 or _current_y < 0:
		return

	EventBusGame.request_survey.emit(_current_x, _current_y)


func _on_survey_started(x: int, y: int) -> void:
	if x == _current_x and y == _current_y:
		_update_ui_state()


func _on_survey_progress_updated(x: int, y: int, progress: float) -> void:
	if x == _current_x and y == _current_y and _progress_bar:
		_progress_bar.value = progress


func _on_survey_completed(x: int, y: int, _discovered_aspects: Array) -> void:
	if x == _current_x and y == _current_y:
		_update_ui_state()


func _exit_tree() -> void:
	if _survey_button:
		_survey_button.pressed.disconnect(_on_survey_pressed)

	EventBusGame.survey_started.disconnect(_on_survey_started)
	EventBusGame.survey_progress_updated.disconnect(_on_survey_progress_updated)
	EventBusGame.survey_completed.disconnect(_on_survey_completed)
#endregion
