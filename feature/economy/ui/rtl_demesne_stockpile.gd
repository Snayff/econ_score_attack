## DemesneStockpile
## Displays information about the demesne's stockpile in a top bar
## Shows current resource levels with icons
#@icon("")
class_name RTLDemesneStockpile
extends RichTextLabel


#region EXPORTS
@export var sim: Sim
#endregion


#region VARS
#endregion


#region FUNCS
func _ready() -> void:
	# Connect to signals for updates
	EventBusGame.turn_complete.connect(update_info)
	if sim:
		sim.sim_initialised.connect(_on_sim_initialised)

	# Set up the UI
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fit_content = true

	update_info()

## Updates the displayed information
func update_info() -> void:
	if not sim:
		Logger.error("DemesneStockpile: sim is null", "DemesneStockpile")
		text = "No simulation data available (sim is null)"
		return

	if not sim.demesne:
		Logger.error("DemesneStockpile: sim.demesne is null", "DemesneStockpile")
		text = "No simulation data available (demesne is null)"
		return

	var info_text: String = ""
	var stockpile = sim.demesne.get_stockpile()

	# Create a horizontal bar with icons and amounts
	for good in stockpile:
		var icon = Library.get_good_icon(good)
		info_text += icon + " " + str(stockpile[good]) + "  "

	text = info_text

## Handles stockpile changes from the demesne
func _on_stockpile_changed(_good_id: String, _new_amount: int) -> void:
	update_info()

## Called when the simulation is initialised
func _on_sim_initialised() -> void:
	# Connect to demesne's stockpile_changed signal
	if sim and sim.demesne:
		sim.demesne.stockpile_changed.connect(_on_stockpile_changed)
	update_info()
#endregion
