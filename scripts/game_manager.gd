extends Node

const GAME_STATE_MAIN_MENU = 0
const GAME_STATE_PLAYING = 1
const GAME_STATE_PAUSED = 2
const GAME_STATE_GAME_OVER = 3

var game_state: int = GAME_STATE_MAIN_MENU

var score: int = 0
var highscores_save_data_path: String = "res://highscores_save_data.tres"
var highscores_save_data: HighscoreSaveData
var is_hisghscore: bool = false

var main_menu_scene_path := "res://gui/main_menu/main_menu.tscn"
var maze_scene_path := "res://maze/gameplay.tscn"

var current_scene: Node = null
var currently_loading_scene := ""
var game_state_on_loaded: int


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
			call_deferred("change_scene")


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		match game_state:
			GAME_STATE_PAUSED:
				unpause()
			GAME_STATE_PLAYING:
				pause()
			GAME_STATE_MAIN_MENU, GAME_STATE_GAME_OVER:
				quit()


func score_points(points: int) -> int:
	score += points
	is_hisghscore = score > highscores_save_data.get_highscore_points()
	return score


func start_playing() -> void:
	start_loading_scene(maze_scene_path)
	game_state_on_loaded = GAME_STATE_PLAYING
	score = 0
	is_hisghscore = false
	get_tree().paused = false


func pause() -> void:
	game_state = GAME_STATE_PAUSED
	get_tree().paused = true


func unpause() -> void:
	game_state = GAME_STATE_PLAYING
	get_tree().paused = false


func game_over() -> void:
	highscores_save_data.add_highscore("player", score)
	game_state = GAME_STATE_GAME_OVER
	get_tree().paused = true


func return_to_main_menu() -> void:
	game_state_on_loaded = GAME_STATE_MAIN_MENU
	start_loading_scene(main_menu_scene_path)


func quit() -> void:
	ResourceSaver.save(highscores_save_data, highscores_save_data_path)
	get_tree().quit()


func start_loading_scene(scene_path: String) -> void:
	ResourceLoader.load_threaded_request(scene_path)
	currently_loading_scene = scene_path


func change_scene() -> void:
	current_scene.free()
	var new_scene_resource := ResourceLoader.load_threaded_get(currently_loading_scene) as PackedScene
	var new_scene := new_scene_resource.instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
	currently_loading_scene = ""
	current_scene = new_scene
	game_state = game_state_on_loaded
