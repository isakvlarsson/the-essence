extends Node2D

@onready var icePortalOnSwamp = $Portal;
@onready var swampPortalOnIce = $Portal2;

func _ready():
	#dummy function call just to test the animation
	icePortalOnSwamp.activate_ice_portal();
	swampPortalOnIce.activate_swamp_portal();
	swampPortalOnIce.assign_destination(icePortalOnSwamp);
	icePortalOnSwamp.assign_destination(swampPortalOnIce);
