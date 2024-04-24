extends TileMovement

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@export var target: Node2D

func _physics_process(delta):
	var direction = position.direction_to(nav_agent.get_next_path_position())
	
	if absf(direction.x) < absf(direction.y):
		direction.x = 0
	else:
		direction.y = 0
	
	direction = direction.normalized()
	
	if direction == Vector2.UP or direction == Vector2.DOWN:
		position.x = Util.snap(position.x, 16, 0) - 8
	elif direction == Vector2.LEFT or direction == Vector2.RIGHT:
		position.y = Util.snap(position.y, 16, 0) - 8

func update_path():
	nav_agent.target_position = target.global_position
