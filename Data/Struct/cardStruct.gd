class_name CardData
extends Resource

@export var card_name : String = ""
@export var card_cost : int = 0
@export var description : String = "An empty description"
@export var artwork : Texture
@export var tags : Array[Tag]

signal played

func play(target: UnitData):
	for tag in tags:
		match tag.tag:
			Tag.tag_name.DAMAGE:
				target.take_damage(tag.value)

	played.emit()
