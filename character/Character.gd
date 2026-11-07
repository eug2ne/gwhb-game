extends CharacterBody2D
class_name Character

var revivable: bool
@export var character_resource: CharacterResource

@onready var indicator: CharacterIndicator = $Indicator
@onready var action_manager: ActionManager = $ActionManager
@onready var state_manager: StateManager = $StateManager
@onready var effects_anim: AnimationPlayer = $EffectsAnimationPlayer
@export var freeze_time_scale: float = 0.025 # DEFAULT for basic action
@export var freeze_duration: float = 0.5 # DEFAULT for basic action

func _ready() -> void:
	# set max_hp
	character_resource.max_hp = character_resource.hp
	# set healthbar
	indicator.healthbar.max_value = character_resource.max_hp
	indicator.healthbar.value = character_resource.hp
	indicator.healthbar.visible = character_resource.hp < character_resource.max_hp

func _take_damage(damage: int, critical: bool, _from: Character) -> void:
	# TODO: add screenshake when character take/deal damage
	# apply damage to character hp
	character_resource._apply_damage(damage)
	# pass damage to indicator
	indicator._show_damage(damage)
	# show critical
	if critical:
		indicator._show_critical()
	# play damage animation
	effects_anim.play("damage")
	if character_resource.hp == 0:
		# character death
		_take_death()

func _take_heal(recover: int, critical: bool, _from: Character) -> void:
	if state_manager.current_state.name.to_lower() == "dead":
		return
	
	# apply recover to character hp
	character_resource._apply_heal(recover)
	# pass recover to indicator
	indicator._show_damage(recover)
	# show critical
	if critical:
		indicator._show_critical()
	# play heal animation
	effects_anim.play("heal")

func _take_debuff(debuff: int, debuff_stat: String) -> void:
	# debuff character stat
	character_resource[debuff_stat] -= debuff
	# pass debuff to indicator
	indicator._show_debuff()
	if effects_anim.has_animation("debuff"):
		effects_anim.play("debuff")

func _take_death() -> void:
	# remove character from enemy target when dead
	var enemies = get_tree().get_nodes_in_group("enemy").filter(func(e: Character):
		return e.state_manager._get_current_state().name.to_lower() == "attack" && e.state_manager.current_state.target == self)
	for e in enemies:
		e.state_manager._set_current_state("idle")
	# stop character
	velocity = Vector2(0,0)
	state_manager._set_current_state("dead")
	# disable input
	action_manager.input_disabled = true

func _revive(recover: int, critical: bool) -> void:
	if state_manager.current_state.name.to_lower() == "dead":
		print("revive")
		character_resource._apply_heal(recover)
		# pass recover to indicator
		indicator._show_damage(recover)
		# show critical
		if critical:
			indicator._show_critical()
		# play heal animation
		effects_anim.play("heal")
		state_manager._set_current_state("idle")

func _is_dead() -> bool:
	return state_manager._get_current_state().name.to_lower() == "dead"

func _on_anim_started(anim_name: String) -> void:
	if (anim_name == "damage"):
		Engine.time_scale = freeze_time_scale

func _on_anim_finished(anim_name: String) -> void:
	if (anim_name == "damage"):
		Engine.time_scale = 1.0
