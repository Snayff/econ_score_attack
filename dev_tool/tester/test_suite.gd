class_name TestSuite
extends Node

#region VARS
## Configuration for the test runner
var _config: Dictionary = {}

## Statistics for test runs
var _stats: Dictionary = {
    "total": 0,
    "passed": 0,
    "failed": 0,
    "skipped": 0,
    "categories": {},
    "start_time": "",
    "end_time": ""
}

## Current test run timestamp
var _timestamp: String = ""

## Output file handle
var _output_file: FileAccess = null
#endregion


#region FUNCS
func _init() -> void:
    _load_config()
    _setup_output_directory()
    _timestamp = Time.get_datetime_string_from_system().split(" ")[0]  # Gets YYYY-MM-DD
    _stats.start_time = Time.get_datetime_string_from_system()

func _load_config() -> void:
    var config_path = "res://dev_tool/tester/test_runner.json"
    if not FileAccess.file_exists(config_path):
        push_error("Test runner configuration not found at: " + config_path)
        return
        
    var config_file = FileAccess.open(config_path, FileAccess.READ)
    var json = JSON.new()
    var parse_result = json.parse(config_file.get_as_text())
    
    if parse_result == OK:
        _config = json.get_data()
    else:
        push_error("Failed to parse test configuration: " + json.get_error_message())

func _setup_output_directory() -> void:
    var dir = DirAccess.open("res://")
    var output_dir = _config.get("output_directory", "dev/test_results/")
    
    if not dir.dir_exists(output_dir):
        dir.make_dir_recursive(output_dir)

func run_all_tests() -> void:
    _log_header("Starting Test Run")
    
    for category in _config.get("categories", {}).keys():
        var category_config = _config.categories[category]
        if category_config.get("enabled", false):
            run_category(category)
    
    _write_results()
    _log_footer()

func run_category(category: String) -> void:
    _log_section("Running %s Tests" % category.capitalize())
    
    var category_config = _config.categories[category]
    _stats.categories[category] = {
        "total": 0,
        "passed": 0,
        "failed": 0,
        "skipped": 0,
        "executions": []
    }
    
    for test_path in category_config.get("test_paths", []):
        _run_tests_in_directory(test_path, category)

func _run_tests_in_directory(path: String, category: String) -> void:
    var dir = DirAccess.open("res://" + path)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            if file_name.ends_with(".gd") and file_name.begins_with("test_"):
                var test_script = load(path + file_name)
                if test_script:
                    _run_test_script(test_script, category)
            file_name = dir.get_next()

func _run_test_script(test_script: GDScript, category: String) -> void:
    var test = test_script.new()
    test.test_completed.connect(
        func(test_name: String, result: Dictionary): 
            _on_test_completed(test_name, result, category)
    )
    
    # Get all test methods
    var methods = []
    for method in test.get_method_list():
        if method.name.begins_with("test_"):
            methods.append(method.name)
    
    # Run each test method
    for method in methods:
        _stats.total += 1
        _stats.categories[category].total += 1
        
        test.before_each()
        test.call(method)
        test.after_each()

func _on_test_completed(test_name: String, result: Dictionary, category: String) -> void:
    var execution_result = {
        "name": test_name,
        "status": result.status
    }
    
    # Only include message and stack trace for failures
    if result.status == "failed":
        execution_result["message"] = result.message
        execution_result["stack_trace"] = result.details.stack_trace
    
    # Add execution result to category
    _stats.categories[category].executions.append(execution_result)
    
    # Update statistics
    if result.status == "passed":
        _stats.passed += 1
        _stats.categories[category].passed += 1
        _log_test_result("PASS", execution_result)
    else:
        _stats.failed += 1
        _stats.categories[category].failed += 1
        _log_test_result("FAIL", execution_result)

func _write_results() -> void:
    _stats.end_time = Time.get_datetime_string_from_system()
    
    var output_path = _config.output_directory + "test_results_%s_%s.log" % [
        _timestamp,
        "_".join(_config.categories.keys())
    ]
    
    _output_file = FileAccess.open(output_path, FileAccess.WRITE)
    if _output_file:
        # Format the JSON with indentation for readability
        _output_file.store_string(JSON.stringify(_stats, "  "))
        _output_file.close()

func _log_test_result(status: String, result: Dictionary) -> void:
    if _config.get("output_format", {}).get("verbose", true):
        var message = "[%s] %s" % [status, result.name]
        if status == "FAIL":
            message += ": %s" % result.message
        print(message)

func _log_header(message: String) -> void:
    print("\n=== %s ===\n" % message)

func _log_section(message: String) -> void:
    print("\n--- %s ---\n" % message)

func _log_footer() -> void:
    print("\nTest Run Complete")
    print("Total: %d, Passed: %d, Failed: %d, Skipped: %d" % [
        _stats.total,
        _stats.passed,
        _stats.failed,
        _stats.skipped
    ])
#endregion 