extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


var destroying = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(destroying == true): return
	for body in get_overlapping_bodies():
		if(body.name == "SonicPlayer"):
			if(abs(body.linear_velocity.z) > 25 and body.Rolling):
				destroying = true
				$RockCollider.queue_free()
				$BreakSFX.play()
				await $BreakSFX.finished
				queue_free()
	pass
