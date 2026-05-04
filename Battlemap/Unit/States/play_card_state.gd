extends UnitState

var card
var target

func enter(data = {}):
	print("Play Card State")

	card = data.get("card", null)
	target = data.get("target", null)

	if not card or not target:
		state_machine.change_state("Idle")
		return

	if unit.data.current_pa < card.card_cost:
		print("Not enough PA")
		state_machine.change_state("Idle")
		return

	unit.animator.change_animation("Pistol_Shoot")
	unit.data.use_pa(card.card_cost)
	card.play($"../..".data, target.data)
	await get_tree().create_timer(0.67).timeout
	if unit.is_player:
		unit.data.discard_card_from_hand(card)
	state_machine.change_state("Idle")
