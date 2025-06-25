# SubViewCodex

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
The `SubViewCodex` class implements a law codex view using the standardized ABCView layout system. It displays information about available laws in the simulation and allows for enactment and repeal of laws. This view provides a comprehensive interface for managing the legal system within a demesne.

## Class Hierarchy
- **Extends:** ABCSubView
- **Extended by:** None
- **Used by:** ViewLaws

## Constants
| Name | Type | Description |
|------|------|-------------|
| SCENE_LAW_ENTRY | PackedScene | Preloaded scene for law entry UI elements |

## Properties
| Name | Type | Description |
|------|------|-------------|
| vbx_laws_container | VBoxContainer | Container for law entries |
| lbl_law_name | Label | Label for displaying the selected law's name |
| actions_container | HBoxContainer | Container for action buttons |
| parameters_container | VBoxContainer | Container for parameter controls |
| _laws_list | Array[DataLaw] | List of available laws |
| _law_entry_nodes | Array[PanelContainer] | List of UI nodes for laws |
| _selected_index | int | Index of the currently selected law |
| _selected_law_id | String | ID of the currently selected law |

## Methods
### update_view() -> void
Updates the displayed information in the centre panel.

**Description:** Populates the centre panel with a list of available laws and their details.

### _create_law_entry(law_data: DataLaw) -> PanelContainer
Creates a UI entry for a law's details.

**Parameters:**
- `law_data`: The law data to create an entry for

**Returns:** The created panel container

### _on_law_entry_pressed(index: int) -> void
Handles when a law entry is pressed.

**Parameters:**
- `index`: The index of the pressed entry

### _select_law_by_index(index: int) -> void
Selects a law by their index in the laws list.

**Parameters:**
- `index`: The index of the law to select

**Description:** Updates visual feedback and the right sidebar.

### _update_right_sidebar() -> void
Updates the right sidebar with the selected law's details.

### _on_enact_law_pressed() -> void
Handles enacting a law.

### _on_repeal_law_pressed() -> void
Handles repealing a law.

## Usage Examples
```gdscript
# This class is typically instantiated by the ViewLaws class
# and doesn't need to be manually created

# However, you can interact with it once it's available:

# Get a reference to the codex view
var codex_view = view_laws.get_sub_view("codex")

# Refresh the view to show the latest laws
codex_view.refresh()

# The view handles user interactions automatically:
# - Clicking on a law selects it and shows details
# - Clicking "Enact Law" enacts the selected law
# - Clicking "Repeal Law" repeals the selected law
```

## See Also
- [Law](../base/law.md)
- [DataLaw](../data_class/data_law.md)
- [LawRegistry](../base/law_registry.md)
- [ABCSubView](../../shared/ui/abc_sub_view.md)
