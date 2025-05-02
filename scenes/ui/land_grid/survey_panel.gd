## UI panel for managing land parcel surveys
extends PanelContainer

#region SIGNALS


#endregion


#region EXPORTS


#endregion


#region CONSTANTS


#endregion


#region ON READY

var _current_x: int = -1
var _current_y: int = -1
var _is_surveying: bool = false

@onready var _progress_bar: ProgressBar = %ProgressBar
@onready var _survey_button: Button = %SurveyButton
@onready var _cancel_button: Button = %CancelButton

func _ready() -> void:
	_connect_signals()
	_setup_ui()

#endregion


#region PUBLIC FUNCTIONS

## Updates the panel for a new parcel
func update_parcel(x: int, y: int) -> void:
	_current_x = x
	_current_y = y
	_update_ui_state()

#endregion


#region PRIVATE FUNCTIONS

func _connect_signals() -> void:
	_survey_button.pressed.connect(_on_survey_button_pressed)
	_cancel_button.pressed.connect(_on_cancel_button_pressed)

	EventBusGame.survey_started.connect(_on_survey_started)
	EventBusGame.survey_progress_updated.connect(_on_survey_progress_updated)
	EventBusGame.survey_completed.connect(_on_survey_completed)


func _setup_ui() -> void:
	_progress_bar.min_value = 0.0
	_progress_bar.max_value = 1.0
	_progress_bar.value = 0.0
	_cancel_button.hide()


func _update_ui_state() -> void:
	if _current_x < 0 or _current_y < 0:
		_survey_button.disabled = true
		return

	var progress: float = SurveyManager.get_survey_progress(_current_x, _current_y)
	var parcel := World.get_parcel(_current_x, _current_y)
	var discovered_aspects: Array[String] = []
	if parcel != null:
		discovered_aspects.assign(parcel.get_aspect_storage().get_discovered_aspect_ids())

	# If already surveyed
	if not discovered_aspects.is_empty():
		_survey_button.disabled = true
		_survey_button.text = "Surveyed"
		_progress_bar.value = 1.0
		_cancel_button.hide()
		return

	# If survey in progress
	if progress >= 0:
		_survey_button.hide()
		_cancel_button.show()
		_progress_bar.value = progress
		return

	# Ready for survey
	_survey_button.show()
	_survey_button.disabled = false
	_survey_button.text = "Start Survey"
	_cancel_button.hide()
	_progress_bar.value = 0.0


func _on_survey_button_pressed() -> void:
	if _current_x < 0 or _current_y < 0:
		return

	EventBusGame.request_survey.emit(_current_x, _current_y)


func _on_cancel_button_pressed() -> void:
	if _current_x < 0 or _current_y < 0:
		return

	SurveyManager.cancel_survey(_current_x, _current_y)
	_update_ui_state()


func _on_survey_started(x: int, y: int) -> void:
	if x == _current_x and y == _current_y:
		_update_ui_state()


func _on_survey_progress_updated(x: int, y: int, progress: float) -> void:
	if x == _current_x and y == _current_y:
		_progress_bar.value = progress


func _on_survey_completed(x: int, y: int, _discovered_aspects: Array) -> void:
	if x == _current_x and y == _current_y:
		_update_ui_state()

#endregion
