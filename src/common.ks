module:

const UInt32_to_Int32 = (x :: UInt32) -> Int32 => @native "\(x)";
const Int32_to_UInt32 = (x :: Int32) -> UInt32 => @native "\(x)";
const Int32_to_Float32 = (x :: Int32) -> Float32 => @native "\(x)";
const UInt32_to_Float32 = (x :: UInt32) -> Float32 => @native "\(x)";
const UInt64_to_Float32 = (x :: UInt64) -> Float32 => @native "\(x)";

const is_emscripten = () -> Bool => @native ''
    #ifdef __EMSCRIPTEN__
        true
    #else
        false
    #endif
'';
