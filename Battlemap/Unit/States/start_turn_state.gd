extends UnitState

func enter(data = {}):
	print("Start Turn ", unit.name)
	unit.is_moving = false
	unit.data.reset_turn_values()
	if unit.is_player:
		unit.data.discard_hand()
		unit.data.draw_card(4)
