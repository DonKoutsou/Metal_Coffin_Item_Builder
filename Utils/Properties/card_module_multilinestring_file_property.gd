extends CardModuleProperty

class_name CardModuleMultiLineStringProperty

@export var line : TextEdit

func SetProperty(pName : String, value : Variant) -> void:
	super(pName, value)
	line.text = value
	
func _on_text_edit_text_changed() -> void:
	propertyValue = line.text
	PropertyChanged.emit(propertyName, line.text)
