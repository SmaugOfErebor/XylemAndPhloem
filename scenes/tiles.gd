extends TileMap

# This corresponds to tile IDs in tileset
enum TileId {
	DIRT,
	ENRICHED_DIRT,
	ROCK,
	SHADOW,
	SUNLIGHT,
	WATER
}

var tileData := {}

func _ready():
	tempGenerate()
	
func addTile(tileId: int, position: Vector2):
	var tile: Tile = Tile.new(tileId, position)
	set_cellv(tile.position, tile.tileId)
	tileData[tile.position] = tile
	
func getTile(position: Vector2) -> Tile:
	if tileData.has(position):
		return tileData[position]
	return null
	
func tempGenerate():
	# Iterate through the basic visual range
	for y in range(-10, 10):
		for x in range(0, 23):
			# Remove the middle row of tiles on ground
			if y == -1 and x % 2 == 1:
				continue
			# Generate sun if on top, dirt if bottom
			var tileId: int = TileId.DIRT if y >= 0 else TileId.SUNLIGHT
			addTile(tileId, Vector2(x, y))
