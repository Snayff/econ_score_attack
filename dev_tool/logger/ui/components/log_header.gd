## A component that displays statistics about the current log entries.
extends PanelContainer


#region SIGNALS


#endregion


#region CONSTANTS


#endregion


#region ON READY

func _ready() -> void:
	assert(%lbl_DebugCount != null, "Debug count label not found")
	assert(%lbl_InfoCount != null, "Info count label not found")
	assert(%lbl_WarningCount != null, "Warning count label not found")
	assert(%lbl_ErrorCount != null, "Error count label not found")
	assert(%lbl_TotalCount != null, "Total count label not found")

#endregion


#region EXPORTS


#endregion


#region PUBLIC FUNCTIONS

## Updates the statistics display with counts for each log level
func update_statistics(entries: Array[DataLogEntry]) -> void:
	var debug_count := 0
	var info_count := 0
	var warning_count := 0
	var error_count := 0
	
	for entry in entries:
		match entry.level:
			DataLogEntry.Level.DEBUG: debug_count += 1
			DataLogEntry.Level.INFO: info_count += 1
			DataLogEntry.Level.WARNING: warning_count += 1
			DataLogEntry.Level.ERROR: error_count += 1
	
	%lbl_DebugCount.text = str(debug_count)
	%lbl_InfoCount.text = str(info_count)
	%lbl_WarningCount.text = str(warning_count)
	%lbl_ErrorCount.text = str(error_count)
	%lbl_TotalCount.text = str(entries.size())
	
	# Update colours
	%lbl_DebugCount.modulate = DataLogEntry.LEVEL_COLOURS[DataLogEntry.Level.DEBUG]
	%lbl_InfoCount.modulate = DataLogEntry.LEVEL_COLOURS[DataLogEntry.Level.INFO]
	%lbl_WarningCount.modulate = DataLogEntry.LEVEL_COLOURS[DataLogEntry.Level.WARNING]
	%lbl_ErrorCount.modulate = DataLogEntry.LEVEL_COLOURS[DataLogEntry.Level.ERROR]

#endregion


#region PRIVATE FUNCTIONS


#endregion 