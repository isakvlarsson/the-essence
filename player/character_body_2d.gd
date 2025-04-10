extends CharacterBody2D

@onready var crop_scene = preload("res://farming/farm_plot.tscn") 

var speed = 400
var canDash = true
var dashing = false
var dashSpeed = 1200
var dashDirection = Vector2.ZERO

func get_input():
	if not dashing:
		var input_direction = Input.get_vector("left", "right", "up", "down")
		velocity = input_direction * speed
		dashDirection = input_direction

func _input(event):
	if Input.is_action_pressed("whack"):
		get_node("AnimatedSprite2D").play("whack")
	if Input.is_action_just_pressed("plant"):
		plant_crops()
		
		
func dash():
	if Input.is_action_just_pressed("dash") and canDash and dashDirection != Vector2.ZERO:
		velocity = dashDirection.normalized()*dashSpeed
		canDash = false
		dashing = true
		
		#dash for 0.2 seconds
		await get_tree().create_timer(0.2).timeout 
		dashing = false
		
		#Able to dash again after 1 second
		await get_tree().create_timer(1.0).timeout
		canDash = true
		
func _physics_process(delta):
	get_input()
	dash()
	move_and_slide()

func _on_stick_body_entered(body: Node2D) -> void:
	if body.is_in_group("Creature"):
		body.queue_free() # Replace with function body.
		
func plant_crops():
	var pos: Vector2 = global_position
	var crop_instance: Node2D = crop_scene.instantiate()
	get_tree().root.add_child(crop_instance)
	crop_instance.global_position = pos + Vector2(0.0, 0.0)
	crop_instance.scale = Vector2(1.0, 1.0)*10
	
