extends Node3D


var points: int = 0
var living_npcs: int = 0
var npc_list := []

@export var current_level: PackedScene


func _ready():
	add_child(current_level.instantiate())
	for npc in get_tree().get_nodes_in_group("NPC"):
		npc_list.append(npc_list)


func _on_death():
	pass
