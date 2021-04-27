extends TileMap

# This corresponds to tile IDs in tileset
const TILE_SIZE := Vector2(44, 50)
const SCREEN_TILE_WIDTH: int = 23
const HIGHLIGHT_COLOR_BUYABLE := Color.green
const HIGHLIGHT_COLOR_NOT_BUYABLE := Color.red
const FAN_OUT_DUR: float = 0.07

var selectedFromTile: Tile = null

# Signal for when the user presses a tile
signal tile_pressed(tile)
signal game_over(won)

onready var tileHighlight: Sprite = $tile_highlight
onready var tileSelectHighlight: Sprite = $tile_select_highlight
onready var ct: Sprite = $tile_select_highlight/ct
onready var cb: Sprite = $tile_select_highlight/cb
onready var lt: Sprite = $tile_select_highlight/lt
onready var lb: Sprite = $tile_select_highlight/lb
onready var rt: Sprite = $tile_select_highlight/rt
onready var rb: Sprite = $tile_select_highlight/rb

onready var ctTargetPos: Vector2 = ct.position
onready var cbTargetPos: Vector2 = cb.position
onready var ltTargetPos: Vector2 = lt.position
onready var lbTargetPos: Vector2 = lb.position
onready var rtTargetPos: Vector2 = rt.position
onready var rbTargetPos: Vector2 = rb.position

onready var highlightSlideTween: Tween = $tile_select_highlight/highlight_slide_tween

var tileData := {}

var playerGameTree
var computerGameTree
var ai: AI

var waitingGameOverTransition := false

func _ready():
	# Generate temporary map
	tempGenerate()
	# Add the player and computer trees
	playerGameTree = GameTree.new(Vector2(3, -1), Globals.OWNER_PLAYER)
	computerGameTree = GameTree.new(Vector2(19, -1), Globals.OWNER_COMPUTER)
	add_child(playerGameTree)
	add_child(computerGameTree)
	# Start with super dumb ai
	ai = DumbAI.new(computerGameTree, Globals.curAiLevel)
	# Listen for tile presses
	connect("tile_pressed", self, "tilePressed")
	connect("game_over", self, "onGameOver")
	
func onGameOver(won: bool):
	if waitingGameOverTransition:
		return
	waitingGameOverTransition = true
	yield(get_tree().create_timer(1.0), "timeout")
	Globals.get_root2d().showGameOverScreen(won)
	
# When the user clicks a tile
func tilePressed(tile: Tile):
	# Check which
	if selectedFromTile == null:
		# Only if not the computer's tile
		if tile.ownerId != Globals.OWNER_COMPUTER:
			selectedFromTile = tile
			startSelectFanOutTween()
	else:
		# This is the user's "to" tile selection
		if selectedFromTile == tile:
			removeSelectionHighlight()
		else:
			if attemptToGrow(playerGameTree, selectedFromTile, tile):
				selectedFromTile = tile
				startSelectFanOutTween()
			elif tile.ownerId == Globals.OWNER_PLAYER:
				selectedFromTile = tile
				startSelectFanOutTween()

func attemptToGrow(treeUser, from: Tile, to: Tile) -> bool:
	if canGrow(treeUser, from, to):
		# If the tile had an owner (i.e. had connections at this point in the code; checked above)
		# Then we need to sever that connection of the opponent
		if to.hasConnections():
			to.remove_connections()
			Audio.playSnipSound()
		# Deduct cost (already verified they can pay)
		var cost: int = calculateCost(from, to)
		treeUser.spendableCurrency -= cost
		addChildTileConnection(from, to, 0 if from.position.y < 0 else 1, treeUser.ownerId)
		return true
	return false

func canGrow(treeUser, from: Tile, to: Tile) -> bool:
	# First, make sure it's on the same level
	if Utils.mySign(from.position.y) == Utils.mySign(to.position.y):
		# And make sure it's still valid (has connections still)
		if from.hasConnections():
			# Get all tile neighbors
			var neighborTiles = getNeighborTiles(to)
			# If a connection can be made from a neighbor, make it
			for neighbor in neighborTiles:
				if neighbor == from:
					# Can make a valid connection (if the to tile has no connections yet)
					if not to.hasConnections() or (to.ownerId != Globals.OWNER_NONE and to.ownerId != from.ownerId):
						# Check if cost can be OK
						var cost: int = calculateCost(from, to)
						if treeUser.getSpendableAsInt() >= cost:
							# Can do it
							return true
						return false
	# No valid connection
	return false

func _physics_process(delta):
	ai.update(delta)
	
	if selectedFromTile:
		if selectedFromTile.hasConnections() and selectedFromTile.tileId != Globals.TID_TRANSPARENT:
			# Select a from tile
			if not setTileSelectHighlight(selectedFromTile):
				removeSelectionHighlight()
		else:
			removeSelectionHighlight()
			
	for td in tileData.values():
		td.update(delta)
			
func removeSelectionHighlight():
	selectedFromTile = null
	tileSelectHighlight.visible = false

func startSelectFanOutTween():
	highlightSlideTween.stop_all()
	highlightSlideTween.interpolate_property(ct, "position", Vector2.ZERO, ctTargetPos, FAN_OUT_DUR, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	highlightSlideTween.interpolate_property(cb, "position", Vector2.ZERO, cbTargetPos, FAN_OUT_DUR, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	highlightSlideTween.interpolate_property(lt, "position", Vector2.ZERO, ltTargetPos, FAN_OUT_DUR, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	highlightSlideTween.interpolate_property(lb, "position", Vector2.ZERO, lbTargetPos, FAN_OUT_DUR, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	highlightSlideTween.interpolate_property(rt, "position", Vector2.ZERO, rtTargetPos, FAN_OUT_DUR, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	highlightSlideTween.interpolate_property(rb, "position", Vector2.ZERO, rbTargetPos, FAN_OUT_DUR, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	highlightSlideTween.start()

func addChildTileConnection(fromTile: Tile, toTile: Tile, tileType: int, ownerId: int):
	var newConnection := TileConnection.new(fromTile, toTile, tileType)
	add_child(newConnection)
	fromTile.outgoingConnections.append(newConnection)
	toTile.incomingConnection = newConnection
	toTile.ownerId = ownerId
	
	if tileType == 0:
		newConnection.add_leaf()
		if fromTile.incomingConnection != null:
			fromTile.incomingConnection.remove_leaf()
		reevaluateSunlight(fromTile)
		reevaluateSunlight(toTile)

func reevaluateSunlight(tile: Tile):
	var numLeaves: int = 0
	for i in range(get_used_rect().position.y, 0):
		# Skip the blank tiles at the bottom
		if int(tile.position.x) % 2 == 1 and i == -1:
			continue
		
		match numLeaves:
			0: tile.leafStrength = 1.0
			1: tile.leafStrength = 0.8
			2: tile.leafStrength = 0.6
			3: tile.leafStrength = 0.4
			4: tile.leafStrength = 0.2
			_: tile.leafStrength = 0.0
		var currentTile: Tile = getTile(Vector2(tile.position.x, i))
		if currentTile.hasLeaf:
			currentTile.incomingConnection.reevaluateLeaf(numLeaves)
			numLeaves += 1

func getNumLeavesBelowTile(tile: Tile, ownerId: int) -> int:
	var numLeaves: int = 0
	for i in range(tile.position.y + 1, 0):
		# Skip the blank tiles at the bottom
		if int(tile.position.x) % 2 == 1 and i == -1:
			continue
		
		var check = getTile(Vector2(tile.position.x, i))
		if check.ownerId == ownerId and check.hasLeaf:
			numLeaves += 1

	return numLeaves

func calculateCost(from: Tile, to: Tile) -> int:
	var ownerCost: int = 0
	if to.ownerId != Globals.OWNER_NONE and to.ownerId != from.ownerId:
		ownerCost = to.get_descendant_tile_count() * 3
	if from.position.y < 0 and from.position.x != to.position.x:
		ownerCost += 1 # Horizontal movement above ground + 1 more
	return to.getBaseCost() + (from.getLengthFromHere() / 3) + ownerCost

func showSelectableNeighbor(highlight: Sprite, tile: Tile, neighbor: Tile):
	# Start as not selectable
	highlight.visible = false
	# Check if selectable
	if neighbor == null:
		return
	if not (Utils.mySign(tile.position.y) == Utils.mySign(neighbor.position.y) and (not neighbor.hasConnections() or (neighbor.ownerId != Globals.OWNER_NONE and neighbor.ownerId != tile.ownerId))):
		return
	# It is selectable; see if they have enough $ to buy it
	var cost: int = calculateCost(tile, neighbor)
	highlight.find_node("CostLabel").text = str(cost)
	if playerGameTree.getSpendableAsInt() >= cost:
		highlight.modulate = HIGHLIGHT_COLOR_BUYABLE
	else:
		highlight.modulate = HIGHLIGHT_COLOR_NOT_BUYABLE
	highlight.visible = true

func setTileSelectHighlight(tile: Tile) -> bool:
	var neighbors = getNeighborTiles(tile, true)
	showSelectableNeighbor(ct, tile, neighbors[2])
	showSelectableNeighbor(cb, tile, neighbors[3])
	if (tile.position.x as int) % 2 == 0:
		showSelectableNeighbor(lb, tile, neighbors[0])
		showSelectableNeighbor(rb, tile, neighbors[1])
		showSelectableNeighbor(lt, tile, neighbors[4])
		showSelectableNeighbor(rt, tile, neighbors[5])
	else:
		showSelectableNeighbor(lt, tile, neighbors[0])
		showSelectableNeighbor(rt, tile, neighbors[1])
		showSelectableNeighbor(lb, tile, neighbors[4])
		showSelectableNeighbor(rb, tile, neighbors[5])
	
	if ct.visible or cb.visible or lb.visible or lt.visible or rb.visible or rt.visible:
		tileSelectHighlight.position = getPixelPosition(tile)
		tileSelectHighlight.visible = true
		return true
	else:
		tileSelectHighlight.visible = false
		return false

# Gets all neighbor tiles
func getNeighborTiles(tile: Tile, allowNulls: bool = false) -> Array:
	var ret := []
	var a: Tile = getTile(tile.position + Vector2(-1, 0))
	if a or allowNulls: ret.append(a)
	a = getTile(tile.position + Vector2(1, 0))
	if a or allowNulls: ret.append(a)
	a = getTile(tile.position + Vector2(0, -1))
	if a or allowNulls: ret.append(a)
	a = getTile(tile.position + Vector2(0, 1))
	if a or allowNulls: ret.append(a)
	a = getTile(tile.position + Vector2(-1, -1 if (tile.position.x as int) % 2 == 0 else 1))
	if a or allowNulls: ret.append(a)
	a = getTile(tile.position + Vector2(1, -1 if (tile.position.x as int) % 2 == 0 else 1))
	if a or allowNulls: ret.append(a)
	return ret
	
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
		var newPos = getPixelPosition(tile)
		if newPos != tileHighlight.position:
			Audio.playSelectSound()
		tileHighlight.position = newPos
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
					addTile(Globals.TID_TRANSPARENT, Vector2(x, y))
				continue

			if y < 0:
				# Above ground
				addTile(Globals.TID_BORDERLESS_TRANSPARENT, Vector2(x, y))
			else:
				# Below ground
				addTile(Globals.TID_DIRT, Vector2(x, y))

	generatePockets(Globals.TID_WATER_MAX, 5, 8, 0, SCREEN_TILE_WIDTH-1, 1, 9, 1, 2)
	generatePockets(Globals.TID_ENRICHED_DIRT, 6, 8, 0, SCREEN_TILE_WIDTH-1, 1, 9, 1, 3)
	generatePockets(Globals.TID_ROCK, 2, 3, 0, SCREEN_TILE_WIDTH-1, 4, 7, 1, 1)

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
