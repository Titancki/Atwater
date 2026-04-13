extends HBoxContainer

var tag_name : String = ""
var tag_value : int = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready() -> void:
	$Name/Label.text = tag_name
	$Value/Label.text = str(tag_value)
