extends Node2D

@onready var character = $".."
@onready var highlight_target = $"../../../Highlight"
@onready var highlight_info = $"../../../Highlight2"
@onready var hand = $"../Interface/Container/Hand"

var preview_path: Array[Vector2i] = []
var hovered_card: Control = null
var selected_card: Control = null

var is_previewing_card := false
var preview_range_tiles: Array[Vector2i] = []

enum State {
	IDLE,
	MOVING,
	PLAYING
}

var state: State = State.IDLE

func _ready():
	await character.board.ready

func _input(event):
	if not character.is_my_turn:
		return

	match state:
		State.IDLE:
			if event is InputEventMouseButton and event.pressed:
				if event.button_index == MOUSE_BUTTON_RIGHT:
					enter_moving()

		State.MOVING:
			if event is InputEventMouseButton:
				if event.button_index == MOUSE_BUTTON_RIGHT and event.is_released():
					enter_idle()
				elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
					apply_move()
					enter_idle()

		State.PLAYING:
			if event is InputEventMouseButton and event.pressed:
				if event.button_index == MOUSE_BUTTON_LEFT:
					if not is_previewing_card:
						var card = get_card_under_mouse()
						if card:
							selected_card = card
							preview_play(card)
					else:
						var target = get_target_unit_under_mouse()
						var character_data = character.unit_data
						var card_data = selected_card.data

						if target and character_data.current_pa >= card_data.card_cost:
							character_data.use_pa(card_data.card_cost)
							selected_card.data.play(target.unit_data)
							character_data.discard_card_from_hand(card_data)
							$"../Interface".refresh_hand_ui()
							enter_idle()

				elif event.button_index == MOUSE_BUTTON_RIGHT:
					enter_idle()

func _process(_delta):
	if not character.is_my_turn:
		return

	update_cards_playable()

	if not is_previewing_card:
		update_hovered_card()

	match state:
		State.IDLE:
			update_hover()

		State.MOVING:
			update_move_preview()

		State.PLAYING:
			if is_previewing_card:
				update_target_preview()

func update_cards_playable():
	for card in hand.get_children():
		if not card.visible:
			continue

		card.is_playable = character.unit_data.current_pa >= card.data.card_cost

		if card.is_playable:
			card.modulate = Color(1, 1, 1)
		else:
			card.modulate = Color(0.5, 0.5, 0.5)

func enter_idle():
	state = State.IDLE
	selected_card = null
	is_previewing_card = false
	preview_path.clear()
	preview_range_tiles.clear()
	highlight_target.clear()
	highlight_info.clear()
	highlight_target.modulate = Color(1, 1, 1, 0.7)
	hand.show()

func enter_moving():
	state = State.MOVING
	highlight_target.modulate = Color(0, 0.5, 0, 0.7)
	hand.hide()

func enter_playing():
	state = State.PLAYING
	highlight_target.clear()
	hand.show()

func apply_move():
	if preview_path.is_empty():
		return
	character.set_path(preview_path)
	await character.stopped_moving

func update_move_preview():
	var mouse_tile = character.board.world_to_tile(get_global_mouse_position())
	var raw_path = character.board.compute_path(character.current_tile, mouse_tile)

	preview_path.clear()
	highlight_target.clear()

	var steps := 0

	for tile in raw_path:
		if not character.board.is_walkable(tile):
			break
		if steps >= character.unit_data.current_pm:
			break

		preview_path.append(tile)
		highlight_target.set_cell(tile, 0, Vector2.ZERO)
		steps += 1

func update_hover():
	var tile = character.board.world_to_tile(get_global_mouse_position())

	highlight_target.clear()
	highlight_target.modulate = Color(1, 1, 1, 0.7)
	highlight_target.set_cell(tile, 0, Vector2.ZERO)

func update_hovered_card():
	var mouse_pos = get_viewport().get_mouse_position()
	hovered_card = null

	for card in hand.get_children():
		if not card.visible:
			continue

		if not card.is_playable:
			continue

		if card.get_global_rect().has_point(mouse_pos) and card.z_index > 0:
			hovered_card = card

	if hovered_card and state == State.IDLE:
		enter_playing()

func preview_play(card):
	is_previewing_card = true
	hand.hide()

	highlight_info.clear()
	highlight_info.modulate = Color(0.5, 0.5, 0.5, 0.7)

	var range := 0

	for tag_el in card.data.tags:
		if tag_el.tag == Tag.tag_name.RANGE:
			range = tag_el.value
			break

	if range <= 0:
		return

	preview_range_tiles.clear()

	var origin = character.current_tile

	for x in range(-range, range + 1):
		for y in range(-range, range + 1):
			if abs(x) + abs(y) <= range:
				var tile = origin + Vector2i(x, y)
				preview_range_tiles.append(tile)
				highlight_info.set_cell(tile, 0, Vector2.ZERO)

func update_target_preview():
	var mouse_tile = character.board.world_to_tile(get_global_mouse_position())

	highlight_target.clear()

	if not preview_range_tiles.has(mouse_tile):
		return

	var unit_name = get_unit_name_at_tile(mouse_tile)
	if unit_name == "":
		return

	var target_unit = get_node_or_null("../../" + unit_name)
	if not target_unit:
		return

	var is_buff = is_buff_card(selected_card)

	var valid := false

	if is_buff:
		valid = target_unit.unit_data.is_player == character.unit_data.is_player
	else:
		valid = target_unit.unit_data.is_player != character.unit_data.is_player

	if valid:
		highlight_target.modulate = Color(1, 0, 0, 0.7)
		highlight_target.set_cell(mouse_tile, 0, Vector2.ZERO)

func get_unit_name_at_tile(tile: Vector2i) -> String:
	for name in character.board.units_position:
		if character.board.units_position[name] == tile:
			return name
	return ""

func is_buff_card(card) -> bool:
	for tag_el in card.data.tags:
		if tag_el.tag == Tag.tag_name.BUFF:
			return true
	return false

func get_card_under_mouse() -> Control:
	var mouse_pos = get_viewport().get_mouse_position()

	for card in hand.get_children():
		if not card.visible:
			continue

		if not card.is_playable:
			continue

		if card.get_global_rect().has_point(mouse_pos) and card.z_index > 0:
			return card

	return null

func get_target_unit_under_mouse():
	var tile = character.board.world_to_tile(get_global_mouse_position())

	if not preview_range_tiles.has(tile):
		return null

	var unit_name = get_unit_name_at_tile(tile)
	if unit_name == "":
		return null

	var unit = $"../../".get_node_or_null(unit_name)
	if not unit:
		return null

	var is_buff = is_buff_card(selected_card)

	if is_buff:
		if unit.unit_data.is_player != character.unit_data.is_player:
			return null
	else:
		if unit.unit_data.is_player == character.unit_data.is_player:
			return null

	return unit
