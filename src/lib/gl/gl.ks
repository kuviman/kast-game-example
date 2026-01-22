module:

include "./types.ks";
include "./constants.ks";

const ContextT = web.WebGLRenderingContext;
const Context = @context ContextT;

const clear = (bits :: GLbitfield) -> () => (
    let ctx = (@current Context);
    (@native "({ctx,bits})=>ctx.clear(bits)")(
        .ctx,
        .bits,
    )
);

const clear_color = (
    r :: GLclampf,
    g :: GLclampf,
    b :: GLclampf,
    a :: GLclampf,
) -> () => (
    let ctx = (@current Context);
    (@native "({ctx,r,g,b,a})=>ctx.clearColor(r,g,b,a)")(
        .ctx,
        .r,
        .g,
        .b,
        .a,
    )
);

const create_shader = (shader_type :: GLenum) -> Option.t[Shader] => (
    let ctx = (@current Context);
    (@native "({ctx,t})=>ctx.createShader(t)")(
        .ctx,
        .t = shader_type,
    )
        |> js.check_null
);

const shader_source = (
    shader :: Shader,
    source :: String,
) -> () => (
    let ctx = (@current Context);
    (@native "({ctx,shader,source})=>ctx.shaderSource(shader,source)")(
        .ctx,
        .shader,
        .source,
    )
);

const compile_shader = (shader :: Shader) -> () => (
    let ctx = (@current Context);
    (@native "({ctx,shader})=>ctx.compileShader(shader)")(
        .ctx,
        .shader,
    )
);

const get_shader_parameter_bool = (
    shader :: Shader,
    pname :: GLenum,
) -> GLboolean => (
    let ctx = (@current Context);
    (@native "({ctx,shader,pname})=>ctx.getShaderParameter(shader,pname)")(
        .ctx,
        .shader,
        .pname,
    )
);

const get_shader_info_log = (shader :: Shader) -> String => (
    let ctx = (@current Context);
    (@native "({ctx,shader})=>ctx.getShaderInfoLog(shader)")(
        .ctx,
        .shader,
    )
);

const create_program = () -> Option.t[Program] => (
    let ctx = (@current Context);
    (@native "({ctx})=>ctx.createProgram(ctx)")(
        .ctx,
    )
        |> js.check_null
);

const attach_shader = (
    program :: Program,
    shader :: Shader,
) -> () => (
    let ctx = (@current Context);
    (@native "({ctx,program,shader})=>ctx.attachShader(program,shader)")(
        .ctx,
        .program,
        .shader,
    )
);

const link_program = (program :: Program) -> () => (
    let ctx = (@current Context);
    (@native "({ctx,program})=>ctx.linkProgram(program)")(
        .ctx,
        .program,
    )
);

const get_program_parameter_bool = (
    program :: Program,
    pname :: GLenum,
) -> GLboolean => (
    let ctx = (@current Context);
    (@native "({ctx,program,pname})=>ctx.getProgramParameter(program,pname)")(
        .ctx,
        .program,
        .pname,
    )
);

const get_program_parameter_int = (
    program :: Program,
    pname :: GLenum,
) -> GLint => (
    let ctx = (@current Context);
    (@native "({ctx,program,pname})=>ctx.getProgramParameter(program,pname)")(
        .ctx,
        .program,
        .pname,
    )
);

const get_program_info_log = (program :: Program) -> String => (
    let ctx = (@current Context);
    (@native "({ctx,program})=>ctx.getProgramInfoLog(program)")(
        .ctx,
        .program,
    )
);

const use_program = (program :: Program) -> () => (
    let ctx = (@current Context);
    (@native "({ctx,program})=>ctx.useProgram(program)")(
        .ctx,
        .program,
    )
);

const draw_arrays = (
    mode :: GLenum,
    first :: GLint,
    count :: GLsizei,
) -> () => (
    let ctx = (@current Context);
    (@native "({ctx,mode,first,count})=>ctx.drawArrays(mode,first,count)")(
        .ctx,
        .mode,
        .first,
        .count,
    )
);

const create_buffer = () -> Buffer => (
    let ctx = (@current Context);
    (@native "({ctx})=>ctx.createBuffer()")(
        .ctx,
    )
);

const bind_buffer = (
    target :: GLenum,
    buffer :: Buffer,
) -> () => (
    let ctx = (@current Context);
    (@native "({ctx,target,buffer})=>ctx.bindBuffer(target,buffer)")(
        .ctx,
        .target,
        .buffer,
    )
);

const buffer_data = (
    target :: GLenum,
    src_data :: js.Any,
    usage :: GLenum,
) -> () => (
    let ctx = (@current Context);
    (@native "({ctx,target,src_data,usage})=>ctx.bufferData(target,src_data,usage)")(
        .ctx,
        .target,
        .src_data,
        .usage,
    )
);

const vertex_attrib_pointer = (
    index :: GLuint,
    size :: GLint,
    @"type" :: GLenum,
    normalized :: GLboolean,
    stride :: GLsizei,
    offset :: GLintptr,
) -> () => (
    let ctx = (@current Context);
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

const enable = (cap :: GLenum) -> () => (
    let ctx = (@current Context);
    (@native "({ctx,cap})=>ctx.enable(cap)")(
        .ctx,
        .cap,
    )
);

const blend_color = (
    red :: GLclampf,
    green :: GLclampf,
    blue :: GLclampf,
    alpha :: GLclampf,
) -> () => (
    let ctx = (@current Context);
    (@native "({ctx,red,green,blue,alpha})=>ctx.blendColor(red,green,blue,alpha)")(
        .ctx,
        .red,
        .green,
        .blue,
        .alpha,
    )
);

const blend_func = (src_factor :: GLenum, dst_factor :: GLenum) -> () => (
    let ctx = (@current Context);
    (@native "({ctx,src_factor,dst_factor})=>ctx.blendFunc(src_factor,dst_factor)")(
        .ctx,
        .src_factor,
        .dst_factor,
    )
);

const blend_func_separate = (
    src_rgb :: GLenum,
    dst_rgb :: GLenum,
    src_alpha :: GLenum,
    dst_alpha :: GLenum,
) -> () => (
    let ctx = (@current Context);
    (@native "({ctx,src_rgb,dst_rgb,src_alpha,dst_alpha})=>ctx.blendFuncSeparate(src_rgb,dst_rgb,src_alpha,dst_alpha)")(
        .ctx,
        .src_rgb,
        .dst_rgb,
        .src_alpha,
        .dst_alpha,
    )
);

const blend_equation = (mode :: GLenum) -> () => (
    let ctx = (@current Context);
    (@native "({ctx,mode})=>ctx.blendEquation(mode)")(
        .ctx,
        .mode,
    )
);

const blend_equation_separate = (
    mode_rgb :: GLenum,
    mode_alpha :: GLenum,
) -> () => (
    let ctx = (@current Context);
    (@native "({ctx,mode_rgb,mode_alpha})=>ctx.blendEquationSeparate(mode_rgb,mode_alpha)")(
        .ctx,
        .mode_rgb,
        .mode_alpha,
    )
);

# blendEq(src * srcFactor, dst * dstFactor)
const enable_vertex_attrib_array = (index :: GLuint) -> () => (
    let ctx = (@current Context);
    (@native "({ctx,index})=>ctx.enableVertexAttribArray(index)")(
        .ctx,
        .index,
    )
);

const disable_vertex_attrib_array = (index :: GLuint) -> () => (
    let ctx = (@current Context);
    (@native "({ctx,index})=>ctx.disableVertexAttribArray(index)")(
        .ctx,
        .index,
    )
);

const get_active_attrib = (
    program :: Program,
    index :: GLuint,
) -> ActiveInfo => (
    let ctx = (@current Context);
    (@native "({ctx,program,index})=>ctx.getActiveAttrib(program,index)")(
        .ctx,
        .program,
        .index,
    )
);

const get_active_uniform = (
    program :: Program,
    index :: GLuint,
) -> ActiveInfo => (
    let ctx = (@current Context);
    (@native "({ctx,program,index})=>ctx.getActiveUniform(program,index)")(
        .ctx,
        .program,
        .index,
    )
);

const get_uniform_location = (
    program :: Program,
    name :: String,
) -> Option.t[WebGLUniformLocation] => (
    let ctx = (@current Context);
    (@native "({ctx,program,name})=>ctx.getUniformLocation(program,name)")(
        .ctx,
        .program,
        .name,
    )
        |> js.check_null
);

const create_texture = () -> WebGLTexture => (
    let ctx = (@current Context);
    (@native "({ctx})=>ctx.createTexture()")(
        .ctx,
    )
);

const bind_texture = (
    target :: GLenum,
    texture :: WebGLTexture,
) -> WebGLTexture => (
    let ctx = (@current Context);
    (@native "({ctx,target,texture})=>ctx.bindTexture(target,texture)")(
        .ctx,
        .target,
        .texture,
    )
);

const tex_image_2d = (
    target :: GLenum,
    level :: GLint,
    internal_format :: GLenum,
    format :: GLenum,
    @"type" :: GLenum,
    source :: js.Any,
) -> WebGLTexture => (
    let ctx = (@current Context);
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
    target :: GLenum,
    pname :: GLenum,
    param :: GLint,
) -> WebGLTexture => (
    let ctx = (@current Context);
    (@native "({ctx,target,pname,param})=>ctx.texParameteri(target,pname,param)")(
        .ctx,
        .target,
        .pname,
        .param,
    )
);

const tex_parameter_f = (
    target :: GLenum,
    pname :: GLenum,
    param :: GLfloat,
) -> WebGLTexture => (
    let ctx = (@current Context);
    (@native "({ctx,target,pname,param})=>ctx.texParameterf(target,pname,param)")(
        .ctx,
        .target,
        .pname,
        .param,
    )
);

const generate_mipmap = (target :: GLenum) -> () => (
    let ctx = (@current Context);
    (@native "({ctx,target})=>ctx.generateMipmap(target)")(
        .ctx,
        .target,
    )
);

const pixel_store_bool = (
    pname :: GLenum,
    value :: GLboolean,
) -> () => (
    let ctx = (@current Context);
    (@native "({ctx,pname,value})=>ctx.pixelStorei(pname,value)")(
        .ctx,
        .pname,
        .value,
    )
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
