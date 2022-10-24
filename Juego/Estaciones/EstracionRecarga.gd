# EstacionRecarga.gd
class_name EstacioRecarga
extends Node2D

## Atributos Export
export var energia:float = 10
export var radio_energia_entregada:float = 0.5

onready var carga_sfx:AudioStreamPlayer = $AudioCarga
# Atributos
var nave_player:Player = null
var player_en_zona:bool = false

# Metodos
func _unhandled_input(event: InputEvent) -> void:
	if not puede_recargar(event):
		return
	
	controlar_energia()
	
	if event.is_action("recargar_escudo"):
		nave_player.get_escudo().controlar_energia(radio_energia_entregada)
	if event.is_action("recargar_rayo"):
		nave_player.get_laser().controlar_energia(radio_energia_entregada)

# Metodos Custom
func puede_recargar(event: InputEvent) -> bool:
	var hay_input = event.is_action("recargar_escudo") or event.is_action("recargar_rayo")
	if hay_input and player_en_zona and energia > 0.0:
		if !carga_sfx.playing:
			carga_sfx.play()
		return true
	return false

func controlar_energia() -> void:
	energia -= radio_energia_entregada
	if energia <= 0.0:
		$AudioVacio.play()
	print ("Energia Estacion ", energia)

# Señales internas
func _on_AreaRecarga_body_entered(body: Node) -> void:
	if body is Player:
		nave_player = body
		player_en_zona = true
	body.set_gravity_scale(0.1)

func _on_AreaRecarga_body_exited(body: Node) -> void:
	if body is Player:
		player_en_zona = false
	body.set_gravity_scale(0.0)

func _on_AreaColision_body_entered(body: Node) -> void:
	if body.has_method("destruir"):
		body.destruir()
