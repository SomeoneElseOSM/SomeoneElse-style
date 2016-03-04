SomeoneElse-style
=================
This is an osm2pgsql "style.lua" that incorporates "designation-style" but also does a couple of other changes to aid readability.

The rules in the new "style.lua" are used in place of osm2pgsql's native processing.  See [the answer to this help question](http://help.openstreetmap.org/questions/28465/osm2pqsql-and-lua/28466) and and [osm2pgsql's lua README](https://github.com/openstreetmap/osm2pgsql/blob/master/docs/lua.md).

It's designed to work with https://github.com/SomeoneElseOSM/openstreetmap-carto-AJT which is based on a copy of https://github.com/gravitystorm/openstreetmap-carto from Summer 2014 (before a number of problematical changes were made that prevented useful features showing up).

See the readme for designation-style (https://github.com/SomeoneElseOSM/designation-style) for more details about the changes there.

The extra changes here generally fall into one of the following categories:

- Remove some features I'm not interested in to remove clutter (e.g. admin boundaries)

- Remove some features that are misused by some mappers for "colouring in" landuse (e.g. leisure=common).  Obviously it's a shame that this removes *real* commons from the map - suggestions of better solutions here are welcome.  "highway=living_street" is also misused - they're displayed as residential.

- Remove road and path names and refs that are not signed on the ground.  This is another "colouring in" problem.

- Display many more names of things that are part of industrial, commercial and other areas.

- Display abandoned and dismantled railways.  Abandoned railways were removed from OSM-carto because the tag was being misused in some places; they're often major features and *really should* be shown.  Dismantled railways don't really belong on a general-purpose map, but they can be useful if you're trying to make sense of land features, so I've added them too.

- Display proposed railways.  This is mostly to help me identify where the HS2 will go locally - it will be of little benefit elsewhere.

- Display historic canals.  If a "waterway=canal" is like a "railway=rail", then the equivalent to "railway=disused" is "waterway=derelict_canal".  That gets rendered by OSM-carto (but in a barely visible light blue).  What gets used for the canal equivalent of "railway=abandoned" and "railway=dismantled" tends to be "historic=canal".  In the case of "abandoned-equivalent" canals, they're often still major physical features (but with no water), so they're rendered as per "derelict_canal".

- Display some widely-used tags that have been "deprecated" by OSM-carto, like tourism=bed_and_breakfast.

- Fix some display issues that have since been fixed in OSM-carto.  One example of this was that supermarket buildings used to display in pink over the top of pink retail landuse.  OSM-carto has since fixed this by displaying all buildings apart from churches in a light grey; I just display supermarkets as normal buildings.  Some "new features" are also supported (e.g. tree rows as hedges).

- Display some deprecated tags as "best guess" (e.g. highway=byway as highway=track).

- Handle some mappers' "special" tags.  Where it's obvious what something means (e.g. "access:foot" obviously means "foot") just change it.

- Where tags collide, manually choose one of the pair to render (e.g. "amenity=pub" and "tourism=hotel" - I'm far more likely to be looking for a pub than a hotel, so show that symbol).

- For barriers that are essentially either stiles or gates, display as either stile or gate.

- Consolidated shops, offices and leisure facilities so that most or all will get rendered (by openstreetmap-carto-AJT)

- Created a new road class "tertiary_sidewalk" (that will get rendered differently by the "sidewalk" branch of openstreetmap-carto-AJT).  Still a work in progress; z-order handling not there yet.


