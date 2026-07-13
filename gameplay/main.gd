extends Node2D

# =====================================================================
#  EL ÚLTIMO FARERO — prototipo roguelite estilo "survivors"
#
#  Sos el último farero de la costa. Cada noche, las criaturas del
#  abismo salen del mar. Tu farol dispara orbes de luz solo, hacia
#  el enemigo más cercano. Movete, esquivá y sobreviví.
#
#  Este archivo dirige el juego completo. Los valores de acá abajo
#  se pueden cambiar sin miedo: guardá (Ctrl+S) y volvé a jugar (F5).
# =====================================================================

# ----- ATAQUE -----
var danio := 6.0             # daño de cada orbe de luz
var cadencia := 0.8          # segundos entre disparos (menos = más rápido)
var orbes_por_disparo := 1   # cuántos orbes salen en cada disparo
var perforaciones := 0       # enemigos extra que atraviesa cada orbe

# ----- DIFICULTAD -----
var intervalo_spawn_inicial := 1.4   # segundos entre enemigos al empezar
var intervalo_spawn_minimo := 0.25   # nunca aparecen más rápido que esto

# ----- ESTADO DEL JUEGO (no hace falta tocar de acá para abajo) -----
var jugador: Jugador
var enemigos: Array = []
var gemas: Array = []
var orbes: Array = []
var tiempo_partida := 0.0
var temporizador_disparo := 0.0
var temporizador_spawn := 0.0
var nivel := 1
var xp := 0
var xp_necesaria := 5
var eliminados := 0
var terminado := false

# ----- Interfaz -----
var hud: CanvasLayer
var barra_vida: ColorRect
var barra_xp: ColorRect
var etiqueta_tiempo: Label
var etiqueta_nivel: Label
var etiqueta_eliminados: Label
var panel_mejoras: CenterContainer
var caja_mejoras: VBoxContainer
var panel_final: CenterContainer
var etiqueta_final: Label

# ----- Control táctil (para celular) -----
var touch_inicio := Vector2.ZERO
var touch_activo := false

# ----- Mejoras posibles al subir de nivel -----
var mejoras := [
    {"titulo": "Luz más intensa", "detalle": "+3 de daño por orbe", "id": "danio"},
    {"titulo": "Farol ágil", "detalle": "Dispara 15% más rápido", "id": "cadencia"},
    {"titulo": "Orbe extra", "detalle": "+1 orbe por disparo", "id": "orbe"},
    {"titulo": "Luz penetrante", "detalle": "Los orbes atraviesan +1 enemigo", "id": "perforar"},
    {"titulo": "Botas de cubierta", "detalle": "+12% velocidad de movimiento", "id": "velocidad"},
    {"titulo": "Imán de ámbar", "detalle": "Atrae gemas desde más lejos", "id": "iman"},
    {"titulo": "Corazón de roble", "detalle": "+25 de vida máxima y te cura 25", "id": "vida"},
    {"titulo": "Té caliente", "detalle": "Regenera +1 de vida por segundo", "id": "regen"},
]


func _ready():
    RenderingServer.set_default_clear_color(Color(0.04, 0.07, 0.13))
    _configurar_teclas()
    _crear_jugador()
    _crear_interfaz()


func _process(delta):
    if terminado:
        return
    tiempo_partida += delta
    _generar_enemigos(delta)
    _disparar(delta)
    _chequear_impactos()
    _chequear_contacto_enemigos()
    _atraer_gemas(delta)
    _limpiar_listas()
    _actualizar_interfaz()
    queue_redraw()
    if jugador.vida <= 0.0:
        _fin_del_juego()


# =============== ENTRADA ===============

func _configurar_teclas():
    # Registra WASD + flechas como acciones de movimiento
    var teclas := {
        "mover_izq": [KEY_A, KEY_LEFT],
        "mover_der": [KEY_D, KEY_RIGHT],
        "mover_arriba": [KEY_W, KEY_UP],
        "mover_abajo": [KEY_S, KEY_DOWN],
    }
    for accion in teclas:
        if InputMap.has_action(accion):
            continue
        InputMap.add_action(accion)
        for tecla in teclas[accion]:
            var evento := InputEventKey.new()
            evento.physical_keycode = tecla
            InputMap.action_add_event(accion, evento)


func _unhandled_input(evento):
    # Joystick táctil: arrastrá el dedo en cualquier parte de la pantalla
    if evento is InputEventScreenTouch:
        if evento.pressed:
            touch_activo = true
            touch_inicio = evento.position
        else:
            touch_activo = false
            if jugador != null:
                jugador.direccion_joystick = Vector2.ZERO
    elif evento is InputEventScreenDrag and touch_activo and jugador != null:
        jugador.direccion_joystick = ((evento.position - touch_inicio) / 80.0).limit_length(1.0)


# =============== JUGADOR Y ENEMIGOS ===============

func _crear_jugador():
    jugador = Jugador.new()
    add_child(jugador)
    var camara := Camera2D.new()
    jugador.add_child(camara)   # la cámara sigue al farero


func _generar_enemigos(delta):
    temporizador_spawn -= delta
    if temporizador_spawn > 0.0:
        return
    # El intervalo entre enemigos baja a medida que pasa el tiempo
    temporizador_spawn = max(intervalo_spawn_minimo, intervalo_spawn_inicial - tiempo_partida * 0.02)
    var tipo := 0
    var azar := randf()
    if tiempo_partida > 90.0 and azar < 0.12:
        tipo = 2   # Abisal (tanque) después de 1:30
    elif tiempo_partida > 25.0 and azar < 0.40:
        tipo = 1   # Medusa (rápida) después de 0:25
    var dureza := 1.0 + tiempo_partida / 40.0
    var e := Enemigo.crear(tipo, dureza)
    e.jugador = jugador
    e.position = jugador.position + Vector2.from_angle(randf() * TAU) * 760.0
    add_child(e)
    enemigos.append(e)


func _enemigo_mas_cercano():
    var mejor = null
    var distancia_min := 999999.0
    for e in enemigos:
        if not is_instance_valid(e):
            continue
        var d: float = jugador.position.distance_to(e.position)
        if d < distancia_min:
            distancia_min = d
            mejor = e
    return mejor


func _eliminar_enemigo(e):
    var g := Gema.new()
    g.xp = e.xp
    g.position = e.position
    add_child(g)
    gemas.append(g)
    eliminados += 1
    e.queue_free()


# =============== COMBATE ===============

func _disparar(delta):
    temporizador_disparo -= delta
    if temporizador_disparo > 0.0:
        return
    var objetivo = _enemigo_mas_cercano()
    if objetivo == null:
        return
    temporizador_disparo = cadencia
    var angulo_base: float = (objetivo.position - jugador.position).angle()
    for i in orbes_por_disparo:
        # Si hay varios orbes, salen en abanico
        var desvio := 0.0
        if orbes_por_disparo > 1:
            desvio = (i - (orbes_por_disparo - 1) / 2.0) * 0.22
        var o := Orbe.new()
        o.position = jugador.position
        o.direccion = Vector2.from_angle(angulo_base + desvio)
        o.danio = danio
        o.perforaciones = perforaciones
        add_child(o)
        orbes.append(o)


func _chequear_impactos():
    # Orbes de luz contra criaturas
    for o in orbes:
        if not is_instance_valid(o):
            continue
        for e in enemigos:
            if not is_instance_valid(e) or e.vida <= 0.0 or e in o.golpeados:
                continue
            if o.position.distance_to(e.position) < e.radio + 9.0:
                e.vida -= o.danio
                o.golpeados.append(e)
                if e.vida <= 0.0:
                    _eliminar_enemigo(e)
                o.perforaciones -= 1
                if o.perforaciones < 0:
                    o.queue_free()
                    break


func _chequear_contacto_enemigos():
    # Criaturas que tocan al farero le hacen daño
    for e in enemigos:
        if not is_instance_valid(e):
            continue
        if e.enfriamiento_ataque <= 0.0 and e.position.distance_to(jugador.position) < e.radio + 12.0:
            jugador.recibir_danio(e.danio)
            e.enfriamiento_ataque = 0.8


# =============== EXPERIENCIA Y NIVELES ===============

func _atraer_gemas(delta):
    for g in gemas:
        if not is_instance_valid(g):
            continue
        var distancia: float = g.position.distance_to(jugador.position)
        if distancia < jugador.iman_radio:
            g.position = g.position.move_toward(jugador.position, 420.0 * delta)
        if distancia < 22.0:
            xp += g.xp
            g.queue_free()
            _chequear_nivel()


func _chequear_nivel():
    if xp < xp_necesaria or panel_mejoras.visible:
        return
    xp -= xp_necesaria
    nivel += 1
    xp_necesaria = 4 + nivel * 3
    _mostrar_mejoras()


func _mostrar_mejoras():
    # Borra los botones de la vez anterior
    for hijo in caja_mejoras.get_children():
        if hijo is Button:
            hijo.queue_free()
    # Elige 3 mejoras al azar
    var opciones := mejoras.duplicate()
    opciones.shuffle()
    for i in 3:
        var mejora: Dictionary = opciones[i]
        var boton := Button.new()
        boton.text = str(mejora["titulo"]) + "\n" + str(mejora["detalle"])
        boton.custom_minimum_size = Vector2(440, 64)
        boton.add_theme_font_size_override("font_size", 18)
        boton.pressed.connect(_aplicar_mejora.bind(mejora["id"]))
        caja_mejoras.add_child(boton)
    panel_mejoras.visible = true
    get_tree().paused = true   # el juego se congela mientras elegís


func _aplicar_mejora(id: String):
    match id:
        "danio":
            danio += 3.0
        "cadencia":
            cadencia *= 0.85
        "orbe":
            orbes_por_disparo += 1
        "perforar":
            perforaciones += 1
        "velocidad":
            jugador.velocidad *= 1.12
        "iman":
            jugador.iman_radio += 45.0
        "vida":
            jugador.vida_max += 25.0
            jugador.vida = min(jugador.vida_max, jugador.vida + 25.0)
        "regen":
            jugador.regeneracion += 1.0
    panel_mejoras.visible = false
    get_tree().paused = false
    _chequear_nivel()   # por si juntaste XP para más de un nivel


# =============== FIN DE PARTIDA ===============

func _fin_del_juego():
    terminado = true
    var minutos := int(tiempo_partida / 60.0)
    var segundos := int(tiempo_partida) % 60
    etiqueta_final.text = "Sobreviviste %d:%02d\nNivel %d — %d criaturas eliminadas" % [minutos, segundos, nivel, eliminados]
    panel_final.visible = true
    get_tree().paused = true


func _reiniciar():
    get_tree().paused = false
    get_tree().reload_current_scene()


# =============== INTERFAZ ===============

func _actualizar_interfaz():
    barra_vida.size.x = 216.0 * clamp(jugador.vida / jugador.vida_max, 0.0, 1.0)
    barra_xp.size.x = 1236.0 * clamp(float(xp) / float(xp_necesaria), 0.0, 1.0)
    var minutos := int(tiempo_partida / 60.0)
    var segundos := int(tiempo_partida) % 60
    etiqueta_tiempo.text = "%d:%02d" % [minutos, segundos]
    etiqueta_nivel.text = "Nivel %d" % nivel
    etiqueta_eliminados.text = "Criaturas: %d" % eliminados


func _crear_interfaz():
    hud = CanvasLayer.new()
    hud.process_mode = Node.PROCESS_MODE_ALWAYS   # la interfaz funciona aun en pausa
    add_child(hud)

    # Viñeta oscura en los bordes (ambiente nocturno)
    var degradado := Gradient.new()
    degradado.colors = PackedColorArray([Color(0, 0, 0, 0), Color(0, 0, 0.03, 0.55)])
    var textura := GradientTexture2D.new()
    textura.gradient = degradado
    textura.fill = GradientTexture2D.FILL_RADIAL
    textura.fill_from = Vector2(0.5, 0.5)
    textura.fill_to = Vector2(0.5, 0.0)
    var vineta := TextureRect.new()
    vineta.texture = textura
    vineta.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    vineta.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hud.add_child(vineta)

    # Barra de vida (arriba a la izquierda)
    var fondo_vida := ColorRect.new()
    fondo_vida.position = Vector2(20, 20)
    fondo_vida.size = Vector2(220, 16)
    fondo_vida.color = Color(0, 0, 0, 0.6)
    fondo_vida.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hud.add_child(fondo_vida)
    barra_vida = ColorRect.new()
    barra_vida.position = Vector2(22, 22)
    barra_vida.size = Vector2(216, 12)
    barra_vida.color = Color(0.9, 0.75, 0.25)
    barra_vida.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hud.add_child(barra_vida)

    etiqueta_nivel = _crear_etiqueta(Vector2(20, 42), 18)
    etiqueta_eliminados = _crear_etiqueta(Vector2(20, 66), 18)

    # Reloj de partida (arriba al centro)
    etiqueta_tiempo = _crear_etiqueta(Vector2(0, 14), 26)
    etiqueta_tiempo.size = Vector2(1280, 32)
    etiqueta_tiempo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

    # Barra de experiencia (abajo, todo el ancho)
    var fondo_xp := ColorRect.new()
    fondo_xp.position = Vector2(20, 694)
    fondo_xp.size = Vector2(1240, 10)
    fondo_xp.color = Color(0, 0, 0, 0.6)
    fondo_xp.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hud.add_child(fondo_xp)
    barra_xp = ColorRect.new()
    barra_xp.position = Vector2(22, 696)
    barra_xp.size = Vector2(0, 6)
    barra_xp.color = Color(0.3, 0.95, 0.9)
    barra_xp.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hud.add_child(barra_xp)

    # Panel de mejoras (aparece al subir de nivel)
    panel_mejoras = CenterContainer.new()
    panel_mejoras.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    panel_mejoras.visible = false
    hud.add_child(panel_mejoras)
    var marco := PanelContainer.new()
    panel_mejoras.add_child(marco)
    caja_mejoras = VBoxContainer.new()
    caja_mejoras.add_theme_constant_override("separation", 12)
    marco.add_child(caja_mejoras)
    var titulo := Label.new()
    titulo.text = "¡SUBISTE DE NIVEL! Elegí una mejora:"
    titulo.add_theme_font_size_override("font_size", 22)
    titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    caja_mejoras.add_child(titulo)

    # Panel de fin de partida
    panel_final = CenterContainer.new()
    panel_final.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    panel_final.visible = false
    hud.add_child(panel_final)
    var marco_final := PanelContainer.new()
    panel_final.add_child(marco_final)
    var caja_final := VBoxContainer.new()
    caja_final.add_theme_constant_override("separation", 16)
    marco_final.add_child(caja_final)
    var titulo_final := Label.new()
    titulo_final.text = "EL MAR TE RECLAMÓ"
    titulo_final.add_theme_font_size_override("font_size", 34)
    titulo_final.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    caja_final.add_child(titulo_final)
    etiqueta_final = Label.new()
    etiqueta_final.add_theme_font_size_override("font_size", 20)
    etiqueta_final.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    caja_final.add_child(etiqueta_final)
    var boton_reintentar := Button.new()
    boton_reintentar.text = "Reintentar"
    boton_reintentar.custom_minimum_size = Vector2(300, 56)
    boton_reintentar.add_theme_font_size_override("font_size", 20)
    boton_reintentar.pressed.connect(_reiniciar)
    caja_final.add_child(boton_reintentar)


func _crear_etiqueta(pos: Vector2, tamanio: int) -> Label:
    var etiqueta := Label.new()
    etiqueta.position = pos
    etiqueta.add_theme_font_size_override("font_size", tamanio)
    hud.add_child(etiqueta)
    return etiqueta


# =============== LIMPIEZA Y FONDO ===============

func _limpiar_listas():
    enemigos = enemigos.filter(func(e): return is_instance_valid(e))
    gemas = gemas.filter(func(g): return is_instance_valid(g))
    orbes = orbes.filter(func(o): return is_instance_valid(o))


func _draw():
    # Olitas de fondo para que se note el movimiento sobre el mar
    if jugador == null:
        return
    var color_ola := Color(0.10, 0.16, 0.24)
    var paso := 150.0
    var centro := jugador.position
    var inicio_x := floorf((centro.x - 800.0) / paso) * paso
    var inicio_y := floorf((centro.y - 500.0) / paso) * paso
    var y := inicio_y
    while y < centro.y + 500.0:
        var x := inicio_x
        while x < centro.x + 800.0:
            var vaiven := sin(tiempo_partida * 1.5 + x * 0.01 + y * 0.013) * 4.0
            draw_arc(Vector2(x, y + vaiven), 10.0, PI + 0.4, TAU - 0.4, 10, color_ola, 2.0)
            x += paso
        y += paso
