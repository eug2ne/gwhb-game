extends Node
class_name ActionManager

@export var parent: Character
@export var indicator: CharacterIndicator
@export var input_disabled: bool # if true, do not deal input

# actions
@export var basic_action: Action
@export var secondary_action: Action
@export var special_action: Action
var actions: Dictionary = {}

func _ready():
	if parent is PlayableCharacter:
		input_disabled = !parent.current && parent.character_resource.hp == 0
	
	for child in get_children():
		if child is Action:
			actions[child.name.to_lower()] = child
			child.parent = parent
			child.indicator = indicator
		else:
			push_warning("WARNING: " + child.name + " is not State.")

func _input(event):
	if input_disabled:
		return
	
	# deal input
	if event.is_action_pressed("basic_action") && basic_action.action_available:
		basic_action._start()
	
	if event.is_action_pressed("secondary_action") && secondary_action.action_available:
		secondary_action._start()
	
	if event.is_action_pressed("special_action") && special_action.action_available:
		special_action._start()

func _start_action(action_key: String, direction: Vector2i = Vector2i(0,0)):
	if !actions.get(action_key):
		# action_key unavailable
		return
		
	var new_action: Action = actions.get(action_key)
	if new_action.action_available:
		if new_action.has_method("_lock_on"):
			# start lockon
			new_action._lock_on(direction)
		else:
			# start action
			new_action._start()
	
func _stop_action(action_key: String):
	if !actions.get(action_key):
		# action_key unavailable
		return
		
	actions.get(action_key)._stop()
