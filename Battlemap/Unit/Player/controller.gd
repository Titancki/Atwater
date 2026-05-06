extends Node2D

@onready var unit = $".."
@onready var highlight_target = $"../../../Highlight"
@onready var highlight_info = $"../../../Highlight2"
@onready var hand = $"../Interface/Container/Hand"

var selected_card: Control = null
var preview_range_tiles: Array[Vector2i] = []
var preview_path: Array[Vector2i] = []

enum Mode {
	IDLE,
	MOVE_PREVIEW,
	PLAYING
}

var mode: Mode = Mode.IDLE


func _ready():
	unit.data.hand_changed.connect(_connect_cards)


func _connect_cards():
	for card in hand.get_children():
		if not card.pressed.is_connected(_on_card_pressed):
			card.pressed.connect(_on_card_pressed)


# ==================================================
# INPUT
# ==================================================

func _input(event):
	if not unit.is_my_turn:
		return

	if event is InputEventMouseButton:

		match mode:

			Mode.IDLE:
				if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
					_enter_move_preview()

			Mode.MOVE_PREVIEW:
				if event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
					_enter_idle()

				elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
					if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
						_confirm_move()
						_enter_idle()

			Mode.PLAYING:
				if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
					_try_play_card()

				elif event.button_index == MOUSE_BUTTON_RIGHT:
					_enter_idle()


# ==================================================
# PROCESS
# ==================================================

func _process(_delta):

	if not unit.is_my_turn:
		_enter_idle()
		return

	update_cards_playable()

	match mode:

		Mode.IDLE:
			update_hover()

		Mode.MOVE_PREVIEW:
			update_move_preview()

		Mode.PLAYING:
			update_target_preview()


# ==================================================
# STATES
# ==================================================

func _enter_idle():

	mode = Mode.IDLE

	selected_card = null

	preview_range_tiles.clear()
	preview_path.clear()

	highlight_info.clear()
	highlight_target.clear()

	highlight_target.modulate = Color.WHITE

	_reset_units_modulate()

	hand.show()


func _enter_move_preview():

	mode = Mode.MOVE_PREVIEW

	selected_card = null

	preview_range_tiles.clear()

	highlight_info.clear()
	highlight_target.clear()

	highlight_target.modulate = Color(0, 1, 0, 0.7)

	_reset_units_modulate()

	hand.hide()


func _enter_playing():

	mode = Mode.PLAYING

	_reset_units_modulate()

	hand.hide()


# ==================================================
# CARD INTERACTION
# ==================================================

func _on_card_pressed(card):

	if mode != Mode.IDLE:
		return

	if not card.is_playable():
		return

	selected_card = card

	_enter_playing()

	preview_play(card)


func _try_play_card():

	if not selected_card:
		return

	var mouse_tile = unit.board.world_to_tile(get_global_mouse_position())

	if not preview_range_tiles.has(mouse_tile):
		return

	var target = get_target_unit_under_mouse()

	var unit_data = unit.data
	var card_data = selected_card.data

	if unit_data.current_pa < card_data.card_cost:
		return

	var aoe_radius := _get_aoe_radius(selected_card)

	# AOE cards can target empty tiles
	if aoe_radius > 0:

		if not target:
			target = Node2D.new()

		target.current_tile = mouse_tile

	else:

		if not target:
			return

	unit.request_play_card(card_data, target)

	_enter_idle()


# ==================================================
# MOVE
# ==================================================

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

	var steps: int = unit.data.current_pm

	preview_path = raw_path.slice(0, steps)

	for tile in preview_path:
		highlight_target.set_cell(tile, 0, Vector2.ZERO)


func update_hover():

	var tile = unit.board.world_to_tile(get_global_mouse_position())

	highlight_target.clear()

	highlight_target.modulate = Color(1, 1, 1, 0.7)

	highlight_target.set_cell(tile, 0, Vector2.ZERO)


# ==================================================
# CARD PREVIEW
# ==================================================

func preview_play(card):

	highlight_info.clear()

	highlight_info.modulate = Color(0.5, 0.5, 0.5, 0.5)

	var srange := _get_card_range(card)

	if srange <= 0:
		return

	preview_range_tiles.clear()

	var origin = unit.current_tile

	for x in range(-srange, srange + 1):
		for y in range(-srange, srange + 1):

			if abs(x) + abs(y) <= srange:

				var tile = origin + Vector2i(x, y)

				preview_range_tiles.append(tile)

				highlight_info.set_cell(tile, 0, Vector2.ZERO)


func update_target_preview():

	var mouse_tile = unit.board.world_to_tile(get_global_mouse_position())

	highlight_target.clear()

	_reset_units_modulate()

	if not preview_range_tiles.has(mouse_tile):
		return

	var aoe_radius := _get_aoe_radius(selected_card)

	# ------------------------------------------------
	# HOVER TILE
	# ------------------------------------------------

	highlight_target.modulate = Color(0.3, 0.3, 0.3, 0.7)
	highlight_target.set_cell(mouse_tile, 0, Vector2.ZERO)

	# ------------------------------------------------
	# AOE PREVIEW
	# ------------------------------------------------

	if aoe_radius > 0:

		for x in range(-aoe_radius, aoe_radius + 1):
			for y in range(-aoe_radius, aoe_radius + 1):

				if abs(x) + abs(y) <= aoe_radius:

					var tile = mouse_tile + Vector2i(x, y)

					# Light red AOE tiles
					highlight_target.modulate = Color(1, 0.4, 0.4, 0.5)
					highlight_target.set_cell(tile, 0, Vector2.ZERO)

					var unit_name = get_unit_name_at_tile(tile)

					if unit_name == "":
						continue

					var target = $"../../".get_node_or_null(unit_name)

					if not target:
						continue

					if target.is_player == unit.is_player:
						continue

					# Enemy unit = dark red
					target.modulate = Color(1, 0.2, 0.2)

					highlight_target.modulate = Color(1, 0, 0, 0.7)
					highlight_target.set_cell(tile, 0, Vector2.ZERO)

		return

	# ------------------------------------------------
	# SINGLE TARGET PREVIEW
	# ------------------------------------------------

	var unit_name = get_unit_name_at_tile(mouse_tile)

	if unit_name == "":
		return

	var target = $"../../".get_node_or_null(unit_name)

	if not target:
		return

	if target.is_player == unit.is_player:
		return

	target.modulate = Color(1, 0.2, 0.2)

	highlight_target.modulate = Color(1, 0, 0, 0.7)

	highlight_target.set_cell(mouse_tile, 0, Vector2.ZERO)


# ==================================================
# UTILS
# ==================================================

func update_cards_playable():

	for card in hand.get_children():

		if not card.visible:
			continue

		card.update_playable_state(unit.data.current_pa)


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

	if target.is_player == unit.is_player:
		return null

	return target


func get_unit_name_at_tile(tile: Vector2i) -> String:

	for uname in unit.board.units_position:

		if unit.board.units_position[uname] == tile:
			return uname

	return ""


func _reset_units_modulate():

	for uname in unit.board.units_position:

		var u = $"../../".get_node_or_null(str(uname))

		if u:
			u.modulate = Color.WHITE


func _get_card_range(card) -> int:

	for behavior in card.data.behaviors:

		if behavior is RangeBehavior:
			return behavior.value.calc(unit.data)

	return 0


func _get_aoe_radius(card) -> int:

	for behavior in card.data.behaviors:

		if behavior is AoeBehavior:
			return behavior.value.calc(unit.data)

	return 0
