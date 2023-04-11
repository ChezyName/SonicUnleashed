extends Area3D

@export var MaxSpringSpeed = 15;
@export var MinSpringSpeed = 2.5;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for body in get_overlapping_bodies():
		if(body.name == "SonicPlayer" or body.name.contains("SonicRingGrab")):
			print(body)
			var velocty = body.linear_velocity;
			var speed = abs(body.linear_velocity.z + body.linear_velocity.y);
			#print("REBOUNCING " + str(velocty) + " @ " + body.name + " W " + str(speed))
			print(str(MinSpringSpeed) + " / " + str(MaxSpringSpeed))
			body.linear_velocity = (self.transform.basis.y) * (clamp(speed,MinSpringSpeed,MaxSpringSpeed));
	pass
