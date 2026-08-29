module:

const Int = Int32;

const GetError = () -> String => (
    @native "String_from_C_String(SDL_GetError())"
);

const throw_error = (fn_name :: String) => (
    panic(fn_name + " failed: " + GetError());
);

const InitFlags = @opaque_type "SDL_InitFlags";

const Init = (flags :: InitFlags) => (
    @native "#include <SDL3/SDL.h>";
    @native "#include <SDL3/SDL_main.h>";
    if @native "!SDL_Init(\(flags))" then (
        throw_error("SDL_Init");
    );
);

const Quit = () => (
    @native "SDL_Quit()";
);

const Window = @opaque_type "SDL_Window*";

const WindowFlags = @opaque_type "SDL_WindowFlags";

const CreateWindow = (
    title :: String,
    width :: Int,
    height :: Int,
    window_flags :: WindowFlags,
) -> Result.t[Window, type ()] => (
    let window = @native ''
        SDL_CreateWindow(
            String_to_C_String(\(
                title
            )),
            \(width),
            \(height),
            \(window_flags)
        )
    '';
    if @native "\(window) == NULL" then (
        :Error ()
    ) else (
        :Ok window
    )
);

const GL_Context = @opaque_type "SDL_GLContext";

const GL_CreateContext = (window :: Window) -> GL_Context => (
    let ctx = @native "SDL_GL_CreateContext(\(window))";
    if @native "\(ctx) == NULL" then (
        throw_error("GL_CreateContext");
    );
    ctx
);

const GL_MakeCurrent = (window :: Window, gl :: GL_Context) => (
    if @native "!SDL_GL_MakeCurrent(\(window), \(gl))" then (
        throw_error("SDL_GL_MakeCurrent");
    );
);

const GL_SetSwapInterval = (interval :: Int) => (
    if @native "!SDL_GL_SetSwapInterval(\(interval))" then (
        throw_error("SDL_GL_SetSwapInterval");
    );
);

const GL_SwapWindow = (window :: Window) => (
    if @native "!SDL_GL_SwapWindow(\(window))" then (
        throw_error("SDL_GL_SwapWindow");
    );
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

const GetWindowSize = (window :: Window) -> { Int32, Int32 } => (
    let mut width = 0;
    let mut height = 0;
    if @native "!SDL_GetWindowSize(\(window), \(&mut width), \(&mut height))" then (
        throw_error("SDL_GetWindowSize");
    );
    { width, height }
);

const Surface = @opaque_type "SDL_Surface*";

const PixelFormat = @opaque_type "SDL_PixelFormat";

const ConvertSurface = (surface :: Surface, format :: PixelFormat) -> Surface => (
    let result = @native "SDL_ConvertSurface(\(surface), \(format))";
    if @native "\(result) == NULL" then (
        throw_error("SDL_ConvertSurface");
    );
    result
);

const DestroySurface = (surface :: Surface) => (
    @native "SDL_DestroySurface(\(surface))";
);

const FlipMode = @opaque_type "SDL_FlipMode";

const FlipSurface = (surface :: Surface, mode :: FlipMode) => (
    if @native "!SDL_FlipSurface(\(surface), \(mode))" then (
        throw_error("SDL_FlipSurface");
    );
);

const IMG = (
    module:

    const Load = (path :: String) -> Surface => (
        @native "#include <SDL3_image/SDL_image.h>";
        let surface = @native "IMG_Load(String_to_C_String(\(path)))";
        if @native "\(surface) == NULL" then (
            throw_error("IMG_Load");
        );
        surface
    );
);
