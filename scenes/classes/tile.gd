class_name Tile

var tileId: int
var position: Vector2

var incomingConnectionTile: Tile
var outgoingConnectionTiles = []

func _init(tileId: int, position: Vector2):
	self.tileId = tileId
	self.position = position

func remove_outgoing_connection(tile: Tile):
	var indexToRemove: int = outgoingConnectionTiles.find(tile)
	
	if indexToRemove == -1:
		push_error("Tried to remove invalid tile from outgoing connections.")
	
	outgoingConnectionTiles.remove(indexToRemove)
