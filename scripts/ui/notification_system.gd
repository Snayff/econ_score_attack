## A system for displaying notifications and visual feedback to the user
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

func _ready() -> void:
    assert(_notification_container != null, "NotificationContainer node not found")
    assert(_feedback_container != null, "FeedbackContainer node not found")
    
    EventBusUI.show_notification.connect(_on_show_notification)
    EventBusUI.show_visual_feedback.connect(_on_show_visual_feedback)


func show_notification(message: String, type: String = "info") -> void:
    var notification := _create_notification(message, type)
    _notification_container.add_child(notification)
    
    # Remove after duration
    await get_tree().create_timer(NOTIFICATION_DURATION).timeout
    notification.queue_free()


func show_visual_feedback(message: String, position: Vector2) -> void:
    var feedback := _create_feedback(message)
    feedback.position = position
    _feedback_container.add_child(feedback)
    
    # Animate and remove
    var tween := create_tween()
    tween.tween_property(feedback, "position:y", position.y - 50, FEEDBACK_DURATION)
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


func _on_show_visual_feedback(message: String, position: Vector2) -> void:
    show_visual_feedback(message, position)

#endregion 