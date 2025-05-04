extends Node2D

@onready var plant: Node2D = $Plant
@onready var eat_timer := $Timer

@export var growth_level: float = 0.0 # From 0-1
@export var planted = false
@export var watered = false
@export var watered_modulate_color: Color = Color("b06841")

var growth_per_day: float = 0.2 
var min_size: float = 0.2
var is_protected := false

func _ready() -> void:
	await get_tree().process_frame
	check_overlapping()

func _process(delta: float) -> void:
	if planted:
		plant.scale = Vector2(growth_level + 0.2, growth_level + 0.2)
	else:
		plant.visible = false
	
	if watered:
		$PlotMesh.self_modulate = watered_modulate_color
	else:
		$PlotMesh.self_modulate = Color("ffffff")
		
func growth_tick():
	if planted and watered:
		growth_level += growth_per_day
		growth_level = clamp(growth_level, 0.0, 1.0)
		watered = false

func sow():
	planted = true
	plant.visible = true

func water():
	watered = true
	
func is_harvestable():
	if growth_level >= 1.0:
		return true
	else:
		return false

func _on_new_day(day: int) -> void:
	growth_tick()
	
func check_overlapping():
	for totem in get_tree().get_nodes_in_group("totem"):
		for body in totem.get_node("TotemArea").get_overlapping_areas():
			if body == self:
				totem.check_overlapping()
