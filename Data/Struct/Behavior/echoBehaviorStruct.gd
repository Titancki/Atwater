class_name EchoBehavior
extends Behavior

func execute(_source: UnitData, _target: UnitData):
	pass

func get_echo_count(source: UnitData) -> int:
	return value.calc(source)
