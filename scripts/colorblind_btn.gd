extends MenuButton

@onready var dropdown = get_popup()

var id_to_name = {
	0: "Normal",
	1: "Protanopia",
	2: "Deuteranopia",
	3: "Tritanopia",
}

func _ready():
	dropdown.id_pressed.connect(select_colorblind)
	
	# Update menu display
	var mode = SettingsManager.get_colorblind_mode()
	dropdown.set_item_checked(mode, true)
	text = id_to_name[mode]


func select_colorblind(id: int):
	for i in range(dropdown.item_count):
		dropdown.set_item_checked(i, i == id)
	text = id_to_name[id]
	
	SettingsManager.set_colorblind_mode(id)
