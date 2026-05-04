@tool
extends PanelContainer

signal preview_requested(card_res)

enum State {
	NEW,
	UPDATED,
	CURRENT
}

var state : State = State.NEW
var is_pair = false
var card_data : Dictionary

func setup() -> void:
	if card_data == null:
		return
	
	$HBoxRow/Name.text = card_data.get("name", "")
	$HBoxRow/Category.text = card_data.get("category", "")
	$HBoxRow/Cost.text = str(int(card_data.get("cost", 0)))
	
	update_visual_state()

func import() -> void:
	if card_data == null:
		push_error("No card_data")
		return
	
	var card := build_card_from_api()
	
	# Ensure folder exists
	DirAccess.make_dir_recursive_absolute("res://Data/Cards")
	
	var path = get_card_path()
	
	var err = ResourceSaver.save(card, path)
	if err != OK:
		push_error("Failed saving: %s" % path)
	else:
		print("Saved:", path)
	
	# Refresh editor
	EditorInterface.get_resource_filesystem().scan()

func build_card_from_api() -> CardData:
	var card := CardData.new()
	
	card.id = int(card_data.get("id", -1))
	card.card_name = card_data.get("name", "")
	card.card_cost = card_data.get("cost", 0)
	card.description = card_data.get("info", "")
	
	card.behaviors.clear()
	
	if card_data.has("behaviours"):
		for b_data in card_data["behaviours"]:
			var behavior = create_behavior(b_data)
			if behavior:
				card.behaviors.append(behavior)
	
	return card

func create_behavior(data: Dictionary) -> Behavior:
	var type = data.get("name", "")
	
	var behavior : Behavior = null
	
	match type:
		"damage":
			behavior = DamageBehavior.new()
		"aoe":
			behavior = AoeBehavior.new()
		"armour":
			behavior = ArmourBehavior.new()
		"attract":
			behavior = AttractBehavior.new()
		"discard":
			behavior = DiscardBehavior.new()
		"draw":
			behavior = DrawBehavior.new()
		"duration":
			behavior = DurationBehavior.new()
		"echo":
			behavior = EchoBehavior.new()
		"move":
			behavior = MoveBehavior.new()
		"srange":
			behavior = RangeBehavior.new()
		"stun":
			behavior = StunBehavior.new()
		_:
			push_warning("Unknown behavior: %s" % type)
			return null
	
	var value := BehaviorValue.new()
	value.amount = str(data.get("base_value", "0"))
	value.multiplier = str(data.get("multiplier_value", "1"))
	
	behavior.value = value
	
	return behavior

func get_card_path() -> String:
	var safe_name = card_data.get("name", "").replace(" ", "_")
	return "res://Data/Cards/%s_%s.tres" % [int(card_data.get("id", -1)), safe_name]

func compute_state() -> State:
	var path = get_card_path()
	
	if !ResourceLoader.exists(path):
		return State.NEW
	
	var existing : CardData = ResourceLoader.load(path)
	var api_card = build_card_from_api()
	
	if are_cards_equal(existing, api_card):
		return State.CURRENT
	
	return State.UPDATED

func are_cards_equal(a: CardData, b: CardData) -> bool:
	if a.id != b.id:
		return false
	if a.card_name != b.card_name:
		return false
	if a.card_cost != b.card_cost:
		return false
	if a.description != b.description:
		return false
	
	if a.behaviors.size() != b.behaviors.size():
		return false
	
	for i in a.behaviors.size():
		var ba = a.behaviors[i]
		var bb = b.behaviors[i]
		
		if ba.get_class() != bb.get_class():
			return false
		
		if ba.value.amount != bb.value.amount:
			return false
		if ba.value.multiplier != bb.value.multiplier:
			return false
	
	return true

func update_visual_state():
	state = compute_state()
	
	var base_color = get_state_color(state)
	
	# Alternating rows
	if is_pair:
		base_color += Color(0.05, 0.05, 0.05)
	
	apply_row_color(base_color)
	
	# Optional: display state text
	if has_node("HBoxRow/State"):
		$HBoxRow/State.text = state_to_string(state)

func get_state_color(s: State) -> Color:
	match s:
		State.NEW:
			$HBoxRow/HBoxActions/ButtonPreview.hide()
			return Color(0.2, 0.5, 0.2) # 🟢
		State.UPDATED:
			return Color(0.6, 0.6, 0.2) # 🟡
		State.CURRENT:
			return Color(0.3, 0.3, 0.3) # ⚪
	
	return Color(1, 0, 1) # debug

func state_to_string(s: State) -> String:
	match s:
		State.NEW:
			return "NEW"
		State.UPDATED:
			return "UPDATED"
		State.CURRENT:
			return "CURRENT"
	return "UNKNOWN"

func apply_row_color(color: Color):
	var stylebox := get_theme_stylebox("panel") as StyleBoxFlat
	stylebox = stylebox.duplicate()
	stylebox.bg_color = color
	add_theme_stylebox_override("panel", stylebox)

func _on_button_import_pressed() -> void:
	if state == State.CURRENT:
		print("Already up to date")
		return
	
	import()
	update_visual_state()

func _on_button_preview_pressed() -> void:
	var card_res = load(get_card_path())
	print(card_res)
	preview_requested.emit(card_res)
