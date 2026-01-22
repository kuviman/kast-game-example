module:

const Key = newtype (
    | :ArrowLeft
    | :ArrowRight
    | :ArrowUp
    | :ArrowDown
    | :Space
);

const is_key_pressed = (key :: Key) -> Bool => (
    (@native "Runtime.is_key_pressed")(key)
);
