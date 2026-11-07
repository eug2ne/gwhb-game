extends EnemyState

var target: Character
var lockon: bool = false
var attack_direction: Vector2i

func _on_enter() -> void:
	# play alert animation
	lockon = true
	indicator._start_alert()
	await indicator._end_alert
	lockon = false
	# set speed to moving speed
	SPEED = MOVE_SPEED
	super()

func _update_physics(_delta) -> void:
	if !target:
		return
	if lockon:
		# no physics update during lockon + attack
		return
		
	var distance: float = parent.global_position.distance_to(target.global_position)
	var direction: Vector2 = (target.global_position - parent.global_position).normalized()
	if distance <= 50 && action_manager.actions.get("attack").action_available:
		# stop parent
		parent.velocity = Vector2(0,0)
		# start attack
		var attack_direction: Vector2i = _get_attack_direction((parent.global_position - target.global_position).normalized())
		action_manager._start_action("attack", attack_direction)
		# set lockon true
		lockon = true
	else:
		# follow target
		parent.velocity = direction * SPEED

func _set_target(new_target: Character) -> void:
	# set target + target_chase to true
	target = new_target
	
func _get_attack_direction(direction: Vector2) -> Vector2i:
	# return 4-direction attack-direction
	var zero_vector: Vector2 = Vector2(1,0)
	if direction.angle_to(zero_vector) > -PI/4 && direction.angle_to(zero_vector) < PI/4:
		return Vector2i(-1,0)
	elif direction.angle_to(zero_vector) >= PI/4 && direction.angle_to(zero_vector) <= 3 * PI/4:
		return Vector2i(0,1)
	elif direction.angle_to(zero_vector) <= -PI/4 && direction.angle_to(zero_vector) >= -3 * PI/4:
		return Vector2i(0,-1)
	else:
		return Vector2i(1,0)

func _on_attack_action_end(action):
	# set lockon to false
	lockon = false
