extends RigidBody3D

var AreaParent:Area3D;
var rng = RandomNumberGenerator.new()
var cantPickupTime = 0.3;

var destroy:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Spawned New Ring!")
	AreaParent = get_node("SonicRing")
	var randomX = rng.randf_range(-25, 25)
	var randomY = rng.randf_range(2.5, 15)
	self.linear_velocity = Vector3(0,randomY,randomX)
	var spikes = get_node_or_null("SonicRing/Spikes")
	pass # Replace with function body.

func spin(delta):
	$"SonicRing/Ring Model".rotation_degrees.y += 350 * delta;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position.x = 0
	cantPickupTime -= delta;
	if(cantPickupTime < 0):
		spin(delta)
		if(!destroy):
			for body in AreaParent.get_overlapping_bodies():
				if(body.name == "SonicPlayer"):
					body.onRing()
					destroy = true
					$RingPickup.play()
					var node = get_node_or_null("Ring Model")
					if(node != null): node.visible = false
					await $RingPickup.finished
					queue_free()
	pass
