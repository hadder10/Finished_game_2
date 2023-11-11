extends Node

@export var can_enable:  bool = true
@export var can_disable: bool = false

# @export var enable_filter_pass
@export var target: Control
var anim: AnimationPlayer

@export var enable_animation: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	if !target:
		print(name, ": no Control node specified")
		return
	if enable_animation and \
		target.has_node("appear_anim") and\
		target.get_node("appear_anim") is AnimationPlayer:
		anim = target.get_node("appear_anim")
	else:
		print(name, ": animation omitted")
	
func _process(delta): # dummy 
	pass
	
func _on_activate():
	
	# Object deactivation
	if target.visible:
		if can_disable:
			
			if anim:
				anim.play_backwards("appear")
				await anim.animation_finished
				
			target.mouse_filter = Control.MOUSE_FILTER_IGNORE
			target.process_mode = Node.PROCESS_MODE_DISABLED
			target.visible = false
			print(name, ": disabled GUI element ", target.name)
		else:
			print(name, ": no permission to disable GUI element ", target.name)
			
	# Object activation	
	else:
		if can_enable:
				
			target.mouse_filter = Control.MOUSE_FILTER_STOP
			target.process_mode = Node.PROCESS_MODE_INHERIT
			target.visible = true
			
			if anim:
				anim.play("appear")
				
			print(name, ": enabled GUI element ", target.name)
		else:
			print(name, ": permission to enable GUI element ", target.name)
