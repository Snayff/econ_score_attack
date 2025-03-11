## class desc
#@icon("")
#class_name XXX
extends RichTextLabel


#region SIGNALS

#endregion


#region ON READY (for direct children only)

#endregion


#region EXPORTS
@export_group("Component Links")
@export var sim: Sim = null
#
# @export_group("Details")
#endregion


#region VARS

#endregion


#region FUNCS
func _process(delta: float) -> void:
	text = ""
	for person in sim.people:
		var alive_text: String = ""
		if person.is_alive:
			alive_text = "🧍"
		else:
			alive_text = "💀"

		text += str(
			person.job, " | ",
			alive_text, " | ",
			"❤️ ", person.health, " | ",
			"🪙 ", person.stockpile["money"], " | ",
			"🥪 ", person.stockpile["grain"], " | ",
			"💧 ", person.stockpile["water"], " | ",
			"🪵 ", person.stockpile["wood"], " | ",
			"\n"
		) #"🪵❤️💧🥪"








#endregion
