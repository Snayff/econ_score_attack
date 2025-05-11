## DemesneStockpile
## Displays information about the demesne's stockpile in a top bar
## Shows current resource levels with icons
#@icon("")
class_name RTLDemesneStockpile
extends RichTextLabel


#region EXPORTS
@export var _sim: Sim
#endregion


#region VARS
#endregion


#region FUNCS
func _ready() -> void:
	# Connect to signals for updates
	EventBusGame.turn_complete.connect(update_info)
	ReferenceRegistry.reference_registered.connect(_on_reference_registered)

	# Set up the UI
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fit_content = true

	# Attempt to get _sim if already registered
	var sim_ref = ReferenceRegistry.get_reference(Constants.ReferenceKey.SIM)
	if sim_ref:
		_set_sim(sim_ref)

	update_info()

## Updates the displayed information
func update_info() -> void:
	if not _sim:
		Logger.error("DemesneStockpile: _sim is null", "DemesneStockpile")
		text = "No simulation data available (_sim is null)"
		return

	if not _sim.demesne:
		Logger.error("DemesneStockpile: _sim.demesne is null", "DemesneStockpile")
		text = "No simulation data available (demesne is null)"
		return

	var info_text: String = ""
	var stockpile = _sim.demesne.get_stockpile()

	# Create a horizontal bar with icons and amounts
	for good in stockpile:
		var icon = Library.get_good_icon(good)
		info_text += icon + " " + str(stockpile[good]) + "  "

	text = info_text

## Handles stockpile changes from the demesne
func _on_stockpile_changed(_good_id: String, _new_amount: int) -> void:
	update_info()


## Handles updates from the ReferenceRegistry
func _on_reference_registered(key: int, value: Object) -> void:
	if key == Constants.ReferenceKey.SIM:
		_set_sim(value)

## Sets the _sim reference and connects to demesne signals
func _set_sim(sim_ref: Sim) -> void:
	_sim = sim_ref
	if _sim and _sim.demesne:
		_sim.demesne.stockpile_changed.connect(_on_stockpile_changed)
	update_info()
#endregion
