extends Button
signal clicked

@export var id = 0
@export var item = ""
@export var amount = 0
@export var selected = false
@export var colorSelected: Color
@export var colorUnSelected: Color

@onready var background: ColorRect = $Background

func _ready() -> void:
	pressed.connect(on_pressed)
	
func _process(delta: float) -> void:
	if selected:
		background.color = colorSelected
	else:
		background.color = colorUnSelected


func on_pressed():
	clicked.emit(self)
	
func set_item(new_item: String, new_amount: int):
	item = new_item
	$CenterContainer/Label.text = item
	amount = new_amount


	
	
	
