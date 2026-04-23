class_name PlayerData
extends UnitData

@export var deck : Array[CardData]
@export var max_hand_size : int = 10
var draw : Array[CardData] = []
var discard : Array[CardData] = []
var hand : Array[CardData] = []
var current_location : LocationData = LocationLoader.loc_1
signal hand_changed

func initialize_deck() -> void:
	draw = deck.duplicate()
	draw.shuffle()
	discard.clear()
	hand.clear()
	save()

func add_card_to_deck(card : CardData) -> void :
	deck.append(card)
	save()
	
func remove_card_from_deck(card : CardData) -> void :
	deck.erase(card)
	save()
	
func draw_card(times: int = 1) -> void:
	for i in range(times):
		if draw.is_empty():
			reshuffle_discard_into_draw()

		var card = draw.pop_front()

		if hand.size() >= max_hand_size:
			discard.append(card)
		else:
			hand.append(card)
			hand_changed.emit()

	save()
	
func fetch_card_from_draw(card : CardData) -> void :
	draw.erase(card)
	hand.append(card)
	save()

func fetch_card_from_discard(card : CardData) -> void :
	discard.erase(card)
	hand.append(card)
	save()

func discard_card_from_draw(card : CardData) -> void :
	draw.erase(card)
	discard.append(card)
	save()

func discard_card_from_hand(card : CardData) -> void :
	hand.erase(card)
	discard.append(card)
	hand_changed.emit()
	save()

func reshuffle_discard_into_draw() -> void:
	if discard.is_empty():
		return

	draw = discard.duplicate()
	discard.clear()
	draw.shuffle()

func change_location_by_index(index) -> void:
	var new_loc = LocationLoader.get("loc_%s" % index)
	current_location = new_loc
	save()

func save() -> void :
	ResourceSaver.save(self, "res://Data/Units/player.tres")
	
