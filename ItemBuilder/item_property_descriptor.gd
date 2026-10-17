extends PanelContainer

class_name ItemPropertyDescriptor

@export var simpleSectionScene : PackedScene

signal ItemUpdated

var describedItem : Item

var generalSettingsSecction : CardModuleSection

func ConfigureItem(it : Item) -> void:
	describedItem = it
	
	print("Showing item {0} of path {1}".format([it.ItemName, it.resource_path]))
	for g in get_child(0).get_children():
		g.queue_free()
	
	generalSettingsSecction = AddSection("GENERAL SETTINGS")
	get_child(0).add_child(generalSettingsSecction)
	generalSettingsSecction.DissableAdding()
	generalSettingsSecction.PropertyChanged.connect(OnPropertyChanged)
	generalSettingsSecction.folded = false
	var props = ItemHelper.get_all_script_variables(it)
	
	var wantedProps : PackedStringArray = ["CardProviding", "MissileFile", "Distance", "Speed", "Damage", "Type","WType", "Upgrades", "UpgradeVersion", "UpgradeTime", "IsDamaged", "disp", "DispositionAmm","ItemIcon", "ItemName", "ItemDesc", "MaxStackCount", " CardProviding", "Tier", " CanTransfer", "Cost", "PartType"]
	
	for prop : Dictionary in props:
		var properyName : String = prop["name"]
		if (wantedProps.has(properyName)):
			generalSettingsSecction.ManualProp(prop, it)
	
func MoveUp(moved : Resource, arr : Array) -> void:
	var index = arr.find(moved)
	if (index == 0):
		return
	
	var saved = arr[index - 1]
	arr[index - 1] = moved
	arr[index] = saved
	OnPropertyChanged()

func MoveDown(moved : Resource, arr : Array) -> void:
	var index = arr.find(moved)
	if (index == arr.size() - 1):
		return
	
	var saved = arr[index + 1]
	arr[index + 1] = moved
	arr[index] = saved
	OnPropertyChanged()

func OnPropertyChanged() -> void:
	ResaveCard()
	ItemUpdated.emit()

func ResaveCard() -> void:
	var prevUID = ItemHelper.get_uid_from_tres(describedItem.resource_path)
	
	ResourceSaver.save(describedItem, describedItem.resource_path)
	ItemHelper.write_uid_to_tres(describedItem.resource_path, prevUID)
	
	print("Card Saved At {0}".format([describedItem.resource_path]))

func AddSection(sectionName : String) -> CardModuleSection:
	var section : CardModuleSection = simpleSectionScene.instantiate()
	section.SetSectionName(sectionName)
	return section
