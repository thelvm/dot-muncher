# Controls the enemy's state in a game.
extends Node

# Signal emitted when the enemy's state changes.
signal state_changed(new_state: int)

@export var levels_parameters: Array[LevelParameters]

# Timers for the different states.
var hunt_timer: Timer
var scatter_timer: Timer
var panic_timer: Timer

# Initialization function. Sets up the timers and starts the scatter timer.
func _ready() -> void:
	assert(levels_parameters.size() > 0)
	configure_level()
	scatter_timer.start()


# Starts the panic state.
func start_panic() -> void:
	panic_timer.start()
	state_changed.emit(EnemyController.STATE_PANIC)


func configure_level() -> void:
	hunt_timer = Timer.new()
	hunt_timer.one_shot = true
	hunt_timer.wait_time = levels_parameters[0].hunt_time
	hunt_timer.timeout.connect(_on_hunt_timer_timeout)
	add_child(hunt_timer)
	
	scatter_timer = Timer.new()
	scatter_timer.one_shot = true
	scatter_timer.wait_time = levels_parameters[0].scatter_time
	scatter_timer.timeout.connect(_on_scatter_timer_timeout)
	add_child(scatter_timer)
	
	panic_timer = Timer.new()
	panic_timer.one_shot = true
	panic_timer.wait_time = levels_parameters[0].panic_time
	panic_timer.timeout.connect(_on_panic_timer_timeout)
	add_child(panic_timer)


# Callback for when the hunt timer times out. Starts the scatter state.
func _on_hunt_timer_timeout() -> void:
	scatter_timer.start()
	state_changed.emit(EnemyController.STATE_SCATTER)

# Callback for when the scatter timer times out. Starts the hunt state.
func _on_scatter_timer_timeout() -> void:
	hunt_timer.start()
	state_changed.emit(EnemyController.STATE_HUNT)

# Callback for when the panic timer times out. Starts the hunt state.
func _on_panic_timer_timeout() -> void:
	hunt_timer.start()
	state_changed.emit(EnemyController.STATE_HUNT)
