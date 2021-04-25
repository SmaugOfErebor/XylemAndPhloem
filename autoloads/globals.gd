extends Node

const TID_DIRT: int = 0
const TID_ENRICHED_DIRT: int = 1
const TID_ROCK: int = 2
const TID_TRANSPARENT: int = 3
const TID_BORDERLESS_TRANSPARENT: int = 4
const TID_WATER: int = 5

const OWNER_NONE: int = 0
const OWNER_PLAYER: int = 1
const OWNER_COMPUTER: int = 2

func get_tiles() -> TileMap:
	 return get_tree().get_root().get_node("root_node").get_node("root_2d").get_node("tiles") as TileMap

func get_camera() -> GameCam:
	return get_tree().get_root().get_node("root_node").get_node("root_2d").get_node("camera") as GameCam
