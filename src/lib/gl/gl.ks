module:

include "./types.ks";
include "./constants.ks";

const Context = newtype (
    .webgl :: web.WebGLRenderingContext,
);

impl Context as module = (
    module:
    
    const init = (webgl :: web.WebGLRenderingContext) -> Context => (
        .webgl
    );
    
    const clear = (self :: Context, bits :: GLbitfield) -> () => (
        (@native "({ctx,bits})=>ctx.clear(bits)")(
            .ctx = self.webgl,
            .bits,
        )
    );
    
    const clear_color = (
        self :: Context,
        r :: GLclampf,
        g :: GLclampf,
        b :: GLclampf,
        a :: GLclampf,
    ) -> () => (
        (@native "({ctx,r,g,b,a})=>ctx.clearColor(r,g,b,a)")(
            .ctx = self.webgl,
            .r,
            .g,
            .b,
            .a,
        )
    )
);
