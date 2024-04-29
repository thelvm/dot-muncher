extends Node

var _sclera_base_position: Vector2
var _sclera_offset: int = 2
var _sclera_tween: Tween
var _pupil_base_position: Vector2
var _pupil_offset: int = 2
var _pupil_tween: Tween


@onready var sclera_sprite: Sprite2D = $Sclera
@onready var pupil_sprite: Sprite2D = $Sclera/Pupil


func _ready() -> void:
	_sclera_base_position = sclera_sprite.position
	_pupil_base_position = pupil_sprite.position


func _on_requested_direction_changed(direction: Vector2) -> void:
	if _pupil_tween:
		_pupil_tween.kill()
	_pupil_tween = create_tween()
	_pupil_tween.tween_property(pupil_sprite, "position", _pupil_base_position + (direction * _pupil_offset), 0.1)
	_pupil_tween.set_ease(Tween.EASE_OUT)
	_pupil_tween.set_trans(Tween.TRANS_ELASTIC)


func _on_current_direction_changed(new_direction: Vector2) -> void:
	if _sclera_tween:
		_sclera_tween.kill()
	_sclera_tween = create_tween()
	_sclera_tween.tween_property(sclera_sprite, "position", _sclera_base_position + (new_direction * _sclera_offset), 0.25)
	_sclera_tween.set_ease(Tween.EASE_OUT)
	_sclera_tween.set_trans(Tween.TRANS_ELASTIC)
