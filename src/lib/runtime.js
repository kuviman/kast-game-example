// @ts-nocheck
const Runtime = {};

Runtime.observe_canvas_size = ({ canvas, webgl, handler }) => {
  const observer = new ResizeObserver((entries) => {
    for (const entry of entries) {
      canvas.width = entry.contentRect.width;
      canvas.height = entry.contentRect.height;
      // TODO redraw
      webgl.viewport(0, 0, canvas.width, canvas.height);
      handler({ width: canvas.width, height: canvas.height });
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

Runtime.load_image = (url) => {
  return new Promise((resolve, reject) => {
    const image = new Image();
    image.src = url;
    image.onload = () => resolve(image);
    image.onerror = reject;
  });
};

const pressed_keys = {};
window.addEventListener("keydown", (e) => {
  pressed_keys[e.code] = true;
});
window.addEventListener("keyup", (e) => {
  pressed_keys[e.code] = false;
});

Runtime.is_key_pressed = (key) => {
  const key_name = key.tag.description;
  const pressed = pressed_keys[key_name] === true;
  return pressed;
};

Runtime.fetch_string = async (path) => {
  const response = await fetch(path);
  if (response.status == 200) {
    return await response.text();
  } else {
    throw new Error(response.statusText);
  }
};

window.Runtime = Runtime;
