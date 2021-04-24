class_name GameTree
extends Node2D

var tileMapPosition: Vector2

var trunkConnections := []
var rootConnections := []

func _init(tileMapPosition: Vector2):
	self.tileMapPosition = tileMapPosition
	
	var tileMap: TileMap = Globals.get_tiles()
	
	var trunkPosition: Vector2
	trunkPosition.x = tileMapPosition.x
	trunkPosition.y = tileMapPosition.y - 1
	addTileConnection(TileConnection.new(tileMap.getTile(tileMapPosition), tileMap.getTile(trunkPosition), 0))
	
	var rootPosition: Vector2
	rootPosition.x = tileMapPosition.x
	rootPosition.y = tileMapPosition.y + 1
	addTileConnection(TileConnection.new(tileMap.getTile(tileMapPosition), tileMap.getTile(rootPosition), 1))

func addTileConnection(tileCon: TileConnection):
	if tileCon.lineType == 0:
		trunkConnections.append(tileCon)
	else:
		rootConnections.append(tileCon)
	add_child(tileCon)
