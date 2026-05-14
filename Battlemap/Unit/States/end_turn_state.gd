extends UnitState

func enter(data = {}):
	state_machine.change_state("Idle")
