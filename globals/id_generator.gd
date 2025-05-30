## ID Generator Singleton
##
## Provides a centralised way to generate, validate, and parse unique identifiers for all game objects.
## Each ID consists of a type prefix and a UUID, ensuring uniqueness and debuggability.
##
## Usage Example:
##     var id = IDGenerator.generate_id("ACT")
##     if IDGenerator.validate_id(id):
##         var prefix = IDGenerator.get_prefix(id)
##         var uuid = IDGenerator.get_uuid(id)
##
## Prefixes should be chosen from the PREFIXES constant.
##
## This class should be registered as an autoload singleton named 'IDGenerator'.

extends Node

#region CONSTANTS

const PREFIXES: Dictionary = {
	"ACT": "Actor",
	"BLD": "Building",
	"JOB": "Job",
	# Add more as needed
}

#endregion


#region SIGNALS

#endregion


#region ON READY

#endregion


#region EXPORTS

#endregion


#region PUBLIC FUNCTIONS

## Generates a new unique identifier with a prefix.
## @param prefix String - The type prefix (e.g., "ACT").
## @return String - A unique identifier in the format PREFIX_UUID.
static func generate_id(prefix: String) -> String:
	## Ensure the prefix is valid before generating the ID.
	assert(PREFIXES.has(prefix), "Invalid prefix for ID generation.")
	var uuid: String = _generate_uuid_v4()
	return "%s_%s" % [prefix, uuid]


## Validates an ID string.
## @param id String - The ID to validate.
## @return bool - True if valid, false otherwise.
static func validate_id(id: String) -> bool:
	var parts: Array = id.split("_", false, 1)
	if parts.size() != 2:
		return false
	var prefix: String = parts[0]
	var uuid: String = parts[1]
	if not PREFIXES.has(prefix):
		return false
	var uuid_regex := RegEx.new()
	uuid_regex.compile("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")
	return uuid_regex.search(uuid) != null


## Extracts the prefix from an ID.
## @param id String - The ID string.
## @return String - The prefix.
static func get_prefix(id: String) -> String:
	return id.split("_", false, 1)[0]


## Extracts the UUID from an ID.
## @param id String - The ID string.
## @return String - The UUID.
static func get_uuid(id: String) -> String:
	return id.split("_", false, 1)[1]

#endregion


#region PRIVATE FUNCTIONS

## Generates a UUID v4 string (xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx)
## @return String - A UUID v4 string.
static func _generate_uuid_v4() -> String:
	var uuid = PackedByteArray()
	for i in range(16):
		uuid.append(randi() % 256)
	# Set the version to 4 (randomly generated UUID)
	uuid[6] = (uuid[6] & 0x0F) | 0x40
	# Set the variant to DCE 1.1, ITU-T X.667
	uuid[8] = (uuid[8] & 0x3F) | 0x80
	var str_uuid = ""
	for i in range(16):
		str_uuid += "%02x" % uuid[i]
		if i == 3 or i == 5 or i == 7 or i == 9:
			str_uuid += "-"
	return str_uuid

#endregion
