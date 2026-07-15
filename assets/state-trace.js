document.querySelectorAll("[data-state-trace]").forEach((lab) => {
  const timeOutput = lab.querySelector("[data-time]");
  const frameOutput = lab.querySelector("[data-frame]");
  const clockOutput = lab.querySelector("[data-clock]");
  const log = lab.querySelector("[data-log]");
  const reset = lab.querySelector("[data-reset]");
  let time = 0;
  let frame = 0;

  function renderClock() {
    const total = Math.floor(time);
    const minutes = Math.floor(total / 60);
    const seconds = String(total % 60).padStart(2, "0");
    clockOutput.textContent = `${minutes}:${seconds}`;
  }

  lab.querySelectorAll("[data-step]").forEach((button) => {
    button.addEventListener("click", () => {
      const delta = Number(button.dataset.step);
      const previous = time;
      time += delta;
      frame += 1;
      timeOutput.textContent = time.toFixed(3);
      frameOutput.textContent = String(frame);
      renderClock();

      const line = document.createElement("p");
      line.className = "frame-event";
      line.textContent = `frame ${frame}: ${previous.toFixed(3)} + ${delta.toFixed(3)} = ${time.toFixed(3)}`;
      log.appendChild(line);
      log.scrollTop = log.scrollHeight;
    });
  });

  reset.addEventListener("click", () => {
    time = 0;
    frame = 0;
    timeOutput.textContent = "0.000";
    frameOutput.textContent = "0";
    clockOutput.textContent = "0:00";
    log.textContent = "tiempo_partida comienza en 0.0";
  });
});
