## Notification System
##
## A modular system for displaying notifications and visual feedback to the player.
##
## System Overview:
##   The Notification System provides a centralised, reusable way to display notifications (info, success, warning, error) and floating visual feedback messages in the UI. It is designed to be triggered from anywhere in the game via signals, and is fully decoupled from game logic.
##
## Usage:
##   - To show a notification:
##       EventBusUI.show_notification.emit("Message", "info")
##   - To show visual feedback at a position:
##       EventBusUI.show_visual_feedback.emit("Feedback!", Vector2(100, 200))
##
## Integration:
##   - Instanced as a child of MainUI in main_ui.tscn.
##   - Signals are connected in _ready().
##   - Handles display, animation, and removal of messages automatically.
##
## Example:
##   See scripts/ui/main_ui.gd for an example of emitting a notification on startup.
##
## Related Files:
##   - scenes/ui/notification_system.tscn
##   - scripts/ui/notification_system.gd
##
## Extending:
##   - Add new notification types by extending NOTIFICATION_TYPES.
##   - Customise appearance by editing _create_notification/_create_feedback.

class_name NotificationSystem
extends Control


#region CONSTANTS

const NOTIFICATION_DURATION := 3.0
const FEEDBACK_DURATION := 1.0

const NOTIFICATION_TYPES := {
	"info": Color(0.2, 0.6, 1.0),
	"success": Color(0.2, 0.8, 0.2),
	"warning": Color(1.0, 0.8, 0.2),
	"error": Color(1.0, 0.2, 0.2)
}

#endregion


#region SIGNALS

#endregion


#region ON READY

@onready var _notification_container: VBoxContainer = $NotificationContainer
@onready var _feedback_container: Control = $FeedbackContainer

#endregion


#region PUBLIC FUNCTIONS

## 	Initialises the Notification System, connecting required signals and asserting node references.
## @return void
func _ready() -> void:
	assert(_notification_container != null, "NotificationContainer node not found")
	assert(_feedback_container != null, "FeedbackContainer node not found")

	EventBusUI.show_notification.connect(_on_show_notification)
	EventBusUI.show_visual_feedback.connect(_on_show_visual_feedback)

##	Displays a notification message in the notification area.
## 	@param message: The message to display.
##	@param type: The notification type (info, success, warning, error).
##	@return void
func show_notification(message: String, type: String = "info") -> void:
	var notification := _create_notification(message, type)
	_notification_container.add_child(notification)

	# Remove after duration
	await get_tree().create_timer(NOTIFICATION_DURATION).timeout
	notification.queue_free()

##	Displays a floating feedback message at a given position, animating it upwards and fading out.
##	@param message: The feedback message to display.
##	@param position: The screen position to display the feedback.
##	@return void
func show_visual_feedback(message: String, position_: Vector2) -> void:

	var feedback := _create_feedback(message)
	feedback.position = position_
	_feedback_container.add_child(feedback)

	# Animate and remove
	var tween := create_tween()
	tween.tween_property(feedback, "position:y", position_.y - 50, FEEDBACK_DURATION)
	tween.tween_property(feedback, "modulate:a", 0.0, FEEDBACK_DURATION)
	await tween.finished
	feedback.queue_free()

#endregion


#region PRIVATE FUNCTIONS

func _create_notification(message: String, type: String) -> Label:
	var label := Label.new()
	label.text = message
	label.add_theme_color_override("font_color", NOTIFICATION_TYPES.get(type, Color.WHITE))
	return label


func _create_feedback(message: String) -> Label:
	var label := Label.new()
	label.text = message
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label


func _on_show_notification(message: String, type: String) -> void:
	show_notification(message, type)


func _on_show_visual_feedback(message: String, position_: Vector2) -> void:
	show_visual_feedback(message, position_)

#endregion
