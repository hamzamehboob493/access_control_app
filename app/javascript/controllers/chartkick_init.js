// app/javascript/controllers/chartkick_init.js
import Chartkick from "chartkick";

Chartkick.use(window.Chart);

document.addEventListener("turbo:load", () => {
  if (window.Chartkick) {
    Chartkick.charts.forEach(chart => chart.redraw());
  }
});
