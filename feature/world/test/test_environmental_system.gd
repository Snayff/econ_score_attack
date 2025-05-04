extends ABCTest

#region CONSTANTS


#endregion


#region EXPORTS


#endregion


#region PUBLIC VARIABLES


#endregion


#region PRIVATE VARIABLES

var _env_system: EnvironmentalSystem
var _test_grid: Array[Array]

#endregion


#region ON READY

func before_each() -> void:
	_env_system = EnvironmentalSystem.new()
	add_child(_env_system)

	# Create a 5x5 test grid
	_test_grid = []
	for y in range(5):
		var row: Array[DataLandParcel] = []
		for x in range(5):
			var parcel: DataLandParcel = DataLandParcel.new(x, y, "plains")
			row.append(parcel)
		_test_grid.append(row)

	_env_system.initialize(_test_grid)

func after_each() -> void:
	if _env_system != null:
		_env_system.queue_free()

#endregion


#region PUBLIC FUNCTIONS

func test_season_change() -> void:
	var initial_season := _env_system.current_season

	_env_system.update_season(EnvironmentalSystem.Season.WINTER)
	assert_eq(_env_system.current_season, EnvironmentalSystem.Season.WINTER)
	assert_true(_env_system.current_season != initial_season)

	# Check resource modifiers
	var modifier: float = _env_system.get_resource_modifier(Vector2i(2, 2))
	assert_eq(modifier, 0.5)  # Winter modifier

func test_disaster_application() -> void:
	var origin := Vector2i(2, 2)
	var initial_pollution: float = _test_grid[2][2].pollution_level

	_env_system.apply_disaster(EnvironmentalSystem.DisasterType.FLOOD, origin)

	# Check pollution levels
	var center_parcel: DataLandParcel = _test_grid[2][2]
	assert_gt(center_parcel.pollution_level, initial_pollution)

func test_pollution_spread() -> void:
	# Set initial pollution
	var center_parcel: DataLandParcel = _test_grid[2][2]
	center_parcel.pollution_level = 1.0

	var initial_levels := {
		"north": _test_grid[1][2].pollution_level,
		"east": _test_grid[2][3].pollution_level,
		"south": _test_grid[3][2].pollution_level,
		"west": _test_grid[2][1].pollution_level
	}

	_env_system.update_pollution()

	# Check neighbours received pollution
	assert_gt(_test_grid[1][2].pollution_level, initial_levels.north)
	assert_gt(_test_grid[2][3].pollution_level, initial_levels.east)
	assert_gt(_test_grid[3][2].pollution_level, initial_levels.south)
	assert_gt(_test_grid[2][1].pollution_level, initial_levels.west)

func test_effect_duration() -> void:
	# Add a temporary effect
	var effect := DataEnvironmentalEffect.new()
	effect.effect_id = "test_effect"
	effect.duration = 2.0
	_env_system.active_effects[effect.effect_id] = effect

	# Update twice
	_env_system.update_effects(1.0)
	assert_true(_env_system.active_effects.has("test_effect"))

	_env_system.update_effects(1.0)
	assert_true(not _env_system.active_effects.has("test_effect"))

#endregion


#region PRIVATE FUNCTIONS


#endregion
