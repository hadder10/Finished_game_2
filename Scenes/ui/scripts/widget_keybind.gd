extends Node

signal tab_pressed
# Called when the node enters the scene tree for the first time.
func _input(event):
	if event is InputEventKey \
			 and event.pressed \
			 and event.keycode == KEY_TAB:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				tab_pressed.emit()
