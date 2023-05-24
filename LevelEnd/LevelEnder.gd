extends Area3D

var totalLevelRings = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$SonicGoal.rotation.y = -620
	$"/root/SpeedrunTimer".Reset()
	pass # Replace with function body.

@export var NextLevel:PackedScene
@export var finalScene = false

var levelEnded:bool = false
var ringsObtained:int = 0

var currentTime:float = 0
var currentRings:float = 0

var sceneLoaded = false

func load_next_scene():
	if(finalScene):
		get_tree().change_scene_to_file("res://Levels/MainMenu.tscn")
		sceneLoaded = true
		queue_free()
	else:
		if(NextLevel == null): 
			push_warning(self.name + " has no 'scene' loaded.")
			return
		if(sceneLoaded): return
		get_tree().change_scene_to_packed(NextLevel)
		sceneLoaded = true
		queue_free()

func NumberToTime(Clock):
	var minutes = floor(Clock / 60)
	var seconds = floor(fmod(Clock,60))
	var milliseconds = int(fmod(Clock,1) * 1000)
	return str(minutes) + ":" + str(seconds).pad_zeros(2) + "." + str(milliseconds).pad_zeros(3)

var delaySceneLoad = 2.75

func _process(delta):
	if(!levelEnded):
		for body in get_overlapping_bodies():
			if(body.name == "SonicPlayer"):
				levelEnded = true
				ringsObtained = body.onLevelEnded(self)
				$LevelEndSFX.play()
				$"/root/SpeedrunTimer".onLevelFinished()
				var SaveData = LevelData.new();
				SaveData.levelName = get_tree().current_scene.name;
				SaveData.RingCount = ringsObtained
				SaveData.speedTime = $"/root/SpeedrunTimer".getTime()
				$"/root/SpeedrunSave".Save(SaveData)
				print("Level Endeed With:" + str(ringsObtained) + " RINGS.");
	else:
		if($LevelEndSFX.playing):
			#print($SonicGoal.get_rotation())
			var newRotation = $SonicGoal.get_rotation()
			newRotation.y += clamp((1 - ($LevelEndSFX.get_playback_position() / 1.84)),0.25,1) * delta * 650;
			if(newRotation.y >= -90): newRotation.y = -90
			$SonicGoal.set_rotation(newRotation)
		else:
			if($HUD/TopLayer.position.y != 0):
				if($HUD/TopLayer.position.y > 0):
					$HUD/TopLayer.position.y = 0
				else:
					var moveAmount = 800 * delta * abs(clamp((abs($HUD/TopLayer.position.y)/700),0.3,1))
					$HUD/TopLayer.position.y += moveAmount
			else:
				#RING AND TIME DISPLAY
				if(currentRings < ringsObtained or currentTime < $"/root/SpeedrunTimer".getTime()):
					if(ringsObtained > 0 and currentRings < ringsObtained):
						var r_speed = clamp(1-(currentRings/ringsObtained),0.2,1)
						currentRings += (r_speed*60) * delta
					if(currentTime < $"/root/SpeedrunTimer".getTime()):
						var t_speed = clamp(1-(currentTime/$"/root/SpeedrunTimer".getTime()),0.2,1)
						currentTime += (t_speed*60) * delta
					$HUD/TopLayer/TimeRingText.text = "RINGS: " + str(int(currentRings)) + "\nTIME: " + NumberToTime(currentTime);
				else:
					#print(str(currentRings) + " / " + str(ringsObtained) + " - " + str(currentTime) + " / " + str($"/root/SpeedrunTimer".getTime()))
					if(delaySceneLoad < 0): load_next_scene()
					else: delaySceneLoad -= delta
	pass
