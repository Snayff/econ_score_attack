## class desc
#@icon("")
#class_name XXX
extends Label


#region SIGNALS

#endregion


#region ON READY (for direct children only)
@onready var _chrono: Chrono = %Chrono


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
func _process(_delta: float) -> void:
	if is_instance_valid(_chrono):
		if !_chrono.is_node_ready():
			return


	text = str(
		"Active:",
		_chrono.is_running,
		" | countdown: ",
		"%0.2f" % _chrono.turn_time_remaining,
		" | #",
		_chrono.turn_num
		)








#endregion
