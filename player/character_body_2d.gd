extends CharacterBody2D

@onready var crop_scene = preload("res://farming/farm_plot.tscn") 
@onready var fence_sceneLR = preload("res://defences/fence_lr.tscn") 
@onready var fence_sceneUD = preload("res://defences/fence_ud.tscn") 

var speed = 400
var canDash = true
var dashing = false
var dashSpeed = 1200
var dashDirection = Vector2.ZERO
var input_direction = Vector2.ZERO
var last_direction = Vector2.ZERO

func get_input():
	if not dashing:
		input_direction = Input.get_vector("left", "right", "up", "down")
		if input_direction != Vector2.ZERO:
			last_direction = input_direction
		velocity = input_direction * speed
		dashDirection = input_direction

func _input(event):
	if Input.is_action_pressed("whack"):
		get_node("AnimatedSprite2D").play("whack")
	if Input.is_action_just_pressed("plant"):
		plant_crops()
	if Input.is_action_just_pressed("fence"):
		place_fence()
		
		
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

func place_fence():
	var pos: Vector2 = global_position
	var fence: Node2D = fence_sceneLR.instantiate()
	if last_direction.x != 0:
		fence = fence_sceneLR.instantiate()
	elif last_direction.y != 0:
		fence = fence_sceneUD.instantiate()
	else:
		fence = fence_sceneLR.instantiate()
	get_tree().root.add_child(fence)
	fence.global_position = pos + Vector2(0.0, 0.0)
	var nav_region = get_tree().root.get_node("Main/NavigationRegion")
	nav_region.add_child(fence)
