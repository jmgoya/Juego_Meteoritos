# Eventos.gd
extends Node

signal disparo(proyectil)
signal nave_destruida(nave, posicion, explosiones)
signal sector_peligro(centro_camara, tipo_peligro, num_peligros)
signal spawn_meteorito (posicion, direccion, tamanio)
signal destruccion_meteorito (posicion)
signal base_destruida(base, posiciones)
signal spawn_orbital(orbital)
signal nivel_iniciado()
signal nivel_terminado()
signal detecto_zona_recarga(entrando)
signal cambio_numero_meteoritos(numero)
