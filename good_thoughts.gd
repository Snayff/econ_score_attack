## Represents and manages a person's thoughts and preferences about a specific good/resource
## Handles consumption desires, requirements, and stockpile preferences
## @icon("")
class_name GoodThoughts
extends Node


#region SIGNALS
signal requirement_not_met(damage: int)
signal desire_threshold_reached(good_id: String)
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
var good_id: String:
    get:
        return good_id
    set(value):
        good_id = value
var willing_to_sell: bool = true
## Minimum amount required for basic survival/needs
## Failing to meet this causes health damage
var consumption_required: int = 0
## Desired consumption amount for comfort/satisfaction
## Only consumed when above desire_threshold
var consumption_desired: int = 0
## Minimum stockpile amount to maintain
var min_level_to_hold: int = 0
## Amount needed before consuming desired amount
var desire_threshold: int = 0
## Health damage taken when required consumption not met
var requirement_not_met_damage: int = 0

#endregion


#region FUNCS









#endregion


#region PUBLIC_METHODS
## Checks if current amount meets basic requirements
## @param current_amount: The amount currently held
## @return: bool indicating if requirements are met
func meets_requirements(current_amount: int) -> bool:
    return current_amount >= consumption_required

## Checks if current amount meets desire threshold
## @param current_amount: The amount currently held
## @return: bool indicating if desire threshold is met
func meets_desire_threshold(current_amount: int) -> bool:
    return current_amount >= desire_threshold
#endregion


#region PRIVATE_METHODS
#endregion
