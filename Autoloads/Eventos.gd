# Eventos.gd

extends Node

signal disparo(proyectil)
signal sector_peligro(centro_camara, tipo_peligro, num_peligros)
signal spawn_meteorito (posicion, direccion, tamanio)
signal destruccion_meteorito (posicion)
signal nave_destruida (nave, posicion, explosiones)
