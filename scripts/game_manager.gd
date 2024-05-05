extends Node

const GAME_STATE_MAIN_MENU = 0
const GAME_STATE_PLAYING = 1
const GAME_STATE_PAUSED = 2
const GAME_STATE_GAME_OVER = 3

var game_state: int = GAME_STATE_MAIN_MENU
var score: int = 0

var main_menu_scene_path := "res://gui/main_menu/main_menu.tscn"
var maze_scene_path := "res://maze/maze.tscn"

var current_scene: Node = null
var currently_loading_scene := ""
var game_state_on_loaded: int


func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var root := get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)


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
	return score


func start_playing() -> void:
	start_loading_scene(maze_scene_path)
	game_state_on_loaded = GAME_STATE_PLAYING
	get_tree().paused = false


func pause() -> void:
	game_state = GAME_STATE_PAUSED
	get_tree().paused = true


func unpause() -> void:
	game_state = GAME_STATE_PLAYING
	get_tree().paused = false


func game_over() -> void:
	game_state = GAME_STATE_GAME_OVER
	get_tree().paused = true


func return_to_main_menu() -> void:
	game_state_on_loaded = GAME_STATE_MAIN_MENU
	start_loading_scene(main_menu_scene_path)


func quit() -> void:
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
