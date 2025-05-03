## Data class for passing tile info to the TileInfoPanelNew.
## Usage: var info = DataTileInfo.new(location, is_surveyed, aspects)
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
## @param aspects: Dictionary - Discovered aspects (e.g., {"Soil": "Fertile"}).
func _init(location: Vector2i, is_surveyed: bool, aspects: Dictionary) -> void:
    self.location = location
    self.is_surveyed = is_surveyed
    self.aspects = aspects

#endregion

#region PRIVATE FUNCTIONS
#endregion

#region VARIABLES
var location: Vector2i
var is_surveyed: bool
var aspects: Dictionary
#endregion 