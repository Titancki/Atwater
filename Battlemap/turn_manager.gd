extends Node

var units: Array
var turn_order: Array = []
var current_index := 0
@onready var interface = $Interface/Initiative/HBoxContainer
signal play_next_turn

func _ready() -> void:
	play_next_turn.connect(next_turn)
	for child in get_children():
			if child is Unit:
				units.append(child)
				
	turn_order = units.duplicate()
	turn_order.sort_custom(func(a, b):
		return a.data.initiative > b.data.initiative
	)
	for unit in turn_order:
		var mini_scene = load("res://Battlemap/Interface/character_min.tscn")
		var miniature = mini_scene.instantiate()
		miniature.name = "%s_mini" % unit.name
		miniature.unit_name = unit.name
		$Interface/Initiative/HBoxContainer.add_child(miniature)
	turn_order[0].start_turn()

func next_turn() -> void:
	var _moving_slot: Control
	var _spacing := 112 + 5
	_moving_slot = interface.get_child(0)
	
	var tween := create_tween()
	
	for child in interface.get_children():
		tween.parallel().tween_property(child, "position:x", child.position.x - _spacing, 0.3)
	
	var last_pos := _spacing * (interface.get_child_count() - 1)
	tween.tween_property(_moving_slot, "position:x", last_pos, 0.3)
	tween.finished.connect(_on_shift_finished)
	
func _on_shift_finished() -> void:
	interface.move_child(interface.get_child(0), interface.get_child_count() - 1)
	
	for child in interface.get_children():
		child.position = Vector2.ZERO
	
	var unit : Unit = turn_order.pop_front()
	turn_order.push_back(unit)
	turn_order[0].start_turn()
	


func _on_button_pressed() -> void:
	# Debug only
	get_node("/root/Game/LevelManager").change_scene("world_map")
