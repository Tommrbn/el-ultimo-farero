document.querySelectorAll("[data-game-loop]").forEach((lab) => {
  const start = lab.querySelector("[data-start]");
  const next = lab.querySelector("[data-next]");
  const reset = lab.querySelector("[data-reset]");
  const readyCount = lab.querySelector("[data-ready-count]");
  const frameCount = lab.querySelector("[data-frame-count]");
  const elapsed = lab.querySelector("[data-elapsed]");
  const log = lab.querySelector("[data-log]");
  let frames = 0;
  let time = 0;

  function addEvent(text, className) {
    const line = document.createElement("p");
    line.textContent = text;
    line.className = className;
    log.appendChild(line);
    log.scrollTop = log.scrollHeight;
  }

  start.addEventListener("click", () => {
    readyCount.textContent = "1";
    start.disabled = true;
    next.disabled = false;
    addEvent("_ready() → configura teclas, crea jugador e interfaz", "ready-event");
  });

  next.addEventListener("click", () => {
    frames += 1;
    time += 0.016;
    frameCount.textContent = String(frames);
    elapsed.textContent = `${time.toFixed(3)} s`;
    addEvent(`_process(0.016) → frame ${frames}`, "frame-event");
  });

  reset.addEventListener("click", () => {
    frames = 0;
    time = 0;
    readyCount.textContent = "0";
    frameCount.textContent = "0";
    elapsed.textContent = "0.000 s";
    log.textContent = "Esperando que arranque la escena…";
    start.disabled = false;
    next.disabled = true;
  });
});
