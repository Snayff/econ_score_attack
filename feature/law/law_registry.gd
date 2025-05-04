## LawRegistry
## Registry for available law types within a demesne
## Handles law creation and validation
class_name LawRegistry
extends RefCounted


#region VARS
## Mapping of law IDs to their data classes
var _law_types: Dictionary = {}

## Reference to owning demesne
var _demesne: Demesne
#endregion

#region FUNCS
## Initialize registry for a specific demesne
## @param demesne: The demesne this registry belongs to
func _init(demesne: Demesne) -> void:
	_demesne = demesne
	_register_default_laws()

## Registers built-in law types
func _register_default_laws() -> void:
	register_law_type("sales_tax", SalesTax)
	register_law_type("demesne_inheritance", DemesneInheritance)

## Registers a new law type
## @param law_id: Unique identifier for the law type
## @param law_class: Class to use for instantiation
func register_law_type(law_id: String, law_class: GDScript) -> void:
	_law_types[law_id] = law_class

## Creates a new law instance
## @param law_id: ID of the law type to create
## @return: New law instance or null if creation failed
func create_law(law_id: String) -> Law:
	if not _law_types.has(law_id):
		return null

	var law_data: Dictionary = Library.get_config("laws").get("laws", []).filter(
		func(law): return law.get("id") == law_id
	).front()

	if law_data.is_empty():
		return null

	var law_class: GDScript = _law_types[law_id]

	# Extract default parameter values from the new format
	var default_parameters = {}
	for param_name in law_data.get("parameters", {}):
		default_parameters[param_name] = law_data.parameters[param_name].default

	# Convert tags to Array[String]
	var tags: Array[String] = []
	for tag in law_data.get("tags", []):
		tags.append(tag)

	return law_class.new(
		law_data.name,
		law_data.category,
		law_data.subcategory,
		tags,
		law_data.description,
		default_parameters
	)

## Gets the available parameter options for a law type
## @param law_id: ID of the law type
## @param parameter_name: Name of the parameter
## @return: Array of available options or empty array if not found
func get_parameter_options(law_id: String, parameter_name: String) -> Array:
	var law_data: Dictionary = Library.get_config("laws").get("laws", []).filter(
		func(law): return law.get("id") == law_id
	).front()

	if law_data.is_empty():
		return []

	return law_data.get("parameters", {}).get(parameter_name, {}).get("options", [])

## Gets all laws with a specific tag
## @param tag: Tag to search for
## @return: Array of law IDs that have the tag
func get_laws_by_tag(tag: String) -> Array[String]:
	var matching_laws: Array[String] = []
	var all_laws = Library.get_config("laws").get("laws", [])

	for law_data in all_laws:
		if law_data.get("tags", []).has(tag):
			matching_laws.append(law_data.id)

	return matching_laws

## Gets all laws in a specific category and subcategory
## @param category: Category to search for
## @param subcategory: Optional subcategory to filter by
## @return: Array of law IDs that match the criteria
func get_laws_by_category(category: String, subcategory: String = "") -> Array[String]:
	var matching_laws: Array[String] = []
	var all_laws = Library.get_config("laws").get("laws", [])

	for law_data in all_laws:
		if law_data.get("category") == category:
			if subcategory.is_empty() or law_data.get("subcategory") == subcategory:
				matching_laws.append(law_data.id)

	return matching_laws
#endregion
