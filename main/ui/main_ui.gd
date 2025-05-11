## Main UI controller that manages the different views and UI components
## Last Updated: 2025-05-11
extends Control


#region EXPORTS


#endregion


#region CONSTANTS

enum View {
	PEOPLE,
	LAWS,
	LAND,
	ECONOMY
}

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
	assert(_view_laws != null, "Laws view not found")
	assert(_view_land != null, "Land view not found")
	assert(_view_economy != null, "Economy view not found")
	assert(_panel_header != null, "Panel header not found")

	EventBusUI.sidebar_people_pressed.connect(func(): _switch_view(View.PEOPLE))
	EventBusUI.sidebar_laws_pressed.connect(func(): _switch_view(View.LAWS))
	EventBusUI.sidebar_land_pressed.connect(func(): _switch_view(View.LAND))
	EventBusUI.sidebar_economy_pressed.connect(func(): _switch_view(View.ECONOMY))

	# Start with people view
	_switch_view(View.PEOPLE)

	# Show a test notification to demonstrate the notification system is working
	EventBusUI.show_notification.emit("Welcome to your demesne!", "info")

	# Connect to World grid initialisation
	World.world_grid_updated.connect(_on_world_grid_ready)

func _on_world_grid_ready() -> void:
	var sim_node = get_node("/root/Main/Sim")
	if sim_node and sim_node.demesne:
		var demesne = sim_node.demesne
		var grid_dims = World.get_grid_dimensions()
		_view_land.set_grid_and_demesne(grid_dims.x, grid_dims.y, demesne)
		EventBusGame.land_grid_updated.connect(_on_land_grid_updated)

func _on_land_grid_updated() -> void:
	# Refresh the land view when the grid is updated
	if _view_land:
		var sim_node = get_node("/root/Main/Sim")
		if sim_node and sim_node.demesne:
			var demesne = sim_node.demesne
			var grid_dims = World.get_grid_dimensions()
			_view_land.set_grid_and_demesne(grid_dims.x, grid_dims.y, demesne)

#endregion


#region PUBLIC FUNCTIONS


#endregion


#region PRIVATE FUNCTIONS

func _switch_view(view: View) -> void:
	# Hide all views
	_view_people.visible = false
	_view_laws.visible = false
	_view_land.visible = false
	_view_economy.visible = false

	# Show selected view
	match view:
		View.PEOPLE:
			_view_people.visible = true
			_panel_header.set_title("People")
		View.LAWS:
			_view_laws.visible = true
			_panel_header.set_title("Laws")
		View.LAND:
			_view_land.visible = true
			_panel_header.set_title("Land Management")
		View.ECONOMY:
			_view_economy.visible = true
			_panel_header.set_title("Economy")

#endregion
