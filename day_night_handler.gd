extends Node2D

signal new_hour(hour: int)
signal new_day(day: int)

@onready var goblin_scene = preload("res://creatures/goblin/goblin.tscn")

const seconds_per_hour: float = 1 # Real-world seconds per game-hour
var seconds_since_last_hour: float = 0
var hour = 0
var day = 1


func _process(delta: float) -> void:
	seconds_since_last_hour += delta
	if seconds_since_last_hour > seconds_per_hour:
		hour += 1
		seconds_since_last_hour -= seconds_per_hour
		if hour >= 24:
			hour %= 24
			day += 1
			new_day.emit(day)
			# Find all farm plots and grow them
			get_tree().call_group("farm_plot", "growth_tick")

		new_hour.emit(hour) 
		if hour == 0:
			spawn_goblins()
		

func spawn_goblins():
	var spawn_points: Array[Node] = get_tree().get_nodes_in_group("creature_spawn_point")
	var farm_plots: Array[Node] = get_tree().get_nodes_in_group("farm_plot")
	
	if farm_plots.size() < 1:
		pass
		
	for i in range(0, 5):
		var goblin: CharacterBody2D = goblin_scene.instantiate()
		goblin.target_to_chase = farm_plots.pick_random()
		goblin.position = spawn_points.pick_random().position
		get_tree().root.add_child(goblin)
		
		

	
