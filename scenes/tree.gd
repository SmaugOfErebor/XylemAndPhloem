class_name GameTree
extends Node2D

var tileMapPosition: Vector2

var trunkTile: Tile
var rootTile: Tile

const UNSPENDABLE_CURRENCY_RATE: float = 0.05
const LEAF_STRENGTH: float = 0.01

var unspendableCurrency: float = 0.0
var spendableCurrency: float = 0.0
var spendablePerSec: float = 0.0
var unspendablePerSec: float = 0.0

func _init(tileMapPosition: Vector2):
	self.tileMapPosition = tileMapPosition
	
	var tileMap: TileMap = Globals.get_tiles()
	var seedTile: Tile = tileMap.getTile(tileMapPosition)
	
	var trunkPosition: Vector2
	trunkPosition.x = tileMapPosition.x
	trunkPosition.y = tileMapPosition.y - 1
	trunkTile = tileMap.getTile(trunkPosition)
	tileMap.addChildTileConnection(seedTile, trunkTile, 0)
	
	var rootPosition: Vector2
	rootPosition.x = tileMapPosition.x
	rootPosition.y = tileMapPosition.y + 1
	rootTile = tileMap.getTile(rootPosition)
	tileMap.addChildTileConnection(seedTile, rootTile, 1)

func _process(delta):
	if delta == 0: pass
		
	# Collect unspendable currency based on the number of roots the tree has
	unspendablePerSec = get_total_roots() * UNSPENDABLE_CURRENCY_RATE
	unspendableCurrency += unspendablePerSec * delta
	# Attempt to convert unspendable currency based on total sunlight
	var maximumConvertedCurrency: float = get_total_sunlight() * delta
	if maximumConvertedCurrency > unspendableCurrency:
		spendablePerSec = unspendableCurrency * (1.0 / delta)
		spendableCurrency += unspendableCurrency
		unspendableCurrency = 0
	else:
		spendablePerSec = maximumConvertedCurrency * (1.0 / delta)
		spendableCurrency += maximumConvertedCurrency
		unspendableCurrency -= maximumConvertedCurrency

func get_total_roots() -> int:
	# Add one to account for the first root
	return rootTile.get_descendant_tile_count() + 1

func get_total_sunlight() -> float:
	return get_total_leaves() * Globals.get_tiles().sunlightIntensity * LEAF_STRENGTH

func get_total_leaves() -> int:
	# TODO: Get total leaves that are receiving sunlight
	return 5

func getSpendableAsInt() -> int:
	return floor(spendableCurrency) as int
	
func getUnspendableAsInt() -> int:
	return floor(unspendableCurrency) as int
