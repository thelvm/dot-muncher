extends Node

enum GameState {
	MAIN_MENU,
	PLAYING,
	PAUSED,
	GAME_OVER,
}

var current_game_state: GameState = GameState.MAIN_MENU

var initial_lives: int = 3
var lifes_left: int = 0
var score: int = 0
var highscores_save_data_path: String = "res://highscores_save_data.tres"
var highscores_save_data: HighscoreSaveData
var is_hisghscore: bool = false

var main_menu_scene_path := "res://gui/main_menu/main_menu.tscn"
var maze_scene_path := "res://maze/gameplay.tscn"

var current_scene: Node = null
var currently_loading_scene := ""
var game_state_on_loaded: GameState


func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var root := get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)


func _ready() -> void:
	if not ResourceLoader.exists(highscores_save_data_path):
		highscores_save_data = HighscoreSaveData.new()
		ResourceSaver.save(highscores_save_data, highscores_save_data_path)
	else:
		highscores_save_data = ResourceLoader.load(highscores_save_data_path) as HighscoreSaveData


func _process(_delta: float) -> void:
	if currently_loading_scene:
		if ResourceLoader.load_threaded_get_status(currently_loading_scene) == ResourceLoader.THREAD_LOAD_LOADED:
			call_deferred("_change_scene")


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		match current_game_state:
			GameState.PAUSED:
				unpause()
			GameState.PLAYING:
				pause()
			GameState.MAIN_MENU, GameState.GAME_OVER:
				quit()


func score_points(points: int) -> int:
	score += points
	is_hisghscore = score > highscores_save_data.get_highscore_points()
	return score


func start_playing() -> void:
	start_loading_scene(maze_scene_path)
	game_state_on_loaded = GameState.PLAYING
	score = 0
	is_hisghscore = false
	lifes_left = initial_lives
	get_tree().paused = false


func pause() -> void:
	current_game_state = GameState.PAUSED
	get_tree().paused = true


func unpause() -> void:
	current_game_state = GameState.PLAYING
	get_tree().paused = false


func lose_life() -> void:
	lifes_left -= 1
	if lifes_left <= 0:
		game_over()
	else:
		get_tree().call_group("creatures", "respawn")


func game_over() -> void:
	highscores_save_data.add_highscore("player", score)
	current_game_state = GameState.GAME_OVER
	get_tree().paused = true


func return_to_main_menu() -> void:
	game_state_on_loaded = GameState.MAIN_MENU
	start_loading_scene(main_menu_scene_path)


func quit() -> void:
	ResourceSaver.save(highscores_save_data, highscores_save_data_path)
	get_tree().quit()


func start_loading_scene(scene_path: String) -> void:
	ResourceLoader.load_threaded_request(scene_path)
	currently_loading_scene = scene_path


func _change_scene() -> void:
	current_scene.free()
	var new_scene_resource := ResourceLoader.load_threaded_get(currently_loading_scene) as PackedScene
	var new_scene := new_scene_resource.instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
	currently_loading_scene = ""
	current_scene = new_scene
	current_game_state = game_state_on_loaded
