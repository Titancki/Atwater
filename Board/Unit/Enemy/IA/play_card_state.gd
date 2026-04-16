extends IAState

func enter():
	print("Play Card State")
	play_next_card()
	
func play_next_card():
	var hand = ai.get_hand()
	var card = ai.get_playable_card(hand)
	
	if not card:
		print("No more playable cards")
		ai.evaluate_best_action()
		return
	entity.animator.change_animation("Pistol_Shoot")
	await play_card(card)
	
	play_next_card()
	
func play_card(card: CardData) -> void:
	print("Playing:", card.card_name)
	entity.unit_data.use_pa(card.card_cost)
	card.play(ai.player.unit_data)
	await get_tree().create_timer(0.64).timeout
