extends UnitState

var card
var targets = []

func enter(data = {}):
	print("Play Card State")

	card = data.get("card", null)

	if not card:
		state_machine.change_state("Idle")
		return

	if unit.data.current_pa < card.card_cost:
		print("Not enough PA")
		state_machine.change_state("Idle")
		return

	unit.data.use_pa(card.card_cost)

	var repeat : int = card.get_echo_count(unit.data)
	
	var aoe_radius : int = card.get_aoe_radius(unit.data)
	if aoe_radius > 0:
		targets = _get_aoe_targets(data.get("target", null).current_tile, aoe_radius)
	else:
		targets.append(data.get("target", null))
	
	for i in range(repeat):
		unit.animator.change_animation("Pistol_Shoot")

		for target in targets:
			print(target.name, target.data.current_life)
			card.play($"../..".data, target.data)

		await get_tree().create_timer(0.67).timeout

	if unit.is_player:
		unit.data.discard_card_from_hand(card)

	state_machine.change_state("Idle")
	
func _get_aoe_targets(center_tile: Vector2i, radius: int) -> Array:
	var result: Array = []
	
	for uname in unit.board.units_position:
		var tile: Vector2i = unit.board.units_position[uname]

		var dist = abs(tile.x - center_tile.x) + abs(tile.y - center_tile.y)

		if dist <= radius:
			var u = $"../../..".get_node(str(uname))
			if u and u.is_player != unit.is_player:
				result.append(u)
				
		
	return result
