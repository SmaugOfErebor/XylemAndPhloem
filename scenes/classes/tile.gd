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
