class_name Tile

var tileId: int
var position: Vector2

var incomingConnection
var outgoingConnections = []

func _init(tileId: int, position: Vector2):
	self.tileId = tileId
	self.position = position

func remove_connections():
	incomingConnection.get_parent().remove_child(incomingConnection)
	for outgoingConnection in outgoingConnections:
		outgoingConnection.toTile.remove_connections()
	outgoingConnections = []

func hasConnections():
	return incomingConnection != null or outgoingConnections.size() > 0
