extends Control

signal time_end

@onready var countdownBar = $Display/TimeLimitBar/TextureProgressBar
@onready var countdownLabel = $Display/TimeLimitBar/TimerLabel
@export var timeLimit : float = 30.0

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
	var root_node = get_tree().root.get_child(0)
	time_end.connect(root_node.check_win_lose_on_timer_end)
	countdown = 0
	pause_countdown = -1
	if countdownBar:
		countdownBar.value = 0
	if countdownLabel:
		countdownLabel.text = format_seconds(timeLimit)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if pause:
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
		if pause_countdown != -1:
			pause_countdown = -1
		if countdown < timeLimit:
			countdown += delta
		else:
			time_end.emit()
	
	if countdownBar:
		countdownBar.value = 100 * countdown / timeLimit
	if countdownLabel:
		countdownLabel.text = format_seconds(countdown)


func _on_test_player_rewind_start():
	$"Display/ToggleIdicator<<"._on_activate()
	$CanvasLayer4.show()
	rewind = true


func _on_test_player_rewind_end():
	$"Display/ToggleIdicator<<"._on_activate()
	$CanvasLayer4.hide()
	
	rewind = false


func _on_test_player_pause_start():
	$Crosshair.hide()
	$Display/RewindOverlay.show()
	pause = true


func _on_test_player_pause_end():
	$Crosshair.show()
	$Display/RewindOverlay.hide()
	pause = false


func _on_test_player_fast_forward_start():
	$"Display/ToggleIndicator>>"._on_activate()
	$CanvasLayer4.show()
	fast_forward = true


func _on_test_player_fast_forward_end():
	$"Display/ToggleIndicator>>"._on_activate()
	$CanvasLayer4.hide()
	fast_forward = false


func _on_test_player_accel_start(speed):
	rewind_speed = speed


func _on_test_player_accel_end():
	rewind_speed = 1
