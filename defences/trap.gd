extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Creature"):
		body.queue_free()
		$Area2D/TrapSprite.frame = 1
		await get_tree().create_timer(5).timeout 
		$Area2D/TrapSprite.frame = 0
