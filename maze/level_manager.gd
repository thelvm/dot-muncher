# Controls the enemy's state in a game.
extends Node

@export var levels_parameters: Array[LevelParameters]

var current_level: int = 1

# Timers for the different states.
var hunt_timer: Timer
var scatter_timer: Timer
var panic_timer: Timer

var maze_scene_packed: PackedScene = preload("res://maze/maze_tile_map.tscn")
@onready var maze_parent: Node = $MazeLayer
@onready var maze_scene: Node = $MazeLayer/MazeTileMap

@onready var level_value_label: Label = %LevelValueLabel

# Initialization function. Sets up the timers and starts the scatter timer.
func _ready() -> void:
	assert(levels_parameters.size() > 0)
	configure_level()


func _process(_delta: float) -> void:
	if DotConsumable.dots_in_level <= 0:
		_level_up()


# Starts the panic state.
func start_panic() -> void:
	if hunt_timer:
		hunt_timer.stop()
	if scatter_timer:
		scatter_timer.stop()
	if panic_timer:
		panic_timer.start()
		_change_enemy_state(EnemyController.STATE_PANIC)


func configure_level() -> void:
	DotConsumable.dots_in_level = 0
	level_value_label.text = str(current_level)
	
	var level_difficulty_index: int = mini(current_level - 1, levels_parameters.size() - 1)
	
	if hunt_timer:
		hunt_timer.queue_free()
	if levels_parameters[level_difficulty_index].hunt_time > 0:
		hunt_timer = Timer.new()
		hunt_timer.one_shot = true
		hunt_timer.wait_time = levels_parameters[level_difficulty_index].hunt_time
		if levels_parameters[level_difficulty_index].scatter_time > 0:
			hunt_timer.timeout.connect(_on_hunt_timer_timeout)
		add_child(hunt_timer)
	else:
		hunt_timer = null
	
	if scatter_timer:
		scatter_timer.queue_free()
	if levels_parameters[level_difficulty_index].scatter_time > 0:
		scatter_timer = Timer.new()
		scatter_timer.one_shot = true
		scatter_timer.wait_time = levels_parameters[level_difficulty_index].scatter_time
		if levels_parameters[level_difficulty_index].hunt_time > 0:
			scatter_timer.timeout.connect(_on_scatter_timer_timeout)
		add_child(scatter_timer)
	else:
		scatter_timer = null
	
	if panic_timer:
		panic_timer.queue_free()
	if levels_parameters[level_difficulty_index].panic_time > 0:
		panic_timer = Timer.new()
		panic_timer.one_shot = true
		panic_timer.wait_time = levels_parameters[level_difficulty_index].panic_time
		if levels_parameters[level_difficulty_index].hunt_time > 0:
			panic_timer.timeout.connect(_on_panic_timer_timeout)
		add_child(panic_timer)
	else:
		panic_timer = null
	
	_change_enemy_state(levels_parameters[level_difficulty_index].intial_state)
	
	match levels_parameters[level_difficulty_index].intial_state:
		EnemyController.STATE_HUNT:
			if hunt_timer:
				hunt_timer.start()
		EnemyController.STATE_SCATTER:
			if scatter_timer:
				scatter_timer.start()


# Callback for when the hunt timer times out. Starts the scatter state.
func _on_hunt_timer_timeout() -> void:
	scatter_timer.start()
	_change_enemy_state(EnemyController.STATE_SCATTER)

# Callback for when the scatter timer times out. Starts the hunt state.
func _on_scatter_timer_timeout() -> void:
	hunt_timer.start()
	_change_enemy_state(EnemyController.STATE_HUNT)

# Callback for when the panic timer times out. Starts the hunt state.
func _on_panic_timer_timeout() -> void:
	hunt_timer.start()
	_change_enemy_state(EnemyController.STATE_HUNT)


func _change_enemy_state(new_state: int) -> void:
	if new_state != EnemyController.STATE_GO_HOME:
		EnemyController.eaten_this_vulnerable_state = 0
	get_tree().call_group("enemies", "change_state", new_state)


func _level_up() -> void:
	current_level += 1
	var new_maze := maze_scene_packed.instantiate()
	maze_scene.queue_free()
	maze_scene = new_maze
	maze_parent.add_child(new_maze)
	configure_level()
