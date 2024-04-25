@tool
extends Node2D

@export var color: Color = Color.DEEP_PINK: set = _set_color
@onready var debug_sprite: Sprite2D = $DebugSprite

func _ready() -> void:
	debug_sprite.modulate = color

func update_position(new_position: Vector2) -> void:
	position = new_position

func _set_color(new_color: Color) -> void:
	color = new_color
	if debug_sprite:
		debug_sprite.modulate = new_color
