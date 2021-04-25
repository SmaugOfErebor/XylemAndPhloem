extends AnimatedSprite

const HEART_DUR: float = 1.0

onready var delayTimer: Timer = $delay_timer
onready var nextEventTimer: Timer = $next_event_timer
onready var zParticles: CPUParticles2D = $z_particles
onready var heart: Sprite = $heart
onready var heartTween: Tween = $heart_tween

export var speed: float = 18.0
export var minEventTime: float = 15.0
export var maxEventTime: float = 40.0
export var sleepTime: float = 10.0
export var sleepChance: float = 1.0
export var isMate := false
export var dir: int = 1

var sleeping := false

func _ready():
	heart.self_modulate.a = 0.0
	delayTimer.start(rand_range(2, 5))
	nextEventTimer.start(rand_range(minEventTime, maxEventTime))
	
	if isMate:
		self_modulate = Color.limegreen

func _process(delta):
	if delayTimer.time_left <= 0 and not sleeping:
		position.x += dir * speed * delta
		if dir < 0 and position.x < -16:
			dir = 1
			delayTimer.start(rand_range(3, 8))
		elif dir > 0 and position.x > get_viewport().size.x + 16:
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

func love():
	nextEventTimer.stop()
	delayTimer.start(10.0)
	heartTween.interpolate_property(heart, "self_modulate:a", 0.0, 1.0, HEART_DUR, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	heartTween.interpolate_property(heart, "self_modulate:a", 1.0, 0.0, HEART_DUR, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, HEART_DUR)
	heartTween.start()
	yield(heartTween, "tween_completed")
	delayTimer.stop()
	nextEventTimer.start(rand_range(minEventTime, maxEventTime))

func _on_NextEventTimer_timeout():
	if randf() < sleepChance:
		sleep()

func _on_snail_detector_area_entered(area):
	var snail = area.get_parent()
	if isMate and not sleeping and not snail.sleeping:
		snail.love()
		love()
