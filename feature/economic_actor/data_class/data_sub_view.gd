## DataSubView: Data class for sub view metadata for People feature.
## Usage:
##   var sub_view = DataSubView.new("population", "Population", "res://shared/asset/icons/population.svg", "View population details", "res://feature/people/ui/sub_view_population.tscn")
## Last Updated: 2025-05-24
class_name DataSubView
extends RefCounted

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
var label: String
var icon: String
var tooltip: String
var scene_path: String
#endregion

#region PUBLIC FUNCTIONS
## Constructor for DataSubView.
## @param id (String): Unique identifier for the sub view.
## @param label (String): Display label for the sub view.
## @param icon (String): Path to the icon resource.
## @param tooltip (String): Tooltip text for the sub view button.
## @param scene_path (String): Path to the sub view scene.
func _init(id_: String, label_: String, icon_: String, tooltip_: String, scene_path_: String) -> void:
	id = id_
	label = label_
	icon = icon_
	tooltip = tooltip_
	scene_path = scene_path_
#endregion

#region PRIVATE FUNCTIONS
#endregion 