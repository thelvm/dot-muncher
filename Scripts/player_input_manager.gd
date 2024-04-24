extends Node

@export var input_buffer_timeout_delay: float = 0.25
@onready var input_buffer_timer: Timer = $InputBufferTimeout
var direction_buffer_pending: bool = false

var requested_direction: Vector2 = Vector2.ZERO: set = _set_requested_direction

signal direction_change_requested(direction: Vector2)

func _unhandled_key_input(_event: InputEvent) -> void:
	if Input.is_action_pressed("UP"):
		requested_direction = Vector2.UP
	elif Input.is_action_pressed("DOWN"):
		requested_direction = Vector2.DOWN
	elif Input.is_action_pressed("LEFT"):
		requested_direction = Vector2.LEFT
	elif Input.is_action_pressed("RIGHT"):
		requested_direction = Vector2.RIGHT
	if requested_direction != Vector2.ZERO:
		direction_buffer_pending = true
		input_buffer_timer.start()

func _on_input_buffer_timeout() -> void:
	requested_direction = Vector2.ZERO

func _set_requested_direction(new_value: Vector2) -> void:
	direction_change_requested.emit(new_value)
	requested_direction = new_value
