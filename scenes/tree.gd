class_name GameTree
extends Node2D

var tileMapPosition: Vector2

var trunk: TileConnection
var root: TileConnection

func _init(tileMapPosition: Vector2):
	self.tileMapPosition = tileMapPosition
	
	var tileMap: TileMap = Globals.get_tiles()
	
	var trunkPosition: Vector2
	trunkPosition.x = tileMapPosition.x
	trunkPosition.y = tileMapPosition.y - 1
	trunk = TileConnection.new(tileMap.getTile(tileMapPosition), tileMap.getTile(trunkPosition), 0)
	add_child(trunk)
	
	var rootPosition: Vector2
	rootPosition.x = tileMapPosition.x
	rootPosition.y = tileMapPosition.y + 1
	root = TileConnection.new(tileMap.getTile(tileMapPosition), tileMap.getTile(rootPosition), 1)
	add_child(root)
