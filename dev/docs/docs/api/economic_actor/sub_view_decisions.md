# SubViewDecisions

## Last Updated: 2025-06-25

## Table of Contents
- [Overview](#overview)
- [Class Hierarchy](#class-hierarchy)
- [Properties](#properties)
- [Methods](#methods)
- [Usage Examples](#usage-examples)
- [See Also](#see-also)

## Overview
`SubViewDecisions` is a UI component that displays all decisions made by people in the last turn. It shows a list of decision outputs in the center panel, and when a decision is selected, it displays detailed information about that decision in the right sidebar. This view is part of the standardized ABCView layout system.

## Class Hierarchy
- **Extends:** ABCSubView
- **Extended by:** None
- **Used by:** Main UI system

## Properties
| Name | Type | Description |
|------|------|-------------|
| lbl_person | Label | Label for displaying the person's name |
| lbl_decision | Label | Label for displaying the decision action |
| lbl_rationale | Label | Label for displaying the decision rationale |
| lbl_input | Label | Label for displaying the decision inputs |
| lbl_alternatives | Label | Label for displaying alternative decisions |
| _decision_list | Array | Array of decision data being displayed |
| _decision_entry_nodes | Array[Button] | Array of UI buttons for each decision |
| _selected_index | int | Index of the currently selected decision |

## Methods
### update_view() -> void
Updates the displayed information in the centre panel. Populates the centre panel with a list of decisions made in the last turn.

**Overrides:** ABCSubView.update_view()

### _on_decision_entry_pressed(index: int) -> void
Handles when a decision entry button is pressed.

**Parameters:**
- `index`: The index of the pressed entry

### _select_decision_by_index(index: int) -> void
Selects a decision by its index in the decision list. Updates visual feedback and the right sidebar.

**Parameters:**
- `index`: The index of the decision to select

### _update_right_sidebar() -> void
Updates the right sidebar with the selected decision's details.

## Usage Examples
```gdscript
# This view is typically instantiated by the UI system, not directly
# But here's how you might interact with it programmatically:

# Assuming we have a reference to the view
var decisions_view = get_node("MainUI/ViewContainer/SubViewDecisions")

# Refresh the view to update with latest decision data
decisions_view.refresh()

# The view handles selection internally through UI interaction
# But you could programmatically select a decision by index
decisions_view._select_decision_by_index(0)  # Select the first decision
```

## See Also
- [Person](./person.md)
- [SubViewPopulation](./sub_view_population.md)
- [DataSubView](../shared/data_sub_view.md)
- [Economic Actor Decision System](../systems/economic_actor_decision_system.md)
- [UI System](../systems/ui_system.md)
