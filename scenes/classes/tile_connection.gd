class_name TileConnection
extends Line2D

enum lineTypes {
	branch,
	root
}

var lineType: int

var fromTile: Tile
var toTile: Tile

func _init(fromTile: Tile, toTile: Tile, lineType: int):
	self.fromTile = fromTile
	self.toTile = toTile
	self.lineType = lineType
	
