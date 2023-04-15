extends Node

@export var Clock:float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func TimeToString():
	var minutes = floor(Clock / 60)
	var remaining_seconds = fmod(Clock,60)
	return str(minutes) + ":" + str(int(remaining_seconds)).pad_zeros(2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Clock += delta
	#print(TimeToString())
	pass
