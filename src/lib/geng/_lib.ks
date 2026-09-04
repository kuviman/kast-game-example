use (import "../common.ks").*;
use (import "../la.ks").*;
const gl = import "../gl/_lib.ks";
const ugli = import "../ugli/_lib.ks";
const SDL = import "../sdl3/_lib.ks";

module:

const geng = @current_scope;

const asset = import "./asset.ks";
const audio = import "./audio.ks";
const input = (include "./input.ks");

use (import "./camera.ks").*;

const Vertex = newtype {
    .a_pos :: Vec2,
    .a_uv :: Vec2,
};

include_ast ugli.Vertex_derive(Vertex);

const ContextT = newtype {
    .window :: SDL.Window,
    .gl_context :: SDL.GL.Context,
    .quad :: {
        .program :: ugli.Program,
        .buffer :: ugli.VertexBuffer.t[Vertex],
    },
};
const Context = @context ContextT;

const log = print;

const init = () -> { .geng :: ContextT, .gl :: gl.ContextT } => (
    log("Initializing");
    SDL.Init(@native "SDL_INIT_VIDEO");
    let window = SDL.CreateWindow(
        "Kast Game Example",
        640,
        480,
        @native "SDL_WINDOW_RESIZABLE | SDL_WINDOW_OPENGL",
    );
    log("Created window");

    let gl_context = SDL.GL.CreateContext(window);
    SDL.GL.MakeCurrent(window, gl_context);
    SDL.GL.SetSwapInterval(1);
    log("Created GL context");

    ugli.init();
    log("Initialized ugli");

    let quad = {
        .program = load_shader("assets/shaders/quad"),
        .buffer = (
            let mut data :: ArrayList.t[Vertex] = ArrayList.new();
            ArrayList.push_back(
                &mut data,
                {
                    .a_pos = { -1, -1 },
                    .a_uv = { 0, 0 },
                },
            );
            ArrayList.push_back(
                &mut data,
                {
                    .a_pos = { +1, -1 },
                    .a_uv = { 1, 0 },
                },
            );
            ArrayList.push_back(
                &mut data,
                {
                    .a_pos = { +1, +1 },
                    .a_uv = { 1, 1 },
                },
            );
            ArrayList.push_back(
                &mut data,
                {
                    .a_pos = { -1, +1 },
                    .a_uv = { 0, 1 },
                },
            );
            ugli.VertexBuffer.init(&data)
        ),
    };
    let mut geng = {
        .window,
        .gl_context,
        .quad,
    };
    {
        .geng,
        .gl = (),
    }
);

const draw_quad = (
    .pos :: Vec2,
    .half_size :: Vec2,
    .texture :: ugli.Texture,
) => (
    let ctx = (@current Context);
    let camera = (@current CameraCtx);
    let program = ctx.quad.program;
    program |> ugli.Program.@"use";
    
    let mut draw_state = ugli.DrawState.init();
    let draw_state = &mut draw_state;
    
    program |> ugli.set_uniform("u_pos", pos, draw_state);
    program |> ugli.set_uniform("u_half_size", half_size, draw_state);
    program |> ugli.set_uniform("u_view_matrix", camera.view_matrix, draw_state);
    program |> ugli.set_uniform("u_projection_matrix", camera.projection_matrix, draw_state);
    program |> ugli.set_uniform("u_texture", texture, draw_state);
    program |> ugli.set_vertex_data_source(ctx.quad.buffer);
    gl.draw_arrays(gl.TRIANGLE_FAN, 0, 4);
);

const load_texture = (path :: String, filter :: ugli.Filter) -> ugli.Texture => (
    ugli.Texture.load(path, filter)
);

const load_shader = (path :: String) -> ugli.Program => (
    ugli.Program.init(
        .vertex_glsl = fetch_string(path + "/vertex.glsl"),
        .fragment_glsl = fetch_string(path + "/fragment.glsl"),
    )
);

const is_fullscreen = () -> Bool => (
    let ctx = @current Context;
    @native "(SDL_GetWindowFlags(\(ctx.window)) & SDL_WINDOW_FULLSCREEN) != 0"
);

const set_fullscreen = (full :: Bool) -> () => (
    let ctx = (@current Context);
    SDL.SetWindowFullscreen(ctx.window, full);
);

const toggle_fullscreen = () => (
    set_fullscreen(not is_fullscreen());
);

const get_window_size = () -> Vec2 => (
    let ctx = @current Context;
    let { width, height } = SDL.GetWindowSize(ctx.window);
    { Int32_to_Float32(width), Int32_to_Float32(height) }
);

const time_since_start = () -> Float32 => (
    let ticks = SDL.GetTicks();
    UInt64_to_Float32(ticks) / 1000
);

const await_next_frame = () => (
    let ctx = @current Context;
    SDL.GL.SwapWindow(ctx.window);
);
