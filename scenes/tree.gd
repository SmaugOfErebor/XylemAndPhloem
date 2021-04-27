class_name GameTree
extends Node2D

var tileMapPosition: Vector2

var trunkTile: Tile
var rootTile: Tile

const UNSPENDABLE_CURRENCY_RATE: float = 0.05
const LEAF_STRENGTH: float = 0.2

var unspendableCurrency: float = 0.0
var spendableCurrency: float = 20.0
var spendablePerSec: float = 0.0
var unspendablePerSec: float = 0.0
var ownerId: int = Globals.OWNER_NONE

func _init(tileMapPosition: Vector2, ownerId: int):
	self.tileMapPosition = tileMapPosition
	self.ownerId = ownerId
	
	var tileMap: TileMap = Globals.get_tiles()
	var seedTile: Tile = tileMap.getTile(tileMapPosition)
	seedTile.ownerId = ownerId
	
	var trunkPosition: Vector2
	trunkPosition.x = tileMapPosition.x
	trunkPosition.y = tileMapPosition.y - 1
	trunkTile = tileMap.getTile(trunkPosition)
	tileMap.addChildTileConnection(seedTile, trunkTile, 0, ownerId)
	
	var rootPosition: Vector2
	rootPosition.x = tileMapPosition.x
	rootPosition.y = tileMapPosition.y + 1
	rootTile = tileMap.getTile(rootPosition)
	tileMap.addChildTileConnection(seedTile, rootTile, 1, ownerId)

func _process(delta):
	# Check due to division
	if delta <= 0:
		return

	# Collect unspendable currency based on the number of roots the tree has
	unspendablePerSec = get_total_nutrients() * UNSPENDABLE_CURRENCY_RATE
	unspendableCurrency += unspendablePerSec * delta
	# Attempt to convert unspendable currency based on total sunlight
	var maximumConvertedCurrency: float = get_total_sunlight() * delta
	var oldSpendableInt: int = getSpendableAsInt()
	if maximumConvertedCurrency > unspendableCurrency:
		spendablePerSec = unspendableCurrency * (1.0 / delta)
		spendableCurrency += unspendableCurrency
		unspendableCurrency = 0
	else:
		spendablePerSec = maximumConvertedCurrency * (1.0 / delta)
		spendableCurrency += maximumConvertedCurrency
		unspendableCurrency -= maximumConvertedCurrency
	if ownerId == Globals.OWNER_PLAYER and getSpendableAsInt() > oldSpendableInt:
		Globals.emit_signal("player_currency_converted")

func get_total_nutrients() -> int:
	return rootTile.getSelfAndDescendantNutrients() + get_total_water_bonus()

func get_total_water_bonus() -> int:
	return rootTile.getSelfAndDescendantWaterBonus()

func get_total_sunlight() -> float:
	return trunkTile.getSelfAndDescendantSunlight() * LEAF_STRENGTH + get_total_water_bonus() * LEAF_STRENGTH

func getSpendableAsInt() -> int:
	return floor(spendableCurrency) as int
	
func getUnspendableAsInt() -> int:
	return floor(unspendableCurrency) as int
