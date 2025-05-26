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
	slots[2].set_item("bucket", 1, false)
	slots[3].set_item("seeds", 6, true)
	slots[4].set_item("fence", 4, true)
	slots[5].set_item("trap", 2, true)
	slots[6].set_item("totem", 0, true)
	slots[7].set_item("pumpkin", 0, true)
	slots[8].set_item("ice essence", 0, true)
	slots[9].set_item("iceberg lettuce", 0, true)

func toolbar_slot_clicked(slot):
	slots[selectedSlotID].selected = false
	slot.selected = true
	selectedSlotID = slot.id
	update_selected_item.emit(slot.item)

func set_current_slot(id: int):
	slots[selectedSlotID].selected = false
	slots[id].selected = true
	selectedSlotID = id
	update_selected_item.emit(slots[id].item)
	
func get_current_item_amount():
	return slots[selectedSlotID].amount

func set_current_item_amount(amount: int):
	slots[selectedSlotID].set_amount(amount)

func get_item_amount(item_name: String) -> int:
	var is_item = func (i):
		return i.item == item_name
	var index = slots.find_custom(is_item)
	return slots[index].amount

func set_item_amount(item_name: String, amount: int):
	var is_item = func (i):
		return i.item == item_name
	var index = slots.find_custom(is_item)
	slots[index].set_amount(amount)
	
func get_current_item_name() -> String:
	return slots[selectedSlotID].item
