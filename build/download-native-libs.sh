#!/usr/bin/env bash
set -euo pipefail

MOCK_SERVER_VERSION="0.0.17"
MOCK_SERVER_BASE_URL="https://github.com/pact-foundation/pact-reference/releases/download/libpact_mock_server_ffi-v$MOCK_SERVER_VERSION"

VERIFIER_VERSION="0.0.4"
VERIFIER_BASE_URL="https://github.com/pact-foundation/pact-reference/releases/download/pact_verifier_ffi-v$VERIFIER_VERSION"

base_path=$(dirname "$0")

download_native() {
    base_url="$1"
    component="$2"
    file="$3"
    os="$4"
    platform="$5"
    extension="$6"

    url="$base_url/lib$component-$os-$platform.$extension.gz"
    sha="$url.sha256"

    path="$base_path/$os/$platform"
    mkdir -p "$path"

    echo "Downloading $component"
    echo "    Platform: $os/$platform"
    echo "    File: $file.$extension"
    echo "    URL: $url"

    echo -n "    Downloading... "
    curl --silent -L "$url" -o "$path/$file.$extension.gz"
    curl --silent -L "$sha" -o "$path/$file.$extension.gz.sha256"
    echo "OK"

    echo -n "    Verifying... "

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # OSX requires an empty arg passed to -i, but this doesn't work on Lin/Win
        sed -Ei '' "s|../target/artifacts/.+$|$path/$file.$extension.gz|" "$path/$file.$extension.gz.sha256"
        shasum -a 256 --check --quiet "$path/$file.$extension.gz.sha256"
    else
        sed -Ei "s|../target/artifacts/.+$|$path/$file.$extension.gz|" "$path/$file.$extension.gz.sha256"
        sha256sum --check --quiet "$path/$file.$extension.gz.sha256"
    fi

    rm "$path/$file.$extension.gz.sha256"
    echo "OK"

    echo -n "    Extracting... "
    gunzip -f "$path/$file.$extension.gz"
    echo "OK"
}

download_native "$MOCK_SERVER_BASE_URL" "pact_mock_server_ffi" "pact_mock_server_ffi" "windows" "x86_64" "dll"
download_native "$MOCK_SERVER_BASE_URL" "pact_mock_server_ffi" "libpact_mock_server_ffi" "linux" "x86_64" "so"
download_native "$MOCK_SERVER_BASE_URL" "pact_mock_server_ffi" "pact_mock_server_ffi" "osx" "x86_64" "dylib"

download_native "$VERIFIER_BASE_URL" "pact_verifier_ffi" "pact_verifier_ffi" "windows" "x86_64" "dll"
download_native "$VERIFIER_BASE_URL" "pact_verifier_ffi" "libpact_verifier_ffi" "linux" "x86_64" "so"
download_native "$VERIFIER_BASE_URL" "pact_verifier_ffi" "pact_verifier_ffi" "osx" "x86_64" "dylib"
