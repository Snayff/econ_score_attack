# SubViewPopulation

## Last Updated: 2025-06-25

## Table of Contents
- [Overview](#overview)
- [Class Hierarchy](#class-hierarchy)
- [Constants](#constants)
- [Properties](#properties)
- [Methods](#methods)
- [Usage Examples](#usage-examples)
- [See Also](#see-also)

## Overview
`SubViewPopulation` is a UI component that displays information about people in the simulation using the modular UI layout system. It shows a list of living people in the center panel and detailed information about a selected person in the right sidebar. This view is part of the standardized ABCView layout system.

## Class Hierarchy
- **Extends:** ABCSubView
- **Extended by:** None
- **Used by:** Main UI system

## Constants
| Name | Type | Description |
|------|------|-------------|
| SCENE_PERSON_DETAILS | PackedScene | Preloaded scene for person details entry |

## Properties
| Name | Type | Description |
|------|------|-------------|
| vbx_people_details | VBoxContainer | Container for person detail entries |
| demo_person_details_entry | PanelContainer | Template entry for person details |
| lbl_culture | Label | Label for displaying culture information |
| lbl_ancestry | Label | Label for displaying ancestry information |
| _people_list | Array[Person] | Array of Person instances being displayed |
| _person_entry_nodes | Array[PanelContainer] | Array of UI nodes for each person |
| _selected_index | int | Index of the currently selected person |
| _selected_person_id | String | ID of the currently selected person |

## Methods
### update_view() -> void
Updates the displayed information in the centre panel. Populates the centre panel with a list of living people and their details.

**Overrides:** ABCSubView.update_view()

### _create_person_details_entry(person: Person) -> PanelContainer
Creates a UI entry for a person's details.

**Parameters:**
- `person`: The person to create an entry for

**Returns:** The created panel container

### _on_person_entry_pressed(index: int) -> void
Handles when a person entry is pressed.

**Parameters:**
- `index`: The index of the pressed entry

### _select_person_by_index(index: int) -> void
Selects a person by their index in the people list. Updates visual feedback and the right sidebar.

**Parameters:**
- `index`: The index of the person to select

### _update_right_sidebar() -> void
Updates the right sidebar with the selected person's details.

## Usage Examples
```gdscript
# This view is typically instantiated by the UI system, not directly
# But here's how you might interact with it programmatically:

# Assuming we have a reference to the view
var population_view = get_node("MainUI/ViewContainer/SubViewPopulation")

# Refresh the view to update with latest data
population_view.refresh()

# The view handles selection internally through UI interaction
# But you could programmatically select a person by ID
population_view._selected_person_id = "person_123"
population_view.refresh()
```

## See Also
- [Person](./person.md)
- [DataPerson](./data_person.md)
- [SubViewDecisions](./sub_view_decisions.md)
- [DataSubView](../shared/data_sub_view.md)
- [UI System](../systems/ui_system.md)
