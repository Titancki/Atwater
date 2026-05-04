class_name CardData
extends Resource

@export var id : int = -1
@export var card_name : String = ""
@export var card_cost : int = 0
@export var description : String = "An empty description"
@export var artwork : Texture
@export var behaviors : Array[Behavior]

signal played

func play(source: UnitData, target : UnitData):
	for behavior in behaviors:
		behavior.execute(source, target)
	played.emit()
