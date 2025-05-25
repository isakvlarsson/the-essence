extends Node2D

enum PortalStates {IDLE, FIRE, ICE, SWAMP, WATER}
var current_state = PortalStates.IDLE
@export var destination: Node2D
@export var activated: bool = false
@onready var animated_sprite = $AnimatedSprite2D
var just_teleported: bool = false

func _ready():
	$InteractionBox.connect("body_entered", on_body_entered)
	$InteractionBox.connect("body_exited", on_body_exited)
	# Start with the inactive animation or first frame
	animated_sprite.play("Default")
	if activated:
		activate_ice_portal()

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
	activated = true

func activate_fire_portal():
	current_state = PortalStates.FIRE
	activated = true

func activate_swamp_portal():
	current_state = PortalStates.SWAMP
	activated = true

func activate_water_portal():
	current_state = PortalStates.WATER
	activated = true

func assign_destination(destNode):
	destination = destNode;

func on_body_entered(body: Node2D):
	if !body.is_in_group("player") or !activated or just_teleported:
		return
	
	# Teleport player
	body.global_position = destination.global_position
	destination.just_teleported = true
	if body.current_realm == "swamp":
		body.current_realm = "ice"
	else:
		body.current_realm = "swamp"
	
func on_body_exited(body: Node2D):
	if !body.is_in_group("player") or !activated:
		return
	
	just_teleported = false
	
