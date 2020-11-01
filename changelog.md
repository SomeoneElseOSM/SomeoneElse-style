# Changes made to this rendering
This page describes changes made [here](https://github.com/SomeoneElseOSM/SomeoneElse-style), [here](https://github.com/SomeoneElseOSM/SomeoneElse-style-legend) and [here](https://github.com/SomeoneElseOSM/openstreetmap-carto-AJT), visible [here](//map.atownsend.org.uk/maps/map/map.html).

## As yet unreleased
Display various playground items from zoom 18.

<!---
On Hetzner server map.atownsend.org.uk:
--->
## 01/11/2020
Added support for more bad trail_visibility values, which remove non-designation paths and tracks from the map.
Render trail_visibility=intermediate with wider spaces dashes on paths and tracks.
Render trail_visibility=intermediate, =bad and =no with wider spaces dashes on wide and narrow bridleways and footpaths.
Added less visible paths, tracks and wide and narrow bridleways and footpaths to the legend.
A couple of hidden changes were also made, to reduce references to values in style.lua after they have been changed to something else, and changing output values for the .mss file to have different values (e.g. "bridlewaynarrow") to the value in the input file (which might be "bridleway").  This last change doesn't affect roads, which keep their original values in more situations.
Render "overgrown=yes" as if the trail_visibility was intermediate.
Made "barracks" less red.

<!---
On UbuntuVM51
--->
## 25/09/2020
Added "access:covid19=no" as a "closed due to Covid 19" tag for pubs.
Added international walking networks to ldpnwn - I have found one in the UK that is explicitly signed.  Previously they were ignored because I was aware of none that were signed; they are mostly just a fantasy in the same way that "E" roads are in the UK.  The "name:signed" and "ref:signed" tags will still be honoured.
Extended test for Hogweed following undiscussed but well-meaning tagfiddling changes to values in UK.
Added support for public footpath, bridleway and byway closures - keep the footpath, bridleway or byway rendering, but add the "private" overprint.

## 13/08/2020
Render "closed due to Covid 19" pubs as similar to. but not quite the same as, normal disused pubs.
More beer garden and outside seating edge cases.
Updated legend to include outside seating and beer gardens on pubs and also disused and "closed due to covid" pubs.

## 27/07/2020
Render "guide_type=intermediary" guideposts like route_markers.
Render beer garden ("green floor at right") and outside seating ("black floor at right") on a selection of pubs.

## 11/05/2020
Render pharmacy=yes where it doesn't clash with another amenity tag.
Suppress names on riverbanks where mapped as "natural=water; water=river" to avoid clash with the name of the actual river.
Rendering AEDs in disused:amenity=telepone.
Render shooting ranges with red "military" overlay.
Render indoor_golf as leisure.
Change fill for proposed and construction rail tunnels from grey to silver to show HS2 tunnels slightly more clearly.
If something is tagged both as a supermarket and a pharmacy, remove the tag for the latter.

## 11/04/2020
Render golf=cartpath as path rather than highway=service if that tag is set.
Render variously tagged showgrounds as meadows.
Render shop=meditation as "woo".
Render woodland with an unexpected landuse tag as woodland.
Render various synonyms for leisure=common.

## 23/02/2020 release
Render wheelchair tags on rarer pubs as part of the bar at the bottom of the icon.
Render wheelchair tags on bar, cafe, bank, pharmacy in the same way.
Update legend to include wheelchair tags on pubs.
Render craft=sawmill and industrial=sawmill as industrial, including the name on nodes.
Render craft=electronics_repair (and other keys used with that value).

## 16/02/2020 release
Render wheelchair tags on most pubs as part of the bar at the bottom of the icon - green for yes, yellow for limited and red for no.
Render the names of telescopes and radio telescopes.
Render various other sorts of ruined buildings as building=ruins.
Render named building nodes.
Render natural arches in the same way as bridges - the same as building=roof.  Names (even for nodes) are also displayed.
Render highway=rest_area as amenity=parking.
Render railway=traverser as building=roof.  It's not ideal, but it is better than nothing.
Also render animal=horse_walker as building=roof.
Treat animal=shelter as amenity=animal_shelter, as that is how it is used.
Look at more tags to suggest farmgrass, such as animals kept there.

## 17/01/2020 release
More synonyms for tractor sales added.
Added rendering for natural=saddle.
Added landuse=paddock as a synonym for "farmgrass".
Render solar panels as "roof", not as other power generators.
Render leisure=inflatable_park as other leisure places.
Render leisure=adventure_park as beach_resort.
Display big observation towers from zoom 14.
Render non-historic aeroplanes and helicopters as buildings.
Render coachbuilders as car repair.

## 21/12/2019 release
Render shoulder as if a road has a sidewalk on primary, secondary, tertiary, unclassified and residential.  It's not perfect - if you are walking along a shoulder you'll want to watch out for farm traffic, but it's safer than walking along a normal road.
Added more synonyms for hotels, caravan_sites, beauty and healthcare places.
Render agricultural meadows and grassy farmland with a colour half-way between existing farmland and meadow.

## 21/11/2019 release
Remove "tourism" tag from monasteries and other historic buildings so that they are displayed as "historic".  Also trees and boundary stones.
Fixed a rendering issue where tourist attractions could get rendered as unnamedcommercial when other tags were also present.
Display tall masts from zoom 12, with the names from zoom 13 (as opposed to 15 and 17 for other masts).  Also tall chimneys from zoom 13.
Render various designations as e.g. national park, nature reserve, etc.
If a forest has been mapped as a military danger area because shooting takes place there, just show as forest.

## 04/11/2019 release
Remove extra landuse tagging on some "tourist" values.

## 03/11/2019 release
Handle landuse combinations better - remove duplicate names in more cases.
Make valley repeat text less frequent at high zooms.
Display big peaks from zoom 10, with the name of prominent ones from zoom 11, and the name of all big ones from zoom 12.

## 26/10/2019 release
Added more "car parts" combinations.
If we're allowed to walk somewhere but general access isn't allowed, then don't render as "private"
or "destination", and don't degrade the display of service roads because they are driveways.
Also add lnduse=industrial to substations.
Added small text for natural=valley.

## 10/10/2019 release
Render barrier=flood_wall as wall.
Don't render the names of unsigned long-distance foot, horse, cycle or mtb routes, as unfortunately a number of "routes from books" seem to be making their way into OSM and don't exist on the ground.
Remove "tourism" tag from various towers that are already rendered as towers, and on some other amenity and historic items.
If former_name is set, use it like old_name.
Handle "soft_play" like "indoor_play".
Choose which to render between some tourism and amenity tags.
Render names on cliffs, embankments, levees, walls and linear gates.
Render the names of canals more frequently along their length.
Change private footways, tracks etc. to be more obviously different from non-private ones.
Render "disused:building" as roof etc., as most seem to be still something.
Added more rental-tagged things.
Render more "covered" values as "yes" (in a similar way to "tunnel").

## 28/09/2019 release
Render landuse=college_court as landuse=grass.
Render man_made=geoglyph as historic=monument.
Render parking positions at airports (only if mapped as nodes, to avoid duplication).
Render hazard=plant (Hogweed) as a historic dot.
Don't render service roads with foot=yes as private.
Treat "was:" as "disused:".
Render climbing boulders etc. from zoom 17.

## 15/07/2019 release
Render amenity=feeding_place as a roof, if not already a building.
Likewise for bus shelters.
Don't use the "shelter" icon on animal field shelters (it's already removed for bus shelters).
Include "support=tower" in those clocks rendered as clock towers.
Render pedestal- and similar mounted clocks.
Render fountains.

## 16/05/2019 release
Append "air quality" to name of air quality monitoring stations.

## 23/03/2019 release
Render shop=embroidery as a shop.
Add "artwork" to the list of former telephone box uses.
Append "sewage" to name of wastewater plants.
Render man_made=footwear_decontamination
Add a "hotel roof" to cafes and bars with accommodation.
Treat office=marriage_guidance as an office.
Treat vacant offices like vacant shops.
Render man_made=village_sign.
Make private tracks less prominent.

## 23/02/2019 release
Render names on vending machines.
Render brand and operator on cafes, restaurants and vending machines.
Try and make electricity substations more obvious.
Detect more parcel lockers.
Add a "hotel roof" to pubs with accommodation, and restaurants with rooms.
Don't render private cafes or restaurants, in the same way that private pubs are not rendered.
If a cafe or restaurant is rendered as serving real ale, also include the "F" for food.
Render operator/brand in brackets on man_made objects.

## 06/02/2019 release
Include micropubs mapped as "pub=micro".
Improve and consolidate disused:pub detection logic to not miss some new uses.
Add "pub=yes" (on e.g. hotels) to the pub detection code.
Detect more italian combinations as pizza places.
Render Jehovah's Witness places of worship as generic religious rather than using a cross.
Render B&Bs that are tagged as a subclass of guest_house as B&Bs.
Render street cabinets that are mapped as ways as buildings.
Render Mineshafts.

## 28/01/2019 release
Change destination and private colours so that private does not clash with footpath.
Add a line showing destination and private to legend.
Only render sensible things via "real_ale".
Render craft=brewery with an icon.
Render micropubs with an indicator in the pub icon.

## 19/01/2019 release
Render some military buildings in red.
Added rendering for various "schools" that aren't actually schools (flying_school etc.).
Golf: added rendering for golf ball washers;
added a slightly different colour for golf greens;
added rendering for golf path features as paths.
Added various "diplomatic"-tagged objects to use the same icon as "embassy".
Treat minarets as church spires.
Moved escape_game and sport=laser_tag from shop to leisure.
Added more tower types (based on contruction).
Render non-public and indoor defibrillators as less opaque, like car parks.
Render prisons and zoos from zoom level 15.
Extend the "ex-pubs" to show as non-ex-pubs to include e.g. offices.

## 24/12/2018 release
Cope with airports with iata codes but no names.
Added Unclassified Unpaved and UCR to legend.
Changed restricted byways to blue.
Added icons for ambulance station, mountain rescue and mountain rescue box.

## 24/11/2018 release
Removed rendering of natural earth boundaries, as map.atownsend.org.uk now has a separate boundary database.

## 20/11/2018 release
Changed text-dy on vacant shops to work around a new Mapnik issue (required because of move to Ubuntu 18.04 only).
Added "operator" etc. on all pubs, not just generic ones.
Fixed bug in legend which suppressed narrow BOATs.
Render some protect classes as nature reserves.

## 22/10/2018 release
Move to new larger and faster "map" server.

## 20/10/2018 release
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

