class_name GameCam
extends Camera2D

onready var moveTween: Tween = $move_tween

export var moveDuration: float = 0.3
export var topPos: float = 0.0
export var bottomPos: float = 396.0

func moveToTop():
	moveTween.stop_all()
	moveTween.interpolate_property(self, "position:y", position.y, topPos, moveDuration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	moveTween.start()
	
func moveToBottom():
	moveTween.stop_all()
	moveTween.interpolate_property(self, "position:y", position.y, bottomPos, moveDuration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	moveTween.start()
