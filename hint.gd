extends RefCounted
class_name Hint

enum HintTechnique {
	SINGLE_CANDIDATE,
	HIDDEN_SINGLE,
	NAKED_PAIR_ROW,
	NAKED_PAIR_COL,
	NAKED_PAIR_BOX,
	NAKED_TRIPLE_ROW,
	NAKED_TRIPLE_COL,
	NAKED_TRIPLE_BOX,
	NAKED_QUAD_ROW,
	NAKED_QUAD_COL,
	NAKED_QUAD_BOX,
	POINTING_PAIR,
	BOX_LINE_REDUCTION,
	X_WING_ROW,
	X_WING_COL,
	SWORDFISH_ROW,
	SWORDFISH_COL,
	JELLYFISH_ROW,
	JELLYFISH_COL,
	XY_CHAIN,
	W_WING,
	XY_WING,
	AIC_CHAIN,
	NISHIO
}

var technique: HintTechnique
var title: String
var description: String
var cells: Array[Vector2i] = [] # The primary cells of the hint
var secondary_cells: Array[Vector2i] = [] # Secondary cells for highlighting (e.g., the rest of a house)
var cause_cells: Array[Vector2i] = [] # Cells that cause the hint (e.g. blocking numbers)
var numbers: Array[int] = [] # The numbers involved
var elim_cells: Array[Vector2i] = [] # Cells from which candidates can be eliminated
var elim_numbers: Array[int] = [] # The candidates to eliminate

# Optional step-by-step teaching support
var steps: Array = [] # Each step: {"text": String, "cells": Array[Vector2i], "secondary_cells": Array[Vector2i], "cause_cells": Array[Vector2i], "elim_cells": Array[Vector2i], "elim_numbers": Array[int]}
var _active_step_index: int = -1

func _init(p_technique: HintTechnique, p_description: String):
	technique = p_technique
	description = p_description
	title = _get_technique_title_from_enum(p_technique)

func _get_technique_title_from_enum(p_technique: HintTechnique) -> String:
	var tech_key = Hint.HintTechnique.keys()[p_technique]
	
	var parts = tech_key.split("_")
	
	# For names like NAKED_PAIR_ROW, we don't want the unit type in the title.
	if parts.size() > 1 and (parts[parts.size() - 1] == "ROW" or parts[parts.size() - 1] == "COL" or parts[parts.size() - 1] == "BOX"):
		parts.resize(parts.size() - 1)
	
	var title_words = []
	for part in parts:
		title_words.append(part.capitalize())
	
	var title_str = " ".join(title_words)
	
	# Handle special cases like X-Wing
	if title_str == "X Wing":
		return "X-Wing"
		
	return title_str 

func add_step(text: String, step_cells: Array = [], secondary: Array = [], cause: Array = [], elim: Array = [], elim_nums: Array[int] = []):
	var step = {
		"text": text,
		"cells": step_cells.duplicate(true),
		"secondary_cells": secondary.duplicate(true),
		"cause_cells": cause.duplicate(true),
		"elim_cells": elim.duplicate(true),
		"elim_numbers": elim_nums.duplicate(true)
	}
	steps.append(step)
	if _active_step_index == -1:
		_active_step_index = 0

func has_steps() -> bool:
	return steps.size() > 0

func set_active_step(index: int):
	if steps.is_empty():
		_active_step_index = -1
		return
	_active_step_index = clamp(index, 0, steps.size() - 1)

func get_active_step_index() -> int:
	return _active_step_index

func get_active_description() -> String:
	if has_steps() and _active_step_index >= 0:
		return steps[_active_step_index].text
	return description

func get_active_cells() -> Array:
	if has_steps() and _active_step_index >= 0:
		return steps[_active_step_index].cells
	return cells

func get_active_secondary_cells() -> Array:
	if has_steps() and _active_step_index >= 0:
		return steps[_active_step_index].secondary_cells
	return secondary_cells

func get_active_cause_cells() -> Array:
	if has_steps() and _active_step_index >= 0:
		return steps[_active_step_index].cause_cells
	return cause_cells

func get_active_elim_cells() -> Array:
	if has_steps() and _active_step_index >= 0:
		return steps[_active_step_index].elim_cells
	return elim_cells

func get_active_elim_numbers() -> Array:
	if has_steps() and _active_step_index >= 0:
		return steps[_active_step_index].elim_numbers
	return elim_numbers
