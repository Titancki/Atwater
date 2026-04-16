extends Control

@export var data: CardData
var is_playable = true


func _ready() -> void:
	pivot_offset = Vector2(size.x / 2, size.y)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _process(_delta: float) -> void:
	$Panel/Artwork.texture = data.artwork
	$VBoxContainer/Header/HBoxContainer/Name/Label.text = data.card_name
	$VBoxContainer/Header/HBoxContainer/Cost/Label.text = str(data.card_cost)
	$VBoxContainer/Description/VBoxContainer/DescContainer/Label.text = data.description

	var tag_box = $VBoxContainer/Description/VBoxContainer/TagsContainer/BoxContainer

	for child in tag_box.get_children():
		child.queue_free()

	for tag in data.tags:
		var pill_scene = load("res://Card/tag.tscn")
		var pill = pill_scene.instantiate()
		var tag_name_str = str(Tag.tag_name.keys()[tag.tag]).capitalize()
		pill.tag_name = tag_name_str
		pill.tag_value = tag.value
		tag_box.add_child(pill)
	
	if not is_playable:
		modulate = Color(0.5, 0.5, 0.5, 1)

func _on_mouse_entered():
	scale = Vector2(1.5, 1.5)
	z_index = 1

func _on_mouse_exited():
	scale = Vector2(1.0, 1.0)
	z_index = 0
