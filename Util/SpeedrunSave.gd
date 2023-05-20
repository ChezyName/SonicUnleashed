extends Node

func Save(data:LevelData):
	var map:String = data.levelName
	print("Saving @ " + map)
	var save_game = FileAccess.open("user://"+map+".sonic", FileAccess.WRITE)
	var dataStr:String = data.toJSONString()
	print(dataStr)
	save_game.store_pascal_string(dataStr)

func Load(map:String) -> LevelData:
	if not FileAccess.file_exists("user://"+map+".sonic"):
		push_warning("File Not Found")
		return null
	var load_game = FileAccess.open("user://"+map+".sonic", FileAccess.READ)
	var data = load_game.get_pascal_string()
	return LevelData.overrideData(data)
