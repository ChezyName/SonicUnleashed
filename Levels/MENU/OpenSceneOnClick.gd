extends Button

@export var Scene:PackedScene

var sceneLoaded = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$"OnSelect".visible = is_hovered();
	pass

func _button_pressed():
	if(Scene == null): 
		push_warning(self.name + " has no 'scene' loaded. (BUTTON)")
		return
	if(sceneLoaded): return
	get_tree().change_scene_to_packed(Scene)
	sceneLoaded = true
	queue_free()
