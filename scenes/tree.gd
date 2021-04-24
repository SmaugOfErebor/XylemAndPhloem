class_name GameTree

var position: Vector2

var trunk: TileConnection
var root: TileConnection

func _init(position: Vector2):
	self.position = position
	
	var tileMap: TileMap = Globals.get_tiles()
	
	var trunkPosition: Vector2
	trunkPosition.x = position.x
	trunkPosition.y = position.y - 1
	trunk = TileConnection.new(tileMap.getTile(position), tileMap.getTile(trunkPosition), 0)
	
	var rootPosition: Vector2
	rootPosition.x = position.x
	rootPosition.y = position.y + 1
	root = TileConnection.new(tileMap.getTile(position), tileMap.getTile(rootPosition), 1)
