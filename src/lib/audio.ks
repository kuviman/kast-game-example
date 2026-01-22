module:

const ContextT = @opaque_type;

const Context = @context ContextT;

const init = () -> ContextT => (
    (@native "Runtime.audio.init")()
);

const load = (path) -> AudioBuffer => (
    let ctx = (@current Context);
    (@native "Runtime.audio.load")(.ctx, .path)
);

const play = (buffer :: AudioBuffer) -> () => (
    let ctx = (@current Context);
    (@native "Runtime.audio.play")(.ctx, .buffer)
);

const AudioBuffer = @opaque_type;
