class_name Root2D
extends Node2D

const plTiles = preload("res://scenes/tiles.tscn")

onready var tilesContainer: Node2D = $tiles_container
onready var currencyDisplay: Control = $"../fg/currency_display"
onready var titleScreen: Node2D = $title_screen

func _ready():
	showTitleScreen()
	titleScreen.get_node("title_anim_player").play("title_bounce")

func resetScreens():
	titleScreen.visible = false
	currencyDisplay.visible = false
	$camera.moveToTop()
	$camera.lock()
	removeTilesIfNeeded()

func showTitleScreen():
	resetScreens()
	titleScreen.visible = true

func get_tiles() -> TileMap:
	return tilesContainer.get_child(tilesContainer.get_child_count() - 1) as TileMap
	
func removeTilesIfNeeded():
	if tilesContainer.get_child_count() > 0:
		get_tiles().queue_free() # also removes from tree
	
func playNewGame():
	resetScreens()
	tilesContainer.add_child(plTiles.instance())
	currencyDisplay.visible = true
	$camera.unlock()

func _on_play_btn_pressed():
	playNewGame()
