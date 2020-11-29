# ------------------------------------------------------------------------------
# This script extracts key names used by SomeoneElse-style/style.lua
# for use in a taginfo project file.
#
# Example taginfo project file with lots in it:
# https://raw.githubusercontent.com/mapbox/mapbox-navigation-ios/master/taginfo.json
# ------------------------------------------------------------------------------
STYLEFILE=/home/renderaccount/src/SomeoneElse-style/style.lua
grep 'keyvalues\["' ${STYLEFILE} | sed "s/\].*//" | sed "s/.*keyvalues\[//" | grep -v "z_order" | sort -u | sed "s/^/    \{ \"key\": /" | sed "s/$/, \"description\": \"qqq\" }/"

