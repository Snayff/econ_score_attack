## Tracks and reports on economic metrics
## Provides real-time monitoring of economic indicators and historical trends
## Example usage:
## ```gdscript
## var metrics = EconomicMetrics.new()
## metrics.metric_updated.connect(_on_metric_updated)
## metrics.update_metrics(sim_state)
## var report = metrics.generate_report()
## ```
class_name EconomicMetrics
extends Node


#region SIGNALS

## Emitted when a metric is updated
signal metric_updated(metric_name: String, new_value: float)

## Emitted when a metric crosses its defined threshold
signal threshold_crossed(metric_name: String, threshold: float, current_value: float)

#endregion


#region VARS

## Current metric values
var _metrics: Dictionary = {
	"average_price_level": 0.0,
	"trade_volume": 0.0,
	"money_velocity": 0.0,
	"unemployment_rate": 0.0,
	"production_index": 0.0,
	"wealth_gini": 0.0,
	"market_activity": 0.0
}

## Historical metric values
var _metric_history: Dictionary = {}

## Alert thresholds for metrics
var _metric_thresholds: Dictionary = {
	"unemployment_rate": 0.2,  # Alert if unemployment > 20%
	"trade_volume": 10.0,     # Alert if trade volume < 10
	"market_activity": 5.0    # Alert if market activity < 5
}

## Maximum periods to keep in history
const MAX_HISTORY_PERIODS: int = 100

## Base period for calculating rates (e.g., money velocity)
const BASE_PERIOD: int = 10

#endregion


#region PUBLIC_METHODS

## Updates metrics based on new economic data
## @param sim_state Dictionary containing current simulation state
func update_metrics(sim_state: Dictionary) -> void:
	Logger.log_event("metrics_update_started", {
		"timestamp": Time.get_unix_time_from_system(),
		"current_metrics": _metrics.duplicate()
	}, "EconomicMetrics")
	
	_update_price_level(sim_state)
	_update_trade_volume(sim_state)
	_update_money_velocity(sim_state)
	_update_unemployment(sim_state)
	_update_production_index(sim_state)
	_update_wealth_distribution(sim_state)
	_update_market_activity(sim_state)
	
	_check_thresholds()
	_record_history()
	
	Logger.log_event("metrics_update_completed", {
		"timestamp": Time.get_unix_time_from_system(),
		"updated_metrics": _metrics.duplicate()
	}, "EconomicMetrics")

## Gets a specific metric value
## @param metric_name Name of the metric to retrieve
## @return Current value of the metric
func get_metric(metric_name: String) -> float:
	return _metrics.get(metric_name, 0.0)

## Gets historical values for a metric
## @param metric_name Name of the metric to retrieve history for
## @param periods Number of historical periods to retrieve
## @return Array of historical values
func get_metric_history(metric_name: String, periods: int = 10) -> Array:
	if not _metric_history.has(metric_name):
		return []
	
	var history = _metric_history[metric_name]
	var start_idx = max(0, history.size() - periods)
	return history.slice(start_idx)

## Generates a comprehensive economic report
## @return Dictionary containing current metrics, trends, and alerts
func generate_report() -> Dictionary:
	var report = {
		"current_metrics": _metrics.duplicate(),
		"historical_trends": _calculate_trends(),
		"alerts": _generate_alerts(),
		"timestamp": Time.get_unix_time_from_system()
	}
	
	Logger.log_event("economic_report_generated", report, "EconomicMetrics")
	return report

## Sets a threshold for a metric
## @param metric_name Name of the metric
## @param threshold New threshold value
func set_threshold(metric_name: String, threshold: float) -> void:
	_metric_thresholds[metric_name] = threshold
	Logger.log_event("metric_threshold_set", {
		"metric": metric_name,
		"threshold": threshold,
		"timestamp": Time.get_unix_time_from_system()
	}, "EconomicMetrics")

#endregion


#region PRIVATE_METHODS

## Updates the average price level
func _update_price_level(sim_state: Dictionary) -> void:
	var prices = sim_state.get("market_prices", {})
	if prices.is_empty():
		return
		
	var total_price = 0.0
	for good in prices:
		total_price += prices[good]
	
	var new_price_level = total_price / prices.size()
	_update_metric("average_price_level", new_price_level)

## Updates the trade volume
func _update_trade_volume(sim_state: Dictionary) -> void:
	var transactions = sim_state.get("transactions", [])
	var volume = transactions.size()
	_update_metric("trade_volume", float(volume))

## Updates the money velocity (transactions per period)
func _update_money_velocity(sim_state: Dictionary) -> void:
	var transactions = sim_state.get("transactions", [])
	var total_value = 0.0
	for transaction in transactions:
		total_value += transaction.get("price", 0.0) * transaction.get("amount", 0)
	
	var money_supply = sim_state.get("total_money", 0.0)
	var velocity = 0.0
	if money_supply > 0:
		velocity = total_value / money_supply
	_update_metric("money_velocity", velocity)

## Updates the unemployment rate
func _update_unemployment(sim_state: Dictionary) -> void:
	var people = sim_state.get("people", [])
	if people.is_empty():
		return
		
	var unemployed = 0
	for person in people:
		if person.job == "none" or person.job.is_empty():
			unemployed += 1
	
	var rate = float(unemployed) / float(people.size())
	_update_metric("unemployment_rate", rate)

## Updates the production index
func _update_production_index(sim_state: Dictionary) -> void:
	var production = sim_state.get("production", {})
	if production.is_empty():
		return
		
	var total_production = 0
	for good in production:
		total_production += production[good]
	
	_update_metric("production_index", float(total_production))

## Updates wealth distribution metrics (Gini coefficient)
func _update_wealth_distribution(sim_state: Dictionary) -> void:
	var people = sim_state.get("people", [])
	if people.size() < 2:
		return
		
	var wealth_values = []
	for person in people:
		wealth_values.append(person.stockpile.get("money", 0))
	
	var gini = _calculate_gini_coefficient(wealth_values)
	_update_metric("wealth_gini", gini)

## Updates market activity metric
func _update_market_activity(sim_state: Dictionary) -> void:
	var transactions = sim_state.get("transactions", [])
	var unique_participants = {}
	
	for transaction in transactions:
		unique_participants[transaction.get("buyer", "")] = true
		unique_participants[transaction.get("seller", "")] = true
	
	var activity = unique_participants.size()
	_update_metric("market_activity", float(activity))

## Updates a specific metric and emits signal
func _update_metric(metric_name: String, value: float) -> void:
	var old_value = _metrics.get(metric_name, 0.0)
	_metrics[metric_name] = value
	emit_signal("metric_updated", metric_name, value)
	
	Logger.log_event("metric_updated", {
		"metric": metric_name,
		"old_value": old_value,
		"new_value": value,
		"change": value - old_value,
		"timestamp": Time.get_unix_time_from_system()
	}, "EconomicMetrics")

## Checks if any metrics have crossed their thresholds
func _check_thresholds() -> void:
	for metric in _metric_thresholds:
		if _metrics.has(metric):
			var current_value = _metrics[metric]
			var threshold = _metric_thresholds[metric]
			
			if current_value > threshold:
				emit_signal("threshold_crossed", metric, threshold, current_value)
				Logger.log_event("metric_threshold_crossed", {
					"metric": metric,
					"threshold": threshold,
					"current_value": current_value,
					"timestamp": Time.get_unix_time_from_system()
				}, "EconomicMetrics")

## Records current metrics in history
func _record_history() -> void:
	for metric_name in _metrics:
		if not _metric_history.has(metric_name):
			_metric_history[metric_name] = []
			
		_metric_history[metric_name].append(_metrics[metric_name])
		
		# Keep history size manageable
		if _metric_history[metric_name].size() > MAX_HISTORY_PERIODS:
			_metric_history[metric_name].pop_front()

## Calculates trends for all metrics
func _calculate_trends() -> Dictionary:
	var trends = {}
	for metric in _metric_history:
		var history = _metric_history[metric]
		if history.size() >= 2:
			var current = history[-1]
			var previous = history[-2]
			var percent_change = 0.0
			if previous != 0:
				percent_change = (current - previous) / previous * 100
			trends[metric] = {
				"change": current - previous,
				"percent_change": percent_change
			}
	return trends

## Generates alerts based on current metrics
func _generate_alerts() -> Array:
	var alerts = []
	for metric in _metric_thresholds:
		if _metrics.has(metric):
			var current_value = _metrics[metric]
			var threshold = _metric_thresholds[metric]
			if current_value > threshold:
				alerts.append({
					"metric": metric,
					"current_value": current_value,
					"threshold": threshold,
					"timestamp": Time.get_unix_time_from_system()
				})
	return alerts

## Calculates the Gini coefficient for wealth distribution
func _calculate_gini_coefficient(values: Array) -> float:
	if values.is_empty():
		return 0.0
		
	values.sort()
	var n = values.size()
	var sum_numerator = 0.0
	var sum_denominator = 0.0
	
	for i in range(n):
		sum_numerator += (n - i) * values[i]
		sum_denominator += values[i]
	
	if sum_denominator == 0:
		return 0.0
		
	var gini = (2.0 * sum_numerator) / (n * sum_denominator) - (n + 1.0) / n
	return max(0.0, min(1.0, gini))

#endregion 