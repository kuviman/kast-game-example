const fetch_string = (path :: String) -> String => (
    (@native "Runtime.fetch_string")(path)
);

const time = (
    module:
    
    const now = () -> Float64 => (
        (@native "performance.now()") / 1000
    );
);

const load_image = (url :: String) -> web.HtmlImageElement => (
    (@native "Runtime.load_image")(url)
);

const await_animation_frame = () -> () => (
    (@native "Runtime.await_animation_frame")()
);

const abs = (x :: Float32) -> Float32 => (
    if x < 0 then (
        -x
    ) else (
        x
    )
);
