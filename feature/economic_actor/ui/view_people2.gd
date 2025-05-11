##
## ViewPeople2: Updated people view using ABCView layout.
## Displays information about people in the simulation using the standardised UI layout.
## Usage: Add this scene to a parent UI node. Populates the centre panel of ABCView with people info.
## Last Updated: 2025-05-11
##
extends Control

#region CONSTANTS
#endregion

#region SIGNALS
#endregion

#region EXPORTS
@export var sim: Sim
#endregion

#region ON READY
@onready var abc_view: Control = $ABCView
@onready var left_sidebar: VBoxContainer = $ABCView/HBoxContainer/LeftSidebar
@onready var centre_panel: PanelContainer = $ABCView/HBoxContainer/MainArea/CentrePanel
#endregion

#region VARS
var _debug_panel: Control = null
#endregion

#region PUBLIC FUNCTIONS
## Updates the displayed information in the centre panel.
func update_info() -> void:
    centre_panel.clear_children()
    if not sim:
        _add_error_message("No simulation data available (sim is null)")
        return
    if not sim.demesne:
        _add_error_message("No simulation data available (demesne is null)")
        return
    var living_people = []
    for person in sim.demesne.get_people():
        if person.is_alive:
            living_people.append(person)
    if living_people.is_empty():
        _add_error_message("No living people in the demesne.")
        return
    var vbox = VBoxContainer.new()
    vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
    # Header row
    var header = _create_person_row(["Name", "Job", "Health", "Happiness", "Stockpile"], true)
    vbox.add_child(header)
    # Person rows
    for person in living_people:
        var row = _create_person_panel(person)
        vbox.add_child(row)
    centre_panel.add_child(vbox)
#endregion

#region PRIVATE FUNCTIONS
func _ready() -> void:
    # Add debug button to left sidebar
    var btn_debug = Button.new()
    btn_debug.text = "Debug Actor Data"
    btn_debug.pressed.connect(_on_debug_actor_data_pressed)
    left_sidebar.add_child(btn_debug)
    # Connect to simulation events
    if not sim:
        sim = get_node_or_null("/root/Main/Sim")
    if sim:
        if sim.has_signal("sim_initialized"):
            sim.sim_initialized.connect(update_info)
    if EventBusGame.has_signal("turn_complete"):
        EventBusGame.turn_complete.connect(update_info)
    update_info()

func _add_error_message(message: String) -> void:
    var label = Label.new()
    label.text = message
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    centre_panel.add_child(label)

func _create_person_row(values: Array, is_header: bool = false) -> HBoxContainer:
    var row = HBoxContainer.new()
    row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    for value in values:
        var label = Label.new()
        label.text = str(value)
        if is_header:
            label.add_theme_font_size_override("font_size", 16)
            label.add_theme_color_override("font_color", Color(0.7, 0.7, 1.0))
        label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        row.add_child(label)
    return row

func _create_person_panel(person: Person) -> PanelContainer:
    var panel = PanelContainer.new()
    panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    var vbox = VBoxContainer.new()
    panel.add_child(vbox)
    var row = HBoxContainer.new()
    row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    vbox.add_child(row)
    # Name
    var name_label = Label.new()
    name_label.text = person.f_name
    name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    row.add_child(name_label)
    # Job
    var job_label = Label.new()
    job_label.text = person.job if person.is_alive and not person.job.is_empty() else ""
    job_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    job_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    row.add_child(job_label)
    # Health
    var health_label = Label.new()
    health_label.text = str(person.health) + "❤️" if person.is_alive else ""
    health_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    health_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    row.add_child(health_label)
    # Happiness
    var happiness_label = Label.new()
    happiness_label.text = str(person.happiness) + "🙂" if person.is_alive else ""
    happiness_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    happiness_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    row.add_child(happiness_label)
    # Stockpile
    var stockpile_container = VBoxContainer.new()
    stockpile_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.add_child(stockpile_container)
    if person.is_alive:
        for good in person.stockpile:
            var icon = Library.get_good_icon(good)
            var good_label = Label.new()
            good_label.text = str(icon, " ", good, ": ", person.stockpile[good])
            good_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
            stockpile_container.add_child(good_label)
    return panel

func _on_debug_actor_data_pressed() -> void:
    if _debug_panel == null:
        _debug_panel = preload("res://feature/economic_actor/ui/actor_data_inspector.tscn").instantiate()
        add_child(_debug_panel)
        _debug_panel.set_position(Vector2(100, 100))
    else:
        _debug_panel.visible = not _debug_panel.visible
#endregion 