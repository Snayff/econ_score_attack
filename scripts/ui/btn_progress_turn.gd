## class desc
#@icon("")
#class_name XXX
extends Button


#region SIGNALS

#endregion


#region ON READY (for direct children only)

#endregion


#region EXPORTS
# @export_group("Component Links")
# @export var
#
# @export_group("Details")
#endregion


#region VARS

#endregion


#region FUNCS
func _ready() -> void:
	button_up.connect(EventBus.toggle_turn_timer.emit)








#endregion
