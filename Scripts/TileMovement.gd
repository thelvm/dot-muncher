class_name TileMovement extends Node2D

enum DirectionMask {
	NONE = 0,
	UP = 1,
	DOWN = 2,
	LEFT = 4,
	RIGHT = 8
}

@export var tile_map: TileMap
var tile_size: int
var offset: int

@export var speed: float = 16

var current_direction: Vector2
var next_direction: Vector2
var requested_direction: Vector2
var available_directions_mask: DirectionMask = DirectionMask.NONE

var will_stop: bool = false: set = _set_will_stop
var will_change_direction = false: set = _set_will_change_direction
var next_center_of_tile = Vector2.ZERO

signal debug_next_center_tile_updated(position: Vector2)
signal debug_available_directions(directions: int)

func _ready():
	assert(tile_map is TileMap, "No TileMap defined")

	tile_size = tile_map.tile_set.tile_size.x
	# Tile size is always an even number
	@warning_ignore("integer_division")
	offset = tile_size / 2

func _physics_process(delta):
	update_available_directions_mask()
	calculate_next_center_of_tile()
	move(delta)

func move(delta: float):
	will_change_direction = false
	match requested_direction:
		Vector2.UP:
			if (available_directions_mask & DirectionMask.UP) != 0:
				next_direction = Vector2.UP
				will_change_direction = true
		Vector2.DOWN:
			if (available_directions_mask & DirectionMask.DOWN) != 0:
				next_direction = Vector2.DOWN
				will_change_direction = true
		Vector2.LEFT:
			if (available_directions_mask & DirectionMask.LEFT) != 0:
				next_direction = Vector2.LEFT
				will_change_direction = true
		Vector2.RIGHT:
			if (available_directions_mask & DirectionMask.RIGHT) != 0:
				next_direction = Vector2.RIGHT
				will_change_direction = true
		_:
			next_direction = Vector2.ZERO
			will_change_direction = false

	if (vector2_to_direction_mask(current_direction) & available_directions_mask) == 0 and not will_change_direction:
		will_stop = true

	if will_change_direction or will_stop:
		var is_past_center_of_tile: bool = (next_center_of_tile - position).dot(current_direction) <= 0
		if is_past_center_of_tile:
			if will_stop:
				current_direction = Vector2.ZERO
				will_stop = false
			if will_change_direction:
				current_direction = next_direction
				next_direction = Vector2.ZERO
				will_change_direction = false

	position += current_direction * speed * delta

	match current_direction:
		Vector2.UP:
			position.x = Util.snap(position.x, tile_size, 0, offset)
		Vector2.DOWN:
			position.x = Util.snap(position.x, tile_size, 0, offset)
		Vector2.LEFT:
			position.y = Util.snap(position.y, tile_size, 0, offset)
		Vector2.RIGHT:
			position.y = Util.snap(position.y, tile_size, 0, offset)

func update_requested_direction(new_requested_direction: Vector2):
	requested_direction = new_requested_direction

func update_available_directions_mask():
	var cell_tile_position: Vector2i = tile_map.local_to_map(tile_map.to_local(global_position))
	var cell_tile_data: TileData = tile_map.get_cell_tile_data(0, cell_tile_position)
	available_directions_mask = cell_tile_data.get_custom_data_by_layer_id(0)
	debug_available_directions.emit(available_directions_mask)

func vector2_to_direction_mask(direction: Vector2) -> DirectionMask:
	match direction:
		Vector2.UP:
			return DirectionMask.UP
		Vector2.DOWN:
			return DirectionMask.DOWN
		Vector2.LEFT:
			return DirectionMask.LEFT
		Vector2.RIGHT:
			return DirectionMask.RIGHT
		_:
			return DirectionMask.NONE

func calculate_next_center_of_tile():
	var new_center: Vector2 = Vector2.ZERO
	match current_direction:
		Vector2.UP:
			new_center.x = Util.snap(position.x, tile_size, 0, offset)
			new_center.y = Util.snap(position.y, tile_size, -1, offset)
		Vector2.DOWN:
			new_center.x = Util.snap(position.x, tile_size, 0, offset)
			new_center.y = Util.snap(position.y, tile_size, 1, offset)
		Vector2.LEFT:
			new_center.x = Util.snap(position.x, tile_size, -1, offset)
			new_center.y = Util.snap(position.y, tile_size, 0, offset)
		Vector2.RIGHT:
			new_center.x = Util.snap(position.x, tile_size, 1, offset)
			new_center.y = Util.snap(position.y, tile_size, 0, offset)
		_:
			new_center.x = Util.snap(position.x, tile_size, 0, offset)
			new_center.y = Util.snap(position.y, tile_size, 0, offset)

	if new_center != next_center_of_tile:
		next_center_of_tile = new_center
		debug_next_center_tile_updated.emit(new_center)

func _set_will_stop(new_value: bool):
	will_stop = new_value
	if will_stop:
		will_change_direction = false

func _set_will_change_direction(new_value: bool):
	will_change_direction = new_value
	if will_change_direction:
		will_stop = false
