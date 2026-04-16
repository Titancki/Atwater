extends IAState

func enter():
	print("AI Idle")
	entity.animator.change_animation("Idle")
