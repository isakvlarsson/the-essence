extends Node2D
var readyToTrap = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Creature") and readyToTrap:
		readyToTrap = false
		body.queue_free()
		$TrapArea/TrapSprite.frame = 1
		await get_tree().create_timer(5).timeout 
		$TrapArea/TrapSprite.frame = 0
		readyToTrap = true
