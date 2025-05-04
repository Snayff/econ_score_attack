## Demesne
## Represents a territory with its own rules, laws, people, and resources
## Manages the stockpile of resources and the people within its borders
#@icon("")
class_name Demesne
extends Node

const Law = preload("res://scripts/laws/law.gd")
const LawRegistry = preload("res://scripts/laws/law_registry.gd")
const DemesneInheritance = preload("res://scripts/laws/demesne_inheritance.gd")
const DataLandParcel = preload("res://scripts/data/data_land_parcel.gd")
const ResourceGenerator = preload("res://features/economic_actor/components/resource_generator.gd")
const PathfindingSystem = preload("res://scripts/core/pathfinding_system.gd")
const SurveyManager = preload("res://scripts/core/survey_manager.gd")

#region SIGNALS
signal stockpile_changed(good_id: String, new_amount: int)
signal person_added(person: Person)
signal person_removed(person: Person)
signal law_enacted(law: Law)
signal law_repealed(law_id: String)
signal parcel_updated(x: int, y: int, parcel: DataLandParcel)
signal path_found(start: Vector2i, end: Vector2i, path: Array[Vector2i])
signal path_failed(start: Vector2i, end: Vector2i, reason: String)
#endregion


#region VARS
## Name of the demesne
var demesne_name: String = ""

## Stockpile of resources held by the demesne
var stockpile: Dictionary = {}

## People living within the demesne
var people: Array[Person] = []

## Laws and rules of the demesne
var laws: Dictionary = {}

## Registry of available law types
var law_registry: LawRegistry

## Grid of land parcels
var land_grid: Array[Array] = []

## Width of the land grid
var grid_width: int = 0

## Height of the land grid
var grid_height: int = 0

## Resource generator component
var _resource_generator: ResourceGenerator

## Pathfinding system component
var _pathfinding: PathfindingSystem

## Set of surveyed parcels (Dictionary used as a set: keys are Vector2i, values are true)
var surveyed_parcels: Dictionary = {}

## Surveys in progress dictionary
var surveys_in_progress: Dictionary = {} # keys: Vector2i(x, y), values: turns remaining
#endregion


#region FUNCS
func _init(demesne_name_: String) -> void:
	demesne_name = demesne_name_
	law_registry = LawRegistry.new(self)
	_initialise_stockpile()
	_initialise_land_grid()
	_setup_resource_generator()
	_setup_pathfinding()

## Initialises the stockpile with starting values
func _initialise_stockpile() -> void:
	stockpile = {
		"money": 0,
		"grain": 0,
		"water": 0,
		"wood": 0,
		"bureaucracy": 0
	}

## Initialises the land grid with default size and terrain
func _initialise_land_grid() -> void:
	var land_config = Library.get_config("land")
	if not land_config:
		Logger.error("Failed to load land configuration", "Demesne")
		return

	var default_size = land_config.get("grid", {}).get("default_size", {"width": 10, "height": 10})
	grid_width = default_size.width
	grid_height = default_size.height

	# Create empty grid, all parcels unsurveyed by default
	land_grid.clear()
	for x in range(grid_width):
		var column: Array[DataLandParcel] = []
		for y in range(grid_height):
			var terrain_type = "plains"  # Default terrain type
			var parcel = DataLandParcel.new(x, y, terrain_type)
			parcel.is_surveyed = false
			column.append(parcel)
		land_grid.append(column)

	# Survey the centre-most parcel on initialisation
	var centre_x: int = int(grid_width / 2)
	var centre_y: int = int(grid_height / 2)
	if _is_valid_coordinates(centre_x, centre_y):
		survey_parcel(centre_x, centre_y)

## Sets up the resource generator component
func _setup_resource_generator() -> void:
	_resource_generator = ResourceGenerator.new()
	add_child(_resource_generator)

	# Connect signals
	_resource_generator.aspect_discovered.connect(_on_aspect_discovered)
	_resource_generator.aspects_updated.connect(_on_aspects_updated)

	# Initialize resources for all parcels
	for x in range(grid_width):
		for y in range(grid_height):
			_resource_generator.initialise_resources(land_grid[x][y])

## Sets up the pathfinding system component
func _setup_pathfinding() -> void:
	_pathfinding = PathfindingSystem.new()
	add_child(_pathfinding)
	_pathfinding.initialize(land_grid)

	# Connect signals
	_pathfinding.path_found.connect(_on_path_found)
	_pathfinding.path_failed.connect(_on_path_failed)

## Finds a path between two points in the demesne
## @param start: Starting coordinates
## @param end: Target coordinates
## @return: Array of coordinates representing the path, or empty array if no path found
func find_path(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	return _pathfinding.find_path(start, end)

## Gets the movement cost between two adjacent tiles
## @param from: Starting coordinates
## @param to: Target coordinates
## @return: Movement cost between the tiles
func get_movement_cost(from: Vector2i, to: Vector2i) -> float:
	return _pathfinding.get_movement_cost(from, to)

## Handles path found signal from pathfinding system
## @param start: Starting coordinates
## @param end: Target coordinates
## @param path: Found path
func _on_path_found(start: Vector2i, end: Vector2i, path: Array[Vector2i]) -> void:
	path_found.emit(start, end, path)

## Handles path failed signal from pathfinding system
## @param start: Starting coordinates
## @param end: Target coordinates
## @param reason: Reason for failure
func _on_path_failed(start: Vector2i, end: Vector2i, reason: String) -> void:
	path_failed.emit(start, end, reason)

## Gets a land parcel at the specified coordinates
## @param x: X coordinate in the grid
## @param y: Y coordinate in the grid
## @return: The land parcel at the coordinates or null if invalid
func get_parcel(x: int, y: int) -> DataLandParcel:
	if not _is_valid_coordinates(x, y):
		Logger.error("Invalid coordinates (%d, %d)" % [x, y], "Demesne")
		return null
	return land_grid[x][y]

## Sets a land parcel at the specified coordinates
## @param x: X coordinate in the grid
## @param y: Y coordinate in the grid
## @param parcel: The land parcel to set
## @return: bool indicating if the operation was successful
func set_parcel(x: int, y: int, parcel: DataLandParcel) -> bool:
	if not _is_valid_coordinates(x, y):
		Logger.error("Invalid coordinates (%d, %d)" % [x, y], "Demesne")
		return false
	if parcel.x != x or parcel.y != y:
		Logger.error("Parcel coordinates (%d, %d) don't match target position (%d, %d)" % [parcel.x, parcel.y, x, y], "Demesne")
		return false

	land_grid[x][y] = parcel
	emit_signal("parcel_updated", x, y, parcel)
	Logger.log_event("parcel_updated", {
		"x": x,
		"y": y,
		"terrain_type": parcel.terrain_type,
		"timestamp": Time.get_unix_time_from_system()
	}, "Demesne")
	return true

## Checks if the coordinates are within the grid bounds
## @param x: X coordinate to check
## @param y: Y coordinate to check
## @return: bool indicating if the coordinates are valid
func _is_valid_coordinates(x: int, y: int) -> bool:
	return x >= 0 and x < grid_width and y >= 0 and y < grid_height

## Gets the dimensions of the land grid
## @return: Vector2i containing the width and height of the grid
func get_grid_dimensions() -> Vector2i:
	return Vector2i(grid_width, grid_height)

## Processes production for all people in the demesne
func process_production() -> void:
	Logger.log_event("production_cycle_started", {
		"demesne": demesne_name,
		"people_count": people.size(),
		"alive_count": people.filter(func(p): return p.is_alive).size(),
		"timestamp": Time.get_unix_time_from_system()
	}, "Demesne")

	# Update resources in all parcels
	for x in range(grid_width):
		for y in range(grid_height):
			_resource_generator.update(land_grid[x][y], 1.0)  # Update with 1 second delta

	for person in people:
		if not person.is_alive:
			continue

		# Handle regular production
		person.produce()

		# Special handling for bureaucrats
		if person.job == "bureaucrat":
			add_resource("bureaucracy", 5)

	Logger.log_event("production_cycle_completed", {
		"demesne": demesne_name,
		"final_stockpile": stockpile.duplicate(),
		"timestamp": Time.get_unix_time_from_system()
	}, "Demesne")

## Processes consumption for all people in the demesne
func process_consumption() -> void:
	Logger.log_event("consumption_cycle_started", {
		"demesne": demesne_name,
		"people_count": people.size(),
		"alive_count": people.filter(func(p): return p.is_alive).size(),
		"initial_stockpile": stockpile.duplicate(),
		"timestamp": Time.get_unix_time_from_system()
	}, "Demesne")

	var was_alive: Array[Person] = []

	for person in people:
		if not person.is_alive:
			continue

		was_alive.append(person)
		person.consume()

		# Check if person died during consumption
		if not person.is_alive:
			_handle_person_death(person)

	Logger.log_event("consumption_cycle_completed", {
		"demesne": demesne_name,
		"deaths_this_cycle": was_alive.filter(func(p): return not p.is_alive).size(),
		"final_stockpile": stockpile.duplicate(),
		"timestamp": Time.get_unix_time_from_system()
	}, "Demesne")

## Processes a person's death
## @param person: The person who died
func _handle_person_death(person: Person) -> void:
	Logger.log_event("handling_death", {
		"demesne": demesne_name,
		"person_name": person.f_name,
		"person_job": person.job,
		"person_stockpile": person.stockpile.duplicate(),
		"timestamp": Time.get_unix_time_from_system()
	}, "Demesne")

	# Check if demesne inheritance law is active
	var inheritance_law: DemesneInheritance = get_law("demesne_inheritance") as DemesneInheritance
	if inheritance_law and inheritance_law.active:
		inheritance_law.transfer_stockpile(person, self)

## Adds a person to the demesne
## @param person: The person to add
func add_person(person: Person) -> void:
	if not people.has(person):
		people.append(person)
		emit_signal("person_added", person)
		Logger.log_event("person_added_to_demesne", {
			"demesne": demesne_name,
			"person_name": person.f_name,
			"person_job": person.job,
			"total_people": people.size(),
			"timestamp": Time.get_unix_time_from_system()
		}, "Demesne")

## Removes a person from the demesne
## @param person: The person to remove
func remove_person(person: Person) -> void:
	if people.has(person):
		people.erase(person)
		emit_signal("person_removed", person)
		Logger.log_event("person_removed_from_demesne", {
			"demesne": demesne_name,
			"person_name": person.f_name,
			"person_job": person.job,
			"total_people": people.size(),
			"timestamp": Time.get_unix_time_from_system()
		}, "Demesne")

## Adds resources to the demesne's stockpile
## @param good_id: The ID of the good to add
## @param amount: The amount to add
func add_resource(good_id: String, amount: int) -> void:
	if not stockpile.has(good_id):
		stockpile[good_id] = 0
	stockpile[good_id] += amount
	Logger.log_event("resource_added_to_stockpile", {
		"demesne": demesne_name,
		"good": good_id,
		"amount": amount,
		"new_total": stockpile[good_id],
		"timestamp": Time.get_unix_time_from_system()
	}, "Demesne")
	emit_signal("stockpile_changed", good_id, stockpile[good_id])

## Removes resources from the demesne's stockpile
## @param good_id: The ID of the good to remove
## @param amount: The amount to remove
## @return: bool indicating if removal was successful
func remove_resource(good_id: String, amount: int) -> bool:
	if not stockpile.has(good_id) or stockpile[good_id] < amount:
		Logger.log_event("resource_removal_failed", {
			"demesne": demesne_name,
			"good": good_id,
			"amount_requested": amount,
			"available": stockpile.get(good_id, 0),
			"timestamp": Time.get_unix_time_from_system()
		}, "Demesne")
		return false
	stockpile[good_id] -= amount
	Logger.log_event("resource_removed_from_stockpile", {
		"demesne": demesne_name,
		"good": good_id,
		"amount": amount,
		"new_total": stockpile[good_id],
		"timestamp": Time.get_unix_time_from_system()
	}, "Demesne")
	emit_signal("stockpile_changed", good_id, stockpile[good_id])
	return true

## Enacts a law in the demesne
## @param law_id: The ID of the law to enact
## @return: The enacted law or null if creation failed
func enact_law(law_id: String) -> Law:
	# Check if law already exists
	if laws.has(law_id):
		var existing_law: Law = laws[law_id]
		if not existing_law.active:
			existing_law.activate()
			Logger.log_event("existing_law_activated", {
				"demesne": demesne_name,
				"law_id": law_id,
				"law_name": existing_law.name,
				"timestamp": Time.get_unix_time_from_system()
			}, "Demesne")
		return existing_law

	# Create a new law
	var law: Law = law_registry.create_law(law_id)
	if law == null:
		Logger.log_event("law_creation_failed", {
			"demesne": demesne_name,
			"law_id": law_id,
			"timestamp": Time.get_unix_time_from_system()
		}, "Demesne")
		return null

	# Activate and store the law
	law.activate()
	laws[law_id] = law
	emit_signal("law_enacted", law)
	Logger.log_event("new_law_enacted", {
		"demesne": demesne_name,
		"law_id": law_id,
		"law_name": law.name,
		"timestamp": Time.get_unix_time_from_system()
	}, "Demesne")
	return law

## Repeals a law from the demesne
## @param law_id: The ID of the law to repeal
## @return: bool indicating if repeal was successful
func repeal_law(law_id: String) -> bool:
	if not laws.has(law_id):
		Logger.log_event("law_repeal_failed", {
			"demesne": demesne_name,
			"law_id": law_id,
			"reason": "law_not_found",
			"timestamp": Time.get_unix_time_from_system()
		}, "Demesne")
		return false

	var law: Law = laws[law_id]
	law.deactivate()
	laws.erase(law_id)
	emit_signal("law_repealed", law_id)
	Logger.log_event("law_repealed", {
		"demesne": demesne_name,
		"law_id": law_id,
		"law_name": law.name,
		"timestamp": Time.get_unix_time_from_system()
	}, "Demesne")
	return true

## Gets a law by its ID
## @param law_id: The ID of the law to get
## @return: The law or null if not found
func get_law(law_id: String) -> Law:
	return laws.get(law_id, null)

## Checks if a law is active
## @param law_id: The ID of the law to check
## @return: bool indicating if the law is active
func is_law_active(law_id: String) -> bool:
	var law: Law = get_law(law_id)
	return law != null and law.active

## Gets the current stockpile of the demesne
## @return: Dictionary of goods and their amounts
func get_stockpile() -> Dictionary:
	return stockpile.duplicate(true)

## Gets the people living in the demesne
## @return: Array of Person objects
func get_people() -> Array[Person]:
	return people.duplicate(true)

## Gets the laws of the demesne
## @return: Dictionary of laws
func get_laws() -> Dictionary:
	return laws.duplicate(true)

## Surveys a land parcel for resources
## @param x: X coordinate of the parcel
## @param y: Y coordinate of the parcel
## @return: Array of discovered aspect IDs
func survey_parcel(x: int, y: int) -> Array[String]:
	Logger.log_event("diagnostic_survey_parcel_called", {"x": x, "y": y, "type_x": typeof(x), "type_y": typeof(y), "timestamp": Time.get_unix_time_from_system()}, "Demesne")
	var parcel = World.get_parcel(x, y)
	if not parcel:
		Logger.log_event("diagnostic_survey_parcel_null_parcel", {"x": x, "y": y, "timestamp": Time.get_unix_time_from_system()}, "Demesne")
		return []

	# Log parcel state before survey
	var aspect_storage_before = parcel.get_aspect_storage()
	var all_aspects_before = aspect_storage_before.get_all_aspects()
	var discovered_before = aspect_storage_before.get_discovered_aspects()
	Logger.log_event("diagnostic_survey_before", {
		"x": x,
		"y": y,
		"is_surveyed": parcel.is_surveyed,
		"all_aspects": all_aspects_before,
		"discovered_aspects": discovered_before,
		"timestamp": Time.get_unix_time_from_system()
	}, "Demesne")

	surveyed_parcels[Vector2i(x, y)] = true
	Logger.log_event("diagnostic_survey_parcel_set", {"key": str(Vector2i(x, y)), "timestamp": Time.get_unix_time_from_system()}, "Demesne")

	# Complete the survey on the parcel itself
	var discovered_aspects: Array[String] = []
	discovered_aspects.append_array(parcel.complete_survey())

	# Ensure World is updated about the survey completion
	World.complete_survey(x, y)

	# Log the parcel state after survey
	var aspect_storage_after = parcel.get_aspect_storage()
	var all_aspects_after = aspect_storage_after.get_all_aspects()
	var discovered_after = aspect_storage_after.get_discovered_aspects()
	Logger.log_event("diagnostic_survey_after", {
		"x": x,
		"y": y,
		"is_surveyed": parcel.is_surveyed,
		"all_aspects": all_aspects_after,
		"discovered_aspects": discovered_after,
		"newly_discovered": discovered_aspects,
		"timestamp": Time.get_unix_time_from_system()
	}, "Demesne")

	# Also run the resource generator's survey for any additional logic
	_resource_generator.survey_parcel(parcel)

	return discovered_aspects

## Handles resource discovery events
## @param x: X coordinate of the parcel
## @param y: Y coordinate of the parcel
## @param aspect_id: ID of the discovered aspect
## @param aspect_data: Data about the discovered aspect
func _on_aspect_discovered(x: int, y: int, aspect_id: String, aspect_data: Dictionary) -> void:
	EventBusGame.emit_signal("aspect_discovered", x, y, aspect_id, aspect_data)
	Logger.log_event("aspect_discovered", {
		"demesne": demesne_name,
		"x": x,
		"y": y,
		"aspect_id": aspect_id,
		"aspect_data": aspect_data,
	}, "Demesne")

## Handles aspect update events
## @param x: X coordinate of the parcel
## @param y: Y coordinate of the parcel
## @param aspects: Updated aspects dictionary
func _on_aspects_updated(x: int, y: int, aspects: Dictionary) -> void:
	EventBusGame.emit_signal("aspects_updated", x, y, aspects)
	Logger.log_event("parcel_aspects_updated", {
		"demesne": demesne_name,
		"x": x,
		"y": y,
		"aspects": aspects,
	}, "Demesne")
	emit_signal("parcel_updated", x, y, land_grid[x][y])

## Checks if a parcel is surveyed for this demesne
## @param x: int
## @param y: int
## @return: bool
func is_parcel_surveyed(x: int, y: int) -> bool:
	var key = Vector2i(x, y)
	var result = surveyed_parcels.has(key)
	return result

## Requests a survey for a parcel. Returns true if started, false if already surveyed or in progress.
func request_survey(x: int, y: int) -> bool:
	var key = Vector2i(x, y)
	if is_parcel_surveyed(x, y) or surveys_in_progress.has(key):
		return false
	surveys_in_progress[key] = SurveyManager.SURVEY_TURNS
	Logger.log_event("survey_started", {"x": x, "y": y, "demesne": demesne_name, "timestamp": Time.get_unix_time_from_system()}, "Demesne")
	return true

## Advances all surveys by 1 turn. Call this at the end of each turn.
func advance_turn() -> void:
	var completed: Array = []
	for key in surveys_in_progress.keys():
		surveys_in_progress[key] -= 1
		if surveys_in_progress[key] <= 0:
			completed.append(key)
	for key in completed:
		surveys_in_progress.erase(key)

		# Complete the survey and get discovered resources
		var discovered_aspects = survey_parcel(key.x, key.y)

		# Log the completion
		Logger.log_event("survey_completed", {
			"x": key.x,
			"y": key.y,
			"demesne": demesne_name,
			"discovered_aspects": discovered_aspects,
			"timestamp": Time.get_unix_time_from_system()
		}, "Demesne")

		# Emit signal with the properly typed array
		var typed_aspects: Array[String] = []
		typed_aspects.append_array(discovered_aspects)
		EventBusGame.parcel_surveyed.emit(key.x, key.y, typed_aspects)

func connect_to_turns() -> void:
	EventBusGame.turn_complete.connect(_on_turn_complete)

func _on_turn_complete() -> void:
	advance_turn()
	EventBusGame.land_grid_updated.emit()
