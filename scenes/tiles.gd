extends TileMap

# This corresponds to tile IDs in tileset
const TILE_SIZE := Vector2(44, 50)
enum TileId {
	DIRT,
	ENRICHED_DIRT,
	ROCK,
	SHADOW,
	SUNLIGHT,
	WATER
}

# Signal for when the user presses a tile
signal tile_pressed(tile)

onready var tileHighlight: Sprite = $tile_highlight

var tileData := {}

func _ready():
	# Generate temporary map
	tempGenerate()
	
# Add a tile to the map and data class
func addTile(tileId: int, position: Vector2):
	var tile: Tile = Tile.new(tileId, position)
	set_cellv(tile.position, tile.tileId)
	tileData[tile.position] = tile
	
# Gets a tile from the tile data based on coordinate
func getTile(position: Vector2) -> Tile:
	if tileData.has(position):
		return tileData[position]
	return null
	
func _input(event):
	if event is InputEventMouseMotion:
		# Get the tilemap coordinate (always integer)
		var tilePos: Vector2 = world_to_map(to_local(get_global_mouse_position()))
		# Get the tile
		var tile: Tile = getTile(tilePos)
		if not tile:
			tileHighlight.visible = false
			return
		# Because of the offset tilemap, we need to adjust each odd column by half
		if (tilePos.x as int) % 2 == 1:
			tilePos.y += 0.5
		# Draw the highlight at the given tile position
		tileHighlight.position = tilePos * TILE_SIZE
		tileHighlight.visible = true
	elif (event is InputEventMouseButton or event is InputEventScreenTouch) and event.is_pressed():
		# The user pressed on a tile (possibly)
		# Get the touch or mouse press location
		var pressedPos: Vector2 = get_global_mouse_position()
		if event is InputEventScreenTouch:
			# Cruddy hack for touch screens, to account for camera
			pressedPos = get_canvas_transform().affine_inverse().xform(event.position)
		# Get the tile
		var tilePos: Vector2 = world_to_map(to_local(pressedPos))
		var tile: Tile = getTile(tilePos)
		# If it exists, trigger a tile pressed event
		if tile:
			emit_signal("tile_pressed", tile)
			print("TILE PRESSED")
		
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
