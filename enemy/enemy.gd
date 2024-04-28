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
var _speed_base: float
var _speed_panic: float
var _speed_go_home: float


@onready var _offensive_hitbox: Area2D = $OffensiveHitbox
@onready var _hitbox: Area2D = $Hitbox


func _ready() -> void:
	super._ready()
	_target = scatter_position.global_position
	_speed_base = speed
	_speed_panic = speed / 3
	_speed_go_home = speed * 2


func _physics_process(delta: float) -> void:
	_update_next_intersetion_coordinates()
	_update_reached_intersection()
	if _reached_intersection and _current_mode == MODE_HUNT: # FIXME onyl switch when home reached
		_update_hunt_target()
	_update_best_direction()
	_move(delta)


func change_mode(new_mode: int) -> void:
	if _current_mode == new_mode:
		return

	turn_around()

	if _current_mode == MODE_GO_HOME and new_mode != MODE_HUNT:
		return

	match new_mode:
		MODE_HUNT, MODE_SCATTER:
			speed = _speed_base
			_offensive_hitbox.set_deferred("monitorable", true)
			_hitbox.monitoring = false
			if new_mode == MODE_HUNT:
				_update_hunt_target()
			else:
				_target = scatter_position.global_position
		MODE_PANIC:
			speed = _speed_panic
			_offensive_hitbox.set_deferred("monitorable", false) # FIXME not turning off?
			_hitbox.monitoring = true
		MODE_GO_HOME:
			speed = _speed_go_home
			_target = home_position.global_position
			_offensive_hitbox.set_deferred("monitorable", false)
			_hitbox.monitoring = false
	_current_mode = new_mode

func _update_best_direction() -> void:
	if not _reached_intersection:
		return

	if _current_mode == MODE_PANIC:
		_target = global_position + Vector2(randf_range(-5,5), randf_range(-5,5))

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


func _on_hitbox_area_entered(area: Area2D) -> void:
	change_mode(MODE_GO_HOME)
