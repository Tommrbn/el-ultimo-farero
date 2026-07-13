function normalize(value) {
  return value
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, " ")
    .trim();
}

document.querySelectorAll("[data-retrieval]").forEach((exercise) => {
  const input = exercise.querySelector("input");
  const button = exercise.querySelector("button");
  const feedback = exercise.querySelector(".feedback");
  const accepted = exercise.dataset.answer.split("|").map(normalize);

  function check() {
    const response = normalize(input.value);
    const correct = accepted.some((answer) => response.includes(answer));
    feedback.textContent = correct
      ? "Correcto. Recuperaste la relación sin verla."
      : exercise.dataset.hint;
    feedback.className = `feedback ${correct ? "good" : "try"}`;
  }

  button.addEventListener("click", check);
  input.addEventListener("keydown", (event) => {
    if (event.key === "Enter") check();
  });
});
