class_name Root2D
extends Node2D

const plTiles = preload("res://scenes/tiles.tscn")

onready var tilesContainer: Node2D = $tiles_container
onready var currencyDisplay: Control = $"../fg/currency_display"
onready var titleScreen: Node2D = $title_screen
onready var gameOverScreen: Node2D = $game_over_screen
onready var gameOverWon: Label = $game_over_screen/won_label
onready var gameOverLost: Label = $game_over_screen/lost_label
onready var tutScreen: Node2D = $tutorial_screen

func _ready():
	showTitleScreen()
	titleScreen.get_node("title_anim_player").play("title_bounce")

func resetScreens():
	titleScreen.visible = false
	gameOverScreen.visible = false
	currencyDisplay.visible = false
	tutScreen.visible = false
	$camera.moveToTop()
	$camera.lock()
	removeTilesIfNeeded()

func showTutorialScreen():
	resetScreens()
	tutScreen.visible = true
	tutScreen.reload()

func showTitleScreen():
	resetScreens()
	titleScreen.visible = true
	
func showGameOverScreen(won: bool):
	resetScreens()
	gameOverScreen.visible = true
	gameOverWon.visible = won
	gameOverLost.visible = not won

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
	showTutorialScreen()

func _on_menu_btn_pressed():
	showTitleScreen()
