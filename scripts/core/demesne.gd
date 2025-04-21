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
#endregion


#region FUNCS
func _init(demesne_name_: String) -> void:
	Logger.debug("Demesne: Initializing with name " + demesne_name_, "Demesne")
	demesne_name = demesne_name_
	_initialise_stockpile()

## Initialises the stockpile with starting values
func _initialise_stockpile() -> void:
	Logger.debug("Demesne: Initializing stockpile", "Demesne")
	stockpile = {
		"money": 0,
		"grain": 0,
		"water": 0,
		"wood": 0,
		"bureaucracy": 0
	}

## Processes production for all people in the demesne
func process_production() -> void:
	Logger.debug("Demesne: Processing production for " + str(people.size()) + " people", "Demesne")
	for person in people:
		if not person.is_alive:
			continue
			
		# Handle regular production
		person.produce()
		
		# Special handling for bureaucrats
		if person.job == "bureaucrat":
			add_resource("bureaucracy", 5)
			Logger.debug(str(
				"Demesne received 5 bureaucracy from ", 
				person.f_name, 
				". Total: ", 
				stockpile["bureaucracy"],
				"📋"
			), "Demesne")

## Processes consumption for all people in the demesne
func process_consumption() -> void:
	Logger.debug("Demesne: Processing consumption for " + str(people.size()) + " people", "Demesne")
	for person in people:
		if not person.is_alive:
			continue
			
		person.consume()

## Adds a person to the demesne
## @param person: The person to add
func add_person(person: Person) -> void:
	Logger.debug("Demesne: Adding person " + person.f_name, "Demesne")
	if not people.has(person):
		people.append(person)
		emit_signal("person_added", person)
		Logger.debug("Demesne: Now has " + str(people.size()) + " people", "Demesne")

## Removes a person from the demesne
## @param person: The person to remove
func remove_person(person: Person) -> void:
	Logger.debug("Demesne: Removing person " + person.f_name, "Demesne")
	if people.has(person):
		people.erase(person)
		emit_signal("person_removed", person)
		Logger.debug("Demesne: Now has " + str(people.size()) + " people", "Demesne")

## Adds resources to the demesne's stockpile
## @param good_id: The ID of the good to add
## @param amount: The amount to add
func add_resource(good_id: String, amount: int) -> void:
	if not stockpile.has(good_id):
		stockpile[good_id] = 0
	stockpile[good_id] += amount
	Logger.debug("Demesne: Added " + str(amount) + " " + good_id + ". Total: " + str(stockpile[good_id]), "Demesne")
	emit_signal("stockpile_changed", good_id, stockpile[good_id])

## Removes resources from the demesne's stockpile
## @param good_id: The ID of the good to remove
## @param amount: The amount to remove
## @return: bool indicating if removal was successful
func remove_resource(good_id: String, amount: int) -> bool:
	if not stockpile.has(good_id) or stockpile[good_id] < amount:
		return false
	stockpile[good_id] -= amount
	emit_signal("stockpile_changed", good_id, stockpile[good_id])
	return true

## Adds a law to the demesne
## @param law_id: The ID of the law
## @param law_data: The data for the law
func add_law(law_id: String, law_data: Dictionary) -> void:
	laws[law_id] = law_data

## Removes a law from the demesne
## @param law_id: The ID of the law to remove
func remove_law(law_id: String) -> void:
	if laws.has(law_id):
		laws.erase(law_id)

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
#endregion 