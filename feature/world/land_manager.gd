## LandManager
## Manages all land parcels for all demesnes. Responds to data requests and emits updates.
## Example usage:
##   var land_manager = LandManager.new()
##   land_manager.register_demesne("demesne_1", land_grid)
##   land_manager.get_parcel("demesne_1", 2, 3)
class_name LandManager
extends Node

#region CONSTANTS
#endregion


#region SIGNALS
#endregion


#region ON READY
func _ready() -> void:
	# Connect to parcel data requests
	EventBusGame.request_parcel_data.connect(_on_request_parcel_data)
#endregion


#region PUBLIC FUNCTIONS
## Registers a demesne's land grid
## @param demesne_id: String - Unique identifier for the demesne
## @param land_grid: Array[Array[DataLandParcel]] - 2D array of parcels
func register_demesne(demesne_id: String, land_grid: Array) -> void:
	_demesne_land[demesne_id] = land_grid

## Gets the parcel for a demesne at (x, y)
## @param demesne_id: String
## @param x: int
## @param y: int
## @return: DataLandParcel
func get_parcel(demesne_id: String, x: int, y: int) -> DataLandParcel:
	if not _demesne_land.has(demesne_id):
		push_error("Demesne ID not found in LandManager: %s" % demesne_id)
		return null
	return _demesne_land[demesne_id][y][x]
#endregion


#region PRIVATE FUNCTIONS
var _demesne_land: Dictionary = {} # {demesne_id: Array[Array[DataLandParcel]]}

func _on_request_parcel_data(x: int, y: int) -> void:
	var sim_node = get_node("%Sim")
	if sim_node == null or sim_node.demesne == null:
		push_error("LandManager: Sim or demesne is null")
		return
	var demesne_id = sim_node.demesne.demesne_name
	if not _demesne_land.has(demesne_id):
		push_error("No land registered for demesne: %s" % demesne_id)
		return
	var parcel = get_parcel(demesne_id, x, y)
	if parcel == null:
		push_error("Parcel not found at (%d, %d) for demesne %s" % [x, y, demesne_id])
		return
	EventBusUI.land_grid_updated.emit(parcel)
#endregion
