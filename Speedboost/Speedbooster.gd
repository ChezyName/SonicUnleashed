extends Area3D

@export var Speed = 250;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for body in get_overlapping_bodies():
		if(body.name == "SonicPlayer"):
			body.Speedboost(get_global_transform().basis.z * -Speed)
