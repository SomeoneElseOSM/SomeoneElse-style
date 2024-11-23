#!/bin/bash
# -----------------------------------------------------------------------------
# taginfo_compare.sh
#
# Copyright (C) 2023-2024  Andy Townsend
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
#
# ----------------------------------------------------------------------------
# Taginfo projects
# https://taginfo.openstreetmap.org/projects#projects
# list what OSM projects use what OSM keys and values, in a .json file.
# Mine are:
# 
# Raster maps:
# https://github.com/SomeoneElseOSM/SomeoneElse-style/blob/master/taginfo.json
#
# Mkgmap maps:
# https://github.com/SomeoneElseOSM/mkgmap_style_ajt/blob/master/taginfo_ajt03.json
# and a much simpler version closer to "normal" mkgmap maps:
# https://github.com/SomeoneElseOSM/mkgmap_style_ajt/blob/master/taginfo_ajt02.json
#
# Vector map export of sve01 schema:
# https://github.com/SomeoneElseOSM/SomeoneElse-vector-extract/blob/main/resources/taginfo_sve01.json
#
# There isn't a taginfo file for the svwd01 map style in
# https://github.com/SomeoneElseOSM/SomeoneElse-vector-web-display/tree/main/resources
# mostly because it pretty much displays everything in the sve01 schema,
# and the keys and values in the data it works with don't match OSM any more.
#
# For each of these, actual tag usage can be checked with
# https://github.com/SomeoneElseOSM/SomeoneElse-style/blob/master/report_tag_usage_changes.sh
# to detect when certain key and value combinations no longer appear in OSM at all.
# In each project, the key/value combinations that no longer appear in OSM 
# (but are retained because people might add them) have a comment at the 
# start of the description to indicate that.
#
# Of these, the raster map one is the main one, created initially from
# https://github.com/SomeoneElseOSM/SomeoneElse-style/blob/master/style.lua
# using
# https://github.com/SomeoneElseOSM/SomeoneElse-style/blob/master/taginfo_lua_genkeylist.sh
# and then manually edited to reflect changes in e.g. .mml and .mss files.
#
# ----------------------------------------------------------------------------
# This script is designed to compare other taginfo files to that.
# 
# The sve01 vector schema is a reimplementation of the schema used for the
# raster map style, so should be broadly identical.
#
# The ajt03 mkgmap schema tries to implement the same features, but the
# display mechanism on Garmin devices (and the added search functionality)
# means that there are some differences - it's easier on Garmin to handle 
# "any value" for certain keys, meaning fewer explicit values handled.
#
# The ajt02 mkgmap schema isn't related to the others and doesn't concern 
# us here.
#
# ----------------------------------------------------------------------------
# In order to compare files we need to create a version of the relevant 
# taginfo .json file for each schema without any of the descriptions so that 
# the files can then be compared with "diff".
# "~/temp" is used for the temporary copies for comparison.
# First get the file for the main raster style
# ----------------------------------------------------------------------------
TAGLIST0=~/src/SomeoneElse-style/taginfo.json
grep '"key"' ${TAGLIST0} | sed 's/"description":.*//' > ~/temp/taglist0.txt
#
# ----------------------------------------------------------------------------
# and then compare with sve01
# ----------------------------------------------------------------------------
TAGLIST1=~/src/SomeoneElse-vector-extract/resources/taginfo_sve01.json
grep '"key"' ${TAGLIST1} | sed 's/"description":.*//' > ~/temp/taglist1.txt
#
diff ~/temp/taglist0.txt ~/temp/taglist1.txt | wc
diff ~/temp/taglist0.txt ~/temp/taglist1.txt | more
