## Law
## Base class for all economic laws that can be enacted in a demesne
## Provides core functionality for law management and parameter handling
class_name Law
extends RefCounted

#region SIGNALS
signal parameters_changed(parameter_name: String, new_value: float)
#endregion

#region VARS
## Unique identifier for this law type
var id: String:
    get:
        return id
    set(value):
        id = value

## Human-readable name of the law
var name: String:
    get:
        return name
    set(value):
        name = value

## Detailed description of the law's effects
var description: String:
    get:
        return description
    set(value):
        description = value

## Current parameter values for this law instance
var parameters: Dictionary:
    get:
        return parameters
    set(value):
        parameters = value

## Whether the law is currently in effect
var active: bool:
    get:
        return active
    set(value):
        active = value
#endregion

#region FUNCS
## Creates a new law instance
## @param id_: Unique identifier for the law type
## @param name_: Human-readable name
## @param description_: Detailed description
## @param parameters_: Initial parameter values
func _init(id_: String, name_: String, description_: String, parameters_: Dictionary) -> void:
    id = id_
    name = name_
    description = description_
    parameters = parameters_
    active = false

## Activates this law instance
func activate() -> void:
    active = true

## Deactivates this law instance
func deactivate() -> void:
    active = false

## Updates a parameter value
## @param parameter_name: Name of parameter to update
## @param value: New parameter value
## @return: bool indicating if update was successful
func set_parameter(parameter_name: String, value: float) -> bool:
    if not parameters.has(parameter_name):
        return false
    parameters[parameter_name] = value
    emit_signal("parameters_changed", parameter_name, value)
    return true

## Retrieves a parameter value
## @param parameter_name: Name of parameter to retrieve
## @return: Parameter value or null if not found
func get_parameter(parameter_name: String) -> float:
    return parameters.get(parameter_name, 0.0)

## Validates if all required parameters are present and valid
## @return: bool indicating if parameters are valid
func validate_parameters() -> bool:
    return true
#endregion 