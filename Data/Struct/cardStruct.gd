class_name CardData
extends Resource

@export var id : int = -1
@export var card_name : String = ""
@export var card_cost : int = 0
@export var description : String = "An empty description"
@export var artwork : Texture
@export var behaviors : Array[Behavior]

signal played

func play(source: UnitData, target: UnitData):
	for behavior in behaviors:
		behavior.execute(source, target)

	played.emit()

func get_echo_count(source: UnitData) -> int:
	var repeat : int = 1
	for behavior in behaviors:
		if behavior is EchoBehavior:
			repeat += behavior.value.calc(source)
	return repeat

func get_aoe_radius(source: UnitData) -> int:
	var radius : int = 0
	for behavior in behaviors:
		if behavior is AoeBehavior:
			radius = behavior.value.calc(source)
	return radius
