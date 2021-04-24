extends Node

func _ready():
	randomize()

# Random integer, both bounds inclusive
func randInt(minimum: int, maximum: int):
	return randi() % (maximum - minimum + 1) + minimum
