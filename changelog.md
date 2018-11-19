# Changes made to this rendering
This page describes changes made [here](https://github.com/SomeoneElseOSM/SomeoneElse-style), [here](https://github.com/SomeoneElseOSM/SomeoneElse-style-legend) and [here](https://github.com/SomeoneElseOSM/openstreetmap-carto-AJT), visible [here](//map.atownsend.org.uk/maps/map/map.html).

<!---
## As yet unreleased
not yet on map.atownsend.org.uk
--->

## 20/11/2018 release
<!---
not yet on UbuntuVM51
--->
Changed text-dy on vacant shops to work around a new Mapnik issue (required because of move to Ubuntu 18.04 only).
Added "operator" etc. on all pubs, not just generic ones.
Fixed bug in legend which suppressed narrow BOATs.
Render some protect classes as nature reserves.

## 22/10/2018 release
Move to new larger and faster "map" server.

## 20/10/2018 release
<!---
On both Hetzner and UbuntuVM51:
--->
Added support for more tagging of waterfalls.
Made grass aprons appear as grass; made grass runway width more reasonable at z14 and z15.
Render unnamed "amenity=biergarten" as "leisure=garden; garden=beer_garden", since that's likely what they are.
Render tax advisors as accountants.
Remove greyed-out effect from permissive parking.
Added home care offices as office.
Processed operator and brand on animal shelters etc.
Single-node stepping stones are now handled using a separate icon.  Ways are still handled as fords.
Added telescopes to list of ways that get building tags added.
Don't display the "private" fill on driveways if the driveway itself is not shown.
Accept "tunnel=flooded" as a valid tunnel tag.
Display public bookcases (even those not in former phone boxes) and add to legend.  Treat telephone_box as telephone_kiosk.

## 09/09/2018 release
Added "shop=mattress" to homeware shops list.
Move non-money-losing "gaming" shops out of the "bookies" list.
Render "location=underground" waterways as tunnels.
Render "maxwidth" on tertiary roads as if "width" was set.
Render canal spillways and headraces as drains.
Render excrement bag vending differently from ticket machines.
Display name and/or operator and/or brand on vending machines.
Render windmill buildings and former windmills as windmills.
Render "two sided embankments" from z14 rather than z13.
Render maypoles from z16 and use a larger icon from z18.
Re-added horse mounting block code and added "amenity=horse_dismount_block".
Render ruins=yes as building=ruins.
Don't display alleged biergartens from z16.  In the UK, many are mistagged pub beer gardens.
Added about button to example map.

## 24/08/2018 release
At z13, don't show linear barriers  or nature reserve / national park boundaries or ditches (but still show drains and streams).

## 14/08/2018 release
Don't show underground railway platforms (stations are still shown of course).
Added icon for water monitoring stations.
Show unpaved service roads and residentials as tracks.
Show electric bike shops as bike shops.
Render loc_ref on roads if appropriate.
Add more spellings of "official" refs.
Add icon for bicycle repair station, compressed air.
Add missing z_order setting for MTB routes.
Only render tree names from z18.
Made LDP dots smaller at z13 and z14.
Removed max zoom on which large_aerodrome name is displayed.
Render lcn_ref as something on nodes
Added "service" to roads to handle "official" and unsigned refs and names on.
Resolved order of byway/gallop code to process prow_refs etc. should any exist.
Added more comments to the "grade" logic.
Moved prow_ref logic to below each designation.
Reduced set of highways for which designation takes precedence (previously e.g. trunk_links turned into bridleways).
Added military to set of "private" roads.
Added many more "edge case" designations, including ones with semicolons where something is on the list of streets and has another designation.

## 08/08/2018 release
Made ferry routes less prominent from zoom 11.
Suppress "historic" for amenity=pub.
Added IATA code to large aerodromes.
Render man_made=spillway areas as water.
Render brand on offices.
Render unsigned "official" road refs and names in brackets, after a signed name (if any), in the same way that PROW refs are handled.

## 22/07/2018 release
Changed the icons for women's toilets to include F rather than W to better distinguish it from M.
Added icon for emergency=life_ring.
Added "emergency" to the "brand/operator" logic (so that "RNLI" shows) and expanded the "emergency" office list.
Added beach safety signs to the information=board list.
Added icon for music, motorcycle, farm, toy, tattoo and photo shops.
Added icon for grit_bin.
Extended brand and operator logic to doctors and pharmacy.
Show skate parks etc. (that aren't skate shops) as pitches.
Added maypoles.
Added gas and electric street lamps.
Render sport=yoga as leisure.
Render credit union as bank.
Render railway platform names, suppress disused platforms, and use platform 
ref to create the name if set.

## 28/06/2018 release
Fixed a [bug](https://github.com/SomeoneElseOSM/SomeoneElse-style/issues/4) where gendered hairdressers (or other features, actually) could render as male or female toilets.
Added icon for shop=art, shop=computer and related shops.
Resolved a layer calculation issue to fix [this problem](https://github.com/SomeoneElseOSM/SomeoneElse-style/issues/5).

## 12/06/2018 release
Added icons for different sorts of historic=memorial and similar objects (e.g. obelisks).
Added more icons for male and female toilets.
User operator / brand if set instead of name on shops and pubs.
Added laundry, pet shop, travel agent and bookshop icons.
Show the operator of woods and forests in brackets after the name if available.
Change the dot frequency for long distance horse routes to match the walking route frequency instead of the cycle route frequency, so that more dots are visible.
Added names for wetland.
Added another key to translate for horse mounting blocks.
Added "unclassified_road" as a designation to be processed as "unclassified_county_road" etc.
If a former pub is a shop/hotel, render it as a shop/hotel.
When checking if a pub is also a hotel, also check for B&Bs etc. (and render as pub).  Do this test before the "real_ale" logic so as not to exclude some pubs from it.
Render MTB trails like cycle routes but with the dots and text closer together.
Added icon for various alcohol shops, mobile phone and confectionery shops.
Moved "shop=party" to "gift" and consolidated "spa" as "beauty".
Added "motor_accessories" as "car_parts", "petfood" as "pet", "guns" as "shopnonspecific", "ship_chandler","chandlers","kitchen;bathroom_furnishing" as "furniture", "tan","nail_salon" as "beauty", "locksmiths" as "shopnonspecific" and "christmas" as "gift".
Added boat_rental as nonspecific leisure.

## 28/05/2018 release
Render the areas of police and fire stations in line with other similar areas (unnamedcommercial).
Render playground sandpits as sand.
Render names for heathland from zoom 13.
Change default Noto font to one that works better and avoids a "double spaced" effect.
Increased text wrap width for various names.
Added more bingo hall tags as "leisure".
Add a special case of railway=halt for Manulla Junction.
Added nightclub and pay toilets to legend.
Added icon for "amenity=musical_instrument", and also use that for pub and station pianos.

## 29/04/2018 release
Increased the tags rendered as "clock tower".
Render tunnel names if available.
If a bar doesn't serve real ale, render as a bar not a lager pub.
Render pipelines (with names) and add to legend.
Render non-private bicycle_parking, bicycle_rental and car_sharing as less blue.
Distinguish pay and free toilets.
Render disused shops with an "old_name".

## 08/04/2018 release
More detail about church spires and towers and other towers; better icons.
Split recycling centres and bins.
Added office=research_institute to list of rendered offices.
Added icon for shop=deli.

## 04/03/2018 release
Treated "fence_type=hedge" as "hedge".
Made tramlines less prominent betwen zooms 13 and 16.
Added icon for defensive and observation towers.
Render ha-has as walls (there's usually a wall, even if recessed).
Use brand and/or operator on tourism=hotel.
Treat landcover=trees as "here be trees" and landcover=grass as "here be grass".
Render non-private toilets as less brown.
Use illumination tower icon for "lighting" as well as "illumination".
Added rendering for clock towers, aircraft control towers, radar towers and firefighter training towers.  
Also church towers and spires.

## 10/02/2018 release
Added support for some common golf tags.
Added icon for horse mounting blocks and translated the most common tags to use it.
Added icon for illumination towers.
Treat access=no as access=private when deciding whether to ignore "no/private" on a footpath.
Treat access=customers as access=destination.
Made meadow significantly less green.
Removed access=permissive rendering on selected roads and footpaths.
Changed destination colour and added to tracks etc.
Made "booth telephone" icon telephone larger.
Added amenity=bbq.
Added support for intermittent rivers and streams.
Added icon for amenity=charging_station.
Added icon advertising columns.

## 17/01/2018 release
Added Sustrans route markers to legend.
Added rendering support for railway and waterway embankments (actually, waterway embankments are rare and some may be mistagged)..
Don't treat existing bridges or tunnels as embankments.
Manually map some invalid layer tags to "what the mapper probably meant".
Ensure "negative layer" bridges are treated as bridges.
Render red phoneboxes as such, with an appropriate icon for telephone, library, defibrillator, etc.  Also added to legend.
Even out town and suburb name sizes at z12-z14 to make the distinction clearer.
Added jersey_barrier to the list of linear features treated as wall.
Added icon for fire extinguisher.

## 06/01/2018 release
Added embankments and fords to legend.
Added footway etc. tunnels and bridges to legend.
Added more linear barriers to legend.
Render bridges on dismantled railways.
Added more waterway tag combinations to legend.
Render sustrans mileposts as indigo "information" icons with an icon based on the design of the milepost type.

## 27/12/2017 release
Extended the range of what counts as a "ventilation shaft".
Ensure that "agricultural" etc. are changed to "private" before "private is checked against "designation".
Remove names from footpaths explicitly tagged as sidewalks (the name will be on the road).
Render amenity=archive as a government office.
Treat embankment=yes as man_made=levee/bridge=levee and tidied up or added embankment rendering on roads.
Made non-designation steps a lot narrower to make them less "in your face" on the map.
Made designation steps a little bit narrower also.

## 19/12/2017 release
Render building=canopy as building=roof.
Change name of motorway junctions to black (to match the ref).
Render ncn and rcn in a similar way to nwn, rwn and lwn, except use the ref as the label (unless National Byway, in which case the name is needed to inclde loop info).  Also nhn, and add to legend.
Render highway=unsurfaced and gallop as pathwide (track).
Render highway=waymarker as tourism=information;information=route_marker.
Moved highway=road to a lower z_order.
Render linear cycle barriers as fence.
Removed catch-all for linear (but not area) barriers.
Added linear barriers to legend.
Long fords on tertiary and below are now rendered with a water-coloured casing.

## 16/12/2017 release
Added specific icons for shop=bookmaker and shop=furniture.
Map man_made=monument to historic=monument (handled below) if no better tag exists.
Added icons for barriers door, toll_booth.
Treat linear unknown barriers as "fence" and point ones as "bollard".
Treat linear unknown tank traps as "wall" and point ones as "bollard".
Treat barrier=sally_port and various other gate types as gate.
Mapped barrier=border_control as lift_gate.
If a pedestrian crossing includes traffic lights, render as traffic_signals.
Moved historic=ruins to the non-building historic rendering.
Moved node barriers to POI area of legend and moved ford, passing place etc. up a row.
Tidied up linear barriers, made fence and other default ones explicit, made wall wider.
Made hedge a proportionate width at >z20, also increased fence and wall.  
Added cattle_grid rendering.
Made larger versions of some point barrier symbols to fit nicely into the larger linear barriers.

## 11/12/2017 release
Ensure that wind turbines are shown as wind turbines (and not towers) at all zoom levels.
Remove "private" indication on path and pathwide if foot=yes or foot=permissive.
Render layer/level 0 highway=corridor as footways.  Non-ground corridors omitted (it'd get messy); indoor=corridor omitted (area highway features mostly supressed in this style).
Process some non-carpeted "floor:material" values the same way as "description:floor".  "floor:material" is extensively used in indoor tagging and it makes sense to consider it here too.
Added fish farms (which may be tagged in several ways) as commercial landuse.
Added specific icon for leisure=fitness_station.
Added support for more shop tags.
Apply changes from parent repository from [pull 814](https://github.com/gravitystorm/openstreetmap-carto/pull/814) and then reapply changes from [here](https://github.com/SomeoneElseOSM/openstreetmap-carto-AJT/commits/master/water.mss) .
Changed motorway junction refs to black, as these are used on other roads too.
Differentiate between railway=disused/abandoned/dismantled etc.
Added specific icons for shop=beauty and shop=gift.

## 03/12/2017 release
Added support for more shop tags.
Render craft=counsellor.
Render landuse=religious.
Render railway=milestone.
Render waterfall as weir/sluice_gate (blue dot or grey line depending on whether node or way).
Moved landuse=landfill from construction to something nearer industrial.
Used a better shopmobility icon.
Rendered bus_guideway at zooms 10 and 12 as a type of "railway" with a less in-your-face colour, so that bridges and tunnels are handled correctly.
Added bus_guideway to legend.

## 28/11/2017 release
Added support for more historic tags.
More tweaks to historic rendering,  Added a slight background.
Use brand and/or operator on amenity=fuel.
Move craft=bakery to "industrial" (shop=bakery has its own shop icon).
Added more shop renderings, including different ways of tagging empty shops.

## 21/11/2017 release
If "name:historic" is set and name is not, use "name:historic" on "waterway=derelict_canal"
Add "newsagent;toys" to list of valid newsagents (handled as convenience).
If bridge_ref or bridge_ref is set on e.g. a canal bridge, append to road name in brackets.
Added name to waterway=weir ways.
Added craft= and industrial=distillery as industrial landuse.
Added support for more historic tags.
Moved some historic area tags (castle, manor) to non-building based on usage.
If a cairn has been mapped at a peak, render the peak.

## 16/11/2017 release
Treat access=agricultural, forestry and delivery as private (as "permit" already is).
Added various "historic" items, so that names get rendered and areas rendered as buildings (if appropriate).

## 11/11/2017 release
Added support for man_made=bunker_silo as "not quite a building" (roof).
Added new icon for boundary stones.
Changed lua processing to suppress "non-multipolygons" such as Marble Arch.  Arguably a workaround to bad data.

## 23/10/2017 release
Added support for boundary stones.
Added sluice gates (named, and as infrastructure).
Like trail_visibility, suppress some demanding sac_scale paths if no designation.
Treat waterway=fish_pass like waterway=drain.
Added private parking to legend.
Changed parking to use a .png and added support for "fee parking".

## 11/10/2017 release
New symbol for route markers (as distinct from guideposts et al).
Added icon for shopmobility and selected for it in style file.

## 01/10/2017 release
Added more leisure values.  
Added more mistaggings and aliases for e.g. swimming_pool.
Updated legend with existing and new leisure values.

## 27/09/2017 release
Added public_bath to nonspecific leisure.
Added support for names on barriers.
Various legend updates including cars, education, rail and aeroway.
Added shop=milk and amenity=van_rental.
Remove man_made=tower from wind turbines.
Added healthcare=therapy, various tutoring places.
Treat access=permit as access=private.
If a street has different names on each side, render it.
Render natural=fell as natural=heath ("generic upland").
Added shop=milk and amenity=van_rental.

## 22/09/2017 release
Changed survey point et al names to black.
Changed embassy to brown and changed similar brown z17 names to the same font.
Changed ATM to use operator if set as the name.
Changed lighthouse to black.
Only render bus_stop on joint bus_stop/waste_baskets and fix rendering of bus_stop name in the legend.
Render names for bicycle_rental, bicycle_parking etc.
Changed water tower to render at z15 and added name.
Changed other classes of points to render similarly (see the rows in the legend) and added names.
Changed ventilation_shaft to man_made.

## 18/09/2017 map layer change
Added German Style layer to [this map](https://map.atownsend.org.uk/maps/map/map.html)

## 14/09/2017 style updates
Added more feature names.  See Legend for details of current coverage.
Moved more features (e.g. slipway) to amenity brown.

## 13/09/2017 release
Added road names for primary sidewalk and verge.
Added more prow_ref names.
In legend, split primary, trunk and motorway into sidewalk and trunk etc.
Added a couple of prow_ref to show up on the legend.
Added a "legend generator" to generate the "pub" legend and use that legend in reload scripts.
Add support for parcel lockers.
Add building tag to lighthouses.

## 07/09/2017 release
Added support for left luggage lockers.

## 04/09/2017 release
Added support for sidewalks and verges on primary roads.

## 29/08/2017 style updates
Further improved road rendering at z13-z19.  
Added more granularity, including explicit z18 settings.
Adjusted the size of verges to allow for the extra prominence of the colour.
Reduced width of residential/unclassified at high zooms.
Reduced service casing.

## 28/08/2017 style updates
Removed rendering of verges on secondary roads at z12.
Split verge width from sidewalk width.  
Reduced sidewalk width slightly at z13 and reduced verge width significantly at z13.
Rendered sidewalks/verges for unclassified / residential.

## 26/08/2017 release
Welsh-speaking areas rendered using "name:cy" in place of "name; Scots Gaelic areas similarly use "name:gd".  The rest of England, Wales and Scotland use "name:en"; Ireland and Northern Ireland use "name".  See [here](https://github.com/SomeoneElseOSM/SomeoneElse-style/blob/master/update_render.sh) for the script that handles this.
Added "unmade_road" to the list of handled designations for UCR.
If name:en exists but name does not, use name:en.
Added another spelling of PNFS.
If "bridge_name" or "bridge:name" exist, render those on bridges in place of "name".
If it exists, append "lock_ref" to the end of "lock_name" or "name" in brackets.
Added more signs to be displayed using the "information=sign" icon.
Added various "tourist" values so that they show in green as nonspecific leisure.
Improved rendering of holiday cottages and synonyms.

## 17/08/2017 release
Car washes now have their own icon
Added craft=roofer to the "house fixing" group icon.

## 08/08/2017 release
Added support for shop=tourism, office=advertising, shop=fuel.
Added support for waterway=aqueduct.
Show parking spaces as private parking areas (which actually mirrors usage in UK).
Added support for a couple of variations of pet grooming.
Improvements car repair display and added icon for car parts and synonyms.
Added support for more fast food cuisines.
Added support for leisure=club, and sailing and sport clubs.
Added icons for bicycle parking, waste_basket.

## 27/06/2017 release
Further improvements to shop rendering based on their use according to taginfo.
Change aerodrome tagging to not show small, disused or military airports.
Change runway tagging to show grass strips less prominently.
Show flood banks and embankments where there's no highway on top.
Show flood banks and embankments in some easy-to-categorise cases where there is a highway on top.
Show different sorts of information - board, office, etc., and add to legend.

## 17/06/2017 01:49 release
Further improvements to shop and office rendering based on their use according to taginfo.
Added display of defibrillators at high zooms in healthcare red.
Added more fast food icons.
Support more bridge and tunnel types and "man_made=bridge".

## 05/06/2017 23:08 release
Render pubs with a microbrewery with a characteristic icon and add to legend.

## 29/05/2017 18:25 release
Added more shop and leisure types.
Added different sorts of milestones.
Changed "fast food" display so that different but similar icons are used for different cuisine types.
Made highway=road less prominent.
Improved rendering of long distance paths.
Added name for sundial icon.
Added map legend based on [this](https://github.com/SomeoneElseOSM/SomeoneElse-style-legend) repository.

## 03/04/2017 00:43 release
Improvements to shop and office rendering based on their use according to taginfo.
Added support for emergency phones.
Added different sorts of lesser-used waterways.
Added the display of roadside verges (green as opposed to grey for sidewalks).
Change fonts use to "Noto" to work with non-latin characters.

## First map.atownsend.org.uk release - 19/02/2017
Added different but similar icons for different types of pubs.
Added support for vacant shops.

