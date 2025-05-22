extends Node2D

@onready var plant: Node2D = $Plant
@onready var eat_timer := $Timer

@export var growth_level: float = 0.0 # From 0-1
@export var planted = false
@export var watered = false
@export var watered_modulate_color: Color = Color("b06841")
@export var plant_green_color: Color

@export var plant_type: String

var growth_per_day: float = 0.2 
var min_size: float = 0.2
var is_protected := false

func _ready() -> void:
	await get_tree().process_frame
	check_overlapping()
	if planted && plant_type != "":
		plant.visible = true
		match plant_type:
			"pumpkin": 
				$Plant/PumpkinSprite.visible = true
			"ice essence":
				$Plant/IceEssenceSprite.visible = true

func _process(delta: float) -> void:
	if planted:
		var color = plant_green_color
		color.s = 1-growth_level
		plant.modulate = color
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

func sow(seed_type: String):
	plant_type = seed_type
	planted = true
	plant.visible = true
	match seed_type:
		"pumpkin": 
			$Plant/PumpkinSprite.visible = true
		"ice essence":
			$Plant/IceEssenceSprite.visible = true

func water():
	watered = true
	
func is_harvestable():
	return growth_level >= 1.0

func harvest():
	planted = false
	growth_level = 0.0
	plant_green_color.s = 1.0
	plant.visible = false
	plant_type = ""
	plant.get_children().map(func(c): c.visible = false)


func _on_new_day(day: int) -> void:
	growth_tick()
	
func check_overlapping():
	for totem in get_tree().get_nodes_in_group("totem"):
		for body in totem.get_node("TotemArea").get_overlapping_areas():
			if body == self:
				totem.check_overlapping()
