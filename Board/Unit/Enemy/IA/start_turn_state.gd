extends IAState

func enter():
	print("Start turn state")
	entity.unit_data.reset_turn_values()
	ai.evaluate_best_action()
