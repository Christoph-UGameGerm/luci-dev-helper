#!/usr/bin/bash

target_app=
openwrt_path=
router_ssh_path=

# Usage information
usage() {
    cat << EOF
Usage: $(basename $0) [OPTIONS]
Options:
    -t TARGET_APP    Target application path (default: ${target_app})
    -p OPENWRT_PATH  OpenWrt environment path (default: ${openwrt_path})
    -r ROUTER_PATH   Router SSH path (default: ${router_ssh_path})
    -h              Show this help message

Example: $(basename $0) -t feeds/local/luci-app-example -p ~/openwrt -r root@192.168.1.1:~
EOF
    exit 1
}

# Parse command line options
while getopts "t:p:r:h" opt; do
    case ${opt} in
        t)
            target_app=$OPTARG
            ;;
        p)
            openwrt_path=$OPTARG
            ;;
        r)
            router_ssh_path=$OPTARG
            ;;
        h)
            usage
            ;;
        \?)
            usage
            ;;
    esac
done

if [[ ! -d "${openwrt_path}" ]] then
    echo "Indicated OpenWrt env path does not exist, please check the script"
    exit 1
else if [[ ! -d "${openwrt_path}/${target_app}" ]] then
    echo "Indicated Package does not exist under OpenWrt env, please check \
    \'feeds list\' for install status or \'make menuconfig\'"
    exit 1
fi

cd ${openwrt_path}
make package/${target_app}/{clean,compile} V=s

$target_app_name=$(basename ${target_app})
$target_app_ipk_path=$(find ./bin/packages/ -type f -name "*${target_app_name}*.ipk" | head -n 1)

if [ -z "$target_app_ipk_path" ]; then
    echo "No compiled IPK package found for ${target_app_name}, please check if compilation failed!"
    exit 1
fi

scp ${target_app_ipk_path} ${router_ssh_path}
echo "Compilation and Upload Done."
exit 0
