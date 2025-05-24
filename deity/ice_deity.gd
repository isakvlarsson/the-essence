extends Sprite2D

var DeityStates = {
	"APPEAR": "APPEAR",
	"TALK": "TALK",
	"DISSAPEAR": "DISSAPEAR"
}
var current_state = DeityStates.TALK
@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	# Start with the inactive animation or first frame
	animated_sprite.play(current_state)

func _process(delta):
	animated_sprite.play(current_state)

func start_deity_talk():
	current_state = DeityStates.TALK

func wake_deity():
	current_state = DeityStates.APPEAR

func hide_deity():
	current_state = DeityStates.DISSAPEAR
