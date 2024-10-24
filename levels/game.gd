extends Node2D

@onready var camera = $Camera2D
@onready var laborer = $Laborer
@onready var foreman = $Foreman
@onready var dirtMound = $DirtMound

@onready var digBGM = $DigBGMPlayer
@onready var ascendBGM = $AscendBGMPlayer
@onready var skydiveBGM = $SkydiveBGMPlayer
@onready var postGameBGM = $PostGameBGMPlayer

@onready var pregameTimer = $PregameTimer
@onready var digTimer = $DigTimer
@onready var startInstructions = $StartInstructions
@onready var digInstructions = $DigInstructions
@onready var flyInsructions = $FlyInstructions
@onready var ringInstructions = $RingInstructions
@onready var digCountdownLabel = $DigCountdown
@onready var drillDepthLabel = $Camera2D/DepthLabel
@onready var digAgainLabel = $Camera2D/DigAgainLabel

const GAME_TIME = 10
const COUNTDOWN_TIME = 3

var cameraStartPosition: Vector2
var foremanStartPosition: Vector2
var dirtMoundStartPosition: Vector2

var cameraSpeed = 1
const startCameraSpeed = 1
const maxCameraSpeed = 100

var foremanJumpProgress = 0

var hasPregameCountdownStarted = false
var isAscending = false
var cameraAtDestination = false
var isSkydiving = false
var isDrilling = false

func reset():
	hasPregameCountdownStarted = false
	isAscending = false
	cameraAtDestination = false
	isSkydiving = false
	isDrilling = false
	
	digInstructions.reset()
	
	digInstructions.visible = false
	startInstructions.visible = true
	flyInsructions.visible  = false
	ringInstructions.visible = false
	digCountdownLabel.visible = false
	drillDepthLabel.visible = false
	digAgainLabel.visible = false
	
	laborer.setCanDig(false)
	foreman.reset()
	
	camera.position = cameraStartPosition
	camera.offset.y = 0
	cameraSpeed = startCameraSpeed
	
	foreman.position = foremanStartPosition
	dirtMound.position = dirtMoundStartPosition
	
	digBGM.play()
	ascendBGM.stop()
	skydiveBGM.stop()
	postGameBGM.stop()

# Called when the node enters the scene tree for the first time.
func _ready():
	cameraStartPosition = camera.position
	foremanStartPosition = foreman.position
	dirtMoundStartPosition = dirtMound.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not hasPregameCountdownStarted and Input.is_action_just_pressed("Dig"):
		hasPregameCountdownStarted = true
		pregameTimer.start(COUNTDOWN_TIME)
		digInstructions.visible = true
		digInstructions.startCountdown()
		startInstructions.visible = false
	
	if !digTimer.is_stopped():
		digCountdownLabel.text = str(roundf(digTimer.time_left))
	
	if isAscending and (camera.position.y > foreman.position.y - 25):
		var movement = Vector2.UP * delta * cameraSpeed
		camera.position = camera.position + movement
		cameraSpeed = minf(cameraSpeed + (100 * delta), maxCameraSpeed)
		print(camera.position)
	elif isAscending:
		prepareForSkydive()
	elif isSkydiving:
		camera.position += Vector2.DOWN * delta * foreman.get_falling_speed()
	elif isDrilling:
		var dirtHeight = abs(dirtMound.position.y - dirtMoundStartPosition.y)
		var drillDepth = abs(roundf(foreman.get_foreman().get_drill_depth()))
		drillDepthLabel.text = str("Climbed " + str(dirtHeight) + " Meters\nDrilled " + str(drillDepth) + " Meters")
		camera.position += Vector2.DOWN * delta * foreman.get_falling_speed()
		camera.offset.y = move_toward(camera.offset.y, -50, 50 * delta)
		
func prepareForSkydive():
	cameraAtDestination = true
	isAscending = false
	digCountdownLabel.visible = false
	flyInsructions.visible = true
	flyInsructions.position = camera.position + (Vector2.LEFT * 115) + (Vector2.UP * 50)
	foreman.jump()

func _on_pregame_timer_timeout():
	# dig instruction's visibility set in its own script
	# so that the MASH!!! text can show up for a bit longer
	laborer.setCanDig(true)
	digCountdownLabel.visible = true
	digTimer.start(GAME_TIME)

func _on_dig_timer_timeout():
	laborer.setCanDig(false)
	digBGM.stop()
	ascendBGM.play()
	isAscending = true
	
func _on_foreman_finished_jump():
	ascendBGM.stop()
	skydiveBGM.play()
	isSkydiving = true

func _on_foreman_landed():
	drillDepthLabel.visible = true
	digAgainLabel.visible = true
	skydiveBGM.stop()
	postGameBGM.play()

func _on_foreman_started_drilling():
	isSkydiving = false
	isDrilling = true

func _on_foreman_reset_pressed():
	reset()
