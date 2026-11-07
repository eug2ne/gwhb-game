extends Action
# TODO: create eggshell (egg protection to all pcs for 10 sec)

@onready var pc_group: Array[Node] = get_tree().get_nodes_in_group("pc")

func _start() -> void:
	# heal + create eggshell to all pcs
	for pc: Node in pc_group:
		pc._take_heal(action_resource.base_damage, false, parent)
		pc._start_eggshell()
	
	# start cool-time timer
	action_available = false
	timer.start(cool_time)

func _stop() -> void:
	super()
