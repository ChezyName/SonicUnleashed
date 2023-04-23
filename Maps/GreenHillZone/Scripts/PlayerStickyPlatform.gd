extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


var sonic:Node3D = null

func _process(delta):
	var sonicTouched = false
	for body in get_overlapping_bodies():
		if(body.name == "SonicPlayer"):
			#print("SONIC BE TOUCHING ;)")
			sonicTouched = true
			sonic = body
			sonic.reparent(self)
	if(!sonicTouched and sonic != null):
		sonic.reparent(get_tree().current_scene)
		sonic = null
	pass
