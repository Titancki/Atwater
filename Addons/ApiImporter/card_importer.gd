@tool
extends Control

var http_request : HTTPRequest
var json : Array
@onready var row_scene := preload("res://Addons/ApiImporter/row.tscn")
@onready var card_preview = $BG/VBoxMain/PanelContainer/HBoxContainer/Control/CardPreview

var show_current := true
var show_updated := true
var show_new := true

func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_http_request_completed)

func _http_request_completed(result, response_code, headers, body):
	if response_code != 200:
		print("Erreur API")
		return
	json = JSON.parse_string(body.get_string_from_utf8())

func _on_button_fetch_api_pressed() -> void:
	fetch_data()
	$BG/VBoxMain/Info/VBoxContainer/Label.text = "%s card found !" % json.size()
	$BG/VBoxMain/Info/VBoxContainer/Label.show()
	await get_tree().create_timer(2.0).timeout
	$BG/VBoxMain/Info/VBoxContainer/Label.hide()
	create_array()

func fetch_data():
	var error = http_request.request("http://127.0.0.1:8000/api/cards/")
	if error != OK:
		push_error("HTTP error")

func create_array() -> void:
	var i = 0
	var table = $BG/VBoxMain/PanelContainer/HBoxContainer/VBoxContainer/ScrollTable/VBoxCardTable
	
	for row in table.get_children():
		row.queue_free()
	
	for c_data in json:
		var row = row_scene.instantiate()
		row.card_data = c_data
		row.is_pair = bool(i % 2)
		
		table.add_child(row)
		row.setup()
		row.preview_requested.connect(_on_preview_requested)
		
		i += 1
	
	apply_filters()

func apply_filters():
	var table = $BG/VBoxMain/PanelContainer/HBoxContainer/VBoxContainer/ScrollTable/VBoxCardTable
	
	for row in table.get_children():
		if !("state" in row):
			continue
		
		match int(row.state):
			0: row.visible = show_new
			1: row.visible = show_updated
			2: row.visible = show_current

func _on_check_current_toggled(toggled_on: bool) -> void:
	show_current = toggled_on
	apply_filters()

func _on_check_updated_toggled(toggled_on: bool) -> void:
	show_updated = toggled_on
	apply_filters()

func _on_check_new_toggled(toggled_on: bool) -> void:
	show_new = toggled_on
	apply_filters()

func _on_preview_requested(data: CardData):
	if not data:
		return
	
	card_preview.visible = true
	card_preview.data = data
	card_preview.setup()
