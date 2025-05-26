##
## ReferenceRegistry: Holds references to key game objects for decoupled access.
## Usage: ReferenceRegistry.register_reference(Constants.REFERENCE_KEY.SIM, sim_instance)
##        ReferenceRegistry.get_reference(Constants.REFERENCE_KEY.SIM)
##        ReferenceRegistry.reference_registered.connect(_on_reference_registered)
## Last Updated: 2024-06-09
##
extends Node

#region CONSTANTS
#endregion

#region SIGNALS
signal reference_registered(key, value) # Emitted when a reference is registered or updated.
#endregion

#region EXPORTS
#endregion

#region ON READY
#endregion

#region VARS
var _references: Dictionary = {}
#endregion

#region PUBLIC FUNCTIONS
## Register a reference with a given key (from Constants.REFERENCE_KEY enum).
## Arguments:
##   key (int): Enum value from Constants.REFERENCE_KEY.
##   value (Object): The object to register.
func register_reference(key: int, value: Object) -> void:
    _references[key] = value
    emit_signal("reference_registered", key, value)

## Retrieve a reference by key (from Constants.REFERENCE_KEY enum).
## Arguments:
##   key (int): Enum value from Constants.REFERENCE_KEY.
## Returns:
##   Object or null if not found.
func get_reference(key: int) -> Object:
    return _references.get(key, null)
#endregion

#region PRIVATE FUNCTIONS
#endregion 