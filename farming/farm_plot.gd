extends Node2D

@onready var plant: Node2D = $Plant
@onready var eat_timer := $Timer

@export var growth_level: float = 0.0 # From 0-1
@export var planted = false
var growth_per_day: float = 0.2 
var min_size: float = 0.2
var eating_creatures := []

func _ready() -> void:
	sow()
	eat_timer = Timer.new()
	eat_timer.wait_time = 2.0
	eat_timer.one_shot = false
	add_child(eat_timer)
	eat_timer.connect("timeout", Callable(self, "_on_eat_timeout"))

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
