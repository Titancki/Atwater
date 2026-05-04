@tool
extends Control

@export var data: CardData
@export var enabled_zoom := true

enum State {
	NORMAL,
	HOVER,
	PRESSED,
	DISABLED
}

var state: State = State.NORMAL

signal normal(card)
signal hover(card)
signal pressed(card)
signal disabled(card)

@onready var visual = $Visual
@onready var artwork = $Visual/VBoxContainer/PanelArtwork/TextureArtwork
@onready var title = $Visual/VBoxContainer/HBoxHeader/Title
@onready var cost = $Visual/VBoxContainer/HBoxHeader/Cost
@onready var description = $Visual/VBoxContainer/PanelContainer/Description


func _ready():
	_disable_mouse_on_children(self)
	visual.pivot_offset = visual.size / 2
	
	mouse_entered.connect(func():
		if state != State.DISABLED:
			_set_state(State.HOVER)
	)

	mouse_exited.connect(func():
		if state != State.DISABLED:
			_set_state(State.NORMAL)
	)

	normal.connect(_on_normal)
	hover.connect(_on_hover)
	pressed.connect(_on_pressed)
	disabled.connect(_on_disabled)
	setup()

func setup():
	_update_visual()
	_set_state(State.NORMAL)


func _gui_input(event):
	if state == State.DISABLED:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_set_state(State.PRESSED)
		else:
			if Rect2(Vector2.ZERO, size).has_point(get_local_mouse_position()):
				_set_state(State.HOVER)
			else:
				_set_state(State.NORMAL)


func _set_state(new_state: State):
	if state == new_state:
		return

	state = new_state

	match state:
		State.NORMAL:
			normal.emit(self)
		State.HOVER:
			hover.emit(self)
		State.PRESSED:
			pressed.emit(self)
		State.DISABLED:
			disabled.emit(self)


func _on_normal(_c):
	_apply_visual(Vector2.ONE, 0, Color(1,1,1,1))


func _on_hover(_c):
	if enabled_zoom:
		_apply_visual(Vector2(1.2, 1.2), 5, Color(1,1,1,1))


func _on_pressed(_c):
	if enabled_zoom:
		_apply_visual(Vector2(1.1, 1.1), 10, Color(0.9,0.9,0.9,1))


func _on_disabled(_c):
	_apply_visual(Vector2.ONE, 0, Color(0.5,0.5,0.5,1))


func _apply_visual(target_scale: Vector2, z: int, mod: Color):
	visual.z_index = z
	visual.scale = target_scale
	#create_tween().tween_property(visual, "scale", target_scale, 0.08)
	modulate = mod


func _update_visual():
	if not data:
		return

	artwork.texture = data.artwork
	title.text = data.card_name
	cost.text = str(data.card_cost)
	description.text = data.description
	
func _disable_mouse_on_children(node):
	for child in node.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_disable_mouse_on_children(child)

func update_playable_state(current_pa: int):
	if current_pa >= data.card_cost:
		if state == State.DISABLED:
			_set_state(State.NORMAL)
	else:
		_set_state(State.DISABLED)
	

func is_playable() -> bool :
	if state == State.DISABLED : return false
	return true
