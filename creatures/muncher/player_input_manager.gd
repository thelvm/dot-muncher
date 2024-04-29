extends Node

signal requested_direction_changed(direction: Vector2)

var _requested_direction: Vector2 = Vector2.ZERO: set = _set_requested_direction


func _unhandled_key_input(_event: InputEvent) -> void:
	if _event.is_action_pressed("UP"):
		_requested_direction = Vector2.UP
	elif _event.is_action_pressed("DOWN"):
		_requested_direction = Vector2.DOWN
	elif _event.is_action_pressed("LEFT"):
		_requested_direction = Vector2.LEFT
	elif _event.is_action_pressed("RIGHT"):
		_requested_direction = Vector2.RIGHT

	if _event.is_action_released("UP") and _requested_direction == Vector2.UP:
		_requested_direction = Vector2.ZERO
	elif _event.is_action_released("DOWN") and _requested_direction == Vector2.DOWN:
		_requested_direction = Vector2.ZERO
	elif _event.is_action_released("LEFT") and _requested_direction == Vector2.LEFT:
		_requested_direction = Vector2.ZERO
	elif _event.is_action_released("RIGHT") and _requested_direction == Vector2.RIGHT:
		_requested_direction = Vector2.ZERO


func _set_requested_direction(new_value: Vector2) -> void:
	requested_direction_changed.emit(new_value)
	_requested_direction = new_value
