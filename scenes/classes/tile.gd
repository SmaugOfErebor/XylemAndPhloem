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

func remove_connections():
	incomingConnection.get_parent().remove_child(incomingConnection)
	ownerId = Globals.OWNER_NONE
	for outgoingConnection in outgoingConnections:
		outgoingConnection.toTile.remove_connections()
	outgoingConnections = []

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
