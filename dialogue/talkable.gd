extends Area2D

@export var dialogue_resource : DialogueResource
@export var dialogue_start : String = "start"

var base_balloon

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func start_action():
	base_balloon = DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_start)

func stop_action():
	if base_balloon:
		base_balloon.queue_free()

func _on_body_entered(body):
	if body.name == "player":
		start_action()

func _on_body_exited(body):
	if body.name == "player":
		stop_action()
