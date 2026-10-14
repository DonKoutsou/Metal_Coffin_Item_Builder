extends CardModuleProperty

class_name CardModuleStringFileProperty

@export var picker : ResourcePicker

var isRes : bool = true

func SetProperty(pName : String, value : Variant) -> void:
	super(pName, value)
	
	if (!value):
		return
	if (value is Resource):
		picker.SetFile(value.resource_path)
		isRes = true
	else:
		picker.SetFile(value)
		isRes = false

func _on_resource_picker_changed(t: String) -> void:
	propertyValue = t
	PropertyChanged.emit(propertyName, load(t))
