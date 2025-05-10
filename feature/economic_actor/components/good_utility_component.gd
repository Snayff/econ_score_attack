 ##
## GoodUtilityComponent: Calculates utility values for goods for a given actor, and selects the best affordable good.
## Usage Example:
##   var util_dict = GoodUtilityComponent.calculate_good_utility(actor, goods, cultures, ancestries, prices)
##   var best_good = GoodUtilityComponent.select_best_affordable_good(actor, goods, cultures, ancestries, prices)
## Note: ancestry is a Dictionary, not a class.
## Last Updated: DATE
class_name GoodUtilityComponent
extends Node

#region CONSTANTS
#endregion

#region SIGNALS
#endregion

#region ON READY
#endregion

#region EXPORTS
#endregion

#region PUBLIC FUNCTIONS
## Calculates the utility value for each good for the given actor.
## Args:
## 	actor (DataPerson): The actor evaluating goods.
## 	goods (Array): Array of DataGood.
##	cultures (Dictionary): culture_id -> DataCulture.
##	ancestries (Dictionary): ancestry_id -> ancestry Dictionary.
##	prices (Dictionary): good_id -> price (float).
## Returns:
##	Dictionary: good_id -> utility (float).
static func calculate_good_utility(
		actor: DataPerson,
		goods: Array,
		cultures: Dictionary,
		ancestries: Dictionary,
		prices: Dictionary
	) -> Dictionary:

	var result: Dictionary = {}
	var culture: DataCulture = cultures.get(actor.culture_id, null)
	var ancestry: Dictionary = ancestries.get(actor.ancestry_id, null)
	for good in goods:
		var base_weight: float = 1.0
		if culture and good.need_type in culture.base_preferences:
			base_weight = float(culture.base_preferences[good.need_type])
		elif ancestry and ancestry.has("base_preferences") and good.need_type in ancestry["base_preferences"]:
			base_weight = float(ancestry["base_preferences"][good.need_type])
		var need_level: float = float(actor.needs.get(good.need_type, 0.0))
		var marginal_factor: float = 1.0 / (1.0 + need_level)
		var random_noise: float = randf_range(-0.05, 0.05)
		var price_sensitivity: float = 1.0
		if culture and culture.has("price_sensitivity"):
			price_sensitivity = float(culture.price_sensitivity)
		var price: float = float(prices.get(good.id, 1.0))
		var utility: float = (base_weight * need_level * marginal_factor + random_noise) * price_sensitivity
		result[good.id] = utility
	return result


##	Selects the best affordable good for the actor based on calculated utility.
##	Args:
##		actor (DataPerson): The actor evaluating goods.
##		goods (Array): Array of DataGood.
##		cultures (Dictionary): culture_id -> DataCulture.
##		ancestries (Dictionary): ancestry_id -> DataAncestry.
##		prices (Dictionary): good_id -> price (float).
##	Returns:
##		String: good_id of the best affordable good, or "" if none.
static func select_best_affordable_good(
		actor: DataPerson,
		goods: Array,
		cultures: Dictionary,
		ancestries: Dictionary,
		prices: Dictionary
	) -> String:

	var utilities := calculate_good_utility(actor, goods, cultures, ancestries, prices)
	var best_good: String = ""
	var best_utility: float = -INF
	for good in goods:
		var price: float = float(prices.get(good.id, 1.0))
		if actor.disposable_income >= price:
			var util: float = float(utilities.get(good.id, 0.0))
			if util > best_utility:
				best_utility = util
				best_good = good.id
	return best_good

#endregion

#region PRIVATE FUNCTIONS
#endregion
