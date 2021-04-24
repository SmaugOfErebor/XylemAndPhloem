class_name GameTree
extends Node2D

var tileMapPosition: Vector2

var trunkTile: Tile
var rootTile: Tile

const UNSPENDABLE_CURRENCY_RATE: float = 0.05
const LEAF_STRENGTH: float = 0.01

var unspendableCurrency: float = 0.0
var spendableCurrency: float = 0.0

func _init(tileMapPosition: Vector2):
	self.tileMapPosition = tileMapPosition
	
	var tileMap: TileMap = Globals.get_tiles()
	
	var trunkPosition: Vector2
	trunkPosition.x = tileMapPosition.x
	trunkPosition.y = tileMapPosition.y - 1
	trunkTile = tileMap.getTile(trunkPosition)
	add_child(TileConnection.new(tileMap.getTile(tileMapPosition), trunkTile, 0))
	
	var rootPosition: Vector2
	rootPosition.x = tileMapPosition.x
	rootPosition.y = tileMapPosition.y + 1
	rootTile = tileMap.getTile(rootPosition)
	add_child(TileConnection.new(tileMap.getTile(tileMapPosition), rootTile, 1))

func _process(delta):
	# Collect unspendable currency based on the number of roots the tree has
	unspendableCurrency += get_total_roots() * UNSPENDABLE_CURRENCY_RATE * delta
	# Attempt to convert unspendable currency based on total sunlight
	var maximumConvertedCurrency: float = get_total_sunlight() * delta
	if maximumConvertedCurrency > unspendableCurrency:
		spendableCurrency += unspendableCurrency
		unspendableCurrency = 0
	else:
		spendableCurrency += maximumConvertedCurrency
		unspendableCurrency -= maximumConvertedCurrency

func get_total_roots() -> int:
	#TODO: Return the actual total roots
	return 5

func get_total_sunlight() -> float:
	return get_total_leaves() * Globals.get_tiles().sunlightIntensity * LEAF_STRENGTH

func get_total_leaves() -> int:
	#TODO: Return the actual total leaves
	return 5
