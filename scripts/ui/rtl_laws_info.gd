extends RichTextLabel

## Displays information about all possible laws in the demesne.
## Example:
## var laws_info = rtl_laws_info.new()


#region EXPORTS


#endregion


#region CONSTANTS


#endregion


#region SIGNALS


#endregion


#region ON READY

func _ready() -> void:
	bbcode_enabled = true
	fit_content = true
	update_info()


#endregion


#region PUBLIC FUNCTIONS

func update_info() -> void:
	_update_info()


#endregion


#region PRIVATE FUNCTIONS

func _update_info() -> void:
	# Temporary placeholder text until we implement actual laws system
	text = "[center][b]Available Laws[/b][/center]\n\n"
	text += "[b]Economic Laws[/b]\n"
	text += "• [u]Minimum Wage[/u]: Set a minimum wage for all workers\n"
	text += "• [u]Price Controls[/u]: Set maximum prices for goods\n\n"
	text += "[b]Social Laws[/b]\n"
	text += "• [u]Working Hours[/u]: Regulate maximum working hours\n"
	text += "• [u]Child Labour[/u]: Allow or prohibit child labour\n\n"
	text += "[b]Trade Laws[/b]\n"
	text += "• [u]Export Tariffs[/u]: Set tariffs on exported goods\n"
	text += "• [u]Import Restrictions[/u]: Control what goods can be imported"


#endregion 