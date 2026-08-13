class_name EncounterManager
extends Node

signal enemy_count_changed(remaining: int)
signal encounter_cleared

var active_enemies: Array[Node] = []


func register_existing_enemies() -> void:
	active_enemies.clear()
	for enemy: Node in get_tree().get_nodes_in_group(&"enemies"):
		register_enemy(enemy)
	enemy_count_changed.emit(active_enemies.size())


func register_enemy(enemy: Node) -> void:
	if enemy in active_enemies:
		return
	active_enemies.append(enemy)
	if enemy.has_signal("died"):
		enemy.died.connect(_on_enemy_died)


func _on_enemy_died(enemy: Node) -> void:
	active_enemies.erase(enemy)
	enemy_count_changed.emit(active_enemies.size())
	if active_enemies.is_empty():
		encounter_cleared.emit()
