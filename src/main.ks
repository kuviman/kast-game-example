const SDL = import "./sdl3/_lib.ks";
const ugli = import "./ugli.ks";
const gl = import "./gl/_lib.ks";

use (import "./la.ks").*;
use (import "./camera.ks").*;

const log = print;

const Vertex = newtype {
    .a_pos :: Vec2,
    .a_uv :: Vec2,
};

include_ast ugli.Vertex_derive(Vertex);

const main = () => (
    @native "{KAST_GC_ENABLED = false;}";
    log("Initializing");
    SDL.Init(@native "SDL_INIT_VIDEO");
    let window = SDL.CreateWindow(
        "Kast Game Example",
        640,
        480,
        @native "SDL_WINDOW_RESIZABLE | SDL_WINDOW_OPENGL",
    );
    log("Created window");

    let gl_context = SDL.GL_CreateContext(window);
    SDL.GL_MakeCurrent(window, gl_context);
    SDL.GL_SetSwapInterval(1);
    log("Created GL context");

    ugli.init();
    log("Initialized ugli");

    let vertex_shader = ugli.compile_shader(
        gl.VERTEX_SHADER,
        std.fs.read_file("assets/shaders/quad/vertex.glsl"),
    );
    let fragment_shader = ugli.compile_shader(
        gl.FRAGMENT_SHADER,
        std.fs.read_file("assets/shaders/quad/fragment.glsl"),
    );
    let program = ugli.Program.init(vertex_shader, fragment_shader);
    log("Compiled shader program");

    const TT = newtype {
        .unicorn :: ugli.Texture,
        .angry :: ugli.Texture,
    };
    let textures :: TT = {
        .unicorn = ugli.Texture.load(
            "assets/textures/unicorn.png",
            :Nearest,
        ),
        .angry = ugli.Texture.load(
            "assets/textures/angry.png",
            :Nearest,
        ),
    };
    log("Loaded textures");

    let quad_buffer = (
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
    );
    log("Vertex buffer created");

    let draw_quad = (
        pos :: Vec2,
        half_size :: Vec2,
        texture :: ugli.Texture,
    ) => (
        let camera = @current CameraCtx;
        program |> ugli.Program.@"use";
        let mut draw_state = ugli.DrawState.init();
        let draw_state = &mut draw_state;
        program |> ugli.set_uniform("u_pos", pos, draw_state);
        program |> ugli.set_uniform("u_half_size", half_size, draw_state);
        program
            |> ugli.set_uniform(
                "u_view_matrix",
                camera.view_matrix,
                draw_state
            );
        program
            |> ugli.set_uniform(
                "u_projection_matrix",
                camera.projection_matrix,
                draw_state
            );
        program |> ugli.set_uniform("u_texture", texture, draw_state);
        program |> ugli.set_vertex_data_source(quad_buffer);
        gl.draw_arrays(gl.TRIANGLE_FAN, 0, 4);
    );

    let mut camera :: Camera = {
        .pos = { 0, 0 },
        .fov = 10,
    };

    log("Starting main loop");
    let mut keep_running = true;
    let mut ticks = SDL.GetTicks();
    let mut x :: Float32 = 0;
    while keep_running do (
        print("TICKS = " + to_string(ticks));
        let new_ticks = SDL.GetTicks();
        let delta_time :: Float32 = @native "(float)\(new_ticks - ticks) / 1000.0";
        ticks = new_ticks;

        while SDL.PollEvent() is :Some event do (
            if @native "\(event).type == SDL_EVENT_QUIT" then (
                keep_running = false;
            );
        );
        let { width, height } = SDL.GetWindowSize(window);
        gl.viewport(0, 0, width, height);
        ugli.clear({ 0.8, 0.8, 1, 1 });

        with CameraCtx = CameraUniforms.init(
            camera,
            .framebuffer_size = {
                Int32_to_Float32(width),
                Int32_to_Float32(height),
            },
        );

        @native "#include <math.h>";
        x += delta_time;

        draw_quad({ @native "sin(\(x))", 0 }, { 1, 1 }, textures.unicorn);
        draw_quad({ 2, 2 }, { 1, 1 }, textures.angry);

        SDL.GL_SwapWindow(window);
    );
    log("Quitting");
    SDL.Quit();
);

main();
