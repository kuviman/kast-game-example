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

Runtime.input = {};
{
  const pressed_keys = {};
  const pressed_mouse_buttons = {};

  const pointers = {};

  function canvas_pos(canvas, event) {
    const rect = canvas.getBoundingClientRect();
    const scale_x = canvas.width / rect.width;
    const scale_y = canvas.height / rect.height;
    return {
      0: (event.clientX - rect.left) * scale_x,
      1: canvas.height - (event.clientY - rect.top) * scale_y - 1,
    };
  }

  Runtime.input.init = async ({ canvas, mouse_press, pointer_press }) => {
    window.addEventListener("keydown", (e) => {
      pressed_keys[e.code] = true;
    });
    window.addEventListener("keyup", (e) => {
      pressed_keys[e.code] = false;
    });
    window.addEventListener("mousedown", (e) => {
      mouse_press(e);
      pressed_mouse_buttons[e.button] = true;
    });
    window.addEventListener("mouseup", (e) => {
      pressed_mouse_buttons[e.button] = false;
    });
    canvas.addEventListener("pointerdown", (e) => {
      pointers[e.pointerId] = {
        down: true,
      };
      const pos = canvas_pos(canvas, e);
      pointer_press({ 0: e, 1: pos });
    });
    canvas.addEventListener("pointerup", (e) => {
      pointers[e.pointerId] = {
        down: false,
      };
    });
    canvas.addEventListener("pointercancel", (e) => {
      delete pointers[e.pointerId];
    });
  };

  Runtime.input.is_key_pressed = (key) => {
    const key_name = key.tag.description;
    return pressed_keys[key_name] === true;
  };

  Runtime.input.is_mouse_button_pressed = (button) => {
    return pressed_mouse_buttons[button] === true;
  };

  Runtime.input.is_any_pointer_pressed = () => {
    for (const pointer of Object.values(pointers)) {
      if (pointer.down) {
        return true;
      }
    }
    return false;
  };
}

Runtime.fetch_string = async (path) => {
  const response = await fetch(path);
  if (response.status == 200) {
    return await response.text();
  } else {
    throw new Error(response.statusText);
  }
};

Runtime.audio = {
  init: async () => {
    const audio = new AudioContext();
    const master = audio.createGain();
    master.gain.value = 0.1; // TODO
    master.connect(audio.destination);
    return { audio, master };
  },
  load: async ({ ctx, path }) => {
    const response = await fetch(path);
    if (response.status != 200) {
      throw new Error(response.statusText);
    }
    return await ctx.audio.decodeAudioData(await response.arrayBuffer());
  },
  play: async ({ ctx, buffer, options }) => {
    const audio = ctx.audio;
    const source = audio.createBufferSource();
    const gain = audio.createGain();
    gain.gain.value = options.gain;
    source.buffer = buffer;
    source.loop = options.loop;
    source.connect(gain).connect(ctx.master);
    source.start();
  },
};

Runtime.is_fullscreen = async () => {
  console.log(document.fullscreenElement);
  return document.fullscreenElement !== null;
};

Runtime.set_fullscreen = async ({ canvas, full }) => {
  console.log("full=", full);
  if (full) {
    await canvas.requestFullscreen({ navigationUI: "hide" });
  } else {
    await document.exitFullscreen();
  }
};

window.Runtime = Runtime;
