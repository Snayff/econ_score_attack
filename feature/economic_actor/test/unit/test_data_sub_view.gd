## Unit test for Library.get_all_sub_views_data('people')
## Last Updated: 2025-05-24
extends Object

func test_get_all_sub_views_data_people() -> void:
	var sub_views = Library.get_all_sub_views_data("people")
	assert(sub_views.size() == 2, "Should load 2 sub views for people")

	var first = sub_views[0]
	assert(first.id == "population", "First sub view id should be 'population'")
	assert(first.label == "Population", "First sub view label should be 'Population'")
	assert(first.icon == "res://shared/asset/icons/population.svg", "First sub view icon should match")
	assert(first.tooltip == "View population details", "First sub view tooltip should match")
	assert(first.scene_path == "res://feature/economic_actor/people/ui/sub_view_population.tscn", "First sub view scene_path should match")

	var second = sub_views[1]
	assert(second.id == "decisions", "Second sub view id should be 'decisions'")
	assert(second.label == "Decisions", "Second sub view label should be 'Decisions'")
	assert(second.icon == "res://shared/asset/icons/decisions.svg", "Second sub view icon should match")
	assert(second.tooltip == "Make decisions", "Second sub view tooltip should match")
	assert(second.scene_path == "res://feature/economic_actor/people/ui/sub_view_decisions.tscn", "Second sub view scene_path should match")

	# Check all IDs are unique and snake_case
	var ids = [first.id, second.id]
	assert(ids.size() == ids.duplicate().size(), "Sub view IDs should be unique")
	for id in ids:
		assert(id == id.to_snake_case(), "Sub view ID '%s' should be snake_case" % id) 