## Base class for all test classes in the project.
## Provides common testing functionality and assertions.
##
## Example usage:
## ```gdscript
## class_name TestMyFeature
## extends ABCTest
##
## func test_my_feature():
##     assert_eq(2 + 2, 4, "Basic math should work")
## ```
class_name ABCTest
extends Node

signal test_completed(test_name: String, result: Dictionary)


#region CONSTANTS


#endregion


#region SIGNALS


#endregion


#region ON READY

func _init() -> void:
    pass


#endregion


#region EXPORTS


#endregion


#region PUBLIC FUNCTIONS

func before_each() -> void:
    pass


func after_each() -> void:
    pass


func assert_eq(actual: Variant, expected: Variant, message: String = "") -> void:
    if actual != expected:
        _fail("Expected %s but got %s. %s" % [str(expected), str(actual), message])
    else:
        _pass()


func assert_true(condition: bool, message: String = "") -> void:
    if not condition:
        _fail("Assertion failed. %s" % message)
    else:
        _pass()


#endregion


#region PRIVATE FUNCTIONS

func _fail(message: String) -> void:
    var result = {
        "status": "failed",
        "message": message,
        "details": {
            "stack_trace": get_stack()
        }
    }
    emit_signal("test_completed", _get_test_name(), result)


func _pass() -> void:
    var result = {
        "status": "passed"
    }
    emit_signal("test_completed", _get_test_name(), result)


func _get_test_name() -> String:
    # Get the current test method name from the stack
    for stack_item in get_stack():
        var method_name = stack_item.get("function", "")
        if method_name.begins_with("test_"):
            return method_name
    return "unknown_test"


#endregion 