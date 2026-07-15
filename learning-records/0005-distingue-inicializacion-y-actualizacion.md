# Distingue inicialización y actualización por frame

El estudiante explicó que `_ready()` inicializa el nodo una sola vez y que `_process(delta)` hace avanzar la partida durante cada frame. También distingue `delta` como tiempo entre frames y su producto con la velocidad como desplazamiento.

**Evidence:** corrigió con sus propias palabras la idea imprecisa de que `_ready()` «carga la partida» y la reformuló como inicialización del nodo.

**Implications:** ya puede estudiar cómo una variable conserva estado entre llamadas sucesivas a `_process(delta)`.
