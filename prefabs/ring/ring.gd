extends Node2D

@onready var path = $Path2D/PathFollow2D
@onready var audio = $AudioStreamPlayer2D
const MOVESPEED = 0.15
var movingRight = true

# Called when the node enters the scene tree for the first time.
func _ready():
	path.progress_ratio = randf_range(0, 1)
	movingRight = randf() > 0.5


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	path.progress_ratio += MOVESPEED * delta


func _on_area_2d_body_entered(body):
	if body.isSkydiving:
		body.dove_through_ring()
		audio.play()
