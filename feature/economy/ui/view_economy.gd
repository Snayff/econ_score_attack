## ViewEconomy: Economy view using the standardised ABCView layout system.
## Displays economic metrics and trends for the demesne.
## Usage:
##  Inherit from ABCView. Implements update_view() to populate the centre panel with economic metrics and trends.
##  All user actions in sidebars and top bar should emit the standard signals (left_action_selected, top_tab_selected, right_info_requested) where appropriate.
##  Error and empty state handling is managed by the base class.
##  Uses UIFactory (global autoload) for standard UI element creation.
##
## See: dev/docs/docs/systems/ui_layout.md
## Last Updated: 2025-05-25
extends ABCView

#region VARS
var _sim: Sim = null
#endregion

#region PUBLIC FUNCTIONS
func update_view() -> void:
	var vbox := VBoxContainer.new()
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL

	if not _sim or not _sim._economic_metrics:
		var label := Label.new()
		label.text = "No simulation data available"
		vbox.add_child(label)
		set_centre_content([vbox])
		set_left_sidebar_content([])
		set_right_sidebar_content([])
		set_top_bar_content([])
		return

	var report: Dictionary = _sim._economic_metrics.generate_report()
	var current_metrics: Dictionary = report.get("current_metrics", {})
	var trends: Dictionary = report.get("historical_trends", {})
	var alerts: Array = report.get("alerts", [])

	if not alerts.is_empty():
		var alerts_panel := _create_alerts_panel(alerts)
		vbox.add_child(alerts_panel)

	var metrics_panel := _create_metrics_panel(current_metrics, trends)
	vbox.add_child(metrics_panel)

	set_centre_content([vbox])
	set_left_sidebar_content([])
	set_right_sidebar_content([])
	set_top_bar_content([])
#endregion

#region PRIVATE FUNCTIONS
func _ready() -> void:
	ReferenceRegistry.reference_registered.connect(_on_reference_registered)
	EventBusGame.turn_complete.connect(update_view)
	var sim_ref = ReferenceRegistry.get_reference(Constants.ReferenceKey.SIM)
	if sim_ref:
		_set_sim(sim_ref)
	update_view()

func _on_reference_registered(key: int, value: Object) -> void:
	if key == Constants.ReferenceKey.SIM:
		_set_sim(value)

func _set_sim(sim_ref: Sim) -> void:
	_sim = sim_ref
	update_view()

const TREND_INDICATORS := {
	"positive": "↑",
	"negative": "↓",
	"neutral": "→"
}

const METRIC_LABELS := {
	"average_price_level": "Average Price Level",
	"trade_volume": "Trade Volume",
	"money_velocity": "Money Velocity",
	"unemployment_rate": "Unemployment Rate",
	"production_index": "Production Index",
	"wealth_gini": "Wealth Inequality (Gini)",
	"market_activity": "Market Activity"
}

const METRIC_DESCRIPTIONS := {
	"average_price_level": "The average price of goods in the market",
	"trade_volume": "Number of trades completed in the last period",
	"money_velocity": "Rate at which money changes hands",
	"unemployment_rate": "Percentage of people without jobs",
	"production_index": "Total production output",
	"wealth_gini": "Measure of wealth inequality (0-1)",
	"market_activity": "Number of unique market participants"
}

func _create_alerts_panel(alerts: Array) -> PanelContainer:
	var panel := PanelContainer.new()
	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	var header := Label.new()
	header.text = "Economic Alerts"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 18)
	header.add_theme_color_override("font_color", Color(1, 0.5, 0.5))
	vbox.add_child(header)

	for alert in alerts:
		var alert_label := Label.new()
		alert_label.text = "⚠ %s: %.2f (Threshold: %.2f)" % [
			METRIC_LABELS[alert.metric],
			alert.current_value,
			alert.threshold
		]
		alert_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(alert_label)

	return panel

func _create_metrics_panel(metrics: Dictionary, trends: Dictionary) -> PanelContainer:
	var panel := PanelContainer.new()
	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	for metric_id in METRIC_LABELS:
		if metrics.has(metric_id):
			var metric_container := HBoxContainer.new()
			metric_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			vbox.add_child(metric_container)

			var info_container := VBoxContainer.new()
			info_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			metric_container.add_child(info_container)

			var name_label := Label.new()
			name_label.text = METRIC_LABELS[metric_id]
			name_label.add_theme_font_size_override("font_size", 16)
			info_container.add_child(name_label)

			var desc_label := Label.new()
			desc_label.text = METRIC_DESCRIPTIONS[metric_id]
			desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
			desc_label.add_theme_font_size_override("font_size", 12)
			info_container.add_child(desc_label)

			var value_container := HBoxContainer.new()
			value_container.size_flags_horizontal = Control.SIZE_SHRINK_END
			metric_container.add_child(value_container)

			var value_label := Label.new()
			value_label.text = "%.2f" % metrics[metric_id]
			value_label.add_theme_font_size_override("font_size", 16)
			value_container.add_child(value_label)

			if trends.has(metric_id):
				var trend = trends[metric_id]
				var trend_label := Label.new()
				var trend_color: Color
				var trend_indicator: String
				if trend.percent_change > 1:
					trend_color = Color(0.2, 0.8, 0.2)
					trend_indicator = TREND_INDICATORS.positive
				elif trend.percent_change < -1:
					trend_color = Color(0.8, 0.2, 0.2)
					trend_indicator = TREND_INDICATORS.negative
				else:
					trend_color = Color(0.7, 0.7, 0.7)
					trend_indicator = TREND_INDICATORS.neutral
				trend_label.text = " %s %.1f%%" % [trend_indicator, trend.percent_change]
				trend_label.add_theme_color_override("font_color", trend_color)
				trend_label.add_theme_font_size_override("font_size", 16)
				value_container.add_child(trend_label)

			var separator := HSeparator.new()
			separator.add_theme_constant_override("separation", 10)
			vbox.add_child(separator)

	return panel
#endregion
