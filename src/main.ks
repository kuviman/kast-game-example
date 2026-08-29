const SDL = import "./sdl3/_lib.ks";
const ugli = import "./ugli.ks";
const gl = import "./gl/_lib.ks";

use (import "./la.ks").*;
use (import "./camera.ks").*;

const SDL_error = (msg :: String) -> Never => (
    panic(msg + ": " + (@native "String_from_C_String(SDL_GetError())"))
);

const log = print;

const main = () => (
    SDL.Init(@native "SDL_INIT_VIDEO");
    let window = match SDL.CreateWindow(
        "Kast Game Example",
        640,
        480,
        @native "SDL_WINDOW_RESIZABLE | SDL_WINDOW_OPENGL",
    ) with (
        | :Ok result => result
        | :Error () => (
            SDL_error("Failed to create window") |> from_never
        )
    );
    let gl_context = SDL.GL_CreateContext(window);
    SDL.GL_MakeCurrent(window, gl_context);
    SDL.GL_SetSwapInterval(1);

    ugli.init();
    let vertex_shader = ugli.compile_shader(
        gl.VERTEX_SHADER,
        std.fs.read_file("target/assets/shaders/quad/vertex.glsl"),
    );
    let fragment_shader = ugli.compile_shader(
        gl.FRAGMENT_SHADER,
        std.fs.read_file("target/assets/shaders/quad/fragment.glsl"),
    );
    let program = ugli.Program.init(vertex_shader, fragment_shader);

    let mut camera :: Camera = {
        .pos = { 0, 0 },
        .fov = 10,
    };
    let mut pos :: Vec2 = { 0, 0 };
    let mut half_size :: Vec2 = { 1, 1 };

    let mut keep_running = true;
    while keep_running do (
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

        program |> ugli.Program.@"use";
        let mut draw_state = ugli.DrawState.init();
        let draw_state = &mut draw_state;
        program |> ugli.set_uniform("u_pos", pos, draw_state);
        program |> ugli.set_uniform("u_half_size", half_size, draw_state);
        program
            |> ugli.set_uniform(
                "u_view_matrix",
                (@current CameraCtx).view_matrix,
                draw_state
            );
        program
            |> ugli.set_uniform(
                "u_projection_matrix",
                (@current CameraCtx).projection_matrix,
                draw_state
            );
        # program |> ugli.set_uniform("u_texture", texture, draw_state);
        # program |> ugli.set_vertex_data_source(ctx.quad.buffer);
        gl.draw_arrays(gl.TRIANGLE_FAN, 0, 3);

        SDL.GL_SwapWindow(window);
    # @native "SDL_RenderPresent(\(renderer))";
    );
    log("Quitting");
    SDL.Quit();
);

main();
