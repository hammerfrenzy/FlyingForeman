##############################
# I wanted to keep Foreman a CharacterBody2D after parenting
# it under the jump path, so this is a workaround to communicate
# through the game scene 
##############################
extends Node2D

signal finished_jump
signal started_drilling
signal landed
signal reset_pressed

@onready var foreman = $Path2D/PathFollow2D/Foreman
	
func jump():
	foreman.jump()
	
func reset():
	foreman.reset()
	
func get_foreman():
	return foreman
		
func get_falling_speed():
	return foreman.get_falling_speed()
	
func _on_foreman_finished_jump():
	finished_jump.emit()

func _on_foreman_landed():
	landed.emit()

func _on_foreman_started_drilling():
	started_drilling.emit()

func _on_foreman_reset_pressed():
	reset_pressed.emit()
