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
    );
    
    const create_program = (ctx :: Context) -> Option.t[Program] => (
        (@native "({ctx})=>ctx.createProgram(ctx)")(
            .ctx,
        )
            |> js.check_null
    );
    
    const attach_shader = (
        ctx :: Context,
        program :: Program,
        shader :: Shader
    ) -> () => (
        (@native "({ctx,program,shader})=>ctx.attachShader(program,shader)")(
            .ctx,
            .program,
            .shader,
        )
    );
    
    const link_program = (
        ctx :: Context,
        program :: Program,
    ) -> () => (
        (@native "({ctx,program})=>ctx.linkProgram(program)")(
            .ctx,
            .program,
        )
    );
    
    const get_program_parameter_bool = (
        ctx :: Context,
        program :: Program,
        pname :: GLenum,
    ) -> GLboolean => (
        (@native "({ctx,program,pname})=>ctx.getProgramParameter(program,pname)")(
            .ctx,
            .program,
            .pname,
        )
    );
    
    const get_program_info_log = (
        ctx :: Context,
        program :: Program,
    ) -> String => (
        (@native "({ctx,program})=>ctx.getProgramInfoLog(program)")(
            .ctx,
            .program,
        )
    );
    
    const use_program = (
        ctx :: Context,
        program :: Program,
    ) -> () => (
        (@native "({ctx,program})=>ctx.useProgram(program)")(
            .ctx,
            .program,
        )
    );
    
    const draw_arrays = (
        ctx :: Context,
        mode :: GLenum,
        first :: GLint,
        count :: GLsizei,
    ) -> () => (
        (@native "({ctx,mode,first,count})=>ctx.drawArrays(mode,first,count)")(
            .ctx,
            .mode,
            .first,
            .count,
        )
    );
    
    const create_buffer = (ctx :: Context) -> Buffer => (
        (@native "({ctx})=>ctx.createBuffer()")(
            .ctx,
        )
    );
    
    const bind_buffer = (
        ctx :: Context,
        target :: GLenum,
        buffer :: Buffer,
    ) -> () => (
        (@native "({ctx,target,buffer})=>ctx.bindBuffer(target,buffer)")(
            .ctx,
            .target,
            .buffer,
        )
    );
    
    const buffer_data = (
        ctx :: Context,
        target :: GLenum,
        src_data :: js.Any,
        usage :: GLenum,
    ) -> () => (
        (@native "({ctx,target,src_data,usage})=>ctx.bufferData(target,src_data,usage)")(
            .ctx,
            .target,
            .src_data,
            .usage,
        )
    );
    
    const vertex_attrib_pointer = (
        ctx :: Context,
        index :: GLuint,
        size :: GLint,
        @"type" :: GLenum,
        normalized :: GLboolean,
        stride :: GLsizei,
        offset :: GLintptr,
    ) -> () => (
        (@native "({ctx,index,size,ty,normalized,stride,offset})=>ctx.vertexAttribPointer(index,size,ty,normalized,stride,offset)")(
            .ctx,
            .index,
            .size,
            .ty = @"type",
            .normalized,
            .stride,
            .offset,
        )
    );
    
    const enable_vertex_attrib_array = (
        ctx :: Context,
        index :: GLuint,
    ) -> () => (
        (@native "({ctx,index})=>ctx.enableVertexAttribArray(index)")(
            .ctx,
            .index,
        )
    );
    
    const disable_vertex_attrib_array = (
        ctx :: Context,
        index :: GLuint,
    ) -> () => (
        (@native "({ctx,index})=>ctx.disableVertexAttribArray(index)")(
            .ctx,
            .index,
        )
    );
);

const Shader = @opaque_type;
const Program = @opaque_type;
const Buffer = @opaque_type;
