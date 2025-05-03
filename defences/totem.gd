extends Node2D

func _ready():
	$TotemArea/TotemSprite.play("idle")
	check_overlapping()
	
func check_overlapping():
	for body in $TotemArea.get_overlapping_bodies():
		if body.is_in_group("farm_plot"):
			body.is_protected = true
			
