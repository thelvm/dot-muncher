class_name TileMovement
extends Node2D

signal current_direction_changed(new_direction: Vector2)

enum MoveMode {
	TILED,
	FREE,
}

@export var tile_map: TileMap
@export var speed: float = 16
@export var respawn_node: Node2D

var respawn_coords: Vector2
var move_mode: MoveMode = MoveMode.TILED

var _tile_size: int
var _offset: int

var current_direction: Vector2 = Vector2.RIGHT: set = _set_current_direction
var _requested_direction: Vector2

var _next_intersection_coords: Vector2
var _next_intersection_available_directions: DirectionMask
var _reached_intersection := false
var _is_next_intersection_coordinates_up_to_date := false


func _ready() -> void:
	assert(tile_map is TileMap, "No TileMap defined")

	_tile_size = tile_map.tile_set.tile_size.x
	# Tile size is always an even number
	@warning_ignore("integer_division")
	_offset = _tile_size / 2
	
	if respawn_node == null:
		respawn_coords = global_position
	else:
		respawn_coords = respawn_node.global_position


func _physics_process(delta: float) -> void:
	_update_next_intersetion_coordinates()
	_reached_intersection = _reached_point(_next_intersection_coords)
	_move(delta)


func update_requested_direction(new_requested_direction: Vector2) -> void:
	if new_requested_direction == -current_direction:
		turn_around()
	_requested_direction = new_requested_direction


func respawn() -> void:
	current_direction = Vector2.RIGHT
	global_position = respawn_coords
	_reached_intersection = true
	_is_next_intersection_coordinates_up_to_date = false


func turn_around() -> void:
	current_direction = -current_direction
	_is_next_intersection_coordinates_up_to_date = false


func _move(delta: float) -> void:
	if move_mode == MoveMode.TILED:
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
			if not _next_intersection_available_directions.has_direction(current_direction):
				current_direction = Vector2.ZERO
				_is_next_intersection_coordinates_up_to_date = true
				_reached_intersection = true

		position += current_direction * speed * delta

		match current_direction:
			Vector2.UP, Vector2.DOWN:
				position.x = Util.snap(position.x, _tile_size, 0, _offset)
			Vector2.LEFT, Vector2.RIGHT:
				position.y = Util.snap(position.y, _tile_size, 0, 0)
			_:
				position.y = Util.snap(position.y, _tile_size, 0, 0)
				position.x = Util.snap(position.x, _tile_size, 0, _offset)
	
	if move_mode == MoveMode.FREE:
		position += current_direction * speed * delta


## Calculates the coordinates of the next intersection along
## the player's current direction.
func _update_next_intersetion_coordinates() -> void:
	if _is_next_intersection_coordinates_up_to_date:
		return
	
	# Get coords of the tile at the current player's position
	var current_tile_map_coords: Vector2i
	current_tile_map_coords = tile_map.local_to_map(tile_map.to_local(self.global_position))
	
	var is_past_center_of_tile: bool = (tile_map.to_global(tile_map.map_to_local(current_tile_map_coords)) - global_position).dot(current_direction) <= 0

	if not is_past_center_of_tile:
		current_tile_map_coords -= Vector2i(current_direction)

	# Test every tile in a straight line in the direction of the player
	# and return the first intersection found
	var intersection_found := false
	while not intersection_found:
		match DirectionMask.vector2_to_bitmask(current_direction):
			DirectionMask.UP:
				current_tile_map_coords = tile_map.get_neighbor_cell(current_tile_map_coords,
						TileSet.CELL_NEIGHBOR_TOP_SIDE)
			DirectionMask.DOWN:
				current_tile_map_coords = tile_map.get_neighbor_cell(current_tile_map_coords,
						TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)
			DirectionMask.LEFT:
				current_tile_map_coords = tile_map.get_neighbor_cell(current_tile_map_coords,
						TileSet.CELL_NEIGHBOR_LEFT_SIDE)
			DirectionMask.RIGHT:
				current_tile_map_coords = tile_map.get_neighbor_cell(current_tile_map_coords,
						TileSet.CELL_NEIGHBOR_RIGHT_SIDE)

		var current_tile_available_directions := DirectionMask.new()
		current_tile_available_directions.bitmask = tile_map.get_cell_tile_data(0, current_tile_map_coords).get_custom_data_by_layer_id(0) as int

		# If the tile is not a corridor, mark it as the next intersection
		if not (current_tile_available_directions.bitmask == DirectionMask.UP + DirectionMask.DOWN or current_tile_available_directions.bitmask == DirectionMask.LEFT + DirectionMask.RIGHT):
			_next_intersection_coords = tile_map.to_global(tile_map.map_to_local(current_tile_map_coords))
			_next_intersection_available_directions = DirectionMask.new(current_tile_available_directions)
			intersection_found = true
			_is_next_intersection_coordinates_up_to_date = true


func _reached_point(point: Vector2) -> bool:
	return (point - global_position).dot(current_direction) <= 0 and global_position.distance_to(point) < (_tile_size / 2.0)


func _set_current_direction(new_direction: Vector2) -> void:
	current_direction = new_direction
	current_direction_changed.emit(current_direction)


func _on_teleporter_entered(area: Area2D) -> void:
	if area is Teleporter:
		global_position = area.destination.global_position
		_is_next_intersection_coordinates_up_to_date = false
