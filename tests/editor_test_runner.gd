@tool
extends EditorScript

func _run():
	var script = load("res://tests/test_solvers.gd")
	var tree := SceneTree.new()
	Engine.set_main_loop(tree)
	# Instantiate and run _init of the test SceneTree
	var runner = script.new()
	# runner will call quit() with exit code
	return

