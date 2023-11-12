extends Node

# @export var enable_filter_pass
@export var target: TextureRect

@export var default: Texture2D
@export var changed: Texture2D

var toggled = false
# Called when the node enters the scene tree for the first time.
func _ready():
	target.texture = default
	
func _process(delta): # dummy 
	pass
	
func _on_activate():
	if toggled:
		target.texture = default
	else:
		target.texture = changed
	toggled = !toggled
	
	


func _on_playback_toggler_dummy_tab_pressed():
	pass # Replace with function body.
