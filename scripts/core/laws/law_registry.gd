## LawRegistry
## Registry for available law types within a demesne
## Handles law creation and validation
class_name LawRegistry
extends RefCounted

const Law = preload("res://scripts/core/laws/law.gd")
const SalesTax = preload("res://scripts/core/laws/sales_tax.gd")

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
    return law_class.new(
        law_data.name,
        law_data.description,
        law_data.default_parameters.duplicate()
    )
#endregion 