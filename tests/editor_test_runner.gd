@tool
extends EditorScript

func _run():
	var script = load("res://tests/test_solvers.gd")
	var runner = script.new()
	if runner.has_method("run_all_tests"):
		var failed: int = runner.run_all_tests()
		if failed != 0:
			push_error("Tests failed: %d" % failed)
		else:
			print("All tests passed.")
	else:
		push_error("run_all_tests() not found on test runner.")

