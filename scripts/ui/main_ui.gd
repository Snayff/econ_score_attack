extends Control

## Main UI controller that manages the different views and UI components


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

@onready var _btn_people: Button = %BtnPeople
@onready var _btn_laws: Button = %BtnLaws
@onready var _btn_land: Button = %BtnLand
@onready var _btn_economy: Button = %BtnEconomy

@onready var _view_people: Control = %ViewPeople
@onready var _view_laws: Control = %ViewLaws
@onready var _view_land: Control = %ViewLand
@onready var _view_economy: Control = %ViewEconomy

@onready var _panel_header: Control = %PanelHeader

func _ready() -> void:
	assert(_btn_people != null, "People button not found")
	assert(_btn_laws != null, "Laws button not found")
	assert(_btn_land != null, "Land button not found")
	assert(_btn_economy != null, "Economy button not found")
	
	assert(_view_people != null, "People view not found")
	assert(_view_laws != null, "Laws view not found")
	assert(_view_land != null, "Land view not found")
	assert(_view_economy != null, "Economy view not found")
	
	assert(_panel_header != null, "Panel header not found")
	
	_btn_people.pressed.connect(func(): _switch_view(View.PEOPLE))
	_btn_laws.pressed.connect(func(): _switch_view(View.LAWS))
	_btn_land.pressed.connect(func(): _switch_view(View.LAND))
	_btn_economy.pressed.connect(func(): _switch_view(View.ECONOMY))
	
	# Start with people view
	_switch_view(View.PEOPLE)

	# Show a test notification to demonstrate the notification system is working
	EventBusUI.show_notification.emit("Welcome to your demesne!", "info")

	# Inject real land grid data into LandViewPanel
	var sim_node = get_node("/root/Main/Sim")
	if sim_node and sim_node.demesne:
		var demesne = sim_node.demesne
		var land_grid = demesne.land_grid
		var grid_dims = demesne.get_grid_dimensions()
		_view_land.set_land_grid(land_grid, grid_dims.x, grid_dims.y)
		EventBusGame.land_grid_updated.connect(_on_land_grid_updated)

func _on_land_grid_updated() -> void:
	# Refresh the land view when the grid is updated
	if _view_land:
		var sim_node = get_node("/root/Main/Sim")
		if sim_node and sim_node.demesne:
			var demesne = sim_node.demesne
			var land_grid = demesne.land_grid
			var grid_dims = demesne.get_grid_dimensions()
			_view_land.set_land_grid(land_grid, grid_dims.x, grid_dims.y)

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
