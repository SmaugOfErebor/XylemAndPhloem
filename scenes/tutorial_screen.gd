extends Node2D

onready var images: Node2D = $images

var nextImgIdx: int = 0

func reload():
	for child in images.get_children():
		child.visible = false
	nextImgIdx = 0
	next()

func next():
	if nextImgIdx > 0:
		images.get_child(nextImgIdx - 1).visible = false
	if nextImgIdx < images.get_child_count():
		images.get_child(nextImgIdx).visible = true
	else:
		Globals.get_root2d().playNewGame()
	nextImgIdx += 1

func _on_next_btn_pressed():
	next()

func _on_skip_btn_pressed():
	nextImgIdx = images.get_child_count()
	next()
