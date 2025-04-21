## DemesneStockpile
## Displays information about the demesne's stockpile
## Shows current resource levels with icons
#@icon("")
class_name RTLDemesneStockpile
extends RichTextLabel


#region EXPORTS
@export var sim: Sim
#endregion


#region VARS
var goods_config: Dictionary
#endregion


#region FUNCS
func _ready() -> void:
	Logger.debug("DemesneStockpile: _ready called", "DemesneStockpile")
	EventBus.turn_complete.connect(update_info)
	if sim:
		sim.sim_initialized.connect(update_info)
	_load_goods_config()
	update_info()

func _load_goods_config() -> void:
	var config_file = FileAccess.open("res://data/goods_config.json", FileAccess.READ)
	if config_file:
		var json = JSON.parse_string(config_file.get_as_text())
		goods_config = json.get("goods", {})
	else:
		Logger.error("Failed to load goods config", "DemesneStockpile")

## Updates the displayed information
func update_info() -> void:
	Logger.debug("DemesneStockpile: update_info called", "DemesneStockpile")

	if not sim:
		Logger.error("DemesneStockpile: sim is null", "DemesneStockpile")
		text = "No simulation data available (sim is null)"
		return

	if not sim.demesne:
		Logger.error("DemesneStockpile: sim.demesne is null", "DemesneStockpile")
		text = "No simulation data available (demesne is null)"
		return

	var info_text: String = "[b]Demesne Stockpile[/b]\n\n"
	info_text += "[table=2]\n"
	info_text += "[cell][b]Resource[/b][/cell][cell][b]Amount[/b][/cell]\n"

	var stockpile = sim.demesne.get_stockpile()
	for good in stockpile:
		var icon = Library.get_good_icon(good)
		info_text += "[cell]" + icon + " " + good + "[/cell][cell]" + str(stockpile[good]) + "[/cell]\n"

	info_text += "[/table]"
	text = info_text
#endregion 