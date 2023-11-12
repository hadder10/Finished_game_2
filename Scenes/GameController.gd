extends Node3D


var points: int = 0
var living_npcs: int = 0
var npc_list := []
var player: CharacterBody3D 

@export var current_level: PackedScene
@export var rumble: AudioStreamPlayer

func _ready():
	rumble.play()
	add_child(current_level.instantiate())
	print(get_tree().get_nodes_in_group("NPC"))
	for npc in get_tree().get_nodes_in_group("NPC"):
		npc_list.append(npc)

func _on_death():
	lose()


func lose():
	print("Game lost")


func win():
	print("Game won")


func check_win_lose_on_timer_end():
	for npc in npc_list:
		if not npc._is_dead:
			lose()
			return
	win()
	return


func manage_musci():
	pass
