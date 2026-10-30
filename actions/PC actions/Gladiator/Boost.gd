extends Action

@onready var boost_timer: Timer = $BoostTimer
var boost_time: float = 5
var base_power: float
var base_critical: float


func _process(_delta) -> void:
	# place target_area according to parent position + direction
	target_area.global_position = parent.global_position

func _start() -> void:
	super()
	base_power = parent.character_resource.power
	base_critical = parent.character_resource.critical
	# add bonus ap, critical rate
	parent.character_resource.power *= 1.2
	parent.character_resource.critical *= 1.2
	# start boost-timer
	boost_timer.start(boost_time)

func _on_boost_timer_timeout():
	# stop animation
	anim.stop()
	target_area.visible = false
	# reset bonus ap, critical rate
	parent.character_resource.power = base_power
	parent.character_resource.critical = base_critical
	base_power = 0
	base_critical = 0
