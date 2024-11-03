extends Tile
class_name Arrow

var ArrowActivateEffect: PackedScene = preload("res://tile_effects/arrow_activate_effect/ArrowActivateEffect.tscn")
var push_force = 75 # used for gliding up/down/left/right
var push_force_stand_pressed = 3200 # used for standing, bumps you up into the air
var push_force_stand_idle = 1250
var push_force_bump = 75 #
var phantom_push_force_bump = 400
var phantom_push_force_bump_decay = 0.85


func init():
	matter_type = Tile.SOLID


func push(node: Node2D, tilemap: Node2D, coords: Vector2i, push_dir: Vector2):
	if "velocity" not in node:
		return
		
	var rotated_push_dir = push_dir.rotated(tilemap.global_rotation)
	var target_global_position = tilemap.to_global((coords * 128) + Vector2i(64, 64)) 
	var player_global_position = node.to_global(Vector2(0, -100))
	var player_dir = (player_global_position - target_global_position).normalized()
	var cross = rotated_push_dir.cross(player_dir)
	
	# player is perpendicular, running across or sliding up/down
	if abs(cross) > 0.5:
		node.velocity += rotated_push_dir * push_force
	
	# player is standing or bumping on the block
	else:
		if abs(node.rotation - rotated_push_dir.rotated(PI/2).angle()) < 0.1:
			if node.is_on_floor():
				if Input.is_action_pressed("jump"):
					node.velocity += rotated_push_dir * push_force_stand_pressed
				else:
					node.velocity += rotated_push_dir * push_force_stand_idle
			else:
				print('phantom')
				node.velocity += rotated_push_dir * push_force
				node.phantom_velocity = rotated_push_dir * phantom_push_force_bump
				node.phantom_velocity_decay = phantom_push_force_bump_decay
		else:
			node.velocity += rotated_push_dir * push_force
	
	# add effect
	var effect_name = str(coords.x) + "-" + str(coords.y) + "-arrow"
	var existing_effect = tilemap.get_node(effect_name)
	if existing_effect:
		existing_effect.get_node("AnimationPlayer").seek(0)
		return
	var effect = ArrowActivateEffect.instantiate()
	effect.position = (coords * Settings.tile_size) + Settings.tile_size_half
	effect.rotation = push_dir.rotated(-PI / 2).angle()
	effect.name = effect_name
	tilemap.add_child(effect)
