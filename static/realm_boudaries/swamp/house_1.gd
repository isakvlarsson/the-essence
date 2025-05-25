extends Node2D

func _ready() -> void:
	$InteractionBox.connect("body_entered", on_body_entered)
	$InteractionBox.connect("body_exited", on_body_exited)

func on_body_entered(body: Node2D): 
	if !body.is_in_group("player"):
		return
	$InteractionText.visible = true


func on_body_exited(body: Node2D):
	if !body.is_in_group("player"):
		return
	$InteractionText.visible = false

func interact(player: CharacterBody2D):
	player.day_night_handler.skip_time(1)
