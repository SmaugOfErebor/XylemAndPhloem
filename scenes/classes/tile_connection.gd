class_name TileConnection
extends Line2D

enum lineTypes {
	branch,
	root
}

var lineType: int

var fromTile: Tile
var toTile: Tile

var leafSprite: Sprite
var terminationPosition: Vector2

func _init(fromTile: Tile, toTile: Tile, lineType: int):
	self.fromTile = fromTile
	self.toTile = toTile
	self.lineType = lineType
	
	if lineType == lineTypes.branch:
		default_color = Color(.29, .16, .04, 1.0)
	else:
		default_color = Color(.88, .67, .47, 1.0)
	
	width = 4
	
	# Store the termination position to draw a leaf at
	terminationPosition = Globals.get_tiles().getCenterPixelPosition(toTile)
	
	add_point(Globals.get_tiles().getCenterPixelPosition(fromTile))
	add_point(terminationPosition)

func add_leaf():
	leafSprite = Sprite.new()
	leafSprite.texture = load("res://images/leaf.png")
	leafSprite.position = terminationPosition
	add_child(leafSprite)
	toTile.hasLeaf = true

func remove_leaf():
	remove_child(leafSprite)
	toTile.hasLeaf = false
