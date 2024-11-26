# luci-dev-helper
Bash script tools for OpenWrt LuCI App development. Make life easier

### compile_and_upload_core.sh
Allow automated compilation and uploading to target machine via scp.

Avoid a bunch of `cd openwrt` `make .../{clean,compile} V=s` `scp ...`

### i18n_update_helper_core.sh
Allow automated i18n_sync and lmo compilation.

Avoid a bunch of `cd openwrt/feeds/luci/build/...` `i18n-... <luci-app-folder>` and inconsistency in paths dependent across different script.