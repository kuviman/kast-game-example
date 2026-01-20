include "lib/_lib.ks";

let document = web.document();
let canvas :: web.HtmlCanvasElement = document
    |> web.HtmlDocumentElement.get_element_by_id("canvas")
    |> js.unsafe_cast;

let ctx :: gl.Context = canvas
    |> web.HtmlCanvasElement.get_context("webgl")
    |> js.unsafe_cast
    |> gl.Context.init;

ctx |> gl.Context.clear_color(0.8, 0.8, 1.0, 1.0);
ctx |> gl.Context.clear(gl.COLOR_BUFFER_BIT);

print("Hello, world2");
