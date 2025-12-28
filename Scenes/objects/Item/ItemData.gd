extends Resource
class_name ItemData

enum DAMAGE_TYPE {
    HP,
    MP
}

@export var damage_type: DAMAGE_TYPE = DAMAGE_TYPE.HP
@export var damage_amount: int = 0
@export var item_name: String = ""
@export var item_description: String = ""
@export var price : int = -1
@export var world_texture : Texture2D = null
@export var icon_texture : Texture2D = null


