## EnemigoDummy.gd

extends Node2D

var hitpoints:float = 100

func _process(delta: float) -> void:
	$Canion.set_esta_disparando(true)

func _on_Area2D_body_entered(body: Node) -> void:
	if body is Player:
		body.destruir()

func recibir_danio(intensidad_danio:float) -> void:
	hitpoints -= intensidad_danio
	if hitpoints <= 0:
		queue_free()
	
