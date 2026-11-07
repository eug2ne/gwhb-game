extends EnemyAction

func _on_target_area_body_entered(body) -> void:
	# get target
	if body is Character && body.is_in_group(target_group):
		target = body

func _on_animation_finished(_anim_name: String) -> void:
	# deal damage on target
	_deal_damage()
	super(_anim_name)

func _deal_damage() -> void:
	if !target:
		return
	
	# apply damage to targeta
	var parent_accuracy: float = parent.character_resource.accuracy
	var parent_power: float = parent.character_resource.power
	var target_agility = target.character_resource.agility
	var target_defense = target.character_resource.defense
	
	var miss: bool = parent.character_resource._check_miss(target_agility)
	if miss:
		target._take_damage(0, false, parent)
	
	var critical: bool = parent.character_resource._check_critical()
	var damage: float = action_resource._deal_damage(target_agility, target_defense, parent_accuracy, parent_power, critical)
	if damage < 0:
		damage = 0
	# frame freeze
	if critical:
		_frame_freeze(freeze_time_scale * 1.5, freeze_duration)
	else:
		_frame_freeze(freeze_time_scale, freeze_duration)
	target._take_damage(damage, critical, parent)
