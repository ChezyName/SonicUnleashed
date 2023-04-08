extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func spin(delta):
	$"Ring Model".rotation_degrees.y += 350 * delta;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	spin(delta)
	for body in get_overlapping_bodies():
		if(body.name == "SonicPlayer"):
			body.onRing()
			print(self.name + " is going to die.")
			queue_free()
	pass
