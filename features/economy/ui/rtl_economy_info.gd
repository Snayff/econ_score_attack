## Displays economic information and metrics about the demesne.
## Shows various economic indicators like price levels, trade volume, unemployment, etc.
## in a clear, organized panel with historical trends.
##
extends Control


#region EXPORTS

@export var sim: Sim

#endregion


#region CONSTANTS

const TREND_INDICATORS = {
	"positive": "↑",
	"negative": "↓",
	"neutral": "→"
}

const METRIC_LABELS = {
	"average_price_level": "Average Price Level",
	"trade_volume": "Trade Volume",
	"money_velocity": "Money Velocity",
	"unemployment_rate": "Unemployment Rate",
	"production_index": "Production Index",
	"wealth_gini": "Wealth Inequality (Gini)",
	"market_activity": "Market Activity"
}

const METRIC_DESCRIPTIONS = {
	"average_price_level": "The average price of goods in the market",
	"trade_volume": "Number of trades completed in the last period",
	"money_velocity": "Rate at which money changes hands",
	"unemployment_rate": "Percentage of people without jobs",
	"production_index": "Total production output",
	"wealth_gini": "Measure of wealth inequality (0-1)",
	"market_activity": "Number of unique market participants"
}

#endregion


#region SIGNALS


#endregion


#region ON READY

@onready var metrics_container: VBoxContainer = %MetricsContainer

func _ready() -> void:
	# Ensure we have our required nodes
	assert(metrics_container != null, "MetricsContainer node not found!")

	# Find the Sim node if not provided
	if not sim:
		sim = get_node("/root/Main/Sim")

	if sim:
		sim.sim_initialized.connect(_on_sim_initialized)
		EventBusGame.turn_complete.connect(update_info)

	update_info()

#endregion


#region PUBLIC FUNCTIONS

func update_info() -> void:
	_update_info()

#endregion


#region PRIVATE FUNCTIONS

func _on_sim_initialized() -> void:
	update_info()

func _update_info() -> void:
	# Safety check for our container
	if not metrics_container:
		push_error("MetricsContainer node not found!")
		return

	# Clear existing content
	for child in metrics_container.get_children():
		child.queue_free()

	if not sim:
		var label = Label.new()
		label.text = "No simulation data available"
		metrics_container.add_child(label)
		return

	if not sim._economic_metrics:
		var label = Label.new()
		label.text = "No economic metrics available"
		metrics_container.add_child(label)
		return

	# Get the economic report
	var report = sim._economic_metrics.generate_report()
	var current_metrics = report.get("current_metrics", {})
	var trends = report.get("historical_trends", {})
	var alerts = report.get("alerts", [])

	# Display alerts if any
	if not alerts.is_empty():
		var alerts_panel = _create_alerts_panel(alerts)
		metrics_container.add_child(alerts_panel)

	# Display metrics grouped by category
	var metrics_panel = _create_metrics_panel(current_metrics, trends)
	metrics_container.add_child(metrics_panel)

func _create_alerts_panel(alerts: Array) -> PanelContainer:
	var panel = PanelContainer.new()
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)

	var header = Label.new()
	header.text = "Economic Alerts"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 18)
	header.add_theme_color_override("font_color", Color(1, 0.5, 0.5))
	vbox.add_child(header)

	for alert in alerts:
		var alert_label = Label.new()
		alert_label.text = "⚠ %s: %.2f (Threshold: %.2f)" % [
			METRIC_LABELS[alert.metric],
			alert.current_value,
			alert.threshold
		]
		alert_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(alert_label)

	return panel

func _create_metrics_panel(metrics: Dictionary, trends: Dictionary) -> PanelContainer:
	var panel = PanelContainer.new()
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)

	# Add each metric with its value and trend
	for metric_id in METRIC_LABELS:
		if metrics.has(metric_id):
			var metric_container = HBoxContainer.new()
			metric_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			vbox.add_child(metric_container)

			# Metric name and description
			var info_container = VBoxContainer.new()
			info_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			metric_container.add_child(info_container)

			var name_label = Label.new()
			name_label.text = METRIC_LABELS[metric_id]
			name_label.add_theme_font_size_override("font_size", 16)
			info_container.add_child(name_label)

			var desc_label = Label.new()
			desc_label.text = METRIC_DESCRIPTIONS[metric_id]
			desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
			desc_label.add_theme_font_size_override("font_size", 12)
			info_container.add_child(desc_label)

			# Value and trend
			var value_container = HBoxContainer.new()
			value_container.size_flags_horizontal = Control.SIZE_SHRINK_END
			metric_container.add_child(value_container)

			var value_label = Label.new()
			value_label.text = "%.2f" % metrics[metric_id]
			value_label.add_theme_font_size_override("font_size", 16)
			value_container.add_child(value_label)

			if trends.has(metric_id):
				var trend = trends[metric_id]
				var trend_label = Label.new()

				# Determine trend direction and color
				var trend_color: Color
				var trend_indicator: String
				if trend.percent_change > 1:
					trend_color = Color(0.2, 0.8, 0.2)  # Green for positive
					trend_indicator = TREND_INDICATORS.positive
				elif trend.percent_change < -1:
					trend_color = Color(0.8, 0.2, 0.2)  # Red for negative
					trend_indicator = TREND_INDICATORS.negative
				else:
					trend_color = Color(0.7, 0.7, 0.7)  # Grey for neutral
					trend_indicator = TREND_INDICATORS.neutral

				trend_label.text = " %s %.1f%%" % [trend_indicator, trend.percent_change]
				trend_label.add_theme_color_override("font_color", trend_color)
				trend_label.add_theme_font_size_override("font_size", 16)
				value_container.add_child(trend_label)

			# Add separator
			var separator = HSeparator.new()
			separator.add_theme_constant_override("separation", 10)
			vbox.add_child(separator)

	return panel

#endregion
