SomeoneElse-style
=================
[This project](https://github.com/SomeoneElseOSM/SomeoneElse-style) is one of four projects that together are used to create and display the map that is visible [here](https://map.atownsend.org.uk/maps/map/map.html).

The four projects are:

* [SomeoneElse-style](https://github.com/SomeoneElseOSM/SomeoneElse-style) - the lua preprocessing.
* [openstreetmap-carto-AJT](https://github.com/SomeoneElseOSM/openstreetmap-carto-AJT) - the Carto style.
* [SomeoneElse-style-legend](https://github.com/SomeoneElseOSM/SomeoneElse-style-legend) - the data used to generate the map legend.
* [SomeoneElse-map](https://github.com/SomeoneElseOSM/SomeoneElse-map) - a simple Leaflet map.

The map style is designed for "England and Wales-based rural pedestrians".  The example map area also covers Ireland and Scotland.

The links from the top of the [example map](https://map.atownsend.org.uk/maps/map/map.html) are designed to answer common questions like "what is this map" on an ["about"](https://map.atownsend.org.uk/maps/map/about.html) page.  That page also addresses common questions about OSM-based maps (is it accurate and up to date, how do I fix it, what do people know about me if I use this map?).  There's also a [change log](https://map.atownsend.org.uk/maps/map/changelog.html) that shows updates to the map style as they are released.

What the map is designed to show varies by zoom level.  Roughly speaking:

* At the lowest zoom levels only large scale features (coastline, motorways) are visible.
* At zoom level 6 lakes are added.
* Up to zoom level 12 progressively more man-made and natural features are added.  Roads are shown, but not paths and tracks.
* At zoom level 13 foot, bicycle and horse navigation features are added, including public rights of way and named long distance paths.
* Zoom level 14 adds hedges and ditches
* Zoom level 15 adds the first "destination" points of interest (see the [legend](https://map.atownsend.org.uk/maps/map/map.html#zoom=15&lat=-24.99388&lon=135.18359)).
* Higher zoom levels show progressively more detail - zoom in on the legend to see.
* The [example map](https://map.atownsend.org.uk/maps/map/map.html) supports native zoom levels up to 24 because it uses a [forked version of mod_tile](https://github.com/SomeoneElseOSM/mod_tile/tree/zoom) that has been modified to support it.

The general principle is that things that people map should be shown.  Sometimes there are multiple tags used to express the same concept; both forms of tagging will be shown.  Commonly-used typos are also shown as the desired feature.  If there's a conflict between being useful and being pretty, being useful wins.

The "heavy lifting" of converting complicated tagging combinations (for example, pubs with different features) into something to be rendered is done here in style.lua, with the Carto CSS part of the project just rendering one of the couple of hundred of icons it corresponds to.

# Other things here

## Changelog

[Changelog.md](https://github.com/SomeoneElseOSM/SomeoneElse-style/blob/master/changelog.md) is a historical list of what's changed in the three main projects that make up this map style.

## Update scripts

There's a script that gets the latest extract for an area [here](https://github.com/SomeoneElseOSM/SomeoneElse-style/blob/master/update_render.sh).  That gets two areas - by default Great Britain (which has extra name processing performed on it) and Ireland and Northern Ireland (which doesn't). The "extra name processing" involves using "name:cy" in place of "name" in part of Wales, and "name:gd" in place of "name" in part of Scotland.  The file splitting, name tag changing and file recombining is done with "osmosis".

There is also [this script](https://github.com/SomeoneElseOSM/SomeoneElse-style/blob/master/update_carto.sh) that just reloads carto, not the database - useful if the lua preprocessing does not need to be run.

## Taginfo project files

[This file](https://github.com/SomeoneElseOSM/SomeoneElse-style/blob/master/taginfo.json) is designed to tell the [taginfo](https://github.com/taginfo/taginfo-projects) about the tags used within this map style.


