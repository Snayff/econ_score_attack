## Global event bus for UI-related signals
## Handles communication between unrelated UI components
extends Node


#region SIGNALS

## Instruction to toggle the turn timer display
@warning_ignore("unused_signal")
signal toggle_turn_timer

## Emitted when the land grid data is updated
@warning_ignore("unused_signal")
signal land_grid_updated(parcel_data: DataLandParcel)

## Emitted when visual feedback needs to be shown
@warning_ignore("unused_signal")
signal show_visual_feedback(message: String, position: Vector2)

## Emitted when a notification needs to be shown
@warning_ignore("unused_signal")
signal show_notification(message: String, type: String)

## Emitted when a tile survey is completed (for feedback/notification)
@warning_ignore("unused_signal")
signal survey_completed(x: int, y: int)

## Emitted when the sidebar "People" button is pressed
@warning_ignore("unused_signal")
signal sidebar_people_pressed

## Emitted when the sidebar "Laws" button is pressed
@warning_ignore("unused_signal")
signal sidebar_laws_pressed

## Emitted when the sidebar "Land" button is pressed
@warning_ignore("unused_signal")
signal sidebar_land_pressed

## Emitted when the sidebar "Economy" button is pressed
@warning_ignore("unused_signal")
signal sidebar_economy_pressed

#endregion


#region ON READY

#endregion


#region EXPORTS

#endregion


#region VARS

#endregion


#region FUNCS

#endregion
