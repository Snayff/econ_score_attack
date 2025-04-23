## Tracks and validates economic invariants in the simulation
## Ensures the economy follows core rules like conservation of money and closed-loop production
## Example usage:
## ```gdscript
## var validator = EconomicValidator.new()
## validator.invariant_violated.connect(_on_invariant_violated)
## validator.record_transaction("trade", "grain", 10, 100.0, "buyer_id", "seller_id")
## validator.validate_money_conservation()
## ```
class_name EconomicValidator
extends Node


#region SIGNALS

## Emitted when an economic invariant is violated
signal invariant_violated(invariant_name: String, details: String)

#endregion


#region VARS

## Tracks total resources in the economy
var _total_resources: Dictionary = {}

## Tracks all economic transactions
var _transaction_history: Array[Dictionary] = []

## Initial money in the system
var _initial_money: float = 0.0

## Maximum allowed floating point difference for equality checks
const FLOAT_EPSILON: float = 0.0001

## Maximum transactions to keep in history
const MAX_TRANSACTION_HISTORY: int = 1000

#endregion


#region PUBLIC_METHODS

## Sets the initial money in the system for validation
func set_initial_money(amount: float) -> void:
	_initial_money = amount
	Logger.debug("EconomicValidator: Set initial money to %f" % amount, "EconomicValidator")

## Records a new transaction for validation
func record_transaction(
	transaction_type: String, 
	good: String, 
	amount: int, 
	price: float,
	buyer: String, 
	seller: String
) -> void:
	var transaction = {
		"timestamp": Time.get_unix_time_from_system(),
		"type": transaction_type,
		"good": good,
		"amount": amount,
		"price": price,
		"buyer": buyer,
		"seller": seller
	}
	
	_transaction_history.append(transaction)
	
	# Keep history size manageable
	if _transaction_history.size() > MAX_TRANSACTION_HISTORY:
		_transaction_history.pop_front()
	
	Logger.debug("EconomicValidator: Recorded transaction - %s" % str(transaction), "EconomicValidator")

## Updates the total resources tracking
func update_resource_totals(resource_totals: Dictionary) -> void:
	_total_resources = resource_totals.duplicate()
	Logger.debug("EconomicValidator: Updated resource totals - %s" % str(_total_resources), "EconomicValidator")

## Validates that the total money in the system remains constant
## (except for explicitly tracked sources/sinks)
func validate_money_conservation() -> bool:
	var current_total = _calculate_total_money()
	var expected_total = _get_expected_total_money()
	
	if abs(current_total - expected_total) > FLOAT_EPSILON:
		emit_signal("invariant_violated", 
			"money_conservation",
			"Money not conserved: Expected %f, got %f" % [expected_total, current_total]
		)
		Logger.error(
			"Money conservation violated: Expected %f, got %f" % [expected_total, current_total], 
			"EconomicValidator"
		)
		return false
	return true

## Validates that all goods in the economy came from valid production
func validate_closed_loop_economy() -> bool:
	var production_totals = _calculate_total_production()
	var consumption_totals = _calculate_total_consumption()
	
	for good in production_totals.keys():
		if production_totals[good] < consumption_totals[good]:
			emit_signal("invariant_violated",
				"closed_loop_economy",
				"More %s consumed than produced" % good
			)
			Logger.error(
				"Closed loop economy violated: More %s consumed than produced" % good,
				"EconomicValidator"
			)
			return false
	return true

## Gets the current transaction history
func get_transaction_history() -> Array[Dictionary]:
	return _transaction_history

## Clears the transaction history
func clear_transaction_history() -> void:
	_transaction_history.clear()
	Logger.debug("EconomicValidator: Cleared transaction history", "EconomicValidator")

#endregion


#region PRIVATE_METHODS

## Calculates the total money currently in the system
func _calculate_total_money() -> float:
	var total: float = 0.0
	if "money" in _total_resources:
		total = float(_total_resources["money"])
	return total

## Gets the expected total money based on initial amount and tracked changes
func _get_expected_total_money() -> float:
	return _initial_money

## Calculates total production of all goods
func _calculate_total_production() -> Dictionary:
	var totals: Dictionary = {}
	for transaction in _transaction_history:
		if transaction["type"] == "production":
			var good = transaction["good"]
			if good not in totals:
				totals[good] = 0
			totals[good] += transaction["amount"]
	return totals

## Calculates total consumption of all goods
func _calculate_total_consumption() -> Dictionary:
	var totals: Dictionary = {}
	for transaction in _transaction_history:
		if transaction["type"] == "consumption":
			var good = transaction["good"]
			if good not in totals:
				totals[good] = 0
			totals[good] += transaction["amount"]
	return totals

#endregion 