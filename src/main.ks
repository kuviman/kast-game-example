const SDL = import "./sdl3/_lib.ks";
const ugli = import "./ugli.ks";
const gl = import "./gl/_lib.ks";

use (import "./common.ks").*;
use (import "./la.ks").*;
use (import "./camera.ks").*;

const log = print;

const Vertex = newtype {
    .a_pos :: Vec2,
    .a_uv :: Vec2,
};

include_ast ugli.Vertex_derive(Vertex);

const App = newtype {
    .window :: SDL.Window,
    .gl_context :: SDL.GL.Context,
    .program :: ugli.Program,
    .textures :: {
        .unicorn :: ugli.Texture,
        .angry :: ugli.Texture,
    },
    .quad_buffer :: ugli.VertexBuffer.t[Vertex],
    .camera :: Camera,

    .ticks :: UInt64,
    .x :: Float32,
};

const AppCtx = @context type (&mut App);

const draw_quad = (
    pos :: Vec2,
    half_size :: Vec2,
    texture :: ugli.Texture,
) => (
    let app = @current AppCtx;
    let camera = @current CameraCtx;
    let program = app^.program;
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
    program |> ugli.set_vertex_data_source(app^.quad_buffer);
    gl.draw_arrays(gl.TRIANGLE_FAN, 0, 4);
);

@eval (
    impl App as SDL.App = {
        .init = () => (
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

            let program = ugli.Program.init(
                .vertex_glsl = std.fs.read_file("assets/shaders/quad/vertex.glsl"),
                .fragment_glsl = std.fs.read_file("assets/shaders/quad/fragment.glsl"),
            );
            log("Compiled shader program");

            let textures = {
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
                let findme = data;
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
                print(to_string(&data |> ArrayList.length));
                ugli.VertexBuffer.init(&data)
            );
            log("Vertex buffer created");

            let mut camera :: Camera = {
                .pos = { 0, 0 },
                .fov = 10,
            };
            {
                .window,
                .gl_context,
                .quad_buffer,
                .program,
                .textures,
                .camera,
                .ticks = SDL.GetTicks(),
                .x = 0,
            }
        ),
        .event = (self, event) => with_return (
            if @native "\(event)->type == SDL_EVENT_QUIT" then (
                return :Success;
            );
            :Continue
        ),
        .iterate = self => (
            with AppCtx = self;

            let new_ticks = SDL.GetTicks();
            let delta_time :: Float32 = @native "(float)\(new_ticks - self^.ticks) / 1000.0";
            self^.ticks = new_ticks;

            let { width, height } = SDL.GetWindowSize(self^.window);
            gl.viewport(0, 0, width, height);
            ugli.clear({ 0.8, 0.8, 1, 1 });

            with CameraCtx = CameraUniforms.init(
                self^.camera,
                .framebuffer_size = {
                    Int32_to_Float32(width),
                    Int32_to_Float32(height),
                },
            );

            @native "#include <math.h>";
            self^.x += delta_time;

            draw_quad({ @native "sin(\(self^.x))", 0 }, { 1, 1 }, self^.textures.unicorn);
            draw_quad({ 2, 2 }, { 1, 1 }, self^.textures.angry);

            SDL.GL.SwapWindow(self^.window);
            :Continue
        ),
        .quit = (...) => (
            log("Quitting");
            SDL.Quit();
        ),
    }
);

SDL.EnterAppMainCallbacks[App]();
