extends HBoxContainer

var muncher_life_visual_UI := preload("res://gui/muncher_life_visual_ui.tscn")
var displayed_lifes: int = 3


func _process(_delta: float) -> void:
	if displayed_lifes != GameManager.lifes_left:
		if get_child_count() > GameManager.lifes_left:
			for i in range(GameManager.lifes_left, get_child_count()):
				get_child(i).queue_free()
		elif get_child_count() < GameManager.lifes_left:
			for i in range(GameManager.lifes_left - get_child_count()):
				var new_life_visual := muncher_life_visual_UI.instantiate()
				add_child(new_life_visual)
		displayed_lifes = GameManager.lifes_left
