extends CharacterBody3D


signal pause_start
signal pause_end
signal rewind_start
signal rewind_end
signal fast_forward_start
signal fast_forward_end
signal shot(npc)

@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5


@export var MOUSE_SENSETIVITY : float = 0.5
@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@export var CAMERA_CONTROLLER : Node3D 

@onready var ray = $camera_controller/RayCast3D
@onready var step_sound: AudioStreamPlayer3D = $FootstepPlayer
@onready var pause_click: AudioStreamPlayer = $PauseClick
@onready var footstep_timer: Timer = $FootstepPlayer/FootstepTimer
@onready var rewind_sound: AudioStreamPlayer = $RewindSound

@onready var rewind_start_sound = preload("res://Music/rewind/rewind_start.wav")
@onready var rewind_loop_sound = preload("res://Music/rewind/rewind_loop_2.wav")


var rewind_sound_status: String = "start"
var is_rewind_sound_playing: bool = false

var _npc_shot : Array

var _mouse_input : bool = false
var _mouse_rotation : Vector3 = Vector3(0, 0, 0)
var _rotation_input : float
var _tilt_input : float
var _player_rotation : Vector3
var _camera_rotation : Vector3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var _paused : bool = false
var _rewinding : bool = false
var _fast_forwarding : bool = false
var _frame_counter : int = 0
var _pause_frame : int = -1
var _player_positions_array : Array
var _player_rotations_array : Array

var step_timer_on: bool = false

func _input(event):
	if event.is_action_pressed("exit"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event.is_action_pressed("return") and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event.is_action_pressed("pause"):
		if _paused:
			if _rewinding:
				_rewinding = false
				rewind_sound.stop()
				rewind_end.emit()
			_paused = false
			pause_end.emit()
			rewind_sound.stop()
			pause_click.play()
		else:
			_paused = true
			pause_start.emit()
			pause_click.play()
	if event.is_action_pressed("rewind") and _paused:
		if _fast_forwarding:
			_fast_forwarding = false
			fast_forward_end.emit()
		_rewinding = true
		play_rewind_sound()
		rewind_start.emit()
	if event.is_action_released("rewind") and _paused:
		_rewinding = false
		rewind_sound.stop()
		rewind_sound_status = "start"
		rewind_end.emit()
	if event.is_action_pressed("fast_forward") and _paused:
		if _rewinding:
			_rewinding = false
			rewind_end.emit()
		_fast_forwarding = true
		play_rewind_sound()
		fast_forward_start.emit()
	if event.is_action_released("fast_forward") and _paused:
		_fast_forwarding = false
		rewind_sound.stop()
		rewind_sound_status = "start"
		fast_forward_end.emit()
	if event.is_action_pressed("shoot") and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and !_paused:
		if ray.is_colliding():
			while ray.get_collider() != null and ray.get_collider().is_in_group("NPC"):
				var target = ray.get_collider()
				print(target)
				shot.emit(target)
				_npc_shot.append(target) #add it to the array.
				ray.add_exception(target) #add to ray's exception. That way it could detect something being behind it.
				ray.force_raycast_update() #update the ray's collision query.
			for target in _npc_shot:
				ray.remove_exception(target)
			_npc_shot.clear()


func _unhandled_input(event):
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and !_paused
	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSETIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSETIVITY


func _update_camera(delta):
	if _paused:
		if _rewinding and _frame_counter > 0 or _fast_forwarding and _frame_counter < _pause_frame:
			_mouse_rotation = _player_rotations_array[_frame_counter]
			_player_rotation = Vector3(0.0, _mouse_rotation.y, 0.0)
			_camera_rotation = Vector3(_mouse_rotation.x, 0.0, 0.0)
		
			CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
			CAMERA_CONTROLLER.rotation.z = 0.0
		
			global_transform.basis = Basis.from_euler(_player_rotation)
		else:
			pass
	else:
		_mouse_rotation.x += _tilt_input * delta
		_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
		_mouse_rotation.y += _rotation_input * delta
		
		_player_rotation = Vector3(0.0, _mouse_rotation.y, 0.0)
		_camera_rotation = Vector3(_mouse_rotation.x, 0.0, 0.0)
		
		CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
		CAMERA_CONTROLLER.rotation.z = 0.0
		
		global_transform.basis = Basis.from_euler(_player_rotation)
		
		_rotation_input = 0.0
		_tilt_input = 0.0
		
		_player_rotations_array.append(_mouse_rotation)


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_player_positions_array.append(position)
	_player_rotations_array.append(_mouse_rotation)


func _physics_process(delta):
	if _paused:
		if _pause_frame == -1:
			_pause_frame = _frame_counter
		if _rewinding and _frame_counter > 0:
			_frame_counter -= 1
			position = _player_positions_array[_frame_counter]
		elif _fast_forwarding and _frame_counter < _pause_frame:
			_frame_counter += 1
			position = _player_positions_array[_frame_counter]
		else:
			rewind_sound.stop()
		_update_camera(delta)
	else:
		if _pause_frame != -1:
			for i in range(len(_player_positions_array) - _frame_counter - 1):
				_player_positions_array.pop_back()
				_player_rotations_array.pop_back()
			_pause_frame = -1
		_update_camera(delta)
		
		# Add the gravity.
		if not is_on_floor():
			velocity.y -= gravity * delta
		
		# Handle Jump.
		# if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		# 	velocity.y = JUMP_VELOCITY
		
		# Get the input direction and handle the movement/deceleration.
		var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			if not step_sound.playing and not step_timer_on:
				footstep_timer.start()
				step_timer_on = true
				step_sound.play()
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		
		move_and_slide()
		
		_frame_counter += 1
		_player_positions_array.append(position)


func _on_footstep_timer_timeout():
	step_timer_on = false


func play_rewind_sound():
	if rewind_sound_status == "start":
		rewind_sound.set_stream(rewind_start_sound)
		rewind_sound.play()
		is_rewind_sound_playing = true
		await Signal(rewind_sound, 'finished')
		is_rewind_sound_playing = false
		rewind_sound_status = "loop"
	if rewind_sound_status == "loop":
		rewind_sound.set_stream(rewind_loop_sound)
		rewind_sound.play()
		is_rewind_sound_playing = true
		await Signal(rewind_sound, 'finished')
		is_rewind_sound_playing = false
