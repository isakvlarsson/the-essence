extends Node2D

@onready var portal = $Portal;

func _ready():
    #dummy function call just to test the animation
    portal.activate_ice_portal()
