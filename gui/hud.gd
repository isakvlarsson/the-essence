extends CanvasLayer

@onready var time_label = $TimeLabel
@onready var day_night_handler = %DayNightHandler
var current_day = 1
var current_hour = 8

func _ready() -> void:
	day_night_handler.connect("new_day", _on_new_day)
	day_night_handler.connect("new_hour", _on_new_hour)
	update_time_text()

func _on_new_day(day: int) -> void:
	current_day = day
	update_time_text()


func _on_new_hour(hour: int) -> void:
	current_hour = hour
	update_time_text()

func update_time_text() -> void:
	time_label.text = "Hour %s of Day %s" % [current_hour, current_day]

	
