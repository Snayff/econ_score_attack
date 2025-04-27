## A control panel for land-related actions and information display
class_name LandControlPanel
extends Panel


#region CONSTANTS

const RESOURCE_ITEM_SCENE := preload("res://scenes/ui/land_grid/resource_item.tscn")
const IMPROVEMENT_ITEM_SCENE := preload("res://scenes/ui/land_grid/improvement_item.tscn")

#endregion


#region SIGNALS

#endregion


#region ON READY

@onready var _btn_survey: Button = $MarginContainer/VBoxContainer/btn_Survey
@onready var _btn_build: Button = $MarginContainer/VBoxContainer/btn_Build
@onready var _btn_improve: Button = $MarginContainer/VBoxContainer/btn_Improve
@onready var _vbx_resources: VBoxContainer = $MarginContainer/VBoxContainer/scr_Resources/vbx_Resources
@onready var _vbx_improvements: VBoxContainer = $MarginContainer/VBoxContainer/scr_Improvements/vbx_Improvements

var _selected_coordinates: Vector2i = Vector2i(-1, -1)

#endregion


#region PUBLIC FUNCTIONS

func _ready() -> void:
    assert(_btn_survey != null, "Survey button not found")
    assert(_btn_build != null, "Build button not found")
    assert(_btn_improve != null, "Improve button not found")
    assert(_vbx_resources != null, "Resources container not found")
    assert(_vbx_improvements != null, "Improvements container not found")
    
    _btn_survey.pressed.connect(_on_survey_pressed)
    _btn_build.pressed.connect(_on_build_pressed)
    _btn_improve.pressed.connect(_on_improve_pressed)
    
    # Initially disable buttons until a parcel is selected
    _update_button_states(false)


func update_parcel_info(parcel_data: DataLandParcel) -> void:
    _selected_coordinates = Vector2i(parcel_data.x, parcel_data.y)
    _update_button_states(true)
    
    # Update resources list
    _clear_container(_vbx_resources)
    if parcel_data.is_surveyed:
        for resource_id in parcel_data.resources:
            var resource = parcel_data.resources[resource_id]
            if resource.discovered:
                var resource_item = RESOURCE_ITEM_SCENE.instantiate()
                resource_item.setup(resource_id, resource.amount)
                _vbx_resources.add_child(resource_item)
    
    # Update improvements list
    _clear_container(_vbx_improvements)
    for improvement_id in parcel_data.improvements:
        var level = parcel_data.improvements[improvement_id]
        var improvement_item = IMPROVEMENT_ITEM_SCENE.instantiate()
        improvement_item.setup(improvement_id, level)
        _vbx_improvements.add_child(improvement_item)

#endregion


#region PRIVATE FUNCTIONS

func _clear_container(container: Container) -> void:
    for child in container.get_children():
        child.queue_free()


func _update_button_states(enabled: bool) -> void:
    _btn_survey.disabled = not enabled
    _btn_build.disabled = not enabled
    _btn_improve.disabled = not enabled


func _on_survey_pressed() -> void:
    if _selected_coordinates.x >= 0:
        EventBusGame.request_survey.emit(_selected_coordinates.x, _selected_coordinates.y)
        EventBusUI.show_notification.emit("Surveying land...", "info")


func _on_build_pressed() -> void:
    if _selected_coordinates.x >= 0:
        # TODO: Show building selection dialog
        EventBusUI.show_notification.emit("Building selection coming soon", "info")


func _on_improve_pressed() -> void:
    if _selected_coordinates.x >= 0:
        # TODO: Show improvement selection dialog
        EventBusUI.show_notification.emit("Improvement selection coming soon", "info")

#endregion 