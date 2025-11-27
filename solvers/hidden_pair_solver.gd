const HiddenSubsetSolverBase = preload("res://solvers/hidden_subset_solver_base.gd")

extends HiddenSubsetSolverBase
class_name HiddenPairSolver

func _get_solver_name() -> String:
	return "Hidden Pair Solver"

func _get_subset_size() -> int:
	return 2

func _get_subset_label() -> String:
	return "PAIR"
