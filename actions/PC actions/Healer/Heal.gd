extends Action

# throw configs
var target: Character
var initial_position: Vector2
var activated: bool = false
var hit: bool = false
# physics values
var SPEED: float
var THROW_TIME: float = 2 # default: 2 seconds
var TIMESTAMP: float = 0.0
@onready var throw_timer: Timer = $ThrowTimer

@onready var animatable_body: AnimatableBody2D = $AnimatableBody2D
signal target_hit

func _ready():
	# hide animatable_body
	animatable_body.visible = false
	# assign + disable target_area
	target_area = $AnimatableBody2D/Area2D
	target_area.get_child(0).disabled = true

func sort_by_distance(target1, target2):
	var target1_distance = animatable_body.global_position.distance_to(target1.global_position)
	var target2_distance = animatable_body.global_position.distance_to(target2.global_position)
	# use PlayerManager.current_player instead of player to prevent bug
	
	if target1_distance == target2_distance:
		# if distance is equal, sort by hp
		return target1.character_resource.hp < target2.character_resource.hp
	else:
		return target1_distance < target2_distance

func _get_target() -> Character:
	# get target
	var targets: Array[Node] = get_tree().get_nodes_in_group(target_group)
	targets.erase(parent)
	targets.sort_custom(sort_by_distance)
	var target: Character = null
	if targets.size() > 0:
		target = targets[0]
	
	return target

func get_bottle_speed(bottle_pos: Vector2, target_pos: Vector2, DELTA: float) -> float:
	var distance: float = bottle_pos.distance_to(target_pos)
	return distance / DELTA

func get_intercept(initial_pos: Vector2, bottle_speed: float, target_position: Vector2, target_velocity: Vector2) -> Vector2:
	# parabola trajectory calculation
	var a: float = bottle_speed*bottle_speed - target_velocity.dot(target_velocity)
	var b: float = 2*target_velocity.dot(target_pos - initial_pos)
	var c: float = (target_position - initial_position).dot(target_position - initial_pos)
	
	if bottle_speed > target_velocity.length():
		THROW_TIME = (b+sqrt(b*b + 4*a*c)) / (2*a)
	
	return target_pos + THROW_TIME*target_velocity

func _throw():
	# reset TIMESTAMP
	TIMESTAMP = 0.0
	# get target + direction + angle
	target = _get_target()
	initial_position = animatable_body.global_position
	
	# enable target_area
	target_area.get_node("CollisionShape2D").disabled = false
	
	# activate bottle
	activated = true
	# play throw animation
	anim.play("throw")
	# start timer
	throw_timer.start(THROW_TIME)

func _start():
	_throw()
	# set action_available
	action_available = false
	
	# await hit signal
	await target_hit
	print("target hit")
	# play action animation
	anim.play("action")

func _on_anim_finished(anim_name: StringName) -> void:
	if anim_name == "action":
		var parent_accuracy: float = parent.character_resource.accuracy
		var parent_power: float = parent.character_resource.power
		
		# apply heal to target
		var critical: bool = parent.character_resource._check_critical()
		var recover: int = action_resource._deal_heal(parent_accuracy, parent_power, critical)
		target._take_heal(recover, critical, parent)
		
		_stop()

func _stop():
	# reset position + visible
	animatable_body.visible = false
	animatable_body.global_position = parent.global_position
	# reset action_available
	activated = false
	hit = false
	action_available = true

func _physics_process(delta: float) -> void:
	if !activated:
		animatable_body.global_position = parent.global_position
		return
	
	# FIXME: move toward target in parabola trajectory
	TIMESTAMP += delta
	
	SPEED = get_bottle_speed(animatable_body.global_position, target.global_position, THROW_TIME-TIMESTAMP)
	var vector = (target.global_position - animatable_body.global_position).normalized()
	if hit:
		# slow down velocity
		if animatable_body.global_position.distance_to(target.global_position) < 16:
			animatable_body.global_position += Vector2.ZERO
		elif (SPEED > 0):
			animatable_body.global_position += vector * SPEED * 0.5 * delta
		else:
			animatable_body.global_position += vector * 100 * delta
	else:
		animatable_body.global_position += vector * SPEED * delta

func _on_target_area_body_entered(body) -> void:
	# recover pc health
	# get target
	if body is Character && body.is_in_group(target_group) && body != parent:
		target = body
		hit = true
		emit_signal("target_hit")
		# stop timer
		throw_timer.stop()

func _on_throw_timer_timeout():
	if hit:
		return
	
	hit = true
	emit_signal("target_hit")
