class_name Consumable
extends Node

@export var point_value: int

@onready var animation_player: AnimationPlayer = $PointPopup
@onready var points_label: Label = $Points



func _ready() -> void:
	points_label.visible = false
	$Sprite2D.visible = true


func _on_player_collision(_area: Area2D) -> void:
	points_label.text = str(point_value)
	GameManager.score_points(point_value)
	animation_player.play("points_popup")
