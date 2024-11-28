# luci-dev-helper
Bash script tools for OpenWrt LuCI App development. Make life easier

## [compile_and_upload_core.sh](compile_and_upload_core.sh)
An automation script for building and uploading LuCI applications to a router.

### Features:
- Automatic feeds update and installation
- Targeted LuCI application compilation
- Automatic IPK file location
- SCP upload to target router

### Usage:
```bash
./compile_and_upload_core.sh [OPTIONS]

Options:
    -t TARGET_APP    Target application path (e.g., feeds/local/luci-app-example)
    -p OPENWRT_PATH  OpenWrt environment path
    -r ROUTER_PATH   Router SSH path (format: username@hostname:target_path)
    -h              Show help message

Example:
./compile_and_upload_core.sh -t feeds/local/luci-app-example -p ~/openwrt -r root@192.168.1.1:~
```

Avoid a bunch of `cd openwrt` `make .../{clean,compile} V=s` `scp ...`

### [i18n_update_helper_core.sh](i18n_update_helper_core.sh)
Allow automated i18n_sync and lmo compilation.

#### Features:
- Synchronize translation templates (.pot) and translation files (.po)
- Compile translation files to LuCI-compatible .lmo format
- Automatic path processing to prevent privacy leaks
- Support for separate sync or compile operations

#### Usage:
```bash
./i18n_update_helper_core.sh [OPTIONS] <luci_app_dir> <luci_src_dir>

Options:
    -s, --sync     ONLY sync i18n files (default if no option provided)
    -c, --compile  ONLY compile .po files to .lmo files

Arguments:
    luci_app_dir:  LuCI application directory path
    luci_src_dir:  LuCI source directory path (commonly .../openwrt/feeds/luci)

Example:
./i18n_update_helper_core.sh --s ~/luci-app-example ~/openwrt/feeds/luci
```

Avoid a bunch of `cd openwrt/feeds/luci/build/...` `i18n-... <luci-app-folder>` and inconsistency in paths dependent across different script.