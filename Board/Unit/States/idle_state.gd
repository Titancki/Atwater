extends UnitState

func enter(data = {}):
	unit.animator.change_animation("Idle")
	print("Idle")

func update(delta):
	pass
