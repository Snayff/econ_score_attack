## A UI component for displaying a single log entry.
extends PanelContainer

const DataLogEntry := preload("res://scripts/ui/log_viewer/components/data_log_entry.gd")


#region SIGNALS


#endregion


#region CONSTANTS


#endregion


#region ON READY

func _ready() -> void:
	assert(%lbl_Timestamp != null, "Timestamp label not found")
	assert(%lbl_Level != null, "Level label not found")
	assert(%lbl_Source != null, "Source label not found")
	assert(%lbl_Message != null, "Message label not found")

#endregion


#region EXPORTS


#endregion


#region PUBLIC FUNCTIONS

## Updates the entry display with data from a LogEntry
func display_entry(entry: DataLogEntry) -> void:
	%lbl_Timestamp.text = entry.timestamp
	%lbl_Level.text = DataLogEntry.Level.keys()[entry.level]
	%lbl_Source.text = entry.source
	%lbl_Message.text = entry.message
	
	# Set colours based on log level
	%lbl_Level.modulate = entry.get_colour()
	%lbl_Message.modulate = entry.get_colour()

#endregion


#region PRIVATE FUNCTIONS


#endregion 