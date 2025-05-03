## Panel for displaying tile information in a rich text format.
## Usage: Call update_info(tile_info: DataTileInfo) to update the panel.
extends PanelContainer



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
	var text := ""
	text += "[center][b]Parcel Location[/b]\n" # Centre-aligned header
	text += "%s\n \n" % tile_info.location # Left-aligned info
	text += "[/center]"
	if not tile_info.is_surveyed:
		text += "[center][b]Survey Status[/b][/center]\n[i]Undiscovered[/i]"
	else:
		text += "[center][b]Aspects[/b][/center]\n" # Centre-aligned header
		if tile_info.aspects.is_empty():
			text += "[i]Nothing of interest found.[/i]"
		else:
			for aspect in tile_info.aspects:
				text += "[b]%s[/b] (x%s)\n" % [aspect["f_name"], str(aspect["amount"])]
				if aspect["description"]:
					text += "[i]%s[/i]\n" % aspect["description"]
				text += "\n"
	rtl_info.text = text

func _ready() -> void:
	assert(rtl_info != null, "RichTextLabel 'rtl_info' must exist as a child node.")
	self.custom_minimum_size.x = PANEL_WIDTH
#endregion

#region PRIVATE FUNCTIONS
#endregion
