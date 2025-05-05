extends Node2D

func _ready():
	$TotemArea/TotemSprite.play("idle")
	await get_tree().create_timer(0.1).timeout
	check_overlapping()
	
func check_overlapping():
	for body in $TotemArea.get_overlapping_areas():
		if body.get_parent().is_in_group("farm_plot"):
			body.get_parent().is_protected = true
			
