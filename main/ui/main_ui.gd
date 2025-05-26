## Main UI controller that manages the different views and UI components
## Last Updated: 2025-05-11
extends Control


#region EXPORTS
#endregion


#region CONSTANTS
#endregion


#region SIGNALS
#endregion


#region ON READY
@onready var _sidebar: Control = %GlobalSidebar
@onready var _view_people: Control = %ViewPeople
@onready var _view_laws: Control = %ViewLaws
@onready var _view_land: Control = %ViewLand
@onready var _view_economy: Control = %ViewEconomy
@onready var _panel_header: Control = %PanelHeader

func _ready() -> void:
	assert(_sidebar != null, "Sidebar not found")
	assert(_view_people != null, "People view not found")
#	assert(_view_laws != null, "Laws view not found")
#	assert(_view_land != null, "Land view not found")
#	assert(_view_economy != null, "Economy view not found")
	assert(_panel_header != null, "Panel header not found")

	EventBusUI.sidebar_people_pressed.connect(func(): _switch_view(Constants.Constants.VIEW_KEY.PEOPLE))
	EventBusUI.sidebar_laws_pressed.connect(func(): _switch_view(Constants.Constants.VIEW_KEY.LAWS))
	EventBusUI.sidebar_land_pressed.connect(func(): _switch_view(Constants.Constants.VIEW_KEY.LAND))
	EventBusUI.sidebar_economy_pressed.connect(func(): _switch_view(Constants.Constants.VIEW_KEY.ECONOMY))

	# Start with people view
	_switch_view(Constants.VIEW_KEY.PEOPLE)

	# Show a test notification to demonstrate the notification system is working
	EventBusUI.show_notification.emit("Welcome to your demesne!", "info")

#endregion


#region PUBLIC FUNCTIONS
#endregion


#region PRIVATE FUNCTIONS
func _switch_view(view_key: Constants.VIEW_KEY) -> void:
	# Hide all views
	_view_people.visible = false
#	_view_laws.visible = false
	#_view_land.visible = false
	#_view_economy.visible = false

	# Show selected view
	match view_key:
		Constants.VIEW_KEY.PEOPLE:
			_view_people.visible = true
			_panel_header.set_title("People")
		Constants.VIEW_KEY.LAW:
			_view_laws.visible = true
			_panel_header.set_title("Laws")
		Constants.VIEW_KEY.LAND:
			_view_land.visible = true
			_panel_header.set_title("Land")
		Constants.VIEW_KEY.ECONOMY:
			_view_economy.visible = true
			_panel_header.set_title("Economy")

#endregion
