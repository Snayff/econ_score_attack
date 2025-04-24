## A UI component for displaying a single log entry.
extends PanelContainer

const DataLogEntry := preload("res://scripts/ui/log_viewer/components/data_log_entry.gd")


#region SIGNALS


#endregion


#region CONSTANTS


#endregion


#region ON READY

func _ready() -> void:
	assert(%Timestamp != null, "Timestamp label not found")
	assert(%Level != null, "Level label not found")
	assert(%Source != null, "Source label not found")
	assert(%Message != null, "Message label not found")

#endregion


#region EXPORTS


#endregion


#region PUBLIC FUNCTIONS

## Updates the entry display with data from a LogEntry
func display_entry(entry: DataLogEntry) -> void:
	%Timestamp.text = entry.timestamp
	%Level.text = DataLogEntry.Level.keys()[entry.level]
	%Source.text = entry.source
	%Message.text = entry.message
	
	# Set colours based on log level
	%Level.modulate = entry.get_colour()
	%Message.modulate = entry.get_colour()

#endregion


#region PRIVATE FUNCTIONS


#endregion 