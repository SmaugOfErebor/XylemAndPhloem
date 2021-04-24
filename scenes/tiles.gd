extends TileMap

# This corresponds to tile IDs in tileset
const TILE_SIZE := Vector2(44, 50)
const SCREEN_TILE_WIDTH: int = 23
enum TileId {
	DIRT,
	ENRICHED_DIRT,
	ROCK,
	SHADOW,
	SUNLIGHT,
	WATER,
	TRANSPARENT
}

# Signal for when the user presses a tile
signal tile_pressed(tile)

onready var tileHighlight: Sprite = $tile_highlight

var tileData := {}

# Sunlight should stay within the range of 0-1 (1 being 100%)
var sunlightIntensity: float = 1.0

var playerGameTree
var computerGameTree

func _ready():
	# Generate temporary map
	tempGenerate()
	# Add the player and computer trees
	playerGameTree = GameTree.new(Vector2(3, -1))
	computerGameTree = GameTree.new(Vector2(19, -1))
	add_child(playerGameTree)
	add_child(computerGameTree)
	
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
		# Draw the highlight at the given tile position
		tileHighlight.position = getPixelPosition(tile)
		tileHighlight.visible = true
	elif ((event is InputEventMouseButton and event.button_index == BUTTON_LEFT) or 
			event is InputEventScreenTouch) and event.is_pressed():
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

func getPixelPosition(tile: Tile) -> Vector2:
	var pixelPosition: Vector2
	pixelPosition.x = tile.position.x * TILE_SIZE.x
	pixelPosition.y = tile.position.y * TILE_SIZE.y
	# Because of the offset tilemap, we need to adjust each odd column by half
	if (tile.position.x as int) % 2 == 1:
		pixelPosition.y += TILE_SIZE.y / 2
	return pixelPosition

func getCenterPixelPosition(tile: Tile) -> Vector2:
	var centerPixelPosition: Vector2 = getPixelPosition(tile)
	centerPixelPosition.x += TILE_SIZE.x / 2
	centerPixelPosition.x += 7
	centerPixelPosition.y += TILE_SIZE.y / 2
	return centerPixelPosition

func tempGenerate():
	# Iterate through the basic visual range
	for y in range(-10, 10):
		for x in range(0, SCREEN_TILE_WIDTH):
			# Remove the middle row of tiles on ground
			if y == -1 and x % 2 == 1:
				if x == 3 || x == 19:
					# Add transparent tiles to hold the starting trees
					addTile(TileId.TRANSPARENT, Vector2(x, y))
				continue

			if y < 0:
				# Above ground
				addTile(TileId.SUNLIGHT, Vector2(x, y))
			else:
				# Below ground
				addTile(TileId.DIRT, Vector2(x, y))

	generatePockets(TileId.WATER, 5, 8, 0, SCREEN_TILE_WIDTH-1, 4, 9, 1, 2)
	generatePockets(TileId.ENRICHED_DIRT, 6, 8, 0, SCREEN_TILE_WIDTH-1, 1, 9, 1, 3)
	generatePockets(TileId.ROCK, 2, 3, 0, SCREEN_TILE_WIDTH-1, 4, 7, 1, 1)

func generatePockets(tileId: int, 
					minPockets: int, maxPockets: int,
					xMin: int, xMax: int,
					yMin: int, yMax: int,
					radiusMin: int, radiusMax: int):
	# Randomize number of pockets to generate
	for i in range(Utils.randInt(minPockets, maxPockets)):
		# Calculate a tile to act as the root
		var basePos := Vector2(Utils.randInt(xMin, xMax), Utils.randInt(yMin, yMax))
		# Generate radiuses
		var xRadius: int = Utils.randInt(radiusMin, radiusMax)
		var yRadius: int = Utils.randInt(radiusMin, radiusMax)
		# Build out the pocket
		for x in range(-xRadius, xRadius):
			for y in range(-yRadius, yRadius):
				# Calculate position of tile to change
				var pos: Vector2 = basePos + Vector2(x, y)
				# Ensure it's within bounds
				if pos.y < yMin or pos.y > yMax or pos.x < xMin or pos.x > xMax:
					continue
				# Change the tile
				addTile(tileId, pos)
