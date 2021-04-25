class_name TileConnection
extends Line2D

const plRootNoise: Texture = preload("res://images/root_noise.png")
const plTrunkNoise: Texture = preload("res://images/trunk_noise.png")

enum lineTypes {
	branch,
	root
}

var lineType: int

var fromTile: Tile
var toTile: Tile

var leafSprite: Sprite
var terminationPosition: Vector2

const THICKNESS_POWER: float = 1.3

func _init(fromTile: Tile, toTile: Tile, lineType: int):
	self.fromTile = fromTile
	self.toTile = toTile
	self.lineType = lineType
	
	begin_cap_mode = Line2D.LINE_CAP_ROUND
	end_cap_mode = Line2D.LINE_CAP_ROUND
	
	default_color = Color.white
	#if lineType == lineTypes.branch:
	#	default_color = Color(.29, .16, .04, 1.0)
	#else:
	#	default_color = Color(.88, .67, .47, 1.0)
		
	texture_mode = Line2D.LINE_TEXTURE_TILE
	texture = plRootNoise if lineType == lineTypes.root else plTrunkNoise
	
	# Store the termination position to draw a leaf at
	terminationPosition = Globals.get_tiles().getCenterPixelPosition(toTile)
	
	add_point(Globals.get_tiles().getCenterPixelPosition(fromTile))
	add_point(terminationPosition)
	
	reevaluateThickness()

func add_leaf():
	leafSprite = Sprite.new()
	leafSprite.texture = load("res://images/leaf.png")
	leafSprite.position = terminationPosition
	add_child(leafSprite)
	toTile.hasLeaf = true

func remove_leaf():
	remove_child(leafSprite)
	toTile.hasLeaf = false

func reevaluateThickness():
	var toTileChildren: int = toTile.get_descendant_tile_count()
	var tempThickness: int = 1
	var currentThicknessToBeat: float = THICKNESS_POWER * THICKNESS_POWER
	while toTileChildren > currentThicknessToBeat:
		currentThicknessToBeat *= THICKNESS_POWER
		tempThickness += 1
	width = tempThickness
	
	if fromTile.incomingConnection != null:
		fromTile.incomingConnection.reevaluateThickness()
