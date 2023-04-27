extends Node


func Save(map:String,time:float):
	print("Saving @ " + map + " : " + str(time))
	var save_game = FileAccess.open("user://"+map+".sonic", FileAccess.WRITE)
	save_game.store_float(time)

func Load(map:String) -> float:
	if not FileAccess.file_exists("user://"+map+".sonic"):
		push_warning("File Not Found")
		return 0
	var load_game = FileAccess.open("user://"+map+".sonic", FileAccess.READ)
	var time = load_game.get_float()
	print("Saving @ " + map + " : " + str(time))
	return time
