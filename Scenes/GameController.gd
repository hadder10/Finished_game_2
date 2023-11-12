extends Node3D


var points: int = 0
var living_npcs: int = 0


@export var current_level: PackedScene


func _ready():
	add_child(current_level.instantiate())
