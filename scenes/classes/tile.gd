class_name Tile

var tileId: int
var position: Vector2

var ownerId: int = Globals.OWNER_NONE
var incomingConnection
var outgoingConnections = []

var hasLeaf: bool = false

func _init(tileId: int, position: Vector2):
	self.tileId = tileId
	self.position = position

func remove_connections(removeFromParentOutgoing: bool = true):
	if Globals.get_tiles().playerGameTree.rootTile == self:
		Globals.get_tiles().emit_signal("game_over", false)
	elif Globals.get_tiles().computerGameTree.rootTile == self:
		Globals.get_tiles().emit_signal("game_over", true)
	
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
		match tileId:
			Globals.TID_SUNLIGHT_100: sunlightTotal += 1.0
			Globals.TID_SUNLIGHT_80: sunlightTotal += 0.8
			Globals.TID_SUNLIGHT_60: sunlightTotal += 0.6
			Globals.TID_SUNLIGHT_40: sunlightTotal += 0.4
			Globals.TID_SUNLIGHT_20: sunlightTotal += 0.2
	
	for outgoingConnection in outgoingConnections:
		sunlightTotal += outgoingConnection.toTile.getSelfAndDescendantSunlight()
	
	return sunlightTotal
