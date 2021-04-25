extends AnimatedSprite

onready var delayTimer: Timer = $delay_timer
onready var nextEventTimer: Timer = $next_event_timer
onready var zParticles: CPUParticles2D = $z_particles

export var speed: float = 18.0
export var minEventTime: float = 15.0
export var maxEventTime: float = 40.0
export var sleepTime: float = 10.0
export var sleepChance: float = 1.0

var dir: int = 1
var sleeping := false

func _ready():
	delayTimer.start(rand_range(2, 5))
	nextEventTimer.start(rand_range(minEventTime, maxEventTime))

func _process(delta):
	if delayTimer.time_left <= 0 and not sleeping:
		position.x += dir * speed * delta
		if dir < 0 and position.x < -16:
			dir = 1
			delayTimer.start(rand_range(3, 8))
		elif dir > 0 and position.x > get_viewport().size.x:
			dir = -1
			delayTimer.start(rand_range(3, 8))
	flip_h = (dir > 0)

func sleep():
	sleeping = true
	zParticles.visible = true
	play("sleep")
	yield(get_tree().create_timer(sleepTime), "timeout")
	play("awake")
	zParticles.visible = false
	yield(get_tree().create_timer(1.0), "timeout")
	play("walk")
	sleeping = false
	nextEventTimer.start(rand_range(minEventTime, maxEventTime))

func _on_NextEventTimer_timeout():
	if randf() < sleepChance:
		sleep()
