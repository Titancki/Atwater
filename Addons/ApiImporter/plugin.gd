@tool
extends EditorPlugin

var main_panel

func _enter_tree():
	main_panel = preload("res://addons/ApiImporter/card_importer.tscn").instantiate()
	get_editor_interface().get_editor_main_screen().add_child(main_panel)
	_make_visible(false)

func _exit_tree():
	if main_panel:
		main_panel.queue_free()

func _has_main_screen():
	return true

func _make_visible(visible):
	if main_panel:
		main_panel.visible = visible

func _get_plugin_name():
	return "API Importer"

func _get_plugin_icon():
	return get_editor_interface().get_base_control().get_theme_icon("Node", "EditorIcons")
