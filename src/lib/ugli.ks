module:

const GL = gl.Context;

const SizedType = [Self] newtype (
    .size :: Int32,
);

impl Float32 as SizedType = (
    .size = 4,
);

const compile_shader = (ctx, shader_type, source) => (
    let shader = ctx
        |> GL.create_shader(shader_type)
        |> Option.unwrap;
    ctx |> GL.shader_source(shader, source);
    ctx |> GL.compile_shader(shader);
    let compile_status = ctx
        |> GL.get_shader_parameter_bool(
            shader, gl.COMPILE_STATUS
        );
    if not compile_status then (
        let log = ctx
            |> GL.get_shader_info_log(shader);
        panic("Shader compilation failed: " + log);
    );
    shader
);

const AttributeInfo = newtype (
    .raw :: gl.ActiveInfo,
    .index :: Int32,
);

const UniformInfo = newtype (
    .raw :: gl.ActiveInfo,
    .location :: gl.WebGLUniformLocation,
    .index :: Int32,
);

const Program = newtype (
    .ctx :: gl.Context,
    .handle :: gl.Program,
    .attributes :: Map.t[String, AttributeInfo],
    .uniforms :: Map.t[String, UniformInfo],
);

impl Program as module = (
    module:
    
    const init = (
        ctx,
        vertex_shader :: gl.Shader,
        fragment_shader :: gl.Shader,
    ) -> Program => (
        let program = ctx
            |> GL.create_program
            |> Option.unwrap;
        ctx |> GL.attach_shader(program, vertex_shader);
        ctx |> GL.attach_shader(program, fragment_shader);
        ctx |> GL.link_program(program);
        let link_status = ctx |> GL.get_program_parameter_bool(program, gl.LINK_STATUS);
        if not link_status then (
            let log = ctx
                |> GL.get_program_info_log(program);
            panic("Program link failed: " + log);
        );
        let active_attributes = ctx
            |> GL.get_program_parameter_int(program, gl.ACTIVE_ATTRIBUTES);
        let mut attributes = Map.create();
        for index in 0..active_attributes do (
            let active_info = ctx
                |> GL.get_active_attrib(program, index);
            if active_info.size != 1 then (
                dbg.print(active_info);
                panic("active_info.size != 1");
            );
            let attribute_info = (
                .raw = active_info,
                .index,
            );
            Map.add(&mut attributes, attribute_info.raw.name, attribute_info);
        );
        let active_uniforms = ctx
            |> GL.get_program_parameter_int(program, gl.ACTIVE_UNIFORMS);
        let mut uniforms = Map.create();
        for index in 0..active_uniforms do (
            let active_info = ctx
                |> GL.get_active_uniform(program, index);
            if active_info.size != 1 then (
                dbg.print(active_info);
                panic("active_info.size != 1");
            );
            let location = ctx
                |> GL.get_uniform_location(program, active_info.name)
                |> Option.unwrap;
            let uniform_info = (
                .raw = active_info,
                .location,
                .index,
            );
            Map.add(&mut uniforms, uniform_info.raw.name, uniform_info);
        );
        (
            .ctx,
            .handle = program,
            .attributes,
            .uniforms,
        )
    );
    
    const @"use" = (program :: Program) => (
        program.ctx |> GL.use_program(program.handle);
    );
);

const Texture = newtype (
    .handle :: gl.WebGLTexture,
);

const Filter = newtype (
    | :Nearest
    | :Linear
);

impl Texture as module = (
    module:
    
    const init = (
        ctx :: GL,
        image :: web.HtmlImageElement,
        filter :: Filter,
    ) -> Texture => (
        let handle = ctx |> GL.create_texture;
        ctx |> GL.bind_texture(gl.TEXTURE_2D, handle);
        ctx |> GL.pixel_store_bool(gl.UNPACK_FLIP_Y_WEBGL, true);
        match filter with (
            | :Linear => ()
            | :Nearest => (
                ctx
                    |> GL.tex_parameter_i(
                        gl.TEXTURE_2D,
                        gl.TEXTURE_MAG_FILTER,
                        gl.NEAREST
                    );
            )
        );
        ctx
            |> GL.tex_image_2d(
                gl.TEXTURE_2D,
                0,
                gl.RGBA,
                gl.RGBA,
                gl.UNSIGNED_BYTE,
                image |> js.unsafe_cast
            );
        ctx |> GL.generate_mipmap(gl.TEXTURE_2D);
        (.handle)
    );
);

const VertexAttribute = [Self] newtype (
    .size :: gl.GLint,
    .@"type" :: gl.GLenum,
    .type_size :: Int32,
    .construct_data :: &List.t[Self] -> js.Any,
);

impl Vec2 as VertexAttribute = (
    .size = 2,
    .@"type" = gl.FLOAT,
    .type_size = 4,
    .construct_data = data => (
        let list = js.List.init();
        for &(x, y) in List.iter(data) do (
            list |> js.List.push(x);
            list |> js.List.push(y);
        );
        (@native "list=>new Float32Array(list)")(list)
    ),
);

impl Vec3 as VertexAttribute = (
    .size = 3,
    .@"type" = gl.FLOAT,
    .type_size = 4,
    .construct_data = data => (
        let list = js.List.init();
        for &(x, y, z) in List.iter(data) do (
            list |> js.List.push(x);
            list |> js.List.push(y);
            list |> js.List.push(z);
        );
        (@native "list=>new Float32Array(list)")(list)
    ),
);

impl Vec4 as VertexAttribute = (
    .size = 4,
    .@"type" = gl.FLOAT,
    .type_size = 4,
    .construct_data = data => (
        let list = js.List.init();
        for &(x, y, z, w) in List.iter(data) do (
            list |> js.List.push(x);
            list |> js.List.push(y);
            list |> js.List.push(z);
            list |> js.List.push(w);
        );
        (@native "list=>new Float32Array(list)")(list)
    ),
);

const DrawState = newtype (
    .active_texture_index :: Int32,
);

impl DrawState as module = (
    module:
    
    const init = () -> DrawState => (
        .active_texture_index = 0,
    );
);

const Uniform = [Self] newtype (
    .set :: (GL, gl.WebGLUniformLocation, Self, &mut DrawState) -> (),
);

impl Vec2 as Uniform = (
    .set = (ctx, location, value, state) => (
        let list = js.List.init();
        let (x, y) = value;
        (@native "({ctx,location,x,y})=>ctx.uniform2f(location,x,y)")(
            .ctx,
            .location,
            .x,
            .y,
        );
    ),
);

impl Mat3 as Uniform = (
    .set = (ctx, location, value, state) => (
        let list = js.List.init();
        let add = (x, y, z) => (
            list |> js.List.push(x);
            list |> js.List.push(y);
            list |> js.List.push(z);
        );
        let (a, b, c) = value;
        add(a);
        add(b);
        add(c);
        let data = (@native "list=>new Float32Array(list)")(list);
        (@native "({ctx,location,data})=>ctx.uniformMatrix3fv(location,false,data)")(
            .ctx,
            .data,
            .location,
        );
    ),
);

impl Texture as Uniform = (
    .set = (ctx, location, value, state) => (
        (@native "({ctx,i})=>ctx.activeTexture(i)")(
            .ctx,
            .i = gl.TEXTURE0 + state^.active_texture_index,
        );
        (@native "({ctx,location,i})=>ctx.uniform1i(location,i)")(
            .ctx,
            .location,
            .i = state^.active_texture_index,
        );
        state^.active_texture_index += 1;
    ),
);

const set_uniform = [T] (
    program :: Program,
    name :: String,
    value :: T,
    state :: &mut DrawState,
) -> () => with_return (
    let ctx = program.ctx;
    let uniform_info = match &program.uniforms |> Map.get(name) with (
        | :Some(info) => info
        | :None => return
    );
    (T as Uniform).set(ctx, uniform_info^.location, value, state);
);

const bind_field = [V, T] (
    program :: Program,
    data :: &List.t[V],
    name :: String,
    get :: &V -> T,
) => with_return (
    let ctx = program.ctx;
    let attribute_info = match &program.attributes |> Map.get(name) with (
        | :Some(info) => info
        | :None => return
    );
    
    let mut field_data = List.create();
    for vertex in List.iter(data) do (
        let field = get(vertex);
        &mut field_data |> List.push_back(field);
    );
    let field_data = (T as VertexAttribute).construct_data(&field_data);
    
    let buffer = ctx |> GL.create_buffer;
    ctx |> GL.bind_buffer(gl.ARRAY_BUFFER, buffer);
    ctx |> GL.buffer_data(gl.ARRAY_BUFFER, field_data, gl.STATIC_DRAW);
    
    dbg.print(field_data);
    
    let offset = 0;
    let stride = (
        (T as VertexAttribute).size
        * (T as VertexAttribute).type_size
    );
    GL.vertex_attrib_pointer(
        ctx,
        attribute_info^.index,
        (T as VertexAttribute).size,
        (T as VertexAttribute).@"type",
        false,
        stride,
        offset,
    );
    ctx |> GL.enable_vertex_attrib_array(attribute_info^.index);
);
