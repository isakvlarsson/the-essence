extends Node2D

signal new_hour(hour: int)
signal new_day(day: int)

@onready var goblin_scene = preload("res://creatures/goblin/goblin.tscn")

const seconds_per_hour: float = (15.0*60.0)/24.0 # 20*60/24 = 1200/24 seconds/hour  # Real-world seconds per game-hour
var seconds_since_last_hour: float = 0
var hour = 8
var day = 1

func _ready() -> void:
	new_hour.connect(on_new_hour)

func _process(delta: float) -> void:
	seconds_since_last_hour += delta
	if seconds_since_last_hour > seconds_per_hour:
		hour += 1
		seconds_since_last_hour -= seconds_per_hour
		new_hour.emit(hour) 
	
func on_new_hour(new_hour: int):
	if hour == 0 and day%3 == 0:
		spawn_goblins()
	
	if hour == 18:
		var tween = create_tween()
		tween.tween_property($"../CanvasModulate", "color", Color.BLACK, 16)
		await get_tree().create_timer(8).timeout
		if tween:
			tween.kill()
	if hour == 3:
		var tween2 = create_tween()
		tween2.tween_property($"../CanvasModulate", "color", Color.WHITE, 8)
		await get_tree().create_timer(8).timeout
		if tween2:
				tween2.kill()
	if hour >= 24:
		hour %= 24
		day += 1
		new_day.emit(day)
		# Find all farm plots and grow them
		get_tree().call_group("farm_plot", "growth_tick")

		
func spawn_goblins():
	var swamp_spawn_point = $"../CreatureSpawnPointSwamp"
	var ice_spawn_point = $"../CreatureSpawnPointIce"
	
	var swamp_plots = get_tree().get_nodes_in_group("farm_plot").filter(
	func(plant): 
		return not plant.is_protected and (plant.realm == "swamp")
	)
	
	var ice_plots = get_tree().get_nodes_in_group("farm_plot").filter(
	func(plant): 
		return not plant.is_protected and (plant.realm == "ice")
	)

	for i in range(0, floor(swamp_plots.size()/3)):
		var goblin: CharacterBody2D = goblin_scene.instantiate()
		goblin.target_to_chase = swamp_plots.pick_random()
		goblin.position = swamp_spawn_point.position
		goblin.scale = Vector2(1.0, 1.0)*1.7
		get_tree().root.add_child(goblin)
	
	for i in range(0, floor(ice_plots.size()/3)):
		var goblin: CharacterBody2D = goblin_scene.instantiate()
		goblin.target_to_chase = ice_plots.pick_random()
		goblin.position = ice_spawn_point.position
		goblin.scale = Vector2(1.0, 1.0)*1.7
		get_tree().root.add_child(goblin)
		
func skip_time(hours: int):
	hour += hours
	seconds_since_last_hour = 0.0
	new_hour.emit(hour)
