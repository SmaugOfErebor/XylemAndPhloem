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

func _ready():
	tempGenerate()
	
func tempGenerate():
	# Iterate through the basic visual range
	for y in range(-10, 10):
		for x in range(0, 23):
			# Remove the middle row of tiles on ground
			if y == -1 and x % 2 == 1:
				continue
			# Generate sun if on top, dirt if bottom
			var tileId: int = TileId.DIRT if y >= 0 else TileId.SUNLIGHT
			set_cellv(Vector2(x, y), tileId)
