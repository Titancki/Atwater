class_name BehaviorValue
extends Resource

## Base value. Can only be a PlayerUnit var or a float. 
@export var amount : String = "0"
## Multiply the base value. Can only be a PlayerUnit var or a float. 
@export var multiplier : String = "1" 


func calc(source: UnitData) -> int :
	var parsed_amount : float = 0.0
	var parsed_multiplier : float = 1.0
	if amount.is_valid_float():
		parsed_amount = float(amount)
	elif source.get(amount):
		parsed_amount = float(source.get(amount))
		
	if multiplier.is_valid_float():
		parsed_multiplier = float(multiplier)
	elif source.get(multiplier):
		parsed_multiplier = float(source.get(multiplier))
		
	return roundi(parsed_amount * parsed_multiplier) 
	
