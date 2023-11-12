extends CharacterBody3D

@export var FIRST_ACTION_NODE : Node3D
@export var SPEED = 5.0
@export var TURN_SPEED = 5.0
@export var HEALTH : int = 3
@export var ALIVE_MATERIAL : StandardMaterial3D = StandardMaterial3D.new()
@export var DEAD_MATERIAL : StandardMaterial3D = StandardMaterial3D.new()

@onready var mesh = $CollisionShape3D/MeshInstance3D

signal target_shot(target)

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



func _do_action(delta) -> void:
	var cur_action_node = _action_array[_cur_action]
	if cur_action_node.action == "STAND":
		pass
	elif cur_action_node.action == "MOVE":
		if position == cur_action_node.global_position:
			_cur_action += 1
			return
		position = position.move_toward(cur_action_node.global_position, delta * SPEED)
	elif cur_action_node.action == "FIRE":
		target_shot.emit(cur_action_node.target)
		_cur_action += 1
	else:
		printerr("Node doesn't have action")
	return

func _undo_action(delta) -> void:
	if _cur_action == len(_action_array):
		_cur_action -= 1
	var cur_action_node = _action_array[_cur_action - 1]
	if cur_action_node.next.action == "MOVE":
		if position == cur_action_node.global_position:
			_cur_action -= 1
			return
		position = position.move_toward(cur_action_node.global_position, delta * SPEED)
	elif cur_action_node.next.action == "FIRE":
		_cur_action -= 1
	else:
		printerr("Node doesn't have action")
	return
	

# Called when the node enters the scene tree for the first time.
func _ready():
	ALIVE_MATERIAL.albedo_color = Color(0.349, 0.58, 0.816)
	DEAD_MATERIAL.albedo_color = Color(0.92, 0.69, 0.13, 1.0)
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
					HEALTH += _event_array[_cur_event][1]
					if _is_dead:
						_is_dead = false
						mesh.material_override = ALIVE_MATERIAL
					_cur_event -= 1
				if not _is_dead and _cur_action > 0:
					_undo_action(delta)
				_frame_counter -= 1
			elif _fast_forwarding and _frame_counter < _pause_frame:
				if _cur_event < len(_event_array) - 1 and _event_array[_cur_event + 1][0] == _frame_counter:
					HEALTH -= _event_array[_cur_event + 1][1]
					if HEALTH == 0:
						_is_dead = true
						mesh.material_override = DEAD_MATERIAL
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


func _on_target_shot(target):
	if target == self and !_is_dead:
		_event_array.append([_frame_counter, 1])
		_cur_event += 1
		HEALTH -= 1
		if HEALTH == 0:
			_is_dead = true


func _on_test_player_pause_start():
	_paused = true


func _on_test_player_pause_end():
	_paused = false


func _on_test_player_rewind_start():
	_rewinding = true


func _on_test_player_rewind_end():
	_rewinding = false


func _on_test_player_fast_forward_start():
	_fast_forwarding = true


func _on_test_player_fast_forward_end():
	_fast_forwarding = false


func _on_test_player_shot(npc):
	if npc == self and !_is_dead:
		print("DEAD", self)
		_event_array.append([_frame_counter, HEALTH])
		_cur_event += 1
		HEALTH = 0
		_is_dead = true
		mesh.material_override = DEAD_MATERIAL


func _on_test_player_accel_start(speed):
	_rewind_speed = speed


func _on_test_player_accel_end():
	_rewind_speed = 1
