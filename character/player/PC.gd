extends Character
class_name PlayableCharacter

@export var current: bool = false

@onready var effects_sprite: AnimatedSprite2D = $EffectsAnimatedSprite2D

func _ready() -> void:
	super()
	revivable = true
	effects_sprite.visible = false
	action_manager.input_disabled = !current || _is_dead()

func _get_actions() -> Dictionary:
	return action_manager.actions
	
func _set_current(new_current: bool) -> void:
	# set current, input_disabled
	current = new_current
	action_manager.input_disabled = !current || _is_dead()
	
	if _is_dead():
		return
	
	if current:
		# set pc state to default
		state_manager._set_current_state("default")
	else:
		# set pc state to idle
		state_manager._set_current_state("idle")

# TODO: convert eggshell into module
func _start_eggshell() -> void:
	# start eggshell
	effects_anim.play("eggshell")
