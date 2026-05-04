extends CharacterBody2D
class_name Unit

signal turn_finished
signal turn_started
signal died

@onready var state_machine: StateMachine = $StateMachine
@onready var animator := $SubViewport/UnitAnimator

@export var data: UnitData
@export var board: Node2D

var current_tile: Vector2i
var turn: int = 0
var is_my_turn := false
var is_player := false

var speed := 75.0
var target_world: Vector2
var is_moving := false

func _ready() -> void:
	data.initialize()
	if data is PlayerData:
		is_player = true
		data.initialize_deck()
	else:
		$LifeBar.max_value = data.max_life
		$LifeBar.value = data.current_life
	
	data.damaged.connect(_on_damaged)
	data.life_changed.connect(_on_life_changed)
	animator.change_animation("Idle")

func setup(start_tile: Vector2i):
	current_tile = start_tile
	global_position = board.tile_to_world(current_tile)
	board.units_position[name] = current_tile

func _physics_process(_delta):
	if is_moving:
		var dir = target_world - global_position

		if dir.length() > 2:
			velocity = dir.normalized() * speed
		else:
			global_position = target_world
			velocity = Vector2.ZERO
			is_moving = false

		move_and_slide()
	if board:
		board.units_position[name] = current_tile

func move_to_tile(tile: Vector2i):
	target_world = board.tile_to_world(tile)
	current_tile = tile
	is_moving = true

func is_arrived() -> bool:
	return not is_moving

func _process(delta):
	state_machine.update(delta)

func start_turn():
	is_my_turn = true
	turn_started.emit()
	state_machine.change_state("StartTurn")

func request_move(target_tile: Vector2i):
	state_machine.change_state("Move", {"target": target_tile})

func request_play_card(card, target):
	state_machine.change_state("PlayCard", {
		"card": card,
		"target": target
	})

func end_turn():
	is_my_turn = false
	turn_finished.emit()
	state_machine.change_state("EndTurn")
	get_parent().play_next_turn.emit()
	turn = turn + 1

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

func _on_life_changed(current: int, max: int):
	if current <= 0 : _die()
	if is_player : return
	$LifeBar.max_value = max
	$LifeBar.value = current
		
func _die():
	animator.player.play("Death01")
	await get_tree().create_timer(2.5).timeout
	if is_player: 
		pass
	else:
		queue_free()
	died.emit()
