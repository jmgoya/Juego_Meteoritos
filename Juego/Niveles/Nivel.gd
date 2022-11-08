## Nivel.gd
class_name Nivel
extends Node2D

## Atributos Export
export var explosion:PackedScene = null
export var meteorito:PackedScene = null
export var explosion_meteorito:PackedScene = null
export var sector_meteoritos:PackedScene = null
export var tiempo_transicion_camara:int = 2
export var enemigo_interceptor:PackedScene = null
export var rele_masa:PackedScene = null
export var tiempo_limite:int = 202

## Atributos onready
onready var contenedor_proyectiles:Node
onready var contenedor_meteoritos:Node
onready var contenedor_sector_meteoritos:Node
onready var camara_nivel:Camera2D = $CameraNivel
onready var contenedor_enemigos:Node
onready var actualizador_timer:Timer = $ActualizadorTimer

# Atributos (variable global de la calse)
var peligros_totales:int = 0
var player:Player = null
var numero_bases_enemigas = 0

## Metodos
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	conectar_seniales()
	crear_contenedores()
	player = DatosJuego.get_player_actual()
	numero_bases_enemigas = contabilizar_bases_enemigas()
	player = DatosJuego.get_player_actual()
	Eventos.emit_signal("nivel_iniciado")
	Eventos.emit_signal("actualizar_tiempo", tiempo_limite)
	actualizador_timer.start()

## Metodos Custom
func conectar_seniales() ->void:
	Eventos.connect("disparo", self, "_on_disparo")
	Eventos.connect("nave_destruida", self, "_on_nave_destruida")
	Eventos.connect("sector_peligro", self, "_on_sector_peligro")
	Eventos.connect("spawn_meteorito", self, "_on_spawn_meteoritos")
	Eventos.connect("destruccion_meteorito", self, "_on_meteorito_destruido")
	Eventos.connect("base_destruida", self,"_on_base_destruida")
	Eventos.connect("spawn_orbital", self, "_on_spawn_orbital")

func crear_contenedores() ->void:
	# contenedor proyectiles
	contenedor_proyectiles = Node.new()
	contenedor_proyectiles.name = "ContenedorProyectiles"
	add_child(contenedor_proyectiles)
	# contenedor meteoritos
	contenedor_meteoritos = Node.new()
	contenedor_meteoritos.name = "ContenedorMeteoritos"
	add_child (contenedor_meteoritos)
	# contenedor del sector de meteoritos
	contenedor_sector_meteoritos = Node.new()
	contenedor_sector_meteoritos.name = "ContenedorSectorMeteoritos"
	add_child(contenedor_sector_meteoritos)
	# contenedor de enemigos
	contenedor_enemigos = Node.new()
	contenedor_enemigos.name = "ContenedorEnemigos"
	add_child(contenedor_enemigos)

func crear_posicion_aleatoria(rango_horizontal: float, rango_vertical: float) -> Vector2:
	randomize()
	var rand_x = rand_range(-rango_horizontal, rango_horizontal)
	var rand_y = rand_range(-rango_vertical, rango_vertical)
	return Vector2 (rand_x, rand_y)

func crear_explosion(
	posicion: Vector2,
	num_e: int = 1,
	intervalo: float = 0.0,
	rangos_aleatorios: Vector2 = Vector2(0.0,0.0)
	) -> void:
		for _i in range (num_e):
			var new_explosion:Node2D = explosion.instance()
			new_explosion.global_position = posicion + crear_posicion_aleatoria(
				rangos_aleatorios.x,
				rangos_aleatorios.y
			)
			add_child(new_explosion)
			yield(get_tree().create_timer(intervalo),"timeout")

func contabilizar_bases_enemigas() -> int:
	return $ContenedorBaseEnemiga.get_child_count()

func crear_rele() -> void:
	var new_rele_masa:ReleDeMasa = rele_masa.instance()
	var pos_aleatoria:Vector2 = crear_posicion_aleatoria(400.0, 200.0)
	var margen:Vector2 = Vector2(400.0,400.0)
	if pos_aleatoria.x < 0:
		margen.x *= -1
	if pos_aleatoria.y < 0:
		margen.y *= -1
	new_rele_masa.global_position = player.global_position + (margen + pos_aleatoria)
	add_child(new_rele_masa)

func crear_sector_enemigos(num_enemigos: int) -> void:
	for i in range(num_enemigos):
		var new_interceptor:EnemigoInterceptor = enemigo_interceptor.instance()
		var spawn_pos:Vector2 = crear_posicion_aleatoria(1500.0, 1000.0)
		new_interceptor.global_position = player.global_position + spawn_pos
		contenedor_enemigos.add_child(new_interceptor)

func crear_sector_meteoritos(centro_camara:Vector2, numero_peligros:int) -> void:
	peligros_totales = numero_peligros
	var new_sector_meteoritos:SectorMeteoritos = sector_meteoritos.instance()
	new_sector_meteoritos.crear(centro_camara, numero_peligros)
	camara_nivel.global_position = centro_camara
	contenedor_sector_meteoritos.add_child(new_sector_meteoritos)
	camara_nivel.zoom = $Player/CameraPlayer.zoom
	camara_nivel.devolver_zoom_original()
	transicion_camaras(
		$Player/CameraPlayer.global_position,
		camara_nivel.global_position,
		camara_nivel,
		tiempo_transicion_camara
	)
	
func transicion_camaras(desde:Vector2, hasta:Vector2, camara_actual:Camera2D, tiempo: float) -> void:
	$TweenCamara.interpolate_property(
		camara_actual,
		"global_position",
		desde,
		hasta,
		tiempo,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	camara_actual.current = true
	$TweenCamara.start()

func control_de_peligros() -> void:
	peligros_totales -= 1
	Eventos.emit_signal("cambio_numero_meteoritos", peligros_totales)
	if peligros_totales == 0:
		contenedor_sector_meteoritos.get_child(0).queue_free()
		$Player/CameraPlayer.set_puede_hacer_zoom(true)
		var zoom_actual = $Player/CameraPlayer.zoom
		$Player/CameraPlayer.zoom = camara_nivel.zoom
		$Player/CameraPlayer.zoom_suavizado(zoom_actual.x, zoom_actual.y, 1.0)
		
		transicion_camaras( 
			camara_nivel.global_position,
			$Player/CameraPlayer.global_position,
			$Player/CameraPlayer,
			tiempo_transicion_camara #* 0.10
		)

func destruir_nivel() -> void:
	crear_explosion(
		player.global_position,
		8.0,
		1.5,
		Vector2(300.0,200.9)
	)
	player.destruir()

## Conexion señales externas
func _on_disparo(proyectil:Proyectil) -> void:
	contenedor_proyectiles.add_child(proyectil)

func _on_nave_destruida (nave: Player, posicion: Vector2, num_explosiones:int) -> void:
	if nave is Player:
		transicion_camaras(
			camara_nivel.global_position,
			$Player/CameraPlayer.global_position,
			camara_nivel,
			0
		)
		$RestartTimer.start()
	crear_explosion(posicion, num_explosiones, 0.6, Vector2(100.0,50.0))

func _on_spawn_meteoritos(pos_spawn: Vector2, dir_meteorito: Vector2, tamanio: float) -> void:
	var new_meteorito:Meteorito = meteorito.instance()
	new_meteorito.crear(
		pos_spawn,
		dir_meteorito,
		tamanio
	)
	contenedor_meteoritos.add_child(new_meteorito)

func _on_meteorito_destruido(pos: Vector2) -> void:
	var new_explosion:ExplosionMeteorito = explosion_meteorito.instance()
	new_explosion.global_position = pos
	add_child(new_explosion)
	control_de_peligros()

func _on_sector_peligro(centro_cam:Vector2, tipo_peligro:String, num_peligros:int) ->void:
	if tipo_peligro == "Meteorito":
		crear_sector_meteoritos(centro_cam, num_peligros)
		Eventos.emit_signal("cambio_numero_meteoritos", num_peligros)
	elif tipo_peligro == "Enemigo":
		crear_sector_enemigos(num_peligros)

## Señales externas
func _on_base_destruida(base, partes_pos: Array) -> void:
	for posicion in partes_pos:
		crear_explosion(posicion)
		yield(get_tree().create_timer(0.5),"timeout")
	
	numero_bases_enemigas -=1
	if numero_bases_enemigas == 0:
		crear_rele()

func _on_spawn_orbital(enemigo: EnemigoOrbital) -> void:
	contenedor_enemigos.add_child(enemigo)

## Señales internas
func _on_TweenCamara_tween_completed(object: Object, key: NodePath) -> void:
	if object.name == "CameraPlayer":
		object.global_position = $Player.global_position

func _on_RestartTimer_timeout() -> void:
	Eventos.emit_signal("nivel_terminado")
	yield(get_tree().create_timer(1.0),"timeout")
	get_tree().reload_current_scene()

func _on_ActualizadorTimer_timeout() -> void:
	tiempo_limite -= 1
	Eventos.emit_signal("actualizar_tiempo", tiempo_limite)
	if tiempo_limite == 0:
		destruir_nivel()
