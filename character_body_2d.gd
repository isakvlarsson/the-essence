extends CharacterBody2D

var speed = 400

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func _input(event):
	if Input.is_action_pressed("whack"):
		get_node("AnimatedSprite2D").play("whack")
		
func _physics_process(delta):
	get_input()
	move_and_slide()
