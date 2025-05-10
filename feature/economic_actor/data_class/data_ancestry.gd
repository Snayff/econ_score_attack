## DataAncestry
## Represents an ancestry, including possible names, savings rate range, decision profiles, shock response, and consumption rules for economic actors.
## Example usage:
## var ancestry = DataAncestry.new("northern", ["alfred", "edith"], [0.03, 0.12], ["risk_taker"], "adapt", ["meat_basic"])
class_name DataAncestry
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
var possible_names: Array
var savings_rate_range: Array
var decision_profiles: Array
var shock_response: String
var consumption_rule_ids: Array
#endregion


#region PUBLIC FUNCTIONS
## Constructs a new DataAncestry instance.
## @param id_: Unique string ID for the ancestry.
## @param possible_names_: Array of possible names for this ancestry.
## @param savings_rate_range_: Array [min, max] savings rate for this ancestry.
## @param decision_profiles_: Array of decision profile strings.
## @param shock_response_: String describing response to economic shocks.
## @param consumption_rule_ids_: Array of consumption rule IDs.
func _init(id_: String, possible_names_: Array, savings_rate_range_: Array, decision_profiles_: Array, shock_response_: String, consumption_rule_ids_: Array) -> void:
	id = id_
	possible_names = possible_names_
	savings_rate_range = savings_rate_range_
	decision_profiles = decision_profiles_
	shock_response = shock_response_
	consumption_rule_ids = consumption_rule_ids_
#endregion


#region PRIVATE FUNCTIONS
#endregion 