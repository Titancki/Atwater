extends Node2D
class_name Controller

@onready var unit = $".."
@onready var highlight_target = $"../../../Highlight"
@onready var highlight_info = $"../../../Highlight2"
@onready var hand = $"../Interface/Container/Hand"

var preview_path: Array[Vector2i] = []
var hovered_card: Control = null
var selected_card: Control = null
var preview_range_tiles: Array[Vector2i] = []
enum Mode {
	IDLE,
	MOVE_PREVIEW,
	PLAYING
}
var mode: Mode = Mode.IDLE


func _input(event):
	if not unit.is_my_turn:
		return

	if event is InputEventMouseButton:

		match mode:

			Mode.IDLE:
				if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
					_enter_move_preview()

				elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed and hovered_card:
					var card = get_card_under_mouse()
					if card:
						selected_card = card
						_enter_playing()
						preview_play(card)

			Mode.MOVE_PREVIEW:
				if event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
					_enter_idle()

				elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
					if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
						_confirm_move()
						_enter_idle()
			
			Mode.PLAYING:
				if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
					var target = get_target_unit_under_mouse()
					var unit_data = unit.data
					var card_data = selected_card.data

					if target and unit_data.current_pa >= card_data.card_cost:
						unit.request_play_card(card_data, target)
						_enter_idle()

				elif event.button_index == MOUSE_BUTTON_RIGHT:
					_enter_idle()

func _process(_delta):
	if not unit.is_my_turn:
		_enter_idle()
		return

	update_cards_playable()

	match mode:
		Mode.IDLE:
			update_hover()
			update_hovered_card()

		Mode.MOVE_PREVIEW:
			update_move_preview()

		Mode.PLAYING:
			update_target_preview()

func _enter_move_preview():
	mode = Mode.MOVE_PREVIEW

	selected_card = null
	preview_range_tiles.clear()
	highlight_info.clear()
	highlight_target.clear()
	highlight_target.modulate = Color(0, 1, 0, 0.7) # GREEN

	hand.hide()

func _enter_idle():
	mode = Mode.IDLE

	preview_range_tiles.clear()
	highlight_info.clear()
	highlight_target.clear()
	highlight_target.modulate = Color(1, 1, 1, 0.7)
	
	hand.show()

func _enter_playing():
	hand.hide()
	mode = Mode.PLAYING

func _confirm_move():
	if preview_path.is_empty():
		return

	var target = preview_path.back()
	unit.request_move(target)

	_enter_idle()

func update_move_preview():
	var mouse_tile = unit.board.world_to_tile(get_global_mouse_position())
	var raw_path = unit.board.compute_path(unit.current_tile, mouse_tile)

	preview_path.clear()
	highlight_target.clear()
	highlight_target.modulate = Color(0, 0.5, 0, 0.7)

	var steps :int = unit.data.current_pm
	preview_path = raw_path.slice(0, steps)
	
	for tile in preview_path:
		highlight_target.set_cell(tile, 0, Vector2.ZERO)

func _handle_left_click():
	# 1. Select card
	var card = get_card_under_mouse()
	if card:
		selected_card = card
		mode = Mode.PLAYING
		preview_play(card)
		return

	# 2. Play card
	if selected_card:
		var target = get_target_unit_under_mouse()
		if target:
			unit.request_play_card(selected_card.data, target)
			clear_selection()

func update_cards_playable():
	for card in hand.get_children():
		if not card.visible:
			continue

		card.is_playable = unit.data.current_pa >= card.data.card_cost

		if card.is_playable :
			card.modulate = Color(1,1,1)
		else:
			card.modulate = Color(0.5,0.5,0.5)

func update_hover():
	var tile = unit.board.world_to_tile(get_global_mouse_position())

	highlight_target.clear()
	highlight_target.modulate = Color(1, 1, 1, 0.7)
	highlight_target.set_cell(tile, 0, Vector2.ZERO)

func update_hovered_card():
	var mouse_pos = get_viewport().get_mouse_position()
	hovered_card = null

	for card in hand.get_children():
		if not card.visible or not card.is_playable:
			continue

		if card.get_global_rect().has_point(mouse_pos) and card.z_index > 0:
			hovered_card = card

func preview_play(card):
	highlight_info.clear()
	highlight_info.modulate = Color(0.5, 0.5, 0.5, 0.7)

	var range := _get_card_range(card)
	if range <= 0:
		return

	preview_range_tiles.clear()

	var origin = unit.current_tile

	for x in range(-range, range + 1):
		for y in range(-range, range + 1):
			if abs(x) + abs(y) <= range:
				var tile = origin + Vector2i(x, y)
				preview_range_tiles.append(tile)
				highlight_info.set_cell(tile, 0, Vector2.ZERO)

func clear_selection():
	selected_card = null
	mode = Mode.IDLE

	preview_range_tiles.clear()
	highlight_info.clear()

func update_target_preview():
	var mouse_tile = unit.board.world_to_tile(get_global_mouse_position())

	highlight_target.clear()

	if not preview_range_tiles.has(mouse_tile):
		return

	var unit_name = get_unit_name_at_tile(mouse_tile)
	if unit_name == "":
		return

	var target = $"../../".get_node_or_null(unit_name)
	if not target:
		return

	var is_buff = is_buff_card(selected_card)

	var valid := false

	if is_buff:
		valid = target.is_player == unit.is_player
	else:
		valid = target.is_player != unit.is_player

	if valid:
		highlight_target.modulate = Color(1, 0, 0, 0.7)
		highlight_target.set_cell(mouse_tile, 0, Vector2.ZERO)

func get_target_unit_under_mouse():
	var tile = unit.board.world_to_tile(get_global_mouse_position())

	if not preview_range_tiles.has(tile):
		return null

	var unit_name = get_unit_name_at_tile(tile)
	if unit_name == "":
		return null

	var target = $"../../".get_node_or_null(unit_name)
	if not target:
		return null

	var is_buff = is_buff_card(selected_card)

	if is_buff:
		if target.is_player != unit.is_player:
			return null
	else:
		if target.is_player == unit.is_player:
			return null

	return target

func get_card_under_mouse() -> Control:
	var mouse_pos = get_viewport().get_mouse_position()

	for card in hand.get_children():
		if not card.visible or not card.is_playable:
			continue

		if card.get_global_rect().has_point(mouse_pos) and card.z_index > 0:
			return card

	return null

func get_unit_name_at_tile(tile: Vector2i) -> String:
	for name in unit.board.units_position:
		if unit.board.units_position[name] == tile:
			return name
	return ""

func is_buff_card(card) -> bool:
	for tag_el in card.data.tags:
		if tag_el.tag == Tag.tag_name.BUFF:
			return true
	return false

func _get_card_range(card) -> int:
	for tag_el in card.data.tags:
		if tag_el.tag == Tag.tag_name.RANGE:
			return tag_el.value
	return 0
