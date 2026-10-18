extends State

@export var movement_controller: MovementController

# states
@export var default_state: State

func _on_enter() -> void:
	# disable collision
	parent.get_node("CollisionShape2D").disabled = true
	# set movement_controller speed to dash-speed
	movement_controller.SPEED = movement_controller.DASH_SPEED
	super()
	
func _on_exit() -> void:
	# enable collision
	parent.get_node("CollisionShape2D").disabled = false
	# set next_state
	next_state = default_state

func _update_input(event) -> void:
	# handle basic movement
	movement_controller._handle_input(event)

func _update_physics(delta):
	movement_controller._handle_physics(delta)

func _on_animation_player_animation_finished(anim_name: String):
	if anim_name == "dash":
		# change to default-state
		emit_signal("Transition")
