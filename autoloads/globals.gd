extends Node

const TID_DIRT: int = 0
const TID_ENRICHED_DIRT: int = 1
const TID_ROCK: int = 2
const TID_WATER: int = 3
const TID_SUNLIGHT_100: int = 4
const TID_SUNLIGHT_80: int = 5
const TID_SUNLIGHT_60: int = 6
const TID_SUNLIGHT_40: int = 7
const TID_SUNLIGHT_20: int = 8
const TID_TRANSPARENT: int = 9

const OWNER_NONE: int = 0
const OWNER_PLAYER: int = 1
const OWNER_COMPUTER: int = 2

func get_tiles() -> TileMap:
	 return get_tree().get_root().get_node("root_node").get_node("root_2d").get_node("tiles") as TileMap
