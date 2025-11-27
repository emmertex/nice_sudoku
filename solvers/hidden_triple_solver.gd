const HiddenSubsetSolverBase = preload("res://solvers/hidden_subset_solver_base.gd")

extends HiddenSubsetSolverBase
class_name HiddenTripleSolver

func _get_solver_name() -> String:
	return "Hidden Triple Solver"

func _get_subset_size() -> int:
	return 3

func _get_subset_label() -> String:
	return "TRIPLE"

