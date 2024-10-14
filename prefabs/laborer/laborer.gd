extends Node2D

@onready var animatedSprite = $AnimatedSprite2D
@onready var audio = $AudioStreamPlayer2D
@onready var dirtTemplate = preload("res://prefabs/dirt_debris/dirt_debris.tscn")

var canDig = false
var foreman: Node2D
var dirtMound: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	animatedSprite.play("idle")
	foreman = get_node("../Foreman")
	dirtMound =get_node("../DirtMound")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if canDig and Input.is_action_just_pressed("Dig"):
		audio.pitch_scale = randf_range(0.8, 1.2)
		audio.play()
		animatedSprite.play("dig")
		throw_dirt()

func setCanDig(value: bool):
	canDig = value

func throw_dirt():
	for i in 4:
		var dirt = dirtTemplate.instantiate()
		dirt.set_initial_position(position - Vector2(randf_range(10, 20), 0))
		add_child(dirt)
		
	var translateUpAmount = Vector2.UP * 12
	foreman.translate(translateUpAmount)
	dirtMound.translate(translateUpAmount)

func _on_animated_sprite_2d_animation_looped():
	if animatedSprite.animation == "dig":
		animatedSprite.play("idle")
