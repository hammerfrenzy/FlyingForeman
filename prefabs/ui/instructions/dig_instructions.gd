extends Control

@onready var richTextLabel = $RichTextLabel
@onready var countdownLabel = $Countdown
@onready var audio = $AudioStreamPlayer2D
@onready var timer = $Timer

var countdownSFX = preload("res://audio/sfx/countdown.wav")
var startSFX = preload("res://audio/sfx/start.wav")

var timeLeft = 3
var hideNextTime = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func reset():
	timeLeft = 3
	countdownLabel.text = str(timeLeft)
	hideNextTime = false
	richTextLabel.visible = true
	audio.stream = countdownSFX
	
func startCountdown():
	audio.play()
	timer.start(1)

func _on_timer_timeout():
	if hideNextTime:
		visible = false
		return
	
	timeLeft -= 1
	countdownLabel.text = str(timeLeft)
	
	if timeLeft > 0:
		audio.play()
		timer.start(1)
	else:
		hideNextTime = true
		richTextLabel.visible = false
		countdownLabel.text = "MASH!!!"
		audio.stream = startSFX
		audio.play()
		timer.start(1)
