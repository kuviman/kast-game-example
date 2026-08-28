const SDL = import "./sdl3/_lib.ks";
const ugli = import "./ugli.ks";
const gl = import "./gl/_lib.ks";

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
        ugli.Program.@"use"(program);
        gl.draw_arrays(gl.TRIANGLES, 0, 3);
        SDL.GL_SwapWindow(window);
    # @native "SDL_RenderPresent(\(renderer))";
    );
    log("Quitting");
    SDL.Quit();
);

main();
