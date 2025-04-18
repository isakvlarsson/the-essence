extends Node2D

@onready var plant: Node2D = $Plant

@export var growth_level: float = 0.0 # From 0-1
@export var planted = false
var growth_per_day: float = 0.2 

func _ready() -> void:
	sow()

func _process(delta: float) -> void:
	if planted:
		plant.scale = Vector2(growth_level, growth_level)
	else:
		plant.visible = false
		
func growth_tick():
	if planted:
		growth_level += growth_per_day
		clamp(growth_level, 0.0, 1.0)

func sow():
	planted = true
	plant.visible = true


func _on_new_day(day: int) -> void:
	growth_tick()
