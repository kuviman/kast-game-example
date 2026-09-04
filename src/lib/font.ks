use (import "./common.ks").*;
use (import "./la.ks").*;
const gl = import "./gl/_lib.ks";
const ugli = import "./ugli/_lib.ks";
const geng = import "./geng/_lib.ks";
use std.collections.OrdMap;

module:

const Font = newtype {  };

impl Font as module = (
    module:

    const load = (path :: String) -> Font => (
        {  }
    );

    const measure = (font :: &Font, text :: String) -> Float32 => (
        0.0
    );

    const draw = (
        font :: &Font,
        text :: String,
        .pos :: Vec2,
        .size :: Float32,
        .color :: Vec4,
        .align :: Float32,
    ) => ();
);
