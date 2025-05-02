## SurveyManager
## Global autoload for managing land parcel surveys.
## Handles survey progress, completion, and discovery of aspects.
## Example:
## ```gdscript
## SurveyManager.start_survey(x, y)
## ```

extends Node


#region CONSTANTS
## Number of turns to complete a survey
const SURVEY_TURNS := 3

## Progress increment per turn
const PROGRESS_PER_TURN := 1.0 / float(SURVEY_TURNS)
#endregion


#region SIGNALS
#endregion


#region ON READY
#endregion


#region EXPORTS
#endregion


#region VARS
## Dictionary of active surveys by coordinate key
static var _active_surveys: Dictionary = {}
#endregion


#region PUBLIC FUNCTIONS
## Starts a survey on a parcel
## Returns false if survey already in progress or parcel already surveyed
static func start_survey(x: int, y: int) -> bool:
	if not is_instance_valid(SurveyManager):
		return false
		
	var parcel = World.get_parcel(x, y)
	if parcel == null or parcel.is_surveyed:
		return false
		
	var coord_key := _get_coord_key(x, y)
	if _active_surveys.has(coord_key):
		return false
		
	# Initialize survey data
	_active_surveys[coord_key] = {
		"progress": 0.0,
		"x": x,
		"y": y,
		"turns_remaining": SURVEY_TURNS
	}
	
	EventBusGame.survey_started.emit(x, y)
	return true


## Gets the survey progress for a parcel
## Returns -1 if no survey is active
static func get_survey_progress(x: int, y: int) -> float:
	if not is_instance_valid(SurveyManager):
		return -1.0
		
	var coord_key := _get_coord_key(x, y)
	if not _active_surveys.has(coord_key):
		return -1.0
	return _active_surveys[coord_key].progress


## Process a turn for all active surveys
static func process_turn() -> void:
	if not is_instance_valid(SurveyManager):
		return
		
	var completed_surveys: Array = []
	
	for coord_key in _active_surveys:
		var survey: Dictionary = _active_surveys[coord_key]
		survey.turns_remaining -= 1
		survey.progress = minf(1.0, survey.progress + PROGRESS_PER_TURN)
		
		EventBusGame.survey_progress_updated.emit(
			survey.x,
			survey.y,
			survey.progress
		)
		
		if survey.turns_remaining <= 0:
			completed_surveys.append(coord_key)
			
	for coord_key in completed_surveys:
		_complete_survey(coord_key)
#endregion


#region PRIVATE FUNCTIONS
func _ready() -> void:
	_connect_signals()


static func _connect_signals() -> void:
	EventBusGame.request_survey.connect(_on_request_survey)
	EventBusGame.turn_complete.connect(_on_turn_complete)


static func _complete_survey(coord_key: String) -> void:
	var survey: Dictionary = _active_surveys[coord_key]
	var parcel := World.get_parcel(survey.x, survey.y)
	
	if parcel == null:
		_active_surveys.erase(coord_key)
		return
		
	# Mark parcel as surveyed
	parcel.is_surveyed = true
	
	# Emit completion event with discovered aspects
	EventBusGame.survey_completed.emit(
		survey.x,
		survey.y,
		parcel.get_aspect_storage().get_discovered_aspect_ids()
	)
	
	_active_surveys.erase(coord_key)


static func _on_request_survey(x: int, y: int) -> void:
	start_survey(x, y)


static func _on_turn_complete() -> void:
	process_turn()


static func _get_coord_key(x: int, y: int) -> String:
	return "%d,%d" % [x, y]
#endregion 