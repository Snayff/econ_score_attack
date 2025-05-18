## SurveyManager: Handles surveying for a single demesne.
## Usage: Attach as a child/component to a Demesne node.
## Survey state is tracked per demesne in this component, not on the parcel object.
## Last Updated: 2025-05-18

class_name SurveyManager
extends Node

#region SIGNALS
signal survey_started(x: int, y: int)
signal survey_progress_updated(x: int, y: int, progress: float)
signal survey_completed(x: int, y: int, discovered_aspects: Array)
#endregion

#region CONSTANTS
const SURVEY_TURNS := 3
const PROGRESS_PER_TURN := 1.0 / float(SURVEY_TURNS)
#endregion

#region VARS
var _active_surveys: Dictionary = {} # Vector2i -> {progress, turns_remaining}
var _surveyed_parcels: Dictionary = {} # Vector2i -> true
var _parcel_accessor: Callable = Callable() # Set by demesne to access parcels
#endregion

#region PUBLIC FUNCTIONS
## Sets the callable used to access parcels by coordinates (from the demesne)
func set_parcel_accessor(accessor: Callable) -> void:
	_parcel_accessor = accessor

## Gets a parcel using the accessor
func _get_parcel(x: int, y: int):
	if not _parcel_accessor.is_null():
		return _parcel_accessor.call(x, y)
	return null

## Starts a survey on a parcel
func start_survey(x: int, y: int) -> bool:
	var coords = Vector2i(x, y)
	if _surveyed_parcels.has(coords) or _active_surveys.has(coords):
		return false
	var parcel = _get_parcel(x, y)
	if parcel == null:
		return false
	_active_surveys[coords] = {
		"progress": 0.0,
		"turns_remaining": SURVEY_TURNS
	}
	emit_signal("survey_started", x, y)
	return true

## Gets the survey progress for a parcel
func get_survey_progress(x: int, y: int) -> float:
	var coords = Vector2i(x, y)
	if not _active_surveys.has(coords):
		return -1.0
	return _active_surveys[coords]["progress"]

## Checks if a parcel is surveyed for this demesne
func is_parcel_surveyed(x: int, y: int) -> bool:
	return _surveyed_parcels.has(Vector2i(x, y))

## Advances all surveys by 1 turn
func advance_turn() -> void:
	var completed: Array = []
	for coords in _active_surveys.keys():
		var survey = _active_surveys[coords]
		survey["turns_remaining"] -= 1
		survey["progress"] = minf(1.0, survey["progress"] + PROGRESS_PER_TURN)
		emit_signal("survey_progress_updated", coords.x, coords.y, survey["progress"])
		if survey["turns_remaining"] <= 0:
			completed.append(coords)
	for coords in completed:
		_complete_survey(coords)
#endregion

#region PRIVATE FUNCTIONS
func _complete_survey(coords: Vector2i) -> void:
	var survey = _active_surveys[coords]
	var parcel = _get_parcel(coords.x, coords.y)
	if parcel == null:
		_active_surveys.erase(coords)
		return
	# Mark as surveyed for this demesne only
	_surveyed_parcels[coords] = true
	var discovered_aspects = parcel.complete_survey() if parcel.has_method("complete_survey") else []
	_active_surveys.erase(coords)
	emit_signal("survey_completed", coords.x, coords.y, discovered_aspects)
#endregion
