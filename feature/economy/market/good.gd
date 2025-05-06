## Represents a tradeable good or resource in the economy
## Stores basic information about a good including its identity and quantity
## @icon("")
class_name Good
extends Node


#region SIGNALS
signal amount_changed(new_amount: int)
signal good_consumed(amount: int)
signal good_produced(amount: int)
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
var id: String:
	get:
		return id
	set(value):
		id = value

var amount: int:
	get:
		return amount
	set(value):
		var old_amount = amount
		amount = value
		if old_amount != value:
			emit_signal("amount_changed", value)
#endregion


#region FUNCS









#endregion


#region PUBLIC_METHODS
## Consumes a specified amount of the good
## @param consume_amount: Amount to consume
## @return: bool indicating if consumption was successful
func consume(consume_amount: int) -> bool:
	if amount >= consume_amount:
		amount -= consume_amount
		emit_signal("good_consumed", consume_amount)
		return true
	return false

## Produces a specified amount of the good
## @param produce_amount: Amount to produce
func produce(produce_amount: int) -> void:
	amount += produce_amount
	emit_signal("good_produced", produce_amount)
#endregion


#region PRIVATE_METHODS
#endregion
