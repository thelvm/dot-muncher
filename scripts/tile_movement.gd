class_name TileMovement extends Node2D

signal debug_next_intersection_coords_updated(position: Vector2)
signal debug_available_directions(directions: int)
signal debug_reached_intersection(is_past_center: bool)

@export var tile_map: TileMap
@export var speed: float = 16

var _tile_size: int
var _offset: int

var current_direction: Vector2 = Vector2.RIGHT
var _requested_direction: Vector2

var _next_intersection_coords: Vector2: set = _set_next_intersection_coords
var _next_intersection_available_directions: DirectionMask
var _reached_intersection := false
var _is_next_intersection_coordinates_up_to_date := false


func _ready() -> void:
	assert(tile_map is TileMap, "No TileMap defined")

	_tile_size = tile_map.tile_set.tile_size.x
	# Tile size is always an even number
	@warning_ignore("integer_division")
	_offset = _tile_size / 2


func _physics_process(delta: float) -> void:
	_update_next_intersetion_coordinates()
	_update_reached_intersection()
	_move(delta)


func update_requested_direction(new_requested_direction: Vector2) -> void:
	_requested_direction = new_requested_direction


func _move(delta: float) -> void:
	if _reached_intersection:
		_is_next_intersection_coordinates_up_to_date = false
		_reached_intersection = false
		match _requested_direction:
			Vector2.UP:
				if _next_intersection_available_directions.has_direction(DirectionMask.UP):
					current_direction = Vector2.UP
			Vector2.DOWN:
				if _next_intersection_available_directions.has_direction(DirectionMask.DOWN):
					current_direction = Vector2.DOWN
			Vector2.LEFT:
				if _next_intersection_available_directions.has_direction(DirectionMask.LEFT):
					current_direction = Vector2.LEFT
			Vector2.RIGHT:
				if _next_intersection_available_directions.has_direction(DirectionMask.RIGHT):
					current_direction = Vector2.RIGHT
		var current_direction_as_mask := DirectionMask.new()
		current_direction_as_mask.from_vector2(current_direction)
		if not _next_intersection_available_directions.has_direction(current_direction_as_mask.bitmask):
			current_direction = Vector2.ZERO
			_is_next_intersection_coordinates_up_to_date = true
			_reached_intersection = true
	
	position += current_direction * speed * delta


	match current_direction:
		Vector2.UP, Vector2.DOWN:
			position.x = Util.snap(position.x, _tile_size, 0, _offset)
		Vector2.LEFT, Vector2.RIGHT:
			position.y = Util.snap(position.y, _tile_size, 0, _offset)
		_:
			position.y = Util.snap(position.y, _tile_size, 0, _offset)
			position.x = Util.snap(position.x, _tile_size, 0, _offset)


## Calculates the coordinates of the next intersection along
## the player's current direction.
func _update_next_intersetion_coordinates() -> void:
	if _is_next_intersection_coordinates_up_to_date:
		return
	
	# TODO fix next intersection not behaving with direction change on same tile as intersection
	# Get coords of the tile at the current player's position
	var current_tile_coords: Vector2i
	current_tile_coords = tile_map.local_to_map(tile_map.to_local(self.global_position))
	
	# Test every tile in a straight line in the direction of the player
	# and return the first intersection found
	var intersection_found := false
	while not intersection_found:
		var current_direction_as_mask := DirectionMask.new()
		current_direction_as_mask.from_vector2(current_direction)
		match current_direction_as_mask.bitmask:
			DirectionMask.UP:
				current_tile_coords = tile_map.get_neighbor_cell(current_tile_coords,
						TileSet.CELL_NEIGHBOR_TOP_SIDE)
			DirectionMask.DOWN:
				current_tile_coords = tile_map.get_neighbor_cell(current_tile_coords,
						TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)
			DirectionMask.LEFT:
				current_tile_coords = tile_map.get_neighbor_cell(current_tile_coords,
						TileSet.CELL_NEIGHBOR_LEFT_SIDE)
			DirectionMask.RIGHT:
				current_tile_coords = tile_map.get_neighbor_cell(current_tile_coords,
						TileSet.CELL_NEIGHBOR_RIGHT_SIDE)
		
		var current_tile_available_directions := DirectionMask.new()
		current_tile_available_directions.bitmask = tile_map.get_cell_tile_data(0, current_tile_coords).get_custom_data_by_layer_id(0) as int
		
		# If the tile is not a corridor, mark it as the next intersection
		if not (current_tile_available_directions.bitmask == DirectionMask.UP + DirectionMask.DOWN or current_tile_available_directions.bitmask == DirectionMask.LEFT + DirectionMask.RIGHT):
			_next_intersection_coords = tile_map.to_global(tile_map.map_to_local(current_tile_coords))
			_next_intersection_available_directions = current_tile_available_directions
			intersection_found = true
			_is_next_intersection_coordinates_up_to_date = true


func _update_reached_intersection() -> void:
	if not _reached_intersection:
		_reached_intersection = (_next_intersection_coords - global_position).dot(current_direction) <= 0


func _set_next_intersection_coords(new_value: Vector2) -> void:
	_next_intersection_coords = new_value
	debug_next_intersection_coords_updated.emit(_next_intersection_coords)
