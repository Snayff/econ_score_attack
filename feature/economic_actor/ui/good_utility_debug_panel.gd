## good_utility_debug_panel.gd
## Stand-alone debug UI for inspecting good utility calculations for actors.
## Requires Factory to be set as an autoload (singleton)
extends Control

#region CONSTANTS
#endregion


#region SIGNALS
signal actor_selected(actor_id: String)
signal evaluation_triggered(actor_id: String)
#endregion


#region ON READY
@onready var lst_actor: OptionButton = %lst_actor
@onready var btn_evaluate: Button = %btn_evaluate
@onready var txt_actor_info: RichTextLabel = %txt_actor_info
@onready var txt_goods_info: RichTextLabel = %txt_goods_info
@onready var txt_result: Label = %txt_result
#endregion


#region EXPORTS
#endregion


#region VARS
var _actors: Array = []
var _goods: Array = []
var _cultures: Dictionary = {}
var _ancestries: Dictionary = {}
var _prices: Dictionary = {}
var _selected_actor: DataActor = null
#endregion


#region PUBLIC FUNCTIONS
func _ready() -> void:
	assert(lst_actor != null)
	assert(btn_evaluate != null)
	assert(txt_actor_info != null)
	assert(txt_goods_info != null)
	assert(txt_result != null)

	_actors = Factory.generate_starting_people()
	_goods = Library.get_all_goods_data()
	Logger.info("[ACTOR_DEBUG_TRACE] UI ready, actors loaded: %s" % [_actors], "ActorDebug")
	print("Loaded actors: ", _actors)
	_cultures = {}
	for culture in Library.get_all_cultures_data():
		_cultures[culture.id] = culture

	# Build ancestries dict
	_ancestries = {}
	var ancestry_config = Library.get_config("ancestries")
	if ancestry_config.has("ancestries"):
		for ancestry in ancestry_config["ancestries"]:
			_ancestries[ancestry["id"]] = ancestry

	# Build prices dict
	_prices = {}
	for good in _goods:
		_prices[good.id] = good.base_price

	lst_actor.clear()
	if _actors.size() == 0:
		lst_actor.add_item("No actors loaded", -1)
	else:
		for actor in _actors:
			lst_actor.add_item("Actor %s" % str(actor.id), actor.id)
	lst_actor.connect("item_selected", Callable(self, "_on_actor_selected"))
	btn_evaluate.connect("pressed", Callable(self, "_on_evaluate_pressed"))

	if _actors.size() > 0:
		_select_actor(0)

func _on_actor_selected(index: int) -> void:
	_select_actor(index)
	emit_signal("actor_selected", str(_selected_actor.id))

func _on_evaluate_pressed() -> void:
	if _selected_actor == null:
		txt_result.text = "No actor selected."
		return
	var util_dict = GoodUtilityComponent.calculate_good_utility(_selected_actor, _goods, _cultures, _ancestries, _prices)
	var best_good = GoodUtilityComponent.select_best_affordable_good(_selected_actor, _goods, _cultures, _ancestries, _prices)
	_update_goods_info(util_dict, best_good)
	emit_signal("evaluation_triggered", str(_selected_actor.id))

func _select_actor(index: int) -> void:
	_selected_actor = _actors[index]
	_update_actor_info()
	txt_goods_info.text = ""
	txt_result.text = ""

func _update_actor_info() -> void:
	var info = "[b]Actor ID:[/b] %s\n[b]Culture:[/b] %s\n[b]Ancestry:[/b] %s\n[b]Needs:[/b] %s\n[b]Disposable Income:[/b] %.2f" % [
		str(_selected_actor.id), _selected_actor.culture_id, _selected_actor.ancestry_id, str(_selected_actor.needs), _selected_actor.disposable_income]
	txt_actor_info.text = info

func _update_goods_info(util_dict: Dictionary, best_good: String) -> void:
	var text = "[b]Goods Utility:[/b]\n"
	for good in _goods:
		var util = util_dict.get(good.id, 0.0)
		var price = _prices.get(good.id, 0.0)
		var affordable = _selected_actor.disposable_income >= price
		text += "%s: Utility=%.2f, Price=%.2f, %s\n" % [good.id, util, price, ("Affordable" if _selected_actor.disposable_income >= price else "Not affordable")]
	txt_goods_info.text = text
	txt_result.text = ("Best Good: %s" % best_good) if best_good != "" else "No affordable good."
#endregion


#region PRIVATE FUNCTIONS
#endregion
