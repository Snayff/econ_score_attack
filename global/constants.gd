## class desc
#@icon("")
#class_name XXX
extends Node


#region CONSTANTS
## Enum for valid keys in the ReferenceRegistry.
enum ReferenceKey {
	SIM,
	PLAYER,
	DEMESNE,
	# Add more as needed
}

## Enum for main UI views.
## Used to identify the main view context for sub view selection and logic.
enum View {
	PEOPLE,
	ECONOMY,
	LAW,
	LAND
}

## Enum for sub views within each main view.
## Used to uniquely identify sub views for data-driven UI and logic.
enum SubView {
	PEOPLE_POPULATION,
	PEOPLE_DECISIONS,
	ECONOMY_METRICS,
	LAW_LAWBOOK,
	LAND_WORLD
}

## Mapping from JSON sub view keys to SubView enum values.
## Used for converting data-driven string keys to enum values for robust code.
const SUB_VIEW_KEY_TO_ENUM = {
	"population": SubView.PEOPLE_POPULATION,
	"decisions": SubView.PEOPLE_DECISIONS,
	"metrics": SubView.ECONOMY_METRICS,
	"lawbook": SubView.LAW_LAWBOOK,
	"world": SubView.LAND_WORLD
}

## Mapping from SubView enum values to JSON sub view keys.
## Used for converting enum values back to string keys for data or UI.
const SUB_VIEW_ENUM_TO_KEY = {
	SubView.PEOPLE_POPULATION: "population",
	SubView.PEOPLE_DECISIONS: "decisions",
	SubView.ECONOMY_METRICS: "metrics",
	SubView.LAW_LAWBOOK: "lawbook",
	SubView.LAND_WORLD: "world"
}

#endregion
