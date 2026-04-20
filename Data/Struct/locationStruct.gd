class_name LocationData
extends Resource

@export var node_index : int
@export var loc_name : String = ""
@export var connected_loc_indexes : Array[int] = []

func get_connected_location() -> Array[LocationData]:
	var connected_locations : Array[LocationData] = []
	
	for loc_index in connected_loc_indexes:
		connected_locations.append(LocationLoader.get_by_index(loc_index))
		
	return connected_locations
