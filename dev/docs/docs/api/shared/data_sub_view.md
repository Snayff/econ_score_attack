# DataSubView

## Last Updated: 2025-06-25

## Table of Contents
- [Overview](#overview)
- [Class Hierarchy](#class-hierarchy)
- [Properties](#properties)
- [Methods](#methods)
- [Usage Examples](#usage-examples)
- [See Also](#see-also)

## Overview
`DataSubView` is a data class for sub view metadata used in the UI system. It stores information about sub views, including their identifiers, display labels, icons, tooltips, and scene paths. This class is used by the UI system to dynamically load and display different sub views within main view panels.

## Class Hierarchy
- **Extends:** RefCounted
- **Extended by:** None
- **Used by:** Library, UI system, ABCView, ABCSubView

## Properties
| Name | Type | Description |
|------|------|-------------|
| id | String | Unique identifier for the sub view |
| label | String | Display label for the sub view |
| icon | String | Path to the icon resource |
| tooltip | String | Tooltip text for the sub view button |
| scene_path | String | Path to the sub view scene |
| sub_view_key | int | SubView enum value for robust identification |

## Methods
### _init(id_: String, label_: String, icon_: String, tooltip_: String, scene_path_: String, sub_view_key_: int) -> void
Constructor for DataSubView.

**Parameters:**
- `id_`: Unique identifier for the sub view
- `label_`: Display label for the sub view
- `icon_`: Path to the icon resource
- `tooltip_`: Tooltip text for the sub view button
- `scene_path_`: Path to the sub view scene
- `sub_view_key_`: SubView enum value for robust identification

## Usage Examples
```gdscript
# Create a new sub view definition
var sub_view = DataSubView.new(
    "population", 
    "Population", 
    "res://shared/asset/icons/population.svg", 
    "View population details", 
    "res://feature/economic_actor/ui/sub_view/population/sub_view_population.tscn",
    Constants.SUB_VIEW_KEY.POPULATION
)

# Access sub view properties
print("Sub view ID: %s" % sub_view.id)
print("Sub view label: %s" % sub_view.label)
print("Sub view scene path: %s" % sub_view.scene_path)

# Use with Library to get sub views for a feature
var people_sub_views = Library.get_all_sub_views_data(Constants.VIEW_KEY.PEOPLE)
for sub_view in people_sub_views:
    print("Found sub view: %s (%s)" % [sub_view.label, sub_view.id])
```

## See Also
- [SubViewPopulation](../economic_actor/sub_view_population.md)
- [SubViewDecisions](../economic_actor/sub_view_decisions.md)
- [Library](./library.md)
- [UI System](../systems/ui_system.md)
