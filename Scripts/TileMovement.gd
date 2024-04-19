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

@export var root: Node2D
@export var speed: float

var current_direction: Vector2
var next_direction: Vector2
var requested_direction: Vector2
var available_directions: int

func _ready():
	assert(tile_map is TileMap, "No TileMap defined")
	
	tile_size = tile_map.tile_set.tile_size.x
	offset = tile_size / 2

func _physics_process(delta):
	move(delta)

func move(delta: float):
	match requested_direction:
		Vector2.UP:
			if (available_directions & DirectionMask.UP) != 0:
				next_direction = Vector2.UP
		Vector2.DOWN:
			if (available_directions & DirectionMask.DOWN) != 0:
				next_direction = Vector2.DOWN
		Vector2.LEFT:
			if (available_directions & DirectionMask.LEFT) != 0:
				next_direction = Vector2.LEFT
		Vector2.RIGHT:
			if (available_directions & DirectionMask.RIGHT) != 0:
				next_direction = Vector2.RIGHT
		_:
			next_direction = Vector2.ZERO
	
	var can_change_direction: bool = false
	
	if can_change_direction:
		current_direction = next_direction
		next_direction = Vector2.ZERO
	
	position += current_direction * speed * delta

func update_available_directions(directions: int):
	available_directions = directions
