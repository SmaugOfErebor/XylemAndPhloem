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
	
	if lineType == lineTypes.branch:
		default_color = Color(.29, .16, .04, 1.0)
	else:
		default_color = Color(.88, .67, .47, 1.0)
	
	add_point(Globals.get_tiles().getCenterPixelPosition(fromTile))
	add_point(Globals.get_tiles().getCenterPixelPosition(toTile))
