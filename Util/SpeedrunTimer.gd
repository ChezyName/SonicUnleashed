extends Node

@export var Clock:float = 0

var levelDone:bool = false

func _ready():
	pass

func onLevelFinished():
	levelDone = true

func TimeToString() -> String:
	var minutes = floor(Clock / 60)
	var seconds = floor(fmod(Clock,60))
	var milliseconds = int(fmod(Clock,1) * 1000)

	# Format the time as a string
	return str(minutes) + ":" + str(seconds).pad_zeros(2) + "." + str(milliseconds).pad_zeros(3)

func getTime():
	return Clock

func _process(delta):
	var timeScale:float = abs(1-Engine.time_scale) + 1
	if(!levelDone): Clock += delta * timeScale
	#print(TimeToString())
	pass
