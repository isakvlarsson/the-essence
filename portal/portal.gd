extends Node2D

enum PortalStates {IDLE, FIRE, ICE, SWAMP, WATER}
var current_state = PortalStates.IDLE
@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	# Start with the inactive animation or first frame
	animated_sprite.play("Default")

func _process(delta):
	match current_state:
		PortalStates.IDLE:
			$AnimatedSprite2D.play("Default")
		PortalStates.FIRE:
			$AnimatedSprite2D.play("fire")
		PortalStates.ICE:
			$AnimatedSprite2D.play("ice")
		PortalStates.SWAMP:
			$AnimatedSprite2D.play("swamp")
		PortalStates.WATER:
			$AnimatedSprite2D.play("water")

func activate_ice_portal():
	current_state = PortalStates.ICE

func activate_fire_portal():
	current_state = PortalStates.FIRE

func activate_swamp_portal():
	current_state = PortalStates.SWAMP

func activate_water_portal():
	current_state = PortalStates.WATER
