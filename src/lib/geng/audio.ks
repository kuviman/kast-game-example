const asset = import "./asset.ks";
const SDL = import "../sdl3/_lib.ks";

module:

const ContextT = newtype {
    .mixer :: SDL.MIX.Mixer,
};

const Context = @context ContextT;

const init = () -> ContextT => (
    SDL.MIX.Init();
    let mixer = SDL.MIX.CreateMixerDevice(
        @native "SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK",
        @native "NULL",
    );
    { .mixer }
);

const PlayOptions = newtype {
    .@"loop" :: Bool,
    .gain :: Float32,
};

impl PlayOptions as module = (
    module:

    const default = () -> PlayOptions => {
        .@"loop" = false,
        .gain = 1,
    };
);

const play_with = (buffer :: Buffer, options :: PlayOptions) -> () => (
    let ctx = (@current Context);
    let track = SDL.MIX.CreateTrack(ctx.mixer);
    SDL.MIX.SetTrackAudio(track, buffer.audio);
    SDL.MIX.SetTrackGain(track, options.gain);
    SDL.MIX.SetTrackLoops(track, if options.@"loop" then (-1) else 0);
    SDL.MIX.PlayTrack(track, @native "0");
);

const play = (buffer :: Buffer) => (
    play_with(buffer, PlayOptions.default())
);

const set_master_volume = (volume :: Float32) -> () => (
    let ctx = (@current Context);
    SDL.MIX.SetMixerGain(ctx.mixer, volume);
);

const Buffer = newtype {
    .audio :: SDL.MIX.Audio,
};

const load = (path) -> Buffer => (
    let ctx = (@current Context);
    let audio = SDL.MIX.LoadAudio(ctx.mixer, path, true);
    { .audio }
);

impl Buffer as asset.Load = {
    .load,
    .default_ext = :Some "wav",
};
