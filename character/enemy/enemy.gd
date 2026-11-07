extends Character

@export var target_group: String


func _ready():
	super()
	revivable = false

func _physics_process(_delta) -> void:
	move_and_slide()

func _take_damage(damage: int, critical: bool, from: Character) -> void:
	super(damage, critical, from)
	
	if character_resource.hp != 0:
		# change state to attack + set target
		state_manager._set_current_state("attack")
		state_manager.current_state.target = from

func _on_area_2d_body_entered(body):
	if body is Character && body.is_in_group(target_group) && !body._is_dead():
		# change state to attack
		state_manager._set_current_state("attack")
		# assign target to attack state
		if state_manager.current_state.name.to_lower() != "dead":
			state_manager.current_state.target = body
