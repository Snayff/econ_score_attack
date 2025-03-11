## time-related functionality
#@icon("")
class_name Chrono
extends Node


#region SIGNALS

#endregion


#region ON READY (for direct children only)
@onready var _timer_turn: Timer = $TimerTurn

#endregion


#region EXPORTS
# @export_group("Component Links")
#
@export_group("Details")
## how long each turn is, in seconds
@export var _turn_duration: float = 2.0
#endregion


#region VARS
## if turn timer is counting down
var is_running: bool = false
## what turn number, counting up from 0
var turn_num: int = 0
## seconds left in current turn
var turn_time_remaining: float:
	set(x):
		push_error("Can't set directly")
	get:
		return _timer_turn.time_left
#endregion


#region FUNCS
func _ready() -> void:
	## timer timeout connections
	# next turn
	_timer_turn.timeout.connect(_timer_turn.start.bind(_turn_duration))
	# increment turn num
	_timer_turn.timeout.connect(func(): turn_num += 1)
	# announce turn completion
	_timer_turn.timeout.connect(EventBus.turn_complete.emit)

	## listen to input commands
	EventBus.toggle_turn_timer.connect(toggle_is_running)


## pause or unpause turn timer
func toggle_is_running() -> void:
	if is_running:
		_timer_turn.paused = true

	else:
		_timer_turn.paused = false
		if _timer_turn.is_stopped():
			_timer_turn.start(_turn_duration)

	is_running = !is_running

#endregion
