extends Area3D

var destroy:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func spin(delta):
	$"Ring Model".rotation_degrees.y += 350 * delta;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	spin(delta)
	if(destroy == false):
		for body in get_overlapping_bodies():
			if(body.name == "SonicPlayer"):
				body.onRing()
				destroy = true
				$RingPickup.play()
				$"Ring Model".visible = false
				await $RingPickup.finished
				queue_free()
	pass
