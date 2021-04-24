class_name Root2D
extends Node2D

onready var camera: GameCam = $camera

func _process(delta):
	if Input.is_action_just_pressed("move_cam_down"):
		camera.moveToBottom()
	elif Input.is_action_just_pressed("move_cam_up"):
		camera.moveToTop()
