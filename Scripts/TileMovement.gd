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
var available_directions_mask: int = 15

signal debug_next_middle_tile_updated(position: Vector2)

func _ready():
	assert(tile_map is TileMap, "No TileMap defined")
	
	tile_size = tile_map.tile_set.tile_size.x
	offset = tile_size / 2

func _physics_process(delta):
	update_available_directions_mask()
	next_middle_tile()
	move(delta)

func move(delta: float):
	match requested_direction:
		Vector2.UP:
			if (available_directions_mask & DirectionMask.UP) != 0:
				next_direction = Vector2.UP
		Vector2.DOWN:
			if (available_directions_mask & DirectionMask.DOWN) != 0:
				next_direction = Vector2.DOWN
		Vector2.LEFT:
			if (available_directions_mask & DirectionMask.LEFT) != 0:
				next_direction = Vector2.LEFT
		Vector2.RIGHT:
			if (available_directions_mask & DirectionMask.RIGHT) != 0:
				next_direction = Vector2.RIGHT
		_:
			next_direction = Vector2.ZERO
	
	if vector2_to_direction_mask(current_direction) & available_directions_mask == 0:
		current_direction = Vector2.ZERO
	
	var can_change_direction: bool = true
	
	if can_change_direction:
		current_direction = next_direction
		next_direction = Vector2.ZERO
	
	position += current_direction * speed * delta

func update_requested_direction(new_requested_direction: Vector2):
	requested_direction = new_requested_direction

func update_available_directions_mask():
	var cell_tile_position: Vector2i = tile_map.local_to_map(tile_map.to_local(global_position))
	var cell_tile_data: TileData = tile_map.get_cell_tile_data(0, cell_tile_position)
	available_directions_mask = cell_tile_data.get_custom_data_by_layer_id(0)

func vector2_to_direction_mask(direction: Vector2) -> int:
	match direction:
		_:
			return DirectionMask.NONE

func next_middle_tile() -> Vector2:
	var next_middle: Vector2
	match current_direction:
		Vector2.UP:
			next_middle.x = Util.snap(position.x, tile_size, offset, -1)
			next_middle.y = Util.snap(position.y, tile_size, offset, 0)
		Vector2.DOWN:
			next_middle.x = Util.snap(position.x, tile_size, offset, 1)
			next_middle.y = Util.snap(position.y, tile_size, offset, 0)
		Vector2.LEFT:
			next_middle.x = Util.snap(position.x, tile_size, offset, 0)
			next_middle.y = Util.snap(position.y, tile_size, offset, -1)
		Vector2.RIGHT:
			next_middle.x = Util.snap(position.x, tile_size, offset, 0)
			next_middle.y = Util.snap(position.y, tile_size, offset, 1)
		_:
			next_middle.x = Util.snap(position.x, tile_size, offset, 0)
			next_middle.y = Util.snap(position.y, tile_size, offset, 0)
	
	debug_next_middle_tile_updated.emit(next_middle)
	
	return next_middle
	
