import Plotly from "plotly.js-dist-min";

function createTrace(params) {
  const xSeries = typeof params.x == "string" ? JSON.parse(params.x) : params.x;

  const trace = {
    histfunc: params.histfunc | "count",
    x: xSeries,
    type: "histogram",
    name: params.name | "",
    xbins: {
      size:
        (Math.max(...xSeries) + 1 - Math.min(...xSeries)) /
        (Math.max(...xSeries) + 1),
    },
  };

  return trace;
}

function plotChart(elem, dataset) {
  const data = [createTrace(dataset)];
  Plotly.newPlot(elem, data);
}

export default histogram = {
  dataset() {
    return JSON.parse(this.el.dataset.trace);
  },

  mounted() {
    plotChart(this.el, this.dataset());

    this.handleEvent(`update-${this.el.id}`, ({ trace }) => {
      plotChart(this.el, trace);
    });
  },
};
