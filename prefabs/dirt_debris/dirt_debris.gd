extends RigidBody2D

@onready var rigidbody = $"."

var rotationSpeed = -4
var initialVelocity

var reset_state = false
var initialPosition: Vector2

var fromLaborer = true

func set_initial_position(newPosition: Vector2):
	reset_state = true
	initialPosition = newPosition
	
func _integrate_forces(state):
	if reset_state:
		state.transform = Transform2D(0.0, initialPosition)
		reset_state = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var impulseDirection: Vector2
	if fromLaborer:
		var dx = randf_range(-3, -1) * 30
		var dy = randf_range(1, 3) * 150
		impulseDirection = Vector2(dx, -dy)
	else:
		var dx = randf_range(-3, 3) * 30
		var dy = randf_range(1, 3) * 150
		impulseDirection = Vector2(dx, -dy)
		
	rigidbody.apply_central_impulse(impulseDirection)


func _on_queue_free_timer_timeout():
	queue_free()
