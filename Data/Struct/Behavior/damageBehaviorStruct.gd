class_name DamageBehavior
extends Behavior

func execute(_source: UnitData, _target: UnitData):
	_target.take_damage(value.calc(_source))
