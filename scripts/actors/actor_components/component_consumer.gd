## Component that handles consumption of goods
class_name ComponentConsumer
extends Node

#region CONSTANTS
const TOKEN_CONSUMER := "[consumer]"
const TOKEN_GOOD := "[good]"
const TOKEN_AMOUNT := "[amount]"
#endregion

#region VARS
var f_name: String
var stockpile: Dictionary
#endregion

#region FUNCS
func _init(f_name_: String, stockpile_: Dictionary) -> void:
	f_name = f_name_
	stockpile = stockpile_

func _process_consumption_statement(statement: String, good_id: String, amount: int) -> String:
	var processed := statement
	processed = processed.replace(TOKEN_CONSUMER, f_name)
	processed = processed.replace(TOKEN_GOOD, good_id)
	processed = processed.replace(TOKEN_AMOUNT, str(amount))
	return processed

func consume() -> bool:
	Logger.debug("ComponentConsumer: " + f_name + " consuming goods", "ComponentConsumer")
	
	for rule in Library.get_all_consumption_rules():
		var good_id = rule.good_id
		var icon = Library.get_good_icon(good_id)
		
		# consume desired amount
		if stockpile[good_id] > rule.min_held_before_desired_consumption:
			stockpile[good_id] -= rule.desired_consumption_amount
			var statement := _process_consumption_statement(
				rule.desired_consumption_statement,
				good_id,
				rule.desired_consumption_amount
			)
			Logger.debug(str(
				statement,
				" ⬇️",
				rule.desired_consumption_amount,
				icon
			), "ComponentConsumer")
			return true

		# consume required amount
		elif stockpile[good_id] >= rule.min_consumption_amount:
			stockpile[good_id] -= rule.min_consumption_amount
			var statement := _process_consumption_statement(
				rule.min_consumption_statement,
				good_id,
				rule.min_consumption_amount
			)
			Logger.debug(str(
				statement,
				" ⬇️",
				rule.min_consumption_amount,
				icon
			), "ComponentConsumer")
			return true
		
		# handle lack of good
		else:
			Logger.debug(str(
				f_name,
				" lacked ",
				rule.min_consumption_amount,
				icon,
				". Cannot consume."
			), "ComponentConsumer")
			return false
	return false
#endregion 