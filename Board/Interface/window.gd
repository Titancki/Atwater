extends Control
@export var window_name : String = ""
@export var cards : Array[CardData]
@onready var card_ui_scene = load("res://Card/card.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/Header/HBoxContainer/Label.text = window_name
	for card in cards:
		var card_ui = card_ui_scene.instantiate()
		card_ui.data = card
		$VBoxContainer/Main/ScrollContainer/GridContainer.add_child(card_ui)

func _on_close_pressed() -> void:
	print("clicked")
	queue_free()
