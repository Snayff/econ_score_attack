## DataLaw
## Represents a law in the simulation, including its id, display name, description, category, and any other relevant properties.
## Example usage:
## var law = DataLaw.new("law_1", "No Taxation", "Prohibits all forms of taxation.", "economic")
class_name DataLaw
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
var description: String
var category: String
#endregion


#region PUBLIC FUNCTIONS
## Constructs a new DataLaw instance.
## @param id_: Unique string ID for the law.
## @param f_name_: Display name for the law.
## @param description_: Description of the law.
## @param category_: Category of the law (e.g., economic, social).
func _init(id_: String, f_name_: String, description_: String, category_: String) -> void:
	id = id_
	f_name = f_name_
	description = description_
	category = category_
#endregion


#region PRIVATE FUNCTIONS
#endregion 