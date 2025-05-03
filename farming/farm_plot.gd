extends Node2D

@onready var plant: Node2D = $Plant
@onready var eat_timer := $Timer

@export var growth_level: float = 0.0 # From 0-1
@export var planted = false
var growth_per_day: float = 0.2 
var min_size: float = 0.2
var is_protected := false

func _ready() -> void:
	print(get_tree())
	for totem in get_tree().get_nodes_in_group("totem"):
		for body in totem.get_overlapping_bodies():
			if body == self:
				totem.check_overlapping()

func _process(delta: float) -> void:
	if planted:
		plant.scale = Vector2(growth_level, growth_level)
	else:
		plant.visible = false
		
func growth_tick():
	if planted:
		growth_level += growth_per_day
		growth_level = clamp(growth_level, 0.0, 1.0)

func sow():
	planted = true
	plant.visible = true

func is_harvestable():
	if growth_level >= 1.0:
		return true
	else:
		return false

func _on_new_day(day: int) -> void:
	growth_tick()
