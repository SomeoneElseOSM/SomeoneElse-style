designation-style
=================

This is an osm2pgsql "style.lua" that causes the "standard" OSM map style to render England/Wales access "designations" in preference to highway or tracktype.

The "standard" stylesheet contains rules for different sorts of tracks (tracktype=grade1 - grade4), but doesn't contain rules for English/Welsh rights of way designations ("public_footpath" etc.).

The changes here do the following:

1. Render any non-designated footway, bridleway or track as "path" (grey dashes in the "standard" style)
2. Render anything designated as "public_footpath" as a "footway" (dotted salmon)
3. Render anything designated as "public_bridleway" as a "footway" (dotted green)
4. Render anything designated as "restricted_byway" as a "grade4 track" (dashed and dotted brown).
5. Render anything designated as "byway_open_to_all_traffic" as a "grade3 track" (dashed brown)
6. Render anything designated as "unclassified_county_road" as a "grade2 track" (longer dashed brown)

These changes do mean that the the resulting database isn't any use for anything other than rendering, but they do allow designations to be displayed without any stylesheet changes.  Also, some information is lost in the process (e.g. track or steps vs path).

Usage
-----
Previously I'd do something like this to load an OSM extract into a rendering database:

    osm2pgsql --slim -d gis -C 2000 -k --number-processes 1 /path/to/osm_extract.osm.pbf 

Instead I'll now do the following:

    osm2pgsql --slim -d gis -C 2000 --number-processes 1 --tag-transform-script /path/to/designation-style/style.lua --hstore-all /path/to/osm_extract.osm.pbf 

The rules in the new "style.lua" are used in place of osm2pgsql's native processing.  See [the answer to this help question](http://help.openstreetmap.org/questions/28465/osm2pqsql-and-lua/28466) and and [osm2pgsql's lua README](https://github.com/openstreetmap/osm2pgsql/blob/master/README_lua.md).

