extends Node2D

signal new_hour(hour: int)
signal new_day(day: int)

const seconds_per_hour: float = 1 # Real-world seconds per game-hour
var seconds_since_last_hour: float = 0
var hour = 0
var day = 1


func _process(delta: float) -> void:
	seconds_since_last_hour += delta
	if seconds_since_last_hour > seconds_per_hour:
		hour += 1
		seconds_since_last_hour -= seconds_per_hour
		if hour >= 24:
			hour %= 24
			day += 1
			new_day.emit(day)

		new_hour.emit(hour) 
		
		
		

	
