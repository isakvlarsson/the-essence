extends Node2D

var current_sacrifice_item = "ice essence"
var current_sacrifice_amount = 1
var completed_sacrifice = false

@export var glow_color: Color
@export var inactive_color: Color = Color("0000003d")

@export var portal: Node2D


func _ready() -> void:
	$KeyboardIcon.visible = false
	$SacrificeSprite.modulate = inactive_color
	$InteractionBox.connect("body_entered", on_body_entered)
	$InteractionBox.connect("body_exited", on_body_exited)

func on_body_entered(body: Node2D): 
	if !body.is_in_group("player"):
		return
	if !completed_sacrifice:
		$KeyboardIcon.visible = true
	if body.hud_toolbar.get_current_item_name() == current_sacrifice_item:
		$SacrificeSprite.modulate = glow_color

func on_body_exited(body: Node2D):
	if !body.is_in_group("player"):
		return
	$KeyboardIcon.visible = false
	if !completed_sacrifice:
		$SacrificeSprite.modulate = inactive_color

func try_sacrifice(item: String, amount: int) -> bool:
	if !completed_sacrifice and item == current_sacrifice_item and amount >= current_sacrifice_amount:
		portal.activate_ice_portal()
		completed_sacrifice = true
		return true
	else:
		return false
