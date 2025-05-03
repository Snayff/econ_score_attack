# Import the DataTileInfo data class
extends PanelContainer

## Panel for displaying tile information in a rich text format.
## Usage: Call update_info(tile_info: DataTileInfo) to update the panel.

#region CONSTANTS
const PANEL_WIDTH := 350
#endregion

#region SIGNALS
#endregion

#region ON READY
@onready var rtl_info: RichTextLabel = $rtl_info
#endregion

#region EXPORTS
#endregion

#region PUBLIC FUNCTIONS

## Updates the panel with the given tile info.
## @param tile_info: DataTileInfo - The data for the selected tile.
func update_info(tile_info: DataTileInfo) -> void:
    var text := "[b]Location:[/b] %s\n[hr]\n" % tile_info.location
    if not tile_info.is_surveyed:
        text += "[i]Undiscovered[/i]"
    else:
        for aspect in tile_info.aspects.keys():
            text += "[b]%s:[/b] %s\n" % [aspect, tile_info.aspects[aspect]]
    rtl_info.text = text

func _ready() -> void:
    assert(rtl_info != null, "RichTextLabel 'rtl_info' must exist as a child node.")
    self.custom_minimum_size.x = PANEL_WIDTH
#endregion

#region PRIVATE FUNCTIONS
#endregion

# Import DataTileInfo for static typing
const DataTileInfo = preload("res://scripts/data/DataTileInfo.gd") 