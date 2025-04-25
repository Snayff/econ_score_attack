## Unit tests for the land system
class_name TestLandSystem
extends ABCTest

const DataLandParcel = preload("res://scripts/data/data_land_parcel.gd")
const Demesne = preload("res://scripts/actors/demesne.gd")

var _demesne: Demesne

func before_each() -> void:
	_demesne = Demesne.new("Test Demesne")

func after_each() -> void:
	_demesne = null

func test_land_parcel_creation() -> void:
	var parcel = DataLandParcel.new(5, 3, "plains")
	
	assert_eq(
		parcel.x,
		5,
		"Parcel should have correct x coordinate"
	)
	assert_eq(
		parcel.y,
		3,
		"Parcel should have correct y coordinate"
	)
	assert_eq(
		parcel.terrain_type,
		"plains",
		"Parcel should have correct terrain type"
	)
	assert_eq(
		parcel.building_id,
		"",
		"New parcel should have no building"
	)
	assert_eq(
		parcel.improvements.size(),
		0,
		"New parcel should have no improvements"
	)
	assert_eq(
		parcel.fertility,
		1.0,
		"New parcel should have default fertility"
	)
	assert_eq(
		parcel.pollution_level,
		0.0,
		"New parcel should have no pollution"
	)
	assert_eq(
		parcel.is_surveyed,
		false,
		"New parcel should not be surveyed"
	)

func test_demesne_grid_initialization() -> void:
	var dimensions = _demesne.get_grid_dimensions()
	var land_config = Library.get_config("land")
	var default_size = land_config.get("grid", {}).get("default_size", {"width": 10, "height": 10})
	
	assert_eq(
		dimensions.x,
		default_size.width,
		"Grid should have correct default width"
	)
	assert_eq(
		dimensions.y,
		default_size.height,
		"Grid should have correct default height"
	)

func test_parcel_access() -> void:
	var dimensions = _demesne.get_grid_dimensions()
	
	# Test valid coordinates
	var parcel = _demesne.get_parcel(0, 0)
	assert_eq(
		parcel != null,
		true,
		"Should get parcel at valid coordinates"
	)
	
	# Test invalid coordinates
	parcel = _demesne.get_parcel(-1, 0)
	assert_eq(
		parcel,
		null,
		"Should return null for invalid x coordinate"
	)
	
	parcel = _demesne.get_parcel(0, dimensions.y + 1)
	assert_eq(
		parcel,
		null,
		"Should return null for invalid y coordinate"
	)

func test_parcel_modification() -> void:
	var original_parcel = _demesne.get_parcel(1, 1)
	var new_parcel = DataLandParcel.new(1, 1, "forest")
	
	assert_eq(
		_demesne.set_parcel(1, 1, new_parcel),
		true,
		"Should successfully set parcel at valid coordinates"
	)
	
	var retrieved_parcel = _demesne.get_parcel(1, 1)
	assert_eq(
		retrieved_parcel.terrain_type,
		"forest",
		"Retrieved parcel should have updated terrain type"
	)
	
	# Test setting parcel with mismatched coordinates
	var mismatched_parcel = DataLandParcel.new(2, 2, "mountains")
	assert_eq(
		_demesne.set_parcel(1, 1, mismatched_parcel),
		false,
		"Should fail to set parcel with mismatched coordinates"
	)

func test_parcel_properties() -> void:
	var parcel = _demesne.get_parcel(0, 0)
	var properties = parcel.get_properties()
	
	assert_eq(
		properties.has("x"),
		true,
		"Properties should include x coordinate"
	)
	assert_eq(
		properties.has("y"),
		true,
		"Properties should include y coordinate"
	)
	assert_eq(
		properties.has("terrain_type"),
		true,
		"Properties should include terrain type"
	)
	assert_eq(
		properties.has("building_id"),
		true,
		"Properties should include building ID"
	)
	assert_eq(
		properties.has("improvements"),
		true,
		"Properties should include improvements"
	)
	assert_eq(
		properties.has("fertility"),
		true,
		"Properties should include fertility"
	)
	assert_eq(
		properties.has("pollution_level"),
		true,
		"Properties should include pollution level"
	)
	assert_eq(
		properties.has("is_surveyed"),
		true,
		"Properties should include survey status"
	) 