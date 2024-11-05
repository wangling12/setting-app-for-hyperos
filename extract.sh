#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./script.sh arg-one arg-two

This is an awesome bash script to make your life better.

'
    exit
fi

cd "$(dirname "$0")"

main() {
    IFS=_ read -ra arr <<< "$1"
    codename="${arr[1]}"
    version="${arr[2]}"
    # echo $codename
    # echo $version
    [ -f "payload.bin" ] && rm "payload.bin"
    [ -d "extract_files" ] && rm -rf "extract_files"
    unzip "$1" payload.bin
    ./payload-dumper-go -p system_ext -o extract_files payload.bin
    mkdir -p extract_files/mount_files
    sudo mount -o ro ./extract_files/system_ext.img ./extract_files/mount_files
    cp ./extract_files/mount_files/priv-app/Settings/Settings.apk "./settings_apks/Settings_${codename}_from_${version}.apk"
    sudo umount extract_files/mount_files
}

main "$@"
