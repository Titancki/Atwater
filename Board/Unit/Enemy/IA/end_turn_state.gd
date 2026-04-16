extends IAState

func enter():
	print("End Turn State")
	ai.change_state("IdleState")
	entity.end_turn()
