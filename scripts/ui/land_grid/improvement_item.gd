## A UI component that displays an improvement and its level
class_name ImprovementItem
extends HBoxContainer


#region CONSTANTS

#endregion


#region SIGNALS

#endregion


#region ON READY

@onready var _lbl_name: Label = $lbl_Name
@onready var _lbl_level: Label = $lbl_Level

#endregion


#region PUBLIC FUNCTIONS

func _ready() -> void:
    assert(_lbl_name != null, "Name label not found")
    assert(_lbl_level != null, "Level label not found")


func setup(improvement_id: String, level: int) -> void:
    _lbl_name.text = improvement_id.capitalize()
    _lbl_level.text = "Lvl %d" % level

#endregion


#region PRIVATE FUNCTIONS

#endregion 