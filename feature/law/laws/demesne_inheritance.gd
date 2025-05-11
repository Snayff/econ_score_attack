## DemesneInheritance
## When a person dies, their stockpile is added to the demesne's stockpile
## This law ensures all unclaimed goods return to the demesne
class_name DemesneInheritance
extends Law


#region CONSTANTS


#region SIGNALS


#region ON READY


#region EXPORTS


#region PUBLIC FUNCTIONS
## Creates a new demesne inheritance law instance
## @param name_: Human-readable name
## @param category_: Main category of the law
## @param subcategory_: Subcategory for more specific categorization
## @param tags_: Array of tags for searching and filtering
## @param description_: Detailed description
## @param parameters_: Initial parameter values
func _init(name_: String, category_: String, subcategory_: String, tags_: Array[String], description_: String, parameters_: Dictionary) -> void:
	super._init("demesne_inheritance", name_, category_, subcategory_, tags_, description_, parameters_)


## Validates parameters for this law
## @return: bool indicating if parameters are valid
func validate_parameters() -> bool:
	return true  # No parameters to validate


## Transfers a person's stockpile to the demesne
## @param person: The person whose stockpile to transfer
## @param demesne: The demesne to transfer the stockpile to
func transfer_stockpile(person: Person, demesne: Demesne) -> void:
	if not active:
		return

	Logger.log_event("Transferring stockpile", {
		"from": person.f_name,
		"to": "demesne"
	}, "DemesneInheritance")

	var total_transferred: Dictionary = {}

	# Transfer each good in the person's stockpile to the demesne
	for good_id in person.stockpile:
		var amount: int = person.stockpile[good_id]
		if amount > 0:
			demesne.add_resource(good_id, amount)
			total_transferred[good_id] = amount
			Logger.log_resource_change(good_id, amount, demesne.stockpile[good_id], "DemesneInheritance")
			# Clear the person's stockpile as we transfer
			person.stockpile[good_id] = 0

	Logger.log_event("Stockpile transfer complete", {
		"from": person.f_name,
		"transferred": total_transferred
	}, "DemesneInheritance")
#endregion


#region PRIVATE FUNCTIONS


#endregion
