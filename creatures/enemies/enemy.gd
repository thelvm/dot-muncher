class_name EnemyController extends TileMovement

signal hunt_target_updated(new_target: Vector2)

enum State {
	HUNT,
	SCATTER,
	PANIC,
	GO_HOME,
	AT_HOME,
}

@export var muncher: TileMovement
@export var scatter_position: Node2D

@export_category("Home Positions")
@export var home_position: Node2D
@export var home_center_position: Node2D
@export var home_entrance_position: Node2D

var _target: Vector2: set = _set_target
var _current_state: int = State.SCATTER
var _speed_base: float
var _speed_panic: float
var _speed_go_home: float

var _home_entrance_reached := false
var _home_center_reached := false
var _home_reached := false
var _entering_home := false
var _exiting_home := false

static var eaten_this_vulnerable_state: int = 0

@onready var _offensive_hitbox: Area2D = $OffensiveHitbox
@onready var _hitbox: Area2D = $Hitbox

func _ready() -> void:
	super._ready()
	_target = scatter_position.global_position
	_speed_base = speed
	_speed_panic = speed / 3
	_speed_go_home = speed * 2


func _physics_process(delta: float) -> void:
	if _current_state == State.GO_HOME:
		_home_entrance_reached = _reached_point(home_entrance_position.global_position)
		if _home_entrance_reached:
			_entering_home = true
			_current_state = State.AT_HOME
	
	if _current_state == State.AT_HOME:
		_home_routine()
		_move(delta)
	else:
		_update_next_intersetion_coordinates()
		_reached_intersection = _reached_point(_next_intersection_coords)
		if _current_state == State.HUNT:
			_update_hunt_target()
		_update_best_direction()
		_move(delta)


func change_state(new_state: int) -> void:
	if _current_state == new_state:
		return

	if _current_state == State.GO_HOME or _current_state == State.AT_HOME:
		return

	turn_around()

	match new_state:
		State.HUNT, State.SCATTER:
			speed = _speed_base
			_offensive_hitbox.set_deferred("monitorable", true)
			_hitbox.set_deferred("monitoring", false)
			if new_state == State.HUNT:
				_update_hunt_target()
			else:
				_target = scatter_position.global_position
		State.PANIC:
			speed = _speed_panic
			_offensive_hitbox.set_deferred("monitorable", false)
			_hitbox.set_deferred("monitoring", true)
		State.GO_HOME:
			speed = _speed_go_home
			_target = home_entrance_position.global_position
			_offensive_hitbox.set_deferred("monitorable", false)
			_hitbox.set_deferred("monitoring", false)
	_current_state = new_state

func _update_best_direction() -> void:
	if not _reached_intersection:
		return

	if _current_state == State.PANIC:
		_target = global_position + Vector2(randf_range(-5,5), randf_range(-5,5))

	var available_directions := DirectionMask.new(_next_intersection_available_directions)
	available_directions.remove_direction(-current_direction)

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
	eaten_this_vulnerable_state += 1
	GameManager.score_points((2 ** eaten_this_vulnerable_state) * 100)
	change_state(State.GO_HOME)


func _home_routine() -> void:
	if _entering_home and not _home_center_reached and not _home_reached:
		_home_center_reached = _reached_point(home_center_position.global_position)
		move_mode = MoveMode.FREE
		current_direction = global_position.direction_to(home_center_position.global_position)
		return
	if  _entering_home and _home_center_reached and not _home_reached:
		_home_reached = _reached_point(home_position.global_position)
		move_mode = MoveMode.FREE
		current_direction = global_position.direction_to(home_position.global_position)
		return
	if  _entering_home and _home_center_reached and _home_reached:
		# TODO go back to visible
		move_mode = MoveMode.FREE
		current_direction = global_position.direction_to(home_center_position.global_position)
		_home_center_reached = false
		_home_entrance_reached = false
		_entering_home = false
		_exiting_home = true
		return
	if _exiting_home and not _home_entrance_reached and not _home_center_reached:
		_home_center_reached = _reached_point(home_center_position.global_position)
		move_mode = MoveMode.FREE
		current_direction = global_position.direction_to(home_center_position.global_position)
		return
	if _exiting_home and not _home_entrance_reached and _home_center_reached:
		_home_entrance_reached = _reached_point(home_entrance_position.global_position)
		move_mode = MoveMode.FREE
		current_direction = global_position.direction_to(home_entrance_position.global_position)
		return
	if _exiting_home and _home_center_reached and _home_reached:
		move_mode = MoveMode.TILED
		_current_state = State.PANIC
		current_direction = Vector2.LEFT
		change_state(State.HUNT)
		_home_entrance_reached = false
		_home_center_reached = false
		_home_reached = false
		_entering_home = false
		_exiting_home = false
		
		return
