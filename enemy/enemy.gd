class_name EnemyController extends TileMovement

signal hunt_target_updated(new_target: Vector2)

const MODE_HUNT = 0
const MODE_SCATTER = 1
const MODE_PANIC = 2
const MODE_GO_HOME = 3

@export var muncher: TileMovement
@export var scatter_position: Node2D
@export var home_position: Node2D

var _target: Vector2: set = _set_target
var _current_mode: int = MODE_SCATTER


func _ready() -> void:
	super._ready()
	_target = scatter_position.global_position


func _physics_process(delta: float) -> void:
	_update_next_intersetion_coordinates()
	_update_reached_intersection()
	if _reached_intersection and _current_mode == MODE_HUNT:
		_update_hunt_target()
	_update_best_direction()
	_move(delta)


func change_mode(new_mode: int) -> void:
	turn_around()
	_current_mode = new_mode
	match _current_mode:
		MODE_HUNT:
			_update_hunt_target()
		MODE_SCATTER:
			_target = scatter_position.global_position
		MODE_PANIC:
			pass # TODO
		MODE_GO_HOME:
			_target = home_position.global_position


func _update_best_direction() -> void:
	if not _reached_intersection:
		return
	
	var available_directions: DirectionMask = DirectionMask.new()
	available_directions.bitmask = _next_intersection_available_directions.bitmask
	var current_direction_as_mask := DirectionMask.new()
	current_direction_as_mask.from_vector2(-current_direction)
	available_directions.remove_direction(current_direction_as_mask.bitmask)
	
	var min_distance_to_target: float = 100_000_000
	var best_direction: Vector2
	if available_directions.has_direction(DirectionMask.UP):
		var tile_position: Vector2 = global_position + (Vector2.UP * _tile_size)
		var distance_to_target: float = tile_position.distance_to(_target)
		if distance_to_target < min_distance_to_target:
			min_distance_to_target = distance_to_target
			best_direction = Vector2.UP
	if available_directions.has_direction(DirectionMask.RIGHT):
		var tile_position: Vector2 = global_position + (Vector2.RIGHT * _tile_size)
		var distance_to_target: float = tile_position.distance_to(_target)
		if distance_to_target < min_distance_to_target:
			min_distance_to_target = distance_to_target
			best_direction = Vector2.RIGHT
	if available_directions.has_direction(DirectionMask.DOWN):
		var tile_position: Vector2 = global_position + (Vector2.DOWN * _tile_size)
		var distance_to_target: float = tile_position.distance_to(_target)
		if distance_to_target < min_distance_to_target:
			min_distance_to_target = distance_to_target
			best_direction = Vector2.DOWN
	if available_directions.has_direction(DirectionMask.LEFT):
		var tile_position: Vector2 = global_position + (Vector2.LEFT * _tile_size)
		var distance_to_target: float = tile_position.distance_to(_target)
		if distance_to_target < min_distance_to_target:
			min_distance_to_target = distance_to_target
			best_direction = Vector2.LEFT
	
	current_direction = best_direction

func _update_hunt_target() -> void:
	_target = muncher.global_position


func _set_target(new_value: Vector2) -> void:
	_target = new_value
	hunt_target_updated.emit(_target)
