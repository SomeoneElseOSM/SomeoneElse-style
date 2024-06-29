# Changes made to this rendering
This page describes changes made in these projects: [SomeoneElse-style](https://github.com/SomeoneElseOSM/SomeoneElse-style), [SomeoneElse-style-legend](https://github.com/SomeoneElseOSM/SomeoneElse-style-legend) and [openstreetmap-carto-AJT](https://github.com/SomeoneElseOSM/openstreetmap-carto-AJT), and visible [on this site](//map.atownsend.org.uk/maps/map/map.html).

## As yet unreleased
Show [tourism=camp_pitch](https://taginfo.openstreetmap.org/tags/tourism=camp_pitch#overview) at high zoom levels.
Added icons for [leisure=golf_course](https://taginfo.openstreetmap.org/tags/leisure=golf_course#overview) and [leisure=sports_centre](https://taginfo.openstreetmap.org/tags/leisure=sports_centre#overview).
Added an icon for [amenity=car_rental](https://taginfo.openstreetmap.org/tags/amenity=car_rental#overview) and van rental.
Added an icon for [amenity=nightclub](https://taginfo.openstreetmap.org/tags/amenity=nightclub#overview).
Added an icon for [amenity=waste_disposal](https://taginfo.openstreetmap.org/tags/amenity=waste_disposal#overview).
Create new icons for [shop=pet_food](https://taginfo.openstreetmap.org/tags/shop=pet_food#overview), [shop=pet_grooming](https://taginfo.openstreetmap.org/tags/shop=pet_grooming#overview), [amenity=veterinary](https://taginfo.openstreetmap.org/tags/amenity=veterinary#overview), [amenity=animal_boarding](https://taginfo.openstreetmap.org/tags/amenity=animal_boarding#overview) and [amenity=animal_shelter](https://taginfo.openstreetmap.org/tags/amenity=animal_shelter#overview).
Added "utilities" list to list of amenities considered for drinking water.
Rearranged the legend so that items better fit categories.

## 25/06/2024
Removed "[amenity=book_exchange](https://taginfo.openstreetmap.org/tags/amenity=book_exchange#overview)", no longer in the data.
Show [bus stands](https://taginfo.openstreetmap.org/tags/highway=bus_stand#overview) as [disused bus stops](https://taginfo.openstreetmap.org/tags/disused:highway=bus_stop#overview) (since you cannot get a bus there).
Show [fire hydrants](https://taginfo.openstreetmap.org/tags/emergency=fire_hydrant#overview) from zoom level 22.
Also fix the display of [mountain rescue supplies](https://taginfo.openstreetmap.org/tags/emergency=rescue_box#overview) in the legend.
Show more characteristic icons for [various sorts](https://map.atownsend.org.uk/maps/map/map.html#18/-24.99494/135.18162) of self-catering accommodation.

## 06/06/2024
Removed "[prow:ref](https://taginfo.openstreetmap.org/keys/prow%3Aref#overview)", no longer in the data.
Detect "[amenity=social_facility](https://taginfo.openstreetmap.org/tags/amenity=social_facility#overview); [social_facility=shopmobility](https://taginfo.openstreetmap.org/tags/social_facility=shopmobility#overview)" as shopmobility.
Delect "[shop=mobility_hire](https://taginfo.openstreetmap.org/tags/shop=mobility_hire#overview)" as shopmobility if the name also matches.
Use various "[produce](https://taginfo.openstreetmap.org/keys/produce#overview)" values to detect grassy farmland.
Removed "[farmland=dairy](https://taginfo.openstreetmap.org/tags/farmland=dairy#overview)", no longer in the data.
Changed "[farmland=pasture+heath](https://taginfo.openstreetmap.org/tags/farmland=pasture+heath#overview)" and "[farmland=pasture+wetland](https://taginfo.openstreetmap.org/tags/farmland=pasture+wetland#overview)" to their semicolon equivalents, which objects with these tags these have been changed to.
"[natural=erratic](https://taginfo.openstreetmap.org/tags/natural=erratic#overview)" has been changed to "[geological=glacial_erratic](https://taginfo.openstreetmap.org/tags/geological=glacial_erratic#overview)" in the data.
Show "[waterway=boatyard](https://taginfo.openstreetmap.org/tags/waterway=boatyard#overview)" and "[industrial=boatyard](https://taginfo.openstreetmap.org/tags/industrial=boatyard#overview)" as boatyards.
Add more noncarpeted "[floor:material](https://taginfo.openstreetmap.org/keys/floor%3Amaterial#overview)" values.
Detect more tags that can be interpreted as drinking water and non-drinking water.

## 04/06/2024
Updated the OSM OpenMap Local layer to the new OpenStreetMap-hosted April 2024 tiles.

## 13/05/2024
Rearranged long lines in the changelog for improved display on mobile for those with relatively narrow phones and larger text settings for legibility.

## 12/05/2024
Changed the brand check to not append brand if it's contained within the name.
Added "[playground=trampoline](https://taginfo.openstreetmap.org/tags/playground=trampoline#overview)" to complement "[leisure=trampoline](https://taginfo.openstreetmap.org/tags/leisure=trampoline#overview)"; most of the latter are no longer in the data but new ones are still being added.
Removed "[historic=martello_tower;fort](https://taginfo.openstreetmap.org/tags/historic=martello_tower;fort#overview)", no longer in the data.
Added "[waterway=rapids](https://taginfo.openstreetmap.org/tags/waterway=rapids#overview)" to the list of detected linear waterway features.
Show "[waterway=cave_of_debouchement](https://taginfo.openstreetmap.org/tags/waterway=cave_of_debouchement#overview)" as a "wet sinkhole".
Remove "[crossing=traffic_signals;pelican](https://taginfo.openstreetmap.org/tags/crossing=traffic_signals;pelican#overview)", no longer in the data.
Show larger museums etc. at lower zoom levels.
Where museums have some other tag (e.g. "[park](https://taginfo.openstreetmap.org/tags/leisure=park#overview)"), decide which tag to use to show them.

## 06/04/2024
Show departure boards that exist on their own, not attached to bus stops etc.
Show public transport information boards with a blue pole.
Show linear lock gates with a a thick black line, like other linear gates.
Don't show unnamed MTB "routes" as routes.
Removed "shop=takeaway" and "shop=offlicence", no longer in the data.
Removed "amenity=shopmobility" from list of expected tags, no longer in the data.

## 27/03/2024
Removed "shop=guns", no longer in the data.
Detect outfalls, sewage and otherwise.
Show "location=overhead" pipelines in the same way as "location=overground" ones.
Show "seamark_type=pipeline_submarine" in the same way as "man_made=pipeline".
Removed "craft=joinery", no longer in the data.
Show inscriptions and directions on milestones at higher zooms.
Show inscriptions on boundary markers and stones at higher zooms.
Show island names up to and including the size of Ireland, but not Great Britain.

## 21/03/2024
Show bus stops which exist but have no service with a unique icon.
Suppress "naptan:Indicator" or "ref" on a bus stop if more than 3 characters long.
Where a platform is also a bus stop, show it as a bus stop first.

## 16/03/2024
Added accommodation, wheelchair and beer garden checks for a few more combinations, including microbreweries.
Show mazes as nonspecific leisure items.
Removed "shop=jeweller", no longer in the data.
Show "bus_speech_output_name" and/or "bus_display_name" if non-blank and not contained within "name".

## 09/03/2024
Render shop=esoteric in the same list as other "woo" shops such as "new_age" etc.
Treat NaPTAN customary stops with no departures as "pole not present" ones.  This isn't assured, but you can't assume there is a pole at a customary stop.
Include "man_made=marker" in the list of pipeline markers.
If something has been tagged as a beach resort and a beach, show as just a beach.
Added wheelchair and beer garden checks for micropubs which serve food and have noncarpeted floors, and some other pubs with other combinations of tags.
Added "grubby carpet" to the list of floor:material values that indicate a less-precious floor.
Excluded some "food" values (such as "snacks") from indicating that "this pub serves food".

## 28/02/2024
Fixed spelling of "paper timetable" (sic) in the lua code.  Taginfo was correct already.
Removed "shop=beautician", no longer in the data.
Added "departures_board=yes" as "implying at least a timetable".
Use a larger icon for ventilation shafts at high zoom levels.
Display stiles with dog gates with a different icon.
Show duty free shops not tagged as something else as "gift".
Show "leisure=garden" and "leisure=nature_reserve" that are also "tourism=attraction" as the former.
Removed "departures_board=realtime; timetable", no longer in the data.
Show ventilation shafts mapped as areas in the same way as roofs if not already mapped as buildings.
Detect more subtags that indicate that farmland or meadows should be treated as "farm grass".
Detect "farm shop honesty boxes" and show with produce if known.
Detect more taggings of "farm shop honesty boxes".
Add icons for "baseball" sports pitches.

## 18/02/2024
Include "tower:type = ventilation_shaft" in the list of things that get shown as ventilation shafts.
On bus stops, show whichever of "name", "ref", "naptan:Indicator" is available.  If available show "website" as well from zoom 21 upwards.
Removed "pole=maypole", no longer in the data.
Show whether a bus stop has a real-time departures board, a timetable or no flag or pole at all by using a different icon.  Also show whether the departures board has speech output.
Show larger icons for bus stops at higher zooms.
Removed "man_made=telephone_kiosk" and "telephone_kiosk=K4", no longer in the data.

## 06/02/2024
Nudge the text on artwork names down slightly at high zooms to avoid it being obscured.
Removed "cuisine" check for "ice_cream;coffee;waffles;crepes" as it is no longer in the data.
Moved some more historic items into the "show at lower zoom if they are larger" section.
Changed to historic size thresholds to show some medium sized items earlier.
Removed "emergency_service=air", no longer in the data.

## 30/01/2024
Detect tumuli mapped as tombs.
Suppress duplicate name display on some historic / landuse combinations on buildings and some other features.
Added support for "historic=workhouse" as a nonspecific historic item.
Treat "status=abandoned" as a synonym for "disused=yes".
Detect historic quarries that have "historic=yes" set.
Suppress duplicate name display on some historic / natural combinations.
Use various "segregated" tags as an indicator of "sidewalk".
At high zooms show directions on guideposts.

## 27/01/2024
If something is a historic quarry, mineshaft or castle, or falls into the historic "nonspecific catch-all", and is tagged with something leisure or natural, show it as that other thing.
If something is a historic tomb, and is tagged with landuse, leisure or natural, show it as the latter.
Show some "area" historic objects at a lower zoom level if large enough.
Suppress landuse=historic display on 'modern' archaeological sites.
Suppress duplicate name display on some historic / landuse combinations.

## 23/01/2024
Show non-historic watermills.
Detect former kilns tagged as "ruins:man_made".
If a "ref" is set for an international walking network, use that instead of "name".
Fix bug whereby rugby pitches weren't shown in green.
Removed "natural=lake" from styling and taginfo after removing it from UK/IE data.
Show larger lakes at lower zoom levels based on size.  Changed "smallest lake" display level from zoom 15 to zoom 16.
Show area battlefield names at lower zoom levels based on size.  Smallest area battlefield shows from zoom 16, as before.

## 12/01/2024
Removed "floor:material=rough wood", no longer in the data.
Add "football" as a synonym for "soccer" and detect more combinations for that, and other sports.
Add icons for "athletics", "boules", "bowls", "croquet", "cycling", "equestrian", "gaelic_games", "hockey", "multi", "netball", "polo" and "shooting" sports pitches.
Don't display a name from both "leisure=pitch" and e.g. "sport=shooting".  
Display military hatching on both "sport=shooting" and "sport=shooting_range".
Sorted the sport legends entry in rough order of popularity in UK/IE and added new icons for sports with pitches down to "boules".
Display a "ref" from zoom 19 for aerial pipeline markers.
Removed "craft=glazier", no longer in the data.
Display "waterway=drainage_channel" as "waterway=ditch".
Added support for "vending=bottle_return" with a unique icon based on other "vending" ones.
Show "historic=pound" as a synonym for "historic=pinfold".  Many pinfolds have been [retagged](https://www.openstreetmap.org/changeset/146161946) as pounds.

## 01/01/2024
Added "ruins=donjon" to the list of ruined castle tags.
Use "ruins=yes" more often to detect that historical buildings are fuins.
Detect "ruins=windmill" as a ruined windmill.
Detect "ruins=barn", "ruins=barrack", "ruins=blackhouse", and "ruins=hut" as ruined buildings
Detect "ruins=farm_auxiliary" as a ruined building.
Detect "ruins=mill" as a ruined mill.
Detect "ruins=mine" as a ruined mine.
Detect "ruins=lime_kiln" as a ruined lime kiln.
Detect "ruins=manor" as a ruined manor.
Detect "ruins=well" as a ruined well.
Detect "ruins=watermill" as a ruined watermill.
Detect "historic=village" as nonspecific historical items.
Detect "ruins=village" as a ruined village.
Show "historic=village_pump" as a historic, hand-operated water pump.
Detect "ruins=grave_yard" as a ruined graveyard.
Detect "man_made=sound mirror" as a nonspecific historical item.
Detect "ruins=round_tower" as a ruined round tower.
If a saltmarsh has surface=mud, render as saltmarsh.
Detect wetland=wet_meadow where natural!=wetland.
Append "(m)" to mountain bike route names.
Detect "historic=battery" and "defensive_works=battery" as nonspecific historical items.
Detect more ruined buildings without a "ruins" tag.
Use "castle_type to detect things "troll tagged" as castles that are not castles.
Better handle geoglyphs - now that named "bare rock" appears, use that.
Only add "unnamed commercial" landuse at the very end of the processing.
Treat water towers as buildings.
Don't show a label on commercial or grass landuse if an underlying aerodrome will have a name shown.
Remove landuse=conservation if we can.
Fixed typo in "stately" in a couple of places including taginfo.
Removed various duplicate landuse / leisure labels.
Increased the materials detected as noncarpeted pub floors.
Look for grass on horse_riding.
Removed "shop=printer_cartridges", no longer in the data.

## 28/12/2023
Show hilltop enclosures as hill forts.
Fixed bug where some military bunker names appeared twice.
Show showers (free and for-pay).
Removed "shop=ink_cartridge", no longer in the data.
Increased width of rivers and other waterways drawn only as lines at high zooms.  See this [diary entry](https://www.openstreetmap.org/user/SomeoneElse/diary/403118).
Fixed bug where some historic items were not shown.
Show "historic=bullaun_stone" as other historic stones.
Show "historic=anchor" as nonspecific historical items.
Show "historic=clochan" as other secular historic buildings.
Show "historic=tramway" as abandoned railways.
Show "historic=deserted_medieval_village" and "historic=ice_house" as nonspecific historical items.
Show "historic=rath" as a synonym for ringforts.
Show "historic=monument" like a memorial obelisk, but without the the memorial 'M'.
Show "historic=tomb" like a memorial grave, but without the the memorial 'M'.
Show "historic=folly" like a falling-down castle.
Show "historic=cannon" as a cannon.
Show "historic=kiln" and "historic=lime_kiln" with a characteristic kiln shape.
Show "historic=ship" as a ship.
Show "historic=aircraft" as an aircraft, and "historic=aircraft_wreck" as more obviously not an aircraft any more.
Show "historic=windmill", "historic=watermill" "historic=mill" with appropriate historic icons.
Show "historic=water_pump" as a historic, hand-operated water pump.
Better detect some of the hodge-podge tagging on operational and former windmills.
Show "historic=tank" as a miltary tank.
Show "historic=ice_house" (and "man_made=ice_house") with a characteristic icon.
When processing access land etc., don't remove existing leisure tags.
If a building is defined as a place, display building tags not place tags.
"company" is used as an alternative to "office" by some people.

## 23/12/2023
Detect telephone exchanges rather than other telecom equipment,
Better handling of historic items - detect when still in use.
Removed "historic=churchyard cross", no longer in the data.
Detect "leisure=yoga" as generic leisure.
Detect "leisure=trailhead" as a synonym of "highway=trailhead".
As well as "amenity=leisure_centre", detect "leisure=leisure_centre" as "leisure=sports_centre".
Detect "leisure=dojo" as a synonym for "amenity=dojo".
Detect "landuse=playground" as a synonym for "leisure=playground".
Append "inscription" to names of boundary stones as well as historic ones.
"icao" tag is used to split large/small and public/private heliports, if "iata" not present.
Detect "historic=baths", "historic=naval_mine", "historic=residence", "historic=smithy" and "historic=sound_mirror" as generic historic items.
Detect "emergency=water_rescue_station" as coastguard-adjacent facilities.
Show larger islands at lower zoom levels based on size.  Also show islets in the same way as islands.
See this [diary entry](https://www.openstreetmap.org/user/SomeoneElse/diary/403118) for more details.

## 16/12/2023
Detect public transport stations not obviously bus, railway or aerialway stations.
Removed "healthcare=cosmetic_treatments", no longer in the data.
Added "emergency=ses_station" as a synonym for "emergency=coast_guard" and show as a government office.
Show "historic=millstone" as nonspecific historical item.
Add "area:highway" to generic_keys to show as kerbs.
Removed "shop=undertaker", "shop=solicitors", "shop=chandlers", "leisure=court", no longer in the data.
Update OS OpenMap Local data from April 2023 to October 2023.
Added "craft" to the list of tags that causes "disused:amenity" to be removed.
Removed "tourism=guesthouse", no longer in the data (it was a typo for "tourism=guest_house").
Added "brand=independant" as a brand to suppress.
Detect escooter operators via the "network" tag if used.
Detect "bicycle_parking;bicycle_rental" as "bicycle_rental".

## 01/12/2023
Following the tagfiddling prior to and as part of [this change](https://lists.openstreetmap.org/pipermail/talk-gb/2023-November/thread.html#30914), try and distinguish lifeboats and lifeboat stations with other tags.  See also [here](https://lists.openstreetmap.org/pipermail/talk-gb/2023-December/030932.html).
Removed "shop=take_away", no longer in the data.
Added some missing fast food cuisines.
Added "shop=winery" as a synonym for "craft=winery".
Added "designation=footpath" as a synonym for "designation=public_footpath".
Removed "shop=electricial", no longer in the data.
Detect "covered=roof" as a synonym for "building=roof".
Detect hills tagged as peaks.
Detect more "ford" values as fords.

## 26/11/2023
Various crafts that previously did not appear are now shown as at least a nonspecific office.
Removed "fee=No", no longer in the data.
Show covered waterways as tunnels.
Removed "shop=car_inspection" (no longer in the data), added "amenity=vehicle_inspection".
Removed "shop=accountants" (no longer in the data).
Don't show cycle route references of "N/A"
Append "(r)" to regional cycle routes, except the National Byway.
Append "(loop)" to the name of NB loops.  See this [diary entry](https://www.openstreetmap.org/user/SomeoneElse/diary/403118).
Removed "shop=pet;florist" and "shop=alarm", no longer in the data.

## 14/11/2023
Updated list of "non-operators" used in operator and brand.
Don't replace a blank name with brand on closed pubs.
When deciding whether a tertiary road should be rendered narrower, assume roundabouts are oneway.
If "surface=scree" is set on another natural feature, show the scree.
Show military aerodromes with red text.
Added larger icons at higher zooms for playground items, and for bench, tree and artwork.
Show "protect_class=98" in the same way as nature reserves.

## 05/11/2023
Changed "jewelry, arts, crafts" to "jewelry;art;crafts" to match the data.
Show "railway:miniature=station" as "tourist stations".
Show "station=miniature" or "tourism=yes" as "tourist stations".
Handle scooter rental places mapped as car parks(!).
Show sand-covered reefs as more sandy than rock-covered ones.

## 23/10/2023
Removed "embassy=embassy", which no longer appears in the data.
Treat "closed:" pubs and shops as disused.
Treat pillboxes as historic bunkers.
Detect disused "building=bunker" as historic bunkers.
Detect "building=bunker" without obvious other tags as military bunkers.
Removed "amenity=storage_rental", which no longer appears in the data, and replaced it with "office" which has a few examples.
Removed "shop=jewellery", which no longer appears in the data, and added a number of semicolon-based versions as synonyms in the style.
Removed "shop=picture_frames", which no longer appears in the data, and added "shop=frame;restoration", which does.
Ensured that "wetland=tidalflat" implies "tidal=yes".  Added "natural=saltmarsh" and translate to more common tags.
Show "historic=vehicle" as a nonspecific historic item.
Updated pyosmium_replag.sh to ask curl to follow redirects.

## 07/10/2023
Show recycling_type=scrap_yard as per regular scrapyards.
Show historic=martello_tower (and some semicolon derivatives) as uncrenellated historic tower.
Show historic=railway_station as nonspecific historical objects, like e.g. "historic:railway=station".

## 06/09/2023
Show salt marsh and reedbed wetlands with unique icons.
Move mud and tidal_mud from water_areas to water_areas_overlay, so that they appear over the top of natural=water.
Show mud and tidal wetland from zoom 10
Add name for more "natural" features from z13 or z15.
See this [diary entry](https://www.openstreetmap.org/user/SomeoneElse/diary/403118) for more details.

## 04/09/2023
Removed "shop=luggage_locker" as a synonym for left luggage; it was only ever an extreme outlier and it has now been removed from the data.
Removed "historic=limekiln" as a synonym for "historic=lime_kiln"; no longer in the data.
Render "leisure=music_venue" as a concert hall if "amenity" isn't set to something more relevant.
Removed "megalith_type=passage_tomb" as a synonym for "megalith_type=passage_grave"; no longer in the data.
If a sensible surface tag is set, render wetland as that rather than as vanilla wetland.
If a wetland value suggests mud, render as mud rather than as vanilla wetland.
Show "wet meadow" wetlands as such.
Change the wetland and intermittent wetland patterns to better represent the data and fit in with the rest of the style.

## 18/08/2023
Handle amenity=youth_centre in the same way as amenity=youth_club.
If "boundary=forest" is set and "landuse" is not, handle as per "landuse=forest".
Added a couple more synonyms for "leisure=bird_hide".
Added an icon for grouse butts.
Added an icon for hunting stands that are not grouse butts.
Added "waterway=tidal_channel" as a synonym of "waterway=stream".

## 03/08/2023
Handle office=advertising_agency in the same way as office=advertising.
Handle office=religion in the same way as office=charity.
Handle office=engineer in the same way as office=engineering.
Handle office=construction_company in the same way as office=consulting.
Handle office=geodesist in the same way as office=engineering.
Handle office=private in the same way as office=yes.
Handle office=organization in the same way as office=ngo.
If something has a shop tag and a generic office tag, remove the office tag.
If a building that isn't something else has a name but no addr:housename, use name in place of addr:housename.
Suppressed tourism tag on more historic items to prevent inconsistent rendering.
Handle historic=grinding_mill in the same way as historic=mill.
Handle historic=round_tower in the same way as tower:type=round_tower.
Handle historic=jail in the same way as historic=prison.
Handle historic=pillory in the same way as historic=stocks.
Handle historic=cathedral in the same way as historic=abbey.
If a historic=abbey etc. is active place of worship, show it as that.
Handle historic=oratory in the same way as nonspecific historical item.
Handle historic=place_of_worship in the same way as historic=church.
Ensure that the "no vis paths" layer only considers highways.
Show loungers as benches.
Show linear bollards as fences (the least worst option; any arrangement of dots or dashes would look like a path or a railway line).
Suppress place=locality with some other tags (amenity, man_made, historic).
Show pipeline=marker and marker=post as marker=pipeline.
Remove support for shop-motoring - it was actually a very old mistagging.

## 12/07/2023
Interpreted various less frequently used wheelchair values as one of the three common ones.
Added some "post" synonyms.

## 01/07/2023
Added more historic and memorial crosses, including historic=high_cross.
Added man_made=cross.
Added leisure=bandstand - show as a roof with a green musical icon.
Removed waterway=aqueduct; no longer in the data.
Update taginfo to reflect that shop=gun is back in the data again.
"historic=bridge site" has been changed in the data to "historic=bridge_site".
If a tourist attraction is also a sports centre, show as a sports centre.
If 'visibility' is set and 'trail_visibility' is not; use the former.

## 17/06/2023
Show amenity=watering_place on ways as water, on nodes as a blue dot.
Removed "building=residential_home" as a synonym for "amenity=residential_home"; no longer in the data.
Removed "shop=bureau_de_change"; no longer in the data.
Added some semicolon-separated sports: climbing;bouldering, cricket_nets;multi, skateboard;bmx, soccer;basketball, soccer;football, soccer;rugby, soccer;hockey, soccer;gaelic_games, soccer;gaelic_games;rugby, basketball;soccer, basketball;football, basketball;multi, basketball;netball, multi;basketball;soccer, rugby;soccer, rugby_union;soccer, rugby;football, tennis;netball, tennis;multi, yoga;pilates, motor;karting, soccer;archery.
Show information boards without a tourism tag.
Consolidated PNFS operator tags.
Added support for various "information=board" and "information=map" variations.
Added support for shop=catering_supplies.
Handle various incompletely tagged Howden's Joinery.

## 29/05/2023
Added report_tag_usage_changes.sh script that can run from cron and detect changes to tags/values used by a project at taginfo.
Treat historic=earthworks as archaeological.
Handle historic graves in the same way as memorial graves.
Add certain named historic=industrial objects with historic dot and landuse.
Show disused and historic quarries.
Show historic pubs as former pubs.
Removed shop=locksmiths and shop=fireplaces; no longer in the data.
Show "historic=moat" as "waterway=derelict_canal".
Show "historic=bridge site" as a generic historic site.
Show "disused:landuse=cemetery" as a generic historic item if there are no other tags.
Show "historic=cemetery" as a historic item if it is not a current cemetery.
Show "historic=wreck" with a unique icon.
Show "historic=aircraft_wreck" with a unique icon.
Removed "shop=bags", "shop=beds", "shop=cars", "shop=closed", "shop=collectables", "shop=crafts", "shop=fabrics", "shop=farm_shop", "shop=haberdasher", "shop=lamps", "shop=misc", "shop=models", "shop=opticians", "shop=pets", no longer in the data.
Changed "shop=spice" to "shop=spices", following some mechanical tag changes.
Treat "name:absent=yes" as "name:signed=no".
Suppress footway / cycleway name on "is_sidepath:of" and related keys.
Don't show covered reservoirs or telescopes as buildings if a landuse tag is already set.

## 27/05/2023
Update OS OpenMap Local layer to April 2023.

## 13/05/2023
Humanitarian tiles added as an extra layer.
Updated OS OpenMap Local tiles to October 2022.
OSMUK cadastral parcels added as an extra layer.

## 08/05/2023
Removed shop=flower; no longer in the data.
Suggested by [this forum post](https://community.openstreetmap.org/t/tagging-for-outdoor-education-centres/98422), add support for "amenityoutdoor_education_centre".  Low usage currently.
Support healthcare=doctor as a synonym for amenity=doctors.
Similarly support other "healthcare" synonyms, and some others (e.g. "midwife").
Removed amenity=doctor; no longer in the data.
Removed amenity=micro_scooter_rental; no longer in the data.
Removed amenity=scooter_hire; no longer in the data.
Removed amenity:old; no longer in the data.
Corrected spelling of "K4 Post Office" (no underscores).
Added values for "booth" to taginfo,json.
Removed "Gala Bingo Hall"; no longer in the data.
Added "name" values that are explicitly handled to taginfo,json.
Removed "shop=army_surplus"; no longer in the data.
Added operator values that are explicitly handled to taginfo.
Assume prehistoric hillforts are archaeological but not necessarily hillforts.
Assume other early forts are archaeological.
Made the three "wood" patterns larger, and less regular.

## 23/04/2023
Show disused:man_made=mineshaft etc. as historic mines.
Show disused:military=bunker etc. as historic bunkers.
Removed shop=healthfood; no longer in the data.
Show highways with designation=access_land as public_footpath.
Show smaller aerodromes (gliding clubs etc.) with leisure brown text, not transport blue. 
Show historic=pinfold with a unique icon.
Show hedges as linear features if tagged on a different area feature; as area fatures if on their own on an area, and as linear features if on their own on a line.  See this [diary entry](https://www.openstreetmap.org/user/SomeoneElse/diary/401631).
Treat surface=grass on nature_reserves as landuse=grass.

## 10/04/2023
Removed "shop=eco-grocer"; no longer in the data.
Show historic churches and chapels with a unique icon as a building.
Show ruined historic churches and chapels with a unique icon as a ruined building.
Show ruined castles in the same way as "archaeological" castles.
Ensure that "ruins=house" and "ruins=farmhouse" houses are shown as such.
Ensure that "ruins=tower" towers are shown as some sort of tower.
Show military bunkers with a unique icon.
Show historic military bunkers (including ruined ones) with a unique icon.
Ensure that "ruins=monastery" etc. monasteries, abbeys and priories are shown as such.

## 08/04/2023
Ensure that tunnels on preserved, miniature and narrow_gauge railways are shown.
Process beer garden / outdoor _seating or wheelchair tags on non real ale pubs with accommodation.
Assume that prehistoric "historic forts" are archaeological, not historic.
Added a couple of designations in use in Northern Ireland (carriageway, PROW).
Added icon for historic=monastery and other similar places.
Added icons for historic=city_gate, historic=battlefield, historic=stocks, historic=well, historic=cross and historic=well.
Catch "historic" "ringfort"s as archaeological.
Show historic graveyards that aren't tagged as regular graveyards with "graveyard" landuse (like "disused" ones).
Show non-historic monasteries and convents with a unique icon.
Show "historic=ruins; ruins=building" as per other ruined nonspecific buildings.

## 04/04/2023
Show archaeological mottes, castles, promontory forts and crannogs with icons unique to them.
Changed "mine_shaft" to not assume building on closed ways.
Added icon for historic mine features, including also "historic=mine_level".
Added icon for historic=castle.
Some more "industrial" values are treated as industrial landuse or "offices".
Added icon for historic=manor and other large houses.
Added various icons for historic towers.
If a "fort" has "fortification_type=hill_fort" etc., assume it is an archaeological site.

## 25/03/2023
Show stone circles with a unique icon, different to the default megalith icon of a single standing stone.
Show megalithic tombs and stone rows with icons unique to them as well.
Show archaeological sites that are fortifications or tumuli with icons unique to them.
Show ringforts and hillforts with icons unique to them.

## 19/03/2023
If an amenity=bicycle_parking is mapped as a closed way, but as covered=no, don't show it with a roof.
Show natural=hill like natural=peak, but from a higher zoom level.
Show natural=hedge as barrier=hedge.
Treat natural=earth_bank as a type of embankment.
Treat natural=woodland as a synonym of natural=wood.
Treat natural=headland and natural=peninsula as synonyms of natural=cape.
Treat natural=dune as a synonym of natural=sand.
Treat natural=boulder and natural=erratic as natural=rock, if not sport=climbing or climbing=boulder.
Show natural=bare_rock as natural=rock on nodes.
Removed "shop=unknown", "shop=travel_agent", "shop=empty", "military=ta centre", "amenity=youth_centre", no longer in the data.
Show natural=rocks as natural=rock on nodes, and natural=bare_rock on non-nodes.
Show natural=grass as landuse=grass if some other tag does not apply.
Show natural=arete like natural=ridge; as an embankment or an embanked highway.
Treat natural=meadow as a synonym for landuse=meadow, if no other landuse.
Show tidal beaches with blue dots instead of grey.
Render tidal scree, rocks, mud, shingle and sand with more blue.
Consolidate some "ford" values into "yes".
If a highway has tidal=yes but not yet a ford or bridge tag, add ford=yes.
Added more bridge=yes synonyms.
Treat natural=garden, natural=plants and natural=flower_bed as synonyms for leisure=garden, if no other appropriate tag.
Treat natural=dunes and natural=sand_dunes as further synonyms of natural=sand.
Show natural=stones as natural=rock on nodes, and natural=bare_rock on non-nodes.
Show natural=embankment as man_made=embankment.
Show natural=bracken as scrub.
Handle natural=sound and natural=point as place=locality if no other place tag.
Handle "natural=pond" as water.
Show natural=col as natural=saddle.
See this [diary entry](https://www.openstreetmap.org/user/SomeoneElse/diary/401361) for more details.

## 06/03/2023
Show highway=emergency_bay as "private parking".
Removed holiday_accommodation as a synonym as it is no longer in the data.
Added background patterns for natural=bare_rock and (with fewer dots) natural=scree.
Added an icon for natural=shrub, based on natural=tree.
Changed climbing boulder to have some "sport" green on it.  
Handle natural=rock on ways as per natural=bare_rock; Handle natural=rock on nodes as grey boulder.
Added a background pattern for natural=shingle (with more dots than beach).
Show mud, beach, shingle, bare_rock and scree from z10, consistently with sand.
Add natural=reef, as rocks on a transparent background.
Add natural=ridge to the list of tags treated as non-highway and highway embankments.
Handle natural=shoal as either mud or reef.

## 04/03/2023
Removed shop=auto_repair, which is no longer in the data.
Added lifevest and "flotation device" as synonyms for life_ring.
Add "designation=March Stone" as a synonym for boundary stones.
Replace office=photo_studio with craft=photographer.
Added holiday_accommodation as a synonym.
Show heliports in the same way as aerodromes.
Show names for small aerodromes (and heliports) from zoom 14.
Filter out some trailheads if the other tags on the same object are more plausible.
Try and guess whether chalets are parks or just single chalets, based on other tags.
Show turning loops that are ways as service roads, in addition to the nodes that are shown as turning circles.

## 06/02/2023
Support various keys with an "electrician" value as offices.
Show "shop=atv" as motorcycle shops.
Handle "unsigned=name" and "unsigned=ref" as equivalents of "name:signed=no" and "ref:signed=no" respectively.
Don't render underground railway station platforms as if they are not underground, if they are tagged as "underground=yes" or "layer=negative".  The latter isn't supposed to be only relative, but effectively does describe overground/underground.
Include "sport=cricket_nets" among cricket pitches.
Include "leisure=practice_pitch" among sports pitches.
Show "shop=winery" and "tourism=wine_cellar" as alcohol shops.
Include "barrier=berm" among the list of "non-highway embankments".
"business" is used as an alternative to "office" by some people.
If a shop is vacant, don't include any "ref" in the name.

## 14/01/2023
Added more quiet lane combinations in the "designation" tag where that is processed, both to turn quiet lane roads into living streets, and to use the correct colouring for the other designation (byway etc.).
Tidied up comments a bit so that everything that matches the "mkgmap" equivalent of the code can be found easily.
Added support for "emergency_service=air" to detect more coastguard infrastructure.
If a skate park has a leisure tag already, don't reset it.
Render icons for some sports pitches - especially useful where they are just mapped as a node (e.g. Table Tennis).
Show grass taxiways as tracks.
Treat "trail_visibility=medium" as "intermediate" and improve taginfo documentation on other "trail_visbility" synonyms.
Add "memorial=pavement_plaque" support to match the more common (in UK/IE) "memorial=pavement plaque".
Detect pubs that are also e.g. motels as having accommodation.

## 04/01/2023
Update taginfo.json with all missing values from all remaining .mss files: buildings.mss, amenity-symbols.mss, stations.mss, ferry-routes.mss, aerialways.mss, admin.mss, addressing.mss.
Changed update_render.sh and make_gis3_live.sh so that styling changes as well as database changes are held off until gis3 is made live.
Detect electric charging stations mistagged as amenity=fuel or waterway=fuel.
Show amenity=fuel that also provide electric charging with "+/-" to the side of the normal fuel icon.
Show vending machines that sell petrol as amenity=fuel.
Show aeroway=fuel as amenity=fuel.
Show waterway=fuel as a maritime version of amenity=fuel.
Show hydrogen fuel stations as such.
Show amenity=fuel selling LPG as such.  Unfortunately the data isn't yet there to distinguish "LPG only" and "LPG as well".
Added government=police and office=property_maintenance.
Added man_made=standing_stone and man_made=stone.
Detect "training" without "amenity", "shop" or "leisure".
Detect social_facility without amenity or office.

## 27/12/2022
Update taginfo.json with all missing values from amenity-points.mss, landcover.mss, water.mss, water-features.mss, roads.mss, power.mss, citywalls.mss, placenames.mss
Show linear equestrian tracks (typically gallops etc.) as black on green, with the name offset.
Show linear motor leisure=tracks as raceways.
Show other linear leisure=tracks as generic paths.
Use dance_teaching=yes as a synonym for dance places.
Show healthcare=sample_collection as clinic.
Added office=forestry to the list of government offices.

## 23/12/2022
Synonyms for grassy farmland expanded to match grassy values in [taginfo](https://taginfo.geofabrik.de/europe/britain-and-ireland/keys/farmland#values).
Added emergency=rescue_box, which has cropped up as a value by stealth.
Under the diplomatic key, embassy is now being used for non-embassies, so process sub-tags of that and render non-embassies as offices.
Likewise, consulate.
Someone changed "lawnmower" to "lawn_mower" in the data ages ago, but oddly left "lawnmowers", so render "shop=lawn_mower".
"plant_hire;tool_hire" was always amenity not shop; fixed.
Show amenity=biergarten, amenity=beer_garden and outdoor_seating=garden as green.
Update taginfo.json with all recent changes from style.lua.
Removed some formerly low-use synonyms that are no longer in use from the style.
Show "hazard_prone=yes" where "hazard_type=flood" as flood prone.
Add "shop=agrarian" and various agrarian values as either feed or agricultural machinery shops.
Don't show stand-up benches as benches.
Detect dentists that are also clinics etc.

## 12/12/2022
Detect Quiet Lanes via a "designation" of "quiet_lane;unclassified_highway" as well as just "quiet_lane".
Potentially detect bulk_purchase=only, even though it isn't widely used in UK/IE.
"archaeological_site=megalith" has appeared as a duplicate of "site_type=megalith", so adding support for that.
Don't show motorway junction names if name:signed=no.
Removed support for bridleway=mounting_block as the one example of that has been changed to something more sensible.
Removed support for some "bridge" values that have (sensibly) been moved in the data to e.g. "bridge:structure" or similar.
Removed support for the misspelt "barrier=tank_traps" (no longer in the data).
Removed support for "barrier=lift_gate,lights" (no longer in the data).
Removed support for "amenity=vehicle_rental" (no longer in the data).
Removed support for "amenity=car_repair" (no longer in the data).
Updated README with more project information.
Render lifeboats on moorings (tagged as amenities or seamarks).
Render coastguard stations tagged as seamarks.

## 04/12/2022
Don't render disused fountains in the same way as vacant shops etc.
There are a couple of "highway=layby" in the UK.  Handle as "amenity=parking".
Send living_street through to the database with that tag, not "residential".  Render living streets slightly darker than unclassified / residential.
Render Quiet Lanes on tertiary, unclassified and residential as living_street.

## 01/12/2022
The automatic permalinks at [map.atownsend.org.uk](https://map.atownsend.org.uk) now support layers as well as zoom levels and location.  See this [diary entry](https://www.openstreetmap.org/user/SomeoneElse/diary/400496).

## 28/11/2022
Update [map.atownsend.org.uk](https://map.atownsend.org.uk) to use "[leaflet-hash](https://github.com/mlevans/leaflet-hash)".

## 27/11/2022
Render "tower:type=chimney" and "building=chimney" as "chimney" or "bigchimney", depending on height.
Render office=medical_supply as shop=medical_supply.
Added railway:historic to the style, for compatibility with mkgmap style.
If it has no other tags, ensure that military bunkers appear as buildings.
Updated (in SomeoneElse-style) update_render.sh, update_carto.sh and (in SomeoneElse-style-legend) update_generated_legend.sh to link comments to [stackoverflow](https://stackoverflow.com/a/73836045/8145448).

## 13/11/2022
Show reservoir_covered as building=roof, so that they don't blend in with a wider industrial area.
Also treat a couple of spellings of "hard shoulder" as "shoulder".
Don't show narrow tertiary roads as unclassified if a oneway tag is set.
Suppress "tourism" on showgrounds.
Show grass outdoor_seating in green.
Show unnamed farm shops with particular produce as farm "vending machines".
Show signs with a landscape information sign icon rather than a portrait information board one.
Show military signs in red.
Use board:title as the name on information signs as well.
Increased maxzoom on test views to 24/25.
Also render lifeguard bases (all lifeguard features in UK and IE now rendered).
Include Isle of Man and Guernsey/Jersey in rendering.

## 01/11/2022
Renderd geological=paleontological things.  Improve the icon for historic=archaelogical (less fuzzy, less brown).
Render inscriptions on marker stones.

## 12/10/2022
If est_width is set but width is not, use est_width.
Handle non-integer-width narrow tertiary roads that should be shown as unclassified.
Update taginfo.json with recent changes.

## 21/09/2022
Don't render disused car parks in the same way as vacant shops etc.
Don't process old-style polygons in lua.

## 04/09/2022
Major behind the scenes changes - support Ubuntu 22.04, 
the latest osm2pgsql and mod_tile (patched to support zoom levels up to 24).  
Also the use of osmosis was replaced with osmium, pyosmium and osm-tags-transform.
Scripts now do more error checking and can detect e.g. out-of-memory errors and tidy up after failures.
Update process now preserves language tags - places with a hybrid "name A / name B" name tag keep either name A or B depending on location.
Main database still "gis", but scripts amended to allow loading of new data into "gis3", testing, and swapping over later, in order to reduce downtime.
The "borders" database is now "gis6", and no longer depends on any external styles or software run "ad hoc" at data load.

## 04/09/2022
Add novispaths to the default (Ubuntu 22.04 LTS) update_render.sh
Render "small_electric_vehicle" as scooter_rental.
Added selecting vending machine products such as "eggs" as the label.
Added "beach" to the list of natural items for which names are renderd.
Handled some edge cases of trail_visibility=bad - when there's a bridge, it can't be _that_ hard to see, can it?  
Similarly if there's something that would display as a levee, let that still happen.
Continue showing ele on peaks beyond zoom 20.

## 24/07/2022
Treat school=entrance as entrance=main.
Add access=destination to highway escape lanes.
Removed very old "builtup areas" layer from project.mml
Add "boundary" as a multipolygon key so that national parks drawn as ways are still shown (specifically, St Kilda).
Paths suppressed for bad visibility or over-demanding sac_scale now get their own key, and an overlay optionally displays those.

## 03/06/2022
Added craft=floorer to the same list as "roofer" etc.
Exclude "independent" and "free house" etc. from brand and operator.
Render amenity=waste_transfer_station as industrial.
Render amenity=food_court in the same way as marketplace - as a name, with no icon.
Render historic railway stations in the same way as other historic items.
Prevent highway=raceway from appearing in the polygon table.
Render entrance=main at higher zoom levels (from 18).
Render roofs for shelters mapped as ways, and bicycle_parking ways.
Remove shelter icon from "shopping cart", "trolley park", "animal_shelter" and "parking" shelters.
Render "bicycle_parking" shelters with a bicycle_parking icon.
Render leisure=bleachers as "not quite a building" along with e.g. bridges.
Include "site_type=megalith" in the "standing stone" list.

## 30/05/2022
Added more pub outside seating and wheelchair combinations for more pubs.

## 14/05/2022
Added craft cider breweries.
Render pubs with "opening_hours=closed" as closed pubs.
Render shops with "opening_hours=closed" as vacant shops.
Now that regional cycle networks are shown, the "name" logic needs to include the name (rather than the ref) in cases where there is no ref.
Show waterway=floating_barrier in the same way as other waterway barriers.
Catch various other ways of detecting locked gates.
Add shop=plant_centre as a garden centre synonym.
Use "is_sidepath" as another tag to suppress names on cycleways etc.
Added pipeline marks to legend.
In "update_render.sh", remove the "pubs" file before sorting the input file into it.
Add "office=politician" in addition to "political_party".
Added more pub outside seating and wheelchair combinations for micropubs and microbreweries.

## 21/04/2022
Render pitch=line as a white line.
Render old_name on farmland if name is not set.
Render natural=tree_group as wood, if it has no other relevant tags.
Treat obstacle=vegetation as overgrown=yes and set trail_visibility accordingly.
Handle intermittent rivers and streams better - make them more visible, but not too prominent.
Added a couple of synonyms for pipeline markers.

## 10/04/2022
Correct the max native zoom on LA PRoW tiles to 18.

## 23/02/2022
Show flowerbeds as green.
Ensure that vaccination centries (e.g. for COVID 19) that aren't already something else get shown as something.  Things that _are_ something else get (e.g. community centres) get left as that something else.
Show wicket_gates as gates.  Detect kissing_gates where tagged as a subtag.
Change "monument" to not assume "building".
"removed:amenity=telephone" is a tag that people use.
Small museums in former phoneboxes are now shown.
If a "holy_well" is actually a spring, ensure it gets rendered as such.
Show stone markers in a similar way to natural stones.
Show aerial pipeline markers.
Don't show stations on e.g. preserved railways as normal railway stations.
If a walking route has no name but does have a colour, render the colour as the name.
Only use old_name on vacant shops and offices.
Show an "outdoor seating" indicator on bars and cafes.
Show beer garden and outside seating indicators on more pubs.
Where "real_ale" is used on breweries, suppress it to avoid them appearing as pubs.
Where "real_ale" is used on hotels and guest houses, render as a pub.
Remove "shop" tag on industrial or craft breweries - we pick one thing to display them as, and in this case it's "brewery".

## 17/02/2022
Fixed some minor issues with the display of crossings.
Show ladders on footways as steps.
Show windsocks.
Render golf=cartpath as wide, not narrow.
Updated taginfo.json  with recent updates.  Also added a number of values through to "barrier".
Remove tourism=attraction if a shop or amenity tag is present.
If board:title is set, use that as the name of information boards.
Changed leisure green dot to a slightly larger more green dot.
Changed some name placements (nonspecific leisure, pubs, breweries) to be centroid instead of point, so that fewer name/icon clashes occur.
Also include regional horse routes in those that are rendered.
Handle various synonyms for e-scooter rental.
Added icon for "eco greengrocers".

## 31/01/2022
Treat the three National Scenic Areas in Scotland as AONBs.
Changed line-cap on some roads to avoid non-embankments to appear "over" embankments of the same class.
On footpaths, if foot=no set access=no.
Where a building would come through as industrial on a building, only display from zoom 17.
Exclude "state=proposed" etc. cycle routes.
Where something is both landuse=grass and leisure=common, only render the name once.
Render various non-water basins as flood_prone.
Fixed a bug where the "legend" button sometimes had to be clicked twice.

## 17/01/2022
Add lots of other clubs (social, sailing, etc.) with no other tags as "leisure".
Added an icon for scooter rental and added to legend.
Changed criteria for national parks to exclude protect_class=5.  Many UK ones are tagged this way, but they will be included by other checks such as on "designation" or explicitly tagged as "boundary=national_park".
Added icons for taxi stand and taxi office, and added to legend.
Following a [taginfo.json](https://taginfo.openstreetmap.org/projects/someoneelse_style#tags) update, removed some tags from the style.lua file that no longer occur in OSM anywhere.
Updating taginfo.json with more key information.  Tag information is complete, but keys processed for those tags is still a work in progress.
Added blue hatching for "intermittent" water areas and a slightly less prominent blue hatching for areas that are merely flood-prone.
Added a rendering for intermittent wetland.
Re-saved some .pngs from gimp to make them much smaller (300 bytes rather than 30k).

## 09/01/2022
Updated taginfo.json  with recent updates.
Updated update_render.sh to handle separate users for "getting things from github" and "running renderd", as now required by Debian 11 and Ubuntu 21.04 and above.

## 05/01/2022
Updated map at map.atownsend.org.uk to show "[flooded](https://github.com/SomeoneElseOSM/floodedmap)" layer and England and Wales-sourced local authority public rights-of-way.
Moved the CSS file used and changed the layer switcher font to be legible on more platforms.
Added attribution for non-OSM layers.

## 26/12/2021
Render flagpoles - normal ones in black; MOD ones in red, show name, and add to legend.
Resolve an issue whereby maypole names weren't displayed at some zoom levels.
Add "office=police" to the list of offices that are rendered.
Render "informal=yes" the same as "trail_visibility=intermediate".
Changed the "big chimney" threshold to 50m so that a couple of very prominent York chimneys pass the threshold.
Remove a couple of no-longer-existing-in-this-form maps from SomeoneElse-map.
Display "location=overgroundground" pipelines as bridges.
Display gantries as pipeline bridges.
Move the handling of some offices from "building" and "landuse" to the "office" tag.
Handle telephone exchanges and some other offices as offices rather than just landuse.
Remove ferry terminals and from landuse=commercial handling.
Don't treat highway=services as rest_area but instead as landuse=commercial.
Handle club=sport via noncommercial leisure rather than landuse.
If there's no other information with a club=yes, assume it is "leisure".

## 21/11/2021
Change start node of legend from 9100000000 to 29100000000 as OSM has now caught up: [node 9100000000 in OSM](https://www.openstreetmap.org/node/9100000000).
Don't show long distance path relations without name or colour.
If something is tagged as both an archaelogical site and a place, lose the place tag.
Don't display building names for amenities if the building tag is empty, or if a name for an amenity is already displayed.

## 10/10/2021
Rearrange legend to split the "shops" line.
Render shop=seafood as its own icon.
Include amenity=scooter_rental in the list of objects for which operator is counted as name.
Don't include disused:amenity=grave_yard as "vacant" if still landuse=cemetery.
Render shop=copyshop and shop=coffee etc. with their own icons.

## 12/09/2021
Render shop=pastry as shop=bakery.
Render shop=optician, shop=shoes, shop=electronics, shop=stationery, shop=catalogue, shop=musical_instrument with their own icons.
Render shop=locksmith and shop=shoe_repair with their own icons.
Render shop=storage_rental with its own icon.
Render shop=health_food with its own icon, and also zero-waste health food shops.
Add an icon for various "soft" homeware shops ("hard" homeware shops still get the furniture icon).

## 02/09/2021
Render various sidewalk:left and sidewalk:right combinations as sidewalk.
If motor_vehicle=no is set on a BOAT, it's likely that a TRO is in place, so render as restricted byway instead.
Render linear barrier=rendering_wall as wall.
Render sinkholes that are mapped as ways as linear cliffs, and sinkholes that are mapped as nodes with a separate icon.
Render zero-waste convenience stores and supermarkets with a distinctive icon.

## 31/07/2021
Render "public_transport=platform" as "highway=platform" if there is no "highway=platform" or "railway=platform" tag.
Render a couple more water man_made=monitoring_station.
Added protect_class=2 to protected areas shown as national parks.
Render castle walls as city walls.

## 31/05/2021
Fix a bug where narrow "designation=public_bridleway; trail_visibility=intermittent" paths were omitted.
Fix a bug where narrow paths without designations with trail_visibility=intermittent" paths were omitted.
Added support for motorcycle_parking (including if mapped as a modifier for amenity=parking).
Treat zero waste shops as other grocers.
Added a few more combinations of ice_cream fast_food.

## 16/05/2021
Render service=aircraft_control and aeroway=control_tower the same as tower:type=aircraft_control.
Render "emergency=lifeguard;lifeguard=tower" as "emergency=lifeguard_tower".
Render "chicken;grill" fast food as "chicken".
Added rendering for historic mass rocks.
Where a phone box is allegedly something else, it probably isn't a phone box any more.  Render as that something else.
Show black, white, blue, green, grey and gold phone boxes as the correct colour rather than red.

## 10/05/2021
Render "highway=busway" as highway=service.
Fix a bug where narrow "designation=public_footpath; trail_visibility=intermittent" paths were omitted.
Render things tagged as natural=shrubbery as hedge areas.

## 29/03/2021
Added support (following wiki vote) for historic=ogham_stone.
The "taginfo.json" list was also updated with recent changes.
Render locked gates differently (with an "L" in the icon) to other gates.
Render more "fast_food" cuisine combinations.
Treat car ports as building=roof, like other similar buildings.
Render holy wells using a variant icon of either a water well or a spring, depending on other tags (see legend for examples).

## 08/03/2021
Render for-pay bicycle_parking differently from free ones.  Also updated legend.
Render highway=trailhead (used only occasionally) as information=route_marker.
Render narrow tracks as narrow.
Render some semicolon network values such as "ncn;nhn;nwn" as an appropriate value (here nhn).
Added rendering for weather, rainfall, sky brightness and earthquake monitoring stations.
Added support for more combinations used on Timpson-like shops.

## 12/01/2021
<!---
On Hetzner server map.atownsend.org.uk:
--->
Treat "foot:physical=no" as "trail_visibility=no".  Description also added to taginfo.json, and taginfo.json updated with openstreetmap-carto-AJT key use as well (only the addr:housename, aerialway and oneway keys pass through unchanged).  Also updated "last updated" date in taginfo.json.
Added support for various sorts of stones - natural=stone, historic=stone, historic=standing_stone, megalith_type=standing_stone, historic=rune_stone, stone_type=ogham_stone.

## 02/01/2021
Display various playground items from zoom 18.
Display waterway=brook as waterway=stream.
Change "width" check for "pathwide" etc. to include any numeric values >= 2, and a selection of common legal non-numeric values.

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
Added "motor_accessories" as "car_parts", "petfood" as "pet", "guns" as "shopnonspecific", "ship_chandler", "chandlers", "kitchen;bathroom_furnishing" as "furniture", "tan", "nail_salon" as "beauty", "locksmiths" as "shopnonspecific" and "christmas" as "gift".
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
Render "highway=waymarker" as "tourism=information" and "information=route_marker".
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

