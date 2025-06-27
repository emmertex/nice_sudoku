extends PopupPanel

signal hint_dismissed
signal next_hint_requested
signal hint_selected(hint)

var hints: Array[Hint] = []
var current_hint_index: int = 0

@onready var description_label = $VBoxContainer/DescriptionLabel
@onready var next_button = $VBoxContainer/HBoxContainer/NextButton
@onready var dismiss_button = $VBoxContainer/HBoxContainer/DismissButton

func _ready():
	next_button.pressed.connect(_on_next_pressed)
	dismiss_button.pressed.connect(_on_dismiss_pressed)

func set_hints(p_hints: Array[Hint]):
	self.hints = p_hints
	current_hint_index = 0
	if hints.is_empty():
		description_label.text = "No hints available."
		next_button.disabled = true
	else:
		_show_hint(current_hint_index)

func _show_hint(index: int):
	var hint = hints[index]
	description_label.text = hint.description
	next_button.disabled = (hints.size() <= 1)
	emit_signal("hint_selected", hint)

func _on_next_pressed():
	current_hint_index = (current_hint_index + 1) % hints.size()
	_show_hint(current_hint_index)
	emit_signal("next_hint_requested", hints[current_hint_index])

func _on_dismiss_pressed():
	emit_signal("hint_dismissed")
	queue_free() 