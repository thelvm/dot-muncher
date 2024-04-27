extends Node

const GAME_STATE_PAUSED = 1
const GAME_STATE_PLAYING = 2

var game_state: int = GAME_STATE_PLAYING
var score: int = 0


func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if game_state == GAME_STATE_PAUSED:
			change_game_state(GAME_STATE_PLAYING)
		else:
			change_game_state(GAME_STATE_PAUSED)


func score_points(points: int) -> int:
	score += points
	return score


func change_game_state(new_game_state: int) -> void:
	game_state = new_game_state
	match new_game_state:
		GAME_STATE_PAUSED:
			get_tree().paused = true
		GAME_STATE_PLAYING:
			get_tree().paused = false


func quit() -> void:
	get_tree().quit()
