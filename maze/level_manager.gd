extends Node

signal mode_changed(new_mode: int)

@export_range(0, 120) var hunt_duration: float = 20
@export_range(0, 120) var scatter_duration: float = 7

var hunt_timer: Timer
var scatter_timer: Timer


func _ready() -> void:
	hunt_timer = Timer.new()
	hunt_timer.one_shot = true
	hunt_timer.wait_time = hunt_duration
	hunt_timer.timeout.connect(_on_hunt_timer_timeout)
	add_child(hunt_timer)
	
	scatter_timer = Timer.new()
	scatter_timer.one_shot = true
	scatter_timer.wait_time = scatter_duration
	scatter_timer.timeout.connect(_on_scatter_timer_timeout)
	add_child(scatter_timer)
	
	scatter_timer.start()


func _on_hunt_timer_timeout() -> void:
	print("Scatter time!")
	scatter_timer.start()
	mode_changed.emit(EnemyController.MODE_SCATTER)


func _on_scatter_timer_timeout() -> void:
	print("Hunting time!")
	hunt_timer.start()
	mode_changed.emit(EnemyController.MODE_HUNT)
