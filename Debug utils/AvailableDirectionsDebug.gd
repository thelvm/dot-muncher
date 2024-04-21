extends Control

enum DirectionMask {
	NONE = 0,
	UP = 1,
	DOWN = 2,
	LEFT = 4,
	RIGHT = 8
}

@onready var up_texture: TextureRect = $Up
@onready var down_texture: TextureRect = $Down
@onready var left_texture: TextureRect = $Left
@onready var right_texture: TextureRect = $Right
@onready var past_center_label: Label = $"Past Center"

func update_avaibale_directions(direction_mask: int):
	up_texture.visible = (direction_mask & DirectionMask.UP) != 0
	down_texture.visible = (direction_mask & DirectionMask.DOWN) != 0
	left_texture.visible = (direction_mask & DirectionMask.LEFT) != 0
	right_texture.visible = (direction_mask & DirectionMask.RIGHT) != 0

func update_past_center(is_past_center: bool):
	past_center_label.visible = is_past_center
