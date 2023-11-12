extends Node

@export var player : CharacterBody3D
@export var rewind_widget : Control
@export var crosshair : Control
@export var countdownBar : TextureProgressBar
@export var countdownLabel : Label
@export var timeLimit : float

var rewind : bool = false
var fast_forward : bool = false
var pause : bool = false
var rewind_speed : int = 1

var countdown
var pause_countdown
# Called when the node enters the scene tree for the first time.
func format_seconds(seconds):
	var minutes = int(seconds / 60)
	var millis = int(seconds*100) % 100
	
	seconds = int(seconds - minutes * 60)
	
	var mins_string = "%0*d" % [2, minutes]
	var secs_string = "%0*d" % [2, seconds]
	var mils_string = "%0*d" % [2, millis]

	return mins_string + ":" + secs_string + "." + mils_string


func _ready():
	countdown = 0
	pause_countdown = -1
	if countdownBar:
		countdownBar.value = 0
	if countdownLabel:
		countdownLabel.text = format_seconds(timeLimit)
	
	rewind_widget.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if pause:
		if not rewind_widget.visible:
			rewind_widget.visible = true
		
		if crosshair.visible:
			crosshair.visible = false
		
		if pause_countdown == -1:
			pause_countdown = countdown
		for i in range (rewind_speed):
			if countdown > 0 and rewind:
				countdown -= delta
				if countdown < 0:
					countdown = 0
			elif countdown < pause_countdown and fast_forward:
				countdown += delta
				if countdown > pause_countdown:
					countdown = pause_countdown
			else:
				pass
	else:
		if rewind_widget.visible:
			rewind_widget.visible = false
		
		if not crosshair.visible:
			crosshair.visible = true
		
		if pause_countdown != -1:
			pause_countdown = -1
		if countdown < timeLimit:
			countdown += delta
	
	if countdownBar:
		countdownBar.value = 100 * countdown / timeLimit
	if countdownLabel:
		countdownLabel.text = format_seconds(countdown)


func _on_test_player_rewind_start():
	rewind = true


func _on_test_player_rewind_end():
	
	rewind = false


func _on_test_player_pause_start():
	pause = true


func _on_test_player_pause_end():
	pause = false


func _on_test_player_fast_forward_start():
	fast_forward = true


func _on_test_player_fast_forward_end():
	fast_forward = false


func _on_test_player_accel_start(speed):
	rewind_speed = speed


func _on_test_player_accel_end():
	rewind_speed = 1
