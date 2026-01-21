// @ts-nocheck
const Runtime = {};

Runtime.setup_canvas_size = ({ canvas, webgl }) => {
  const observer = new ResizeObserver((entries) => {
    for (const entry of entries) {
      canvas.width = entry.contentRect.width;
      canvas.height = entry.contentRect.height;
      // TODO redraw
      webgl.viewport(0, 0, canvas.width, canvas.height);
    }
  });
  observer.observe(canvas);
};

Runtime.await_animation_frame = () => {
  return new Promise((resolve) => {
    requestAnimationFrame(resolve);
  });
};

Runtime.get_canvas_size = (canvas) => {
  return { 0: canvas.width, 1: canvas.height };
};

window.Runtime = Runtime;
