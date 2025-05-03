extends Button
signal clicked

@export var id = 0
@export var item = ""
@export var countable_item = false
@export var amount = 0
@export var selected = false
@export var colorSelected: Color
@export var colorUnSelected: Color

@onready var background: ColorRect = $Background

func _ready() -> void:
	pressed.connect(on_pressed)
	if item == "":
		set_item("", 0, false)
	
func _process(delta: float) -> void:
	if selected:
		background.color = colorSelected
	else:
		background.color = colorUnSelected


func on_pressed():
	clicked.emit(self)
	
func set_item(new_item: String, new_amount: int, countable: bool):
	if new_item == "":
		$Amount.visible = false
		$CenterContainer.visible = false
	else:
		item = new_item
		$CenterContainer/Label.text = item
		$CenterContainer.visible = true
		if countable:
			set_amount(new_amount)
		else:
			$Amount.visible = false

func set_amount(new_amount: int):
	amount = new_amount
	if amount == 0:
		$Amount.visible = false
		$CenterContainer.visible = false
	else:
		$Amount.text = str(amount)
		$Amount.visible = true
		$CenterContainer.visible = true
	
	
	
	
