extends TextureRect
@export var artwork : Texture2D
@export var unit_name : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Artwork.texture = artwork
	$UnitName.text = unit_name


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
