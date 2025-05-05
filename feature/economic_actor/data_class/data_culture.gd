## DataCulture
## Represents a culture, including preferences, savings rate, and shock response for economic actors.
## Example usage:
## var culture = DataCulture.new("northern", {"food": 1.2, "entertainment": 0.8}, 0.25, "hoard")
class_name DataCulture
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
var base_preferences: Dictionary
var savings_rate: float
var shock_response: String
#endregion


#region PUBLIC FUNCTIONS
## Constructs a new DataCulture instance.
## @param id_: Unique string ID for the culture.
## @param base_preferences_: Dictionary of base preferences for goods.
## @param savings_rate_: Default savings rate for this culture.
## @param shock_response_: String describing response to economic shocks.
func _init(id_: String, base_preferences_: Dictionary, savings_rate_: float, shock_response_: String) -> void:
	id = id_
	base_preferences = base_preferences_
	savings_rate = savings_rate_
	shock_response = shock_response_
#endregion


#region PRIVATE FUNCTIONS
#endregion 