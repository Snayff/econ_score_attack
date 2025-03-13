## what a person thinks about a good.
#@icon("")
class_name GoodThoughts
extends Node


#region SIGNALS

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
var good_id: String = ""
var willing_to_sell: bool = true
## base level of a good to meet basic need
var consumption_required: int = 0
## level of good needed to meet desire
var consumption_desired: int = 0
## num to try to have in stockpile. 
var min_level_to_hold: int = 0
## amount to be held before consuming desired amount
var desire_threshold: int = 0
## damage taken to health when num required not met
var requirement_not_met_damage: int = 0

#endregion


#region FUNCS









#endregion
