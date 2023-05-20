extends Node

@export var Level:PackedScene;

var LoadedData:LevelData;


func NumberToTime(Clock):
	var minutes = floor(Clock / 60)
	var seconds = floor(fmod(Clock,60))
	var milliseconds = int(fmod(Clock,1) * 1000)
	return str(minutes) + ":" + str(seconds).pad_zeros(2) + "." + str(milliseconds).pad_zeros(3)

# Called when the node enters the scene tree for the first time.
func _ready():
	var Name:String = Level._bundled.names[0]
	LoadedData = $"/root/SpeedrunSave".Load(Name)
	var str = "Level " + Name + " | " + "N/A"
	if(LoadedData != null):
		str = "Level " + LoadedData.levelName + " | " + str(LoadedData.speedTime) + "s | " +  str(LoadedData.RingCount) + "*";
	$Text.text = str;
	pass # Replace with function body.

func onClicked():
	get_tree().change_scene_to_packed(Level)
	queue_free()
