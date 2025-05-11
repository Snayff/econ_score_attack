## Sidebar for main UI, emits signals when sidebar buttons are pressed.
## Usage: Connect to the signals to handle view switching in the main UI.
## Last Updated: 2025-05-11

extends PanelContainer

#region SIGNALS
signal people_pressed
signal laws_pressed
signal land_pressed
signal economy_pressed
#endregion


#region ON READY
@onready var _btn_people: Button = %BtnPeople
@onready var _btn_laws: Button = %BtnLaws
@onready var _btn_land: Button = %BtnLand
@onready var _btn_economy: Button = %BtnEconomy

func _ready() -> void:
	assert(_btn_people != null, "BtnPeople not found")
	assert(_btn_laws != null, "BtnLaws not found")
	assert(_btn_land != null, "BtnLand not found")
	assert(_btn_economy != null, "BtnEconomy not found")
	_btn_people.pressed.connect(_on_people_pressed)
	_btn_laws.pressed.connect(_on_laws_pressed)
	_btn_land.pressed.connect(_on_land_pressed)
	_btn_economy.pressed.connect(_on_economy_pressed)
#endregion


#region PUBLIC FUNCTIONS

#endregion


#region PRIVATE FUNCTIONS
func _on_people_pressed() -> void:
	emit_signal("people_pressed")
	EventBusUI.sidebar_people_pressed.emit()

func _on_laws_pressed() -> void:
	emit_signal("laws_pressed")
	EventBusUI.sidebar_laws_pressed.emit()

func _on_land_pressed() -> void:
	emit_signal("land_pressed")
	EventBusUI.sidebar_land_pressed.emit()

func _on_economy_pressed() -> void:
	emit_signal("economy_pressed")
	EventBusUI.sidebar_economy_pressed.emit()
#endregion
