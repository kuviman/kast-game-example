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
    
    const get_program_parameter_int = (
        ctx :: Context,
        program :: Program,
        pname :: GLenum,
    ) -> GLint => (
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
        (@native "({ctx,index,size,type,normalized,stride,offset})=>ctx.vertexAttribPointer(index,size,type,normalized,stride,offset)")(
            .ctx,
            .index,
            .size,
            .@"type",
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
    
    const get_active_attrib = (
        ctx :: Context,
        program :: Program,
        index :: GLuint,
    ) -> ActiveInfo => (
        (@native "({ctx,program,index})=>ctx.getActiveAttrib(program,index)")(
            .ctx,
            .program,
            .index,
        )
    );
    
    const get_active_uniform = (
        ctx :: Context,
        program :: Program,
        index :: GLuint,
    ) -> ActiveInfo => (
        (@native "({ctx,program,index})=>ctx.getActiveUniform(program,index)")(
            .ctx,
            .program,
            .index,
        )
    );
    
    const get_uniform_location = (
        ctx :: Context,
        program :: Program,
        name :: String,
    ) -> Option.t[WebGLUniformLocation] => (
        (@native "({ctx,program,name})=>ctx.getUniformLocation(program,name)")(
            .ctx,
            .program,
            .name,
        )
            |> js.check_null
    );
    
    const create_texture = (
        ctx :: Context
    ) -> WebGLTexture => (
        (@native "({ctx})=>ctx.createTexture()")(
            .ctx,
        )
    );
    
    const bind_texture = (
        ctx :: Context,
        target :: GLenum,
        texture :: WebGLTexture,
    ) -> WebGLTexture => (
        (@native "({ctx,target,texture})=>ctx.bindTexture(target,texture)")(
            .ctx,
            .target,
            .texture,
        )
    );
    
    const tex_image_2d = (
        ctx :: Context,
        target :: GLenum,
        level :: GLint,
        internal_format :: GLenum,
        format :: GLenum,
        @"type" :: GLenum,
        source :: js.Any,
    ) -> WebGLTexture => (
        (@native "({ctx,target,level,internal_format,format,type,source})=>ctx.texImage2D(target,level,internal_format,format,type,source)")(
            .ctx,
            .target,
            .level,
            .internal_format,
            .format,
            .@"type",
            .source,
        )
    );
    
    const tex_parameter_i = (
        ctx :: Context,
        target :: GLenum,
        pname :: GLenum,
        param :: GLint,
    ) -> WebGLTexture => (
        (@native "({ctx,target,pname,param})=>ctx.texParameteri(target,pname,param)")(
            .ctx,
            .target,
            .pname,
            .param,
        )
    );
    
    const tex_parameter_f = (
        ctx :: Context,
        target :: GLenum,
        pname :: GLenum,
        param :: GLfloat,
    ) -> WebGLTexture => (
        (@native "({ctx,target,pname,param})=>ctx.texParameterf(target,pname,param)")(
            .ctx,
            .target,
            .pname,
            .param,
        )
    );
    
    const generate_mipmap = (
        ctx :: Context,
        target :: GLenum,
    ) -> () => (
        (@native "({ctx,target})=>ctx.generateMipmap(target)")(
            .ctx,
            .target,
        )
    );
    
    const pixel_store_bool = (
        ctx :: Context,
        pname :: GLenum,
        value :: GLboolean,
    ) -> () => (
        (@native "({ctx,pname,value})=>ctx.pixelStorei(pname,value)")(
            .ctx,
            .pname,
            .value,
        )
    );
);

const Shader = @opaque_type;
const Program = @opaque_type;
const Buffer = @opaque_type;
const ActiveInfo = newtype (
    .name :: String,
    .size :: GLsizei,
    .@"type" :: GLenum,
);
const WebGLUniformLocation = @opaque_type;
const WebGLTexture = @opaque_type;
