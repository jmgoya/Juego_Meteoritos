# SectorMEteoritos.gd

class_name SectorMeteoritos
extends Node2D

# Atributos Export
export var cantidad_meteoritos = 10
export var intervalos_spanwn:float = 1.2

# Atributos
var spawners:Array

func crear(pos: Vector2, meteoritos:int) -> void:
	global_position = pos
	cantidad_meteoritos = meteoritos

# Metodos
func _ready() -> void:
	$Timer.wait_time = intervalos_spanwn
	almacenar_spawners()
	conectar_seniales_detectores()

# Metodos Customs
func almacenar_spawners():
	for spawner in $Spawners.get_children():
		spawners.append(spawner)

func spawner_aleatorio() -> int:
	randomize()
	return randi() % spawners.size()

func conectar_seniales_detectores() ->void:
	for detector in $DetectorFueraZona.get_children():
		detector.connect("body_entered", self, "_on_detector_body_entered")

##Señales Internas
func _on_detector_body_entered(body: Node) -> void:
	body.set_esta_en_sector(false)

#TimeOut crea los meteoritos
func _on_Timer_timeout() -> void:
	if cantidad_meteoritos == 0:
		$Timer.stop()
		return
	spawners[spawner_aleatorio()].spawnear_meteorito()
	cantidad_meteoritos -= 1
