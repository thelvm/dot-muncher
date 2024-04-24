extends Node

signal requested_direction_changed(direction: Vector2)

@export var input_buffer_timeout_delay: float = 0.25

var _requested_direction: Vector2 = Vector2.ZERO: set = _set_requested_direction

@onready var input_buffer_timer: Timer = $InputBufferTimeout

func _unhandled_key_input(_event: InputEvent) -> void:
	if Input.is_action_pressed("UP"):
		_requested_direction = Vector2.UP
	elif Input.is_action_pressed("DOWN"):
		_requested_direction = Vector2.DOWN
	elif Input.is_action_pressed("LEFT"):
		_requested_direction = Vector2.LEFT
	elif Input.is_action_pressed("RIGHT"):
		_requested_direction = Vector2.RIGHT
	if _requested_direction != Vector2.ZERO:
		input_buffer_timer.start()

func _on_input_buffer_timeout() -> void:
	_requested_direction = Vector2.ZERO

func _set_requested_direction(new_value: Vector2) -> void:
	requested_direction_changed.emit(new_value)
	_requested_direction = new_value
