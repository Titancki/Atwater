extends UnitState

func enter(data = {}):
	print("End Turn")
	state_machine.change_state("Idle")
