default:
    echo "Hi"

build:
    kast compile \
        --target js \
        --output target/compiled/main.mjs \
        src/main.ks

build-native:
    kast compile \
        --target c \
        --output target/compiled/main.c \
        src/main.ks
    just build-c

build-c:
    gcc -o target/compiled/main.exe target/compiled/main.c

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
