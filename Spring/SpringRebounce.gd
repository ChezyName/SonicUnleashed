extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for body in get_overlapping_bodies():
		if(body.name == "SonicPlayer" or body.name == "SonicRing"):
			var velocty = body.linear_velocity;
			var speed = abs(body.linear_velocity.z + body.linear_velocity.y);
			print("REBOUNCING " + str(velocty) + " @ " + body.name + " W " + str(speed))
			body.linear_velocity = (self.transform.basis.y) * (clamp(speed,50,150));
	pass
