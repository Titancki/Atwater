extends Node

signal level_changed

var current_scene: Node = null
var current_scene_name: String = ""


func _ready():
	change_scene("main_menu")
	pass


func change_scene(scene_name: String) -> void:
	if not SceneLoader.scenes.has(scene_name):
		push_error("Scene '%s' not found in SceneLoader!" % scene_name)
		return

	# Optional safeguard
	if current_scene_name == scene_name and current_scene:
		return

	_free_current_scene()

	var packed_scene: PackedScene = SceneLoader.scenes[scene_name]
	var new_scene: Node = packed_scene.instantiate()

	add_child(new_scene)

	current_scene = new_scene
	current_scene_name = scene_name

	level_changed.emit()


func reload_scene() -> void:
	if current_scene_name == "":
		push_warning("No scene to reload.")
		return

	change_scene(current_scene_name)


func _free_current_scene() -> void:
	if current_scene:
		current_scene.queue_free()
		current_scene = null
