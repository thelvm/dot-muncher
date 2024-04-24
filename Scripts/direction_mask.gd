## Direction bitmasks made easy
class_name DirectionMask extends RefCounted

const NONE = 0b0000
const UP = 0b0001
const DOWN = 0b0010
const LEFT = 0b0100
const RIGHT = 0b1000

var bitmask: int = 0


## Checks if direction(s) bit is set in the mask.
func has_direction(direction: int) -> bool:
	return (bitmask & direction) > 0


func add_direction(direction: int) -> void:
	bitmask |= direction


func remove_direction(direction: int) -> void:
	bitmask &= ~direction


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


func from_vector2(vec: Vector2) -> int:
	bitmask = NONE
	if vec.y < 0:
		add_direction(UP)
	elif vec.y > 0:
		add_direction(DOWN)
	if vec.x > 0:
		add_direction(RIGHT)
	elif vec.x < 0:
		add_direction(LEFT)
	return bitmask


## Returns true is direction is the oppposite of this direction.
## Always returns false if either masks contains more than one direction
func is_opposite(direction: int) -> bool:
	return (direction == UP and bitmask == DOWN) or (bitmask == UP and direction == DOWN) or (direction == LEFT and bitmask == RIGHT) or (bitmask == LEFT and direction == RIGHT)
