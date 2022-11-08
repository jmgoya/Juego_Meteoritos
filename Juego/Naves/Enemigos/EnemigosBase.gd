## EnemigoBase.gd
class_name EnemigosBase
extends NaveBase

## Atributos
var player_objetivo:Player = null
var dir_player:Vector2
var frame_actual:int = 0

## Metodos
func _ready() -> void:
	player_objetivo = DatosJuego.get_player_actual()
	Eventos.connect("nave_destruida", self, "_on_nave_destruida")
	#temporal
	#canion.set_esta_disparando(true)

func _physics_process(delta: float) -> void:
	frame_actual +=1
	if frame_actual % 3 == 0:
		rotar_hacia_player()

## Metodos Cuystom
func _on_nave_destruida(nave: NaveBase, _posicion, _explosiones) -> void:
	if nave is Player:
		player_objetivo = null
	if nave.is_in_group("minimapa"):
		Eventos.emit_signal("minimapa_objeto_destruido", nave)

func rotar_hacia_player() -> void:
	if player_objetivo:
		dir_player =  player_objetivo.global_position - global_position
		rotation = dir_player.angle()
