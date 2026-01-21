module:

const HtmlElement = @opaque_type;

const HtmlCanvasElement = @opaque_type;

impl HtmlCanvasElement as module = (
    module:
    
    const get_context = (
        canvas :: HtmlCanvasElement,
        context_type :: String,
    ) -> js.Any => (
        (@native "({canvas,context_type})=>canvas.getContext(context_type)")(
            .canvas,
            .context_type,
        )
    );
    
    const set_width = (
        canvas :: HtmlCanvasElement,
        width :: Int32,
    ) -> () => (
        (@native "({canvas,width})=>{canvas.width=width}")(
            .canvas,
            .width,
        )
    );
    
    const set_height = (
        canvas :: HtmlCanvasElement,
        height :: Int32,
    ) -> () => (
        (@native "({canvas,height})=>{canvas.height=height}")(
            .canvas,
            .height,
        )
    );
);

const HtmlDocumentElement = @opaque_type;

impl HtmlDocumentElement as module = (
    module:
    
    const get_element_by_id = (
        document :: HtmlDocumentElement,
        id :: String,
    ) -> HtmlElement => (
        (@native "({document,id})=>document.getElementById(id)")(
            .document,
            .id,
        )
    );
);

const document = () -> HtmlDocumentElement => (
    @native "document"
);

const WebGLRenderingContext = @opaque_type;

const HtmlImageElement = @opaque_type;
