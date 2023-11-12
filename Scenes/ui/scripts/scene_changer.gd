extends Node

@export var scene: PackedScene

func _on_activate():
	if scene:
		print(name,": Loading scene...")
		get_tree().quit()
	else:
		print(name, ": WARNING: no associated scene")
