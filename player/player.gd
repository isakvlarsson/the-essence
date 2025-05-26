extends CharacterBody2D

@onready var crop_scene = preload("res://farming/farm_plot.tscn") 
@onready var fence_sceneLR = preload("res://defences/fence_lr.tscn") 
@onready var fence_sceneUD = preload("res://defences/fence_ud.tscn") 
@onready var trap_scene = preload("res://defences/trap.tscn") 
@onready var totem_scene = preload("res://defences/totem.tscn") 
@onready var interaction_area: Area2D = $InteractionBox
@onready var hud_toolbar = %HUD/ToolBar
@onready var day_night_handler = %DayNightHandler

var can_interact = true

var speed = 400
var canDash = true
var dashing = false
var whacking = false
var facing
var dashSpeed = 1200
var dashDirection = Vector2.ZERO
var input_direction = Vector2.ZERO
var last_direction = Vector2.ZERO
var current_realm: String

# --- FOOTSTEP STUFF ---
@export var footstep_sounds: Array[AudioStream] = []
var last_index := -1
@onready var audio_player := $FootstepPlayer
var step_distance := 30.0
var distance_traveled := 0.0
var last_position := Vector2.ZERO

# --- WHACK SOUND STUFF ---
@export var whack_sounds: Array[AudioStream] = []  # Array for whack sounds
@onready var whack_audio_player := $WhackPlayer  # WhackPlayer node for whack sounds
var currentItem = "Stick"

# --- PLANT SOUND STUFF ---
@export var plant_sound: AudioStream  # Declaring AudioStream for the plant to player
@onready var plant_audio_player := $PlantPlayer  # Audio player for planting

# --- SHOVELING SOUND STUFF ---
@export var shoveling_sound: AudioStream  # Declaring AudioStream for the shoveling to player
@onready var shoveling_audio_player := $ShovelingPlayer  # Audio player for shoveling

# --- HARVESTING SOUND STUFF ---
@export var harvesting_sound: AudioStream  # Declaring AudioStream for the harvesting to player
@onready var harvesting_audio_player := $HarvestingPlayer  # Audio player for harvesting

# --- WATERING SOUND STUFF ---
@export var watering_sound: AudioStream  # Declaring AudioStream for the watering to player
@onready var watering_audio_player := $WateringPlayer  # Audio player for watering

# --- FENCE SOUND STUFF ---
@export var fence_sound: AudioStream  # Declaring AudioStream for the fence to player
@onready var fence_audio_player := $FencePlayer  # Audio player for fence

# --- TOTEM SOUND STUFF ---
@export var totem_sound: AudioStream  # Declaring AudioStream for the totem to player
@onready var totem_audio_player := $TotemPlayer  # Audio player for totem

# --- PORTAL SOUND STUFF ---
@onready var portal_audio_player := $PortalSoundPlayer
var portal_pos = Vector2(-650, 1700)  # Hardcoded portal position
var max_portal_distance = 1500.0       # Max distance where sound plays
var min_portal_distance = 50.0        # Min distance for max volume
var portal_is_activated = false
func _ready():
	last_position = global_position
	hud_toolbar.connect("update_selected_item", _on_update_selected_item)
	current_realm = "swamp"

func get_input():
	if not dashing and not whacking:
		input_direction = Input.get_vector("left", "right", "up", "down")
		if input_direction != Vector2.ZERO:
			last_direction = input_direction
		velocity = input_direction * speed
		dashDirection = input_direction
		walk()
		if(velocity.length() == 0 and not whacking):
			$Animations.play("default")
			if(last_direction.x > 0  or last_direction.y > 0):
				$Animations.flip_h = false
			else:
				$Animations.flip_h = true
			$AnimationPlayer.stop()

func _input(event):
	if event.is_action_pressed("whack"):
		if !can_interact or dashing or whacking:
			return
		can_interact = false
		match currentItem:
			"stick": 
				whack()
			"seeds":
				plant()
				play_plant_sound()  # Play the plant sound after planting
			"shovel":
				create_soil()
				play_shoveling_sound()
			"fence":
				place_fence()
				play_fence_sound()
			"bucket":
				water_plant()
				play_watering_sound()
			"totem":
				place_totem()
				play_totem_sound()
			"trap":
				place_trap()
				play_totem_sound()
		await get_tree().create_timer(0.1).timeout
		can_interact = true
	if Input.is_action_pressed("increment_selected_slot"):
		hud_toolbar.set_current_slot((hud_toolbar.selectedSlotID + 1)%10)
	if Input.is_action_pressed("decrement_selected_slot"):
		hud_toolbar.set_current_slot((hud_toolbar.selectedSlotID + -1)%10)
	if event.is_action_pressed("select_toolbar_slot"):
		match event.keycode:
			KEY_1:
				hud_toolbar.set_current_slot(0)
			KEY_2:
				hud_toolbar.set_current_slot(1)
			KEY_3:
				hud_toolbar.set_current_slot(2)
			KEY_4:
				hud_toolbar.set_current_slot(3)
			KEY_5:
				hud_toolbar.set_current_slot(4)
			KEY_6:
				hud_toolbar.set_current_slot(5)
			KEY_7:
				hud_toolbar.set_current_slot(6)
			KEY_8:
				hud_toolbar.set_current_slot(7)
			KEY_9:
				hud_toolbar.set_current_slot(8)
			KEY_0:
				hud_toolbar.set_current_slot(9)
	if Input.is_action_just_pressed("interact"):
		interact()
func dash():
	if Input.is_action_just_pressed("dash") and canDash and dashDirection != Vector2.ZERO:
		velocity = dashDirection.normalized()*dashSpeed
		canDash = false
		dashing = true
		$Animations.play("dash")
		#dash for 0.2 seconds
		await get_tree().create_timer(0.2).timeout 
		dashing = false
		
		#Able to dash again after 1 second
		await get_tree().create_timer(1.0).timeout
		canDash = true
		
func whack():
	whacking = true
	if(last_direction.x > 0 or last_direction.y > 0):
		$Animations.flip_h = false
		facing = "R"
	else:
		$Animations.flip_h = true
		facing = "L"
	velocity = Vector2.ZERO
	$Animations.play("whack")
	await get_tree().create_timer(0.3).timeout
	if facing == "R":
		$stick/stickShapeR.disabled = false
	else:
		$stick/stickShapeL.disabled = false
	await get_tree().create_timer(0.2).timeout
	$stick/stickShapeR.disabled = true
	$stick/stickShapeL.disabled = true
	whacking = false
	play_whack_sound() # Play whack sound when whack animation is triggered

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

func play_plant_sound():
	if plant_sound == null:
		return
	plant_audio_player.stream = plant_sound
	plant_audio_player.pitch_scale = randf_range(0.95, 1.05)  # A small pitch variation
	plant_audio_player.play()

func play_shoveling_sound():
	if shoveling_sound == null:
		return
	shoveling_audio_player.stream = shoveling_sound
	shoveling_audio_player.pitch_scale = randf_range(0.95, 1.05)  # A small pitch variation
	shoveling_audio_player.play()

func play_harvesting_sound():
	if harvesting_sound == null:
		return
	harvesting_audio_player.stream = harvesting_sound
	harvesting_audio_player.pitch_scale = randf_range(0.95, 1.05)  # A small pitch variation
	harvesting_audio_player.play()

func play_watering_sound():
	if watering_sound == null:
		return
	watering_audio_player.stream = watering_sound
	watering_audio_player.pitch_scale = randf_range(0.95, 1.05)  # A small pitch variation
	watering_audio_player.play()

func play_fence_sound():
	if fence_sound == null:
		return
	fence_audio_player.stream = fence_sound
	fence_audio_player.pitch_scale = randf_range(0.95, 1.05)  # A small pitch variation
	fence_audio_player.play()

func play_totem_sound():
	if totem_sound == null:
		return
	totem_audio_player.stream = totem_sound
	totem_audio_player.pitch_scale = randf_range(0.95, 1.05)  # A small pitch variation
	totem_audio_player.play()

func update_portal_sound():
	var dist = global_position.distance_to(portal_pos)
	
	if dist < max_portal_distance and portal_is_activated:
		if not portal_audio_player.playing:
			portal_audio_player.play()
		
		var volume = 1.0 - clamp((dist - min_portal_distance) / (max_portal_distance - min_portal_distance), 0, 1)
		portal_audio_player.volume_db = linear_to_db(volume)
	else:
		if portal_audio_player.playing:
			portal_audio_player.stop()
		
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

	# Update portal sound volume based on distance
	update_portal_sound()

func _on_stick_body_entered(body: Node2D) -> void:
	if body.is_in_group("Creature"):
		if body.has_method("play_hit_sound_and_die"):
			body.play_hit_sound_and_die()
		
func create_soil():
	var areas = interaction_area.get_overlapping_areas()
	if areas.size() > 0:
		return # No planting on interaction objects
	
	var pos: Vector2 = global_position
	var crop_instance: Node2D = crop_scene.instantiate()
	get_tree().root.add_child(crop_instance)
	crop_instance.global_position = pos + Vector2(0.0, 0.0)
	crop_instance.scale = Vector2(1.0, 1.0)*18
	crop_instance.realm = current_realm

func plant():
	var current_amount = hud_toolbar.get_current_item_amount()
	if  current_amount< 1:
		return
	
	var closest_area = get_closest_area()
	if closest_area == null:
		return
	var closest_area_parent = closest_area.get_parent()
	if closest_area_parent.is_in_group("farm_plot") && !closest_area_parent.planted:
		if closest_area_parent.realm == "swamp":
			closest_area_parent.sow("pumpkin")
		elif closest_area_parent.realm == "ice":
			closest_area_parent.sow("iceberg lettuce")
		
		hud_toolbar.set_current_item_amount(current_amount-1)
	

func place_fence():
	var current_amount = hud_toolbar.get_current_item_amount()
	if current_amount <= 0:
		return
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
	hud_toolbar.set_current_item_amount(current_amount-1)
	
func place_trap():
	var current_amount = hud_toolbar.get_current_item_amount()
	if current_amount <= 0:
		return
	var pos: Vector2 = global_position
	var trap: Node2D = trap_scene.instantiate()
	get_tree().root.add_child(trap)
	trap.global_position = pos + Vector2(0.0, 0.0)
	trap.scale = Vector2(1.0, 1.0) * 2
	hud_toolbar.set_current_item_amount(current_amount-1)
	
func place_totem():
	var current_amount = hud_toolbar.get_current_item_amount()
	if current_amount <= 0:
		return
	var pos: Vector2 = global_position
	var totem: Node2D = totem_scene.instantiate()
	get_tree().root.add_child(totem)
	totem.global_position = pos + Vector2(0.0, 0.0)
	totem.scale = Vector2(1.0, 1.0) * 3
	var nav_region = get_tree().root.get_node("Main/NavigationRegion")
	nav_region.add_child(totem)
	nav_region.bake_navigation_polygon(true)
	hud_toolbar.set_current_item_amount(current_amount-1)

func water_plant():
	var closest_area = get_closest_area()
	if closest_area == null:
		return
	var closest_area_parent = closest_area.get_parent()
	if closest_area_parent.is_in_group("farm_plot"):
		closest_area_parent.water()
	
func _on_update_selected_item(item):
	currentItem = item

func get_closest_area() -> Area2D:
	var areas = interaction_area.get_overlapping_areas()
	if areas.size() == 0:
		return null
	var sort_by_distance = func (a: Area2D, b: Area2D):
		return a.global_position.distance_squared_to(self.global_position) < b.global_position.distance_squared_to(self.global_position)
	areas.sort_custom(sort_by_distance)
	return areas[0]

func get_current_areas_by_distance():
	var areas = interaction_area.get_overlapping_areas()
	if areas.size() == 0:
		return []
	var sort_by_distance = func (a: Area2D, b: Area2D):
		return a.global_position.distance_squared_to(self.global_position) < b.global_position.distance_squared_to(self.global_position)
	areas.sort_custom(sort_by_distance)
	return areas
	
func interact():
	var areas = get_current_areas_by_distance()
	if areas.size() == 0:
		return
	for a in areas:
		var parent = a.get_parent()
		if parent.is_in_group("farm_plot") && parent.is_harvestable():
			harvest_plant(parent)
			return
		elif parent.is_in_group("altar"):
			if parent.try_sacrifice(hud_toolbar.get_current_item_name(), hud_toolbar.get_current_item_amount()):
				hud_toolbar.set_current_item_amount(hud_toolbar.get_current_item_amount() - parent.current_sacrifice_amount)
				portal_is_activated = true
		elif parent.is_in_group("interactible"):
			parent.interact(self)
			

func harvest_plant(node: Node2D):
	var plant_type = node.plant_type
	var plant_amount = hud_toolbar.get_item_amount(plant_type)
	hud_toolbar.set_item_amount(plant_type, plant_amount + 1)
	node.harvest()
	play_harvesting_sound()
		
func walk():
	if(velocity.x < 0 or velocity.y < 0):
		$Animations.flip_h = false
	if(velocity.x > 0 or velocity.y > 0):
		$Animations.flip_h = true
	$Animations.play("walk")
	
