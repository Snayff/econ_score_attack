## DataActor
## Represents an economic actor (person) in the simulation, holding all relevant state for decision-making.
## Example usage:
## var actor = DataActor.new(1, "northern", "ancestral_1", {"hunger": 0.5}, 0.25, 100.0, "greedy")
class_name DataActor
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
var culture_id: String
var ancestry_id: String
var needs: Dictionary
var savings_rate: float
var disposable_income: float
var decision_profile: String
#endregion


#region PUBLIC FUNCTIONS
## Constructs a new DataActor instance.
## @param id_: Unique string ID for the actor.
## @param f_name_: Friendly name for actor.
## @param culture_id_: The culture ID this actor belongs to.
## @param ancestry_id_: The ancestry ID this actor belongs to.
## @param needs_: Dictionary of needs (e.g., hunger, comfort).
## @param savings_rate_: Proportion of income reserved as savings.
## @param disposable_income_: Money available for spending.
## @param decision_profile_: String describing decision logic profile.
func _init(
	id_: String, 
	f_name_: String, 
	culture_id_: String, 
	ancestry_id_: String, 
	needs_: Dictionary, 
	savings_rate_: float, 
	disposable_income_: float, 
	decision_profile_: String
	) -> void:
	id = id_
	f_name = f_name_
	culture_id = culture_id_
	ancestry_id = ancestry_id_
	needs = needs_
	savings_rate = savings_rate_
	disposable_income = disposable_income_
	decision_profile = decision_profile_
#endregion


#region PRIVATE FUNCTIONS
#endregion 