extends Control

@export var current_loc_index : int = 1
@export var dot_offset : Vector2 = Vector2.ZERO

var last_loc_index : int = 1
var current_location_data : LocationData
var is_traveling : bool = false

signal on_node_changed


func _ready() -> void:
	on_node_changed.connect(update_travellable_nodes)

	# Init current location
	current_location_data = LocationLoader.get_by_index(current_loc_index)

	for node_btn : Button in $TravelNodes.get_children():
		var index = int(node_btn.name.replace("TravelNode", ""))
		node_btn.pressed.connect(travel_node_pressed.bind(index))

	update_travellable_nodes()

func travel_node_pressed(loc_index : int):
	if is_traveling:
		return

	last_loc_index = current_loc_index
	current_loc_index = loc_index
	current_location_data = LocationLoader.get_by_index(loc_index)

	var route_data = get_route_path(last_loc_index, current_loc_index)

	if route_data.path != null:
		is_traveling = true
		$TravelNodes.mouse_filter = Control.MOUSE_FILTER_IGNORE

		await move_along_path(route_data.path, route_data.reversed)

		$TravelNodes.mouse_filter = Control.MOUSE_FILTER_STOP
		is_traveling = false

	on_node_changed.emit()

func get_route_path(from : int, to : int) -> Dictionary:
	var forward_name = "%s-%s" % [from, to]
	var reverse_name = "%s-%s" % [to, from]

	var route = $TravelRoutes.get_node_or_null(forward_name)
	if route != null:
		return { "path": route, "reversed": false }

	route = $TravelRoutes.get_node_or_null(reverse_name)
	if route != null:
		return { "path": route, "reversed": true }

	return { "path": null, "reversed": false }

func move_along_path(path : Path2D, reversed : bool):
	var curve := path.curve
	if curve == null:
		return

	var duration := 1.0
	var elapsed := 0.0
	var length := curve.get_baked_length()

	while elapsed < duration:
		await get_tree().process_frame
		elapsed += get_process_delta_time()

		var t := elapsed / duration
		t = clamp(t, 0.0, 1.0)

		t = t * t * (3.0 - 2.0 * t)

		if reversed:
			t = 1.0 - t

		var pos := curve.sample_baked(t * length)
		$LocationDot.position = pos + dot_offset

	# Snap to final position (avoid precision issues)
	var final_t := 0.0 if reversed else 1.0
	$LocationDot.position = curve.sample_baked(final_t * length) + dot_offset

func update_travellable_nodes():
	if current_location_data == null:
		return

	var reachable := current_location_data.connected_loc_indexes.duplicate()

	for node in $TravelNodes.get_children():
		if node is Button:
			var index = int(node.name.replace("TravelNode", ""))

			var is_reachable = index in reachable

			node.disabled = not is_reachable
