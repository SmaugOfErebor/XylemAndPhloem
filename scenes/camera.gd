class_name GameCam
extends Camera2D

const SCROLL_MOVE_SPEED := 30.0

onready var moveTween: Tween = $move_tween

export var moveDuration: float = 0.3
export var topPos: float = 0.0
export var bottomPos: float = 396.0
export var shakeDecay: float = 0.05
export var shakeThresh: float = 0.3
export var shakeLimit: float = 6.0

var shakePower: float = 0.0
var realPosition := Vector2()
var locked := false

func _ready():
	realPosition = position

func lock():
	locked = true
	
func unlock():
	locked = false

func _process(delta):
	position = realPosition
	
	if delta == 0 or locked:
		return
		
	if shakePower > shakeThresh:
		position += Vector2(rand_range(-shakePower, shakePower), rand_range(-shakePower, shakePower))
		shakePower -= shakePower * shakeDecay
		if shakePower < 0:
			shakePower = 0
	else:
		shakePower = 0.0
	
	if Input.is_action_just_pressed("move_cam_down"):
		moveToBottom()
	elif Input.is_action_just_pressed("move_cam_up"):
		moveToTop()
		
func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_WHEEL_UP:
			moveTween.stop_all()
			realPosition.y -= SCROLL_MOVE_SPEED
		elif event.button_index == BUTTON_WHEEL_DOWN:
			moveTween.stop_all()
			realPosition.y += SCROLL_MOVE_SPEED
	if realPosition.y < topPos:
		realPosition.y = topPos

func shake(power: float):
	shakePower += power
	if shakePower < 0:
		shakePower = 0
	elif shakePower > shakeLimit:
		shakePower = shakeLimit

func moveToTop():
	moveTween.stop_all()
	moveTween.interpolate_property(self, "realPosition:y", realPosition.y, topPos, moveDuration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	moveTween.start()
	
func moveToBottom():
	moveTween.stop_all()
	moveTween.interpolate_property(self, "realPosition:y", realPosition.y, bottomPos, moveDuration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	moveTween.start()
