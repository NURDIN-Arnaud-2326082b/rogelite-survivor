extends Node

# warnings-disable
signal coin_collected()
signal nb_coins_changed(new_count: int)
signal character_hp_changed(new_hp: int)
signal room_finished()
signal actor_died(actor: Node)
signal spawn_item(item_data: Resource, position: Vector2)
signal spawn_special_item(item_scene: PackedScene, position: Vector2)
signal object_collected(item_data: Item)
