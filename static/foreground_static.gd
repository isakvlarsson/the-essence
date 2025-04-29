extends Node2D

@onready var portal = $Portal;
@onready var portal2 = $Portal2;

func _ready():
	#dummy function call just to test the animation
	portal2.activate_ice_portal()
