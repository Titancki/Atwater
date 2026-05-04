extends Node
class_name AI

@onready var unit: Unit = get_parent()
@onready var board = unit.board
var player: Unit = null

func _ready():
	await unit.ready
	player = get_tree().get_first_node_in_group("allies")
	unit.turn_started.connect(_on_turn_started)

func _on_turn_started():
	await get_tree().process_frame # small delay (safety)
	evaluate_best_action()

func _process(delta: float) -> void:
	if not unit.is_my_turn : return
	evaluate_best_action()

func evaluate_best_action():
	print("AI evaluating...")

	# 1. Try play card
	var card = _get_playable_card()
	if card:
		var target = _get_card_target(card)
		if target:
			print("AI → PlayCard")
			unit.request_play_card(card, target)
			return

	# 2. Try move
	if _can_move():
		var tile = _get_move_target()
		if tile != unit.current_tile:
			print("AI → Move")
			unit.request_move(tile)
			return

	# 3. End turn
	print("AI → EndTurn")
	unit.end_turn()

func _get_hand() -> Array:
	return unit.data.get_current_hand(unit.turn)

func _get_playable_card():
	var hand = _get_hand()

	for card in hand:
		if _can_play_card(card):
			return card

	return null

func _can_play_card(card) -> bool:
	if card.card_cost > unit.data.current_pa:
		return false

	if not _is_in_range(card):
		return false

	return true

func _is_in_range(card) -> bool:
	var range := 0

	for behavior in card.behaviors:
		if behavior is RangeBehavior and behavior.value :
			range = behavior.value.calc(unit.data)
			break

	var dist = unit.current_tile.distance_to(player.current_tile)
	return dist <= range

func _get_card_target(card):
	# For now: always target player
	if _is_in_range(card):
		return player

	return null

func _can_move() -> bool:
	if unit.data.current_pm <= 0:
		return false

	var dist = unit.current_tile.distance_to(player.current_tile)
	return dist > 1

func _get_move_target() -> Vector2i:
	var from = unit.current_tile
	var to = player.current_tile
	var max_steps = unit.data.current_pm

	var path = board.compute_path(from, to)

	if path.is_empty():
		return from

	var last_valid = from
	var steps := 0

	for tile in path:
		if tile == from:
			continue

		if not board.is_walkable(tile):
			break

		if steps >= max_steps:
			break

		last_valid = tile
		steps += 1

	return last_valid
