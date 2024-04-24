class_name Enemy extends Node2D

enum Mode {
	IDLE,
	HUNT,
	SCATTER,
	COWER
}

@export var target: Node2D

var _current_mode: Mode = Mode.IDLE

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D


func update_target_position():
	nav_agent.target_position = target.global_position
