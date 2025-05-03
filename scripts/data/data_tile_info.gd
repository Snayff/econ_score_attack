## DataTileInfo
## Lightweight, read-only data transfer object for passing tile information to UI components.
## This class is intended solely for UI display and should not be used for simulation logic or state mutation.
## Example usage:
##     var info = DataTileInfo.new(Vector2i(3, 5), true, [{"f_name": "Fertile Soil", "description": "Rich in nutrients", "amount": 5}])
##     # Pass 'info' to a UI panel for display
class_name DataTileInfo
extends RefCounted

#region CONSTANTS
#endregion

#region SIGNALS
#endregion

#region ON READY
#endregion

#region EXPORTS
#endregion

#region PUBLIC FUNCTIONS

## Constructs a new DataTileInfo.
## @param location: Vector2i - The grid location of the tile.
## @param is_surveyed: bool - Whether the tile has been surveyed.
## @param aspects: Array - List of discovered aspect data dictionaries (e.g., [{"f_name": "Fertile Soil", "description": "Rich in nutrients", "amount": 5}]).
func _init(location: Vector2i, is_surveyed: bool, aspects: Array) -> void:
    self.location = location
    self.is_surveyed = is_surveyed
    self.aspects = aspects

#endregion

#region PRIVATE FUNCTIONS
#endregion

#region VARIABLES
var location: Vector2i
var is_surveyed: bool
var aspects: Array
#endregion 