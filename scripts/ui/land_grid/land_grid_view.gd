## A UI component that displays the land grid and handles user interactions with land parcels.
## This component visualizes terrain, resources, and improvements, and provides
## interaction capabilities for selecting and viewing parcel information.
class_name LandGridView
extends Control


#region CONSTANTS

const PARCEL_SIZE := 64
const PARCEL_MARGIN := 2

#endregion


#region SIGNALS

## Emitted when a land parcel is selected
signal parcel_selected(x: int, y: int)

#endregion


#region EXPORTS

@export var grid_size: Vector2i = Vector2i(10, 10)

#endregion


#region ON READY

@onready var _grid_container: GridContainer = $HBoxContainer/GridContainer
@onready var _info_panel: Panel = $HBoxContainer/InfoPanel
@onready var _lbl_parcel_info: RichTextLabel = $HBoxContainer/InfoPanel/lbl_ParcelInfo
@onready var _control_panel: LandControlPanel = $HBoxContainer/LandControlPanel

#endregion


#region PUBLIC FUNCTIONS

func _ready() -> void:
    assert(_grid_container != null, "GridContainer node not found")
    assert(_info_panel != null, "InfoPanel node not found")
    assert(_lbl_parcel_info != null, "ParcelInfo label node not found")
    assert(_control_panel != null, "Control panel node not found")
    
    EventBusUI.land_grid_updated.connect(_on_land_grid_updated)
    _initialize_grid()
    # Always show info for the default parcel (0,0) on startup
    EventBusGame.request_parcel_data.emit(0, 0)


func update_parcel(x: int, y: int, parcel_data: DataLandParcel) -> void:
    var parcel_view := _get_parcel_view(x, y)
    if parcel_view:
        parcel_view.update_display(parcel_data)


func highlight_parcel(x: int, y: int, highlight: bool = true) -> void:
    var parcel_view := _get_parcel_view(x, y)
    if parcel_view:
        parcel_view.set_highlighted(highlight)

#endregion


#region PRIVATE FUNCTIONS

func _initialize_grid() -> void:
    _grid_container.columns = grid_size.x
    
    for y in range(grid_size.y):
        for x in range(grid_size.x):
            var parcel_view := _create_parcel_view(x, y)
            _grid_container.add_child(parcel_view)


func _create_parcel_view(x: int, y: int) -> LandParcelView:
    var parcel_view := LandParcelView.new()
    parcel_view.custom_minimum_size = Vector2(PARCEL_SIZE, PARCEL_SIZE)
    parcel_view.size = Vector2(PARCEL_SIZE, PARCEL_SIZE)
    parcel_view.position = Vector2(x * (PARCEL_SIZE + PARCEL_MARGIN), 
                                 y * (PARCEL_SIZE + PARCEL_MARGIN))
    parcel_view.coordinates = Vector2i(x, y)
    parcel_view.parcel_clicked.connect(_on_parcel_clicked)
    return parcel_view


func _get_parcel_view(x: int, y: int) -> LandParcelView:
    var index := y * grid_size.x + x
    if index < _grid_container.get_child_count():
        return _grid_container.get_child(index) as LandParcelView
    return null


func _update_info_panel(parcel_data: DataLandParcel) -> void:
    if not parcel_data.is_surveyed:
        _lbl_parcel_info.text = "[b]Unknown[/b]"
        _control_panel.update_parcel_info(parcel_data)
        return
    var info_text := "[b]Terrain:[/b] %s\n" % parcel_data.terrain_type
    
    if parcel_data.is_surveyed:
        info_text += "\n[b]Resources:[/b]\n"
        for resource_id in parcel_data.resources:
            var resource = parcel_data.resources[resource_id]
            if resource.discovered:
                info_text += "- %s: %.1f\n" % [resource_id, resource.amount]
    else:
        info_text += "\n[i]Unsurveyed[/i]\n"
    
    if parcel_data.building_id:
        info_text += "\n[b]Building:[/b] %s" % parcel_data.building_id
    
    if parcel_data.improvements:
        info_text += "\n[b]Improvements:[/b]\n"
        for improvement_id in parcel_data.improvements:
            var level = parcel_data.improvements[improvement_id]
            info_text += "- %s (Level %d)\n" % [improvement_id, level]
    
    info_text += "\n[b]Environmental:[/b]\n"
    info_text += "Fertility: %.2f\n" % parcel_data.fertility
    info_text += "Pollution: %.2f" % parcel_data.pollution_level
    
    _lbl_parcel_info.text = info_text
    _control_panel.update_parcel_info(parcel_data)


func _on_parcel_clicked(x: int, y: int) -> void:
    parcel_selected.emit(x, y)
    EventBusGame.request_parcel_data.emit(x, y)


func _on_land_grid_updated(parcel_data: DataLandParcel) -> void:
    update_parcel(parcel_data.x, parcel_data.y, parcel_data)
    _update_info_panel(parcel_data)

#endregion 