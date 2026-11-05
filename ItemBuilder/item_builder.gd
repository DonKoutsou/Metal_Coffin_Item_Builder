extends PanelContainer

class_name ItemBuilder

@export var Menu : PopupMenu
@export var desc : ItemDescriptor
@export var propDesc : ItemPropertyDescriptor

var items : Array[Item]
var currentItem : int = 0

func _ready() -> void:
	UpdateItems()
#--------------------------------------------------------
##Checks happening directory and pulls all of them out
func UpdateItems() -> void:
	Menu.clear()
	items.clear()
	var DirsToExplore :Array[String] = [Main.dirs.ModDir + "/Resources/Items/"]
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
						if (crd is Item):
							items.append(crd)
							Menu.add_item(crd.ItemName)
				
				file_name = dir.get_next()
	
	for g in items:
		if (g is ShipPart):
			var needResave : bool = false
			
			var hull : ShipPartUpgrade
			for up : ShipPartUpgrade in g.Upgrades:
				
				if (up.CurrentValue != up.UpgradeAmmount):
					up.CurrentValue = up.UpgradeAmmount
					needResave = true
					
				if (up.UpgradeName == STAT_CONST.STATS.HULL):
					hull = up

			if (!hull):
				var newHull = ShipPartUpgrade.new()
				newHull.UpgradeName = STAT_CONST.STATS.HULL
				newHull.UpgradeAmmount = 30
				newHull.CurrentValue = 30
				g.Upgrades.append(newHull)
				needResave = true

			if (needResave):
				ResaveItem(g)
				
				
	SetItem(items[currentItem])

func ResaveItem(it : Item) -> void:
	var prevUID = ItemHelper.get_uid_from_tres(it.resource_path)
	
	ResourceSaver.save(it, it.resource_path)
	ItemHelper.write_uid_to_tres(it.resource_path, prevUID)
	
	print("Item Saved At {0}".format([it.resource_path]))

func _on_open_item_index_pressed(index: int) -> void:
	currentItem = index
	SetItem(items[index])
	
	
func SetItem(it : Item) -> void:
	desc.SetManual(it)
	propDesc.ConfigureItem(it)


func _on_panel_container_item_updated() -> void:
	desc.SetManual(items[currentItem])


func _on_new_item_index_pressed(index: int) -> void:
	var diag = FileDialog.new()
	diag.use_native_dialog = true
	diag.access = FileDialog.ACCESS_FILESYSTEM
	diag.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	diag.filters.append("*.tres")
	diag.current_dir = Main.dirs.ModDir + "/Resources/Items/"
	add_child(diag)
	diag.popup_centered()

	var f : String = await diag.file_selected
	if (f.is_empty()):
		return
	if (f.get_extension().is_empty()):
		f += ".tres"
	else :if (f.get_extension() != "tres"):
		return

	var newItem : Item
	
	if (index == 0):
		newItem = Item.new()
	else: if (index == 1):
		newItem = ShipPart.new()
	else: if (index == 2):
		newItem = MissileItem.new()
	else: if (index == 3):
		newItem = AmmoItem.new()
	
	var itemName = f.get_file().replace(".tres", "")
	newItem.ItemName = itemName
	
	if (FileAccess.file_exists(f)):
		var existingIndex = items.find(ResourceLoader.load(f))
		items[existingIndex] = newItem
		currentItem = existingIndex
		SetItem(newItem)
	else:
		items.append(newItem)
		currentItem = items.size() - 1
		SetItem(newItem)
	
	ResourceSaver.save(newItem, f)
