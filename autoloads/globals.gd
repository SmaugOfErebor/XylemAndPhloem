extends Node

const TID_DIRT: int = 0
const TID_ENRICHED_DIRT: int = 1
const TID_ROCK: int = 2
const TID_SHADOW: int = 3
const TID_SUNLIGHT: int = 4
const TID_WATER: int = 5
const TID_TRANSPARENT: int = 6

func get_tiles() -> TileMap:
	 return get_tree().get_root().get_node("root_node").get_node("root_2d").get_node("tiles") as TileMap
