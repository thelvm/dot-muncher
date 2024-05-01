class_name EnemyController extends TileMovement

signal hunt_target_updated(new_target: Vector2)

const MODE_HUNT = 0
const MODE_SCATTER = 1
const MODE_PANIC = 2
const MODE_GO_HOME = 3

@export var muncher: TileMovement
@export var scatter_position: Node2D
@export var home_position: Node2D
@export var home_entrance_position: Node2D

var states: Dictionary = {}
var _current_state: EnemyState

var _target: Vector2: set = _set_target
var _current_mode: int = MODE_SCATTER
var _speed_base: float
var _speed_panic: float
var _speed_go_home: float
var _home_entrance_reached: bool


@onready var _offensive_hitbox: Area2D = $OffensiveHitbox
@onready var _hitbox: Area2D = $Hitbox


func _ready() -> void:
	super._ready()
	_target = scatter_position.global_position
	_speed_base = speed
	_speed_panic = speed / 3
	_speed_go_home = speed * 2

	for child in get_children():
		if child is EnemyState:
			states[child.name.to_lower()] = child


func _physics_process(delta: float) -> void:
	if _current_mode == MODE_GO_HOME:
		_home_entrance_reached = ((home_entrance_position.global_position - global_position).dot(current_direction) <= 0) and global_position.distance_to(home_entrance_position.global_position) < 16
		if _home_entrance_reached:
			change_mode(MODE_HUNT)

	if _current_mode == MODE_HUNT and _reached_intersection:
		_update_hunt_target()

	_update_next_intersetion_coordinates()
	_update_reached_intersection()
	_update_best_direction()
	_move(delta)


func change_mode(new_mode: int) -> void:
	# TODO switch to dictionary based

	if _current_mode == new_mode:
		return

	if _current_mode == MODE_GO_HOME and not _home_entrance_reached:
		return

	turn_around()

	match new_mode:
		MODE_HUNT, MODE_SCATTER:
			speed = _speed_base
			_offensive_hitbox.set_deferred("monitorable", true)
			_hitbox.set_deferred("monitoring", false)
			if new_mode == MODE_HUNT:
				_update_hunt_target()
			else:
				_target = scatter_position.global_position
		MODE_PANIC:
			speed = _speed_panic
			_offensive_hitbox.set_deferred("monitorable", false)
			_hitbox.set_deferred("monitoring", true)
		MODE_GO_HOME:
			speed = _speed_go_home
			_target = home_entrance_position.global_position
			_offensive_hitbox.set_deferred("monitorable", false)
			_hitbox.set_deferred("monitoring", false)
	_current_mode = new_mode

func _update_best_direction() -> void:
	if not _reached_intersection:
		return

	if _current_mode == MODE_PANIC:
		_target = global_position + Vector2(randf_range(-5,5), randf_range(-5,5))

	var available_directions := DirectionMask.new_from_direction_mask(_next_intersection_available_directions)
	var current_direction_as_mask := DirectionMask.new_from_vector2(-current_direction)
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


func _on_hitbox_area_entered(_area: Area2D) -> void:
	change_mode(MODE_GO_HOME)
