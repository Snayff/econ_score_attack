## central repository for shared constants
extends Node


#region CONSTANTS
## Enum for valid keys in the ReferenceRegistry.
enum REFERENCE_KEY {
	SIM,
	PLAYER,
	DEMESNE,
}

## Enum for main UI views.
## Used to identify the main view context for sub view selection and logic.
enum VIEW_KEY {
	PEOPLE,
	ECONOMY,
	LAW,
	LAND
}

## Mapping from VIEW_KEY enum values to their string keys.
const VIEW_KEY_ENUM_TO_KEY = {
	VIEW_KEY.PEOPLE: "people",
	VIEW_KEY.ECONOMY: "economy",
	VIEW_KEY.LAW: "law",
	VIEW_KEY.LAND: "land"
}

## Enum for sub views within each main view.
## Used to uniquely identify sub views for data-driven UI and logic.
enum SUB_VIEW_KEY {
	PEOPLE_POPULATION,
	PEOPLE_DECISIONS,
	ECONOMY_METRICS,
	LAW_LAWBOOK,
	LAND_WORLD
}

## Mapping from JSON sub view keys to SUB_VIEW_KEY enum values.
## Used for converting data-driven string keys to enum values for robust code.
const SUB_VIEW_KEY_TO_ENUM = {
	"population": SUB_VIEW_KEY.PEOPLE_POPULATION,
	"decisions": SUB_VIEW_KEY.PEOPLE_DECISIONS,
	"metrics": SUB_VIEW_KEY.ECONOMY_METRICS,
	"lawbook": SUB_VIEW_KEY.LAW_LAWBOOK,
	"world": SUB_VIEW_KEY.LAND_WORLD
}

## Mapping from SUB_VIEW_KEY enum values to JSON sub view keys.
## Used for converting enum values back to string keys for data or UI.
const SUB_VIEW_ENUM_TO_KEY = {
	SUB_VIEW_KEY.PEOPLE_POPULATION: "population",
	SUB_VIEW_KEY.PEOPLE_DECISIONS: "decisions",
	SUB_VIEW_KEY.ECONOMY_METRICS: "metrics",
	SUB_VIEW_KEY.LAW_LAWBOOK: "lawbook",
	SUB_VIEW_KEY.LAND_WORLD: "world"
}

## prefixes to use with id generation
enum ID_PREFIX {
	ACT, ## actor
	BLD, ## building
	JOB, ## job
}

#endregion
