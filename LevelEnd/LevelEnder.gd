extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


var levelEnded:bool = false
var ringsObtained:int = 0

var currentTime:float = 0
var currentRings:float = 0

func NumberToTime(number):
	var minutes = floor(number / 60)
	var remaining_seconds = fmod(number,60)
	return str(minutes) + ":" + str(int(remaining_seconds)).pad_zeros(2)

func _process(delta):
	if(!levelEnded):
		for body in get_overlapping_bodies():
			if(body.name == "SonicPlayer"):
				levelEnded = true
				ringsObtained = body.onLevelEnded()
				$LevelEndSFX.play()
				$"/root/SpeedrunTimer".onLevelFinished()
				print("Level Endeed With:" + str(ringsObtained) + " RINGS.");
	else:
		if($LevelEndSFX.playing): 
			var newRot = clamp((1 - ($LevelEndSFX.get_playback_position() / 1.84)),0,1) * delta * 127.25;
			$SonicGoal.rotate_y(newRot)
		else:
			if($HUD/TopLayer.position.y != 0):
				if($HUD/TopLayer.position.y > 0):
					$HUD/TopLayer.position.y = 0
				else:
					var moveAmount = 800 * delta * abs(clamp((abs($HUD/TopLayer.position.y)/700),0.3,1))
					$HUD/TopLayer.position.y += moveAmount
			else:
				#RING AND TIME DISPLAY
				if(currentRings != ringsObtained or currentTime != $"/root/SpeedrunTimer".getTime()):
					if(ringsObtained > 0 and currentTime < ringsObtained):
						var r_speed = clamp(1-(currentTime/ringsObtained),0.2,1)
						currentRings += (r_speed*15) * delta
					if(currentTime < $"/root/SpeedrunTimer".getTime()):
						var t_speed = clamp(1-(currentTime/$"/root/SpeedrunTimer".getTime()),0.2,1)
						currentTime += (t_speed*60) * delta
					$HUD/TopLayer/TimeRingText.text = "RINGS: " + str(int(currentRings)) + "\nTIME: " + NumberToTime(int(currentTime));
	pass
