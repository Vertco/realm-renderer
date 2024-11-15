extends Node

#region session constants
const imageCursor = preload("res://media/icons/image.svg")
#endregion

#region signals
@warning_ignore("unused_signal")
signal togglePlayersView(display:int)
@warning_ignore("unused_signal")
signal togglePlayersViewVis()
@warning_ignore("unused_signal")
signal updateOutliner(nodes:Array)
@warning_ignore("unused_signal")
signal updateOutlinerItem(index:int)
@warning_ignore("unused_signal")
signal layerChanged()
@warning_ignore("unused_signal")
signal loadSession()
#endregion

#region session variables
var gmZoom:float
var session:String:
	set(value):
		session = value
		path = "user://sessions/"+session
		assetsRoot = "user://sessions/"+session+"/assets"
		filePath = "user://sessions/"+session+"/"+session+".rrmap"
var path:String
var assetsRoot:String
var filePath:String
var activeLayer:int = 4:
	set(value):
		activeLayer = value
		emit_signal("layerChanged")
var newAsset:Node:
	set(value):
		newAsset = value
		if newAsset:
			Input.set_custom_mouse_cursor(imageCursor,Input.CURSOR_ARROW,Vector2(12,12))
		else:
			Input.set_custom_mouse_cursor(null)
#endregion

#region session functions
func save() -> void:
	var savePath:String = "user://sessions/"+session+"/"+session+".rrmap"
	var saveGame = FileAccess.open(savePath, FileAccess.WRITE)
	var saveNodes = get_tree().get_nodes_in_group("saveWithSession")
	for node in saveNodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue
		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue
		# Call the node's save function.
		var nodeData = node.call("save")
		# JSON provides a static method to serialized JSON string.
		var jsonString = JSON.stringify(nodeData)
		# Store the save dictionary as a new line in the save file.
		saveGame.store_line(jsonString)

func saveV2() -> void:
	var file := FileAccess.open(filePath, FileAccess.WRITE)
	var saveData := {
		"version": ProjectSettings.get_setting("application/config/version"),
		"nodes": []  # Initialize an empty array for nodes
	}
	var saveNodes := get_tree().get_nodes_in_group("saveWithSession")
	for node in saveNodes:
		if node.scene_file_path.is_empty():
			print("Savable node " + node.name + " is not an instanced scene, skipped")
			continue
		if !node.has_method("save"):
			print("Savable node " + node.name + " is missing a saveData() function, skipped saving")
			continue
		var nodeData = node.call("save")
		saveData["nodes"].append(nodeData)  # Append node data to the nodes array in saveData
	var metaString = JSON.stringify(saveData)
	file.store_line(metaString)
	file.close()  # Close the file after writing
#endregion
