## LandManager
## Global autoload for managing all land parcels for all demesnes. Responds to data requests and emits updates.
## Example usage:
##   LandManager.register_demesne("demesne_1", land_grid)
##   LandManager.get_parcel("demesne_1", 2, 3)
##   # To request a parcel update (note: demesne_id is required):
##   EventBusGame.request_parcel_data.emit("demesne_1", 2, 3)
extends Node

#region CONSTANTS
#endregion


#region SIGNALS
#endregion


#region ON READY
func _ready() -> void:
	# Connect to parcel data requests using the injected event bus
	if not _event_bus_game.is_null():
		_event_bus_game.call().request_parcel_data.connect(_on_request_parcel_data)
#endregion


#region PUBLIC FUNCTIONS
## Registers a demesne's land grid
## @param demesne_id: String - Unique identifier for the demesne
## @param land_grid: Array[Array[DataLandParcel]] - 2D array of parcels
static func register_demesne(demesne_id: String, land_grid: Array) -> void:
	_demesne_land[demesne_id] = land_grid

## Gets the parcel for a demesne at (x, y)
## @param demesne_id: String
## @param x: int
## @param y: int
## @return: DataLandParcel
static func get_parcel(demesne_id: String, x: int, y: int) -> DataLandParcel:
	if not _demesne_land.has(demesne_id):
		push_error("Demesne ID not found in LandManager: %s" % demesne_id)
		return null
	return _demesne_land[demesne_id][y][x]

## Sets the event bus callables
## @param event_bus_game: Callable that returns the game event bus
## @param event_bus_ui: Callable that returns the UI event bus
static func set_event_buses(event_bus_game: Callable, event_bus_ui: Callable) -> void:
	"""
	Sets the callables used to access the event buses. This decouples LandManager from the EventBusGame and EventBusUI globals.
	@param event_bus_game: Callable
	@param event_bus_ui: Callable
	"""
	_event_bus_game = event_bus_game
	_event_bus_ui = event_bus_ui
#endregion


#region PRIVATE FUNCTIONS
static var _demesne_land: Dictionary = {} # {demesne_id: Array[Array[DataLandParcel]]}

## Callables for event buses, to be injected at runtime
static var _event_bus_game: Callable = Callable()
static var _event_bus_ui: Callable = Callable()

# Now expects demesne_id, x, y
static func _on_request_parcel_data(demesne_id: String, x: int, y: int) -> void:
	if not _demesne_land.has(demesne_id):
		push_error("No land registered for demesne: %s" % demesne_id)
		return
	var parcel = get_parcel(demesne_id, x, y)
	if parcel == null:
		push_error("Parcel not found at (%d, %d) for demesne %s" % [x, y, demesne_id])
		return
	# Emit signal using the injected UI event bus
	if not _event_bus_ui.is_null():
		_event_bus_ui.call().land_grid_updated.emit(parcel)
#endregion
