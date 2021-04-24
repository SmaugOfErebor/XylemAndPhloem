extends Node

func _ready():
	randomize()

# Random integer, both bounds inclusive
func randInt(minimum: int, maximum: int):
	return randi() % (maximum - minimum + 1) + minimum

# Like sign() except it'll never return 0 (causes issues for our use)
func mySign(val: float):
	return -1 if val < 0 else 1
