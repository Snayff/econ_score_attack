## SalesTax
## Implements a percentage-based tax on all goods transactions
## Tax revenue is collected by the demesne
class_name SalesTax
extends Law

const Law = preload("res://scripts/laws/law.gd")

#region VARS
## Minimum allowed tax rate
const MIN_TAX_RATE: float = 0.0

## Maximum allowed tax rate
const MAX_TAX_RATE: float = 100.0

## Parameter name for tax rate
const PARAM_TAX_RATE: String = "tax_rate"
#endregion

#region FUNCS
## Creates a new sales tax law instance
## @param name_: Human-readable name
## @param category_: Main category of the law
## @param subcategory_: Subcategory for more specific categorization
## @param tags_: Array of tags for searching and filtering
## @param description_: Detailed description
## @param parameters_: Initial parameter values
func _init(name_: String, category_: String, subcategory_: String, tags_: Array[String], description_: String, parameters_: Dictionary) -> void:
	super._init("sales_tax", name_, category_, subcategory_, tags_, description_, parameters_)

## Validates if tax rate is within acceptable bounds
## @return: bool indicating if parameters are valid
func validate_parameters() -> bool:
	if not parameters.has(PARAM_TAX_RATE):
		return false

	var rate: float = parameters[PARAM_TAX_RATE]
	return rate >= MIN_TAX_RATE and rate <= MAX_TAX_RATE

## Calculates tax amount for a transaction
## @param base_price: Original price before tax
## @return: Tax amount to add
func calculate_tax(base_price: int) -> int:
	if not active:
		return 0

	var tax_rate: float = get_parameter(PARAM_TAX_RATE)
	return int(ceil(base_price * tax_rate / 100.0))

## Calculates final price including tax
## @param base_price: Original price before tax
## @return: Final price with tax included
func calculate_final_price(base_price: int) -> int:
	return base_price + calculate_tax(base_price)
#endregion
