default:
    echo "Hi"

build:
    kast compile \
        --target js \
        --output target/compiled/main.mjs \
        src/main.ks

build-native:
    kastc compile \
        --target c \
        --output target/compiled/main.c \
        src/main.ks
    just build-c

build-c:
    ${CC:-gcc} \
        -lgc -lSDL3 -lSDL3_image -lGL -lGLEW \
        -Wfatal-errors \
        -fsanitize=address,leak,undefined \
        -g -O1 \
        -o target/compiled/main.exe \
        target/compiled/main.c
    # -fno-omit-frame-pointer \

run:
    just build-native
    LSAN_OPTIONS='suppresions=suppr.txt' \
        ./target/compiled/main.exe

build-watch:
    #!/usr/bin/env bash
    just build
    while inotifywait -r -e modify,create,delete,move src; do
        sleep 0.2
        just build
    done

serve:
    just build
    caddy run
