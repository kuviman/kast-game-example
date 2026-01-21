include "./la.ks";
const js = include "./js.ks";
const web = include "./web.ks";
const gl = include "./gl/gl.ks";
const ugli = include "./ugli.ks";
const obj = include "./obj.ks";
const input = include "./input.ks";

include "./common.ks";

const geng = include "./geng.ks";

@native (
    "(()=>{"
    + std.fs.read_file(
        std.path.dirname(__FILE__) + "/runtime.js"
    )
    + "})()"
);
