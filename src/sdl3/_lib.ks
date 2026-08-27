module:

const Int = Int32;

const InitFlags = @opaque_type "SDL_InitFlags";

const Init = (flags :: InitFlags) -> Bool => (
    @native "#include <SDL3/SDL.h>";
    @native "#include <SDL3/SDL_main.h>";
    @native "SDL_Init(\(flags))"
);

const Quit = () => (
    @native "SDL_Quit()";
);

const Window = @opaque_type "SDL_Window*";
const Renderer = @opaque_type "SDL_Renderer*";

const WindowFlags = @opaque_type "SDL_WindowFlags";

const CreateWindowAndRenderer = (
    title :: String,
    width :: Int,
    height :: Int,
    window_flags :: WindowFlags,
) -> Result.t[type { Window, Renderer }, type ()] => (
    let mut window = @native "NULL";
    let mut renderer = @native "NULL";
    let success :: Bool = @native ''
        SDL_CreateWindowAndRenderer(
            String_to_C_String(\(title)),
            \(width),
            \(height),
            \(window_flags),
            \(&mut window),
            \(&mut renderer)
        )
    '';
    if not success then (
        :Error ()
    ) else (
        :Ok { window, renderer }
    )
);

const Event = @opaque_type "SDL_Event";
const PollEvent = () -> Option.t[Event] => (
    let event = @native "(SDL_Event){}";
    if @native "SDL_PollEvent(\(&event))" then (
        :Some event
    ) else (
        :None
    )
);
