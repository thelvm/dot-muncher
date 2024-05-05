class_name HighscoreSaveData extends Resource

@export var highscores: Array = []


func add_highscore(player_name: String, score: int) -> void:
	highscores.push_back([player_name, score])
	highscores.sort_custom(_sort_callable)


func _sort_callable(a: Array, b: Array) -> bool:
	return a[1] > b[1]
