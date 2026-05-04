extends Control

@onready var reward_choices := $VBoxContainer/HBoxReward

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for cardbox in reward_choices.get_children():
		var card = cardbox.get_node("Card")
		card.hover.connect(_on_hover)
		card.pressed.connect(_on_pressed)
		card.normal.connect(_on_normal)

func _on_button_continue_pressed() -> void:
	get_node("/root/Game/LevelManager").change_scene("world_map")

func _on_hover(card) -> void :
	pass
	
func _on_pressed(card) -> void:
	get_node("/root/Game").player.add_card_to_deck(card.data)
	$VBoxContainer/HBoxReward.hide()

func _on_normal(card) -> void:
	pass
