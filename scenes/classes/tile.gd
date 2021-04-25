class_name Tile

const WATER_DEPLETION_TIME_STEP: float = 2.0

var tileId: int
var position: Vector2

var ownerId: int = Globals.OWNER_NONE
var incomingConnection
var outgoingConnections = []

var hasLeaf: bool = false
var leafStrength: float = 0.0

var waterTileDepletionTimer: float = 0.0
var waterTilePower: int = Globals.TID_WATER_MAX - Globals.TID_WATER_0
var prevWaterIncomingConnection = null

func update(delta: float):
	if isWaterTile():
		if incomingConnection:
			if incomingConnection != prevWaterIncomingConnection:
				if prevWaterIncomingConnection:
					prevWaterIncomingConnection.changeWaterBenefit(-waterTilePower)
				waterTileDepletionTimer = 0.0
				waterTilePower = Globals.TID_WATER_MAX - Globals.TID_WATER_0
				refreshWaterTilePower()
				incomingConnection.changeWaterBenefit(waterTilePower)
			prevWaterIncomingConnection = incomingConnection
			waterTileDepletionTimer += delta
			if waterTilePower > 0 and waterTileDepletionTimer > WATER_DEPLETION_TIME_STEP:
				waterTileDepletionTimer = 0.0
				incomingConnection.changeWaterBenefit(-waterTilePower)
				waterTilePower -= 1
				incomingConnection.changeWaterBenefit(waterTilePower)
				refreshWaterTilePower()
		elif incomingConnection != prevWaterIncomingConnection:
			# Prev wasn't null, but incoming is now null, so reset
			prevWaterIncomingConnection.changeWaterBenefit(-waterTilePower)
			waterTileDepletionTimer = 0.0
			waterTilePower = Globals.TID_WATER_MAX - Globals.TID_WATER_0
			refreshWaterTilePower()
			prevWaterIncomingConnection = null

func refreshWaterTilePower():
	Globals.get_tiles().set_cellv(position, Globals.TID_WATER_0 + waterTilePower)

func isWaterTile() -> bool:
	return tileId >= Globals.TID_WATER_0 and tileId <= Globals.TID_WATER_MAX

func _init(tileId: int, position: Vector2):
	self.tileId = tileId
	self.position = position

func remove_connections(removeFromParentOutgoing: bool = true):
	if Globals.get_tiles().playerGameTree.rootTile == self:
		Globals.get_tiles().emit_signal("game_over", false)
	elif Globals.get_tiles().computerGameTree.rootTile == self:
		Globals.get_tiles().emit_signal("game_over", true)
		
	Globals.get_camera().shake(get_descendant_tile_count())
	
	if incomingConnection:
		incomingConnection.get_parent().remove_child(incomingConnection)
		if removeFromParentOutgoing:
			incomingConnection.fromTile.outgoingConnections.remove(
				incomingConnection.fromTile.outgoingConnections.find(incomingConnection)
			)
			if atleast_one_descendant_has_leaf() and incomingConnection.fromTile.incomingConnection:
				if incomingConnection.fromTile.outgoingConnections.size() <= 0:
					incomingConnection.fromTile.incomingConnection.add_leaf()
			incomingConnection.reevaluateThickness()
		incomingConnection = null
		
	ownerId = Globals.OWNER_NONE
	for outgoingConnection in outgoingConnections:
		outgoingConnection.toTile.remove_connections(false)
	outgoingConnections = []
	
	hasLeaf = false
	
	if Globals.get_tiles().selectedFromTile == self:
		Globals.get_tiles().removeSelectionHighlight()

func atleast_one_descendant_has_leaf() -> bool:
	# If we have a leaf, return
	if hasLeaf:
		return true
	# Start with immediate children
	var descendantCount: int = outgoingConnections.size()
	# Check if they have a leaf
	for outgoingConnection in outgoingConnections:
		if outgoingConnection.toTile.atleast_one_descendant_has_leaf():
			return true
	return false

func get_descendant_tile_count() -> int:
	# Start with immediate children
	var descendantCount: int = outgoingConnections.size()
	# Add descendants of children
	for outgoingConnection in outgoingConnections:
		descendantCount += outgoingConnection.toTile.get_descendant_tile_count()
	
	return descendantCount

func getSelfAndDescendantNutrients() -> int:
	var totalNutrientCount: int = 0
	match tileId:
		Globals.TID_DIRT: totalNutrientCount += 1
		Globals.TID_ENRICHED_DIRT: totalNutrientCount += 3
	
	for outgoingConnection in outgoingConnections:
		totalNutrientCount += outgoingConnection.toTile.getSelfAndDescendantNutrients()
	
	return totalNutrientCount
	
func getSelfAndDescendantWaterBonus() -> int:
	var total: int = 0
	for outgoing in outgoingConnections:
		total += outgoing.toTile.getSelfAndDescendantWaterBonus()
	return total + (waterTilePower if isWaterTile() else 0)

func getLengthFromHere() -> int:
	if incomingConnection == null:
		return 0
	return 1 + incomingConnection.fromTile.getLengthFromHere()

func hasConnections():
	return incomingConnection != null or outgoingConnections.size() > 0

func getBaseCost() -> int:
	if tileId == Globals.TID_ROCK:
		return 5
	return 1

func getSelfAndDescendantSunlight() -> float:
	var sunlightTotal: float = 0.0
	
	if hasLeaf:
		sunlightTotal += leafStrength
	
	for outgoingConnection in outgoingConnections:
		sunlightTotal += outgoingConnection.toTile.getSelfAndDescendantSunlight()
	
	return sunlightTotal
