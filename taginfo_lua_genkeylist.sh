# ------------------------------------------------------------------------------
# taginfo_lua_genkeylist.sh
#
# Copyright (C) 2018-2024  Andy Townsend
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
# -----------------------------------------------------------------------------
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
STYLEFILE=/home/ajtown/src/SomeoneElse-style/style.lua
grep 'keyvalues\["' ${STYLEFILE} | sed "s/\].*//" | sed "s/.*keyvalues\[//" | grep -v "z_order" | sort -u | sed "s/^/    \{ \"key\": /" | sed "s/$/, \"description\": \"qqq\" }/"

