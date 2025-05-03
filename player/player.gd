extends CharacterBody2D

@onready var crop_scene = preload("res://farming/farm_plot.tscn") 
@onready var fence_sceneLR = preload("res://defences/fence_lr.tscn") 
@onready var fence_sceneUD = preload("res://defences/fence_ud.tscn") 
@onready var trap_scene = preload("res://defences/trap.tscn") 
@onready var totem_scene = preload("res://defences/totem.tscn") 
@onready var interaction_area: Area2D = $InteractionBox
@onready var hud_toolbar = %HUD/ToolBar

var can_interact = true

var speed = 400
var canDash = true
var dashing = false
var dashSpeed = 1200
var dashDirection = Vector2.ZERO
var input_direction = Vector2.ZERO
var last_direction = Vector2.ZERO

# --- FOOTSTEP STUFF ---
@export var footstep_sounds: Array[AudioStream] = []
var last_index := -1
@onready var audio_player := $FootstepPlayer
var step_distance := 20.0
var distance_traveled := 0.0
var last_position := Vector2.ZERO

# --- WHACK SOUND STUFF ---
@export var whack_sounds: Array[AudioStream] = []  # Array for whack sounds
@onready var whack_audio_player := $WhackPlayer  # WhackPlayer node for whack sounds
var currentItem = "Stick"

func _ready():
	last_position = global_position
	hud_toolbar.connect("update_selected_item", _on_update_selected_item)

func get_input():
	if not dashing:
		input_direction = Input.get_vector("left", "right", "up", "down")
		if input_direction != Vector2.ZERO:
			last_direction = input_direction
		velocity = input_direction * speed
		dashDirection = input_direction

func _input(event):
	if Input.is_action_pressed("whack"):
		if !can_interact:
			return
		can_interact = false
		match currentItem:
			"stick": 
				get_node("AnimatedSprite2D").play("whack")
				play_whack_sound() # Play whack sound when whack animation is triggered
			"seeds":
				plant()
			"shovel":
				create_soil()
			"fence":
				place_fence()
		await get_tree().create_timer(0.1).timeout
		can_interact = true
		
		
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

func play_footstep():
	if footstep_sounds.size() == 0:
		return

	var index = randi() % footstep_sounds.size()
	while index == last_index and footstep_sounds.size() > 1:
		index = randi() % footstep_sounds.size()
	last_index = index

	audio_player.stream = footstep_sounds[index]
	audio_player.pitch_scale = randf_range(0.9, 1.1)  # Random pitch between 0.9 and 1.1
	audio_player.play()

func play_whack_sound():
	if whack_sounds.size() == 0:
		return

	var index = randi() % whack_sounds.size()
	whack_audio_player.stream = whack_sounds[index]
	whack_audio_player.play()
		
func _physics_process(delta):
	get_input()
	dash()
	move_and_slide()
	# FOOTSTEP TRIGGER LOGIC
	if not dashing and velocity.length() > 0:
		var moved = global_position.distance_to(last_position)
		distance_traveled += moved
		last_position = global_position

		if distance_traveled >= step_distance:
			play_footstep()
			distance_traveled = 0.0

func _on_stick_body_entered(body: Node2D) -> void:
	if body.is_in_group("Creature"):
		body.queue_free()
		
func create_soil():
	var areas = interaction_area.get_overlapping_areas()
	if areas.size() > 0:
		return # No planting on interaction objects
	
	var pos: Vector2 = global_position
	var crop_instance: Node2D = crop_scene.instantiate()
	get_tree().root.add_child(crop_instance)
	crop_instance.global_position = pos + Vector2(0.0, 0.0)
	crop_instance.scale = Vector2(1.0, 1.0)*18

func plant():
	var current_amount = hud_toolbar.get_current_item_amount()
	if  current_amount< 1:
		return
	
	var areas = interaction_area.get_overlapping_areas()
	if areas.size() == 0:
		return
	var sort_by_distance = func (a: Area2D, b: Area2D):
		return a.global_position.distance_squared_to(self.global_position) < b.global_position.distance_squared_to(self.global_position)
	areas.sort_custom(sort_by_distance)
	var closest_area_parent = areas[0].get_parent()
	if closest_area_parent.is_in_group("farm_plot") && !closest_area_parent.planted:
		closest_area_parent.sow()
		hud_toolbar.set_current_item_amount(current_amount-1)
	

func place_fence():
	var pos: Vector2 = global_position
	var fence: Node2D = fence_sceneLR.instantiate()
	if last_direction.x != 0:
		fence = fence_sceneLR.instantiate()
	elif last_direction.y != 0:
		fence = fence_sceneUD.instantiate()
	else:
		fence = fence_sceneLR.instantiate()
	fence.global_position = pos + Vector2(0.0, 0.0)
	var nav_region = get_tree().root.get_node("Main/NavigationRegion")
	nav_region.add_child(fence)
	nav_region.bake_navigation_polygon(true)
	
func place_trap():
	var pos: Vector2 = global_position
	var trap: Node2D = trap_scene.instantiate()
	get_tree().root.add_child(trap)
	trap.global_position = pos + Vector2(0.0, 0.0)
	trap.scale = Vector2(1.0, 1.0)	
	
func place_totem():
	var pos: Vector2 = global_position
	var totem: Node2D = totem_scene.instantiate()
	get_tree().root.add_child(totem)
	totem.global_position = pos + Vector2(0.0, 0.0)
	totem.scale = Vector2(1.0, 1.0)*2
	var nav_region = get_tree().root.get_node("Main/NavigationRegion")
	nav_region.add_child(totem)
	nav_region.bake_navigation_polygon(true)
	
func _on_update_selected_item(item):
	currentItem = item
