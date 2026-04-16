extends Node

var current_state: Node = null
@onready var entity = get_parent()
@onready var data: EnemyData = entity.unit_data
@onready var board = get_tree().get_first_node_in_group("board")
@onready var player = get_tree().get_first_node_in_group("allies")

func _ready():
	await(entity.ready)
	change_state("IdleState")
	entity.turn_started.connect(start_turn_state)

func _process(delta):
	if current_state:
		current_state.process(delta)

func change_state(state_name: String):
	if current_state:
		current_state.exit()
	
	current_state = get_node(state_name)
	current_state.enter()

func start_turn_state():
	change_state("StartTurnState")

func evaluate_best_action() -> void:
	var hand = get_hand()
	var playable_card = get_playable_card(hand)
	
	if playable_card:
		print("playable card")
		change_state("PlayCardState")
	elif can_move_toward_player():
		print("can move")
		change_state("MoveState")
	else:
		change_state("EndTurnState")

func get_hand() -> Array:
	return data.get_current_hand(entity.turn)
	
func get_playable_card(hand: Array) -> CardData:
	for card in hand:
		if can_play_card(card):
			return card
	
	return null

func can_play_card(card: CardData) -> bool:
	if card.card_cost > data.current_pa:
		return false
	
	if not is_in_range(card):
		return false
	
	return true

func is_in_range(card: CardData) -> bool:
	var range := 0

	for tag_el in card.tags:
		if tag_el.tag == Tag.tag_name.RANGE:
			range = tag_el.value
			break
	var dist = entity.current_tile.distance_to(player.current_tile)
	return dist <= range
	
func can_move_toward_player() -> bool:
	if data.current_pm <= 0:
		return false
	
	var dist = entity.current_tile.distance_to(player.current_tile)
	return dist > 1

func get_reachable_tile_towards(from: Vector2i, target: Vector2i, max_steps: int) -> Vector2i:
	var full_path = board.compute_path(from, target)
	
	if full_path.is_empty():
		return from
	
	var last_valid_tile = from
	var steps := 0
	
	for tile in full_path:
		if tile == from:
			continue
		
		if not board.is_walkable(tile):
			break
		
		if steps >= max_steps:
			break
		
		last_valid_tile = tile
		steps += 1
	
	return last_valid_tile
