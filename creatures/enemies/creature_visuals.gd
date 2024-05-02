extends Sprite2D

var _sclera_base_position: Vector2
var _sclera_offset: int = 2
var _sclera_tween: Tween
var _pupil_base_position: Vector2
var _pupil_offset: int = 2
var _body_texture_original: CompressedTexture2D
var _body_texture_vulnerable: CompressedTexture2D = preload("res://creatures/enemies/body-vulnerable.png")

@onready var base_enemy: EnemyController = $".."
@onready var sclera_sprite: Sprite2D = $Sclera
@onready var pupil_sprite: Sprite2D = $Sclera/Pupil


func _ready() -> void:
	_body_texture_original = texture as CompressedTexture2D
	_sclera_base_position = sclera_sprite.position
	_pupil_base_position = pupil_sprite.position


func _process(_delta: float) -> void:
	var direction_to: Vector2 
	if base_enemy._current_state == EnemyController.STATE_PANIC or base_enemy._current_state == EnemyController.STATE_GO_HOME:
		direction_to = base_enemy.muncher.global_position.direction_to(base_enemy.global_position)
	else:
		direction_to = base_enemy.global_position.direction_to(base_enemy.muncher.global_position)
	pupil_sprite.position = round(_pupil_base_position + (direction_to * _pupil_offset))
	
	if base_enemy._current_state == EnemyController.STATE_PANIC:
		self_modulate = Color.WHITE
		texture = _body_texture_vulnerable
	elif base_enemy._current_state == EnemyController.STATE_GO_HOME:
		self_modulate = Color.TRANSPARENT
	else:
		self_modulate = Color.WHITE
		texture = _body_texture_original


func _on_current_direction_changed(new_direction: Vector2) -> void:
	if _sclera_tween:
		_sclera_tween.kill()
	_sclera_tween = create_tween()
	_sclera_tween.tween_property(sclera_sprite, "position", _sclera_base_position + (new_direction * _sclera_offset), 0.25)
	_sclera_tween.set_ease(Tween.EASE_OUT)
	_sclera_tween.set_trans(Tween.TRANS_ELASTIC)
