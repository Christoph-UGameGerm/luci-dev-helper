#!/usr/bin/bash

set -e

print_usage() {
    echo "Usage: $0 [OPTIONS] <luci_app_dir> <luci_src_dir>"
    echo "Options:"
    echo "  -s, --sync     ONLY sync i18n files (default if no option provided, override --compile if both provided)"
    echo "  -c, --compile  ONLY compile .po files to .lmo files"
    echo "Arguments:"
    echo "  luci_app_dir:  LuCI application directory path"
    echo "  luci_src_dir:  LuCI source directory path. Commonly .../openwrt/feeds/luci"
}

# SYNC operation default
DO_SYNC=1
DO_COMPILE=0

POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--sync)
            DO_SYNC=1
            DO_COMPILE=0
            shift
            ;;
        -c|--compile)
            DO_SYNC=0
            DO_COMPILE=1
            shift
            ;;
        -*|--*)
            echo "Unknown option $1"
            print_usage
            exit 1
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done

set -- "${POSITIONAL_ARGS[@]}"

if [ $# -ne 2 ]; then
    print_usage
    exit 1
fi

luci_app_dir=$(realpath "$1")
luci_src_dir=$(realpath "$2")
if [[ ! -f "${luci_src_dir}/build/i18n-sync.sh" ]]; then
    echo "i18n-sync.sh does not exist in indicated luci_src_dir"
    exit 1
fi
cd ${luci_src_dir}

if [ $DO_SYNC -eq 1 ]; then
    ./build/i18n-sync.sh -b ${luci_app_dir}

    # If luci app dir start with luci-app,
    # strip the potential absolute path to prevent privacy leak in generated .po files' comments
    find "${luci_app_dir}/po" -type f \( -name '*.pot' -o -name '*.po' -o -name '*.po~' \) | while read -r file; do
        echo "Processing file: $file"
        temp_file=$(mktemp)
        sed 's|#: .*/\(luci-app[^|]*\)|#: \1|g' "$file" > "$temp_file"
        mv "$temp_file" "$file"
    done

    echo "i18n sync complete"
fi

if [ $DO_COMPILE -eq 1 ]; then
    echo "starting lmo compilation..."

    luci_base_src_dir=modules/luci-base/src
    luci_po2lmo_path=${luci_base_src_dir}/po2lmo
    if [[ ! -d ${luci_base_src_dir} ]]; then
        echo "${luci_base_src_dir} does not exist. Please check openwrt env for luci-base/src folder"
        exit 1
    elif [[ ! -f ${luci_po2lmo_path} ]]; then
        echo "Executable po2lmo does not exist. Compiling..."
        cd ${luci_base_src_dir}
        make po2lmo V=s
        echo "Compile complete"
        cd ${luci_src_dir}
    fi

    mkdir -p ${luci_app_dir}/root/usr/lib/lua/luci/i18n/
    find "${luci_app_dir}" -type f -name "*.po" | while read -r po_file; do
        parent_dir=$(basename $(dirname "${po_file}"))
        base_name=$(basename ${po_file} .po)
        output_file="${luci_app_dir}/root/usr/lib/lua/luci/i18n/${base_name}.${parent_dir}.lmo"
        echo "Converting ${po_file} to ${base_name}.${parent_dir}.lmo"
        ${luci_po2lmo_path} $(realpath "${po_file}") ${output_file}
    done
fi

echo "Process completed!"
