extends Node
class_name StateMachine

var current_state: UnitState = null


func change_state(name: String, data = {}):
	if current_state:
		current_state.exit()

	current_state = get_node(name)

	if current_state:
		current_state.enter(data)

func update(delta):
	if current_state:
		current_state.update(delta)
