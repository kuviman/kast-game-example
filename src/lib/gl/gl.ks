module:

include "./types.ks";
include "./constants.ks";

const Context = @opaque_type;

impl Context as module = (
    module:
    
    const init = (webgl :: web.WebGLRenderingContext) -> Context => (
        webgl |> js.unsafe_cast
    );
    
    const clear = (ctx :: Context, bits :: GLbitfield) -> () => (
        (@native "({ctx,bits})=>ctx.clear(bits)")(
            .ctx,
            .bits,
        )
    );
    
    const clear_color = (
        ctx :: Context,
        r :: GLclampf,
        g :: GLclampf,
        b :: GLclampf,
        a :: GLclampf,
    ) -> () => (
        (@native "({ctx,r,g,b,a})=>ctx.clearColor(r,g,b,a)")(
            .ctx,
            .r,
            .g,
            .b,
            .a,
        )
    );
    
    const create_shader = (
        ctx :: Context,
        shader_type :: GLenum,
    ) -> Option.t[Shader] => (
        (@native "({ctx,t})=>ctx.createShader(t)")(
            .ctx,
            .t = shader_type,
        )
            |> js.check_null
    );
    
    const shader_source = (
        ctx :: Context,
        shader :: Shader,
        source :: String,
    ) -> () => (
        (@native "({ctx,shader,source})=>ctx.shaderSource(shader,source)")(
            .ctx,
            .shader,
            .source,
        )
    );
    
    const compile_shader = (
        ctx :: Context,
        shader :: Shader,
    ) -> () => (
        (@native "({ctx,shader})=>ctx.compileShader(shader)")(
            .ctx,
            .shader,
        )
    );
    
    const get_shader_parameter_bool = (
        ctx :: Context,
        shader :: Shader,
        pname :: GLenum,
    ) -> GLboolean => (
        (@native "({ctx,shader,pname})=>ctx.getShaderParameter(shader,pname)")(
            .ctx,
            .shader,
            .pname,
        )
    );
    
    const get_shader_info_log = (
        ctx :: Context,
        shader :: Shader,
    ) -> String => (
        (@native "({ctx,shader})=>ctx.getShaderInfoLog(shader)")(
            .ctx,
            .shader,
        )
    )
);

const Shader = @opaque_type;
