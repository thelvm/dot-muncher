extends Node2D

@onready var buffer_timeout = $DirectionBufferTimeout
var direction_buffer_pending: bool = false

var requested_direction: Vector2 = Vector2.ZERO: set = _set_requested_direction
signal direction_change_requested(direction: Vector2)

func _unhandled_key_input(_event):
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
		buffer_timeout.start()

func _on_direction_buffer_timeout_timeout():
	requested_direction = Vector2.ZERO

func _set_requested_direction(new_value):
	direction_change_requested.emit(new_value)
