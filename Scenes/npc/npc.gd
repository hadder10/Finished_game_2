extends CharacterBody3D

signal died

@export var FIRST_ACTION_NODE : Node3D
@export var SPEED = 5.0
@export var TURN_SPEED = 5.0
@export var HEALTH : int = 3
@export var IS_ENEMY : bool = false

@onready var pain_sound = $PainSound
@onready var die_timer = $DieTimer
@onready var _animplayer = $CollisionShape3D/MAN_skeletal/AnimationPlayer
@onready var ray = $RayCast3D
@onready var _collision = $CollisionShape3D

var mat1 = preload("res://Assets/enemies/enemy_kurtka.tres")
var mat2 = preload("res://Assets/enemies/friendkurtka.tres")
var facemat1 = preload("res://Assets/enemies/enemyface.tres")
var facemat2 = preload("res://Assets/enemies/friendface.tres")


var _action_array : Array
var _cur_action = 0
var _is_dead : bool = false


var _frame_counter = 0
var _pause_frame = -1
var _event_array : Array
var _cur_event = -1
var _rewind_speed = 1
var _paused : bool = false
var _rewinding : bool = false
var _fast_forwarding : bool = false
var _shots_fired : bool = false
var _cur_wait : float = -1


func _do_action(delta) -> void:
	var cur_action_node = _action_array[_cur_action]
	if cur_action_node.action == "STAND":
		_animplayer.play("idle")
		look_at(Vector3(cur_action_node.target.global_position.x, position.y, cur_action_node.target.global_position.z))
		if _cur_wait == -1:
			_cur_wait = cur_action_node.wait
		if _cur_wait <= 0:
			_cur_action += 1
			_cur_wait = -1
			return
		else:
			_cur_wait -= delta
		pass
	elif cur_action_node.action == "MOVE":
		_animplayer.play("RUN_alternative");
		if position == cur_action_node.global_position:
			_cur_action += 1
			return
		look_at(Vector3(cur_action_node.global_position.x, position.y, cur_action_node.global_position.z))
		position = position.move_toward(cur_action_node.global_position, delta * SPEED)
	
	elif cur_action_node.action == "FIRE":
		look_at(Vector3(cur_action_node.target.global_position.x, position.y, cur_action_node.target.global_position.z))
		_animplayer.play("shoot")
		if _shots_fired:
			if ray.is_colliding():
				var target = ray.get_collider()
				if target.is_in_group("NPC"):
					target._get_shot()
				elif target.is_in_group("PLAYER"):
					target._dead()
			_cur_action += 1
			_shots_fired = false
			return
	else:
		printerr("Node doesn't have action")
	return

func _undo_action(delta) -> void:
	if _cur_action == len(_action_array):
		_cur_action -= 1
	var cur_action_node = _action_array[_cur_action]
	var prev_action_node = _action_array[_cur_action - 1] if _cur_action > 0 else null
	if cur_action_node.action == "STAND":
		look_at(Vector3(cur_action_node.target.global_position.x, position.y, cur_action_node.target.global_position.z))
		_animplayer.play("idle")
		if _cur_wait == -1:
			_cur_wait = 0
		if _cur_wait >= cur_action_node.wait:
			_cur_action -= 1
			_cur_wait = -1
			return
		else:
			_cur_wait += delta
	elif cur_action_node.action == "MOVE":
		_animplayer.play("RUN_alternative");
		if position == prev_action_node.global_position:
			_cur_action -= 1
			return
		look_at(2 * position - Vector3(prev_action_node.global_position.x, position.y, prev_action_node.global_position.z))
		position = position.move_toward(prev_action_node.global_position, delta * SPEED)
	
	elif cur_action_node.action == "FIRE":
		look_at(Vector3(cur_action_node.target.global_position.x, position.y, cur_action_node.target.global_position.z))
		_animplayer.play("shoot", -1, 1, true)
		if _shots_fired:
			_cur_action -= 1
			_shots_fired = false
			return
	else:
		printerr("Node doesn't have action")
	return
	

# Called when the node enters the scene tree for the first time.
func _ready():
	var root_node: Node3D = get_tree().root.get_child(0)
	died.connect(root_node._on_death)

	if IS_ENEMY:
		$CollisionShape3D/MAN_skeletal/Armature/Skeleton3D/Cube.set_surface_override_material(2, mat1)
		$CollisionShape3D/MAN_skeletal/Armature/Skeleton3D/Cube.set_surface_override_material(0, facemat1)
	else:
		$CollisionShape3D/MAN_skeletal/Armature/Skeleton3D/Cube.set_surface_override_material(2, mat2)
		$CollisionShape3D/MAN_skeletal/Armature/Skeleton3D/Cube.set_surface_override_material(0, facemat2)
	if FIRST_ACTION_NODE != null:
		_action_array.append(FIRST_ACTION_NODE)
		while _action_array.back().next != null:
			_action_array.append(_action_array.back().next)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _paused:
		if _pause_frame == -1:
			_pause_frame = _frame_counter
		for i in range(_rewind_speed):
			if _rewinding and _frame_counter > 0:
				if _cur_event > -1 and _event_array[_cur_event][0] == _frame_counter:
					if _event_array[_cur_event][1] == "death":
						print("play undeath")
						
						_animplayer.play("death", -1, 1, true)
					if _event_array[_cur_event][1] == "hp":
						HEALTH += _event_array[_cur_event][2]
						if _is_dead:
							$Decal.hide()
							_is_dead = false
							_collision.disabled = false
					_cur_event -= 1
				if not _is_dead and _cur_action >= 0:
					_undo_action(delta)
				_frame_counter -= 1
			elif _fast_forwarding and _frame_counter < _pause_frame:
				if _cur_event < len(_event_array) - 1 and _event_array[_cur_event + 1][0] == _frame_counter:
					if _event_array[_cur_event + 1][1] == "hp":
						HEALTH -= _event_array[_cur_event + 1][2]
						if HEALTH == 0:
							_is_dead = true
							$Decal.show()
							_collision.disabled = true
							_animplayer.play("death")
							_animplayer.queue("dead/deatd")
					_cur_event += 1
				if not _is_dead and _cur_action < len(_action_array):
					_do_action(delta)
				_frame_counter += 1
			else:
				pass
	else:
		if _pause_frame != -1:
			_pause_frame = -1
			for i in range(len(_event_array) - _cur_event - 1):
				_event_array.pop_back()
		if not _is_dead and _cur_action < len(_action_array):
			_do_action(delta)
		
		_frame_counter += 1


func _get_shot():
	if !_is_dead:
		_event_array.append([_frame_counter, "hp", 1])
		_cur_event += 1
		HEALTH -= 1
		if HEALTH == 0:
			_is_dead = true
			$Decal.show()
			_collision.disabled = true
			_animplayer.play("death")
			_animplayer.queue("dead/deatd")


func _on_test_player_pause_start():
	_animplayer.pause()
	_paused = true
	stop_all_sounds()


func _on_test_player_pause_end():
	_animplayer.speed_scale = 1.0
	_animplayer.play()
	_paused = false


func _on_test_player_rewind_start():
	_animplayer.speed_scale = -1 * _rewind_speed
	_animplayer.play()
	_rewinding = true


func _on_test_player_rewind_end():
	_animplayer.pause()
	_rewinding = false


func _on_test_player_fast_forward_start():
	_animplayer.speed_scale = _rewind_speed
	_animplayer.play()
	if _animplayer.current_animation == "death":
		_animplayer.queue("dead/deatd")
	_fast_forwarding = true


func _on_test_player_fast_forward_end():
	_animplayer.pause()
	_fast_forwarding = false


func _on_test_player_shot(npc):
	if npc == self and !_is_dead:
		emit_signal("died")
		print("DEAD ", self)
		
		_event_array.append([_frame_counter, "hp", HEALTH])
		_cur_event += 1
		HEALTH = 0
		_is_dead = true
		$Decal.show()
		_collision.disabled = true
		_animplayer.play("death")
		_animplayer.queue("dead/deatd")

		#ALWAYS DO THIS AT THE END OF THE FUNC
		die_timer.start()
		await Signal(die_timer, 'timeout')
		pain_sound.play()


func _on_test_player_accel_start(speed):
	_rewind_speed = speed


func _on_test_player_accel_end():
	_rewind_speed = 1


func stop_all_sounds():
	die_timer.stop()
	pain_sound.stop()


func _on_animation_player_animation_changed(old_name, _new_name):
	if old_name == "death" and !_paused:
		_event_array.append([_frame_counter, "death"])
		_cur_event += 1


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "shoot":
		_shots_fired = true
