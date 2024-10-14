extends CharacterBody2D

signal finished_jump
signal started_drilling
signal landed
signal reset_pressed

@onready var parentNode = $"../../.."
@onready var pathFollow = $".."
@onready var sprite = $AnimatedSprite2D
@onready var gitAudio = $GitAudio
@onready var jumpAudio = $JumpAudio
@onready var drillAudio = $DrillAudio

@onready var dirtTemplate = preload("res://prefabs/dirt_debris/dirt_debris.tscn")
@onready var dugDirtTemplate = preload("res://prefabs/dug_dirt/dug_dirt.tscn")

const HORIZONTAL_SPEED = 200.0
const START_MAX_FALL_SPEED = 300
const START_FALL_SPEED = 100.0

var fallSpeed = START_FALL_SPEED
var maxFallSpeed = START_MAX_FALL_SPEED

var isJumping = false
var isSkydiving = false
var isDrilling = false
var isPostGame = false

var lastDirtPosition = Vector2.ZERO
var startPosition: Vector2

var drilledDirt: Sprite2D

func _ready():
	startPosition = position

func _physics_process(delta):
	if isJumping:
		rotation += delta * 50
		pathFollow.progress_ratio += delta * 0.5
		if pathFollow.progress_ratio >= 1:
			startSkydive()
	
	if isSkydiving:
		add_fall_velocity(50 * delta)
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction = Input.get_axis("Left", "Right")
		
		
		if direction:
			velocity.x = direction * HORIZONTAL_SPEED
			rotation = deg_to_rad(160) if velocity.x > 0 else deg_to_rad(200)
			# stinky way to keep foreman in bounds
			if position.x < -110 and velocity.x < 0:
				velocity.x = move_toward(velocity.x, 0, HORIZONTAL_SPEED)
			elif position.x > 110 and velocity.x > 0:
				velocity.x = move_toward(velocity.x, 0, HORIZONTAL_SPEED)
		else:
			rotation = PI
			velocity.x = move_toward(velocity.x, 0, HORIZONTAL_SPEED)
		
		move_and_slide()
		
	if isSkydiving and global_position.y >= -4:
		endSkydive()
		
	if isDrilling:
		var startYVelocity = velocity.y
		velocity.y = move_toward(velocity.y, 0, 200 * delta)
		move_and_slide()
		
		if velocity.y > 0.1:
			for i in 4:
				var dirt = dirtTemplate.instantiate()
				dirt.fromLaborer = false
				add_child(dirt)
				
		update_drilled_dirt()
		
		if startYVelocity > 0 and velocity.y == 0:
			isDrilling = false
			isPostGame = true
			sprite.play("idle")
			landed.emit()
			
	if isPostGame:
		if Input.is_action_just_pressed("Dig"):
			reset_pressed.emit()
			

func start_drilling_dirt():
	drillAudio.play()
	lastDirtPosition = position
	drilledDirt = dugDirtTemplate.instantiate()
	drilledDirt.global_position = Vector2(global_position.x - 16, -8) #global_position - Vector2(16, 5)
	get_tree().root.add_child(drilledDirt)

func update_drilled_dirt():
	var region_rect = drilledDirt.region_rect
	var dy = get_drill_depth()
	var new_region = Rect2(region_rect.position, Vector2(32, dy - 15))
	drilledDirt.region_rect = new_region
		
func get_falling_speed():
	return velocity.y
	
func get_drill_depth():
	return lastDirtPosition.y - position.y
	
func add_fall_velocity(amount: float):
	fallSpeed = minf(fallSpeed + amount, maxFallSpeed)
	velocity.y = fallSpeed

func dove_through_ring():
	maxFallSpeed += 200
	add_fall_velocity(50)
		
func reset():
	pathFollow.progress_ratio = 0 #reset position change from jump
	position = startPosition #reset the position change from falling
	isJumping = false
	isSkydiving = false
	isDrilling = false
	isPostGame = false
	maxFallSpeed = START_MAX_FALL_SPEED
	fallSpeed = START_FALL_SPEED
	sprite.play("idle")
	drilledDirt.queue_free()
		
func jump():
	gitAudio.play()
	jumpAudio.play()
	isJumping = true

func startSkydive():
	rotation = PI
	velocity.y = fallSpeed
	isJumping = false
	isSkydiving = true
	finished_jump.emit()
	
func endSkydive():
	isSkydiving = false
	isJumping = false
	isDrilling = true
	rotation = 0
	velocity.x = 0
	# don't mess with velocity.y here; we'll use it to do the "drill"
	sprite.play("land")
	start_drilling_dirt()
	started_drilling.emit()	

func _on_drill_audio_finished():
	if isDrilling:
		drillAudio.pitch_scale = randf_range(0.8, 1.2)
		drillAudio.play()
