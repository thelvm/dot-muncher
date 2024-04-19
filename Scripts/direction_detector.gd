extends Node

signal entered_new_tile(directions: int)

func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int):
	if body is TileMap:
		var tile_position: Vector2i = body.get_coords_for_body_rid(body_rid)
		var tile_data: TileData = body.get_cell_tile_data(0, tile_position)
		var available_directions: int = tile_data.get_custom_data_by_layer_id(0)
		entered_new_tile.emit(available_directions)

