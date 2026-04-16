class_name EnemyData
extends UnitData

@export var turn_hands: Array[Array] = []
@export var loop_pattern: bool = true

func get_current_hand(turn : int) -> Array:
	if turn_hands.is_empty():
		return []
	
	var turn_index = turn % turn_hands.size()
	var hand = turn_hands[turn_index]

	return hand
