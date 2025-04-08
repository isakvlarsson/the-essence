extends Control

@onready var time_label = $TimeLabel

var current_day = 1
var current_hour = 0

func _ready() -> void:
	update_time_text()

func _on_new_day(day: int) -> void:
	current_day = day
	update_time_text()


func _on_new_hour(hour: int) -> void:
	current_hour = hour
	update_time_text()

func update_time_text() -> void:
	time_label.text = "Hour %s of Day %s" % [current_hour, current_day]

	
