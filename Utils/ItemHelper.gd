extends RefCounted

class_name ItemHelper

#----------------------------------------------------------------------
static func GetCardList() -> Array[CardStats]:
	var cardList: Array[CardStats] = []
	
	var DirsToExplore :Array[String] = [Main.dirs.ModDir + "/Resources/Cards/"]
	for g in DirsToExplore:
		var dir = DirAccess.open(g)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					print("Found directory: " + file_name)
					DirsToExplore.append(g + "/" + file_name)
				else:
					print("Found file: " + file_name)
					if (file_name.ends_with(".tres")):
						var crd = ResourceLoader.load(g + "/" + file_name)
						if (crd is CardStats):
							cardList.append(crd)

				file_name = dir.get_next()
	return cardList


#----------------------------------------------------------------------
##Returns the class name of the script without loading it
static func get_class_name_from_file(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""

	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line.begins_with("class_name "):
			return line.trim_prefix("class_name ").split(" ")[0]

	return ""

#----------------------------------------------------------------------
##Returns the class the provided script file extends from without loading it
static func get_extended_class_from_file(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""

	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line.begins_with("extends "):
			return line.trim_prefix("extends ").split(" ")[0]

	return ""
	
#----------------------------------------------------------------------
static func get_all_script_variables(res : Resource) -> Array[Dictionary]:
	return res.get_property_list().filter(func(prop):
		return prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE
	)


#----------------------------------------------------------------------
static func replace_class_source(original_path: String ,external_path: String) -> Error:
	var original : Script = ResourceLoader.load(original_path)
	if original == null:
		return ERR_CANT_OPEN

	var file := FileAccess.open(external_path, FileAccess.READ)
	if file == null:
		return ERR_CANT_OPEN

	var new_source = file.get_as_text()
	file.close()
	
	var originalSource : String = original.source_code
	var dif : bool = _files_are_identical(originalSource, new_source)
	
	if (dif):
		original.source_code = new_source
		var error = original.reload(true)
		print("Script Replaced {0}".format([original_path.get_file()]))
		return error
			
	return ERR_ALREADY_EXISTS

#----------------------------------------------------------------------
static func prettify_class_name(clName: String) -> String:
	var regex := RegEx.new()
	regex.compile("(?<!^)([A-Z])")
	return regex.sub(clName, " $1", true)

#----------------------------------------------------------------------
##Passes both files through a hash function and checks the resault
static func _files_are_identical(file_a: String,file_b: String) -> bool:

	var hash_a := FileAccess.get_sha256(file_a)
	var hash_b := FileAccess.get_sha256(file_b)

	return hash_a == hash_b

#----------------------------------------------------------------------
static func get_exported_enum_data(prop_dict: Dictionary) -> PackedStringArray:
	var enum_data : PackedStringArray = []
	
	if prop_dict.hint == PROPERTY_HINT_ENUM:
		var keys = prop_dict.hint_string.split(",")
		
		for i in keys.size():
			enum_data.append(keys[i])
			
	return enum_data

#----------------------------------------------------------------------
static func get_exported_enum_data_from_hint(hint: String) -> PackedStringArray:
	var enum_data : PackedStringArray = []

	var keys = hint.split(",")
	
	for i in keys.size():
		enum_data.append(keys[i])
			
	return enum_data
