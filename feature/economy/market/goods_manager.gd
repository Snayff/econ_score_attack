## GoodsManager
## Manages all goods in the economy, providing access to loaded DataGood instances and utility functions.
## Handles loading and accessing goods configuration via the Library.
## Example usage:
##   var goods = GoodsManager.get_goods()
##   var prices = GoodsManager.get_good_prices()
#@icon("")
class_name GoodsManager
extends Node


#region SIGNALS
signal config_loaded
signal err_config_load_failed(error: String)
#endregion


#region VARS
#endregion


#region FUNCS
## Returns all DataGood instances from the Library
## @return Array of DataGood
static func get_goods() -> Array:
	return Library.get_all_goods_data()

## Returns a dictionary mapping good ids to their prices
## @return A dictionary mapping good ids to their base prices
static func get_good_prices() -> Dictionary:
	var prices := {}
	for good in get_goods():
		prices[good.id] = good.base_price
	return prices
#endregion 