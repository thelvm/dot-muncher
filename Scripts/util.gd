class_name Util

static func snap(value: float, snap_value: int , snap_mode: int = 0, offset: int = 0) -> float:
	var adjusted_value: int = int(value) - offset
	var remainder: int = adjusted_value % snap_value
	var rounded_value: int
	if snap_mode <= 0:
		rounded_value = adjusted_value - remainder
		if snap_mode == 0 and remainder >= snap_value / 2.0:
			rounded_value += snap_value
	elif snap_mode > 0:
		if remainder != 0:
			rounded_value = adjusted_value + (snap_value - remainder)
		else:
			rounded_value = adjusted_value

	return rounded_value + offset

static func get_first_ancestor_of_type(current: Node, type: Variant) -> Node:
	while current != null:
		if is_instance_of(current, type):
			return current
		current = current.get_parent()
	return null
