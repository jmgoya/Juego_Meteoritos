#MiniMapa.gd
extends MarginContainer

## Atributos Export
export var escala_zoom:float = 4.0

## Atributos
var escala_grilla:Vector2
var player:Player = null

## Atributos Onready
onready var zona_renderizado:TextureRect = $CuadroMiniMapa/ContenedorIconos/ZonaRenderMiniMapa
onready var icono_base = $CuadroMiniMapa/ContenedorIconos/ZonaRenderMiniMapa/IconoBaseEnemiga
onready var icono_player:Sprite  = $CuadroMiniMapa/ContenedorIconos/ZonaRenderMiniMapa/IconoPlayer
onready var icono_estacion:Sprite = $CuadroMiniMapa/ContenedorIconos/ZonaRenderMiniMapa/IconoEstacion
onready var items_mini_mapa:Dictionary = {}

## Metodos
func _ready() -> void:
	set_process(false)
	icono_player.position = zona_renderizado.rect_size * 0.5
	escala_grilla = zona_renderizado.rect_size / (get_viewport_rect().size * escala_zoom)
	Eventos.connect("nivel_iniciado", self, "_on_nivel_iniciado")
	Eventos.connect("nave_destruida", self, "_on_nave_destruida")

func _process(delta: float) -> void:
	if not player:
		return
	icono_player.rotation_degrees = player.rotation_degrees + 90
	modificar_posicion_iconos()

## Metodos Custom
func _on_nivel_iniciado() -> void:
	player = DatosJuego.get_player_actual()
	obtener_objetos_minimapa()
	set_process(true)

func _on_nave_destruida(nave: NaveBase, _posicion, explosiones) -> void:
	if nave is Player:
		player = null

func obtener_objetos_minimapa() -> void:
	var objetivos_en_ventana:Array = get_tree().get_nodes_in_group("minimapa")
	for objeto in objetivos_en_ventana:
		if not items_mini_mapa.has(objeto):
			var sprite_icono:Sprite
			if objeto is BaseEnemiga:
				sprite_icono = icono_base.duplicate()
			elif objeto is EstacioRecarga:
				sprite_icono = icono_estacion.duplicate()
			items_mini_mapa[objeto] = sprite_icono
			items_mini_mapa[objeto].visible = true
			zona_renderizado.add_child(items_mini_mapa[objeto])

func modificar_posicion_iconos() -> void:
	for item in items_mini_mapa:
		var item_icono:Sprite = items_mini_mapa[item]
		var offset_pos:Vector2 = item.position - player.position
		var pos_icono:Vector2 = offset_pos * escala_grilla + (zona_renderizado.rect_size * 0.5)
		pos_icono.x = clamp(pos_icono.x, 0, zona_renderizado.rect_size.x)
		pos_icono.y = clamp(pos_icono.y, 0, zona_renderizado.rect_size.y)
		item_icono.position = pos_icono
		if zona_renderizado.get_rect().has_point(pos_icono - zona_renderizado.rect_position):
			item_icono.scale = Vector2(0.5, 0.5)
		else:
			item_icono.scale = Vector2(0.3, 0.3)
