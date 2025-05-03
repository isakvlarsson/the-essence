extends HBoxContainer

signal update_selected_item

@onready var slots = self.get_children()
var selectedSlotID = 0

func _ready() -> void:
	var sort_by_id = func (a, b):
			return a.id < b.id
	slots.sort_custom(sort_by_id)
	
	for s: Button in slots:
		s.connect("clicked", toolbar_slot_clicked)
	
	slots[0].set_item("stick", 1, false)
	slots[1].set_item("shovel", 1, false)
	slots[2].set_item("seeds", 10, true)
	slots[3].set_item("fence", 5, true)
	slots[4].set_item("trap", 5, true)
	slots[5].set_item("totem", 1, true)

func toolbar_slot_clicked(slot):
	slots[selectedSlotID].selected = false
	slot.selected = true
	selectedSlotID = slot.id
	update_selected_item.emit(slot.item)
	
func get_current_item_amount():
	return slots[selectedSlotID].amount

func set_current_item_amount(amount: int):
	slots[selectedSlotID].set_amount(amount)
