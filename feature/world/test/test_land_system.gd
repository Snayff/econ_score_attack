## Unit tests for the land system
## Tests resource generation and discovery functionality
class_name TestLandSystem
extends ABCTest


var _demesne: Demesne
var _resource_generator: ResourceGenerator

func before_each() -> void:
	_demesne = Demesne.new("Test Demesne")
	_resource_generator = ResourceGenerator.new()

func after_each() -> void:
	_demesne = null
	_resource_generator = null

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
	assert_eq(
		parcel.resources.size(),
		0,
		"New parcel should have no resources"
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

func test_resource_initialization() -> void:
	var parcel = DataLandParcel.new(0, 0, "plains")
	_resource_generator.initialise_resources(parcel)

	var land_config = Library.get_config("land")
	var terrain_type = land_config.terrain_types[parcel.terrain_type]

	for resource_id in terrain_type.resource_modifiers:
		if terrain_type.resource_modifiers[resource_id] > 0:
			assert_eq(
				parcel.resources.has(resource_id),
				true,
				"Parcel should have resource: %s" % resource_id
			)
			assert_eq(
				parcel.resources[resource_id].discovered,
				false,
				"Resource should start undiscovered: %s" % resource_id
			)

func test_resource_discovery() -> void:
	var parcel = DataLandParcel.new(0, 0, "plains")
	_resource_generator.initialise_resources(parcel)

	# Force discovery of a specific resource
	parcel.add_resource("grain", 100.0, false)
	assert_eq(
		parcel.is_resource_discovered("grain"),
		false,
		"Resource should start undiscovered"
	)

	var discovered = parcel.discover_resource("grain")
	assert_eq(
		discovered,
		true,
		"Resource should be discovered successfully"
	)
	assert_eq(
		parcel.is_resource_discovered("grain"),
		true,
		"Resource should now be discovered"
	)

func test_resource_generation() -> void:
	var parcel = DataLandParcel.new(0, 0, "plains")
	parcel.add_resource("grain", 100.0, true)

	var initial_amount = parcel.get_resource_amount("grain")
	parcel.update_resources(1.0)  # Update for 1 second
	var new_amount = parcel.get_resource_amount("grain")

	assert_true(
		new_amount > initial_amount,
		"Resource amount should increase over time"
	)

func test_resource_surveying() -> void:
	var parcel = DataLandParcel.new(0, 0, "plains")
	_resource_generator.initialise_resources(parcel)

	assert_eq(
		parcel.is_surveyed,
		false,
		"Parcel should start unsurveyed"
	)

	var discovered_resources = _resource_generator.survey_parcel(parcel)

	assert_eq(
		parcel.is_surveyed,
		true,
		"Parcel should be surveyed after survey_parcel"
	)

	# Verify that any discovered resources are properly marked
	for resource_id in discovered_resources:
		assert_eq(
			parcel.is_resource_discovered(resource_id),
			true,
			"Discovered resource should be marked as discovered: %s" % resource_id
		)

func test_resource_generation_rates() -> void:
	var parcel = DataLandParcel.new(0, 0, "plains")
	parcel.add_resource("grain", 100.0, true)
	parcel.add_resource("wood", 100.0, true)

	var initial_grain = parcel.get_resource_amount("grain")
	var initial_wood = parcel.get_resource_amount("wood")

	parcel.update_resources(1.0)

	var grain_increase = parcel.get_resource_amount("grain") - initial_grain
	var wood_increase = parcel.get_resource_amount("wood") - initial_wood

	# Plains should generate grain faster than wood
	assert_true(
		grain_increase > wood_increase,
		"Plains should generate grain faster than wood"
	)

func test_pathfinding_integration() -> void:
	var start := Vector2i(0, 0)
	var end := Vector2i(1, 1)
	var path := _demesne.find_path(start, end)

	assert_true(
		path.size() > 0,
		"Should find a path between valid coordinates"
	)
	assert_eq(
		path[0],
		start,
		"Path should start at start position"
	)
	assert_eq(
		path[-1],
		end,
		"Path should end at end position"
	)

func test_movement_cost_calculation() -> void:
	var start := Vector2i(0, 0)
	var end := Vector2i(1, 0)
	var cost := _demesne.get_movement_cost(start, end)

	var land_config := Library.get_config("land")
	var expected_cost: float = land_config.terrain_types["plains"].movement_cost

	assert_eq(
		cost,
		expected_cost,
		"Movement cost should match terrain cost for plains"
	)

func test_pathfinding_with_road() -> void:
	var start := Vector2i(0, 0)
	var end := Vector2i(1, 0)

	# Add road improvement
	var parcel1: DataLandParcel = _demesne.get_parcel(0, 0)
	var parcel2: DataLandParcel = _demesne.get_parcel(1, 0)
	parcel1.improvements["road"] = 1
	parcel2.improvements["road"] = 1

	var cost := _demesne.get_movement_cost(start, end)
	var land_config := Library.get_config("land")
	var expected_cost: float = land_config.terrain_types["plains"].movement_cost * \
							  land_config.improvements.road.movement_cost_multiplier * \
							  land_config.improvements.road.movement_cost_multiplier

	assert_eq(
		cost,
		expected_cost,
		"Movement cost should be reduced by road improvements"
	)

func test_pathfinding_signals() -> void:
	var path_found_emitted := false
	var path_failed_emitted := false

	# Connect to signals
	_demesne.path_found.connect(
		func(start: Vector2i, end: Vector2i, path: Array[Vector2i]) -> void:
			path_found_emitted = true
	)
	_demesne.path_failed.connect(
		func(start: Vector2i, end: Vector2i, reason: String) -> void:
			path_failed_emitted = true
	)

	# Test valid path
	var start := Vector2i(0, 0)
	var end := Vector2i(1, 1)
	_demesne.find_path(start, end)

	assert_true(
		path_found_emitted,
		"Should emit path_found signal for valid path"
	)

	# Test invalid path
	start = Vector2i(-1, -1)
	_demesne.find_path(start, end)

	assert_true(
		path_failed_emitted,
		"Should emit path_failed signal for invalid path"
	)
