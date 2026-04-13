extends CanvasLayer
@onready var character = $".."
@onready var card_ui_scene = load("res://Card/card.tscn")
@onready var card_window_scene = load("res://Board/Interface/window.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	character.unit_data.hand_changed.connect(refresh_hand_ui)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$CharInfo/PM/Label.text = "PM %s/%s " % [character.unit_data.current_pm, character.unit_data.max_pm]
	$CharInfo/PA/Label.text = "PA %s/%s" % [character.unit_data.current_pa, character.unit_data.max_pa]
	$CharInfo/Life.max_value = character.unit_data.max_life
	$CharInfo/Life.value = character.unit_data.current_life
	$Container/Zones/DrawBtn/Label.text = str(character.unit_data.draw.size())
	$Container/Zones/DiscardBtn/Label.text = str(character.unit_data.discard.size())
	$Container/Zones/DeckBtn/Label.text = str(character.unit_data.deck.size())
	
	
func refresh_hand_ui():
	var hand = character.unit_data.hand
	var hand_ui = $Container/Hand
	for card_ui in hand_ui.get_children():
		card_ui.queue_free()
	for card in hand:
		var card_ui = card_ui_scene.instantiate()
		card_ui.data = card
		hand_ui.add_child(card_ui)

func _on_btn_pressed() -> void:
	character.turn_ended.emit()


func _on_draw_btn_pressed() -> void:
	var card_window = card_window_scene.instantiate()
	card_window.window_name = "Draw Cards"
	card_window.cards = character.unit_data.draw
	add_child(card_window)

func _on_discard_btn_pressed() -> void:
	var card_window = card_window_scene.instantiate()
	card_window.window_name = "Discard Cards"
	card_window.cards = character.unit_data.discard
	add_child(card_window)

func _on_deck_btn_pressed() -> void:
	print("deck btn")
	var card_window = card_window_scene.instantiate()
	card_window.window_name = "Deck Cards"
	card_window.cards = character.unit_data.deck
	add_child(card_window)
