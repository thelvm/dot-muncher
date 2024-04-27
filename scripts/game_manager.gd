extends Node

const GAME_STATE_MAIN_MENU = 0
const GAME_STATE_PLAYING = 1
const GAME_STATE_PAUSED = 2
const GAME_STATE_GAME_OVER = 3

var game_state: int = GAME_STATE_MAIN_MENU
var score: int = 0


func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready() -> void:
	get_tree().paused = true


func _process(_delta: float) -> void:
	get_tree().paused = not (game_state == GameManager.GAME_STATE_PLAYING)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		match game_state:
			GAME_STATE_PAUSED:
				change_game_state(GAME_STATE_PLAYING)
			GAME_STATE_PLAYING:
				change_game_state(GAME_STATE_PAUSED)
			GAME_STATE_MAIN_MENU, GAME_STATE_GAME_OVER:
				quit()


func score_points(points: int) -> int:
	score += points
	return score


func change_game_state(new_game_state: int) -> void:
	game_state = new_game_state

func quit() -> void:
	get_tree().quit()
