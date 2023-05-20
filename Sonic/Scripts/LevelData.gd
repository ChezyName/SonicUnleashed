extends Resource

class_name LevelData

@export var levelName = ""
@export var speedTime = ""
@export var RingCount = ""

func toJSONString() -> String:
	var Data = {
		"Name": levelName,
		"Time": snappedf(speedTime,0.001),
		"Rings": RingCount,
	}
	return JSON.stringify(Data)

static func overrideData(JSONData:String) -> LevelData:
	var newData = JSON.parse_string(JSONData)
	var newLevelData = LevelData.new()
	newLevelData.levelName = newData["Name"]
	newLevelData.speedTime = newData["Time"]
	newLevelData.RingCount = newData["Rings"]
	return newLevelData
