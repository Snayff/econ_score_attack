## Demesne
## Represents a territory with its own rules, laws, people, and resources
## Manages the stockpile of resources and the people within its borders
#@icon("")
class_name Demesne
extends Node


#region SIGNALS
signal stockpile_changed(good_id: String, new_amount: int)
signal person_added(person: Person)
signal person_removed(person: Person)
signal law_enacted()
signal law_repealed()
signal parcel_updated(x: int, y: int, parcel: DataLandParcel)
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

## Add survey manager component
var survey_manager: SurveyManager
#endregion


#region FUNCS
func _init(demesne_name_: String) -> void:
	demesne_name = demesne_name_
	law_registry = LawRegistry.new(self)
	_initialise_stockpile()

	survey_manager = SurveyManager.new()
	add_child(survey_manager)
	survey_manager.set_parcel_accessor(self.get_parcel)

## Initialises the stockpile with starting values
func _initialise_stockpile() -> void:
	stockpile = {
		"money": 0,
		"grain": 0,
		"water": 0,
		"wood": 0,
		"bureaucracy": 0
	}

## Gets a land parcel at the specified coordinates
## @param x: X coordinate in the grid
## @param y: Y coordinate in the grid
## @return: The land parcel at the coordinates or null if invalid
func get_parcel(x: int, y: int) -> DataLandParcel:
	return World.get_parcel(x, y)

## Checks if the coordinates are within the grid bounds
## @param x: X coordinate to check
## @param y: Y coordinate to check
## @return: bool indicating if the coordinates are valid
func _is_valid_coordinates(x: int, y: int) -> bool:
	var dims = World.get_grid_dimensions()
	return x >= 0 and x < dims.x and y >= 0 and y < dims.y

## Gets the dimensions of the land grid
## @return: Vector2i containing the width and height of the grid
func get_grid_dimensions() -> Vector2i:
	return World.get_grid_dimensions()

## Processes production for all people in the demesne
func process_production() -> void:
	Logger.log_event("production_cycle_started", {
		"demesne": demesne_name,
		"people_count": people.size(),
		"alive_count": people.filter(func(p): return p.is_alive).size(),

	}, "Demesne")

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

	}, "Demesne")

## Processes consumption for all people in the demesne
func process_consumption() -> void:
	Logger.log_event("consumption_cycle_started", {
		"demesne": demesne_name,
		"people_count": people.size(),
		"alive_count": people.filter(func(p): return p.is_alive).size(),
		"initial_stockpile": stockpile.duplicate(),

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

	}, "Demesne")

## Processes a person's death
## @param person: The person who died
func _handle_person_death(person: Person) -> void:
	Logger.log_event("handling_death", {
		"demesne": demesne_name,
		"person_name": person.f_name,
		"person_job": person.job,
		"person_stockpile": person.stockpile.duplicate(),

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

		}, "Demesne")
		return false
	stockpile[good_id] -= amount
	Logger.log_event("resource_removed_from_stockpile", {
		"demesne": demesne_name,
		"good": good_id,
		"amount": amount,
		"new_total": stockpile[good_id],

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

			}, "Demesne")
		return existing_law

	# Create a new law
	var law: Law = law_registry.create_law(law_id)
	if law == null:
		Logger.log_event("law_creation_failed", {
			"demesne": demesne_name,
			"law_id": law_id,

		}, "Demesne")
		return null

	# Activate and store the law
	law.activate()
	laws[law_id] = law
	emit_signal("law_enacted")
	Logger.log_event("new_law_enacted", {
		"demesne": demesne_name,
		"law_id": law_id,
		"law_name": law.name,

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

		}, "Demesne")
		return false

	var law: Law = laws[law_id]
	law.deactivate()
	laws.erase(law_id)
	emit_signal("law_repealed")
	Logger.log_event("law_repealed", {
		"demesne": demesne_name,
		"law_id": law_id,
		"law_name": law.name,

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
	Logger.log_event("diagnostic_survey_parcel_called", {"x": x, "y": y, "type_x": typeof(x), "type_y": typeof(y), }, "Demesne")
	var parcel = World.get_parcel(x, y)
	if not parcel:
		Logger.log_event("diagnostic_survey_parcel_null_parcel", {"x": x, "y": y, }, "Demesne")
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

	}, "Demesne")

	survey_manager.survey_parcel(x, y)

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

	}, "Demesne")

	return discovered_after

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
	emit_signal("parcel_updated", x, y, World.get_parcel(x, y))

## Requests a survey for a parcel. Returns true if started, false if already surveyed or in progress.
func request_survey(x: int, y: int) -> bool:
	return survey_manager.start_survey(x, y)

## Gets the survey progress for a parcel
## @param x: X coordinate of the parcel
## @param y: Y coordinate of the parcel
## @return: Survey progress as a float (0.0 to 1.0)
func get_survey_progress(x: int, y: int) -> float:
	return survey_manager.get_survey_progress(x, y)

## Checks if a parcel is surveyed for this demesne
## @param x: int
## @param y: int
## @return: bool
func is_parcel_surveyed(x: int, y: int) -> bool:
	return survey_manager.is_parcel_surveyed(x, y)

## Advances all surveys by 1 turn. Call this at the end of each turn.
func advance_turn() -> void:
	survey_manager.advance_turn()

func connect_to_turns() -> void:
	EventBusGame.turn_complete.connect(_on_turn_complete)

func _on_turn_complete() -> void:
	advance_turn()
	EventBusGame.land_grid_updated.emit()
