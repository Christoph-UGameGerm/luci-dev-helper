#!/usr/bin/bash

target_app=
openwrt_path=
router_ssh_path=

# Usage information
usage() {
    cat << EOF
Usage: $(basename $0) [OPTIONS]
Options:
    -t TARGET_APP    Target application path. Should include self-defined feeds like 'feeds/local/luci-app-example'. Notice that no slashes on both sides
    -p OPENWRT_PATH  OpenWrt environment path
    -r ROUTER_PATH   Router SSH path, format should be like: <username>@<hostname>:<target_path>
    -h              Show this help message

Example: $(basename $0) -t feeds/local/luci-app-example -p ~/openwrt -r root@192.168.1.1:~
EOF
    exit 1
}

# Parse command line options
while getopts "t:p:r:h" opt; do
    case ${opt} in
        t)
            target_app=$(echo ${OPTARG} | sed 's:^/*::; s:/*$::')
            ;;
        p)
            openwrt_path=$(realpath $OPTARG)
            ;;
        r)
            router_ssh_path=$OPTARG
            if [[ "$router_ssh_path" != *: ]]; then
                router_ssh_path="${router_ssh_path}:"
            fi
            ;;
        h)
            usage
            ;;
        \?)
            usage
            ;;
    esac
done

if [ $# -ne 6 ]; then
    usage
    exit 1
fi

if [[ ! -d "${openwrt_path}" ]]; then
    echo "Indicated OpenWrt env path does not exist, please check the script"
    exit 1
elif [[ ! -d "${openwrt_path}/${target_app}" ]]; then
    echo "Indicated Package does not exist under OpenWrt env, please check \
    'feeds list' for install status or 'make menuconfig'"
    exit 1
fi

cd ${openwrt_path}
echo "OpenWrt and target app path check passed, updating feeds..."
./scripts/feeds update -a
echo "Installing from feeds..."
./scripts/feeds install -a
echo "Start building..."
make package/${target_app}/{clean,compile}
if [ $? -eq 1 ]; then
    echo "Compilation failed, trying to make with V=s..."
    make package/${target_app}/clean V=s
    make package/${target_app}/compile V=s
    exit 1
fi

echo "Building Complete, start ipk existence check..."

target_app_name=$(basename ${target_app})
target_app_ipk_path=$(find ./bin/packages/ -type f -name "*${target_app_name}*.ipk" | head -n 1)

if [ -z "$target_app_ipk_path" ]; then
    echo "No compiled IPK package found for ${target_app_name}, please check if compilation failed!"
    exit 1
fi
echo "Check passed, start scp uploading..."

scp ${target_app_ipk_path} ${router_ssh_path}
if [ $? -eq 0 ]; then
    echo "Compilation and Upload Done."
    exit 0
else
    echo "Upload failed, please try manually or check your router path."
    exit 1
fi
