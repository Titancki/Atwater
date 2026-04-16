class_name Unit
extends CharacterBody2D

@export var unit_data: UnitData
@export var board: Node2D
@onready var animator = $SubViewport/UnitAnimator
var is_my_turn := false
var turn := 1
var speed := 75.0
var path: Array[Vector2i] = []
var moving := false
var has_emitted_stop := false
var target_world: Vector2
var current_tile: Vector2i = Vector2i.ZERO

signal turn_started
signal turn_ended
signal started_moving
signal stopped_moving


func _ready() -> void:
	turn_started.connect(start_turn)
	turn_ended.connect(end_turn)
	unit_data.life_changed.connect(_on_life_changed)
	unit_data.damaged.connect(_on_damaged)
	unit_data.initialize()
	animator.change_animation("Idle")
	if unit_data.is_player:
		unit_data.initialize_deck()
		unit_data.draw_card(3)
	else:
		$LifeBar.max_value = unit_data.max_life
		$LifeBar.value = unit_data.current_life
	
func setup(start_tile: Vector2i):
	current_tile = start_tile
	global_position = board.tile_to_world(current_tile)
	board.units_position[name] = current_tile

func set_path(new_path: Array[Vector2i]):
	if new_path.is_empty():
		return

	path = new_path.duplicate()
	unit_data.use_pm(path.size())
	has_emitted_stop = false

func _physics_process(_delta):
	var from = board.ground.local_to_map(global_position)
	var to = from

	if not is_my_turn:
		board.move_astar_obstacle(from, to)
		return

	if not moving and not path.is_empty():
		_start_next_step()

	if moving:
		_process_movement()
		to = board.ground.local_to_map(target_world)
		board.units_position[name] = to
		move_and_slide()

	if not moving and path.is_empty():
		if not has_emitted_stop:
			has_emitted_stop = true
			stopped_moving.emit()

	board.move_astar_obstacle(from, to)

func _start_next_step():
	var next_tile = path.pop_front()

	if not board.is_walkable(next_tile):
		path.clear()
		return

	target_world = board.tile_to_world(next_tile)
	current_tile = next_tile
	moving = true
	started_moving.emit()

func _process_movement():
	var dir = target_world - global_position

	if dir.length() > 2:
		velocity = dir.normalized() * speed
	else:
		global_position = target_world
		velocity = Vector2.ZERO
		moving = false

func start_turn():
	is_my_turn = true
	unit_data.reset_turn_values()
	turn += 1

	if unit_data.is_player:
		unit_data.draw_card(1)

func end_turn():
	is_my_turn = false
	$"..".play_next_turn.emit()
	
func _on_life_changed(current: int, max: int):
	if unit_data.is_player : return
	$LifeBar.max_value = max
	$LifeBar.value = current
	
func _on_damaged(value: int):
	var damage_label = $Damage
	damage_label.text = str(value)
	damage_label.visible = true
	damage_label.modulate.a = 1.0

	var start_pos = Vector2.ZERO
	var peak = Vector2(randf_range(-20, 20), -40)
	var end_pos = Vector2(randf_range(-10, 10), -80)

	damage_label.position = start_pos

	var tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(damage_label, "position", peak, 0.2)
	tween.tween_property(damage_label, "position", end_pos, 0.4).set_delay(0.2)

	tween.tween_property(damage_label, "modulate:a", 0.0, 1)

	tween.finished.connect(func():
		damage_label.visible = false
		damage_label.position = Vector2.ZERO
	)
