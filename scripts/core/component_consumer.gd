## Component that handles consumption of goods
class_name ComponentConsumer
extends Node

#region VARS
var f_name: String
var stockpile: Dictionary
var thoughts: Dictionary[String, GoodThoughts]
#endregion

#region FUNCS
func _init(f_name_: String, stockpile_: Dictionary, thoughts_: Dictionary[String, GoodThoughts]) -> void:
	f_name = f_name_
	stockpile = stockpile_
	thoughts = thoughts_

func consume() -> bool:
	Logger.debug("ComponentConsumer: " + f_name + " consuming goods", "ComponentConsumer")
	for thought in thoughts.values():
		var icon: String = ""
		match thought.good_id:
			"grain":
				icon = "🥪"
			"water":
				icon = "💧"

		# consume desired amount
		if stockpile[thought.good_id] > thought.desire_threshold:
			stockpile[thought.good_id] -= thought.consumption_desired
			Logger.debug(str(
				f_name,
				" consumed ",
				thought.good_id,
				" to their heart's desire. ⬇️",
				thought.consumption_desired,
				icon
			), "ComponentConsumer")
			return true

		# consume required amount
		elif stockpile[thought.good_id] >= thought.consumption_required:
			stockpile[thought.good_id] -= thought.consumption_required
			Logger.debug(str(
				f_name,
				" consumed what they needed of ",
				thought.good_id,
				". ⬇️",
				thought.consumption_required,
				icon
			), "ComponentConsumer")
			return true
		
		# handle lack of good
		else:
			Logger.debug(str(
				f_name,
				" lacked ",
				thought.consumption_required,
				icon,
				". Cannot consume."
			), "ComponentConsumer")
			return false
	return false
#endregion 