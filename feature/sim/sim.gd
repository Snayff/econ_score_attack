## Sim
## The main simulation class that manages the economic simulation.
## It handles people creation, turn resolution, and market operations.
#@icon("")
class_name Sim
extends Node


#region SIGNALS
signal sim_initialised
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
## The demesne in the simulation
var demesne: Demesne

## Dictionary of good prices in the market
var good_prices: Dictionary = {}

## Economic validator for monitoring invariants
var _economic_validator: EconomicValidator

## Economic metrics tracker
var _economic_metrics: EconomicMetrics

## Transactions in the current turn
var _turn_transactions: Array[Dictionary] = []

#endregion


#region FUNCS
## Initialises the simulation and connects to the turn_complete signal
func _ready() -> void:
	EventBusGame.turn_complete.connect(resolve_turn)

	# Initialise economic monitoring
	_economic_validator = EconomicValidator.new()
	add_child(_economic_validator)
	_economic_validator.invariant_violated.connect(_on_invariant_violated)

	_economic_metrics = EconomicMetrics.new()
	add_child(_economic_metrics)
	_economic_metrics.threshold_crossed.connect(_on_threshold_crossed)

	# Create the demesne
	var demesne_data = DataDemesne.new()
	demesne = Demesne.new(demesne_data.get_default_demesne_name())
	demesne.connect_to_turns()

	# Enact initial laws
	var sales_tax = demesne.enact_law("sales_tax")
	if not sales_tax:
		Logger.error("Failed to create sales tax law", "Sim")

	var inheritance = demesne.enact_law("demesne_inheritance")
	if not inheritance:
		Logger.error("Failed to create inheritance law", "Sim")

	# Initialise demesne stockpile with starting resources
	var starting_resources = demesne_data.get_starting_resources()
	for resource in starting_resources:
		demesne.add_resource(resource, starting_resources[resource])

	# Initialise good prices from Library
	good_prices.clear()
	for good in Library.get_all_goods_data():
		good_prices[good.id] = good.base_price

	# Set initial money for validation
	var total_money = _calculate_total_money()
	_economic_validator.set_initial_money(total_money)

	# Generate people using the GameFactory and add them to the demesne
	var people = GameFactory.generate_starting_people()
	for person in people:
		demesne.add_person(person)

	emit_signal("sim_initialised")
	EventBusGame.emit_signal("sim_initialised", self)
	ReferenceRegistry.register_reference(Constants.REFERENCE_KEY.SIM, self)

## Resolves a single turn of the simulation
## Handles production, consumption, and market operations
func resolve_turn() -> void:
	_turn_transactions.clear()
	# Clear last turn decisions for all people
	for person in demesne.get_people():
		person.clear_last_turn_decisions()
	var saleable_goods: Dictionary = {}  # { good: { person: { amount: 123, money_made: 123 } } }
	var desired_goods: Dictionary = {}  # { good: { person: { amount: 123 } } }

	# Process production and consumption through the demesne
	demesne.process_production()
	demesne.process_consumption()

	# Record production and consumption in validator
	_record_production_consumption()

	# simulate each person's turn for market operations
	for person in demesne.get_people():
		if !person.is_alive:
			continue

		# get goods would sell, based on what is left
		var goods_to_sell: Dictionary = person.get_goods_for_sale()
		for good in goods_to_sell:
			# init dict
			if good not in saleable_goods:
				saleable_goods[good] = {}

			# add person's good
			saleable_goods[good][person] = {
				"amount": goods_to_sell[good],
				"money_made": 0
			}

		# get goods people want to buy
		var goods_to_buy: Dictionary = person.get_goods_to_buy()
		for good in goods_to_buy:
			if good not in desired_goods:
				desired_goods[good] = {}

			desired_goods[good][person] = goods_to_buy[good]

	Logger.info(">>> Market Opens", "Sim")
	var purchasers: Array = []
	var amount_to_buy: int = 0
	var sellers: Array = []

	for good in saleable_goods:
		# no buyers, move on
		if good not in desired_goods:
			continue

		# get sellers and randomise order
		sellers = saleable_goods[good].keys()
		sellers.shuffle()

		# loop sellers of the good, pick a buyer at random and let them buy
		# all that they want
		for seller in sellers:
			var amount_to_sell: int = saleable_goods[good][seller]["amount"]

			# people who want to buy the good in question
			purchasers = desired_goods[good].keys()
			purchasers.shuffle()

			for buyer in purchasers:
				# make purchase
				amount_to_buy = min(floor(buyer.stockpile.get("money", 0) / good_prices.get(good, 0)), desired_goods[good][buyer])

				# Apply sales tax if the law is active
				var tax_amount: float = 0.0
				var final_cost: int = good_prices.get(good, 0) * amount_to_buy
				var sales_tax_law: SalesTax = demesne.get_law("sales_tax") as SalesTax
				if sales_tax_law and sales_tax_law.active:
					tax_amount = sales_tax_law.calculate_tax(final_cost)
					final_cost += tax_amount
					demesne.add_resource("money", tax_amount)

				# Check if buyer can afford the purchase with tax
				if buyer.stockpile.get("money", 0) < final_cost:
					# Recalculate affordable amount
					var tax_rate: float = sales_tax_law.get_parameter("tax_rate") if sales_tax_law else 0.0
					amount_to_buy = floor(buyer.stockpile.get("money", 0) / (good_prices.get(good, 0) * (1 + tax_rate / 100.0)))
					final_cost = good_prices.get(good, 0) * amount_to_buy
					if sales_tax_law and sales_tax_law.active:
						tax_amount = sales_tax_law.calculate_tax(final_cost)
						final_cost += tax_amount
						demesne.add_resource("money", tax_amount)

				buyer.stockpile["money"] = buyer.stockpile.get("money", 0) - final_cost
				seller.stockpile["money"] = seller.stockpile.get("money", 0) + good_prices.get(good, 0) * amount_to_buy  # Seller gets only the base cost

				# Record the transaction
				_record_transaction(good, amount_to_buy, good_prices.get(good, 0), buyer.f_name, seller.f_name)

				# Log the decision for the buyer
				var action = "Purchased %d %s from %s" % [amount_to_buy, good, seller.f_name]
				var inputs = {
					"money": buyer.stockpile.get("money", 0),
					"grain_needed": desired_goods[good].get(buyer, 0),
					"price": good_prices.get(good, 0),
					"tax": tax_amount
				}
				var reasoning = "Chose to buy because utility gain exceeded cost."
				# Example alternatives: buy less, buy nothing
				var alternatives = [
					{"action": "Buy 0 %s" % good, "utility": 0},
					{"action": "Buy %d %s" % [amount_to_buy, good], "utility": amount_to_buy * 2} # Dummy utility
				]
				buyer.log_decision(action, inputs, reasoning, alternatives)

				# buyer doesnt want anything, move to next buyer
				if amount_to_buy == 0:
					continue

				# add to buyers stockpile
				if good not in buyer.stockpile:
					buyer.stockpile[good] = 0
				buyer.stockpile[good] = buyer.stockpile.get(good, 0) + amount_to_buy
				seller.stockpile[good] = seller.stockpile.get(good, 0) - amount_to_buy

				# update desired good and purchasers
				desired_goods[good][buyer] -= amount_to_buy
				if desired_goods[good][buyer] <= 0:
					desired_goods[good].erase(buyer)

				# update remaining
				var goods_left: int = max(0, amount_to_sell - amount_to_buy)
				saleable_goods[good][seller]["amount"] = goods_left
				saleable_goods[good][seller]["money_made"] += good_prices.get(good, 0) * amount_to_buy

	Logger.info(">>> Market Closes", "Sim")

	# Validate economic state
	_validate_economic_state()

	# Update economic metrics
	_update_economic_metrics()

	Logger.info(">>> Turn Resolved >>>>>>>>>>>>>>>>>>>>", "Sim")

## Records a transaction for monitoring
func _record_transaction(
	good: String,
	amount: int,
	price: float,
	buyer: String,
	seller: String
) -> void:
	var transaction = {
		"good": good,
		"amount": amount,
		"price": price,
		"buyer": buyer,
		"seller": seller
	}
	_turn_transactions.append(transaction)
	_economic_validator.record_transaction("trade", good, amount, price, buyer, seller)

## Records production and consumption for monitoring
func _record_production_consumption() -> void:
	for person in demesne.get_people():
		if not person.is_alive:
			continue

		# Record production based on job
		match person.job:
			"farmer":
				_economic_validator.record_transaction("production", "grain", 10, 0.0, person.f_name, "")
			"water collector":
				_economic_validator.record_transaction("production", "water", 20, 0.0, person.f_name, "")
			"woodcutter":
				_economic_validator.record_transaction("production", "wood", 10, 0.0, person.f_name, "")
			"bureaucrat":
				_economic_validator.record_transaction("production", "bureaucracy", 5, 0.0, person.f_name, "")

## Validates the current economic state
func _validate_economic_state() -> void:
	# Update resource totals
	var resource_totals = _calculate_resource_totals()
	_economic_validator.update_resource_totals(resource_totals)

	# Validate economic invariants
	_economic_validator.validate_money_conservation()
	_economic_validator.validate_closed_loop_economy()

## Updates economic metrics
func _update_economic_metrics() -> void:
	var sim_state = {
		"market_prices": good_prices,
		"transactions": _turn_transactions,
		"total_money": _calculate_total_money(),
		"people": demesne.get_people(),
		"production": _calculate_production_totals()
	}

	_economic_metrics.update_metrics(sim_state)

	var report = _economic_metrics.generate_report()
	Logger.info("Economic Report: " + str(report), "Sim")

## Calculates the total money in the system
func _calculate_total_money() -> float:
	var total = float(demesne.stockpile.get("money", 0))
	for person in demesne.get_people():
		total += float(person.stockpile.get("money", 0))
	return total

## Calculates total resources in the system
func _calculate_resource_totals() -> Dictionary:
	var totals = {}

	# Add demesne resources
	for resource in demesne.stockpile:
		totals[resource] = demesne.stockpile[resource]

	# Add people's resources
	for person in demesne.get_people():
		for resource in person.stockpile:
			if resource not in totals:
				totals[resource] = 0
			totals[resource] += person.stockpile[resource]

	return totals

## Calculates production totals for the current turn
func _calculate_production_totals() -> Dictionary:
	var totals = {}
	for transaction in _turn_transactions:
		if transaction.get("type") == "production":
			var good = transaction["good"]
			if good not in totals:
				totals[good] = 0
			totals[good] += transaction["amount"]
	return totals

## Emits an economic error signal when an invariant is violated
func _on_invariant_violated(invariant_name: String, details: String) -> void:
	EventBusGame.economic_error.emit(invariant_name, details)

## Emits an economic alert signal when a threshold is crossed
func _on_threshold_crossed(metric_name: String, threshold: float, current_value: float) -> void:
	EventBusGame.economic_alert.emit(metric_name, threshold, current_value)

#endregion
