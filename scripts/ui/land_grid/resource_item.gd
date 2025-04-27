## A UI component that displays a resource and its amount
class_name ResourceItem
extends HBoxContainer


#region CONSTANTS

#endregion


#region SIGNALS

#endregion


#region ON READY

@onready var _lbl_name: Label = $lbl_Name
@onready var _lbl_amount: Label = $lbl_Amount

#endregion


#region PUBLIC FUNCTIONS

func _ready() -> void:
    assert(_lbl_name != null, "Name label not found")
    assert(_lbl_amount != null, "Amount label not found")


func setup(resource_id: String, amount: float) -> void:
    _lbl_name.text = resource_id.capitalize()
    _lbl_amount.text = "%.1f" % amount

#endregion


#region PRIVATE FUNCTIONS

#endregion 