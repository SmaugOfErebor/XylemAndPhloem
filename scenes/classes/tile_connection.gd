class_name TileConnection
extends Line2D

const GROW_POINT_TIME: float = 0.03

const plRootNoise: Texture = preload("res://images/root_noise.png")
const plTrunkNoise: Texture = preload("res://images/trunk_noise.png")
const plTrunkNoiseEnemy: Texture = preload("res://images/enemy_trunk_noise.png")

const POINT_ROOT_STEPS: int = 10
const POINT_TRUNK_STEPS: int = 7
const TRUNK_VARIATION_PROB: float = 0.3

enum lineTypes {
	branch,
	root
}

var lineType: int

var fromTile: Tile
var toTile: Tile

var leafSprite: Sprite
var startPos: Vector2
var terminationPosition: Vector2

var generatedPointsToAdd := []

var waterBenefit: int = 0

const THICKNESS_POWER: float = 1.3

func _init(fromTile: Tile, toTile: Tile, lineType: int):
	self.fromTile = fromTile
	self.toTile = toTile
	self.lineType = lineType
	
	begin_cap_mode = Line2D.LINE_CAP_ROUND
	end_cap_mode = Line2D.LINE_CAP_ROUND
	
	default_color = Color.white if fromTile.ownerId == Globals.OWNER_PLAYER else Color.lightcoral
	#if lineType == lineTypes.branch:
	#	default_color = Color(.29, .16, .04, 1.0)
	#else:
	#	default_color = Color(.88, .67, .47, 1.0)
		
	texture_mode = Line2D.LINE_TEXTURE_TILE
	texture = plRootNoise if lineType == lineTypes.root else (plTrunkNoise if fromTile.ownerId == Globals.OWNER_PLAYER else plTrunkNoiseEnemy)
	
	# Store the termination position to draw a leaf at
	terminationPosition = Globals.get_tiles().getCenterPixelPosition(toTile)
	startPos = Globals.get_tiles().getCenterPixelPosition(fromTile)
	var fullVec: Vector2 = terminationPosition - startPos
	
	var steps: int = POINT_ROOT_STEPS if lineType == lineTypes.root else POINT_TRUNK_STEPS
	for i in range(steps + 1):
		var variation := Vector2()
		if i > 0 and i < steps:
			if lineType == lineTypes.root:
				variation = Vector2(rand_range(-2, 2), rand_range(-2, 2))
			elif randf() < TRUNK_VARIATION_PROB:
				variation = Vector2(rand_range(-2, 2), rand_range(-2, 2))
		generatedPointsToAdd.append(startPos + (((i as float) / (steps as float)) * fullVec) + variation)
	
	reevaluateThickness()
	match lineType:
		lineTypes.branch: Audio.playLeafSound()
		lineTypes.root: Audio.playRootSound()
		
	generateNextPoint()

func generateNextPoint():
	var point: Vector2 = generatedPointsToAdd.pop_front()
	add_point(point)
	if leafSprite:
		leafSprite.position = point
	if generatedPointsToAdd.size() > 0:
		yield(Globals.get_tiles().get_tree().create_timer(GROW_POINT_TIME), "timeout")
		generateNextPoint()

func changeWaterBenefit(amount: int):
	if amount <= 0:
		return
	waterBenefit += amount

func add_leaf():
	leafSprite = Sprite.new()
	leafSprite.texture = load("res://images/leaf_100.png")
	leafSprite.position = terminationPosition if generatedPointsToAdd.size() <= 0 else generatedPointsToAdd.front()
	leafSprite.rotation = (terminationPosition - startPos).normalized().angle()
	leafSprite.self_modulate = Color.white if fromTile.ownerId == Globals.OWNER_PLAYER else Color.orangered
	if (terminationPosition - startPos).x < 0:
		leafSprite.flip_v = true
		leafSprite.rotation -= deg2rad(40)
	else:
		leafSprite.flip_v = false
		leafSprite.rotation += deg2rad(40)
	leafSprite.rotation += deg2rad(rand_range(-15, 15))
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

func reevaluateLeaf(leavesAbove: int):
	match leavesAbove:
		0: leafSprite.texture = load("res://images/leaf_100.png")
		1: leafSprite.texture = load("res://images/leaf_80.png")
		2: leafSprite.texture = load("res://images/leaf_60.png")
		3: leafSprite.texture = load("res://images/leaf_40.png")
		4: leafSprite.texture = load("res://images/leaf_20.png")
		_: leafSprite.texture = load("res://images/leaf_00.png")
