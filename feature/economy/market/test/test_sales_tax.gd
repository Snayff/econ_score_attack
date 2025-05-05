## Unit tests for the SalesTax law
class_name TestSalesTax
extends ABCTest


var _sales_tax: SalesTax

func before_each() -> void:
    _sales_tax = SalesTax.new(
        "Test Tax", # name_
        "Taxation", # category_
        "General", # subcategory_
        ["test"], # tags_
        "A test tax", # description_
        {"tax_rate": 10.0} # parameters_
    )
    _sales_tax.activate()

func after_each() -> void:
    _sales_tax = null

func test_calculate_tax() -> void:
    var tax_amount = _sales_tax.calculate_tax(100)
    assert_eq(tax_amount, 10, "Tax should be 10% of base price")

func test_calculate_final_price() -> void:
    var final_price = _sales_tax.calculate_final_price(100)
    assert_eq(final_price, 110, "Final price should include 10% tax")

func test_inactive_tax() -> void:
    _sales_tax.deactivate()
    var tax_amount = _sales_tax.calculate_tax(100)
    assert_eq(tax_amount, 0, "Inactive tax should not apply")

func test_validate_parameters_valid() -> void:
    assert_true(_sales_tax.validate_parameters(), "Default tax rate should be valid")

func test_validate_parameters_invalid_high() -> void:
    _sales_tax.parameters["tax_rate"] = 150.0
    assert_true(!_sales_tax.validate_parameters(), "Tax rate > 100 should be invalid")

func test_validate_parameters_invalid_low() -> void:
    _sales_tax.parameters["tax_rate"] = -10.0
    assert_true(!_sales_tax.validate_parameters(), "Negative tax rate should be invalid") 