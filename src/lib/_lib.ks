include "./la.ks";
const js = include "./js.ks";
const web = include "./web.ks";
const gl = include "./gl/gl.ks";
const ugli = include "./ugli.ks";
const obj = include "./obj.ks";

include "./common.ks";

const geng = include "./geng.ks";
const input = include "./input.ks";
const audio = include "./audio.ks";
const font = include "./font.ks";

@native (
    "(()=>{"
    + std.fs.read_file(
        std.path.dirname(__FILE__) + "/runtime.js"
    )
    + "})()"
);
