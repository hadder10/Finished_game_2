extends Node

@export var keybind : InputEvent

signal tab_pressed
# Called when the node enters the scene tree for the first time.
func _input(event):
	if event is InputEventKey \
			 and event.pressed \
			 and event.keycode == keybind.keycode:
				# Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				tab_pressed.emit()
