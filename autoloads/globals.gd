extends Node

func get_tiles() -> TileMap:
	 return get_tree().get_root().get_node("root_node").get_node("root_2d").get_node("tiles") as TileMap
