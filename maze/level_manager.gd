# Controls the enemy's state in a game.
extends Node

# Signal emitted when the enemy's state changes.
signal state_changed(new_state: int)

# The duration of the hunting state in seconds. Can be set between 0 and 120 in the editor.
@export_range(0, 120) var hunt_duration: float = 20

# The duration of the scattering state in seconds. Can be set between 0 and 120 in the editor.
@export_range(0, 120) var scatter_duration: float = 7

# The duration of the panic state in seconds. Can be set between 0 and 120 in the editor.
@export_range(0, 120) var panic_duration: float = 7

# Timers for the different states.
var hunt_timer: Timer
var scatter_timer: Timer
var panic_timer: Timer

# Initialization function. Sets up the timers and starts the scatter timer.
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

	panic_timer = Timer.new()
	panic_timer.one_shot = true
	panic_timer.wait_time = panic_duration
	panic_timer.timeout.connect(_on_panic_timer_timeout)
	add_child(panic_timer)

# Starts the panic state.
func start_panic() -> void:
	panic_timer.start()
	state_changed.emit(EnemyController.STATE_PANIC)

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
