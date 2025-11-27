const HiddenSubsetSolverBase = preload("res://solvers/hidden_subset_solver_base.gd")

extends HiddenSubsetSolverBase
class_name HiddenQuadSolver

func _get_solver_name() -> String:
	return "Hidden Quad Solver"

func _get_subset_size() -> int:
	return 4

func _get_subset_label() -> String:
	return "QUAD"

