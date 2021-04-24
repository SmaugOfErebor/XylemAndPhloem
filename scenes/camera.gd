class_name GameCam
extends Camera2D

const SCROLL_MOVE_SPEED := 30.0

onready var moveTween: Tween = $move_tween

export var moveDuration: float = 0.3
export var topPos: float = 0.0
export var bottomPos: float = 396.0

func _process(delta):
	if Input.is_action_just_pressed("move_cam_down"):
		moveToBottom()
	elif Input.is_action_just_pressed("move_cam_up"):
		moveToTop()
		
func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_WHEEL_UP:
			moveTween.stop_all()
			position.y -= SCROLL_MOVE_SPEED
		elif event.button_index == BUTTON_WHEEL_DOWN:
			moveTween.stop_all()
			position.y += SCROLL_MOVE_SPEED

func moveToTop():
	moveTween.stop_all()
	moveTween.interpolate_property(self, "position:y", position.y, topPos, moveDuration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	moveTween.start()
	
func moveToBottom():
	moveTween.stop_all()
	moveTween.interpolate_property(self, "position:y", position.y, bottomPos, moveDuration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	moveTween.start()
