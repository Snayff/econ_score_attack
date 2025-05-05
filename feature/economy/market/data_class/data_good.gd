## DataGood
## Represents a static configuration for a good in the economy (not a runtime instance).
## Example usage:
## var good = DataGood.new("food", "Food", 10.0, "basic", "🌾")
class_name DataGood
extends Resource


#region CONSTANTS
#endregion


#region SIGNALS
#endregion


#region ON READY
#endregion


#region EXPORTS
#endregion


#region VARS
var id: String
var f_name: String
var base_price: float
var category: String
var icon: String
#endregion


#region PUBLIC FUNCTIONS
## Constructs a new DataGood instance.
## @param id_: Unique string ID for the good.
## @param f_name_: Display name for the good.
## @param base_price_: The base price of the good.
## @param category_: The category of the good (e.g., basic, luxury).
## @param icon_: The icon for the good (e.g., emoji or string).
func _init(id_: String, f_name_: String, base_price_: float, category_: String, icon_: String) -> void:
	id = id_
	f_name = f_name_
	base_price = base_price_
	category = category_
	icon = icon_
#endregion


#region PRIVATE FUNCTIONS
#endregion 