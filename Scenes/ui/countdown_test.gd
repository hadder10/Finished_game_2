extends Node

@export var countdownBar : TextureProgressBar
@export var countdownLabel : Label
@export var timeLimit : float

var countdown
# Called when the node enters the scene tree for the first time.
func format_seconds(seconds):
	var minutes = int(seconds / 60)
	var millis = int(seconds*1000) % 1000
	
	seconds = int(seconds - minutes * 60)
	
	var mins_string = "%0*d" % [2, minutes]
	var secs_string = "%0*d" % [2, seconds]
	var mils_string = "%0*d" % [2, millis]
		
	return mins_string + ":" + secs_string + "." + mils_string
	
	
func _ready():
	countdown = timeLimit
	if countdownBar:
		countdownBar.value = 100
	if countdownLabel:
		countdownLabel.text = format_seconds(timeLimit)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if countdown > 0:
		countdown -= delta
		
		if countdownBar:
			countdownBar.value = 100 * countdown / timeLimit
		if countdownLabel:
			countdownLabel.text = format_seconds(countdown)
	
