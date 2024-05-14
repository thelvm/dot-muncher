## Direction bitmasks made easy
class_name DirectionMask extends RefCounted

const NONE = 0b0000
const UP = 0b0001
const RIGHT = 0b0010
const DOWN = 0b0100
const LEFT = 0b1000

@export_flags("UP:1", "RIGHT:2", "DOWN:4", "LEFT:8") var bitmask: int = 0

func _init(from: Variant = null) -> void:
	if from is Vector2:
		bitmask = DirectionMask.vector2_to_bitmask(from)
		return
	if from is DirectionMask:
		bitmask = from.bitmask
		return
	if from is int:
		if 0 < from and from <= 0b1111:
			bitmask = from


static func vector2_to_bitmask(from: Vector2) -> int:
	var new_bitmask := 0
	new_bitmask += UP if from.y < 0 else 0
	new_bitmask += RIGHT if from.x > 0 else 0
	new_bitmask += DOWN if from.y > 0 else 0
	new_bitmask += LEFT if from.x < 0 else 0
	return new_bitmask


## Checks if direction(s) bit is set in the mask.
func has_direction(direction: Variant) -> bool:
	if direction is int:
		return (bitmask & direction) > 0
	if direction is Vector2:
		return (bitmask & DirectionMask.vector2_to_bitmask(direction)) > 0
	return false


func add_direction(direction: Variant) -> void:
	if direction is int:
		if 0 < direction and direction <= 0b1111:
			bitmask |= direction
	if direction is Vector2:
		bitmask |= DirectionMask.vector2_to_bitmask(direction)


func remove_direction(direction: Variant) -> void:
	if direction is int:
		if 0 < direction and direction <= 0b1111:
			bitmask &= ~direction
	if direction is Vector2:
		bitmask &= ~DirectionMask.vector2_to_bitmask(direction)


func to_vector2() -> Vector2:
		var direction := Vector2.ZERO
		if has_direction(UP):
			direction.y -= 1
		if has_direction(DOWN):
			direction.y += 1
		if has_direction(LEFT):
			direction.x -= 1
		if has_direction(RIGHT):
			direction.x += 1
		return direction


## Returns true is direction is the oppposite of this direction.
## Always returns false if either masks contains more than one direction
func is_opposite(direction: int) -> bool:
	return (direction == UP and bitmask == DOWN) or (bitmask == UP and direction == DOWN) or (direction == LEFT and bitmask == RIGHT) or (bitmask == LEFT and direction == RIGHT)
