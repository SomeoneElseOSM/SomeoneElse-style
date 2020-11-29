# ------------------------------------------------------------------------------
# This script extracts key names used by SomeoneElse-style/style.lua
# for use in a taginfo project file.
#
# The results are designed to be compared with taginfo_lua_nodesc.txt to see
# what has changed, and those changes should then be manually changed in
# taginfo.json.  The change has to be manual as the "description" in the .json
# can't be generated from anywhere.  Changes to the use of keys in the .lua
# will also require changes to the json, and this must also be done manually.
#
# Example taginfo project file with lots in it:
# https://raw.githubusercontent.com/mapbox/mapbox-navigation-ios/master/taginfo.json
# ------------------------------------------------------------------------------
STYLEFILE=/home/renderaccount/src/SomeoneElse-style/style.lua
grep 'keyvalues\["' ${STYLEFILE} | sed "s/\].*//" | sed "s/.*keyvalues\[//" | grep -v "z_order" | sort -u | sed "s/^/    \{ \"key\": /" | sed "s/$/, \"description\": \"qqq\" }/"

