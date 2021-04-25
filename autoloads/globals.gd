extends Node

const TID_DIRT: int = 0
const TID_ENRICHED_DIRT: int = 1
const TID_ROCK: int = 2
const TID_TRANSPARENT: int = 3
const TID_BORDERLESS_TRANSPARENT: int = 4
const TID_WATER_0: int = 5
const TID_WATER_1: int = 6
const TID_WATER_2: int = 7
const TID_WATER_3: int = 8
const TID_WATER_MAX: int = 9

const OWNER_NONE: int = 0
const OWNER_PLAYER: int = 1
const OWNER_COMPUTER: int = 2

signal player_currency_converted()

func get_root2d() -> Root2D:
	return get_tree().get_root().get_node("root_node").get_node("root_2d") as Root2D

func get_tiles() -> TileMap:
	 return get_root2d().get_tiles()

func get_camera() -> GameCam:
	return get_root2d().get_node("camera") as GameCam

func get_snailbert() -> AnimatedSprite:
	return get_root2d().get_node("snails").get_node("snailbert") as AnimatedSprite
