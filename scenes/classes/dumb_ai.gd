class_name DumbAI
extends AI

const GROW_DELAY_TIMEOUT: float = 1.0

var tree: GameTree
var growVsRootLikelihood: float
var growDelayTime: float = 0.0

func _init(tree: GameTree, growVsRootLikelihood: float):
	self.tree = tree
	self.growVsRootLikelihood = growVsRootLikelihood

func update(delta: float):
	growDelayTime += delta
	if growDelayTime < GROW_DELAY_TIMEOUT:
		return
	
	var lastRandomRootTile: Tile = getRandomPartTile(randf() < growVsRootLikelihood, 0.1)
	if lastRandomRootTile:
		var neighbors: Array = Globals.get_tiles().getNeighborTiles(lastRandomRootTile)
		if neighbors.size() > 0:
			var randNeighbor: Tile = neighbors[Utils.randInt(0, neighbors.size() - 1)]
			if Globals.get_tiles().attemptToGrow(tree, lastRandomRootTile, randNeighbor):
				growDelayTime = 0.0

func getRandomPartTile(useTrunkTile: bool, stopEarlyChance: float) -> Tile:
	var tile: Tile = tree.trunkTile if useTrunkTile else tree.rootTile
	while tile and tile.outgoingConnections.size() > 0 and randf() > stopEarlyChance:
		tile = tile.outgoingConnections[Utils.randInt(0, tile.outgoingConnections.size() - 1)].toTile
	if tile.ownerId != tree.ownerId:
		return null
	return tile
