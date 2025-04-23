## Chrono
## Manages time-related functionality in the simulation.
## Handles turn timing and progression.
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
## How long each turn is, in seconds
@export var _turn_duration: float = 2.0
#endregion


#region VARS
## Whether the turn timer is counting down
var is_running: bool = false
## Current turn number, counting up from 0
var turn_num: int = 0
## Seconds left in the current turn
var turn_time_remaining: float:
	set(x):
		push_error("Can't set directly")
	get:
		return _timer_turn.time_left
#endregion


#region FUNCS
## Initialises the Chrono class and connects signals
func _ready() -> void:
	connect_timer_signals()
	connect_event_signals()
	EventBusGame.turn_complete.connect(_on_turn_complete)

## Connects timer signals for turn progression
func connect_timer_signals() -> void:
	# Next turn
	_timer_turn.timeout.connect(_timer_turn.start.bind(_turn_duration))
	# Increment turn number
	_timer_turn.timeout.connect(func(): turn_num += 1)
	# Announce turn completion
	_timer_turn.timeout.connect(EventBusGame.turn_complete.emit)

## Connects event signals for timer control
func connect_event_signals() -> void:
	# Listen to input commands
	EventBusUI.toggle_turn_timer.connect(toggle_is_running)

## Pauses or unpauses the turn timer
func toggle_is_running() -> void:
	if is_running:
		pause_timer()
	else:
		unpause_timer()
	
	is_running = !is_running

## Pauses the turn timer
func pause_timer() -> void:
	_timer_turn.paused = true

## Unpauses the turn timer and starts it if stopped
func unpause_timer() -> void:
	_timer_turn.paused = false
	if _timer_turn.is_stopped():
		_timer_turn.start(_turn_duration)

func _on_turn_complete() -> void:
	pass
#endregion
