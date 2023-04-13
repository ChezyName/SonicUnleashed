extends Area3D

var did = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(did): return
	for body in get_overlapping_bodies():
		if(body.name == "SonicPlayer"):
			$CheckpointSFX.play()
			body.onCheckpoint(self.position)
			did = true
	pass
