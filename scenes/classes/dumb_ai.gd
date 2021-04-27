class_name DumbAI
extends AI

var tree: GameTree
var growVsRootLikelihood: float = 0.3
var growDelayTime: float = 0.0

var aiLevel: int = 0

func _init(tree: GameTree, aiLevel: int):
	self.tree = tree
	self.aiLevel = aiLevel

func update(delta: float):
	growDelayTime += delta
	match aiLevel:
		Globals.AI_EASY:
			if growDelayTime < 1.0:
				return
		Globals.AI_MED:
			if growDelayTime < 0.5:
				return
		Globals.AI_HARD:
			if growDelayTime < 0.2:
				return
	
	var startTile = tree.rootTile
	match aiLevel:
		Globals.AI_EASY:
			if tree.unspendablePerSec - 1.0 > tree.spendablePerSec:
				startTile = tree.trunkTile
		Globals.AI_MED:
			if tree.unspendablePerSec - 0.5 > tree.spendablePerSec:
				startTile = tree.trunkTile
		Globals.AI_HARD:
			if tree.unspendablePerSec > tree.spendablePerSec:
				startTile = tree.trunkTile
	
	var allMoves: Array = getAllPossibleMoves(startTile, [])
	var randMostUndesireable: Move = getRandomMinUndesireable(allMoves)
	if randMostUndesireable:
		Globals.get_tiles().attemptToGrow(tree, randMostUndesireable.fromTile, randMostUndesireable.toTile)

	growDelayTime = 0.0

func getRandomMinUndesireable(moves: Array) -> Move:
	if moves.size() <= 0:
		return null
	moves.sort_custom(self, "undesireableSort")
	return moves[0]

func undesireableSort(a, b):
	return a.undesireability(aiLevel) < b.undesireability(aiLevel)

func getAllPossibleMoves(rootTile: Tile, excluding: Array) -> Array:
	var ret := []
	
	# Get all neighbors
	var neighbors: Array = Globals.get_tiles().getNeighborTiles(rootTile)
	var selfNeighborsToProcess := []
	for neighbor in neighbors:
		if excluding.has(neighbor): continue
		if Utils.mySign(rootTile.position.y) != Utils.mySign(neighbor.position.y): continue
		if neighbor.ownerId == Globals.OWNER_COMPUTER:
			selfNeighborsToProcess.append(neighbor)
			continue
		var cost: int = Globals.get_tiles().calculateCost(rootTile, neighbor)
		ret.append(Move.new(rootTile, neighbor, cost))
	
	excluding.append(rootTile)
	for neighbor in selfNeighborsToProcess:
		ret.append_array(getAllPossibleMoves(neighbor, excluding))
	
	# Return array
	return ret

class Move:
	var cost: int
	var fromTile: Tile
	var toTile: Tile

	func _init(fromTile: Tile, toTile: Tile, cost: int):
		self.fromTile = fromTile
		self.toTile = toTile
		self.cost = cost

	func undesireability(aiLevel: int) -> int:
		var ret: int = 0
		if Utils.mySign(fromTile.position.y) < 0:
			# Above ground
			match aiLevel:
				Globals.AI_EASY:
					pass
				Globals.AI_MED:
					var playerLeavesBelow: int = Globals.get_tiles().getNumLeavesBelowTile(toTile, Globals.OWNER_PLAYER)
					ret -= playerLeavesBelow
				Globals.AI_HARD:
					var playerLeavesBelow: int = Globals.get_tiles().getNumLeavesBelowTile(toTile, Globals.OWNER_PLAYER)
					ret -= playerLeavesBelow
					var ownLeavesBelow: int = Globals.get_tiles().getNumLeavesBelowTile(toTile, Globals.OWNER_COMPUTER)
					if ownLeavesBelow > 4: # TODO
						ret += ownLeavesBelow
		else:
			# Below ground
			match toTile.tileId:
				Globals.TID_ROCK:
					match aiLevel:
						Globals.AI_EASY:
							pass
						Globals.AI_MED:
							ret += 3
						Globals.AI_HARD:
							ret += 10
				Globals.TID_DIRT:
					match aiLevel:
						Globals.AI_EASY:
							pass
						Globals.AI_MED:
							ret += 2
						Globals.AI_HARD:
							ret += 7
				Globals.TID_ENRICHED_DIRT:
					match aiLevel:
						Globals.AI_EASY:
							pass
						Globals.AI_MED:
							ret += 1
						Globals.AI_HARD:
							ret += 3
			
#			if toTile.isWaterTile():
#				match aiLevel:
#					Globals.AI_EASY:
#						pass
#					Globals.AI_MED:
#						pass
#					Globals.AI_HARD:
#						pass
			
			# Prioritize player
			if toTile.ownerId == Globals.OWNER_PLAYER:
				match aiLevel:
					Globals.AI_EASY:
						pass
					Globals.AI_MED:
						ret -= cost
					Globals.AI_HARD:
						ret -= (cost + 5)
		return ret
