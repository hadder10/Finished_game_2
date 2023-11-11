extends Node

@export var player : CharacterBody3D
@export var countdownBar : TextureProgressBar
@export var countdownLabel : Label
@export var timeLimit : float
@export var reverse : bool = false
@export var pause : bool = false

var countdown
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
	if countdownBar:
		countdownBar.value = 0
	if countdownLabel:
		countdownLabel.text = format_seconds(timeLimit)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if pause:
		if countdown > 0 and reverse:
			countdown -= delta
		else:
			pass
	else:
		if countdown < timeLimit:
			countdown += delta
	
	if countdownBar:
		countdownBar.value = 100 * countdown / timeLimit
	if countdownLabel:
		countdownLabel.text = format_seconds(countdown)


func _on_test_player_rewind_start():
	reverse = true


func _on_test_player_rewind_end():
	reverse = false


func _on_test_player_pause_start():
	pause = true


func _on_test_player_pause_end():
	pause = false
