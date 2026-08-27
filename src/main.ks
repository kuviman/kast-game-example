const SDL = import "./sdl3/_lib.ks";

const SDL_error = (msg :: String) -> Never => (
    panic(msg + (@native "String_from_C_String(SDL_GetError())"))
);

const log = print;

const main = () => (
    log("Initializing");
    if not SDL.Init(@native "SDL_INIT_VIDEO") then (
        SDL_error("SDL.Init failed");
    );
    log("Creating window and renderer");
    let { window, renderer } = match SDL.CreateWindowAndRenderer(
        "Kast Game Example",
        640,
        480,
        @native "SDL_WINDOW_RESIZABLE",
    ) with (
        | :Ok result => result
        | :Error () => (
            SDL_error("Failed to create window and renderer") |> from_never
        )
    );
    @native "SDL_SetRenderLogicalPresentation(\(renderer), 640, 480, SDL_LOGICAL_PRESENTATION_LETTERBOX)";
    let mut keep_running = true;
    while keep_running do (
        while SDL.PollEvent() is :Some event do (
            if @native "\(event).type == SDL_EVENT_QUIT" then (
                keep_running = false;
            );
        );
        @native "SDL_SetRenderDrawColor(\(renderer), 0xaa, 0xaa, 0xff, 0x00)";
        @native "SDL_RenderClear(\(renderer))";
        @native "SDL_RenderPresent(\(renderer))";
    );
    log("Quitting");
    SDL.Quit();
);

main();
