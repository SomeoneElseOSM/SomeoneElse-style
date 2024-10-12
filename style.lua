-- ----------------------------------------------------------------------------
-- style.lua
--
-- Copyright (C) 2018-2024  Andy Townsend
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.
-- ----------------------------------------------------------------------------
-- Code common to several projects is in "shared_lua.lua".
-- That file is in this repository, but needs to be available on the standard
-- lua path when this script is invoked.  The "update_render.sh" script does 
-- this by:
-- cp /home/${local_filesystem_user}/src/SomeoneElse-style/shared_lua.lua -
--      /usr/local/share/lua/5.3/
-- ----------------------------------------------------------------------------
require "shared_lua"

polygon_keys = { 'boundary', 'building', 'landcover', 'landuse', 'amenity', 'harbour', 'historic', 'leisure', 
      'man_made', 'military', 'natural', 'office', 'place', 'power',
      'public_transport', 'seamark:type', 'shop', 'sport', 'tourism', 'waterway',
      'wetland', 'water', 'aeroway' }

generic_keys = {'access','addr:housename','addr:housenumber','addr:interpolation','admin_level','advertising','aerialway','aeroway','amenity','area','area:highway','barrier',
   'bicycle','brand','bridge','bridleway','booth','boundary','building', 'canoe', 'capital','construction','covered','culvert','cutting','denomination','departures_board','designation','disused','disused:highway','disused:man_made','disused:military','disused:shop','ele',
   'embankment','emergency','entrance','foot','flood_prone','generation:source','geological','golf','government',
   'harbour','hazard_prone','hazard_type','highway','historic','horse','hours','information','intermittent',
   'junction','landcover','landuse','layer','leisure','lcn_ref','lock','locked',
   'man_made','marker','military','motor_car','name','natural','ncn_milepost','office','oneway','operator','opening_hours:covid19','outlet','passenger_information_display','pipeline','pitch','place','playground','poi','population','power','power_source','public_transport',
   'railway','railway:historic','ref','religion','rescue_equipment','route',
   'school','seamark:type','seamark:rescue_station:category','service','shop','sport','surface',
   'toll','tourism','tower:type', 'tracktype','training','tunnel','water','waterway',
   'wetland', 'whitewater', 'width','wood','type', 'zoo' }

function add_z_order(keyvalues)
   z_order = 0
   if (keyvalues["layer"] ~= nil and tonumber(keyvalues["layer"])) then
      z_order = 10*keyvalues["layer"]
   end

   
   zordering_tags = {{ 'railway', nil, 5, 1}, { 'boundary', 'administrative', 0, 1}, 
      { 'bridge', 'yes', 10, 0 }, { 'bridge', 'true', 10, 0 }, { 'bridge', 1, 10, 0 },
      { 'tunnel', 'yes', -10, 0}, { 'tunnel', 'true', -10, 0}, { 'tunnel', 1, -10, 0}, 
      { 'highway', 'road', 2, 0 }, 
      { 'highway', 'unclassified', 3, 0 }, { 'highway', 'unclassified_sidewalk', 3, 0 }, { 'highway', 'unclassified_verge', 3, 0 }, { 'highway', 'unclassified_ford', 3, 0 },
      { 'highway', 'living_street', 3, 0 }, { 'highway', 'living_street_sidewalk', 3, 0 }, { 'highway', 'living_street_verge', 3, 0 }, { 'highway', 'living_street_ford', 3, 0 },
      { 'highway', 'residential', 3, 0 }, 
      { 'highway', 'tertiary_link', 4, 0}, { 'highway', 'tertiary', 4, 0}, { 'highway', 'tertiary_sidewalk', 4, 0}, { 'highway', 'tertiary_verge', 4, 0},
      { 'highway', 'secondary_link', 6, 1}, { 'highway', 'secondary', 6, 1}, { 'highway', 'secondary_sidewalk', 6, 1}, { 'highway', 'secondary_verge', 6, 1},
      { 'highway', 'primary_link', 7, 1}, { 'highway', 'primary', 7, 1},{ 'highway', 'primary_sidewalk', 7, 1},{ 'highway', 'primary_verge', 7, 1},
      { 'highway', 'trunk_link', 8, 1}, { 'highway', 'trunk', 8, 1},
      { 'highway', 'motorway_link', 9, 1}, { 'highway', 'motorway', 9, 1},
      { 'highway', 'ldpnwn', 91, 1}, { 'highway', 'ldpncn', 91, 1}, { 'highway', 'ldpmtb', 91, 1}, { 'highway', 'ldpnhn', 91, 1},
}
   
   for i,k in ipairs(zordering_tags) do
      if ((k[2]  and keyvalues[k[1]] == k[2]) or (k[2] == nil and keyvalues[k[1]] ~= nil)) then
         if (k[4] == 1) then
            roads = 1
         end
         z_order = z_order + k[3]
      end
   end

   keyvalues["z_order"] = z_order

   return keyvalues, roads

end

function filter_tags_generic(keyvalues, nokeys)
-- ----------------------------------------------------------------------------
-- local table for parameter passing
-- ----------------------------------------------------------------------------
   local t = {}
   filter = 0
   tagcount = 0

   if nokeys == 0 then
      filter = 1
      return filter, keyvalues
   end

   delete_tags = { 'FIXME', 'note', 'source' }

   for i,k in ipairs(delete_tags) do
      keyvalues[k] = nil
   end
   
   for k,v in pairs(keyvalues) do
      for i, k2 in ipairs(generic_keys) do if k2 == k then tagcount = tagcount + 1; end end
   end
   if tagcount == 0 then
      filter = 1
   end

-- ----------------------------------------------------------------------------
-- Invalid layer values - change them to something plausible.
-- ----------------------------------------------------------------------------
   keyvalues["layer"] = fix_invalid_layer_values( keyvalues["layer"], keyvalues["bridge"], keyvalues["embankment"] )

-- ----------------------------------------------------------------------------
-- Treat "was:" as "disused:"
-- ----------------------------------------------------------------------------
   if (( keyvalues["was:amenity"]     ~= nil ) and
       ( keyvalues["disused:amenity"] == nil )) then
      keyvalues["disused:amenity"] = keyvalues["was:amenity"]
   end

   if (( keyvalues["was:waterway"]     ~= nil ) and
       ( keyvalues["disused:waterway"] == nil )) then
      keyvalues["disused:waterway"] = keyvalues["was:waterway"]
   end

   if (( keyvalues["was:railway"]     ~= nil ) and
       ( keyvalues["disused:railway"] == nil )) then
      keyvalues["disused:railway"] = keyvalues["was:railway"]
   end

   if (( keyvalues["was:aeroway"]     ~= nil ) and
       ( keyvalues["disused:aeroway"] == nil )) then
      keyvalues["disused:aeroway"] = keyvalues["was:aeroway"]
   end

   if (( keyvalues["was:landuse"]     ~= nil ) and
       ( keyvalues["disused:landuse"] == nil )) then
      keyvalues["disused:landuse"] = keyvalues["was:landuse"]
   end

   if (( keyvalues["was:shop"]     ~= nil ) and
       ( keyvalues["disused:shop"] == nil )) then
      keyvalues["disused:shop"] = keyvalues["was:shop"]
   end

-- ----------------------------------------------------------------------------
-- Treat "closed:" as "disused:" in some cases too.
-- ----------------------------------------------------------------------------
   if (( keyvalues["closed:amenity"]     ~= nil ) and
       ( keyvalues["disused:amenity"] == nil )) then
      keyvalues["disused:amenity"] = keyvalues["closed:amenity"]
   end

   if (( keyvalues["closed:shop"]     ~= nil ) and
       ( keyvalues["disused:shop"] == nil )) then
      keyvalues["disused:shop"] = keyvalues["closed:shop"]
   end

-- ----------------------------------------------------------------------------
-- Treat "status=abandoned" as "disused=yes"
-- ----------------------------------------------------------------------------
   if ( keyvalues["status"] == "abandoned" ) then
      keyvalues["disused"] = "yes"
   end

-- ----------------------------------------------------------------------------
-- Designation processing
--
-- The "standard" stylesheet contains rules for different sorts of tracks 
-- (tracktype), but doesn't contain rules for English/Welsh rights of way
-- designations.
--
-- The changes here do the following:
-- 1) Render any non-designated footway, bridleway, cycleway or track as "path" 
--    (grey dashes in the "standard" style)
-- 2) Render anything designated as "public_footpath" as a "footway" (dotted 
--    salmon)
-- 3) Render anything designated as "public_bridleway" as a "bridleway" (dotted 
--    green).
-- 4) Render anything designated as "restricted_byway" as something a bit like
--    a bridleway, but with different dashes.  Likewise "public_right_of_way".
-- 5) Render anything designated as "byway_open_to_all_traffic" as something
--    like a track (dashed brown)
-- 6) Render anything designated as "unclassified_county_road" or a 
--    misspelling also like a track, but longer dashed brown.
--
-- These changes do mean that the the resulting database isn't any use for
-- anything other than rendering, but they do allow designations to be 
-- displayed without any stylesheet changes.
-- ----------------------------------------------------------------------------
   keyvalues["tracktype"] = nil

-- ----------------------------------------------------------------------------
-- Before processing footways, turn certain corridors into footways
--
-- Note that https://wiki.openstreetmap.org/wiki/Key:indoor defines
-- indoor=corridor as a closed way.  highway=corridor is not documented there
-- but is used for corridors.  We'll only process layer or level 0 (or nil)
-- ----------------------------------------------------------------------------
   keyvalues["highway"] = fix_corridors( keyvalues["highway"], keyvalues["layer"], keyvalues["level"] )

-- ----------------------------------------------------------------------------
-- If there are different names on each side of the street, we create one name
-- containing both.
-- If "name" does not exist but "name:en" does, use that.
-- ----------------------------------------------------------------------------
   keyvalues["name"] = set_name_left_right_en( keyvalues["name"], keyvalues["name:left"], keyvalues["name:right"], keyvalues["name:en"] )

-- ----------------------------------------------------------------------------
-- Move refs to consider as "official" to official_ref
-- ----------------------------------------------------------------------------
   keyvalues["official_ref"] = set_official_ref( keyvalues["official_ref"], keyvalues["highway_authority_ref"], keyvalues["highway_ref"], keyvalues["admin_ref"], keyvalues["admin:ref"], keyvalues["loc_ref"], keyvalues["ref"] )

-- ----------------------------------------------------------------------------
-- Consolidate some rare highway types into ones we can display.
-- ----------------------------------------------------------------------------
   keyvalues["highway"] = process_golf_tracks( keyvalues["highway"], keyvalues["golf"] )

-- ----------------------------------------------------------------------------
-- "Sabristas" sometimes add dubious names to motorway junctions.  Don't show
-- them if they're not signed.
-- ----------------------------------------------------------------------------
   keyvalues["name"] = suppress_unsigned_motorway_junctions( keyvalues["name"], keyvalues["highway"], keyvalues["name:signed"], keyvalues["name:absent"], keyvalues["unsigned"] )

-- ----------------------------------------------------------------------------
-- Move unsigned road refs to the name, in brackets.
-- ----------------------------------------------------------------------------
    t = { keyvalues["name"], keyvalues["highway"], keyvalues["name:signed"], keyvalues["name:absent"], keyvalues["official_ref"], keyvalues["ref"], keyvalues["ref:signed"], keyvalues["unsigned"] }
    suppress_unsigned_road_refs( t )
    keyvalues["name"] = t[1]
    keyvalues["highway"] = t[2]
    keyvalues["name:signed"] = t[3]
    keyvalues["name:absent"] = t[4]
    keyvalues["official_ref"] = t[5]
    keyvalues["ref"] = t[6]
    keyvalues["ref:signed"] = t[7]
    keyvalues["unsigned"] = t[8]

-- ----------------------------------------------------------------------------
-- Show natural=bracken as scrub
-- ----------------------------------------------------------------------------
   if ( keyvalues["natural"]  == "bracken" ) then
      keyvalues["natural"] = "scrub"
   end
 
-- ----------------------------------------------------------------------------
-- Show natural=col as natural=saddle
-- ----------------------------------------------------------------------------
   if ( keyvalues["natural"]  == "col" ) then
      keyvalues["natural"] = "saddle"
   end
 
-- ----------------------------------------------------------------------------
-- Render old names on farmland etc.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["landuse"]  == "farmland"       )  or
        ( keyvalues["natural"]  == "grassland"      )  or
        ( keyvalues["natural"]  == "scrub"          )) and
       (  keyvalues["name"]     == nil               ) and
       (  keyvalues["old_name"] ~= nil               )) then
      keyvalues["name"] = "(" .. keyvalues["old_name"] .. ")"
      keyvalues["old_name"] = nil
   end

-- ----------------------------------------------------------------------------
-- If "visibility" is set but "trail_visibility" is not, use "visibility".
-- ----------------------------------------------------------------------------
   if (( keyvalues["visibility"]       ~= nil ) and
       ( keyvalues["trail_visibility"] == nil )) then
      keyvalues["trail_visibility"] = keyvalues["visibility"]
   end

-- ----------------------------------------------------------------------------
-- Rationalise the various trail_visibility values into 3 sets
-- (no value)    Implied good trail visibility.
--               
-- intermediate  Less trail visibility.  Shown with wider gaps in dotted line
-- bad           Even less trail visibility.  Shown with wider gaps or not shown
--               (depending on designation).
--
-- "trail_visibility=unknown" is treated as "good" since it's been mapped 
-- from aerial imagery.  It's not explicitly referenced below.
--
-- "trail_visibility=low" is treated as "intermediate" based on looking at 
-- the use in OSM.
--
-- Also treat "overgrown=yes" as "intermediate".  A discussion on talk-gb was
-- largely inconclusive, but "overgrown" is the "most renderable" way to deal
-- with things like this.  A later suggestion "foot:physical=no" is also 
-- included.
--
-- "informal=yes" was less common in the UK (but is becoming more so).
-- ----------------------------------------------------------------------------
   if (( keyvalues["trail_visibility"] == "no"         )  or
       ( keyvalues["trail_visibility"] == "none"       )  or
       ( keyvalues["trail_visibility"] == "nil"        )  or
       ( keyvalues["trail_visibility"] == "horrible"   )  or
       ( keyvalues["trail_visibility"] == "very_bad"   )  or
       ( keyvalues["trail_visibility"] == "bad"        )  or
       ( keyvalues["trail_visibility"] == "poor"       )  or
       ( keyvalues["foot:physical"]    == "no"         )) then
      keyvalues["trail_visibility"] = "bad"
   end

   if ((  keyvalues["trail_visibility"] == "intermediate"  )  or
       (  keyvalues["trail_visibility"] == "intermittent"  )  or
       (  keyvalues["trail_visibility"] == "indistinct"    )  or
       (  keyvalues["trail_visibility"] == "medium"        )  or
       (  keyvalues["trail_visibility"] == "low"           )  or
       (  keyvalues["overgrown"]        == "yes"           )  or
       (  keyvalues["obstacle"]         == "vegetation"    )  or
       (( keyvalues["trail_visibility"] == nil            )   and
        ( keyvalues["informal"]         == "yes"          ))) then
      keyvalues["trail_visibility"] = "intermediate"
   end

-- ----------------------------------------------------------------------------
-- If we have an est_width but no width, use the est_width
-- ----------------------------------------------------------------------------
   if (( keyvalues["width"]     == nil  ) and
       ( keyvalues["est_width"] ~= nil  )) then
      keyvalues["width"] = keyvalues["est_width"]
   end

-- ----------------------------------------------------------------------------
-- highway=scramble is used very occasionally
--
-- If sac_scale is unset, set it to "demanding_alpine_hiking" here so that
-- e.g. "badpathnarrow" is set lower down.  
-- If it is already set, use the already-set value.
--
-- Somewhat related, if "scramble=yes" is set and "trail_visibility" isn't,
-- set "trail_visibility==intermediate" so that e.g. "badpathnarrow" is set.
-- ----------------------------------------------------------------------------
   if ( keyvalues["highway"] == "scramble"  ) then
      keyvalues["highway"] = "path"

      if ( keyvalues["sac_scale"] == nil  ) then
         keyvalues["sac_scale"] = "demanding_alpine_hiking"
      end
   end

   if (( keyvalues["highway"]          ~= nil   ) and
       ( keyvalues["scramble"]         == "yes" ) and
       ( keyvalues["sac_scale"]        == nil   ) and
       ( keyvalues["trail_visibility"] == nil   )) then
      keyvalues["trail_visibility"] = "intermediate"
   end

-- ----------------------------------------------------------------------------
-- Suppress non-designated very low-visibility paths
-- Various low-visibility trail_visibility values have been set to "bad" above
-- to suppress from normal display.
-- The "bridge" check (on trail_visibility, not sac_scale) is because if 
-- there's really a bridge there, surely you can see it?
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"]          ~= nil   ) and
       ( keyvalues["designation"]      == nil   ) and
       ( keyvalues["trail_visibility"] == "bad" )) then
      if ((( tonumber(keyvalues["width"]) or 0 ) >=  2 ) or
          ( keyvalues["width"] == "2 m"                ) or
          ( keyvalues["width"] == "2.5 m"              ) or
          ( keyvalues["width"] == "3 m"                ) or
          ( keyvalues["width"] == "4 m"                )) then
         if ( keyvalues["bridge"] == nil ) then
            keyvalues["highway"] = "badpathwide"
         else
            keyvalues["highway"] = "intpathwide"
         end
      else
         if ( keyvalues["bridge"] == nil ) then
            keyvalues["highway"] = "badpathnarrow"
         else
            keyvalues["highway"] = "intpathnarrow"
         end
      end
   end


-- ----------------------------------------------------------------------------
-- Various low-visibility trail_visibility values have been set to "bad" above.
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"] ~= nil   ) and
       ( keyvalues["ladder"]  == "yes" )) then
      keyvalues["highway"] = "steps"
      keyvalues["ladder"]  = nil
   end


-- ----------------------------------------------------------------------------
-- Where a wide width is specified on a normally narrow path, render as wider
--
-- Note that "steps" and "footwaysteps" are unchanged by the 
-- pathwide / path choice below:
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"] == "footway"   ) or 
       ( keyvalues["highway"] == "bridleway" ) or 
       ( keyvalues["highway"] == "cycleway"  ) or
       ( keyvalues["highway"] == "path"      )) then
      if ((( tonumber(keyvalues["width"]) or 0 ) >=  2 ) or
          ( keyvalues["width"] == "2 m"                ) or
          ( keyvalues["width"] == "2.5 m"              ) or
          ( keyvalues["width"] == "3 m"                ) or
          ( keyvalues["width"] == "4 m"                )) then
         if (( keyvalues["trail_visibility"] == "bad"          )  or
             ( keyvalues["trail_visibility"] == "intermediate" )) then
            keyvalues["highway"] = "intpathwide"
         else
            keyvalues["highway"] = "pathwide"
         end
      else
         if (( keyvalues["trail_visibility"] == "bad"          )  or
             ( keyvalues["trail_visibility"] == "intermediate" )) then
            keyvalues["highway"] = "intpathnarrow"
         else
            keyvalues["highway"] = "pathnarrow"
         end
      end
   end

-- ----------------------------------------------------------------------------
-- Where a narrow width is specified on a normally wide track, render as
-- narrower
-- ----------------------------------------------------------------------------
   if ( keyvalues["highway"] == "track" ) then
      if ( keyvalues["width"] == nil ) then
         keyvalues["width"] = "2"
      end
      if ((( tonumber(keyvalues["width"]) or 0 ) >= 2 ) or
          (  keyvalues["width"] == "2 m"              ) or
          (  keyvalues["width"] == "2.5 m"            ) or
          (  keyvalues["width"] == "2.5m"             ) or
          (  keyvalues["width"] == "3 m"              ) or
          (  keyvalues["width"] == "3 metres"         ) or
          (  keyvalues["width"] == "3.5 m"            ) or
          (  keyvalues["width"] == "4 m"              ) or
          (  keyvalues["width"] == "5m"               )) then
         if (( keyvalues["trail_visibility"] == "bad"          )  or
             ( keyvalues["trail_visibility"] == "intermediate" )) then
            keyvalues["highway"] = "intpathwide"
         else
            keyvalues["highway"] = "pathwide"
         end
      else
         if (( keyvalues["trail_visibility"] == "bad"          )  or
             ( keyvalues["trail_visibility"] == "intermediate" )) then
            keyvalues["highway"] = "intpathnarrow"
         else
            keyvalues["highway"] = "pathnarrow"
         end
      end
   end

-- ----------------------------------------------------------------------------
-- Suppress some "demanding" paths.  UK examples with sac_scale:
-- alpine_hiking:
-- http://www.openstreetmap.org/way/168426583   Crib Goch, Snowdon
-- demanding_mountain_hiking:
-- http://www.openstreetmap.org/way/114871124   Near Tryfan
-- difficult_alpine_hiking:
-- http://www.openstreetmap.org/way/334306672   Jack's Rake, Pavey Ark
-- ----------------------------------------------------------------------------
   if ((  keyvalues["designation"] == nil                        ) and
       (( keyvalues["sac_scale"]   == "demanding_alpine_hiking" )  or
        ( keyvalues["sac_scale"]   == "difficult_alpine_hiking" ))) then
      if ((( tonumber(keyvalues["width"]) or 0 ) >=  2 ) or
          ( keyvalues["width"] == "2 m"                ) or
          ( keyvalues["width"] == "2.5 m"              ) or
          ( keyvalues["width"] == "3 m"                ) or
          ( keyvalues["width"] == "4 m"                )) then
         keyvalues["highway"] = "badpathwide"
      else
         keyvalues["highway"] = "badpathnarrow"
      end
   end

-- ----------------------------------------------------------------------------
-- The OSM Carto derivative that I'm using still tries to second-guess paths
-- as footway or cycleway.  We don't want to do this - set "designated" to
-- "yes"
--
-- First - lose "access=designated", which is meaningless.
-- ----------------------------------------------------------------------------
   if ( keyvalues["access"] == "designated" ) then
      keyvalues["access"] = nil
   end

   if ( keyvalues["foot"] == "designated" ) then
      keyvalues["foot"] = "yes"
   end

   if ( keyvalues["bicycle"] == "designated" ) then
      keyvalues["bicycle"] = "yes"
   end

   if ( keyvalues["horse"] == "designated" ) then
      keyvalues["horse"] = "yes"
   end

-- ----------------------------------------------------------------------------
-- Handle dodgy access tags.  Note that this doesn't affect my "designation"
-- processing, but may be used by the main style, as "foot", "bicycle" and 
-- "horse" are all in as columns.
-- ----------------------------------------------------------------------------
   if (keyvalues["access:foot"] == "yes") then
      keyvalues["access:foot"] = nil
      keyvalues["foot"] = "yes"
   end

   if (keyvalues["access:bicycle"] == "yes") then
      keyvalues["access:bicycle"] = nil
      keyvalues["bicycle"] = "yes"
   end

   if (keyvalues["access:horse"] == "yes") then
      keyvalues["access:horse"] = nil
      keyvalues["horse"] = "yes"
   end

-- ----------------------------------------------------------------------------
-- On footpaths, if foot=no set access=no
--
-- Tracks etc. that aren't narrow won't be "pathnarrow" at this stage, and we
-- shouldn't set "access" based on "foot"
--
-- Things that are narrow but have a designation will either not be private to
-- foot traffic or should be picked up by the TRO etc. handling below.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["highway"] == "pathnarrow" ) and
       (( keyvalues["foot"]    == "private"   )  or
        ( keyvalues["foot"]    == "no"        )) and
       (( keyvalues["bicycle"] == nil         )  or
        ( keyvalues["bicycle"] == "private"   )  or
        ( keyvalues["bicycle"] == "no"        )) and
       (( keyvalues["horse"]   == nil         )  or
        ( keyvalues["horse"]   == "private"   )  or
        ( keyvalues["horse"]   == "no"        ))) then
      keyvalues["access"] = "no"
   end

-- ----------------------------------------------------------------------------
-- When handling TROs etc. we test for "no", not private, hence this change:
-- ----------------------------------------------------------------------------
   if ( keyvalues["access"] == "private" ) then
      keyvalues["access"] = "no"
   end

   if ( keyvalues["foot"] == "private" ) then
      keyvalues["foot"] = "no"
   end

   if ( keyvalues["bicycle"] == "private" ) then
      keyvalues["bicycle"] = "no"
   end

   if ( keyvalues["horse"] == "private" ) then
      keyvalues["horse"] = "no"
   end

-- ----------------------------------------------------------------------------
-- Here we apply the track grade rendering to road designations:
--   unpaved roads                      unpaved
--   narrow unclassigned_county_road    ucrnarrow
--   wide unclassigned_county_road      ucrwide
--   narrow BOAT			boatnarrow
--   wide BOAT				boatwide
--   narrow restricted byway		rbynarrow
--   wide restricted byway		rbywide
--
-- prow_ref is appended in brackets if present.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["highway"] == "unclassified"  ) and
       (( keyvalues["surface"] == "unpaved"      )  or 
        ( keyvalues["surface"] == "gravel"       ))) then
      keyvalues["highway"] = "unpaved"
   end

   if ((( keyvalues["highway"] == "residential"  )  or
        ( keyvalues["highway"] == "service"      )) and
       (( keyvalues["surface"] == "unpaved"      )  or 
        ( keyvalues["surface"] == "gravel"       ))) then
      keyvalues["highway"] = "track"
   end

   if (( keyvalues["designation"] == "unclassified_county_road"                       ) or
       ( keyvalues["designation"] == "unclassified_country_road"                      ) or
       ( keyvalues["designation"] == "unclassified_highway"                           ) or
       ( keyvalues["designation"] == "unclassified_road"                              ) or
       ( keyvalues["designation"] == "unmade_road"                                    ) or
       ( keyvalues["designation"] == "public_highway"                                 ) or 
       ( keyvalues["designation"] == "unclassified_highway;public_footpath"           ) or 
       ( keyvalues["designation"] == "unmade_road"                                    ) or 
       ( keyvalues["designation"] == "adopted"                                        ) or 
       ( keyvalues["designation"] == "unclassified_highway;public_bridleway"          ) or 
       ( keyvalues["designation"] == "adopted highway"                                ) or 
       ( keyvalues["designation"] == "adopted_highway"                                ) or 
       ( keyvalues["designation"] == "unclassified_highway;byway_open_to_all_traffic" ) or 
       ( keyvalues["designation"] == "adopted_highway;public_footpath"                ) or 
       ( keyvalues["designation"] == "tertiary_highway"                               ) or 
       ( keyvalues["designation"] == "public_road"                                    ) or
       ( keyvalues["designation"] == "quiet_lane;unclassified_highway"                ) or
       ( keyvalues["designation"] == "unclassified_highway;quiet_lane"                )) then
      if (( keyvalues["highway"] == "steps"         ) or 
	  ( keyvalues["highway"] == "intpathnarrow" ) or
	  ( keyvalues["highway"] == "pathnarrow"    )) then
	  keyvalues["highway"] = "ucrnarrow"
      else
         if (( keyvalues["highway"] == "service"     ) or 
             ( keyvalues["highway"] == "road"        ) or
             ( keyvalues["highway"] == "track"       ) or
             ( keyvalues["highway"] == "intpathwide" ) or
             ( keyvalues["highway"] == "pathwide"    )) then
	     keyvalues["highway"] = "ucrwide"
         end
      end
      if ( keyvalues["prow_ref"] ~= nil ) then
         if ( keyvalues["name"] == nil ) then
            keyvalues["name"]     = "(" .. keyvalues["prow_ref"] .. ")"
            keyvalues["prow_ref"] = nil
         else
            keyvalues["name"]     = keyvalues["name"] .. " (" .. keyvalues["prow_ref"] .. ")"
            keyvalues["prow_ref"] = nil
         end
      end
   end

   if (( keyvalues["designation"] == "byway_open_to_all_traffic" ) or
       ( keyvalues["designation"] == "public_byway"              ) or 
       ( keyvalues["designation"] == "byway"                     ) or
       ( keyvalues["designation"] == "carriageway"               )) then
      if (( keyvalues["highway"] == "steps"         ) or 
	  ( keyvalues["highway"] == "intpathnarrow" ) or
	  ( keyvalues["highway"] == "pathnarrow"    )) then
	  keyvalues["highway"] = "boatnarrow"
	  keyvalues["designation"] = "byway_open_to_all_traffic"
      else
         if (( keyvalues["highway"] == "service"     ) or 
             ( keyvalues["highway"] == "road"        ) or
             ( keyvalues["highway"] == "track"       ) or
             ( keyvalues["highway"] == "intpathwide" ) or
             ( keyvalues["highway"] == "pathwide"    )) then
	     keyvalues["highway"] = "boatwide"
	     keyvalues["designation"] = "byway_open_to_all_traffic"
         end
      end
      if ( keyvalues["prow_ref"] ~= nil ) then
         if ( keyvalues["name"] == nil ) then
            keyvalues["name"]     = "(" .. keyvalues["prow_ref"] .. ")"
            keyvalues["prow_ref"] = nil
         else
            keyvalues["name"]     = keyvalues["name"] .. " (" .. keyvalues["prow_ref"] .. ")"
            keyvalues["prow_ref"] = nil
         end
      end
   end

-- ----------------------------------------------------------------------------
-- Note that a designated restricted_byway up some steps would be rendered
-- as a restricted_byway.  I've never seen one though.
-- There is special processing for "public footpath" and "public_bridleway"
-- steps (see below) and non-designated steps are rendered as is by the
-- stylesheet.
-- ----------------------------------------------------------------------------
   if (( keyvalues["designation"] == "restricted_byway"                        ) or
       ( keyvalues["designation"] == "public_right_of_way"                     ) or
       ( keyvalues["designation"] == "unclassified_highway;restricted_byway"   ) or 
       ( keyvalues["designation"] == "unknown_byway"                           ) or 
       ( keyvalues["designation"] == "public_way"                              ) or 
       ( keyvalues["designation"] == "tertiary_highway;restricted_byway"       ) or 
       ( keyvalues["designation"] == "orpa"                                    ) or
       ( keyvalues["designation"] == "restricted_byway;quiet_lane"             )) then
      if (( keyvalues["highway"] == "steps"         ) or 
	  ( keyvalues["highway"] == "intpathnarrow" ) or
	  ( keyvalues["highway"] == "pathnarrow"    )) then
         keyvalues["highway"] = "rbynarrow"
         keyvalues["designation"] = "restricted_byway"
      else
         if (( keyvalues["highway"] == "service"     ) or 
             ( keyvalues["highway"] == "road"        ) or
             ( keyvalues["highway"] == "track"       ) or
             ( keyvalues["highway"] == "intpathwide" ) or
             ( keyvalues["highway"] == "pathwide"    )) then
	    keyvalues["highway"] = "rbywide"
            keyvalues["designation"] = "restricted_byway"
         end
      end
      if ( keyvalues["prow_ref"] ~= nil ) then
         if ( keyvalues["name"] == nil ) then
            keyvalues["name"]     = "(" .. keyvalues["prow_ref"] .. ")"
            keyvalues["prow_ref"] = nil
         else
            keyvalues["name"]     = keyvalues["name"] .. " (" .. keyvalues["prow_ref"] .. ")"
            keyvalues["prow_ref"] = nil
         end
      end
   end

-- ----------------------------------------------------------------------------
-- When a value is changed we get called again.  That's why there's a check
-- for "bridlewaysteps" below "before the only place that it can be set".
-- ----------------------------------------------------------------------------
   if (( keyvalues["designation"] == "public_bridleway"                    ) or
       ( keyvalues["designation"] == "bridleway"                           ) or 
       ( keyvalues["designation"] == "tertiary_highway;public_bridleway"   ) or 
       ( keyvalues["designation"] == "public_bridleway;public_cycleway"    ) or 
       ( keyvalues["designation"] == "public_cycleway;public_bridleway"    ) or 
       ( keyvalues["designation"] == "public_bridleway;public_footpath"    )) then
      if (( keyvalues["highway"] == "intpathnarrow" ) or
	  ( keyvalues["highway"] == "pathnarrow"    )) then
         if (( keyvalues["trail_visibility"] == "bad"          )  or
             ( keyvalues["trail_visibility"] == "intermediate" )) then
            keyvalues["highway"] = "intbridlewaynarrow"
         else
            keyvalues["highway"] = "bridlewaynarrow"
         end
      else
         if (( keyvalues["highway"] == "steps"          ) or
             ( keyvalues["highway"] == "bridlewaysteps" )) then
            keyvalues["highway"] = "bridlewaysteps"
         else
            if (( keyvalues["highway"] == "service"     ) or 
                ( keyvalues["highway"] == "road"        ) or
                ( keyvalues["highway"] == "track"       ) or
                ( keyvalues["highway"] == "intpathwide" ) or
                ( keyvalues["highway"] == "pathwide"    )) then
               if (( keyvalues["trail_visibility"] == "bad"          )  or
                   ( keyvalues["trail_visibility"] == "intermediate" )) then
                  keyvalues["highway"] = "intbridlewaywide"
               else
                  keyvalues["highway"] = "bridlewaywide"
               end
            end
         end
      end
      if ( keyvalues["prow_ref"] ~= nil ) then
         if ( keyvalues["name"] == nil ) then
            keyvalues["name"]     = "(" .. keyvalues["prow_ref"] .. ")"
            keyvalues["prow_ref"] = nil
         else
            keyvalues["name"]     = keyvalues["name"] .. " (" .. keyvalues["prow_ref"] .. ")"
            keyvalues["prow_ref"] = nil
         end
      end
   end

-- ----------------------------------------------------------------------------
-- When a value is changed we get called again.  That's why there's a check
-- for "footwaysteps" below "before the only place that it can be set".
--
-- Rights of way for people on foot are designated as:
-- England and Wales: public_footpath
-- Scotland: core_path (ish - more general acess rights exist)
-- Northern Ireland: public_footpath or PROW (actually "footpath" in law)
-- ----------------------------------------------------------------------------
   if (( keyvalues["designation"] == "public_footpath"                        ) or
       ( keyvalues["designation"] == "core_path"                              ) or 
       ( keyvalues["designation"] == "footpath"                               ) or 
       ( keyvalues["designation"] == "public_footway"                         ) or 
       ( keyvalues["designation"] == "public_footpath;permissive_bridleway"   ) or 
       ( keyvalues["designation"] == "public_footpath;public_cycleway"        ) or
       ( keyvalues["designation"] == "PROW"                                   ) or
       ( keyvalues["designation"] == "access_land"                            )) then
      if (( keyvalues["highway"] == "intpathnarrow" ) or
          ( keyvalues["highway"] == "pathnarrow"    )) then
         if (( keyvalues["trail_visibility"] == "bad"          )  or
             ( keyvalues["trail_visibility"] == "intermediate" )) then
            keyvalues["highway"] = "intfootwaynarrow"
         else
            keyvalues["highway"] = "footwaynarrow"
         end
      else
         if (( keyvalues["highway"] == "steps"        ) or
             ( keyvalues["highway"] == "footwaysteps" )) then
            keyvalues["highway"] = "footwaysteps"
         else
            if (( keyvalues["highway"] == "service"     ) or 
                ( keyvalues["highway"] == "road"        ) or
                ( keyvalues["highway"] == "track"       ) or
                ( keyvalues["highway"] == "intpathwide" ) or
                ( keyvalues["highway"] == "pathwide"    )) then
               if (( keyvalues["trail_visibility"] == "bad"          )  or
                   ( keyvalues["trail_visibility"] == "intermediate" )) then
                  keyvalues["highway"] = "intfootwaywide"
               else
                  keyvalues["highway"] = "footwaywide"
               end
            end
         end
      end
      if ( keyvalues["prow_ref"] ~= nil ) then
         if ( keyvalues["name"] == nil ) then
            keyvalues["name"]     = "(" .. keyvalues["prow_ref"] .. ")"
            keyvalues["prow_ref"] = nil
         else
            keyvalues["name"]     = keyvalues["name"] .. " (" .. keyvalues["prow_ref"] .. ")"
            keyvalues["prow_ref"] = nil
         end
      end
   end

-- ----------------------------------------------------------------------------
-- If something is still "track" by this point change it to pathwide.
-- ----------------------------------------------------------------------------
   if ( keyvalues["highway"] == "track" ) then
      if (( keyvalues["trail_visibility"] == "bad"          )  or
          ( keyvalues["trail_visibility"] == "intermediate" )) then
         keyvalues["highway"] = "intpathwide"
      else
         keyvalues["highway"] = "pathwide"
      end
   end

-- ----------------------------------------------------------------------------
-- Treat access=permit as access=no (which is what we have set "private" to 
-- above).
-- ----------------------------------------------------------------------------
   if (( keyvalues["access"]  == "permit"       ) or
       ( keyvalues["access"]  == "agricultural" ) or
       ( keyvalues["access"]  == "forestry"     ) or
       ( keyvalues["access"]  == "delivery"     ) or
       ( keyvalues["access"]  == "military"     )) then
      keyvalues["access"] = "no"
   end

   if ( keyvalues["access"]  == "customers" ) then
      keyvalues["access"] = "destination"
   end

-- ----------------------------------------------------------------------------
-- Don't make driveways with a designation disappear.
-- ----------------------------------------------------------------------------
   if ((    keyvalues["service"]     == "driveway"                     ) and
       ((   keyvalues["designation"] == "public_footpath"             )  or
        (   keyvalues["designation"] == "public_bridleway"            )  or
        (   keyvalues["designation"] == "restricted_byway"            )  or
        (   keyvalues["designation"] == "byway_open_to_all_traffic"   )  or
        (   keyvalues["designation"] == "unclassified_county_road"    )  or
        (   keyvalues["designation"] == "unclassified_country_road"   )  or
        (   keyvalues["designation"] == "unclassified_highway"        ))) then
      keyvalues["service"] = nil
   end

-- ----------------------------------------------------------------------------
-- If motor_vehicle=no is set on a BOAT, it's probably a TRO, so display as
-- an RBY instead
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"]       == "boatwide"    )  and
       ( keyvalues["motor_vehicle"] == "no"          )) then
      keyvalues["highway"] = "rbywide"
   end

   if (( keyvalues["highway"]       == "boatnarrow"  )  and
       ( keyvalues["motor_vehicle"] == "no"          )) then
      keyvalues["highway"] = "rbynarrow"
   end

-- ----------------------------------------------------------------------------
-- Try and detect genuinely closed public footpaths, bridleways (not just those
-- closed to motor traffic etc.).  Examples with "access=no/private" are
-- picked up below; we need to make sure that those that do not get an
-- access=private tag first.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["access"]      == nil                          )  and
       (( keyvalues["designation"] == "public_footpath"           )   or
        ( keyvalues["designation"] == "public_bridleway"          )   or
        ( keyvalues["designation"] == "restricted_byway"          )   or
        ( keyvalues["designation"] == "byway_open_to_all_traffic" )   or
        ( keyvalues["designation"] == "unclassified_county_road"  )   or
        ( keyvalues["designation"] == "unclassified_country_road" )   or
        ( keyvalues["designation"] == "unclassified_highway"      ))  and
       (  keyvalues["foot"]        == "no"                         )) then
      keyvalues["access"]  = "no"
   end

-- ----------------------------------------------------------------------------
-- The extra information "and"ed with "public_footpath" below checks that
-- "It's access=private and designation=public_footpath, and ordinarily we'd
-- just remove the access=private tag as you ought to be able to walk there,
-- unless there isn't foot=yes/designated to say you can, or there is an 
-- explicit foot=no".
-- ----------------------------------------------------------------------------
   if (((   keyvalues["access"]      == "no"                          )  or
        (   keyvalues["access"]      == "destination"                 )) and
       (((( keyvalues["designation"] == "public_footpath"           )    or
          ( keyvalues["designation"] == "public_bridleway"          )    or
          ( keyvalues["designation"] == "restricted_byway"          )    or
          ( keyvalues["designation"] == "byway_open_to_all_traffic" )    or
          ( keyvalues["designation"] == "unclassified_county_road"  )    or
          ( keyvalues["designation"] == "unclassified_country_road" )    or
          ( keyvalues["designation"] == "unclassified_highway"      ))   and
         (  keyvalues["foot"]        ~= nil                          )   and
         (  keyvalues["foot"]        ~= "no"                         ))  or
        ((( keyvalues["highway"]     == "pathnarrow"                )    or
          ( keyvalues["highway"]     == "pathwide"                  )    or
          ( keyvalues["highway"]     == "intpathnarrow"             )    or
          ( keyvalues["highway"]     == "intpathwide"               )    or
          ( keyvalues["highway"]     == "service"                   ))   and
         (( keyvalues["foot"]        == "permissive"                )    or
          ( keyvalues["foot"]        == "yes"                       ))))) then
      keyvalues["access"]  = nil
   end

-- ----------------------------------------------------------------------------
-- Render national parks and AONBs as such no matter how they are tagged.
--
-- Any with "boundary=national_park" set already will be included and won't
-- be affected by this.  Most national parks and AONBs in UK have 
-- "protect_class=5", but also have one of the "designation" values below.
-- Many smaller nature reserves have other values for designation and are
-- ignored here.
--
-- Previously this section also had "protect_class=2" because IE ones had that 
-- and not "boundary"="national_park", but that situation seems to have changed.
-- ----------------------------------------------------------------------------
   if ((   keyvalues["boundary"]      == "protected_area"                      ) and
       ((  keyvalues["designation"]   == "national_park"                      )  or 
        (  keyvalues["designation"]   == "area_of_outstanding_natural_beauty" )  or
        (  keyvalues["designation"]   == "national_scenic_area"               ))) then
      keyvalues["boundary"] = "national_park"
      keyvalues["protect_class"] = nil
   end

-- ----------------------------------------------------------------------------
-- Access land is shown with a high-zoom yellow border (to contrast with the 
-- high-zoom green border of nature reserves) and with a low-opacity 
-- yellow fill at all zoom levels (to contrast with the low-opacity green fill
-- at low zoom levels of nature reserves.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["designation"]   == "access_land"     )  and
       (( keyvalues["boundary"]      == nil              )   or
        ( keyvalues["boundary"]      == "protected_area" ))  and
       (  keyvalues["highway"]       == nil               )) then
      keyvalues["boundary"] = "access_land"
   end

-- ----------------------------------------------------------------------------
-- Render certain protect classes and designations of protected areas as 
-- nature_reserve:
-- protect_class==1   "... strictly set aside to protect ... " (all sorts)
-- protect_class==4   "Habitat/Species Management Area"
--
-- There are a few instances of "leisure" being set to something else already
-- ("common", "park", "golf_course", "dog_park").  We leave that if so.
--
-- This selection does not currently include:
-- protect_class==98  "intercontinental treaties..." (e.g. world heritage)
-- ----------------------------------------------------------------------------
   if (((  keyvalues["boundary"]      == "protected_area"            )   and
        (( keyvalues["protect_class"] == "1"                        )    or
         ( keyvalues["protect_class"] == "2"                        )    or
         ( keyvalues["protect_class"] == "4"                        )    or
         ( keyvalues["designation"]   == "national_nature_reserve"  )    or
         ( keyvalues["designation"]   == "local_nature_reserve"     )    or
         ( keyvalues["designation"]   == "Nature Reserve"           )    or
         ( keyvalues["designation"]   == "Marine Conservation Zone" ))) and
       (   keyvalues["leisure"]       == nil                          )) then
      keyvalues["leisure"] = "nature_reserve"
   end

-- ----------------------------------------------------------------------------
-- Show grass schoolyards as green
-- ----------------------------------------------------------------------------
   if (( keyvalues["leisure"] == "schoolyard" ) and
       ( keyvalues["surface"] == "grass"      )) then
      keyvalues["landuse"] = "grass"
      keyvalues["leisure"] = nil
      keyvalues["surface"] = nil
   end

-- ----------------------------------------------------------------------------
-- "Nature reserve" doesn't say anything about what's inside; but one UK OSMer 
-- changed "landuse" to "surface" (changeset 98859964).  This undoes that.
-- ----------------------------------------------------------------------------
   if (( keyvalues["leisure"] == "nature_reserve" ) and
       ( keyvalues["surface"] == "grass"          )) then
      keyvalues["landuse"] = "grass"
      keyvalues["surface"] = nil
   end

-- ----------------------------------------------------------------------------
-- Treat landcover=grass as landuse=grass
-- Also landuse=college_court, flowerbed
-- ----------------------------------------------------------------------------
   if (( keyvalues["landcover"] == "grass"         ) or
       ( keyvalues["landuse"]   == "college_court" ) or
       ( keyvalues["landuse"]   == "flowerbed"     )) then
      keyvalues["landcover"] = nil
      keyvalues["landuse"] = "grass"
   end

-- ----------------------------------------------------------------------------
-- Treat natural=grass as landuse=grass 
-- if there is no other more appropriate tag
-- ----------------------------------------------------------------------------
   if (( keyvalues["natural"]  == "grass"  ) and
       (( keyvalues["landuse"] == nil     )  and
        ( keyvalues["leisure"] == nil     )  and
        ( keyvalues["aeroway"] == nil     ))) then
      keyvalues["landuse"] = "grass"
   end

-- ----------------------------------------------------------------------------
-- Treat natural=garden and natural=plants as leisure=garden
-- if there is no other more appropriate tag.
-- The "barrier" check is to avoid linear barriers with this tag as well 
-- becoming area ones unexpectedly
-- ----------------------------------------------------------------------------
   if ((( keyvalues["natural"] == "garden"     )   or
        ( keyvalues["natural"] == "plants"     )   or
        ( keyvalues["natural"] == "flower_bed" ))  and
       (( keyvalues["landuse"] == nil          )   and
        ( keyvalues["leisure"] == nil          )   and
        ( keyvalues["barrier"] == nil          ))) then
      keyvalues["leisure"] = "garden"
   end

-- ----------------------------------------------------------------------------
-- Render various synonyms for leisure=common.
-- ----------------------------------------------------------------------------
   if (( keyvalues["landuse"]          == "common"   ) or
       ( keyvalues["leisure"]          == "common"   ) or
       ( keyvalues["designation"]      == "common"   ) or
       ( keyvalues["amenity"]          == "common"   ) or
       ( keyvalues["protection_title"] == "common"   )) then
      keyvalues["leisure"] = "common"
      keyvalues["landuse"] = nil
      keyvalues["amenity"] = nil
   end

-- ----------------------------------------------------------------------------
-- Render quiet lanes as living streets.
-- This is done because it's a difference I don't want to draw attention to -
-- they aren't "different enough to make them render differently".
-- ----------------------------------------------------------------------------
   if ((( keyvalues["highway"]     == "tertiary"                          )  or
        ( keyvalues["highway"]     == "unclassified"                      )  or
        ( keyvalues["highway"]     == "residential"                       )) and
       (( keyvalues["designation"] == "quiet_lane"                        )  or
        ( keyvalues["designation"] == "quiet_lane;unclassified_highway"   )  or
        ( keyvalues["designation"] == "unclassified_highway;quiet_lane"   ))) then
      keyvalues["highway"] = "living_street"
   end

-- ----------------------------------------------------------------------------
-- Use unclassified_sidewalk to indicate sidewalk
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"] == "unclassified"       ) or 
       ( keyvalues["highway"] == "unclassified_link"  ) or
       ( keyvalues["highway"] == "residential"        ) or
       ( keyvalues["highway"] == "residential_link"   )) then
      if (( keyvalues["sidewalk"] == "both"            ) or 
          ( keyvalues["sidewalk"] == "left"            ) or 
          ( keyvalues["sidewalk"] == "mapped"          ) or 
          ( keyvalues["sidewalk"] == "separate"        ) or 
          ( keyvalues["sidewalk"] == "right"           ) or 
          ( keyvalues["sidewalk"] == "shared"          ) or 
          ( keyvalues["sidewalk"] == "yes"             ) or
          ( keyvalues["sidewalk:left"] == "separate"   ) or 
          ( keyvalues["sidewalk:left"] == "yes"        ) or
          ( keyvalues["sidewalk:left"] == "segregated" ) or
          ( keyvalues["sidewalk:right"] == "separate"  ) or 
          ( keyvalues["sidewalk:right"] == "yes"       ) or
          ( keyvalues["sidewalk:both"] == "separate"   ) or 
          ( keyvalues["sidewalk:both"] == "yes"        ) or
          ( keyvalues["footway"]  == "separate"        ) or 
          ( keyvalues["footway"]  == "yes"             ) or
          ( keyvalues["shoulder"] == "both"            ) or
          ( keyvalues["shoulder"] == "left"            ) or 
          ( keyvalues["shoulder"] == "right"           ) or 
          ( keyvalues["shoulder"] == "yes"             ) or
          ( keyvalues["hard_shoulder"] == "yes"        ) or
          ( keyvalues["cycleway"] == "track"           ) or
          ( keyvalues["cycleway"] == "opposite_track"  ) or
          ( keyvalues["cycleway"] == "yes"             ) or
          ( keyvalues["cycleway"] == "separate"        ) or
          ( keyvalues["cycleway"] == "sidewalk"        ) or
          ( keyvalues["cycleway"] == "sidepath"        ) or
          ( keyvalues["cycleway"] == "segregated"      ) or
          ( keyvalues["segregated"] == "yes"           ) or
          ( keyvalues["segregated"] == "right"         )) then
          keyvalues["highway"] = "unclassified_sidewalk"
      end
   end

-- ----------------------------------------------------------------------------
-- Use unclassified_verge to indicate verge
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"] == "unclassified"      ) or 
       ( keyvalues["highway"] == "unclassified_link" ) or
       ( keyvalues["highway"] == "residential"       ) or
       ( keyvalues["highway"] == "residential_link"  )) then
      if (( keyvalues["verge"] == "both"           ) or 
          ( keyvalues["verge"] == "left"           ) or 
          ( keyvalues["verge"] == "separate"       ) or 
          ( keyvalues["verge"] == "right"          ) or 
          ( keyvalues["verge"] == "yes"            )) then
          keyvalues["highway"] = "unclassified_verge"
      end
   end

-- ----------------------------------------------------------------------------
-- Use unclassified_ford to indicate ford
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"] == "unclassified"      ) or 
       ( keyvalues["highway"] == "unclassified_link" ) or
       ( keyvalues["highway"] == "residential"       ) or
       ( keyvalues["highway"] == "residential_link"  )) then
      if ( keyvalues["ford"] == "yes" ) then
          keyvalues["highway"] = "unclassified_ford"
      end
   end

-- ----------------------------------------------------------------------------
-- Use living_street_sidewalk to indicate sidewalk
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"] == "living_street"       ) or 
       ( keyvalues["highway"] == "living_street_link"  )) then
      if (( keyvalues["sidewalk"] == "both"            ) or 
          ( keyvalues["sidewalk"] == "left"            ) or 
          ( keyvalues["sidewalk"] == "mapped"          ) or 
          ( keyvalues["sidewalk"] == "separate"        ) or 
          ( keyvalues["sidewalk"] == "right"           ) or 
          ( keyvalues["sidewalk"] == "shared"          ) or 
          ( keyvalues["sidewalk"] == "yes"             ) or
          ( keyvalues["sidewalk:left"] == "separate"   ) or 
          ( keyvalues["sidewalk:left"] == "yes"        ) or
          ( keyvalues["sidewalk:left"] == "segregated" ) or
          ( keyvalues["sidewalk:right"] == "separate"  ) or 
          ( keyvalues["sidewalk:right"] == "yes"       ) or
          ( keyvalues["sidewalk:both"] == "separate"   ) or 
          ( keyvalues["sidewalk:both"] == "yes"        ) or
          ( keyvalues["footway"]  == "separate"        ) or 
          ( keyvalues["footway"]  == "yes"             ) or
          ( keyvalues["shoulder"] == "both"            ) or
          ( keyvalues["shoulder"] == "left"            ) or 
          ( keyvalues["shoulder"] == "right"           ) or 
          ( keyvalues["shoulder"] == "yes"             ) or
          ( keyvalues["hard_shoulder"] == "yes"        ) or
          ( keyvalues["cycleway"] == "track"           ) or
          ( keyvalues["cycleway"] == "opposite_track"  ) or
          ( keyvalues["cycleway"] == "yes"             ) or
          ( keyvalues["cycleway"] == "separate"        ) or
          ( keyvalues["cycleway"] == "sidewalk"        ) or
          ( keyvalues["cycleway"] == "sidepath"        ) or
          ( keyvalues["cycleway"] == "segregated"      ) or
          ( keyvalues["segregated"] == "yes"           ) or
          ( keyvalues["segregated"] == "right"         )) then
          keyvalues["highway"] = "living_street_sidewalk"
      end
   end

-- ----------------------------------------------------------------------------
-- Use living_street_verge to indicate verge
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"] == "living_street"      ) or 
       ( keyvalues["highway"] == "living_street_link" )) then
      if (( keyvalues["verge"] == "both"           ) or 
          ( keyvalues["verge"] == "left"           ) or 
          ( keyvalues["verge"] == "separate"       ) or 
          ( keyvalues["verge"] == "right"          ) or 
          ( keyvalues["verge"] == "yes"            )) then
          keyvalues["highway"] = "living_street_verge"
      end
   end

-- ----------------------------------------------------------------------------
-- Use living_street_ford to indicate ford
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"] == "living_street"      ) or 
       ( keyvalues["highway"] == "living_street_link" )) then
      if ( keyvalues["ford"] == "yes" ) then
          keyvalues["highway"] = "living_street_ford"
      end
   end

-- ----------------------------------------------------------------------------
-- Use service_ford to indicate ford
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"] == "service"      ) or
       ( keyvalues["highway"] == "service_link" )) then
      if ( keyvalues["ford"] == "yes" ) then
          keyvalues["highway"] = "service_ford"
      end
   end

-- ----------------------------------------------------------------------------
-- Use tertiary_sidewalk to indicate sidewalk
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"] == "tertiary"      ) or 
       ( keyvalues["highway"] == "tertiary_link" )) then
      if (( keyvalues["sidewalk"] == "both"            ) or 
          ( keyvalues["sidewalk"] == "left"            ) or 
          ( keyvalues["sidewalk"] == "mapped"          ) or 
          ( keyvalues["sidewalk"] == "separate"        ) or 
          ( keyvalues["sidewalk"] == "right"           ) or 
          ( keyvalues["sidewalk"] == "shared"          ) or 
          ( keyvalues["sidewalk"] == "yes"             ) or
          ( keyvalues["sidewalk:left"] == "separate"   ) or 
          ( keyvalues["sidewalk:left"] == "yes"        ) or
          ( keyvalues["sidewalk:left"] == "segregated" ) or
          ( keyvalues["sidewalk:right"] == "separate"  ) or 
          ( keyvalues["sidewalk:right"] == "yes"       ) or
          ( keyvalues["sidewalk:both"] == "separate"   ) or 
          ( keyvalues["sidewalk:both"] == "yes"        ) or
          ( keyvalues["footway"]  == "separate"        ) or 
          ( keyvalues["footway"]  == "yes"             ) or
          ( keyvalues["shoulder"] == "both"            ) or
          ( keyvalues["shoulder"] == "left"            ) or 
          ( keyvalues["shoulder"] == "right"           ) or 
          ( keyvalues["shoulder"] == "yes"             ) or
          ( keyvalues["cycleway"] == "track"           ) or
          ( keyvalues["cycleway"] == "opposite_track"  ) or
          ( keyvalues["cycleway"] == "yes"             ) or
          ( keyvalues["cycleway"] == "separate"        ) or
          ( keyvalues["cycleway"] == "sidewalk"        ) or
          ( keyvalues["cycleway"] == "sidepath"        ) or
          ( keyvalues["cycleway"] == "segregated"      ) or
          ( keyvalues["segregated"] == "yes"           ) or
          ( keyvalues["segregated"] == "right"         )) then
          keyvalues["highway"] = "tertiary_sidewalk"
      end
   end

-- ----------------------------------------------------------------------------
-- Use tertiary_verge to indicate verge
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"] == "tertiary"      ) or 
       ( keyvalues["highway"] == "tertiary_link" )) then
      if (( keyvalues["verge"] == "both"           ) or 
          ( keyvalues["verge"] == "left"           ) or 
          ( keyvalues["verge"] == "separate"       ) or 
          ( keyvalues["verge"] == "right"          ) or 
          ( keyvalues["verge"] == "yes"            )) then
          keyvalues["highway"] = "tertiary_verge"
      end
   end

-- ----------------------------------------------------------------------------
-- Use tertiary_ford to indicate ford
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"] == "tertiary"      ) or 
       ( keyvalues["highway"] == "tertiary_link" )) then
      if ( keyvalues["ford"] == "yes" ) then
          keyvalues["highway"] = "tertiary_ford"
      end
   end

-- ----------------------------------------------------------------------------
-- Use secondary_sidewalk to indicate sidewalk
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"] == "secondary"      ) or 
       ( keyvalues["highway"] == "secondary_link" )) then
      if (( keyvalues["sidewalk"] == "both"            ) or 
          ( keyvalues["sidewalk"] == "left"            ) or 
          ( keyvalues["sidewalk"] == "mapped"          ) or 
          ( keyvalues["sidewalk"] == "separate"        ) or 
          ( keyvalues["sidewalk"] == "right"           ) or 
          ( keyvalues["sidewalk"] == "shared"          ) or 
          ( keyvalues["sidewalk"] == "yes"             ) or
          ( keyvalues["sidewalk:left"] == "separate"   ) or 
          ( keyvalues["sidewalk:left"] == "yes"        ) or
          ( keyvalues["sidewalk:left"] == "segregated" ) or
          ( keyvalues["sidewalk:right"] == "separate"  ) or 
          ( keyvalues["sidewalk:right"] == "yes"       ) or
          ( keyvalues["sidewalk:both"] == "separate"   ) or 
          ( keyvalues["sidewalk:both"] == "yes"        ) or
          ( keyvalues["footway"]  == "separate"        ) or 
          ( keyvalues["footway"]  == "yes"             ) or
          ( keyvalues["shoulder"] == "both"            ) or
          ( keyvalues["shoulder"] == "left"            ) or 
          ( keyvalues["shoulder"] == "right"           ) or 
          ( keyvalues["shoulder"] == "yes"             ) or
          ( keyvalues["cycleway"] == "track"           ) or
          ( keyvalues["cycleway"] == "opposite_track"  ) or
          ( keyvalues["cycleway"] == "yes"             ) or
          ( keyvalues["cycleway"] == "separate"        ) or
          ( keyvalues["cycleway"] == "sidewalk"        ) or
          ( keyvalues["cycleway"] == "sidepath"        ) or
          ( keyvalues["cycleway"] == "segregated"      ) or
          ( keyvalues["segregated"] == "yes"           ) or
          ( keyvalues["segregated"] == "right"         )) then
          keyvalues["highway"] = "secondary_sidewalk"
      end
   end

-- ----------------------------------------------------------------------------
-- Use secondary_verge to indicate verge
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"] == "secondary"      ) or 
       ( keyvalues["highway"] == "secondary_link" )) then
      if (( keyvalues["verge"] == "both"           ) or 
          ( keyvalues["verge"] == "left"           ) or 
          ( keyvalues["verge"] == "separate"       ) or 
          ( keyvalues["verge"] == "right"          ) or 
          ( keyvalues["verge"] == "yes"            )) then
          keyvalues["highway"] = "secondary_verge"
      end
   end

-- ----------------------------------------------------------------------------
-- Use primary_sidewalk to indicate sidewalk
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"] == "primary"      ) or 
       ( keyvalues["highway"] == "primary_link" )) then
      if (( keyvalues["sidewalk"] == "both"            ) or 
          ( keyvalues["sidewalk"] == "left"            ) or 
          ( keyvalues["sidewalk"] == "mapped"          ) or 
          ( keyvalues["sidewalk"] == "separate"        ) or 
          ( keyvalues["sidewalk"] == "right"           ) or 
          ( keyvalues["sidewalk"] == "shared"          ) or 
          ( keyvalues["sidewalk"] == "yes"             ) or
          ( keyvalues["sidewalk:left"] == "separate"   ) or 
          ( keyvalues["sidewalk:left"] == "yes"        ) or
          ( keyvalues["sidewalk:left"] == "segregated" ) or
          ( keyvalues["sidewalk:right"] == "separate"  ) or 
          ( keyvalues["sidewalk:right"] == "yes"       ) or
          ( keyvalues["sidewalk:both"] == "separate"   ) or 
          ( keyvalues["sidewalk:both"] == "yes"        ) or
          ( keyvalues["footway"]  == "separate"        ) or 
          ( keyvalues["footway"]  == "yes"             ) or
          ( keyvalues["shoulder"] == "both"            ) or
          ( keyvalues["shoulder"] == "left"            ) or 
          ( keyvalues["shoulder"] == "right"           ) or 
          ( keyvalues["shoulder"] == "yes"             ) or
          ( keyvalues["cycleway"] == "track"           ) or
          ( keyvalues["cycleway"] == "opposite_track"  ) or
          ( keyvalues["cycleway"] == "yes"             ) or
          ( keyvalues["cycleway"] == "separate"        ) or
          ( keyvalues["cycleway"] == "sidewalk"        ) or
          ( keyvalues["cycleway"] == "sidepath"        ) or
          ( keyvalues["cycleway"] == "segregated"      ) or
          ( keyvalues["segregated"] == "yes"           ) or
          ( keyvalues["segregated"] == "right"         )) then
          keyvalues["highway"] = "primary_sidewalk"
      end
   end

-- ----------------------------------------------------------------------------
-- Use primary_verge to indicate verge
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"] == "primary"      ) or 
       ( keyvalues["highway"] == "primary_link" )) then
      if (( keyvalues["verge"] == "both"           ) or 
          ( keyvalues["verge"] == "left"           ) or 
          ( keyvalues["verge"] == "separate"       ) or 
          ( keyvalues["verge"] == "right"          ) or 
          ( keyvalues["verge"] == "yes"            )) then
          keyvalues["highway"] = "primary_verge"
      end
   end

-- ----------------------------------------------------------------------------
-- Render narrow tertiary roads as unclassified
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"]    == "tertiary_sidewalk"  )  and
       ( keyvalues["oneway"]     == nil                  )  and
       ( keyvalues["junction"]   == nil                  )  and
       ((( tonumber(keyvalues["width"])    or 4 ) <=  3 ) or
        (( tonumber(keyvalues["maxwidth"]) or 4 ) <=  3 ))) then
      keyvalues["highway"] = "unclassified_sidewalk"
   end

   if (( keyvalues["highway"]    == "tertiary_verge"     )  and
       ( keyvalues["oneway"]     == nil                  )  and
       ( keyvalues["junction"]   == nil                  )  and
       ((( tonumber(keyvalues["width"])    or 4 ) <=  3 ) or
        (( tonumber(keyvalues["maxwidth"]) or 4 ) <=  3 ))) then
      keyvalues["highway"] = "unclassified_verge"
   end

   if (( keyvalues["highway"]    == "tertiary"           )  and
       ( keyvalues["oneway"]     == nil                  )  and
       ( keyvalues["junction"]   == nil                  )  and
       ((( tonumber(keyvalues["width"])    or 4 ) <=  3 ) or
        (( tonumber(keyvalues["maxwidth"]) or 4 ) <=  3 ))) then
      keyvalues["highway"] = "unclassified"
   end

-- ----------------------------------------------------------------------------
-- Render bus guideways as "a sort of railway" rather than in their own
-- highway layer.
-- ----------------------------------------------------------------------------
   if (keyvalues["highway"] == "bus_guideway") then
      keyvalues["highway"] = nil
      keyvalues["railway"] = "bus_guideway"
   end

-- ----------------------------------------------------------------------------
-- Render bus-only service roads tagged as "highway=busway" as service roads.
-- ----------------------------------------------------------------------------
   if (keyvalues["highway"] == "busway") then
      keyvalues["highway"] = "service"
   end

-- ----------------------------------------------------------------------------
-- Remove admin boundaries from the map
-- I do this because I'm simply not interested in admin boundaries and I'm 
-- lucky enough to live in a place where I don't have to be.
-- ----------------------------------------------------------------------------
   if (keyvalues["boundary"] == "administrative") then
      keyvalues["boundary"] = nil
   end

-- ----------------------------------------------------------------------------
-- Bridge types - only some types (including "yes") are selected in project.mml
-- ----------------------------------------------------------------------------
   if (( keyvalues["bridge"] == "aqueduct"           ) or
       ( keyvalues["bridge"] == "bailey"             ) or
       ( keyvalues["bridge"] == "boardwalk"          ) or
       ( keyvalues["bridge"] == "building_passage"   ) or
       ( keyvalues["bridge"] == "cantilever"         ) or
       ( keyvalues["bridge"] == "chain"              ) or
       ( keyvalues["bridge"] == "covered"            ) or
       ( keyvalues["bridge"] == "foot"               ) or
       ( keyvalues["bridge"] == "footbridge"         ) or
       ( keyvalues["bridge"] == "gangway"            ) or
       ( keyvalues["bridge"] == "low_water_crossing" ) or
       ( keyvalues["bridge"] == "movable"            ) or
       ( keyvalues["bridge"] == "pier"               ) or
       ( keyvalues["bridge"] == "plank"              ) or
       ( keyvalues["bridge"] == "plank_bridge"       ) or
       ( keyvalues["bridge"] == "pontoon"            ) or
       ( keyvalues["bridge"] == "rope"               ) or
       ( keyvalues["bridge"] == "swing"              ) or
       ( keyvalues["bridge"] == "trestle"            ) or
       ( keyvalues["bridge"] == "undefined"          ) or
       ( keyvalues["bridge"] == "viaduct"            )) then
      keyvalues["bridge"] = "yes"
   end

-- ----------------------------------------------------------------------------
-- Remove some combinations of bridge
-- ----------------------------------------------------------------------------
   if ((  keyvalues["bridge"]  == "yes"          ) and
       (( keyvalues["barrier"] == "cattle_grid" )  or
        ( keyvalues["barrier"] == "stile"       ))) then
      keyvalues["barrier"] = nil
   end

-- ----------------------------------------------------------------------------
-- Tunnel values - render as "yes" if appropriate.
-- ----------------------------------------------------------------------------
   if (( keyvalues["tunnel"] == "culvert"             ) or
       ( keyvalues["tunnel"] == "covered"             ) or
       ( keyvalues["tunnel"] == "avalanche_protector" ) or
       ( keyvalues["tunnel"] == "passage"             ) or
       ( keyvalues["tunnel"] == "1"                   ) or
       ( keyvalues["tunnel"] == "cave"                ) or
       ( keyvalues["tunnel"] == "flooded"             ) or
       ( keyvalues["tunnel"] == "building_passage"    )) then
      keyvalues["tunnel"] = "yes"
   end

-- ----------------------------------------------------------------------------
-- Covered values - render as "yes" if appropriate.
-- ----------------------------------------------------------------------------
   if (( keyvalues["covered"] == "arcade"           ) or
       ( keyvalues["covered"] == "covered"          ) or
       ( keyvalues["covered"] == "colonnade"        ) or
       ( keyvalues["covered"] == "building_passage" ) or
       ( keyvalues["covered"] == "building_arcade"  ) or
       ( keyvalues["covered"] == "roof"             ) or
       ( keyvalues["covered"] == "portico"          )) then
      keyvalues["covered"] = "yes"
   end

-- ----------------------------------------------------------------------------
-- Alleged petrol stations that only do fuel:electricity are probably 
-- actually charging stations.
--
-- The combination of "amenity=fuel, electricity, no diesel" is as good as
-- we can make  it without guessing based on brand.  "fuel, electricity,
-- some sort of petrol, no diesel" is not a thing in the UK/IE data currently.
-- Similarly, electric waterway=fuel are charging stations.
--
-- Show vending machines that sell petrol as fuel.
-- One UK/IE example, on an airfield, and "UL91" finds it.
--
-- Show aeroway=fuel as amenity=fuel.  All so far in UK/IE are 
-- general aviation.
--
-- Show waterway=fuel with a "fuel pump on a boat" icon.
--
-- Once we've got those out of the way, detect amenity=fuel that also sell
-- electricity, hydrogen and LPG.
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"]          == "fuel" ) and
       ( keyvalues["fuel:electricity"] == "yes"  )  and
       ( keyvalues["fuel:diesel"]      == nil    )) then
      keyvalues["amenity"] = "charging_station"
   end

   if (( keyvalues["waterway"]         == "fuel" ) and
       ( keyvalues["fuel:electricity"] == "yes"  )) then
      keyvalues["amenity"] = "charging_station"
      keyvalues["waterway"] = nil
   end

   if (( keyvalues["amenity"] == "vending_machine" ) and
       ( keyvalues["vending"] == "fuel"            )  and
       ( keyvalues["fuel"]    == "UL91"            )) then
      keyvalues["amenity"] = "fuel"
   end

   if ( keyvalues["aeroway"] == "fuel" ) then
      keyvalues["aeroway"] = nil
      keyvalues["amenity"] = "fuel"
   end

   if ( keyvalues["waterway"] == "fuel" ) then
      keyvalues["amenity"] = "fuel_w"
      keyvalues["waterway"] = nil
   end

   if (( keyvalues["amenity"]          == "fuel" ) and
       ( keyvalues["fuel:electricity"] == "yes"  )  and
       ( keyvalues["fuel:diesel"]      == "yes"  )) then
      keyvalues["amenity"] = "fuel_e"
   end

   if ((  keyvalues["amenity"]  == "fuel"  ) and
       (( keyvalues["fuel:H2"]  == "yes"  )  or
        ( keyvalues["fuel:LH2"] == "yes"  ))) then
      keyvalues["amenity"] = "fuel_h"
   end

   if ((  keyvalues["amenity"]  == "fuel"  ) and
       (( keyvalues["LPG"]      == "yes"  )  or
        ( keyvalues["fuel"]     == "lpg"  )  or
        ( keyvalues["fuel:lpg"] == "yes"  ))) then
      keyvalues["amenity"] = "fuel_l"
   end

-- ----------------------------------------------------------------------------
-- Aviaries in UK / IE seem to be always within a zoo or larger attraction, 
-- and not "zoos" in their own right.
-- ----------------------------------------------------------------------------
   if (( keyvalues["zoo"]     == "aviary" )  and
       ( keyvalues["amenity"] == nil      )) then
      keyvalues["amenity"] = "zooaviary"
      keyvalues["tourism"] = nil
      keyvalues["zoo"] = nil
   end

-- ----------------------------------------------------------------------------
-- Some zoos are mistagged with extra "animal=attraction" or "zoo=enclosure" 
-- tags, so remove those.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["attraction"] == "animal"    )  or
        ( keyvalues["zoo"]        == "enclosure" )) and
       (  keyvalues["tourism"] == "zoo"           )) then
      keyvalues["attraction"] = nil
      keyvalues["zoo"] = nil
   end

-- ----------------------------------------------------------------------------
-- Retag any remaining animal attractions or zoo enclosures for rendering.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["attraction"] == "animal"    )  or
        ( keyvalues["zoo"]        == "enclosure" )) and
       (  keyvalues["amenity"]    == nil          )) then
      keyvalues["amenity"] = "zooenclosure"
      keyvalues["attraction"] = nil
      keyvalues["zoo"] = nil
   end

-- ----------------------------------------------------------------------------
-- Bridge structures - display as building=roof.
-- Also farmyard "bunker silos" and canopies, and natural arches.
-- Also railway traversers and more.
-- ----------------------------------------------------------------------------
   if ((   keyvalues["man_made"]         == "bridge"          ) or
       (   keyvalues["natural"]          == "arch"            ) or
       (   keyvalues["man_made"]         == "bunker_silo"     ) or
       (   keyvalues["amenity"]          == "feeding_place"   ) or
       (   keyvalues["railway"]          == "traverser"       ) or
       (   keyvalues["building"]         == "canopy"          ) or
       (   keyvalues["building"]         == "car_port"        ) or
       ((( keyvalues["disused:building"] ~= nil             )   or
         ( keyvalues["amenity"]          == "parcel_locker" )   or
         ( keyvalues["amenity"]          == "zooaviary"     )   or
         ( keyvalues["animal"]           == "horse_walker"  )   or
         ( keyvalues["leisure"]          == "bleachers"     )   or
         ( keyvalues["leisure"]          == "bandstand"     )) and
        (  keyvalues["building"]         == nil              )) or
       (   keyvalues["building:type"]    == "canopy"          ) or
       ((  keyvalues["covered"]          == "roof"           )  and
        (  keyvalues["building"]         == nil              )  and
        (  keyvalues["highway"]          == nil              )  and
        (  keyvalues["tourism"]          == nil              ))) then
      keyvalues["building"]      = "roof"
      keyvalues["building:type"] = nil
   end

-- ----------------------------------------------------------------------------
-- Ensure that allegedly operational windmills are treated as such and not as
-- "historic".
-- ----------------------------------------------------------------------------
   if (( keyvalues["man_made"] == "watermill") or
       ( keyvalues["man_made"] == "windmill" )) then
      if (( keyvalues["disused"]           == "yes"  ) or
          ( keyvalues["watermill:disused"] == "yes"  ) or
          ( keyvalues["windmill:disused"]  == "yes"  )) then
         keyvalues["historic"] = keyvalues["man_made"]
         keyvalues["man_made"] = nil
      else
         keyvalues["historic"] = nil
      end
   end

   if ((( keyvalues["disused:man_made"] == "watermill")  or
        ( keyvalues["disused:man_made"] == "windmill" )) and
       (  keyvalues["amenity"]          == nil         ) and
       (  keyvalues["man_made"]         == nil         ) and
       (  keyvalues["shop"]             == nil         )) then
      keyvalues["historic"] = keyvalues["disused:man_made"]
      keyvalues["disused:man_made"] = nil
   end

-- ----------------------------------------------------------------------------
-- Render (windmill buildings and former windmills) that are not something 
-- else as historic windmills.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["historic"] == "ruins"      ) and
       (( keyvalues["ruins"]    == "watermill" )  or
        ( keyvalues["ruins"]    == "windmill"  ))) then
      keyvalues["historic"] = keyvalues["ruins"]
      keyvalues["ruins"] = "yes"
   end

   if (((   keyvalues["building"] == "watermill"        )  or
        (   keyvalues["building"] == "former_watermill" )) and
       ((   keyvalues["amenity"]  == nil                 ) and
        (   keyvalues["man_made"] == nil                 ) and
        ((  keyvalues["historic"] == nil                )  or
         (  keyvalues["historic"] == "restoration"      )  or
         (  keyvalues["historic"] == "heritage"         )  or
         (  keyvalues["historic"] == "industrial"       )  or
         (  keyvalues["historic"] == "tower"            )))) then
      keyvalues["historic"] = "watermill"
   end

   if (((   keyvalues["building"] == "windmill"        )  or
        (   keyvalues["building"] == "former_windmill" )) and
       ((   keyvalues["amenity"]  == nil                ) and
        (   keyvalues["man_made"] == nil                ) and
        ((  keyvalues["historic"] == nil               )  or
         (  keyvalues["historic"] == "restoration"     )  or
         (  keyvalues["historic"] == "heritage"        )  or
         (  keyvalues["historic"] == "industrial"      )  or
         (  keyvalues["historic"] == "tower"           )))) then
      keyvalues["historic"] = "windmill"
   end

-- ----------------------------------------------------------------------------
-- Render ruined mills and mines etc. that are not something else as historic.
-- Items in this list are assumed to be not operational, so the "man_made" 
-- tag is cleared.
-- ----------------------------------------------------------------------------
   if (( keyvalues["historic"]  == "ruins"        ) and
       (( keyvalues["ruins"]    == "lime_kiln"   )  or
        ( keyvalues["ruins"]    == "manor"       )  or
        ( keyvalues["ruins"]    == "mill"        )  or
        ( keyvalues["ruins"]    == "mine"        )  or
        ( keyvalues["ruins"]    == "round_tower" )  or
        ( keyvalues["ruins"]    == "village"     )  or
        ( keyvalues["ruins"]    == "well"        ))) then
      keyvalues["historic"] = keyvalues["ruins"]
      keyvalues["ruins"] = "yes"
      keyvalues["man_made"] = nil
   end

-- ----------------------------------------------------------------------------
-- We can assume that any allegedly non-historic ice_houses are actually 
-- historic.  Any coexisting historic keys will just be stuff like "building".
-- ----------------------------------------------------------------------------
   if ( keyvalues["man_made"] == "ice_house" ) then
      keyvalues["historic"] = "ice_house"
      keyvalues["man_made"] = nil
   end

-- ----------------------------------------------------------------------------
-- Sound mirrors
-- ----------------------------------------------------------------------------
   if ( keyvalues["man_made"] == "sound mirror" ) then

      if ( keyvalues["historic"] == "ruins" ) then
         keyvalues["ruins"] = "yes"
      end

      keyvalues["historic"] = "sound_mirror"
      keyvalues["man_made"] = nil
   end

-- ----------------------------------------------------------------------------
-- Specific defensive_works not mapped as something else
-- ----------------------------------------------------------------------------
   if (( keyvalues["defensive_works"] == "battery" ) and
       ( keyvalues["barrier"]         == nil       ) and
       ( keyvalues["building"]        == nil       ) and
       ( keyvalues["historic"]        == nil       ) and
       ( keyvalues["landuse"]         == nil       ) and
       ( keyvalues["man_made"]        == nil       ) and
       ( keyvalues["place"]           == nil       )) then
      keyvalues["historic"] = "battery"
      keyvalues["defensive_works"] = nil
   end

-- ----------------------------------------------------------------------------
-- Remove name from footway=sidewalk (we expect it to be rendered via the
-- road that this is a sidewalk for), or "is_sidepath=yes" etc.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["footway"]             == "sidewalk" )  or
        ( keyvalues["cycleway"]            == "sidewalk" )  or
        ( keyvalues["is_sidepath"]         == "yes"      )  or
        ( keyvalues["is_sidepath:of"]      ~= nil        )  or
        ( keyvalues["is_sidepath:of:name"] ~= nil        )  or
        ( keyvalues["is_sidepath:of:ref"]  ~= nil        )) and
       (  keyvalues["name"]                ~= nil         )) then
      keyvalues["name"] = nil
   end

-- ----------------------------------------------------------------------------
-- Waste transfer stations
-- First, try and identify mistagged ones.
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "waste_transfer_station" ) and
       ( keyvalues["recycling_type"] == "centre"          )) then
      keyvalues["amenity"] = "recyclingcentre"
      keyvalues["landuse"] = "industrial"
   end

-- ----------------------------------------------------------------------------
-- Next, treat "real" waste transfer stations as industrial.  We remove the 
-- amenity tag here because there's no icon for amenity=waste_transfer_station;
-- an amenity tag would see it treated as landuse=unnamedcommercial with the
-- amenity tag bringing the name (which it won't here).  The "industrial" tag
-- forces it through the brand/operator logic.
-- ----------------------------------------------------------------------------
   if ( keyvalues["amenity"] == "waste_transfer_station" ) then
      keyvalues["amenity"] = nil
      keyvalues["landuse"] = "industrial"
      keyvalues["industrial"] = "waste_transfer_station"
   end

-- ----------------------------------------------------------------------------
-- Recycling bins and recycling centres.
-- Recycling bins are only shown from z19.  Recycling centres are shown from
-- z16 and have a characteristic icon.  Any object without recycling_type, or
-- with a different value, is assumed to be a bin, apart from one rogue
-- "scrap_yard".
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "recycling"         ) and
       ( keyvalues["recycling_type"] == "scrap_yard" )) then
         keyvalues["amenity"] = "scrapyard"
   end

   if ( keyvalues["amenity"] == "recycling" ) then
      if ( keyvalues["recycling_type"] == "centre" ) then
         keyvalues["amenity"] = "recyclingcentre"
         keyvalues["landuse"] = "industrial"
      end
   end

-- ----------------------------------------------------------------------------
-- Mistaggings for wastewater_plant
-- ----------------------------------------------------------------------------
   if (( keyvalues["man_made"]   == "sewage_works"      ) or
       ( keyvalues["man_made"]   == "wastewater_works"  )) then
      keyvalues["man_made"] = "wastewater_plant"
   end

-- ----------------------------------------------------------------------------
-- Outfalls, sewage and otherwise.  We process "man_made=outfall", but also
-- catch outlets not tagged with that.
-- ----------------------------------------------------------------------------
   if (( keyvalues["outlet"] ~= nil  ) and
       ( keyvalues["outlet"] ~= "no" )) then
      keyvalues["man_made"] = "outfall"
   end

-- ----------------------------------------------------------------------------
-- Electricity substations
-- ----------------------------------------------------------------------------
   if (( keyvalues["power"] == "substation"  )  or
       ( keyvalues["power"] == "sub_station" )) then
      keyvalues["power"]   = nil

      if (( keyvalues["building"] == nil  ) or
          ( keyvalues["building"] == "no" )) then
         keyvalues["landuse"] = "industrial"
      else
         keyvalues["building"] = "yes"
         keyvalues["landuse"] = "industrialbuilding"
      end

      if ( keyvalues["name"] == nil ) then
         keyvalues["name"] = "(el.sub.)"
      else
         keyvalues["name"] = keyvalues["name"] .. " (el.sub.)"
      end
   end

-- ----------------------------------------------------------------------------
-- Pretend add landuse=industrial to some industrial sub-types to force 
-- name rendering.  Similarly, some commercial and leisure.
-- man_made=works drops the man_made tag to avoid duplicate labelling.
-- "parking=depot" is a special case - drop the parking tag there too.
-- ----------------------------------------------------------------------------
   if ( keyvalues["man_made"]   == "wastewater_plant" ) then
      keyvalues["man_made"] = nil
      keyvalues["landuse"] = "industrial"
      if ( keyvalues["name"] == nil ) then
         keyvalues["name"] = "(sewage)"
      else
         keyvalues["name"] = keyvalues["name"] .. " (sewage)"
      end
   end

   if (( keyvalues["amenity"]    == "bus_depot"              ) or
       ( keyvalues["amenity"]    == "depot"                  ) or
       ( keyvalues["amenity"]    == "fuel_depot"             ) or
       ( keyvalues["amenity"]    == "scrapyard"              ) or 
       ( keyvalues["craft"]      == "bakery"                 ) or
       ( keyvalues["craft"]      == "distillery"             ) or
       ( keyvalues["craft"]      == "sawmill"                ) or
       ( keyvalues["industrial"] == "auto_wrecker"           ) or 
       ( keyvalues["industrial"] == "automotive_industry"    ) or
       ( keyvalues["industrial"] == "bakery"                 ) or
       ( keyvalues["industrial"] == "brewery"                ) or 
       ( keyvalues["industrial"] == "bus_depot"              ) or
       ( keyvalues["industrial"] == "chemical"               ) or
       ( keyvalues["industrial"] == "concrete_plant"         ) or
       ( keyvalues["industrial"] == "construction"           ) or
       ( keyvalues["industrial"] == "depot"                  ) or 
       ( keyvalues["industrial"] == "distillery"             ) or 
       ( keyvalues["industrial"] == "electrical"             ) or
       ( keyvalues["industrial"] == "engineering"            ) or
       ( keyvalues["industrial"] == "factory"                ) or 
       ( keyvalues["industrial"] == "furniture"              ) or
       ( keyvalues["industrial"] == "gas"                    ) or
       ( keyvalues["industrial"] == "haulage"                ) or
       ( keyvalues["industrial"] == "machine_shop"           ) or
       ( keyvalues["industrial"] == "machinery"              ) or
       ( keyvalues["industrial"] == "metal_finishing"        ) or
       ( keyvalues["industrial"] == "mobile_equipment"       ) or
       ( keyvalues["industrial"] == "oil"                    ) or
       ( keyvalues["industrial"] == "packaging"              ) or
       ( keyvalues["industrial"] == "sawmill"                ) or
       ( keyvalues["industrial"] == "scaffolding"            ) or
       ( keyvalues["industrial"] == "scrap_yard"             ) or 
       ( keyvalues["industrial"] == "shop_fitters"           ) or
       ( keyvalues["industrial"] == "warehouse"              ) or
       ( keyvalues["industrial"] == "waste_handling"         ) or
       ( keyvalues["industrial"] == "woodworking"            ) or
       ( keyvalues["industrial"] == "yard"                   ) or 
       ( keyvalues["industrial"] == "yes"                    ) or 
       ( keyvalues["landuse"]    == "depot"                  ) or
       ( keyvalues["man_made"]   == "gas_station"            ) or
       ( keyvalues["man_made"]   == "gas_works"              ) or
       ( keyvalues["man_made"]   == "petroleum_well"         ) or 
       ( keyvalues["man_made"]   == "pumping_station"        ) or
       ( keyvalues["man_made"]   == "water_treatment"        ) or
       ( keyvalues["man_made"]   == "water_works"            ) or
       ( keyvalues["power"]      == "plant"                  )) then
      keyvalues["landuse"] = "industrial"
   end

-- ----------------------------------------------------------------------------
-- Sometimes covered reservoirs are "basically buildings", sometimes they have
-- e.g. landuse=grass set.  If the latter, don't show them as buildings.
-- The name will still appear via landuse.
-- ----------------------------------------------------------------------------
   if (( keyvalues["man_made"]   == "reservoir_covered" ) and
       ( keyvalues["landuse"]    == nil                 )) then
      keyvalues["building"] = "roof"
      keyvalues["landuse"]  = "industrialbuilding"
   end

   if (( keyvalues["building"]   == "industrial"             ) or
       ( keyvalues["building"]   == "depot"                  ) or 
       ( keyvalues["building"]   == "warehouse"              ) or
       ( keyvalues["building"]   == "works"                  ) or
       ( keyvalues["building"]   == "manufacture"            )) then
      keyvalues["landuse"] = "industrialbuilding"
   end

   if ( keyvalues["man_made"]   == "works" ) then
      keyvalues["man_made"] = nil

      if (( keyvalues["building"] == nil  ) or
          ( keyvalues["building"] == "no" )) then
         keyvalues["landuse"] = "industrial"
      else
         keyvalues["building"] = "yes"
         keyvalues["landuse"] = "industrialbuilding"
      end
   end

   if ( keyvalues["man_made"]   == "water_tower" ) then
      if ( keyvalues["building"] == "no" ) then
         keyvalues["landuse"] = "industrial"
      else
         keyvalues["building"] = "yes"
         keyvalues["landuse"] = "industrialbuilding"
      end
   end

   if ( keyvalues["parking"]   == "depot" ) then
      keyvalues["parking"] = nil
      keyvalues["landuse"] = "industrial"
   end

-- ----------------------------------------------------------------------------
-- Handle spoil heaps as landfill
-- ----------------------------------------------------------------------------
   if ( keyvalues["man_made"] == "spoil_heap" ) then
      keyvalues["landuse"] = "landfill"
   end

-- ----------------------------------------------------------------------------
-- Handle place=islet as place=island
-- Nodes are shown from zoom 20, ways from that or higher zooms if they have
-- a larger way_area.
--
-- Handle place=quarter
-- Handle natural=cape etc. as place=locality if no other place tag.
-- ----------------------------------------------------------------------------
   keyvalues["place"] = consolidate_place( keyvalues["place"], keyvalues["natural"] )

-- ----------------------------------------------------------------------------
-- Handle shoals, either as mud or reef
-- ----------------------------------------------------------------------------
   if ( keyvalues["natural"] == "shoal" ) then
      if ( keyvalues["surface"] == "mud" ) then
         keyvalues["natural"] = "mud"
         keyvalues["surface"] = nil
      else
         keyvalues["natural"] = "reef"
      end
   end

-- ----------------------------------------------------------------------------
-- Show sandy reefs as more sandy than rocky reefs
-- ----------------------------------------------------------------------------
   if (( keyvalues["natural"] == "reef" ) and
       ( keyvalues["reef"]    == "sand" )) then
         keyvalues["natural"] = "reefsand"
   end

-- ----------------------------------------------------------------------------
-- Convert "natural=saltmarsh" into something we can handle below
-- ----------------------------------------------------------------------------
   if ( keyvalues["natural"] == "saltmarsh" ) then
      if ( keyvalues["wetland"] == "tidalflat" ) then
         keyvalues["tidal"] = "yes"
      else
         keyvalues["tidal"] = "no"
      end

      keyvalues["natural"] = "wetland"
      keyvalues["wetland"] = "saltmarsh"
   end

-- ----------------------------------------------------------------------------
-- Detect wetland not tagged with "natural=wetland".
-- Other combinations include
-- natural=water, natural=scrub, landuse=meadow, leisure=nature_reserve,
-- leisure=park, and no natural, landuse or leisure tags.
-- In many cases we don't set natural=wetland, but in some we do.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["wetland"] == "wet_meadow"  ) and
       (( keyvalues["natural"] == nil          )  or
        ( keyvalues["natural"] == "grassland"  )) and
       (  keyvalues["leisure"] == nil           )  and
       (( keyvalues["landuse"] == nil          )  or
        ( keyvalues["landuse"] == "meadow"     ))) then
      keyvalues["natural"] = "wetland"
   end

-- ----------------------------------------------------------------------------
-- Detect wetland also tagged with "surface" tags.
-- The wetland types that we're interested in below are:
-- (nil), tidalflat, mud, wet_meadow, saltmarsh, reedbed
-- Of these, for (nil) and tidalflat, the surface should take precedence.
-- For others, we fall through to 'if "natural" is still "wetland"' nelow, and
-- if "wetland" doesn't match one of those, it'll go through as 
-- "generic wetland", which is an overlay for whatever's underneath.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["natural"] == "wetland"    ) and
       (( keyvalues["wetland"] == nil         ) or
        ( keyvalues["wetland"] == "tidalflat" ))) then
      if (( keyvalues["surface"] == "mud"       ) or
          ( keyvalues["surface"] == "mud, sand" )) then
         keyvalues["natural"] = "mud"
      end

      if (( keyvalues["surface"] == "sand"      ) or
          ( keyvalues["surface"] == "sand, mud" ) or
          ( keyvalues["surface"] == "dirt/sand" )) then
         keyvalues["natural"] = "sand"
      end

      if (( keyvalues["surface"] == "shingle"     ) or
          ( keyvalues["surface"] == "gravel"      ) or
          ( keyvalues["surface"] == "fine_gravel" ) or
          ( keyvalues["surface"] == "pebblestone" )) then
         keyvalues["natural"] = "shingle"
      end

      if (( keyvalues["surface"] == "rock"      ) or
          ( keyvalues["surface"] == "bare_rock" ) or
          ( keyvalues["surface"] == "concrete"  )) then
         keyvalues["natural"] = "bare_rock"
      end
   end

-- ----------------------------------------------------------------------------
-- Also, if "natural" is still "wetland", what "wetland" values should be 
-- handled as some other tag?
-- ----------------------------------------------------------------------------
   if ( keyvalues["natural"] == "wetland" ) then
      if (( keyvalues["wetland"] == "tidalflat" ) or
          ( keyvalues["wetland"] == "mud"       )) then
         keyvalues["natural"] = "mud"
         keyvalues["tidal"] = "yes"
      end

      if ( keyvalues["wetland"] == "wet_meadow" ) then
         keyvalues["landuse"] = "wetmeadow"
         keyvalues["natural"] = nil
      end

      if ( keyvalues["wetland"] == "saltmarsh" ) then
         keyvalues["landuse"] = "saltmarsh"
         keyvalues["natural"] = nil
      end

      if ( keyvalues["wetland"] == "reedbed" ) then
         keyvalues["landuse"] = "reedbed"
         keyvalues["natural"] = nil
      end
   end

-- ----------------------------------------------------------------------------
-- Render tidal mud with more blue
-- ----------------------------------------------------------------------------
   if ((  keyvalues["natural"]   == "mud"        ) and
       (( keyvalues["tidal"]     == "yes"       ) or
        ( keyvalues["wetland"]   == "tidalflat" ))) then
      keyvalues["natural"] = "tidal_mud"
   end

-- ----------------------------------------------------------------------------
-- Handle various sorts of milestones.
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"]  == "milestone" )  or
       ( keyvalues["historic"] == "milestone" )  or
       ( keyvalues["historic"] == "milepost"  )  or
       ( keyvalues["waterway"] == "milestone" )  or
       ( keyvalues["railway"]  == "milestone" )  or
       ( keyvalues["man_made"] == "mile_post" )) then
      keyvalues["highway"] = "milestone"

      append_inscription(keyvalues)
      append_directions(keyvalues)
   end

-- ----------------------------------------------------------------------------
-- Aerial markers for pipelines etc.
-- ----------------------------------------------------------------------------
   if (( keyvalues["marker"]   == "aerial"          ) or
       ( keyvalues["marker"]   == "pipeline"        ) or
       ( keyvalues["marker"]   == "post"            ) or
       ( keyvalues["man_made"] == "pipeline_marker" ) or
       ( keyvalues["man_made"] == "marker"          ) or
       ( keyvalues["pipeline"] == "marker"          )) then
      keyvalues["man_made"] = "markeraerial"
   end

-- ----------------------------------------------------------------------------
-- Boundary stones.  If they're already tagged as tourism=attraction, remove
-- that tag.
-- Note that "marker=stone" (for "non boundary stones") are handled elsewhere.
-- For March Stones see https://en.wikipedia.org/wiki/March_Stones_of_Aberdeen
-- ----------------------------------------------------------------------------
   if (( keyvalues["historic"]    == "boundary_stone"  )  or
       ( keyvalues["historic"]    == "boundary_marker" )  or
       ( keyvalues["man_made"]    == "boundary_marker" )  or
       ( keyvalues["marker"]      == "boundary_stone"  )  or
       ( keyvalues["boundary"]    == "marker"          )  or
       ( keyvalues["designation"] == "March Stone"     )) then
      keyvalues["man_made"] = "boundary_stone"
      keyvalues["tourism"]  = nil

      append_inscription(keyvalues)
   end

-- ----------------------------------------------------------------------------
-- Former telephone boxes
-- ----------------------------------------------------------------------------
   if ((( keyvalues["covered"]         == "booth"          )   and
        ( keyvalues["booth"]           ~= "K1"             )   and
        ( keyvalues["booth"]           ~= "KX100"          )   and
        ( keyvalues["booth"]           ~= "KX200"          )   and
        ( keyvalues["booth"]           ~= "KX300"          )   and
        ( keyvalues["booth"]           ~= "KXPlus"         )   and
        ( keyvalues["booth"]           ~= "KX410"          )   and
        ( keyvalues["booth"]           ~= "KX420"          )   and
        ( keyvalues["booth"]           ~= "KX520"          )   and
        ( keyvalues["booth"]           ~= "oakham"         )   and
        ( keyvalues["booth"]           ~= "ST6"            ))  or
       (  keyvalues["booth"]           == "K2"              )  or
       (  keyvalues["booth"]           == "K4 Post Office"  )  or
       (  keyvalues["booth"]           == "K6"              )  or
       (  keyvalues["booth"]           == "K8"              )  or
       (  keyvalues["telephone_kiosk"] == "K6"              )  or
       (  keyvalues["man_made"]        == "telephone_box"   )  or
       (  keyvalues["building"]        == "telephone_box"   )  or
       (  keyvalues["historic"]        == "telephone"       )  or
       (  keyvalues["disused:amenity"] == "telephone"       )  or
       (  keyvalues["removed:amenity"] == "telephone"       )) then
      if ((( keyvalues["amenity"]   == "telephone"    )  or
           ( keyvalues["amenity"]   == "phone"        )) and
          (  keyvalues["emergency"] ~= "defibrillator" ) and
          (  keyvalues["emergency"] ~= "phone"         ) and
          (  keyvalues["tourism"]   ~= "information"   ) and
          (  keyvalues["tourism"]   ~= "artwork"       ) and
          (  keyvalues["tourism"]   ~= "museum"        )) then
	 if ( keyvalues["colour"] == "black" ) then
            keyvalues["amenity"] = "boothtelephoneblack"
	 else
	    if (( keyvalues["colour"] == "white" ) or
	        ( keyvalues["colour"] == "cream" )) then
               keyvalues["amenity"] = "boothtelephonewhite"
	    else
    	       if ( keyvalues["colour"] == "blue" ) then
                  keyvalues["amenity"] = "boothtelephoneblue"
	       else
    	          if ( keyvalues["colour"] == "green" ) then
                     keyvalues["amenity"] = "boothtelephonegreen"
		  else
    	             if ( keyvalues["colour"] == "grey" ) then
                        keyvalues["amenity"] = "boothtelephonegrey"
		     else
    	                if ( keyvalues["colour"] == "gold" ) then
                           keyvalues["amenity"] = "boothtelephonegold"
			else
                           keyvalues["amenity"] = "boothtelephonered"
			end
		     end
		  end
	       end
	    end
	 end
	    
         keyvalues["tourism"] = nil
         keyvalues["emergency"] = nil
      else
         if ( keyvalues["emergency"] == "defibrillator" ) then
             keyvalues["amenity"]   = "boothdefibrillator"
             keyvalues["disused:amenity"] = nil
             keyvalues["emergency"] = nil
         else
            if (( keyvalues["amenity"] == "public_bookcase" )  or
                ( keyvalues["amenity"] == "library"         )) then
               keyvalues["amenity"] = "boothlibrary"
               keyvalues["disused:amenity"] = nil
            else
               if ( keyvalues["amenity"] == "bicycle_repair_station" ) then
                  keyvalues["amenity"] = "boothbicyclerepairstation"
                  keyvalues["disused:amenity"] = nil
               else
                  if ( keyvalues["amenity"] == "atm" ) then
                     keyvalues["amenity"] = "boothatm"
                     keyvalues["disused:amenity"] = nil
                  else
                     if ( keyvalues["tourism"] == "information" ) then
                        keyvalues["amenity"] = "boothinformation"
                        keyvalues["disused:amenity"] = nil
                        keyvalues["tourism"] = nil
                     else
                        if ( keyvalues["tourism"] == "artwork" ) then
                           keyvalues["amenity"] = "boothartwork"
                           keyvalues["disused:amenity"] = nil
                           keyvalues["tourism"] = nil
                        else
                           if ( keyvalues["tourism"] == "museum" ) then
                              keyvalues["amenity"] = "boothmuseum"
                              keyvalues["disused:amenity"] = nil
                              keyvalues["tourism"] = nil
		  	   else
                              if (( keyvalues["disused:amenity"]    == "telephone"        )  or
                                  ( keyvalues["removed:amenity"]    == "telephone"        )  or
                                  ( keyvalues["abandoned:amenity"]  == "telephone"        )  or
                                  ( keyvalues["demolished:amenity"] == "telephone"        )  or
                                  ( keyvalues["razed:amenity"]      == "telephone"        )  or
                                  ( keyvalues["old_amenity"]        == "telephone"        )  or
                                  ( keyvalues["historic:amenity"]   == "telephone"        )  or
                                  ( keyvalues["disused"]            == "telephone"        )  or
                                  ( keyvalues["was:amenity"]        == "telephone"        )  or
                                  ( keyvalues["old:amenity"]        == "telephone"        )  or
                                  ( keyvalues["amenity"]            == "former_telephone" )  or
                                  ( keyvalues["historic"]           == "telephone"        )) then
                                 keyvalues["amenity"]         = "boothdisused"
                                 keyvalues["disused:amenity"] = nil
                                 keyvalues["historic"]        = nil
                              end
                           end
			end
                     end
                  end
               end
            end
         end
      end
   end
   
-- ----------------------------------------------------------------------------
-- "business" and "company" are used as an alternative to "office" and 
-- "industrial" by some people.  Wherever someone has used a more 
-- frequently-used tag we defer to that.
-- ----------------------------------------------------------------------------
   if (( keyvalues["business"]   ~= nil  ) and
       ( keyvalues["office"]     == nil  ) and
       ( keyvalues["shop"]       == nil  )) then
      keyvalues["office"] = "yes"
      keyvalues["business"] = nil
   end

   if (( keyvalues["company"]   ~= nil  ) and
       ( keyvalues["man_made"]  == nil  ) and
       ( keyvalues["office"]    == nil  ) and
       ( keyvalues["shop"]      == nil  )) then
      keyvalues["office"] = "yes"
      keyvalues["company"] = nil
   end

-- ----------------------------------------------------------------------------
-- Remove generic offices if shop is set.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["shop"]   ~= nil        )  and
       (  keyvalues["shop"]   ~= "no"       )  and
       (  keyvalues["shop"]   ~= "vacant"   )  and
       (( keyvalues["office"] == "company" )   or
        ( keyvalues["office"] == "vacant"  )   or
        ( keyvalues["office"] == "yes"     ))) then
      keyvalues["office"] = nil
   end

-- ----------------------------------------------------------------------------
-- Mappings to shop=car
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "car;car_repair"  )  or
       ( keyvalues["shop"]    == "car_showroom"    )  or
       ( keyvalues["shop"]    == "vehicle"         )) then
      keyvalues["shop"] = "car"
   end

-- ----------------------------------------------------------------------------
-- Mappings to shop=bicycle
-- ----------------------------------------------------------------------------
   if ( keyvalues["shop"] == "bicycle_repair"   ) then
      keyvalues["shop"] = "bicycle"
   end

-- ----------------------------------------------------------------------------
-- Map craft=car_repair etc. to shop=car_repair
-- ----------------------------------------------------------------------------
   if (( keyvalues["craft"]   == "car_repair"         )  or
       ( keyvalues["craft"]   == "coachbuilder"       )  or
       ( keyvalues["shop"]    == "car_service"        )  or
       ( keyvalues["amenity"] == "vehicle_inspection" )  or
       ( keyvalues["shop"]    == "car_bodyshop"       )  or
       ( keyvalues["shop"]    == "vehicle_inspection" )  or
       ( keyvalues["shop"]    == "mechanic"           )  or
       ( keyvalues["shop"]    == "car_repair;car"     )  or
       ( keyvalues["shop"]    == "car_repair;tyres"   )) then
      keyvalues["shop"]    = "car_repair"
      keyvalues["amenity"] = nil
      keyvalues["craft"]   = nil
   end

-- ----------------------------------------------------------------------------
-- Map various diplomatic things to embassy.
-- Pedants may claim that some of these aren't legally embassies, and they'd
-- be correct, but I use the same icon for all of these currently.
-- ----------------------------------------------------------------------------
   if (((  keyvalues["diplomatic"] == "embassy"            )  and
        (( keyvalues["embassy"]    == nil                 )   or
         ( keyvalues["embassy"]    == "yes"               )   or
         ( keyvalues["embassy"]    == "high_commission"   )   or
         ( keyvalues["embassy"]    == "nunciature"        )   or
         ( keyvalues["embassy"]    == "delegation"        ))) or
       ((  keyvalues["diplomatic"] == "consulate"          )  and
        (( keyvalues["consulate"]  == nil                 )   or
         ( keyvalues["consulate"]  == "consulate_general" )   or
         ( keyvalues["consulate"]  == "yes"               ))) or
       ( keyvalues["diplomatic"] == "embassy;consulate"     ) or
       ( keyvalues["diplomatic"] == "embassy;mission"       ) or
       ( keyvalues["diplomatic"] == "consulate;embassy"     )) then
      keyvalues["amenity"]    = "embassy"
      keyvalues["diplomatic"] = nil
      keyvalues["office"]     = nil
   end

   if (((  keyvalues["diplomatic"] == "embassy"              )  and
        (( keyvalues["embassy"]    == "residence"           )   or
         ( keyvalues["embassy"]    == "branch_embassy"      )   or
         ( keyvalues["embassy"]    == "mission"             ))) or
       ((  keyvalues["diplomatic"] == "consulate"            )  and
        (( keyvalues["consulate"]  == "consular_office"     )   or
         ( keyvalues["consulate"]  == "residence"           )   or
         ( keyvalues["consulate"]  == "consular_agency"     ))) or
       (   keyvalues["diplomatic"] == "permanent_mission"     ) or
       (   keyvalues["diplomatic"] == "trade_delegation"      ) or
       (   keyvalues["diplomatic"] == "liaison"               ) or
       (   keyvalues["diplomatic"] == "non_diplomatic"        ) or
       (   keyvalues["diplomatic"] == "mission"               ) or
       (   keyvalues["diplomatic"] == "trade_mission"         )) then
      if ( keyvalues["amenity"] == "embassy" ) then
         keyvalues["amenity"] = nil
      end

      keyvalues["diplomatic"] = nil

-- ----------------------------------------------------------------------------
-- "office" is set to something that will definitely display here, just in case
-- it was set to some value that would not.
-- ----------------------------------------------------------------------------
      keyvalues["office"] = "yes"
   end

-- ----------------------------------------------------------------------------
-- Things that are both localities and peaks or hills 
-- should render as the latter.
-- Also, some other combinations (most amenities, some man_made, etc.)
-- Note that "hill" is handled by the rendering code as similar to "peak" but
-- only at higher zooms.  See 19/03/2023 in changelog.html .
-- ----------------------------------------------------------------------------
   if ((  keyvalues["place"]    == "locality"      ) and
       (( keyvalues["natural"]  == "peak"         )  or
        ( keyvalues["natural"]  == "hill"         )  or
        ( keyvalues["amenity"]  ~= nil            )  or
        ( keyvalues["man_made"] ~= nil            )  or
        ( keyvalues["historic"] ~= nil            ))) then
      keyvalues["place"] = nil
   end

-- ----------------------------------------------------------------------------
-- Things that are both viewpoints or attractions and monuments or memorials 
-- should render as the latter.  Some are handled further down too.
-- Also handle some other combinations.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["tourism"]   == "viewpoint"                 )  or
        ( keyvalues["tourism"]   == "attraction"                )) and
       (( keyvalues["historic"]  == "abbey"                     )  or
        ( keyvalues["historic"]  == "aircraft"                  )  or
        ( keyvalues["historic"]  == "almshouse"                 )  or
        ( keyvalues["historic"]  == "anchor"                    )  or
        ( keyvalues["historic"]  == "archaeological_site"       )  or
        ( keyvalues["historic"]  == "bakery"                    )  or
        ( keyvalues["historic"]  == "barrow"                    )  or
        ( keyvalues["historic"]  == "baths"                     )  or
        ( keyvalues["historic"]  == "battlefield"               )  or
        ( keyvalues["historic"]  == "battery"                   )  or
        ( keyvalues["historic"]  == "bullaun_stone"             )  or
        ( keyvalues["historic"]  == "boundary_stone"            )  or
        ( keyvalues["historic"]  == "building"                  )  or
        ( keyvalues["historic"]  == "bridge_site"               )  or
        ( keyvalues["historic"]  == "bunker"                    )  or
        ( keyvalues["historic"]  == "camp"                      )  or
        ( keyvalues["historic"]  == "cannon"                    )  or
        ( keyvalues["historic"]  == "castle"                    )  or
        ( keyvalues["historic"]  == "chapel"                    )  or
        ( keyvalues["historic"]  == "church"                    )  or
        ( keyvalues["historic"]  == "city_gate"                 )  or
        ( keyvalues["historic"]  == "citywalls"                 )  or
        ( keyvalues["historic"]  == "chlochan"                  )  or
        ( keyvalues["historic"]  == "cross"                     )  or
        ( keyvalues["historic"]  == "deserted_medieval_village" )  or
        ( keyvalues["historic"]  == "drinking_fountain"         )  or
        ( keyvalues["historic"]  == "folly"                     )  or
        ( keyvalues["historic"]  == "fort"                      )  or
        ( keyvalues["historic"]  == "fortification"             )  or
        ( keyvalues["historic"]  == "gate"                      )  or
        ( keyvalues["historic"]  == "grinding_mill"             )  or
        ( keyvalues["historic"]  == "hall"                      )  or
        ( keyvalues["historic"]  == "high_cross"                )  or
        ( keyvalues["historic"]  == "house"                     )  or
        ( keyvalues["historic"]  == "ice_house"                 )  or
        ( keyvalues["historic"]  == "jail"                      )  or
        ( keyvalues["historic"]  == "locomotive"                )  or
        ( keyvalues["historic"]  == "locomotive"                )  or
        ( keyvalues["historic"]  == "martello_tower"            )  or
        ( keyvalues["historic"]  == "martello_tower;bunker"     )  or
        ( keyvalues["historic"]  == "maypole"                   )  or
        ( keyvalues["historic"]  == "memorial"                  )  or
        ( keyvalues["historic"]  == "mill"                      )  or
        ( keyvalues["historic"]  == "millstone"                 )  or
        ( keyvalues["historic"]  == "mine"                      )  or
        ( keyvalues["historic"]  == "monastery"                 )  or
        ( keyvalues["historic"]  == "monastic_grange"           )  or
        ( keyvalues["historic"]  == "monument"                  )  or
        ( keyvalues["historic"]  == "mound"                     )  or
	( keyvalues["historic"]  == "naval_mine"                )  or
        ( keyvalues["historic"]  == "oratory"                   )  or
        ( keyvalues["historic"]  == "pillory"                   )  or
        ( keyvalues["historic"]  == "place_of_worship"          )  or
        ( keyvalues["historic"]  == "police_call_box"           )  or
        ( keyvalues["historic"]  == "prison"                    )  or
        ( keyvalues["historic"]  == "residence"                 )  or
        ( keyvalues["historic"]  == "roundhouse"                )  or
        ( keyvalues["historic"]  == "ruins"                     )  or
        ( keyvalues["historic"]  == "sawmill"                   )  or
        ( keyvalues["historic"]  == "shelter"                   )  or
        ( keyvalues["historic"]  == "ship"                      )  or
        ( keyvalues["historic"]  == "smithy"                    )  or
        ( keyvalues["historic"]  == "sound_mirror"              )  or
        ( keyvalues["historic"]  == "standing_stone"            )  or
        ( keyvalues["historic"]  == "statue"                    )  or
        ( keyvalues["historic"]  == "stocks"                    )  or
        ( keyvalues["historic"]  == "stone"                     )  or
        ( keyvalues["historic"]  == "tank"                      )  or
        ( keyvalues["historic"]  == "theatre"                   )  or
        ( keyvalues["historic"]  == "tomb"                      )  or
        ( keyvalues["historic"]  == "tower"                     )  or
        ( keyvalues["historic"]  == "tower_house"               )  or
        ( keyvalues["historic"]  == "tumulus"                   )  or
        ( keyvalues["historic"]  == "village"                   )  or
        ( keyvalues["historic"]  == "village_pump"              )  or
        ( keyvalues["historic"]  == "water_pump"                )  or
        ( keyvalues["historic"]  == "wayside_cross"             )  or
        ( keyvalues["historic"]  == "wayside_shrine"            )  or
        ( keyvalues["historic"]  == "well"                      )  or
        ( keyvalues["historic"]  == "watermill"                 )  or
        ( keyvalues["historic"]  == "windmill"                  )  or
        ( keyvalues["historic"]  == "workhouse"                 )  or
        ( keyvalues["historic"]  == "wreck"                     )  or
        ( keyvalues["historic"]  == "yes"                       )  or
        ( keyvalues["natural"]   == "beach"                     )  or
        ( keyvalues["natural"]   == "cave_entrance"             )  or
        ( keyvalues["natural"]   == "cliff"                     )  or
        ( keyvalues["natural"]   == "grassland"                 )  or
        ( keyvalues["natural"]   == "heath"                     )  or
        ( keyvalues["natural"]   == "sand"                      )  or
        ( keyvalues["natural"]   == "scrub"                     )  or
        ( keyvalues["natural"]   == "spring"                    )  or
        ( keyvalues["natural"]   == "tree"                      )  or
        ( keyvalues["natural"]   == "water"                     )  or
        ( keyvalues["natural"]   == "wood"                      )  or
        ( keyvalues["leisure"]   == "garden"                    )  or
        ( keyvalues["leisure"]   == "nature_reserve"            )  or
        ( keyvalues["leisure"]   == "park"                      )  or
        ( keyvalues["leisure"]   == "sports_centre"             ))) then
      keyvalues["tourism"] = nil
   end

   if ((  keyvalues["tourism"] == "attraction"  ) and
       (( keyvalues["shop"]    ~= nil          )  or
        ( keyvalues["amenity"] ~= nil          )  or
        ( keyvalues["leisure"] == "park"       ))) then
      keyvalues["tourism"] = nil
   end

-- ----------------------------------------------------------------------------
-- There's a bit of "tagging for the renderer" going on with some large museums
-- ----------------------------------------------------------------------------
   if ((  keyvalues["tourism"] == "museum"          ) and 
       (( keyvalues["leisure"] == "garden"         )  or
        ( keyvalues["leisure"] == "nature_reserve" )  or
        ( keyvalues["leisure"] == "park"           ))) then
      keyvalues["leisure"] = nil
   end

-- ----------------------------------------------------------------------------
-- Detect unusual taggings of hills
-- ----------------------------------------------------------------------------
   if (( keyvalues["natural"] == "peak" ) and
       ( keyvalues["peak"]    == "hill" )) then
      keyvalues["natural"] = "hill"
   end

-- ----------------------------------------------------------------------------
-- Holy wells might be natural=spring or something else.
-- Make sure that we set "amenity" to something other than "place_of_worship"
-- The one existing "holy_well" is actually a spring.
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "holy_well" ) and
       ( keyvalues["natural"] == "spring"    )) then
      keyvalues["amenity"] = "holy_spring"
      keyvalues["natural"] = nil
   end

   if ( keyvalues["place_of_worship"] == "holy_well" ) then
      keyvalues["man_made"] = nil
      if ( keyvalues["natural"] == "spring" ) then
         keyvalues["amenity"] = "holy_spring"
         keyvalues["natural"] = nil
      else
         keyvalues["amenity"] = "holy_well"
         keyvalues["natural"] = nil
      end
   end

-- ----------------------------------------------------------------------------
-- Springs - lose a historic tag, if set.
-- ----------------------------------------------------------------------------
   if (( keyvalues["natural"] == "spring" ) and
       ( keyvalues["historic"] ~= nil     )) then
      keyvalues["historic"] = nil
   end

-- ----------------------------------------------------------------------------
-- Inverse springs - where water seeps below ground
-- We already show "dry" sinkholes; show these in the same way.
-- ----------------------------------------------------------------------------
   if ( keyvalues["waterway"] == "cave_of_debouchement" ) then
      keyvalues["natural"] = "sinkhole"
   end

-- ----------------------------------------------------------------------------
-- Boatyards
-- ----------------------------------------------------------------------------
   if (( keyvalues["waterway"]   == "boatyard" ) or
       ( keyvalues["industrial"] == "boatyard" )) then
      keyvalues["amenity"] = "boatyard"
      keyvalues["waterway"] = nil
      keyvalues["industrial"] = nil
   end

-- ----------------------------------------------------------------------------
-- Beer gardens etc.
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "beer_garden" ) or
       ( keyvalues["leisure"] == "beer_garden" )) then
      keyvalues["amenity"] = nil
      keyvalues["leisure"] = "garden"
      keyvalues["garden"] = "beer_garden"
   end

-- ----------------------------------------------------------------------------
-- Render biergartens as gardens, which is all they likely are.
-- Remove the symbol from unnamed ones - they're likely just pub beer gardens.
-- ----------------------------------------------------------------------------
   if (  keyvalues["amenity"] == "biergarten" ) then
      if (( keyvalues["name"] == nil           )   or
          ( keyvalues["name"] == "Beer Garden" )) then
         keyvalues["amenity"] = nil
      end

      keyvalues["leisure"] = "garden"
      keyvalues["garden"]  = "beer_garden"
   end

-- ----------------------------------------------------------------------------
-- Treat natural=meadow as a synonym for landuse=meadow, if no other landuse
-- ----------------------------------------------------------------------------
   if (( keyvalues["natural"] == "meadow" ) and
       ( keyvalues["landuse"] == nil      )) then
      keyvalues["landuse"] = "meadow"
   end

-- ----------------------------------------------------------------------------
-- "historic=bunker" and "historic=ruins;ruins=bunker"
-- This is set here to prevent unnamedcommercial being set just below.
-- 3 selections make up our "historic" bunkers, "or"ed together.
-- The first "or" includes "building=pillbox" because they are all historic.
-- In the "disused" check we also include "building=bunker".
-- ----------------------------------------------------------------------------
   if ((((  keyvalues["historic"] == "bunker"                      )   or
         (( keyvalues["historic"] == "ruins"                      )    and
          ( keyvalues["ruins"]    == "bunker"                     ))   or
         (  keyvalues["historic"] == "pillbox"                     )   or
         (  keyvalues["building"] == "pillbox"                     ))  and
        (   keyvalues["military"] == nil                            )) or
       ((   keyvalues["disused:military"] == "bunker"               )  and
        (   keyvalues["military"]         == nil                    )) or
       (((  keyvalues["military"]         == "bunker"              )   or
         (  keyvalues["building"]         == "bunker"              ))  and
        ((  keyvalues["disused"]          == "yes"                 )   or
         (( keyvalues["historic"]         ~= nil                  )   and
          ( keyvalues["historic"]         ~= "no"                 ))))) then
      keyvalues["historic"] = "bunker"
      keyvalues["disused"] = nil
      keyvalues["disused:military"] = nil
      keyvalues["military"] = nil
      keyvalues["ruins"] = nil
      keyvalues["tourism"]  = nil

      if (( keyvalues["landuse"] == nil ) and
          ( keyvalues["leisure"] == nil ) and
          ( keyvalues["natural"] == nil )) then
         keyvalues["landuse"] = "historic"
      end
   end

-- ----------------------------------------------------------------------------
-- highway=services is translated to commercial landuse - any overlaid parking
-- can then be seen.
--
-- highway=rest_area is translated lower down to amenity=parking.
-- ----------------------------------------------------------------------------
   if (  keyvalues["highway"] == "services" ) then
      keyvalues["highway"] = nil
      keyvalues["landuse"] = "commercial"
   end

-- ----------------------------------------------------------------------------
-- Things without icons - add "commercial" landuse to include a name 
-- (if one exists) too.
-- ----------------------------------------------------------------------------
   if (( keyvalues["landuse"]      == "churchyard"               ) or
       ( keyvalues["landuse"]      == "religious"                ) or
       ( keyvalues["leisure"]      == "racetrack"                ) or
       ( keyvalues["landuse"]      == "aquaculture"              ) or
       ( keyvalues["landuse"]      == "fishfarm"                 ) or
       ( keyvalues["industrial"]   == "fish_farm"                ) or
       ( keyvalues["seamark:type"] == "marine_farm"              )) then
      keyvalues["landuse"] = "commercial"
   end

-- ----------------------------------------------------------------------------
-- Shop groups - just treat as retail landuse.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "mall"            ) or
       ( keyvalues["amenity"] == "marketplace"     ) or
       ( keyvalues["shop"]    == "market"          ) or
       ( keyvalues["amenity"] == "market"          ) or
       ( keyvalues["amenity"] == "food_court"      ) or
       ( keyvalues["shop"]    == "shopping_centre" )) then
      keyvalues["landuse"] = "retail"
   end

-- ----------------------------------------------------------------------------
-- Scout camps etc.
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"]   == "scout_camp"     ) or
       ( keyvalues["landuse"]   == "scout_camp"     ) or	
       ( keyvalues["leisure"]   == "fishing"        ) or
       ( keyvalues["leisure"]   == "outdoor_centre" )) then
      keyvalues["leisure"] = "park"
   end

-- ----------------------------------------------------------------------------
-- Some people tag beach resorts as beaches - remove "beach_resort" there.
-- ----------------------------------------------------------------------------
   if (( keyvalues["leisure"] == "beach_resort" ) and
       ( keyvalues["natural"] == "beach"        )) then
      keyvalues["leisure"] = nil
   end

-- ----------------------------------------------------------------------------
-- Remove tourism=attraction from rock features that are rendered as rock(s)
-- ----------------------------------------------------------------------------
   if ((  keyvalues["tourism"]   == "attraction"     ) and
       (( keyvalues["natural"]   == "bare_rock"     ) or
        ( keyvalues["natural"]   == "boulder"       ) or
        ( keyvalues["natural"]   == "rock"          ) or
        ( keyvalues["natural"]   == "rocks"         ) or
        ( keyvalues["natural"]   == "stone"         ) or
        ( keyvalues["natural"]   == "stones"        ) or
        ( keyvalues["climbing"]  == "boulder"       ))) then
      keyvalues["tourism"] = nil
   end

-- ----------------------------------------------------------------------------
-- There is at least one closed "natural=couloir" with "surface=scree".
-- ----------------------------------------------------------------------------
   if (( keyvalues["natural"] ~= nil     ) and
       ( keyvalues["surface"] == "scree" )) then
      keyvalues["natural"] = "scree"
   end

-- ----------------------------------------------------------------------------
-- Render tidal beaches with more blue
-- ----------------------------------------------------------------------------
   if ((  keyvalues["natural"]   == "beach"      ) and
       (( keyvalues["tidal"]     == "yes"       )  or
        ( keyvalues["wetland"]   == "tidalflat" ))) then
      keyvalues["natural"] = "tidal_beach"
   end

-- ----------------------------------------------------------------------------
-- Render tidal scree with more blue
-- ----------------------------------------------------------------------------
   if (( keyvalues["natural"]   == "scree" ) and
       ( keyvalues["tidal"]     == "yes"   )) then
      keyvalues["natural"] = "tidal_scree"
   end

-- ----------------------------------------------------------------------------
-- Render tidal shingle with more blue
-- ----------------------------------------------------------------------------
   if (( keyvalues["natural"]   == "shingle" ) and
       ( keyvalues["tidal"]     == "yes"     )) then
      keyvalues["natural"] = "tidal_shingle"
   end

-- ----------------------------------------------------------------------------
-- Change natural=rocks on non-nodes to natural=bare_rock
-- ----------------------------------------------------------------------------
   if (( keyvalues["natural"]   == "rocks"  ) or
       ( keyvalues["natural"]   == "stones" )) then
      keyvalues["natural"] = "bare_rock"
   end

-- ----------------------------------------------------------------------------
-- Render tidal rocks with more blue
-- ----------------------------------------------------------------------------
   if ((  keyvalues["natural"]   == "bare_rock"  ) and
       (( keyvalues["tidal"]     == "yes"       )  or
        ( keyvalues["wetland"]   == "tidalflat" ))) then
      keyvalues["natural"] = "tidal_rock"
   end

-- ----------------------------------------------------------------------------
-- Boulders - are they climbing boulders or not?
-- If yes, let them get detected as "climbing pitches" ("amenity=pitch_climbing") 
-- or non-pitch climbing features ("natural=climbing")
-- ----------------------------------------------------------------------------
   if ((  keyvalues["natural"]    == "boulder"          ) or
       (( keyvalues["natural"]    == "stone"           )  and
        ( keyvalues["geological"] == "glacial_erratic" ))) then
      if (( keyvalues["sport"]    ~= "climbing"            ) and
          ( keyvalues["sport"]    ~= "climbing;bouldering" ) and
          ( keyvalues["climbing"] ~= "boulder"             )) then
         keyvalues["natural"] = "rock"
      end
   end

-- ----------------------------------------------------------------------------
-- leisure=dog_park is used a few times.  Map to pitch to differentiate from
-- underlying park.
-- "cricket_nets" is an oddity.  See https://lists.openstreetmap.org/pipermail/tagging/2023-January/thread.html#66908 .
-- ----------------------------------------------------------------------------
   if (( keyvalues["leisure"] == "dog_park"           ) or
       ( keyvalues["sport"]   == "cricket_nets"       ) or
       ( keyvalues["sport"]   == "cricket_nets;multi" ) or
       ( keyvalues["leisure"] == "practice_pitch"     )) then
      keyvalues["leisure"] = "pitch"
   end

-- ----------------------------------------------------------------------------
-- Show skate parks etc. (that aren't skate shops, or some other leisure 
-- already) as pitches.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["sport"]    == "skateboard"     )  or
        ( keyvalues["sport"]    == "skateboard;bmx" )) and
       (  keyvalues["shop"]     == nil               ) and
       (  keyvalues["leisure"]  == nil               )) then
      keyvalues["leisure"] = "pitch"
   end

-- ----------------------------------------------------------------------------
-- Map leisure=wildlife_hide to bird_hide etc.  Many times it will be.
-- ----------------------------------------------------------------------------
   if (( keyvalues["leisure"]      == "wildlife_hide" ) or
       ( keyvalues["amenity"]      == "wildlife_hide" ) or
       ( keyvalues["man_made"]     == "wildlife_hide" ) or
       ( keyvalues["amenity"]      == "bird_hide"     )) then
      keyvalues["leisure"]  = "bird_hide"
      keyvalues["amenity"]  = nil
      keyvalues["man_made"] = nil
   end

   if ((( keyvalues["amenity"]       == "hunting_stand" )   and
        ( keyvalues["hunting_stand"] == "grouse_butt"   ))  or
       ( keyvalues["man_made"]       == "grouse_butt"    )) then
      keyvalues["leisure"] = "grouse_butt"
      keyvalues["amenity"] = nil
      keyvalues["man_made"] = nil
   end

   if ( keyvalues["amenity"] == "hunting_stand" ) then
      keyvalues["leisure"] = "hunting_stand"
      keyvalues["amenity"] = nil
   end

-- ----------------------------------------------------------------------------
-- Treat harbour=yes as landuse=harbour, if not already landuse.
-- ----------------------------------------------------------------------------
   if (( keyvalues["harbour"] == "yes" ) and
       ( keyvalues["landuse"] == nil   )) then
      keyvalues["landuse"] = "harbour"
   end

-- ----------------------------------------------------------------------------
-- landuse=field is rarely used.  I tried unsuccessfully to change the colour 
-- in the stylesheet so am mapping it here.
-- ----------------------------------------------------------------------------
   if (keyvalues["landuse"]   == "field") then
      keyvalues["landuse"] = "farmland"
   end

-- ----------------------------------------------------------------------------
-- Various tags for showgrounds
-- Other tags are suppressed to prevent them appearing ahead of "landuse"
-- ----------------------------------------------------------------------------
   if ((  keyvalues["amenity"]    == "showground"       )  or
       (  keyvalues["leisure"]    == "showground"       )  or
       (  keyvalues["amenity"]    == "show_ground"      )  or
       (  keyvalues["amenity"]    == "show_grounds"     )  or
       (( keyvalues["tourism"]    == "attraction"      )   and
        ( keyvalues["attraction"] == "showground"      ))  or
       (  keyvalues["amenity"]    == "festival_grounds" )  or
       (  keyvalues["amenity"]    == "car_boot_sale"    )) then
      keyvalues["amenity"] = nil
      keyvalues["leisure"] = nil
      keyvalues["tourism"] = nil
      keyvalues["landuse"] = "meadow"
   end

-- ----------------------------------------------------------------------------
-- Some kinds of farmland and meadow should be changed to "landuse=farmgrass", 
-- which is rendered slightly greener than the normal farmland (and less green 
-- than landuse=meadow)
-- ----------------------------------------------------------------------------
   if ((  keyvalues["landuse"]  == "farmland"                    ) and
       (( keyvalues["farmland"] == "pasture"                    )  or
        ( keyvalues["farmland"] == "heath"                      )  or
        ( keyvalues["farmland"] == "paddock"                    )  or
        ( keyvalues["farmland"] == "meadow"                     )  or
        ( keyvalues["farmland"] == "pasture;heath"              )  or
        ( keyvalues["farmland"] == "turf_production"            )  or
        ( keyvalues["farmland"] == "grassland"                  )  or
        ( keyvalues["farmland"] == "wetland"                    )  or
        ( keyvalues["farmland"] == "marsh"                      )  or
        ( keyvalues["farmland"] == "turf"                       )  or
        ( keyvalues["farmland"] == "animal_keeping"             )  or
        ( keyvalues["farmland"] == "grass"                      )  or
        ( keyvalues["farmland"] == "crofts"                     )  or
        ( keyvalues["farmland"] == "scrub"                      )  or
        ( keyvalues["farmland"] == "pasture;wetland"            )  or
        ( keyvalues["farmland"] == "equestrian"                 )  or
        ( keyvalues["animal"]   == "cow"                        )  or
        ( keyvalues["animal"]   == "cattle"                     )  or
        ( keyvalues["animal"]   == "chicken"                    )  or
        ( keyvalues["animal"]   == "horse"                      )  or
        ( keyvalues["meadow"]   == "agricultural"               )  or
        ( keyvalues["meadow"]   == "paddock"                    )  or
        ( keyvalues["meadow"]   == "pasture"                    )  or
        ( keyvalues["produce"]  == "turf"                       )  or
        ( keyvalues["produce"]  == "grass"                      )  or
        ( keyvalues["produce"]  == "Silage"                     )  or
        ( keyvalues["produce"]  == "cow"                        )  or
        ( keyvalues["produce"]  == "cattle"                     )  or
        ( keyvalues["produce"]  == "milk"                       )  or
        ( keyvalues["produce"]  == "dairy"                      )  or
        ( keyvalues["produce"]  == "meat"                       )  or
        ( keyvalues["produce"]  == "horses"                     )  or
        ( keyvalues["produce"]  == "live_animal"                )  or
        ( keyvalues["produce"]  == "live_animal;cows"           )  or
        ( keyvalues["produce"]  == "live_animal;sheep"          )  or
        ( keyvalues["produce"]  == "live_animal;Cattle_&_Sheep" )  or
        ( keyvalues["produce"]  == "live_animals"               ))) then
      keyvalues["landuse"] = "farmgrass"
   end

   if ((  keyvalues["landuse"]  == "meadow"        ) and
       (( keyvalues["meadow"]   == "agricultural" )  or
        ( keyvalues["meadow"]   == "paddock"      )  or
        ( keyvalues["meadow"]   == "pasture"      )  or
        ( keyvalues["meadow"]   == "agriculture"  )  or
        ( keyvalues["meadow"]   == "hay"          )  or
        ( keyvalues["meadow"]   == "managed"      )  or
        ( keyvalues["meadow"]   == "cut"          )  or
        ( keyvalues["animal"]   == "pig"          )  or
        ( keyvalues["animal"]   == "sheep"        )  or
        ( keyvalues["animal"]   == "cow"          )  or
        ( keyvalues["animal"]   == "cattle"       )  or
        ( keyvalues["animal"]   == "chicken"      )  or
        ( keyvalues["animal"]   == "horse"        )  or
        ( keyvalues["farmland"] == "field"        )  or
        ( keyvalues["farmland"] == "pasture"      )  or
        ( keyvalues["farmland"] == "crofts"       ))) then
      keyvalues["landuse"] = "farmgrass"
   end

   if (( keyvalues["landuse"] == "paddock"        ) or
       ( keyvalues["landuse"] == "animal_keeping" )) then
      keyvalues["landuse"] = "farmgrass"
   end

-- ----------------------------------------------------------------------------
-- As well as agricultural meadows, we show a couple of other subtags of meadow
-- slightly differently.
-- ----------------------------------------------------------------------------
   if (( keyvalues["landuse"]  == "meadow"       ) and
       ( keyvalues["meadow"]   == "transitional" )) then
      keyvalues["landuse"] = "meadowtransitional"
   end

   if (( keyvalues["landuse"]  == "meadow"       ) and
       ( keyvalues["meadow"]   == "wildflower" )) then
      keyvalues["landuse"] = "meadowwildflower"
   end

   if (( keyvalues["landuse"]  == "meadow"       ) and
       ( keyvalues["meadow"]   == "perpetual" )) then
      keyvalues["landuse"] = "meadowperpetual"
   end

-- ----------------------------------------------------------------------------
-- Change landuse=greenhouse_horticulture to farmyard.
-- ----------------------------------------------------------------------------
   if (keyvalues["landuse"]   == "greenhouse_horticulture") then
      keyvalues["landuse"] = "farmyard"
   end

-- ----------------------------------------------------------------------------
-- Attempt to do something sensible with trees
--
-- "boundary=forest" is the latest attempt to resolve the "landuse=forest is 
-- used for different things" issue.  Unfortunately, it can also be used with 
-- other landuse values.
--
-- There are a few 10s of natural=woodland and natural=forest; treat them the same
-- as other woodland.  If we have landuse=forest on its own without
-- leaf_type, then we don't change it - we'll handle that separately in the
-- mss file.
-- ----------------------------------------------------------------------------
  if (( keyvalues["boundary"] == "forest" ) and
      ( keyvalues["landuse"]  == nil      )) then
      keyvalues["landuse"] = "forest"
      keyvalues["boundary"] = nil
  end

  if ( keyvalues["landuse"] == "forestry" ) then
      keyvalues["landuse"] = "forest"
  end

  if ( keyvalues["natural"] == "woodland" ) then
      keyvalues["natural"] = "wood"
  end

-- ----------------------------------------------------------------------------
-- Use operator (but not brand) on various natural objects, always in brackets.
-- (compare with the similar check including "brand" for e.g. "atm" below)
-- This is done before we change tags based on leaf_type.
-- ----------------------------------------------------------------------------
   if (( keyvalues["landuse"] == "forest" )  or
       ( keyvalues["natural"] == "wood"   )) then
      if ( keyvalues["name"] == nil ) then
         if ( keyvalues["operator"] ~= nil ) then
            keyvalues["name"] = "(" .. keyvalues["operator"] .. ")"
            keyvalues["operator"] = nil
         end
      else
         if (( keyvalues["operator"] ~= nil                )  and
             ( keyvalues["operator"] ~= keyvalues["name"]  )) then
            keyvalues["name"] = keyvalues["name"] .. " (" .. keyvalues["operator"] .. ")"
            keyvalues["operator"] = nil
         end
      end
   end

  if ((( keyvalues["landuse"]   == "forest"     )  and
       ( keyvalues["leaf_type"] ~= nil          )) or
      (  keyvalues["natural"]   == "forest"      ) or
      (  keyvalues["landcover"] == "trees"       ) or
      (( keyvalues["natural"]   == "tree_group" )  and
       ( keyvalues["landuse"]   == nil          )  and
       ( keyvalues["leisure"]   == nil          ))) then
      keyvalues["landuse"] = nil
      keyvalues["natural"] = "wood"
   end

-- ----------------------------------------------------------------------------
-- The "landcover" layer considers a whole bunch of tags to incorporate into
-- one layer.  The way that this is done (derived from OSM Carto from some
-- years back) means that an unexpected and unrendered "landuse" tag might
-- prevent a valid "natural" one from being displayed.
-- Other combinations will also be affectedm, but have not been seen occurring
-- together.
-- ----------------------------------------------------------------------------
   if (( keyvalues["landuse"] ~= nil    ) and
       ( keyvalues["natural"] == "wood" )) then
      keyvalues["landuse"] = nil
   end

   if (( keyvalues["leaf_type"]   == "broadleaved"  )  and
       ( keyvalues["natural"]     == "wood"         )) then
      keyvalues["landuse"] = nil
      keyvalues["natural"] = "broadleaved"
   end

   if (( keyvalues["leaf_type"]   == "needleleaved" )  and
       ( keyvalues["natural"]     == "wood"         )) then
      keyvalues["landuse"] = nil
      keyvalues["natural"] = "needleleaved"
   end

   if (( keyvalues["leaf_type"]   == "mixed"        )  and
       ( keyvalues["natural"]     == "wood"         )) then
      keyvalues["landuse"] = nil
      keyvalues["natural"] = "mixedleaved"
   end

-- ----------------------------------------------------------------------------
-- Consolidate some unusual wheelchair tags
-- ----------------------------------------------------------------------------
   if (( keyvalues["wheelchair"] == "1"                )  or
       ( keyvalues["wheelchair"] == "2"                )  or
       ( keyvalues["wheelchair"] == "3"                )  or
       ( keyvalues["wheelchair"] == "5"                )  or
       ( keyvalues["wheelchair"] == "bell"             )  or
       ( keyvalues["wheelchair"] == "customers"        )  or
       ( keyvalues["wheelchair"] == "designated"       )  or
       ( keyvalues["wheelchair"] == "destination"      )  or
       ( keyvalues["wheelchair"] == "friendly"         )  or
       ( keyvalues["wheelchair"] == "full"             )  or
       ( keyvalues["wheelchair"] == "number of rooms"  )  or
       ( keyvalues["wheelchair"] == "official"         )  or
       ( keyvalues["wheelchair"] == "on request"       )  or
       ( keyvalues["wheelchair"] == "only"             )  or
       ( keyvalues["wheelchair"] == "permissive"       )  or
       ( keyvalues["wheelchair"] == "ramp"             )  or
       ( keyvalues["wheelchair"] == "unisex"           )) then
      keyvalues["wheelchair"] = "yes"
   end

   if (( keyvalues["wheelchair"] == "difficult"                    )  or
       ( keyvalues["wheelchair"] == "limited (No automatic door)"  )  or
       ( keyvalues["wheelchair"] == "limited, notice required"     )  or
       ( keyvalues["wheelchair"] == "restricted"                   )) then
      keyvalues["wheelchair"] = "limited"
   end

   if ( keyvalues["wheelchair"] == "impractical" ) then
      keyvalues["wheelchair"] = "limited"
   end

-- ----------------------------------------------------------------------------
-- Remove "real_ale" tag on industrial and craft breweries that aren't also
-- a pub, bar, restaurant, cafe etc. or hotel.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["industrial"] == "brewery" ) or
        ( keyvalues["craft"]      == "brewery" )) and
       (  keyvalues["real_ale"]   ~= nil        ) and
       (  keyvalues["real_ale"]   ~= "maybe"    ) and
       (  keyvalues["real_ale"]   ~= "no"       ) and
       (  keyvalues["amenity"]    == nil        ) and
       (  keyvalues["tourism"]   ~= "hotel"     )) then
      keyvalues["real_ale"] = nil
      keyvalues["real_cider"] = nil
   end

-- ----------------------------------------------------------------------------
-- Remove "shop" tag on industrial or craft breweries.
-- We pick one thing to display them as, and in this case it's "brewery".
-- ----------------------------------------------------------------------------
   if ((( keyvalues["industrial"] == "brewery" ) or
        ( keyvalues["craft"]      == "brewery" ) or
        ( keyvalues["craft"]      == "cider"   )) and
       (  keyvalues["shop"]       ~= nil        )) then
      keyvalues["shop"] = nil
   end

-- ----------------------------------------------------------------------------
-- Don't show pubs, cafes or restaurants if you can't actually get to them.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["amenity"] == "pub"        ) or
        ( keyvalues["amenity"] == "cafe"       ) or
        ( keyvalues["amenity"] == "restaurant" )) and
       (  keyvalues["access"]  == "no"          )) then
      keyvalues["amenity"] = nil
   end

-- ----------------------------------------------------------------------------
-- Suppress historic tag on pubs.
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"]  == "pub"     ) and
       ( keyvalues["historic"] ~= nil       )) then
      keyvalues["historic"] = nil
   end

-- ----------------------------------------------------------------------------
-- If "leisure=music_venue" is set try and work out if something should take 
-- precedence.
-- We do this check here rather than at "concert_hall" further down because 
-- "bar" and "pub" can be changed below based on other tags.
-- ----------------------------------------------------------------------------
   if ( keyvalues["leisure"] == "music_venue" ) then
      if (( keyvalues["amenity"] == "bar" ) or
          ( keyvalues["amenity"] == "pub" )) then
         keyvalues["leisure"] = nil
      else
         keyvalues["amenity"] = "concert_hall"
      end
   end

-- ----------------------------------------------------------------------------
-- Things that are both hotels, B&Bs etc. and pubs should render as pubs, 
-- because I'm far more likely to be looking for the latter than the former.
-- This is done by removing the tourism tag for them.
--
-- People have used lots of tags for "former" or "dead" pubs.
-- "disused:amenity=pub" is the most popular.
--
-- Treat things that were pubs but are now something else as whatever else 
-- they now are.
--
-- If a real_ale tag has got stuck on something unexpected, don't render that
-- as a pub.
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"]   == "pub"   ) and
       ( keyvalues["tourism"]   ~= nil     )) then
      if (( keyvalues["tourism"]   == "hotel"             ) or
          ( keyvalues["tourism"]   == "guest_house"       ) or
          ( keyvalues["tourism"]   == "bed_and_breakfast" ) or
          ( keyvalues["tourism"]   == "chalet"            ) or
          ( keyvalues["tourism"]   == "hostel"            ) or
          ( keyvalues["tourism"]   == "motel"             )) then
         keyvalues["accommodation"] = "yes"
      end

      keyvalues["tourism"] = nil
   end

   if (( keyvalues["tourism"] == "hotel" ) and
       ( keyvalues["pub"]     == "yes"   )) then
      keyvalues["accommodation"] = "yes"
      keyvalues["amenity"] = "pub"
      keyvalues["pub"] = nil
      keyvalues["tourism"] = nil
   end

   if ((( keyvalues["tourism"]  == "hotel"       )   or
        ( keyvalues["tourism"]  == "guest_house" ))  and
       (  keyvalues["real_ale"] ~= nil            )  and
       (  keyvalues["real_ale"] ~= "maybe"        )  and
       (  keyvalues["real_ale"] ~= "no"           )) then
      keyvalues["accommodation"] = "yes"
      keyvalues["amenity"] = "pub"
      keyvalues["tourism"] = nil
   end

   if ((  keyvalues["leisure"]         == "outdoor_seating" ) and
       (( keyvalues["surface"]         == "grass"          ) or
        ( keyvalues["beer_garden"]     == "yes"            ) or
        ( keyvalues["outdoor_seating"] == "garden"         ))) then
      keyvalues["leisure"] = "garden"
      keyvalues["garden"] = "beer_garden"
   end

   if ((  keyvalues["abandoned:amenity"] == "pub"             )   or
       (  keyvalues["amenity:disused"]   == "pub"             )   or
       (  keyvalues["disused"]           == "pub"             )   or
       (  keyvalues["disused:pub"]       == "yes"             )   or
       (  keyvalues["former_amenity"]    == "former_pub"      )   or
       (  keyvalues["former_amenity"]    == "pub"             )   or
       (  keyvalues["former_amenity"]    == "old_pub"         )   or
       (  keyvalues["former:amenity"]    == "pub"             )   or
       (  keyvalues["old_amenity"]       == "pub"             )) then
      keyvalues["disused:amenity"] = "pub"
      keyvalues["amenity:disused"] = nil
      keyvalues["disused"] = nil
      keyvalues["disused:pub"] = nil
      keyvalues["former_amenity"] = nil
      keyvalues["old_amenity"] = nil
   end

   if (( keyvalues["historic"] == "pub" ) and
       ( keyvalues["amenity"]  == nil   ) and
       ( keyvalues["shop"]     == nil   )) then
      keyvalues["disused:amenity"] = "pub"
      keyvalues["historic"] = nil
   end

   if ((  keyvalues["amenity"]           == "closed_pub"      )   or
       (  keyvalues["amenity"]           == "dead_pub"        )   or
       (  keyvalues["amenity"]           == "disused_pub"     )   or
       (  keyvalues["amenity"]           == "former_pub"      )   or
       (  keyvalues["amenity"]           == "old_pub"         )   or
       (( keyvalues["amenity"]           == "pub"            )    and
        ( keyvalues["disused"]           == "yes"            ))   or
       (( keyvalues["amenity"]           == "pub"            )    and
        ( keyvalues["opening_hours"]     == "closed"         ))) then
      keyvalues["disused:amenity"] = "pub"
      keyvalues["amenity:disused"] = nil
      keyvalues["disused"] = nil
      keyvalues["disused:pub"] = nil
      keyvalues["former_amenity"] = nil
      keyvalues["old_amenity"] = nil
      keyvalues["amenity"] = nil
   end

   if ((  keyvalues["disused:amenity"]   == "pub"    ) and
       (( keyvalues["tourism"]           ~= nil     )  or
        ( keyvalues["amenity"]           ~= nil     )  or
        ( keyvalues["leisure"]           ~= nil     )  or
        ( keyvalues["shop"]              ~= nil     )  or
        ( keyvalues["office"]            ~= nil     )  or
        ( keyvalues["craft"]             ~= nil     ))) then
      keyvalues["disused:amenity"] = nil
   end

   if ((  keyvalues["real_ale"]  ~= nil    ) and
       (( keyvalues["amenity"]   == nil   )  and
        ( keyvalues["shop"]      == nil   )  and
        ( keyvalues["tourism"]   == nil   )  and
        ( keyvalues["room"]      == nil   )  and
        ( keyvalues["leisure"]   == nil   )  and
        ( keyvalues["club"]      == nil   ))) then
      keyvalues["real_ale"] = nil
   end

-- ----------------------------------------------------------------------------
-- If something has been tagged both as a brewery and a pub or bar, render as
-- a pub with a microbrewery.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["amenity"]    == "pub"     )  or
        ( keyvalues["amenity"]    == "bar"     )) and
       (( keyvalues["craft"]      == "brewery" )  or
        ( keyvalues["industrial"] == "brewery" ))) then
      keyvalues["amenity"]  = "pub"
      keyvalues["microbrewery"]  = "yes"
      keyvalues["craft"]  = nil
      keyvalues["industrial"]  = nil
   end

-- ----------------------------------------------------------------------------
-- If a food place has a real_ale tag, also add a food tag an let the real_ale
-- tag render.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["amenity"]  == "cafe"       )  or
        ( keyvalues["amenity"]  == "restaurant" )) and
       (( keyvalues["real_ale"] ~= nil          )  and
        ( keyvalues["real_ale"] ~= "maybe"      )  and
        ( keyvalues["real_ale"] ~= "no"         )) and
       (  keyvalues["food"]     == nil           )) then
      keyvalues["food"]  = "yes"
   end

-- ----------------------------------------------------------------------------
-- Attempt to do something sensible with pubs (and other places that serve
-- real_ale)
-- Pubs that serve real_ale get a nice IPA, ones that don't a yellowy lager,
-- closed pubs an "X".  Food gets an F on the right, micropubs a u on the left.
-- Noncarpeted floor gets an underline, accommodation a blue "roof", and 
-- Microbrewery a "mash tun in the background".  Not all combinations exist so
-- not all are checked for.  Pubs without any other tags get the default empty 
-- glass.
--
-- Pub flags:
-- Live or dead pub?  y or n, or c (closed due to covid)
-- Real ale?          y n or d (don't know)
-- Food 	      y or d
-- Noncarpeted floor  y or d
-- Microbrewery	      y n or d
-- Micropub	      y n or d
-- Accommodation      y n or d
-- Wheelchair	      y, l, n or d
-- Beer Garden	      g (beer garden), o (outside seating), d (don't know)
-- ----------------------------------------------------------------------------
   if (( keyvalues["description:floor"] ~= nil                  ) or
       ( keyvalues["floor:material"]    == "brick"              ) or
       ( keyvalues["floor:material"]    == "brick;concrete"     ) or
       ( keyvalues["floor:material"]    == "concrete"           ) or
       ( keyvalues["floor:material"]    == "grubby carpet"      ) or
       ( keyvalues["floor:material"]    == "lino"               ) or
       ( keyvalues["floor:material"]    == "lino;carpet"        ) or
       ( keyvalues["floor:material"]    == "lino;rough_wood"    ) or
       ( keyvalues["floor:material"]    == "lino;tiles;stone"   ) or
       ( keyvalues["floor:material"]    == "paving_stones"      ) or
       ( keyvalues["floor:material"]    == "rough_carpet"       ) or
       ( keyvalues["floor:material"]    == "rough_wood"         ) or
       ( keyvalues["floor:material"]    == "rough_wood;carpet"  ) or
       ( keyvalues["floor:material"]    == "rough_wood;lino"    ) or
       ( keyvalues["floor:material"]    == "rough_wood;stone"   ) or
       ( keyvalues["floor:material"]    == "rough_wood;tiles"   ) or
       ( keyvalues["floor:material"]    == "slate"              ) or
       ( keyvalues["floor:material"]    == "slate;carpet"       ) or
       ( keyvalues["floor:material"]    == "stone"              ) or
       ( keyvalues["floor:material"]    == "stone;carpet"       ) or
       ( keyvalues["floor:material"]    == "stone;rough_carpet" ) or
       ( keyvalues["floor:material"]    == "stone;rough_wood"   ) or
       ( keyvalues["floor:material"]    == "tiles"              ) or
       ( keyvalues["floor:material"]    == "tiles;rough_wood"   )) then
      keyvalues["noncarpeted"] = "yes"
   end

   if (( keyvalues["micropub"] == "yes"   ) or
       ( keyvalues["pub"]      == "micro" )) then
      keyvalues["micropub"] = nil
      keyvalues["pub"]      = "micropub"
   end

-- ----------------------------------------------------------------------------
-- The misspelling "accomodation" (with one "m") is quite common.
-- ----------------------------------------------------------------------------
   if (( keyvalues["accommodation"] == nil )  and
       ( keyvalues["accomodation"]  ~= nil )) then
      keyvalues["accommodation"] = keyvalues["accomodation"]
      keyvalues["accomodation"]  = nil
   end
		  
-- ----------------------------------------------------------------------------
-- Next, "closed due to covid" pubs
-- ----------------------------------------------------------------------------
   if ((  keyvalues["amenity"]               == "pub"        ) and
       (( keyvalues["opening_hours:covid19"] == "off"       ) or
        ( keyvalues["opening_hours:covid19"] == "closed"    ) or
        ( keyvalues["access:covid19"]        == "no"        ))) then
      keyvalues["amenity"] = "pub_cddddddd"
      keyvalues["real_ale"] = nil
   end

-- ----------------------------------------------------------------------------
-- Does a pub really serve food?
-- Below we check for "any food value but no".
-- Here we exclude certain food values from counting towards displaying the "F"
-- that says a pub serves food.  As far as I am concerned, sandwiches, pies,
-- or even one of Michael Gove's scotch eggs would count as "food" but a packet
-- of crisps would not.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["amenity"] == "pub"         ) and
       (( keyvalues["food"]    == "snacks"     ) or
        ( keyvalues["food"]    == "bar_snacks" ))) then
      keyvalues["food"] = "no"
   end

-- ----------------------------------------------------------------------------
-- Main "real_ale icon selection" logic
-- Note that there's no "if pub" here, so any non-pub establishment that serves
-- real ale will get the icon (hotels, restaurants, cafes, etc.)
-- We have explicitly excluded pubs "closed for covid" above.
-- After this large "if" there is no "else" but another "if" for non-real ale
-- pubs (that does check that the thing is actually a pub).
-- ----------------------------------------------------------------------------
   if (( keyvalues["real_ale"] ~= nil     ) and
       ( keyvalues["real_ale"] ~= "maybe" ) and
       ( keyvalues["real_ale"] ~= "no"    )) then
      if (( keyvalues["food"] ~= nil  ) and
          ( keyvalues["food"] ~= "no" )) then
         if ( keyvalues["noncarpeted"] == "yes"  ) then
            if ( keyvalues["microbrewery"] == "yes"  ) then
                           -- pub_yyyyy micropub unchecked (no examples yet)
               if (( keyvalues["accommodation"] ~= nil  ) and
                   ( keyvalues["accommodation"] ~= "no" )) then
                  keyvalues["amenity"] = "pub_yyyyydy"
                  append_wheelchair(keyvalues)
                           -- no beer garden appended (no examples yet)
	       else -- no accommodation
		  if ( keyvalues["wheelchair"] == "yes" ) then
                     keyvalues["amenity"] = "pub_yyyyydny"
                     append_beer_garden(keyvalues)
                  else
		     if ( keyvalues["wheelchair"] == "limited" ) then
                        keyvalues["amenity"] = "pub_yyyyydnl"
                        append_beer_garden(keyvalues)
                     else
                        if ( keyvalues["wheelchair"] == "no" ) then
                           keyvalues["amenity"] = "pub_yyyyydnn"
                                              -- no beer garden appended (no examples yet)
                        else
                           keyvalues["amenity"] = "pub_yyyyydnd"
                           append_beer_garden(keyvalues)
                        end
                     end
                  end
	       end -- accommodation
            else -- no microbrewery
	       if ( keyvalues["pub"] == "micropub" ) then
                  keyvalues["amenity"] = "pub_yyyynyd"
                                              -- accommodation unchecked (no examples yet)
                  append_wheelchair(keyvalues)
                  append_beer_garden(keyvalues)
               else
                  keyvalues["amenity"] = "pub_yyyynn"
                  append_accommodation(keyvalues)
                  append_wheelchair(keyvalues)
                  append_beer_garden(keyvalues)
               end
	    end -- microbrewery
         else -- not noncarpeted
            if ( keyvalues["microbrewery"] == "yes"  ) then
               if (( keyvalues["accommodation"] ~= nil  ) and
                   ( keyvalues["accommodation"] ~= "no" )) then
		  if ( keyvalues["wheelchair"] == "yes" ) then
                     keyvalues["amenity"] = "pub_yyydydyy"
                                              -- no beer garden appended (no examples yet)
		  else
		     if ( keyvalues["wheelchair"] == "limited" ) then
                        keyvalues["amenity"] = "pub_yyydydyl"
                                              -- no beer garden appended (no examples yet)
		     else
		        if ( keyvalues["wheelchair"] == "no" ) then
                           keyvalues["amenity"] = "pub_yyydydyn"
                                              -- no beer garden appended (no examples yet)
			else
                           keyvalues["amenity"] = "pub_yyydydyd"
                           append_beer_garden(keyvalues)
			end
		     end
		  end
	       else
		  if ( keyvalues["wheelchair"] == "yes" ) then
                     keyvalues["amenity"] = "pub_yyydydny"
                                              -- no beer garden appended (no examples yet)
                  else
		     if ( keyvalues["wheelchair"] == "limited" ) then
                        keyvalues["amenity"] = "pub_yyydydnl"
                        append_beer_garden(keyvalues)
                     else
		        if ( keyvalues["wheelchair"] == "no" ) then
                           keyvalues["amenity"] = "pub_yyydydnn"
                                              -- no beer garden appended (no examples yet)
                        else
                           keyvalues["amenity"] = "pub_yyydydnd"
                           append_beer_garden(keyvalues)
                        end
                     end
                  end
	       end
	    else
	       if ( keyvalues["pub"] == "micropub" ) then
                  keyvalues["amenity"] = "pub_yyydnyd"
                                              -- accommodation unchecked (no examples yet)
                  append_wheelchair(keyvalues)
                  append_beer_garden(keyvalues)
               else
                  keyvalues["amenity"] = "pub_yyydnn"
                  append_accommodation(keyvalues)
                  append_wheelchair(keyvalues)
                  append_beer_garden(keyvalues)
               end
	    end
         end -- noncarpeted
      else -- no food
         if ( keyvalues["noncarpeted"] == "yes"  ) then
            if ( keyvalues["microbrewery"] == "yes"  ) then
                                              -- micropub unchecked (no examples yet)
               if (( keyvalues["accommodation"] ~= nil  ) and
                   ( keyvalues["accommodation"] ~= "no" )) then
                  keyvalues["amenity"] = "pub_yydyydy"
                  append_wheelchair(keyvalues)
                                              -- no beer garden appended (no examples yet)
	       else
	          if ( keyvalues["wheelchair"] == "yes" ) then
                     keyvalues["amenity"] = "pub_yydyydny"
                                              -- no beer garden appended (no examples yet)
     		  else
	             if ( keyvalues["wheelchair"] == "limited" ) then
                        keyvalues["amenity"] = "pub_yydyydnl"
                        append_beer_garden(keyvalues)
		     else
		        if ( keyvalues["wheelchair"] == "no" ) then
                           keyvalues["amenity"] = "pub_yydyydnn"
                           append_beer_garden(keyvalues)
		        else
                           keyvalues["amenity"] = "pub_yydyydnd"
                           append_beer_garden(keyvalues)
		        end
		     end
	          end
	       end
	    else
	       if ( keyvalues["pub"] == "micropub" ) then
		  if ( keyvalues["wheelchair"] == "yes" ) then
                     keyvalues["amenity"] = "pub_yydynydy"
                                              -- no beer garden appended (no examples yet)
		  else
		     if ( keyvalues["wheelchair"] == "limited" ) then
                        keyvalues["amenity"] = "pub_yydynydl"
                        append_beer_garden(keyvalues)
	             else
			if ( keyvalues["wheelchair"] == "no" ) then
                           keyvalues["amenity"] = "pub_yydynydn"
                           append_beer_garden(keyvalues)
			else
                           keyvalues["amenity"] = "pub_yydynydd"
                                              -- no beer garden appended (no examples yet)
			end
	             end
		  end
	       else
                  keyvalues["amenity"] = "pub_yydynn"
                  append_accommodation(keyvalues)
                  append_wheelchair(keyvalues)
                  append_beer_garden(keyvalues)
	       end
	    end
         else
            if ( keyvalues["microbrewery"] == "yes"  ) then
	       if ( keyvalues["pub"] == "micropub" ) then
                           -- accommodation unchecked (no examples yet)
		  if ( keyvalues["wheelchair"] == "yes" ) then
                     keyvalues["amenity"] = "pub_yyddyydy"
                     append_beer_garden(keyvalues)
                  else
		     if ( keyvalues["wheelchair"] == "limited" ) then
                        keyvalues["amenity"] = "pub_yyddyydl"
                                             -- no beer garden appended (no examples yet)
                     else
		        if ( keyvalues["wheelchair"] == "no" ) then
                           keyvalues["amenity"] = "pub_yyddyydn"
                                             -- no beer garden appended (no examples yet)
                        else
                           keyvalues["amenity"] = "pub_yyddyydd"
                                             -- no beer garden appended (no examples yet)
                        end
                     end
                  end
               else  -- not micropub
                  if (( keyvalues["accommodation"] ~= nil  ) and
                      ( keyvalues["accommodation"] ~= "no" )) then
		     if ( keyvalues["wheelchair"] == "yes" ) then
                        keyvalues["amenity"] = "pub_yyddynyy"
                        append_beer_garden(keyvalues)
                     else
		        if ( keyvalues["wheelchair"] == "limited" ) then
                           keyvalues["amenity"] = "pub_yyddynyl"
                                             -- no beer garden appended (no examples yet)
                        else
			   if ( keyvalues["wheelchair"] == "no" ) then
                              keyvalues["amenity"] = "pub_yyddynyn"
                                             -- no beer garden appended (no examples yet)
                           else
                              keyvalues["amenity"] = "pub_yyddynyd"
                              append_beer_garden(keyvalues)
                           end
                        end
                     end
                  else  -- no accommodation
                     keyvalues["amenity"] = "pub_yyddynn"
                     append_wheelchair(keyvalues)
                     append_beer_garden(keyvalues)
                  end -- accommodation
               end  -- micropub
	    else  -- not microbrewery
	       if ( keyvalues["pub"] == "micropub" ) then
		  if ( keyvalues["wheelchair"] == "yes" ) then
                     keyvalues["amenity"] = "pub_yyddnydy"
                                             -- no beer garden appended (no examples yet)
		  else
		     if ( keyvalues["wheelchair"] == "limited" ) then
                        keyvalues["amenity"] = "pub_yyddnydl"
                                             -- no beer garden appended (no examples yet)
		     else
			if ( keyvalues["wheelchair"] == "no" ) then
                           keyvalues["amenity"] = "pub_yyddnydn"
                           append_beer_garden(keyvalues)
			else
                           keyvalues["amenity"] = "pub_yyddnydd"
                           append_beer_garden(keyvalues)
			end
		     end
		  end
               else
                  keyvalues["amenity"] = "pub_yyddnn"
                  append_accommodation(keyvalues)
                  append_wheelchair(keyvalues)
                  append_beer_garden(keyvalues)
               end
	    end -- microbrewery
         end
      end -- food
   end -- real_ale

   if (( keyvalues["real_ale"] == "no" ) and
       ( keyvalues["amenity"] == "pub" )) then
      if (( keyvalues["food"] ~= nil  ) and
          ( keyvalues["food"] ~= "no" )) then
         if ( keyvalues["noncarpeted"] == "yes"  ) then
            keyvalues["amenity"] = "pub_ynyyddd"
                                              -- accommodation unchecked (no examples yet)
            append_wheelchair(keyvalues)
            append_beer_garden(keyvalues)
         else
            if (( keyvalues["accommodation"] ~= nil  ) and
                ( keyvalues["accommodation"] ~= "no" )) then
               if ( keyvalues["wheelchair"] == "yes" ) then
                  keyvalues["amenity"] = "pub_ynydddyy"
                  append_beer_garden(keyvalues)
	       else
	          if ( keyvalues["wheelchair"] == "limited" ) then
                     keyvalues["amenity"] = "pub_ynydddyl"
                                              -- no beer garden appended (no examples yet)
	          else
	             if ( keyvalues["wheelchair"] == "no" ) then
                        keyvalues["amenity"] = "pub_ynydddyn"
                                             -- no beer garden appended (no examples yet)
		     else
                        keyvalues["amenity"] = "pub_ynydddyd"
                        append_beer_garden(keyvalues)
	             end
	          end
	       end
	    else  -- accommodation
               if ( keyvalues["wheelchair"] == "yes" ) then
                  keyvalues["amenity"] = "pub_ynydddny"
                  append_beer_garden(keyvalues)
	       else
	          if ( keyvalues["wheelchair"] == "limited" ) then
                     keyvalues["amenity"] = "pub_ynydddnl"
                                              -- no beer garden appended (no examples yet)
	          else
	             if ( keyvalues["wheelchair"] == "no" ) then
                        keyvalues["amenity"] = "pub_ynydddnn"
                                              -- no beer garden appended (no examples yet)
		     else
                        keyvalues["amenity"] = "pub_ynydddnd"
                        append_beer_garden(keyvalues)
	             end
	          end
	       end
	    end  -- accommodation
         end
      else
         if ( keyvalues["noncarpeted"] == "yes"  ) then
            if (( keyvalues["accommodation"] ~= nil  ) and
                ( keyvalues["accommodation"] ~= "no" )) then
               keyvalues["amenity"] = "pub_yndyddy"
               append_wheelchair(keyvalues)
                                              -- no beer garden appended (no examples yet)
	    else
               keyvalues["amenity"] = "pub_yndyddn"
               append_wheelchair(keyvalues)
               append_beer_garden(keyvalues)
	    end
         else
            if (( keyvalues["accommodation"] ~= nil  ) and
                ( keyvalues["accommodation"] ~= "no" )) then
               keyvalues["amenity"] = "pub_ynddddy"
                                              -- no wheelchair appended (no examples yet)
                                              -- no beer garden appended (no examples yet)
	    else
               keyvalues["amenity"] = "pub_ynddddn"
               append_wheelchair(keyvalues)
               append_beer_garden(keyvalues)
	    end
         end
      end
   end

-- ----------------------------------------------------------------------------
-- The many and varied taggings for former pubs should have been turned into
-- disused:amenity=pub above, unless some other tag applies.
-- ----------------------------------------------------------------------------
   if ( keyvalues["disused:amenity"] == "pub" ) then
      keyvalues["amenity"] = "pub_nddddddd"
                                                 -- no other attributes checked
   end

-- ----------------------------------------------------------------------------
-- The catch-all here is still "pub" (leaving the tag unchanged)
-- ----------------------------------------------------------------------------
   if ( keyvalues["amenity"] == "pub" ) then
      if (( keyvalues["food"] ~= nil  ) and
          ( keyvalues["food"] ~= "no" )) then
         if ( keyvalues["noncarpeted"] == "yes"  ) then
            if ( keyvalues["microbrewery"] == "yes"  ) then
               keyvalues["amenity"] = "pub_ydyyydd"
                                              -- no wheelchair appended (no examples yet)
                                              -- no beer garden appended (no examples yet)
	    else
               keyvalues["amenity"] = "pub_ydyyndd"
               append_wheelchair(keyvalues)
               append_beer_garden(keyvalues)
	    end
         else
            if ( keyvalues["microbrewery"] == "yes"  ) then
               if ( keyvalues["wheelchair"] == "yes" ) then
                  keyvalues["amenity"] = "pub_ydydyddy"
                                              -- no beer garden appended (no examples yet)
       	       else
                  if ( keyvalues["wheelchair"] == "limited" ) then
                     keyvalues["amenity"] = "pub_ydydyddl"
                                              -- no beer garden appended (no examples yet)
                  else
                     if ( keyvalues["wheelchair"] == "no" ) then
                        keyvalues["amenity"] = "pub_ydydyddn"
                                              -- no beer garden appended (no examples yet)
                     else
                        keyvalues["amenity"] = "pub_ydydyddd"
                        append_beer_garden(keyvalues)
                     end
                  end
               end
	    else
	       if ( keyvalues["pub"] == "micropub" ) then
                  if ( keyvalues["wheelchair"] == "yes" ) then
                     keyvalues["amenity"] = "pub_ydydnydy"
                                              -- no beer garden appended (no examples yet)
           	  else
                     if ( keyvalues["wheelchair"] == "limited" ) then
                        keyvalues["amenity"] = "pub_ydydnydl"
                                              -- no beer garden appended (no examples yet)
                     else
                        if ( keyvalues["wheelchair"] == "no" ) then
                           keyvalues["amenity"] = "pub_ydydnydn"
                                              -- no beer garden appended (no examples yet)
	                else
                           keyvalues["amenity"] = "pub_ydydnydd"
                           append_beer_garden(keyvalues)
                        end
                     end
	          end
	       else
                  keyvalues["amenity"] = "pub_ydydnn"
                  append_accommodation(keyvalues)
                  append_wheelchair(keyvalues)
                  append_beer_garden(keyvalues)
	       end
	    end
         end
      else -- food don't know
         if ( keyvalues["noncarpeted"] == "yes"  ) then
            if ( keyvalues["microbrewery"] == "yes"  ) then
                                              -- micropub unchecked (no examples yet)
               if (( keyvalues["accommodation"] ~= nil  ) and
                   ( keyvalues["accommodation"] ~= "no" )) then
                  keyvalues["amenity"] = "pub_yddyydy"
                                              -- no wheelchair appended (no examples yet)
                                              -- no beer garden appended (no examples yet)
	       else
                  keyvalues["amenity"] = "pub_yddyydn"
                  append_beer_garden(keyvalues)
	       end
	    else
	       if ( keyvalues["pub"] == "micropub" ) then
                  keyvalues["amenity"] = "pub_yddynyd"
                                              -- no wheelchair appended (no examples yet)
                                              -- no beer garden appended (no examples yet)
	       else
                  keyvalues["amenity"] = "pub_yddynnd"
                  append_wheelchair(keyvalues)
                  append_beer_garden(keyvalues)
	       end
	    end
	 else
            if ( keyvalues["microbrewery"] == "yes"  ) then
               if (( keyvalues["accommodation"] ~= nil  ) and
                   ( keyvalues["accommodation"] ~= "no" )) then
                  keyvalues["amenity"] = "pub_ydddydy"
                                              -- no wheelchair appended (no examples yet)
                                              -- no beer garden appended (no examples yet)
               else
                  keyvalues["amenity"] = "pub_ydddydn"
                  append_wheelchair(keyvalues)
                  append_beer_garden(keyvalues)
               end
            else
	       if ( keyvalues["pub"] == "micropub" ) then
                  keyvalues["amenity"] = "pub_ydddnyd"
                  append_wheelchair(keyvalues)
                                            -- no beer garden appended (no examples yet)
               else
                  keyvalues["amenity"] = "pub_ydddnn"
                  append_accommodation(keyvalues)
                  append_wheelchair(keyvalues)
                  append_beer_garden(keyvalues)
               end
	    end
         end
      end
   end


-- ----------------------------------------------------------------------------
-- Restaurants with accommodation
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"]       == "restaurant" )  and
       ( keyvalues["accommodation"] == "yes"        )) then
      keyvalues["amenity"] = "restaccomm"
   end

-- ----------------------------------------------------------------------------
-- "cafe" - consolidation of lesser used tags
-- ----------------------------------------------------------------------------
   if ( keyvalues["shop"] == "cafe"       ) then
      keyvalues["amenity"] = "cafe"
   end

   if (( keyvalues["shop"] == "sandwiches" ) or
       ( keyvalues["shop"] == "sandwich"   )) then
      keyvalues["amenity"] = "cafe"
      keyvalues["cuisine"] = "sandwich"
   end

-- ----------------------------------------------------------------------------
-- Cafes with accommodation, without, and with wheelchair tags or without
-- ----------------------------------------------------------------------------
   if ( keyvalues["amenity"] == "cafe" ) then
      if ( keyvalues["accommodation"] == "yes" ) then
         if ( keyvalues["wheelchair"] == "yes" ) then
            if ( keyvalues["outdoor_seating"] == "yes" ) then
               keyvalues["amenity"] = "cafe_yyy"
            else
               keyvalues["amenity"] = "cafe_yyd"
            end
         else
            if ( keyvalues["wheelchair"] == "limited" ) then
               if ( keyvalues["outdoor_seating"] == "yes" ) then
                  keyvalues["amenity"] = "cafe_yly"
               else
                  keyvalues["amenity"] = "cafe_yld"
               end
	    else
	       if ( keyvalues["wheelchair"] == "no" ) then
                  if ( keyvalues["outdoor_seating"] == "yes" ) then
                     keyvalues["amenity"] = "cafe_yny"
                  else
                     keyvalues["amenity"] = "cafe_ynd"
                  end
	       else
                  if ( keyvalues["outdoor_seating"] == "yes" ) then
                     keyvalues["amenity"] = "cafe_ydy"
                  else
                     keyvalues["amenity"] = "cafe_ydd"
                  end
	       end
	    end
         end
      else
         if ( keyvalues["wheelchair"] == "yes" ) then
            if ( keyvalues["outdoor_seating"] == "yes" ) then
               keyvalues["amenity"] = "cafe_dyy"
            else
               keyvalues["amenity"] = "cafe_dyd"
            end
         else
            if ( keyvalues["wheelchair"] == "limited" ) then
               if ( keyvalues["outdoor_seating"] == "yes" ) then
                  keyvalues["amenity"] = "cafe_dly"
               else
                  keyvalues["amenity"] = "cafe_dld"
               end
	    else
	       if ( keyvalues["wheelchair"] == "no" ) then
                  if ( keyvalues["outdoor_seating"] == "yes" ) then
                     keyvalues["amenity"] = "cafe_dny"
                  else
                     keyvalues["amenity"] = "cafe_dnd"
                  end
               else
                  if ( keyvalues["outdoor_seating"] == "yes" ) then
                     keyvalues["amenity"] = "cafe_ddy"
                  else
                     keyvalues["amenity"] = "cafe_ddd"
                  end
	       end
	    end
         end
      end
   end

-- ----------------------------------------------------------------------------
-- Bars with accommodation, without, and with wheelchair tags or without
-- ----------------------------------------------------------------------------
   if ( keyvalues["amenity"] == "bar" ) then
      if ( keyvalues["accommodation"] == "yes" ) then
         if ( keyvalues["wheelchair"] == "yes" ) then
            if ( keyvalues["outdoor_seating"] == "yes" ) then
               keyvalues["amenity"] = "bar_yyy"
            else
               keyvalues["amenity"] = "bar_yyd"
            end
         else
            if ( keyvalues["wheelchair"] == "limited" ) then
               if ( keyvalues["outdoor_seating"] == "yes" ) then
                  keyvalues["amenity"] = "bar_yly"
               else
                  keyvalues["amenity"] = "bar_yld"
               end
	    else
	       if ( keyvalues["wheelchair"] == "no" ) then
                  if ( keyvalues["outdoor_seating"] == "yes" ) then
                     keyvalues["amenity"] = "bar_yny"
                  else
                     keyvalues["amenity"] = "bar_ynd"
                  end
	       else
                  if ( keyvalues["outdoor_seating"] == "yes" ) then
                     keyvalues["amenity"] = "bar_ydy"
                  else
                     keyvalues["amenity"] = "bar_ydd"
                  end
	       end
	    end
         end
      else
         if ( keyvalues["wheelchair"] == "yes" ) then
            if ( keyvalues["outdoor_seating"] == "yes" ) then
               keyvalues["amenity"] = "bar_dyy"
            else
               keyvalues["amenity"] = "bar_dyd"
            end
         else
            if ( keyvalues["wheelchair"] == "limited" ) then
               if ( keyvalues["outdoor_seating"] == "yes" ) then
                  keyvalues["amenity"] = "bar_dly"
               else
                  keyvalues["amenity"] = "bar_dld"
               end
	    else
	       if ( keyvalues["wheelchair"] == "no" ) then
                  if ( keyvalues["outdoor_seating"] == "yes" ) then
                     keyvalues["amenity"] = "bar_dny"
                  else
                     keyvalues["amenity"] = "bar_dnd"
                  end
               else
                  if ( keyvalues["outdoor_seating"] == "yes" ) then
                     keyvalues["amenity"] = "bar_ddy"
                  else
                     keyvalues["amenity"] = "bar_ddd"
                  end
	       end
	    end
         end
      end
   end

-- ----------------------------------------------------------------------------
-- Render building societies as banks.  Also shop=bank and credit unions.
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "building_society" ) or
       ( keyvalues["shop"]    == "bank"             ) or
       ( keyvalues["amenity"] == "credit_union"     )) then
      keyvalues["amenity"] = "bank"
   end

-- ----------------------------------------------------------------------------
-- Banks with wheelchair tags or without
-- ----------------------------------------------------------------------------
   if ( keyvalues["amenity"] == "bank" ) then
      if ( keyvalues["wheelchair"] == "yes" ) then
         keyvalues["amenity"] = "bank_y"
      else
         if ( keyvalues["wheelchair"] == "limited" ) then
            keyvalues["amenity"] = "bank_l"
         else
            if ( keyvalues["wheelchair"] == "no" ) then
               keyvalues["amenity"] = "bank_n"
            end
          end
      end
   end

-- ----------------------------------------------------------------------------
-- Various mistagging, comma and semicolon healthcare
-- Note that health centres currently appear as "health nonspecific".
-- ----------------------------------------------------------------------------
   if ((   keyvalues["amenity"]    == "doctors; pharmacy"       ) or
       (   keyvalues["amenity"]    == "surgery"                 ) or
       ((( keyvalues["healthcare"] == "doctor"                )   or
         ( keyvalues["healthcare"] == "doctor;pharmacy"       )   or
         ( keyvalues["healthcare"] == "general_practitioner"  ))  and
        (  keyvalues["amenity"]    == nil                      ))) then
      keyvalues["amenity"] = "doctors"
   end

   if (((   keyvalues["healthcare"]            == "dentist"    )  or
        ((  keyvalues["healthcare:speciality"] == "dentistry" )   and
         (( keyvalues["healthcare"]            == "yes"      )    or
          ( keyvalues["healthcare"]            == "centre"   )    or
          ( keyvalues["healthcare"]            == "clinic"   )))) and
       (   keyvalues["amenity"]    == nil                       )) then
      keyvalues["amenity"] = "dentist"
      keyvalues["healthcare"] = nil
   end

   if (( keyvalues["healthcare"] == "hospital" ) and
       ( keyvalues["amenity"]    == nil        )) then
      keyvalues["amenity"] = "hospital"
   end

-- ----------------------------------------------------------------------------
-- Ensure that vaccination centries (e.g. for COVID 19) that aren't already
-- something else get shown as something.
-- Things that _are_ something else get (e.g. community centres) get left as
-- that something else.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["healthcare"]            == "vaccination_centre" )  or
        ( keyvalues["healthcare"]            == "sample_collection"  )  or
        ( keyvalues["healthcare:speciality"] == "vaccination"        )) and
       (  keyvalues["amenity"]               == nil                   ) and
       (  keyvalues["leisure"]               == nil                   ) and
       (  keyvalues["shop"]                  == nil                   )) then
      keyvalues["amenity"] = "clinic"
   end

-- ----------------------------------------------------------------------------
-- If something is mapped both as a supermarket and a pharmacy, suppress the
-- tags for the latter.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "supermarket" ) and
       ( keyvalues["amenity"] == "pharmacy"    )) then
      keyvalues["amenity"] = nil
   end

   if ((( keyvalues["healthcare"] == "pharmacy"                   )  and
        ( keyvalues["amenity"]    == nil                          )) or
       (( keyvalues["shop"]       == "cosmetics"                  )  and
        ( keyvalues["pharmacy"]   == "yes"                        )  and
        ( keyvalues["amenity"]    == nil                          )) or
       (( keyvalues["shop"]       == "chemist"                    )  and
        ( keyvalues["pharmacy"]   == "yes"                        )  and
        ( keyvalues["amenity"]    == nil                          )) or
       (( keyvalues["amenity"]    == "clinic"                     )  and
        ( keyvalues["pharmacy"]   == "yes"                        ))) then
      keyvalues["amenity"] = "pharmacy"
   end

-- ----------------------------------------------------------------------------
-- Pharmacies with wheelchair tags or without
-- ----------------------------------------------------------------------------
   if ( keyvalues["amenity"] == "pharmacy" ) then
      if ( keyvalues["wheelchair"] == "yes" ) then
         keyvalues["amenity"] = "pharmacy_y"
      else
         if ( keyvalues["wheelchair"] == "limited" ) then
            keyvalues["amenity"] = "pharmacy_l"
         else
            if ( keyvalues["wheelchair"] == "no" ) then
               keyvalues["amenity"] = "pharmacy_n"
            end
          end
      end
   end

-- ----------------------------------------------------------------------------
-- Left luggage
-- ----------------------------------------------------------------------------
   if ( keyvalues["amenity"] == "luggage_locker"  ) then
      keyvalues["amenity"] = "left_luggage"
      keyvalues["shop"]    = nil
   end

-- ----------------------------------------------------------------------------
-- Parcel lockers
-- ----------------------------------------------------------------------------
   if (((  keyvalues["amenity"]         == "vending_machine"                )  and
        (( keyvalues["vending"]         == "parcel_pickup;parcel_mail_in"  )   or
         ( keyvalues["vending"]         == "parcel_mail_in;parcel_pickup"  )   or
         ( keyvalues["vending"]         == "parcel_mail_in"                )   or
         ( keyvalues["vending"]         == "parcel_pickup"                 )   or
         ( keyvalues["vending_machine"] == "parcel_pickup"                 )))  or
       (   keyvalues["amenity"]         == "parcel_box"                      )  or
       (   keyvalues["amenity"]         == "parcel_pickup"                   )) then
      keyvalues["amenity"]  = "parcel_locker"
   end

-- ----------------------------------------------------------------------------
-- Excrement bags
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "vending_machine" ) and
       ( keyvalues["vending"] == "excrement_bags"  )) then
      keyvalues["amenity"]  = "vending_excrement"
   end

-- ----------------------------------------------------------------------------
-- Reverse vending machines
-- Other vending machines have their own icon
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "vending_machine" ) and
       ( keyvalues["vending"] == "bottle_return"   )) then
      keyvalues["amenity"]  = "bottle_return"
   end

-- ----------------------------------------------------------------------------
-- If a farm shop doesn't have a name but does have named produce, map across
-- to vending machine, and also the produce into "vending" for consideration 
-- below.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["shop"]                == "farm"  ) and
       (  keyvalues["name"]                == nil     ) and
       (( keyvalues["produce"]             ~= nil    )  or
        ( keyvalues["payment:honesty_box"] == "yes"  ))) then
      keyvalues["amenity"] = "vending_machine"

      if ( keyvalues["produce"] == nil )  then
         if ( keyvalues["food:eggs"] == "yes" )  then
            keyvalues["produce"] = "eggs"
         else
            keyvalues["produce"] = "farm shop honesty box"
         end
      end

      keyvalues["vending"] = keyvalues["produce"]
      keyvalues["shop"]    = nil
   end

   if ((  keyvalues["shop"] == "eggs"  ) and
       (  keyvalues["name"] == nil     )) then
      keyvalues["amenity"] = "vending_machine"
      keyvalues["vending"] = keyvalues["shop"]
      keyvalues["shop"]    = nil
   end

-- ----------------------------------------------------------------------------
-- Some vending machines get the thing sold as the label.
-- "farm shop honesty box" might have been assigned higher up.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["amenity"] == "vending_machine"        ) and
       (  keyvalues["name"]    == nil                      ) and
       (( keyvalues["vending"] == "milk"                  )  or
        ( keyvalues["vending"] == "eggs"                  )  or
        ( keyvalues["vending"] == "potatoes"              )  or
        ( keyvalues["vending"] == "honey"                 )  or
        ( keyvalues["vending"] == "cheese"                )  or
        ( keyvalues["vending"] == "vegetables"            )  or
        ( keyvalues["vending"] == "fruit"                 )  or
        ( keyvalues["vending"] == "food"                  )  or
        ( keyvalues["vending"] == "photos"                )  or
        ( keyvalues["vending"] == "maps"                  )  or
        ( keyvalues["vending"] == "newspapers"            )  or
        ( keyvalues["vending"] == "farm shop honesty box" ))) then
      keyvalues["name"] = "(" .. keyvalues["vending"] .. ")"
   end

-- ----------------------------------------------------------------------------
-- Render amenity=piano as musical_instrument
-- ----------------------------------------------------------------------------
   if ( keyvalues["amenity"] == "piano" ) then
      keyvalues["amenity"] = "musical_instrument"

      if ( keyvalues["name"] == nil ) then
            keyvalues["name"] = "Piano"
      end
   end

-- ----------------------------------------------------------------------------
-- Motorcycle parking - if "motorcycle" has been used as a subtag,
-- set main tag.  Rendering (with fee or not) is handled below.
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "parking"    )  and
       ( keyvalues["parking"] == "motorcycle" )) then
      keyvalues["amenity"] = "motorcycle_parking"
   end

-- ----------------------------------------------------------------------------
-- Render amenity=layby as parking.
-- highway=rest_area is used a lot in the UK for laybies, so map that over too.
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "layby"     ) or
       ( keyvalues["highway"] == "rest_area" )) then
      keyvalues["amenity"] = "parking"
   end

-- ----------------------------------------------------------------------------
-- Lose any "access=permissive" on parking; it should not be greyed out as it
-- is "somewhere we can park".
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "parking"    ) and
       ( keyvalues["access"]  == "permissive" )) then
      keyvalues["access"] = nil
   end

-- ----------------------------------------------------------------------------
-- Scooter rental
-- All legal scooter rental / scooter parking in UK are private; these are the
-- the tags currently used.
-- "network" is a bit of a special case because normally it means "lwn" etc.
-- ----------------------------------------------------------------------------
   if ((   keyvalues["amenity"]                == "escooter_rental"         ) or
       (   keyvalues["amenity"]                == "scooter_parking"         ) or
       (   keyvalues["amenity"]                == "kick-scooter_rental"     ) or
       (   keyvalues["amenity"]                == "small_electric_vehicle"  ) or
       ((  keyvalues["amenity"]                == "parking"                )  and
        (( keyvalues["parking"]                == "e-scooter"             )   or
         ( keyvalues["small_electric_vehicle"] == "designated"            ))) or
       ((  keyvalues["amenity"]                == "bicycle_parking"        )  and
        (  keyvalues["small_electric_vehicle"] == "designated"             ))) then
      keyvalues["amenity"] = "scooter_rental"
      keyvalues["access"] = nil

      if (( keyvalues["name"]     == nil  ) and
          ( keyvalues["operator"] == nil  ) and
          ( keyvalues["network"]  ~= nil  )) then
         keyvalues["name"] = keyvalues["network"]
         keyvalues["network"] = nil
      end
   end

-- ----------------------------------------------------------------------------
-- Render for-pay parking areas differently.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["amenity"] == "parking"  ) and
       (( keyvalues["fee"]     ~= nil       )  and
        ( keyvalues["fee"]     ~= "no"      )  and
        ( keyvalues["fee"]     ~= "0"       ))) then
      keyvalues["amenity"] = "parking_pay"
   end

-- ----------------------------------------------------------------------------
-- Render for-pay bicycle_parking areas differently.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["amenity"] == "bicycle_parking"  ) and
       (( keyvalues["fee"]     ~= nil               )  and
        ( keyvalues["fee"]     ~= "no"              )  and
        ( keyvalues["fee"]     ~= "0"               ))) then
      keyvalues["amenity"] = "bicycle_parking_pay"
   end

-- ----------------------------------------------------------------------------
-- Render for-pay motorcycle_parking areas differently.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["amenity"] == "motorcycle_parking"  ) and
       (( keyvalues["fee"]     ~= nil               )  and
        ( keyvalues["fee"]     ~= "no"              )  and
        ( keyvalues["fee"]     ~= "0"               ))) then
      keyvalues["amenity"] = "motorcycle_parking_pay"
   end

-- ----------------------------------------------------------------------------
-- Render for-pay toilets differently.
-- Also use different icons for male and female, if these are separate.
-- ----------------------------------------------------------------------------
   if ( keyvalues["amenity"] == "toilets" ) then
      if (( keyvalues["fee"]     ~= nil       )  and
          ( keyvalues["fee"]     ~= "no"      )  and
          ( keyvalues["fee"]     ~= "0"       )) then
         if (( keyvalues["male"]   == "yes" ) and
             ( keyvalues["female"] ~= "yes" )) then
            keyvalues["amenity"] = "toilets_pay_m"
         else
            if (( keyvalues["female"] == "yes"       ) and
                ( keyvalues["male"]   ~= "yes"       )) then
               keyvalues["amenity"] = "toilets_pay_w"
            else
               keyvalues["amenity"] = "toilets_pay"
            end
         end
      else
         if (( keyvalues["male"]   == "yes" ) and
             ( keyvalues["female"] ~= "yes" )) then
            keyvalues["amenity"] = "toilets_free_m"
         else
            if (( keyvalues["female"] == "yes"       ) and
                ( keyvalues["male"]   ~= "yes"       )) then
               keyvalues["amenity"] = "toilets_free_w"
            end
         end
      end
   end

-- ----------------------------------------------------------------------------
-- Render for-pay shower differently.
-- Also use different icons for male and female, if these are separate.
-- ----------------------------------------------------------------------------
   if ( keyvalues["amenity"] == "shower" ) then
      if (( keyvalues["fee"]     ~= nil       )  and
          ( keyvalues["fee"]     ~= "no"      )  and
          ( keyvalues["fee"]     ~= "0"       )) then
         if (( keyvalues["male"]   == "yes" ) and
             ( keyvalues["female"] ~= "yes" )) then
            keyvalues["amenity"] = "shower_pay_m"
         else
            if (( keyvalues["female"] == "yes"       ) and
                ( keyvalues["male"]   ~= "yes"       )) then
               keyvalues["amenity"] = "shower_pay_w"
            else
               keyvalues["amenity"] = "shower_pay"
            end
         end
      else
         if (( keyvalues["male"]   == "yes" ) and
             ( keyvalues["female"] ~= "yes" )) then
            keyvalues["amenity"] = "shower_free_m"
         else
            if (( keyvalues["female"] == "yes"       ) and
                ( keyvalues["male"]   ~= "yes"       )) then
               keyvalues["amenity"] = "shower_free_w"
            end
         end
      end
   end

-- ----------------------------------------------------------------------------
-- Render parking spaces as parking.  Most in the UK are not part of larger
-- parking areas, and most do not have an access tag, but many should have.
--
-- This does not work where e.g. Supermarket car parks have been mapped:
-- https://github.com/SomeoneElseOSM/SomeoneElse-style/issues/14
--
-- Also map emergency bays (used in place of hard shoulders) in the same way.
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "parking_space" ) or
       ( keyvalues["highway"] == "emergency_bay" )) then
       if (( keyvalues["fee"]     ~= nil       )  and
           ( keyvalues["fee"]     ~= "no"      )  and
           ( keyvalues["fee"]     ~= "0"       )) then
         if ( keyvalues["parking_space"] == "disabled" ) then
            keyvalues["amenity"] = "parking_paydisabled"
         else
            keyvalues["amenity"] = "parking_pay"
         end
      else
         if ( keyvalues["parking_space"] == "disabled" ) then
            keyvalues["amenity"] = "parking_freedisabled"
         else
            keyvalues["amenity"] = "parking"
         end
      end

      if ( keyvalues["access"] == nil  ) then
         keyvalues["access"] = "no"
      end
   end

-- ----------------------------------------------------------------------------
-- Render amenity=leisure_centre and leisure=leisure_centre 
-- as leisure=sports_centre
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "leisure_centre" ) or
       ( keyvalues["leisure"] == "leisure_centre" )) then
      keyvalues["leisure"] = "sports_centre"
   end

-- ----------------------------------------------------------------------------
-- Sand dunes
-- ----------------------------------------------------------------------------
   if (( keyvalues["natural"] == "dune"       ) or
       ( keyvalues["natural"] == "dunes"      ) or
       ( keyvalues["natural"] == "sand_dunes" )) then
      keyvalues["natural"] = "sand"
   end

-- ----------------------------------------------------------------------------
-- Render tidal sand with more blue
-- ----------------------------------------------------------------------------
   if ((  keyvalues["natural"]   == "sand"       ) and
       (( keyvalues["tidal"]     == "yes"       )  or
        ( keyvalues["wetland"]   == "tidalflat" ))) then
      keyvalues["natural"] = "tidal_sand"
   end

-- ----------------------------------------------------------------------------
-- Golf (and sandpits)
-- ----------------------------------------------------------------------------
   if ((( keyvalues["golf"]       == "bunker"  )  or
        ( keyvalues["playground"] == "sandpit" )) and
       ( keyvalues["natural"]     == nil        )) then
      keyvalues["natural"] = "sand"
   end

   if ( keyvalues["golf"] == "tee" ) then
      keyvalues["leisure"] = "garden"

      if ( keyvalues["name"] == nil ) then
         keyvalues["name"] = keyvalues["ref"]
      end
   end

   if ( keyvalues["golf"] == "green" ) then
      keyvalues["leisure"] = "golfgreen"

      if ( keyvalues["name"] == nil ) then
         keyvalues["name"] = keyvalues["ref"]
      end
   end

   if ( keyvalues["golf"] == "fairway" ) then
      keyvalues["leisure"] = "garden"

      if ( keyvalues["name"] == nil ) then
         keyvalues["name"] = keyvalues["ref"]
      end
   end

   if ( keyvalues["golf"] == "pin" ) then
      keyvalues["leisure"] = "leisurenonspecific"

      if ( keyvalues["name"] == nil ) then
         keyvalues["name"] = keyvalues["ref"]
      end
   end

   if (( keyvalues["golf"]    == "rough" ) and
       ( keyvalues["natural"] == nil     )) then
      keyvalues["natural"] = "scrub"
   end

   if (( keyvalues["golf"]    == "driving_range" ) and
       ( keyvalues["leisure"] == nil             )) then
      keyvalues["leisure"] = "pitch"
   end

   if (( keyvalues["golf"]    == "path" ) and
       ( keyvalues["highway"] == nil    )) then
      keyvalues["highway"] = "pathnarrow"
   end

   if (( keyvalues["golf"]    == "practice" ) and
       ( keyvalues["leisure"] == nil        )) then
      keyvalues["leisure"] = "garden"
   end

-- ----------------------------------------------------------------------------
-- Playground stuff
--
-- The "leisure=nil" check here is because there are some unusual combinations
-- of "playground" tags on otherwise-rendered "leisure" things.
--
-- "landuse=playground" is a rare synonym of "leisure=playground".
-- "leisure=playground".is handled in the rendering code.
-- ----------------------------------------------------------------------------
   if (( keyvalues["landuse"] == "playground" ) and
       ( keyvalues["leisure"] == nil          )) then
      keyvalues["leisure"] = "playground"
   end

   if ((  keyvalues["leisure"]    == nil            )  and
       (( keyvalues["playground"] == "swing"       )   or
        ( keyvalues["playground"] == "basketswing" ))) then
      keyvalues["amenity"] = "playground_swing"
   end

   if (( keyvalues["leisure"]    == nil         )  and
       ( keyvalues["playground"] == "structure" )) then
      keyvalues["amenity"] = "playground_structure"
   end

   if (( keyvalues["leisure"]    == nil             )  and
       ( keyvalues["playground"] == "climbingframe" )) then
      keyvalues["amenity"] = "playground_climbingframe"
   end

   if (( keyvalues["leisure"]    == nil     )  and
       ( keyvalues["playground"] == "slide" )) then
      keyvalues["amenity"] = "playground_slide"
   end

   if (( keyvalues["leisure"]    == nil       )  and
       ( keyvalues["playground"] == "springy" )) then
      keyvalues["amenity"] = "playground_springy"
   end

   if (( keyvalues["leisure"]    == nil       )  and
       ( keyvalues["playground"] == "zipwire" )) then
      keyvalues["amenity"] = "playground_zipwire"
   end

   if (( keyvalues["leisure"]    == nil      )  and
       ( keyvalues["playground"] == "seesaw" )) then
      keyvalues["amenity"] = "playground_seesaw"
   end

   if (( keyvalues["leisure"]    == nil          )  and
       ( keyvalues["playground"] == "roundabout" )) then
      keyvalues["amenity"] = "playground_roundabout"
   end

-- ----------------------------------------------------------------------------
-- Various leisure=pitch icons
-- Note that these are also listed at the end in 
-- "Shops etc. with icons already".
-- ----------------------------------------------------------------------------
   if (( keyvalues["leisure"] == "pitch"        )  and
       ( keyvalues["sport"]   == "table_tennis" )) then
      keyvalues["amenity"] = "pitch_tabletennis"
      keyvalues["leisure"] = "unnamedpitch"
   end

   if ((  keyvalues["leisure"] == "pitch"                      )  and
       (( keyvalues["sport"]   == "association_football"      )   or
        ( keyvalues["sport"]   == "football"                  )   or
        ( keyvalues["sport"]   == "multi;soccer;basketball"   )   or
        ( keyvalues["sport"]   == "football;basketball"       )   or
        ( keyvalues["sport"]   == "football;rugby"            )   or
        ( keyvalues["sport"]   == "football;soccer"           )   or
        ( keyvalues["sport"]   == "soccer"                    )   or
        ( keyvalues["sport"]   == "soccer;archery"            )   or
        ( keyvalues["sport"]   == "soccer;athletics"          )   or
        ( keyvalues["sport"]   == "soccer;basketball"         )   or
        ( keyvalues["sport"]   == "soccer;cricket"            )   or
        ( keyvalues["sport"]   == "soccer;field_hockey"       )   or
        ( keyvalues["sport"]   == "soccer;football"           )   or
        ( keyvalues["sport"]   == "soccer;gaelic_games"       )   or
        ( keyvalues["sport"]   == "soccer;gaelic_games;rugby" )   or
        ( keyvalues["sport"]   == "soccer;hockey"             )   or
        ( keyvalues["sport"]   == "soccer;multi"              )   or
        ( keyvalues["sport"]   == "soccer;rugby"              )   or
        ( keyvalues["sport"]   == "soccer;rugby_union"        )   or
        ( keyvalues["sport"]   == "soccer;tennis"             ))) then
      keyvalues["amenity"] = "pitch_soccer"
      keyvalues["leisure"] = "unnamedpitch"
   end

   if (( keyvalues["leisure"] == "pitch"                    )  and
       (( keyvalues["sport"]  == "basketball"              )   or
        ( keyvalues["sport"]  == "basketball;soccer"       )   or
        ( keyvalues["sport"]  == "basketball;football"     )   or
        ( keyvalues["sport"]  == "basketball;multi"        )   or
        ( keyvalues["sport"]  == "basketball;netball"      )   or
        ( keyvalues["sport"]  == "basketball;tennis"       )   or
        ( keyvalues["sport"]  == "multi;basketball"        )   or
        ( keyvalues["sport"]  == "multi;basketball;soccer" ))) then
      keyvalues["amenity"] = "pitch_basketball"
      keyvalues["leisure"] = "unnamedpitch"
   end

   if ((  keyvalues["leisure"] == "pitch"                )  and
       (( keyvalues["sport"]   == "cricket"             )   or
        ( keyvalues["sport"]   == "cricket_rugby_union" )   or
        ( keyvalues["sport"]   == "cricket;soccer"      )   or
        ( keyvalues["sport"]   == "cricket_nets"        )   or
        ( keyvalues["sport"]   == "cricket_nets;multi"  ))) then
      keyvalues["amenity"] = "pitch_cricket"
      keyvalues["leisure"] = "unnamedpitch"
   end

   if (( keyvalues["leisure"] == "pitch"           )  and
       (( keyvalues["sport"]  == "skateboard"     )   or
        ( keyvalues["sport"]  == "skateboard;bmx" ))) then
      keyvalues["amenity"] = "pitch_skateboard"
      keyvalues["leisure"] = "unnamedpitch"
   end

   if ((  keyvalues["leisure"] == "pitch"                )  and
       (( keyvalues["sport"]   == "climbing"            )   or
        ( keyvalues["sport"]   == "climbing;bouldering" ))) then
      keyvalues["amenity"] = "pitch_climbing"
      keyvalues["leisure"] = "unnamedpitch"
   end

   if ((  keyvalues["leisure"] == "pitch"                )  and
       (( keyvalues["sport"]   == "rugby"               )   or
        ( keyvalues["sport"]   == "rugby;cricket"       )   or
        ( keyvalues["sport"]   == "rugby;football"      )   or
        ( keyvalues["sport"]   == "rugby;rubgy_union"   )   or
        ( keyvalues["sport"]   == "rugby;soccer"        )   or
        ( keyvalues["sport"]   == "rugby_league"        )   or
        ( keyvalues["sport"]   == "rugby_union"         )   or
        ( keyvalues["sport"]   == "rugby_union;cricket" )   or
        ( keyvalues["sport"]   == "rugby_union;soccer"  ))) then
      keyvalues["amenity"] = "pitch_rugby"
      keyvalues["leisure"] = "unnamedpitch"
   end

   if (( keyvalues["leisure"] == "pitch" )  and
       ( keyvalues["sport"]   == "chess" )) then
      keyvalues["amenity"] = "pitch_chess"
      keyvalues["leisure"] = "unnamedpitch"
   end

   if ((  keyvalues["leisure"] == "pitch"              )  and
       (( keyvalues["sport"]   == "tennis"            )   or
        ( keyvalues["sport"]   == "tennis;basketball" )   or
        ( keyvalues["sport"]   == "tennis;bowls"      )   or
        ( keyvalues["sport"]   == "tennis;hockey"     )   or
        ( keyvalues["sport"]   == "tennis;multi"      )   or
        ( keyvalues["sport"]   == "tennis;netball"    )   or
        ( keyvalues["sport"]   == "tennis;soccer"     )   or
        ( keyvalues["sport"]   == "tennis;squash"     ))) then
      keyvalues["amenity"] = "pitch_tennis"
      keyvalues["leisure"] = "unnamedpitch"
   end

   if ((  keyvalues["leisure"] == "pitch"             )  and
       (( keyvalues["sport"]   == "athletics"        )   or
        ( keyvalues["sport"]   == "athletics;soccer" )   or
        ( keyvalues["sport"]   == "long_jump"        )   or
        ( keyvalues["sport"]   == "running"          )   or
        ( keyvalues["sport"]   == "shot-put"         ))) then
      keyvalues["amenity"] = "pitch_athletics"
      keyvalues["leisure"] = "unnamedpitch"
   end

   if (( keyvalues["leisure"] == "pitch" )  and
       ( keyvalues["sport"]   == "boules" )) then
      keyvalues["amenity"] = "pitch_boules"
      keyvalues["leisure"] = "unnamedpitch"
   end

   if ((  keyvalues["leisure"] == "pitch"         )  and
       (( keyvalues["sport"]   == "bowls"        )   or
        ( keyvalues["sport"]   == "bowls;tennis" ))) then
      keyvalues["amenity"] = "pitch_bowls"
      keyvalues["leisure"] = "unnamedpitch"
   end

   if (( keyvalues["leisure"] == "pitch" )  and
       ( keyvalues["sport"]   == "croquet" )) then
      keyvalues["amenity"] = "pitch_croquet"
      keyvalues["leisure"] = "unnamedpitch"
   end

   if ((  keyvalues["leisure"] == "pitch"         )  and
       (( keyvalues["sport"]   == "cycling"      )   or
        ( keyvalues["sport"]   == "bmx"          )   or
        ( keyvalues["sport"]   == "cycling;bmx"  )   or
        ( keyvalues["sport"]   == "bmx;mtb"      )   or
        ( keyvalues["sport"]   == "bmx;cycling"  )   or
        ( keyvalues["sport"]   == "mtb"          ))) then
      keyvalues["amenity"] = "pitch_cycling"
      keyvalues["leisure"] = "unnamedpitch"
   end

   if (( keyvalues["leisure"] == "pitch" )  and
       ( keyvalues["sport"]   == "equestrian" )) then
      keyvalues["amenity"] = "pitch_equestrian"
      keyvalues["leisure"] = "unnamedpitch"
   end

   if ((  keyvalues["leisure"] == "pitch"                  )  and
       (( keyvalues["sport"]   == "gaelic_games"          )   or
        ( keyvalues["sport"]   == "gaelic_games;handball" )   or
        ( keyvalues["sport"]   == "gaelic_games;soccer"   )   or
        ( keyvalues["sport"]   == "shinty"                ))) then
      keyvalues["amenity"] = "pitch_gaa"
      keyvalues["leisure"] = "unnamedpitch"
   end

   if ((  keyvalues["leisure"] == "pitch"                  )  and
       (( keyvalues["sport"]   == "field_hockey"          )   or
        ( keyvalues["sport"]   == "field_hockey;soccer"   )   or
        ( keyvalues["sport"]   == "hockey"                )   or
        ( keyvalues["sport"]   == "hockey;soccer"         ))) then
      keyvalues["amenity"] = "pitch_hockey"
      keyvalues["leisure"] = "unnamedpitch"
   end

   if (( keyvalues["leisure"] == "pitch" )  and
       ( keyvalues["sport"]   == "multi" )) then
      keyvalues["amenity"] = "pitch_multi"
      keyvalues["leisure"] = "unnamedpitch"
   end

   if (( keyvalues["leisure"] == "pitch" )  and
       ( keyvalues["sport"]   == "netball" )) then
      keyvalues["amenity"] = "pitch_netball"
      keyvalues["leisure"] = "unnamedpitch"
   end

   if (( keyvalues["leisure"] == "pitch" )  and
       ( keyvalues["sport"]   == "polo" )) then
      keyvalues["amenity"] = "pitch_polo"
      keyvalues["leisure"] = "unnamedpitch"
   end

   if ((  keyvalues["leisure"] == "pitch"           )  and
       (( keyvalues["sport"]   == "shooting"       ) or
        ( keyvalues["sport"]   == "shooting_range" ))) then
      keyvalues["amenity"] = "pitch_shooting"
      keyvalues["leisure"] = "unnamedpitch"
   end

   if ((  keyvalues["leisure"] == "pitch"                                             )  and
       (( keyvalues["sport"]   == "baseball"                                         ) or
        ( keyvalues["sport"]   == "baseball;soccer"                                  ) or
        ( keyvalues["sport"]   == "baseball;softball"                                ) or
        ( keyvalues["sport"]   == "baseball;cricket"                                 ) or
        ( keyvalues["sport"]   == "multi;baseball"                                   ) or
        ( keyvalues["sport"]   == "baseball;lacrosse;multi"                          ) or
        ( keyvalues["sport"]   == "baseball;american_football;ice_hockey;basketball" ))) then
      keyvalues["amenity"] = "pitch_baseball"
      keyvalues["leisure"] = "unnamedpitch"
   end

-- ----------------------------------------------------------------------------
-- Handle razed railways and old inclined_planes as dismantled.
-- dismantled, abandoned are now handled separately to disused in roads.mss
-- ----------------------------------------------------------------------------
   if ((( keyvalues["railway:historic"] == "rail"           )  or
        ( keyvalues["historic"]         == "inclined_plane" )  or
        ( keyvalues["historic"]         == "tramway"        )) and
       (  keyvalues["building"]         == nil               ) and
       (  keyvalues["highway"]          == nil               ) and
       (  keyvalues["railway"]          == nil               ) and
       (  keyvalues["waterway"]         == nil               )) then
      keyvalues["railway"] = "abandoned"
   end

   if ( keyvalues["railway"] == "razed" ) then
      keyvalues["railway"] = "dismantled"
   end

-- ----------------------------------------------------------------------------
-- Railway construction
-- This is done mostly to make the HS2 show up.
-- ----------------------------------------------------------------------------
   if ( keyvalues["railway"]   == "proposed" ) then
      keyvalues["railway"] = "construction"
   end

-- ----------------------------------------------------------------------------
-- The "OpenRailwayMap" crowd prefer the less popular railway:preserved=yes
-- instead of railway=preserved (which has the advantage of still allowing
-- e.g. narrow_gauge in addition to rail).
-- ----------------------------------------------------------------------------
   if ( keyvalues["railway:preserved"] == "yes" ) then
      keyvalues["railway"] = "preserved"
   end

-- ----------------------------------------------------------------------------
-- Show preserved railway tunnels as tunnels.
-- ----------------------------------------------------------------------------
   if (( keyvalues["railway"] == "preserved" ) and
       ( keyvalues["tunnel"]  == "yes"       )) then
      keyvalues["railway"] = "rail"
   end

   if ((( keyvalues["railway"] == "miniature"    ) or
        ( keyvalues["railway"] == "narrow_gauge" )) and
       (  keyvalues["tunnel"]  == "yes"           )) then
      keyvalues["railway"] = "light_rail"
   end

-- ----------------------------------------------------------------------------
-- Goods Conveyors - render as miniature railway.
-- ----------------------------------------------------------------------------
   if ( keyvalues["man_made"] == "goods_conveyor" ) then
      keyvalues["railway"] = "miniature"
   end

-- ----------------------------------------------------------------------------
-- Slipways - render ways as miniature railway in addition to slipway icon
-- ----------------------------------------------------------------------------
   if ( keyvalues["leisure"] == "slipway" ) then
      keyvalues["railway"] = "miniature"
   end

-- ----------------------------------------------------------------------------
-- Other waterway access points
-- ----------------------------------------------------------------------------
   if (( keyvalues["waterway"]   == "access_point"  ) or
       ( keyvalues["whitewater"] == "put_in"        ) or
       ( keyvalues["whitewater"] == "put_in;egress" ) or
       ( keyvalues["canoe"]      == "put_in"        )) then
      keyvalues["amenity"] = "waterway_access_point"
      keyvalues["leisure"] = nil
      keyvalues["sport"] = nil
   end

-- ----------------------------------------------------------------------------
-- Sluice gates - send through as man_made, also display as building=roof.
-- Also waterfall (the dot or line is generic enough to work there too)
-- The change of waterway to weir ensures line features appear too.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["waterway"]     == "sluice_gate"      ) or
       (  keyvalues["waterway"]     == "sluice"           ) or
       (( keyvalues["waterway"]     == "flow_control"    )  and
        ( keyvalues["flow_control"] == "sluice_gate"     )) or
       (  keyvalues["waterway"]     == "waterfall"        ) or
       (  keyvalues["natural"]      == "waterfall"        ) or
       (  keyvalues["water"]        == "waterfall"        ) or
       (  keyvalues["waterway"]     == "weir"             ) or
       (  keyvalues["waterway"]     == "floating_barrier" )) then
      keyvalues["man_made"] = "sluice_gate"
      keyvalues["building"] = "roof"
      keyvalues["waterway"] = "weir"
   end

-- ----------------------------------------------------------------------------
-- Historic canal
-- A former canal can, like an abandoned railway, still be a major
-- physical feature.
--
-- Also treat historic=moat in the same way, unless it has an area=yes tag.
-- Most closed ways for historic=moat appear to be linear ways, not areas.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["historic"]           == "canal"           ) or
       (  keyvalues["historic:waterway"]  == "canal"           ) or
       (  keyvalues["historic"]           == "leat"            ) or
       (  keyvalues["disused:waterway"]   == "canal"           ) or
       (  keyvalues["disused"]            == "canal"           ) or
       (  keyvalues["abandoned:waterway"] == "canal"           ) or
       (  keyvalues["waterway"]           == "disused_canal"   ) or
       (  keyvalues["waterway"]           == "historic_canal"  ) or
       (  keyvalues["waterway"]           == "abandoned_canal" ) or
       (  keyvalues["waterway"]           == "former_canal"    ) or
       (  keyvalues["waterway:historic"]  == "canal"           ) or
       (  keyvalues["waterway:abandoned"] == "canal"           ) or
       (  keyvalues["abandoned"]          == "waterway=canal"  ) or
       (( keyvalues["historic"]           == "moat"           )  and
        ( keyvalues["natural"]            == nil              )  and
        ( keyvalues["man_made"]           == nil              )  and
        ( keyvalues["waterway"]           == nil              )  and
        ( keyvalues["area"]               ~= "yes"            ))) then
      keyvalues["waterway"] = "derelict_canal"
      keyvalues["historic"] = nil
      keyvalues["area"]     = "no"
   end

-- ----------------------------------------------------------------------------
-- Use historical names if present for historical canals.
-- ----------------------------------------------------------------------------
   if (( keyvalues["waterway"]      == "derelict_canal" ) and
       ( keyvalues["name"]          == nil              ) and
       ( keyvalues["name:historic"] ~= nil              )) then
      keyvalues["name"] = keyvalues["name:historic"]
   end

   if (( keyvalues["waterway"]      == "derelict_canal" ) and
       ( keyvalues["name"]          == nil              ) and
       ( keyvalues["historic:name"] ~= nil              )) then
      keyvalues["name"] = keyvalues["historic:name"]
   end
   
-- ----------------------------------------------------------------------------
-- Display "waterway=leat" and "waterway=spillway" etc. as drain.
-- "man_made=spillway" tends to be used on areas, hence show as "natural=water".
-- ----------------------------------------------------------------------------
   if ((   keyvalues["waterway"] == "leat"        )  or
       (   keyvalues["waterway"] == "spillway"    )  or
       (   keyvalues["waterway"] == "fish_pass"   )  or
       (   keyvalues["waterway"] == "rapids"      )  or
       ((  keyvalues["waterway"] == "canal"      )   and
        (( keyvalues["usage"]    == "headrace"  )    or
         ( keyvalues["usage"]    == "spillway"  )))) then
      keyvalues["waterway"] = "drain"
   end

   if ( keyvalues["man_made"] == "spillway" ) then
      keyvalues["natural"] = "water"
      keyvalues["man_made"] = nil
   end

-- ----------------------------------------------------------------------------
-- Any remaining extant canals will be linear features, even closed loops.
-- ----------------------------------------------------------------------------
   if ( keyvalues["waterway"] == "canal" ) then
      keyvalues["area"]     = "no"
   end

-- ----------------------------------------------------------------------------
-- Apparently there are a few "waterway=brook" in the UK.  Render as stream.
-- Likewise "tidal_channel" as stream and "drainage_channel" as ditch.
-- ----------------------------------------------------------------------------
   if (( keyvalues["waterway"] == "brook"         ) or
       ( keyvalues["waterway"] == "flowline"      ) or
       ( keyvalues["waterway"] == "tidal_channel" )) then
      keyvalues["waterway"] = "stream"
   end

   if ( keyvalues["waterway"] == "drainage_channel" ) then
      keyvalues["waterway"] = "ditch"
   end

-- ----------------------------------------------------------------------------
-- Handle "natural=pond" as water.
-- ----------------------------------------------------------------------------
   if ( keyvalues["natural"] == "pond" ) then
      keyvalues["natural"] = "water"
   end

-- ----------------------------------------------------------------------------
-- Handle "waterway=mill_pond" as water.
-- "dock" is displayed with a water fill.
-- ----------------------------------------------------------------------------
   if ( keyvalues["waterway"] == "mill_pond" ) then
      keyvalues["waterway"] = "dock"
   end

-- ----------------------------------------------------------------------------
-- Display intermittent rivers as "intriver"
-- ----------------------------------------------------------------------------
   if (( keyvalues["waterway"]     == "river"  )  and
       ( keyvalues["intermittent"] == "yes"    )) then
      keyvalues["waterway"] = "intriver"
   end

-- ----------------------------------------------------------------------------
-- Display intermittent stream as "intstream"
-- ----------------------------------------------------------------------------
   if (( keyvalues["waterway"]     == "stream"  )  and
       ( keyvalues["intermittent"] == "yes"     )) then
      keyvalues["waterway"] = "intstream"
   end

-- ----------------------------------------------------------------------------
-- Display "location=underground" waterways as tunnels.
--
-- There are currently no "location=overground" waterways that are not
-- also "man_made=pipeline".
-- ----------------------------------------------------------------------------
   if ((  keyvalues["waterway"] ~= nil            )  and
       (( keyvalues["location"] == "underground" )   or
        ( keyvalues["covered"]  == "yes"         ))  and
       (  keyvalues["tunnel"]   == nil            )) then
      keyvalues["tunnel"] = "yes"
   end

-- ----------------------------------------------------------------------------
-- Display "location=overground" and "location=overhead" pipelines as bridges.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["man_made"] == "pipeline"    ) and
       (( keyvalues["location"] == "overground" )  or
        ( keyvalues["location"] == "overhead"   )) and
       (  keyvalues["bridge"]   == nil           )) then
      keyvalues["bridge"] = "yes"
   end

-- ----------------------------------------------------------------------------
-- Pipelines
-- We display pipelines as waterways, because there is explicit bridge handling
-- for waterways.
-- Also note that some seamarks
-- ----------------------------------------------------------------------------
   if (( keyvalues["man_made"]     == "pipeline"           ) or
       ( keyvalues["seamark:type"] == "pipeline_submarine" )) then
      keyvalues["man_made"]     = nil
      keyvalues["seamark:type"] = nil
      keyvalues["waterway"]     = "pipeline"
   end

-- ----------------------------------------------------------------------------
-- Display gantries as pipeline bridges
-- ----------------------------------------------------------------------------
   if ( keyvalues["man_made"] == "gantry" ) then
      keyvalues["man_made"] = nil
      keyvalues["waterway"] = "pipeline"
      keyvalues["bridge"] = "yes"
   end

-- ----------------------------------------------------------------------------
-- Display military bunkers
-- Historic bunkers have been dealt with higher up.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["military"] == "bunker"  ) or
       (( keyvalues["building"] == "bunker" )  and
        ( keyvalues["disused"]  == nil      )  and
        ( keyvalues["historic"] == nil      ))) then
      keyvalues["man_made"] = "militarybunker"
      keyvalues["military"] = nil

      if ( keyvalues["building"] == nil ) then
         keyvalues["building"] = "yes"
      end
   end

-- ----------------------------------------------------------------------------
-- Supermarkets as normal buildings
-- In the version of OSM-carto that I use this with, Supermarkets would 
-- otherwise display as pink, which does not show up over pink retail landuse.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["building"]   == "supermarket"      ) or
       (  keyvalues["man_made"]   == "storage_tank"     ) or
       (  keyvalues["man_made"]   == "silo"             ) or
       (  keyvalues["man_made"]   == "tank"             ) or
       (  keyvalues["man_made"]   == "water_tank"       ) or
       (  keyvalues["man_made"]   == "kiln"             ) or
       (  keyvalues["man_made"]   == "gasometer"        ) or
       (  keyvalues["man_made"]   == "oil_tank"         ) or
       (  keyvalues["man_made"]   == "greenhouse"       ) or
       (  keyvalues["man_made"]   == "water_treatment"  ) or
       (  keyvalues["man_made"]   == "trickling_filter" ) or
       (  keyvalues["man_made"]   == "filter_bed"       ) or
       (  keyvalues["man_made"]   == "filtration_bed"   ) or
       (  keyvalues["man_made"]   == "waste_treatment"  ) or
       (  keyvalues["man_made"]   == "lighthouse"       ) or
       (  keyvalues["man_made"]   == "street_cabinet"   ) or
       (  keyvalues["man_made"]   == "aeroplane"        ) or
       (  keyvalues["man_made"]   == "helicopter"       )) then
      keyvalues["building"] = "yes"
   end

-- ----------------------------------------------------------------------------
-- Only show telescopes as buildings if they don't already have a landuse set.
-- Some large radio telescopes aren't large buildings.
-- ----------------------------------------------------------------------------
   if (( keyvalues["man_made"] == "telescope" ) and
       ( keyvalues["landuse"]  == nil         )) then
      keyvalues["building"] = "yes"
   end

-- ----------------------------------------------------------------------------
-- building=ruins is rendered as a half-dark building.
-- The wiki tries to guide building=ruins towards follies only but ruins=yes
-- "not a folly but falling down".  That doesn't match what mappers do but 
-- render both as half-dark.
-- ----------------------------------------------------------------------------
   if (((   keyvalues["building"]        ~= nil               )   and
        ((( keyvalues["historic"]        == "ruins"         )     and
          ( keyvalues["ruins"]           == nil             ))    or
         (  keyvalues["ruins"]           == "yes"            )    or
         (  keyvalues["ruins"]           == "barn"           )    or
         (  keyvalues["ruins"]           == "barrack"        )    or
         (  keyvalues["ruins"]           == "blackhouse"     )    or
         (  keyvalues["ruins"]           == "house"          )    or
         (  keyvalues["ruins"]           == "hut"            )    or
         (  keyvalues["ruins"]           == "farm_auxiliary" )    or
         (  keyvalues["ruins"]           == "farmhouse"      )))  or
       (    keyvalues["ruins:building"]  == "yes"              )  or
       (    keyvalues["building:ruins"]  == "yes"              )  or
       (    keyvalues["ruined:building"] == "yes"              )  or
       (    keyvalues["building"]        == "collapsed"        )) then
      keyvalues["building"] = "ruins"
   end
   
-- ----------------------------------------------------------------------------
-- Map man_made=monument to historic=monument (handled below).
-- ----------------------------------------------------------------------------
   if (( keyvalues["man_made"] == "monument" )  and
       ( keyvalues["tourism"]  == nil        )) then
      keyvalues["historic"] = "monument"
      keyvalues["man_made"] = nil
   end

-- ----------------------------------------------------------------------------
-- Map man_made=geoglyph to natural=bare_rock if another natural tag such as 
-- scree is not already set
-- ----------------------------------------------------------------------------
   if ((  keyvalues["man_made"] == "geoglyph"  ) and
       (  keyvalues["leisure"]  == nil         )) then
      if (  keyvalues["natural"]  == nil ) then
         keyvalues["natural"]  = "bare_rock"
      end

      keyvalues["man_made"] = nil
      keyvalues["tourism"]  = nil
   end
   
-- ----------------------------------------------------------------------------
-- Things that are both towers and monuments or memorials 
-- should render as the latter.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["man_made"]  == "tower"     ) and
       (( keyvalues["historic"]  == "memorial" )  or
        ( keyvalues["historic"]  == "monument" ))) then
      keyvalues["man_made"] = nil
   end

   if ((( keyvalues["tourism"] == "gallery"     )   or
        ( keyvalues["tourism"] == "museum"      ))  and
       (  keyvalues["amenity"] == "arts_centre"  )) then
      keyvalues["amenity"] = nil
   end

   if ((( keyvalues["tourism"] == "attraction"  )   or 
        ( keyvalues["tourism"] == "artwork"     )   or
        ( keyvalues["tourism"] == "yes"         ))  and
       (  keyvalues["amenity"] == "arts_centre"  )) then
      keyvalues["tourism"] = nil
   end

-- ----------------------------------------------------------------------------
-- Mineshafts
-- First make sure that we treat historic ones also tagged as man_made 
-- as historic
-- ----------------------------------------------------------------------------
   if (((( keyvalues["disused:man_made"] == "mine"       )  or
         ( keyvalues["disused:man_made"] == "mineshaft"  )  or
         ( keyvalues["disused:man_made"] == "mine_shaft" )) and
        (  keyvalues["man_made"]         == nil           )) or
       ((( keyvalues["man_made"] == "mine"               )  or
         ( keyvalues["man_made"] == "mineshaft"          )  or
         ( keyvalues["man_made"] == "mine_shaft"         )) and
        (( keyvalues["historic"] == "yes"                )  or
         ( keyvalues["historic"] == "mine"               )  or
         ( keyvalues["historic"] == "mineshaft"          )  or
         ( keyvalues["historic"] == "mine_shaft"         )  or
         ( keyvalues["historic"] == "mine_adit"          )  or
         ( keyvalues["historic"] == "mine_level"         )  or
         ( keyvalues["disused"]  == "yes"                )))) then
      keyvalues["historic"] = "mineshaft"
      keyvalues["man_made"] = nil
      keyvalues["disused:man_made"] = nil
      keyvalues["tourism"]  = nil
   end

-- ----------------------------------------------------------------------------
-- Then other spellings of man_made=mineshaft
-- ----------------------------------------------------------------------------
   if (( keyvalues["man_made"]   == "mine"       )  or
       ( keyvalues["industrial"] == "mine"       )  or
       ( keyvalues["man_made"]   == "mine_shaft" )) then
      keyvalues["man_made"] = "mineshaft"
   end

-- ----------------------------------------------------------------------------
-- and the historic equivalents
-- ----------------------------------------------------------------------------
   if (( keyvalues["historic"] == "mine_shaft"        ) or
       ( keyvalues["historic"] == "mine_adit"         ) or
       ( keyvalues["historic"] == "mine_level"        ) or
       ( keyvalues["historic"] == "mine"              )) then
      keyvalues["historic"] = "mineshaft"

      if (( keyvalues["landuse"] == nil ) and
          ( keyvalues["leisure"] == nil ) and
          ( keyvalues["natural"] == nil )) then
         keyvalues["landuse"] = "historic"
      end
   end

-- ----------------------------------------------------------------------------
-- Before we assume that a "historic=fort" is some sort of castle (big walls,
-- moat, that sort of thing) check that it's not prehistoric or some sort of 
-- hill fort (banks and ditches, people running around painted blue).  If it 
-- is, set "historic=archaeological_site" so it gets picked up as one below.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["historic"]              == "fort"          ) and
       (( keyvalues["fortification_type"]    == "hill_fort"    )  or
        ( keyvalues["fortification_type"]    == "hillfort"     ))) then
      keyvalues["historic"]            = "archaeological_site"
      keyvalues["archaeological_site"] = "fortification"
      keyvalues["fortification_type"]  = "hill_fort"
   end

-- ----------------------------------------------------------------------------
-- Similarly, catch "historic" "ringfort"s
-- ----------------------------------------------------------------------------
   if ((( keyvalues["historic"]           == "fortification" )   and
        ( keyvalues["fortification_type"] == "ringfort"      ))  or
       (  keyvalues["historic"]           == "rath"           )) then
      keyvalues["historic"]            = "archaeological_site"
      keyvalues["archaeological_site"] = "fortification"
      keyvalues["fortification_type"]  = "ringfort"
   end

-- ----------------------------------------------------------------------------
-- Catch other archaeological fortifications.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["historic"]              == "fort"           ) and
       (( keyvalues["fortification_type"]    == "broch"         )  or
        ( keyvalues["historic:civilization"] == "prehistoric"   )  or
        ( keyvalues["historic:civilization"] == "iron_age"      )  or
        ( keyvalues["historic:civilization"] == "ancient_roman" ))) then
      keyvalues["historic"]            = "archaeological_site"
      keyvalues["archaeological_site"] = "fortification"
   end

-- ----------------------------------------------------------------------------
-- First, remove non-castle castles that have been tagfiddled into the data.
-- Castles go through as "historic=castle"
-- Note that archaeological sites that are castles are handled elsewhere.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["historic"]    == "castle"       ) and
       (( keyvalues["castle_type"] == "stately"     )  or
        ( keyvalues["castle_type"] == "manor"       )  or
        ( keyvalues["castle_type"] == "palace"      )  or
        ( keyvalues["castle_type"] == "manor_house" ))) then
      keyvalues["historic"] = "manor"
   end

   if (( keyvalues["historic"] == "castle" ) or
       ( keyvalues["historic"] == "fort"   )) then
      keyvalues["historic"] = "castle"

      if (( keyvalues["landuse"] == nil ) and
          ( keyvalues["leisure"] == nil ) and
          ( keyvalues["natural"] == nil )) then
         keyvalues["landuse"] = "historic"
      end
   end

-- ----------------------------------------------------------------------------
-- Manors go through as "historic=manor"
-- Note that archaeological sites that are manors are handled elsewhere.
-- ----------------------------------------------------------------------------
   if (( keyvalues["historic"] == "manor"           ) or
       ( keyvalues["historic"] == "lodge"           ) or
       ( keyvalues["historic"] == "mansion"         ) or
       ( keyvalues["historic"] == "country_mansion" ) or
       ( keyvalues["historic"] == "stately_home"    ) or
       ( keyvalues["historic"] == "palace"          )) then
      keyvalues["historic"] = "manor"
      keyvalues["tourism"] = nil

      if (( keyvalues["landuse"] == nil ) and
          ( keyvalues["leisure"] == nil ) and
          ( keyvalues["natural"] == nil )) then
         keyvalues["landuse"] = "historic"
      end
   end

-- ----------------------------------------------------------------------------
-- Martello Towers go through as "historic=martello_tower"
-- Some other structural tags that might otherwise get shown are removed.
-- ----------------------------------------------------------------------------
   if (( keyvalues["historic"] == "martello_tower"        ) or
       ( keyvalues["historic"] == "martello_tower;bunker" ) or
       ( keyvalues["historic"] == "martello_tower;fort"   )) then
      keyvalues["historic"] = "martello_tower"
      keyvalues["fortification_type"] = nil
      keyvalues["man_made"] = nil
      keyvalues["tower:type"] = nil

      if (( keyvalues["landuse"] == nil ) and
          ( keyvalues["leisure"] == nil ) and
          ( keyvalues["natural"] == nil )) then
         keyvalues["landuse"] = "historic"
      end
   end

-- ----------------------------------------------------------------------------
-- Unless an active place of worship,
-- monasteries etc. go through as "historic=monastery"
-- "historic=ruins;ruins=monastery" are handled the same way.
-- ----------------------------------------------------------------------------
   if ((   keyvalues["historic"] == "abbey"            ) or
       (   keyvalues["historic"] == "cathedral"        ) or
       (   keyvalues["historic"] == "monastery"        ) or
       (   keyvalues["historic"] == "priory"           ) or
       ((  keyvalues["historic"] == "ruins"            )  and
        (( keyvalues["ruins"] == "abbey"              )  or
         ( keyvalues["ruins"] == "cathedral"          )  or
         ( keyvalues["ruins"] == "monastery"          )  or
         ( keyvalues["ruins"] == "priory"             )))) then
      if ( keyvalues["amenity"] == "place_of_worship" ) then
         keyvalues["historic"] = nil
      else
         keyvalues["historic"] = "monastery"

         if (( keyvalues["landuse"] == nil ) and
             ( keyvalues["leisure"] == nil ) and
             ( keyvalues["natural"] == nil )) then
            keyvalues["landuse"] = "historic"
         end
      end
   end

-- ----------------------------------------------------------------------------
-- Non-historic crosses go through as "man_made=cross".  
-- See also memorial crosses below.
-- ----------------------------------------------------------------------------
   if (( keyvalues["man_made"] == "cross"         ) or
       ( keyvalues["man_made"] == "summit_cross"  ) or
       ( keyvalues["man_made"] == "wayside_cross" )) then
      keyvalues["man_made"] = "cross"
   end

-- ----------------------------------------------------------------------------
-- Various historic crosses go through as "historic=cross".  
-- See also memorial crosses below.
-- ----------------------------------------------------------------------------
   if (( keyvalues["historic"] == "wayside_cross"    ) or
       ( keyvalues["historic"] == "high_cross"       ) or
       ( keyvalues["historic"] == "cross"            ) or
       ( keyvalues["historic"] == "market_cross"     ) or
       ( keyvalues["historic"] == "tau_cross"        ) or
       ( keyvalues["historic"] == "celtic_cross"     )) then
      keyvalues["historic"] = "cross"

      if (( keyvalues["landuse"] == nil ) and
          ( keyvalues["leisure"] == nil ) and
          ( keyvalues["natural"] == nil )) then
         keyvalues["landuse"] = "historic"
      end
   end

-- ----------------------------------------------------------------------------
-- Historic churches go through as "historic=church", 
-- if they're not also an amenity or something else.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["historic"] == "chapel"           )  or
        ( keyvalues["historic"] == "church"           )  or
        ( keyvalues["historic"] == "place_of_worship" )  or
        ( keyvalues["historic"] == "wayside_chapel"   )) and
       (  keyvalues["amenity"]  == nil                 ) and
       (  keyvalues["shop"]     == nil                 )) then
      keyvalues["historic"] = "church"
      keyvalues["building"] = "yes"
      keyvalues["tourism"] = nil

      if (( keyvalues["landuse"] == nil ) and
          ( keyvalues["leisure"] == nil ) and
          ( keyvalues["natural"] == nil )) then
         keyvalues["landuse"] = "historic"
      end
   end

-- ----------------------------------------------------------------------------
-- Historic pinfolds go through as "historic=pinfold", 
-- Some have recently been added as "historic=pound".
-- ----------------------------------------------------------------------------
   if (( keyvalues["historic"] == "pinfold" )  or
       ( keyvalues["amenity"]  == "pinfold" )  or
       ( keyvalues["historic"] == "pound"   )) then
      keyvalues["historic"] = "pinfold"

      if (( keyvalues["landuse"] == nil ) and
          ( keyvalues["leisure"] == nil ) and
          ( keyvalues["natural"] == nil )) then
         keyvalues["landuse"] = "historic"
      end
   end

-- ----------------------------------------------------------------------------
-- City gates go through as "historic=city_gate"
-- Note that historic=gate are generally much smaller and are not included here.
--
-- Also, there are individual icons for these:
-- "historic=battlefield", "historic=stocks" (also used for "pillory"), 
-- "historic=well", "historic=dovecote"
-- ----------------------------------------------------------------------------
   if ( keyvalues["historic"] == "pillory" ) then
      keyvalues["historic"] = "stocks"
   end

   if (( keyvalues["historic"] == "city_gate"   ) or
       ( keyvalues["historic"] == "battlefield" ) or
       ( keyvalues["historic"] == "stocks"      ) or
       ( keyvalues["historic"] == "well"        ) or
       ( keyvalues["historic"] == "dovecote"    )) then
      if (( keyvalues["landuse"] == nil ) and
          ( keyvalues["leisure"] == nil ) and
          ( keyvalues["natural"] == nil )) then
         keyvalues["landuse"] = "historic"
      end
   end

-- ----------------------------------------------------------------------------
-- historic=grave_yard goes through as historic=nonspecific, with fill for 
-- amenity=grave_yard if no landuse fill already.
-- ----------------------------------------------------------------------------
   if (((  keyvalues["historic"]        == "grave_yard"  )  or
        (  keyvalues["historic"]        == "cemetery"    )  or
        (  keyvalues["disused:amenity"] == "grave_yard"  )  or
        (( keyvalues["historic"]        == "ruins"      )   and
         ( keyvalues["ruins"]           == "grave_yard" ))) and
       (  keyvalues["amenity"]         == nil           ) and
       (  keyvalues["landuse"]         ~= "cemetery"    )) then
      keyvalues["historic"] = "nonspecific"

      if (( keyvalues["landuse"] == nil ) and
          ( keyvalues["leisure"] == nil )) then
         keyvalues["landuse"] = "cemetery"
      end
   end

-- ----------------------------------------------------------------------------
-- Towers go through as various historic towers
-- We also send ruined towers through here.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["historic"] == "tower"        ) or
       (  keyvalues["historic"] == "round_tower"  ) or
       (( keyvalues["historic"] == "ruins"       )  and
        ( keyvalues["ruins"]    == "tower"       ))) then
      keyvalues["man_made"] = nil

      if ((  keyvalues["historic"]  == "round_tower"  ) or
          ( keyvalues["tower:type"] == "round_tower"  ) or
          ( keyvalues["tower:type"] == "shot_tower"   )) then
         keyvalues["historic"] = "historicroundtower"
      else
         if ( keyvalues["tower:type"] == "defensive" ) then
            keyvalues["historic"] = "historicdefensivetower"
         else
            if (( keyvalues["tower:type"] == "observation" ) or
                ( keyvalues["tower:type"] == "watchtower"  )) then
               keyvalues["historic"] = "historicobservationtower"
            else
               if ( keyvalues["tower:type"] == "bell_tower" ) then
                  keyvalues["historic"] = "historicchurchtower"
               else
                  keyvalues["historic"] = "historicsquaretower"
               end  -- bell_tower
            end  -- observation
         end  -- defensive
      end  -- round_tower

      if (( keyvalues["landuse"] == nil ) and
          ( keyvalues["leisure"] == nil ) and
          ( keyvalues["natural"] == nil )) then
         keyvalues["landuse"] = "historic"
      end
   end

-- ----------------------------------------------------------------------------
-- Both kilns and lime kilns are shown with the same distinctive bottle kiln
-- shape.
-- ----------------------------------------------------------------------------
   if (( keyvalues["historic"]       == "lime_kiln" ) or
       ( keyvalues["ruins:man_made"] == "kiln"      )) then
      keyvalues["historic"]       = "kiln"
      keyvalues["ruins:man_made"] = nil
   end

-- ----------------------------------------------------------------------------
-- Show village_pump as water_pump
-- ----------------------------------------------------------------------------
   if ( keyvalues["historic"]  == "village_pump" ) then
      keyvalues["historic"] = "water_pump"
   end

-- ----------------------------------------------------------------------------
-- For aircraft without names, try and construct something
-- First use aircraft:model and/or ref.  If still no name, inscription.
-- ----------------------------------------------------------------------------
   if (( keyvalues["historic"] == "aircraft" ) and
       ( keyvalues["name"]     == nil        )) then
      if ( keyvalues["aircraft:model"] ~= nil ) then
         keyvalues["name"] = keyvalues["aircraft:model"]
      end

      if ( keyvalues["ref"] ~= nil ) then
         if ( keyvalues["name"] == nil ) then
            keyvalues["name"] = keyvalues["ref"]
         else
            keyvalues["name"] = keyvalues["name"] .. " " .. keyvalues["ref"]
         end
      end

      if (( keyvalues["name"]        == nil        ) and
          ( keyvalues["inscription"] ~= nil        )) then
         keyvalues["name"] = keyvalues["inscription"]
      end
   end

-- ----------------------------------------------------------------------------
-- Add a building tag to specific historic items that are likely buildings 
-- Note that "historic=mill" does not have a building tag added.
-- ----------------------------------------------------------------------------
   if (( keyvalues["historic"] == "aircraft"           ) or
       ( keyvalues["historic"] == "ice_house"          ) or
       ( keyvalues["historic"] == "kiln"               ) or
       ( keyvalues["historic"] == "ship"               ) or
       ( keyvalues["historic"] == "tank"               ) or
       ( keyvalues["historic"] == "watermill"          ) or
       ( keyvalues["historic"] == "windmill"           )) then
      if ( keyvalues["ruins"] == "yes" ) then
         keyvalues["building"] = "roof"
      else
         keyvalues["building"] = "yes"
      end
   end

-- ----------------------------------------------------------------------------
-- Add a building tag to nonspecific historic items that are likely buildings 
-- so that buildings.mss can process it.  Some shouldn't assume buildings 
-- (e.g. "fort" below).  Some use "roof" (which I use for "nearly a building" 
-- elsewhere).  It's sent through as "nonspecific".
-- "stone" has a building tag added because some are mapped as closed ways.
-- "landuse" is cleared because it might have been set for some building types
--  above.
-- ----------------------------------------------------------------------------
   if (( keyvalues["historic"] == "baths"              ) or
       ( keyvalues["historic"] == "building"           ) or
       ( keyvalues["historic"] == "chlochan"           ) or
       ( keyvalues["historic"] == "gate_house"         ) or
       ( keyvalues["historic"] == "heritage_building"  ) or
       ( keyvalues["historic"] == "house"              ) or
       ( keyvalues["historic"] == "locomotive"         ) or
       ( keyvalues["historic"] == "protected_building" ) or
       ( keyvalues["historic"] == "residence"          ) or
       ( keyvalues["historic"] == "roundhouse"         ) or
       ( keyvalues["historic"] == "smithy"             ) or
       ( keyvalues["historic"] == "sound_mirror"       ) or
       ( keyvalues["historic"] == "standing_stone"     ) or
       ( keyvalues["historic"] == "trough"             ) or
       ( keyvalues["historic"] == "vehicle"            )) then
      if ( keyvalues["ruins"] == "yes" ) then
         keyvalues["building"] = "roof"
      else
         keyvalues["building"] = "yes"
      end

      keyvalues["historic"] = "nonspecific"
      keyvalues["landuse"]  = nil
      keyvalues["tourism"]  = nil
   end

-- ----------------------------------------------------------------------------
-- historic=wreck is usually on nodes and has its own icon
-- ----------------------------------------------------------------------------
   if ( keyvalues["historic"] == "wreck" ) then
      keyvalues["building"] = "roof"
   end

   if ( keyvalues["historic"] == "aircraft_wreck" ) then
      keyvalues["building"] = "roof"
   end

-- ----------------------------------------------------------------------------
-- Ruined buildings do not have their own icon
-- ----------------------------------------------------------------------------
   if (( keyvalues["historic"] == "ruins"    )  and
       ( keyvalues["ruins"]    == "building" )  and
       ( keyvalues["barrier"]  == nil        )) then
      keyvalues["building"] = "roof"
      keyvalues["historic"] = "nonspecific"
   end
   
   if ((  keyvalues["historic"] == "ruins"             )  and
       (( keyvalues["ruins"]    == "church"           )  or
        ( keyvalues["ruins"]    == "place_of_worship" )  or
        ( keyvalues["ruins"]    == "wayside_chapel"   )  or
        ( keyvalues["ruins"]    == "chapel"           )) and
       (  keyvalues["amenity"]  == nil                 )) then
      keyvalues["building"] = "roof"
      keyvalues["historic"] = "church"
   end

   if ((  keyvalues["historic"] == "ruins"           )  and
       (( keyvalues["ruins"]    == "castle"         )  or
        ( keyvalues["ruins"]    == "fort"           )  or
        ( keyvalues["ruins"]    == "donjon"         )) and
       (  keyvalues["amenity"]  == nil               )) then
      keyvalues["historic"] = "historicarchcastle"
   end

-- ----------------------------------------------------------------------------
-- "historic=industrial" has been used as a modifier for all sorts.  
-- We're not interested in most of these but do display a historic dot for 
-- some.
-- ----------------------------------------------------------------------------
   if (( keyvalues["historic"] == "industrial" ) and
       ( keyvalues["building"] == nil          ) and
       ( keyvalues["man_made"] == nil          ) and
       ( keyvalues["waterway"] == nil          ) and
       ( keyvalues["name"]     ~= nil          )) then
      keyvalues["historic"] = "nonspecific"
      keyvalues["tourism"] = nil

      if (( keyvalues["landuse"] == nil ) and
          ( keyvalues["leisure"] == nil ) and
          ( keyvalues["natural"] == nil )) then
         keyvalues["landuse"] = "historic"
      end
   end

-- ----------------------------------------------------------------------------
-- Some tumuli are tagged as tombs, so dig those out first.
-- They are then picked up below.
--
-- Tombs that remain go straight through unless we need to set landuse.
-- ----------------------------------------------------------------------------
   if ( keyvalues["historic"] == "tomb" ) then
      if ( keyvalues["tomb"] == "tumulus" ) then
         keyvalues["historic"]            = "archaeological_site"
         keyvalues["archaeological_site"] = "tumulus"
      else
         if (( keyvalues["landuse"] == nil ) and
             ( keyvalues["leisure"] == nil ) and
             ( keyvalues["natural"] == nil )) then
            keyvalues["landuse"] = "historic"
         end
      end
   end
   
-- ----------------------------------------------------------------------------
-- The catch-all for most "sensible" historic values that are displayed with
-- a historic dot regardless of whether they have a name.
--
-- disused:landuse=cemetery goes through here rather than as 
-- historic=grave_yard above because the notes suggest that these are not 
-- visible as graveyards any more, so no graveyard fill.
-- ----------------------------------------------------------------------------   
   if ((  keyvalues["historic"] == "almshouse"                 ) or
       (  keyvalues["historic"] == "anchor"                    ) or
       (  keyvalues["historic"] == "bakery"                    ) or
       (  keyvalues["historic"] == "barrow"                    ) or
       (  keyvalues["historic"] == "battery"                   ) or
       (  keyvalues["historic"] == "bridge_site"               ) or
       (  keyvalues["historic"] == "camp"                      ) or
       (  keyvalues["historic"] == "deserted_medieval_village" ) or
       (  keyvalues["historic"] == "drinking_fountain"         ) or
       (  keyvalues["historic"] == "fortification"             ) or
       (  keyvalues["historic"] == "gate"                      ) or
       (  keyvalues["historic"] == "grinding_mill"             ) or
       (  keyvalues["historic"] == "hall"                      ) or
       (  keyvalues["historic"] == "jail"                      ) or
       (  keyvalues["historic"] == "millstone"                 ) or
       (  keyvalues["historic"] == "monastic_grange"           ) or
       (  keyvalues["historic"] == "mound"                     ) or
       (  keyvalues["historic"] == "naval_mine"                ) or
       (  keyvalues["historic"] == "oratory"                   ) or
       (  keyvalues["historic"] == "police_call_box"           ) or
       (  keyvalues["historic"] == "prison"                    ) or
       (  keyvalues["historic"] == "ruins"                     ) or
       (  keyvalues["historic"] == "sawmill"                   ) or
       (  keyvalues["historic"] == "shelter"                   ) or
       (  keyvalues["historic"] == "statue"                    ) or
       (  keyvalues["historic"] == "theatre"                   ) or
       (  keyvalues["historic"] == "toll_house"                ) or
       (  keyvalues["historic"] == "tower_house"               ) or
       (  keyvalues["historic"] == "village"                   ) or
       (  keyvalues["historic"] == "workhouse"                 ) or
       (( keyvalues["disused:landuse"] == "cemetery"          )  and
        ( keyvalues["landuse"]         == nil                 )  and
        ( keyvalues["leisure"]         == nil                 )  and
        ( keyvalues["amenity"]         == nil                 ))) then
      keyvalues["historic"] = "nonspecific"
      keyvalues["tourism"] = nil
      keyvalues["disused:landuse"] = nil

      if (( keyvalues["landuse"] == nil ) and
          ( keyvalues["leisure"] == nil ) and
          ( keyvalues["natural"] == nil )) then
         keyvalues["landuse"] = "historic"
      end
   end

-- ----------------------------------------------------------------------------
-- palaeolontological_site
-- ----------------------------------------------------------------------------
   if ( keyvalues["geological"] == "palaeontological_site" ) then
      keyvalues["historic"] = "palaeontological_site"
   end

-- ----------------------------------------------------------------------------
-- historic=icon shouldn't supersede amenity or tourism tags.
-- ----------------------------------------------------------------------------
   if (( keyvalues["historic"] == "icon" ) and
       ( keyvalues["amenity"]  == nil    ) and
       ( keyvalues["tourism"]  == nil    )) then
      keyvalues["historic"] = "nonspecific"
   end

-- ----------------------------------------------------------------------------
-- Historic markers
-- ----------------------------------------------------------------------------
   if (( keyvalues["historic"] == "marker"          ) or
       ( keyvalues["historic"] == "plaque"          ) or
       ( keyvalues["historic"] == "memorial_plaque" ) or
       ( keyvalues["historic"] == "blue_plaque"     )) then
      keyvalues["tourism"] = "informationplaque"
   end

   if ( keyvalues["historic"] == "pillar" ) then
      keyvalues["barrier"] = "bollard"
      keyvalues["historic"] = nil
   end

   if ( keyvalues["historic"] == "cairn" ) then
      keyvalues["man_made"] = "cairn"
      keyvalues["historic"] = nil
   end

   if (( keyvalues["historic"] == "chimney" ) or
       ( keyvalues["man_made"] == "chimney" ) or
       ( keyvalues["building"] == "chimney" )) then
      if (( tonumber(keyvalues["height"]) or 0 ) >  50 ) then
         keyvalues["man_made"] = "bigchimney"
      else
         keyvalues["man_made"] = "chimney"
      end
      keyvalues["historic"] = nil
   end

-- ----------------------------------------------------------------------------
-- hazard=plant is fairly rare, but render as a nonspecific historic dot.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["hazard"]  == "plant"                    )  or
        ( keyvalues["hazard"]  == "toxic_plant"              )) and
       (( keyvalues["species"] == "Heracleum mantegazzianum" )  or
        ( keyvalues["taxon"]   == "Heracleum mantegazzianum" ))) then
      keyvalues["historic"] = "nonspecific"
      keyvalues["name"] = "Hogweed"
   end

-- ----------------------------------------------------------------------------
-- If something has a "lock_ref", append it to "lock_name" (if it exists) or
-- "name" (if it doesn't)
-- ----------------------------------------------------------------------------
   if ( keyvalues["lock_ref"] ~= nil ) then
      if ( keyvalues["lock_name"] ~= nil ) then
         keyvalues["lock_name"] = keyvalues["lock_name"] .. " (" .. keyvalues["lock_ref"] .. ")"
      else
         if ( keyvalues["name"] ~= nil ) then
            keyvalues["name"] = keyvalues["name"] .. " (" .. keyvalues["lock_ref"] .. ")"
         else
            keyvalues["lock_name"] = "(" .. keyvalues["lock_ref"] .. ")"
         end
      end

      keyvalues["lock_ref"] = nil
   end

-- ----------------------------------------------------------------------------
-- If something (now) has a "lock_name", use it in preference to "name".
-- ----------------------------------------------------------------------------
   if ( keyvalues["lock_name"] ~= nil ) then
      keyvalues["name"] = keyvalues["lock_name"]
   end

-- ----------------------------------------------------------------------------
-- If set, move bridge:name to bridge_name
-- ----------------------------------------------------------------------------
   if ( keyvalues["bridge:name"] ~= nil ) then
      keyvalues["bridge_name"] = keyvalues["bridge:name"]
      keyvalues["bridge:name"] = nil
   end

-- ----------------------------------------------------------------------------
-- If set, move bridge_name to name
-- ----------------------------------------------------------------------------
   if ( keyvalues["bridge_name"] ~= nil ) then
      keyvalues["name"] = keyvalues["bridge_name"]
      keyvalues["bridge_name"] = nil
   end

-- ----------------------------------------------------------------------------
-- If set, move bridge:ref to bridge_ref
-- ----------------------------------------------------------------------------
   if ( keyvalues["bridge:ref"] ~= nil ) then
      keyvalues["bridge_ref"] = keyvalues["bridge:ref"]
      keyvalues["bridge:ref"] = nil
   end

-- ----------------------------------------------------------------------------
-- If set, move canal_bridge_ref to bridge_ref
-- ----------------------------------------------------------------------------
   if ( keyvalues["canal_bridge_ref"] ~= nil ) then
      keyvalues["bridge_ref"] = keyvalues["canal_bridge_ref"]
      keyvalues["canal_bridge_ref"] = nil
   end

-- ----------------------------------------------------------------------------
-- If set and relevant, do something with bridge_ref
-- ----------------------------------------------------------------------------
   if ((  keyvalues["bridge_ref"] ~= nil  ) and
       (( keyvalues["highway"]    ~= nil )  or
        ( keyvalues["railway"]    ~= nil )  or
        ( keyvalues["waterway"]   ~= nil ))) then
      if ( keyvalues["name"] == nil ) then
         keyvalues["name"] = "{" .. keyvalues["bridge_ref"] .. ")"
      else
         keyvalues["name"] = keyvalues["name"] .. " {" .. keyvalues["bridge_ref"] .. ")"
      end

      keyvalues["bridge_ref"] = nil
   end

-- ----------------------------------------------------------------------------
-- If set, move tunnel:name to tunnel_name
-- ----------------------------------------------------------------------------
   if ( keyvalues["tunnel:name"] ~= nil ) then
      keyvalues["tunnel_name"] = keyvalues["tunnel:name"]
      keyvalues["tunnel:name"] = nil
   end

-- ----------------------------------------------------------------------------
-- If set, move tunnel_name to name
-- ----------------------------------------------------------------------------
   if ( keyvalues["tunnel_name"] ~= nil ) then
      keyvalues["name"] = keyvalues["tunnel_name"]
      keyvalues["tunnel_name"] = nil
   end

-- ----------------------------------------------------------------------------
-- If something has a "tpuk_ref", use it in preference to "name".
-- It's in brackets because it's likely not signed.
-- ----------------------------------------------------------------------------
   if ( keyvalues["tpuk_ref"] ~= nil ) then
      keyvalues["name"] = "(" .. keyvalues["tpuk_ref"] .. ")"
   end

-- ----------------------------------------------------------------------------
-- Disused railway platforms
-- ----------------------------------------------------------------------------
   if (( keyvalues["railway"] == "platform" ) and
       ( keyvalues["disused"] == "yes"       )) then
      keyvalues["railway"] = nil
      keyvalues["disused:railway"] = "platform"
   end

-- ----------------------------------------------------------------------------
-- Suppress Underground railway platforms
-- ----------------------------------------------------------------------------
   if ((  keyvalues["railway"]     == "platform"     ) and
       (( keyvalues["location"]    == "underground" )  or
        ( keyvalues["underground"] == "yes"         )  or
        (( tonumber(keyvalues["layer"]) or 0 ) <  0 ))) then
      keyvalues["railway"] = nil
   end

-- ----------------------------------------------------------------------------
-- If railway platforms have a ref, use it.
-- ----------------------------------------------------------------------------
   if (( keyvalues["railway"] == "platform" ) and
       ( keyvalues["ref"]     ~= nil        )) then
      keyvalues["name"] = "Platform " .. keyvalues["ref"]
      keyvalues["ref"]  = nil
   end

-- ----------------------------------------------------------------------------
-- Add "water" to some "wet" features for rendering.
-- ----------------------------------------------------------------------------
   if (( keyvalues["man_made"]   == "wastewater_reservoir"  ) or
       ( keyvalues["man_made"]   == "lagoon"                ) or
       ( keyvalues["man_made"]   == "lake"                  ) or
       ( keyvalues["man_made"]   == "reservoir"             ) or
       ( keyvalues["landuse"]    == "reservoir"             ) or
       ( keyvalues["basin"]      == "wastewater"            )) then
      keyvalues["natural"] = "water"
   end

-- ----------------------------------------------------------------------------
-- Suppress "name" on riverbanks mapped as "natural=water"
-- ----------------------------------------------------------------------------
   if (( keyvalues["natural"]   == "water"  ) and
       ( keyvalues["water"]     == "river"  )) then
      keyvalues["name"] = nil
   end

-- ----------------------------------------------------------------------------
-- Handle intermittent water areas.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["natural"]      == "water"  )  or
        ( keyvalues["landuse"]      == "basin"  )) and
       (  keyvalues["intermittent"] == "yes"     )) then
      keyvalues["natural"] = "intermittentwater"
      keyvalues["landuse"] = nil
   end

-- ----------------------------------------------------------------------------
-- Also try and detect flood plains etc.
-- ----------------------------------------------------------------------------
   if ((   keyvalues["natural"]      == "floodplain"     ) or
       ((( keyvalues["flood_prone"]  == "yes"          )   or
         (( keyvalues["hazard_prone"] == "yes"        )    and
          ( keyvalues["hazard_type"]  == "flood"      )))  and
        (  keyvalues["natural"]      == nil             )  and
        (  keyvalues["highway"]      == nil             )) or
       ((  keyvalues["natural"]      == nil             )  and
        (  keyvalues["landuse"]      ~= "basin"         )  and
        (( keyvalues["basin"]        == "detention"    )   or
         ( keyvalues["basin"]        == "retention"    )   or
         ( keyvalues["basin"]        == "infiltration" )   or
         ( keyvalues["basin"]        == "side_pound"   )))) then
      keyvalues["natural"] = "flood_prone"
   end

-- ----------------------------------------------------------------------------
-- Handle intermittent wetland areas.
-- ----------------------------------------------------------------------------
   if (( keyvalues["natural"]      == "wetland"  )  and
       ( keyvalues["intermittent"] == "yes"      )) then
      keyvalues["natural"] = "intermittentwetland"
   end

-- ----------------------------------------------------------------------------
-- Map wind turbines to, er, wind turbines and make sure that they don't also
-- appear as towers.
-- ----------------------------------------------------------------------------
   if (( keyvalues["man_made"]   == "wind_turbine" ) or
       ( keyvalues["man_made"]   == "windpump"     )) then
      keyvalues["power"]        = "generator"
      keyvalues["power_source"] = "wind"
   end

   if ((  keyvalues["man_made"]         == "tower"         ) and
       (  keyvalues["power"]            == "generator"     ) and
       (( keyvalues["power_source"]     == "wind"         )  or
        ( keyvalues["generator:source"] == "wind"         )  or
        ( keyvalues["generator:method"] == "wind_turbine" )  or
        ( keyvalues["plant:source"]     == "wind"         )  or
        ( keyvalues["generator:method"] == "wind"         ))) then
      keyvalues["man_made"] = nil
   end

-- ----------------------------------------------------------------------------
-- Change solar panels to "roof"
-- ----------------------------------------------------------------------------
   if (( keyvalues["power"]            == "generator"    ) and
       ( keyvalues["generator:method"] == "photovoltaic" )) then
      keyvalues["power"]    = nil
      keyvalues["building"] = "roof"
   end

-- ----------------------------------------------------------------------------
-- Railway ventilation shaft nodes.
-- These are rendered as a stubby black tower.
-- ----------------------------------------------------------------------------
   if (( keyvalues["building"]   == "air_shaft"         ) or
       ( keyvalues["man_made"]   == "air_shaft"         ) or
       ( keyvalues["tunnel"]     == "air_shaft"         ) or
       ( keyvalues["historic"]   == "air_shaft"         ) or
       ( keyvalues["railway"]    == "ventilation_shaft" ) or
       ( keyvalues["tunnel"]     == "ventilation_shaft" ) or
       ( keyvalues["tunnel"]     == "ventilation shaft" ) or
       ( keyvalues["building"]   == "ventilation_shaft" ) or
       ( keyvalues["man_made"]   == "ventilation_shaft" ) or
       ( keyvalues["building"]   == "vent_shaft"        ) or
       ( keyvalues["man_made"]   == "vent_shaft"        ) or
       ( keyvalues["tower:type"] == "vent"              ) or
       ( keyvalues["tower:type"] == "ventilation_shaft" )) then
      keyvalues["man_made"] = "ventilation_shaft"

      if ( keyvalues["building"] == nil ) then
         keyvalues["building"] = "roof"
      end
   end

-- ----------------------------------------------------------------------------
-- Horse mounting blocks
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"]   == "mounting_block"       ) or
       ( keyvalues["historic"]  == "mounting_block"       ) or
       ( keyvalues["amenity"]   == "mounting_step"        ) or
       ( keyvalues["amenity"]   == "mounting_steps"       ) or
       ( keyvalues["amenity"]   == "horse_dismount_block" )) then
      keyvalues["man_made"] = "mounting_block"
   end

-- ----------------------------------------------------------------------------
-- Water monitoring stations
-- ----------------------------------------------------------------------------
   if ((  keyvalues["man_made"]                  == "monitoring_station"  ) and
       (( keyvalues["monitoring:water_level"]    == "yes"                )  or
        ( keyvalues["monitoring:water_flow"]     == "yes"                )  or
        ( keyvalues["monitoring:water_velocity"] == "yes"                ))) then
      keyvalues["man_made"] = "monitoringwater"
   end

-- ----------------------------------------------------------------------------
-- Weather monitoring stations
-- ----------------------------------------------------------------------------
   if (( keyvalues["man_made"]               == "monitoring_station" ) and
       ( keyvalues["monitoring:weather"]     == "yes"                ) and
       ( keyvalues["weather:radar"]          == nil                  ) and
       ( keyvalues["monitoring:water_level"] == nil                  )) then
      keyvalues["man_made"] = "monitoringweather"
   end

-- ----------------------------------------------------------------------------
-- Rainfall monitoring stations
-- ----------------------------------------------------------------------------
   if (( keyvalues["man_made"]               == "monitoring_station" ) and
       ( keyvalues["monitoring:rainfall"]    == "yes"                ) and
       ( keyvalues["monitoring:weather"]     == nil                  ) and
       ( keyvalues["monitoring:water_level"] == nil                  )) then
      keyvalues["man_made"] = "monitoringrainfall"
   end

-- ----------------------------------------------------------------------------
-- Earthquake monitoring stations
-- ----------------------------------------------------------------------------
   if (( keyvalues["man_made"]                     == "monitoring_station" ) and
       ( keyvalues["monitoring:seismic_activity"]  == "yes"                )) then
      keyvalues["man_made"] = "monitoringearthquake"
   end

-- ----------------------------------------------------------------------------
-- Sky brightness monitoring stations
-- ----------------------------------------------------------------------------
   if (( keyvalues["man_made"]                   == "monitoring_station" ) and
       ( keyvalues["monitoring:sky_brightness"]  == "yes"                )) then
      keyvalues["man_made"] = "monitoringsky"
   end

-- ----------------------------------------------------------------------------
-- Air quality monitoring stations
-- ----------------------------------------------------------------------------
   if (( keyvalues["man_made"]               == "monitoring_station" ) and
       ( keyvalues["monitoring:air_quality"] == "yes"                ) and
       ( keyvalues["monitoring:weather"]     == nil                  )) then
      keyvalues["man_made"] = nil
      keyvalues["landuse"] = "industrial"
      if ( keyvalues["name"] == nil ) then
         keyvalues["name"] = "(air quality)"
      else
         keyvalues["name"] = keyvalues["name"] .. " (air quality)"
      end
   end

-- ----------------------------------------------------------------------------
-- Golf ball washers
-- ----------------------------------------------------------------------------
   if ( keyvalues["golf"] == "ball_washer" ) then
      keyvalues["man_made"] = "golfballwasher"
   end

-- ----------------------------------------------------------------------------
-- Advertising Columns
-- ----------------------------------------------------------------------------
   if ( keyvalues["advertising"] == "column" ) then
      keyvalues["tourism"] = "advertising_column"
   end

-- ----------------------------------------------------------------------------
-- railway=transfer_station - show as "halt"
-- This is for Manulla Junction, https://www.openstreetmap.org/node/5524753168
-- ----------------------------------------------------------------------------
   if ( keyvalues["railway"] == "transfer_station" ) then
      keyvalues["railway"] = "halt"
   end

-- ----------------------------------------------------------------------------
-- Show unspecified "public_transport=station" as "railway=halt"
-- These are normally one of amenity=bus_station, railway=station or
--  aerialway=station.  If they are none of these at least sow them as something.
-- ----------------------------------------------------------------------------
   if (( keyvalues["public_transport"] == "station" ) and
       ( keyvalues["amenity"]          == nil       ) and
       ( keyvalues["railway"]          == nil       ) and
       ( keyvalues["aerialway"]        == nil       )) then
      keyvalues["railway"]          = "halt"
      keyvalues["public_transport"] = nil
   end

-- ----------------------------------------------------------------------------
-- "tourism" stations - show with brown text rather than blue.
-- ----------------------------------------------------------------------------
   if (((( keyvalues["railway"]           == "station"   )    or
         ( keyvalues["railway"]           == "halt"      ))   and
        (( keyvalues["usage"]             == "tourism"   )    or
         ( keyvalues["station"]           == "miniature" )    or
         ( keyvalues["tourism"]           == "yes"       )))  or
       (   keyvalues["railway:miniature"] == "station"     )) then
      keyvalues["amenity"] = "tourismstation"
      keyvalues["railway"] = nil
      keyvalues["railway:miniature"] = nil
   end

-- ----------------------------------------------------------------------------
-- railway=crossing - show as level crossings.
-- ----------------------------------------------------------------------------
   if ( keyvalues["railway"] == "crossing" ) then
      keyvalues["railway"] = "level_crossing"
   end

-- ----------------------------------------------------------------------------
-- Various types of traffic light controlled crossings
-- ----------------------------------------------------------------------------
   if ((( keyvalues["crossing"] == "traffic_signals"         )  or
        ( keyvalues["crossing"] == "toucan"                  )  or
        ( keyvalues["crossing"] == "puffin"                  )  or
        ( keyvalues["crossing"] == "traffic_signals;island"  )  or
        ( keyvalues["crossing"] == "traffic_lights"          )  or
        ( keyvalues["crossing"] == "island;traffic_signals"  )  or
        ( keyvalues["crossing"] == "signals"                 )  or
        ( keyvalues["crossing"] == "pegasus"                 )  or
        ( keyvalues["crossing"] == "pedestrian_signals"      )  or
        ( keyvalues["crossing"] == "light_controlled"        )  or
        ( keyvalues["crossing"] == "light controlled"        )) and
       (  keyvalues["highway"]  == nil                        )) then
      keyvalues["highway"] = "traffic_signals"
      keyvalues["crossing"] = nil
   end

-- ----------------------------------------------------------------------------
-- highway=passing_place to turning_circle
-- Not really the same thing, but a "widening of the road" should be good 
-- enough.  
-- ----------------------------------------------------------------------------
   if ( keyvalues["highway"] == "passing_place" ) then
      keyvalues["highway"] = "turning_circle"
   end

-- ----------------------------------------------------------------------------
-- highway=escape to service
-- There aren't many escape lanes mapped, but they do exist
-- ----------------------------------------------------------------------------
   if ( keyvalues["highway"]   == "escape" ) then
      keyvalues["highway"] = "service"
      keyvalues["access"]  = "destination"
   end

-- ----------------------------------------------------------------------------
-- Render guest houses subtagged as B&B as B&B
-- ----------------------------------------------------------------------------
   if (( keyvalues["tourism"]     == "guest_house"       ) and
       ( keyvalues["guest_house"] == "bed_and_breakfast" )) then
      keyvalues["tourism"] = "bed_and_breakfast"
   end

-- ----------------------------------------------------------------------------
-- "self_catering" is increasingly common and a series of different icons are
-- used for them, based on values for whether it is:
--
-- self catering       yes or no
-- multiple occupancy  yes, no, or don't know
-- urban setting       urban, rural, or don't know
-- cheap               yes (like a hostel) or no (like a hotel)
--
-- The resulting values such as "tourism_guest_yyyy" are passed through to be 
-- rendered.
-- ----------------------------------------------------------------------------
   if (( keyvalues["tourism"]   == "self_catering"           ) or
       ( keyvalues["tourism"]   == "accommodation"           ) or
       ( keyvalues["tourism"]   == "holiday_let"             )) then
      keyvalues["tourism"] = "tourism_guest_yddd"
   end

   if ( keyvalues["tourism"]   == "apartment"               ) then
      keyvalues["tourism"] = "tourism_guest_ynyn"
   end

   if (( keyvalues["tourism"]   == "holiday_cottage"         ) or
       ( keyvalues["tourism"]   == "cottage"                 )) then
      keyvalues["tourism"] = "tourism_guest_ynnn"
   end

   if (( keyvalues["tourism"]   == "holiday_village"         ) or
       ( keyvalues["tourism"]   == "holiday_park"            ) or
       ( keyvalues["tourism"]   == "holiday_lets"            )) then
      keyvalues["tourism"] = "tourism_guest_dynd"
   end

   if ( keyvalues["tourism"]   == "spa_resort"              ) then
      keyvalues["tourism"] = "tourism_guest_nynn"
   end

   if ( keyvalues["tourism"]   == "Holiday Lodges"          ) then
      keyvalues["tourism"] = "tourism_guest_yynd"
   end

   if (( keyvalues["tourism"]   == "aparthotel"              ) or
       ( keyvalues["tourism"]   == "apartments"              )) then
      keyvalues["tourism"] = "tourism_guest_yyyn"
   end

-- ----------------------------------------------------------------------------
-- tourism=bed_and_breakfast was removed by the "style police" in
-- https://github.com/gravitystorm/openstreetmap-carto/pull/695
-- That now has its own icon.
-- Self-catering is handled above.
-- That just leaves "tourism=guest_house":
-- ----------------------------------------------------------------------------
   if ( keyvalues["tourism"]   == "guest_house"          ) then
      keyvalues["tourism"] = "tourism_guest_nydn"
   end

-- ----------------------------------------------------------------------------
-- Render alternative taggings of camp_site etc.
-- ----------------------------------------------------------------------------
   if (( keyvalues["tourism"] == "camping"                ) or
       ( keyvalues["tourism"] == "camp_site;caravan_site" )) then
      keyvalues["tourism"] = "camp_site"
   end

   if ( keyvalues["tourism"] == "caravan_site;camp_site" ) then
      keyvalues["tourism"] = "caravan_site"
   end

   if ( keyvalues["tourism"] == "adventure_holiday"  ) then
      keyvalues["tourism"] = "hostel"
   end

-- ----------------------------------------------------------------------------
-- Chalets
--
-- Depending on other tags, these will be treated as singlechalet (z17)
-- or as chalet (z16).  Processing here is simpler than for Garmin as we don't
-- have to worry where on the search menu something will appear.
--
-- We assume that tourism=chalet with no building tag could be either a
-- self-contained chalet park or just one chalet.  Leave tagging as is.
--
-- We assume that tourism=chalet with a building tag is a 
-- self-contained chalet or chalet within a resort.  Change to "singlechalet".
-- ----------------------------------------------------------------------------
   if ( keyvalues["tourism"] == "chalet" ) then
      keyvalues["leisure"] = nil

      if (( keyvalues["name"]     == nil ) or
          ( keyvalues["building"] ~= nil )) then
         keyvalues["tourism"] = "singlechalet"
      end
   end

-- ----------------------------------------------------------------------------
-- "leisure=trailhead" is an occasional mistagging for "highway=trailhead"
-- ----------------------------------------------------------------------------
   if (( keyvalues["leisure"] == "trailhead" ) and
       ( keyvalues["highway"] == nil         )) then
      keyvalues["highway"] = "trailhead"
      keyvalues["leisure"] = nil
   end

-- ----------------------------------------------------------------------------
-- Trailheads appear in odd combinations, not all of which make sense.
--
-- If someone's tagged a trailhead as a locality; likely it's not really one
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"] == "trailhead" ) and
       ( keyvalues["place"]   == "locality"  )) then
      keyvalues["place"] = nil
   end

-- ----------------------------------------------------------------------------
-- If a trailhead also has a tourism tag, go with whatever tourism tag that is,
-- rather than sending it through as "informationroutemarker" below.
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"] == "trailhead" ) and
       ( keyvalues["tourism"] ~= nil         )) then
      keyvalues["highway"] = nil
   end

-- ----------------------------------------------------------------------------
-- If a trailhead has no name but an operator, use that
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"]  == "trailhead" ) and
       ( keyvalues["name"]     == nil         ) and
       ( keyvalues["operator"] ~= nil         )) then
      keyvalues["name"] = keyvalues["operator"]
   end

-- ----------------------------------------------------------------------------
-- If a trailhead still has no name, remove it
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"]  == "trailhead" ) and
       ( keyvalues["name"]     == nil         )) then
      keyvalues["highway"] = nil
   end

-- ----------------------------------------------------------------------------
-- Render amenity=information as tourism
-- ----------------------------------------------------------------------------
   if ( keyvalues["amenity"] == "information"  ) then
      keyvalues["tourism"] = "information"
   end

-- ----------------------------------------------------------------------------
-- Various types of information - PNFS guideposts first.
-- ----------------------------------------------------------------------------
   if (( keyvalues["tourism"]    == "information"                          ) and
       (( keyvalues["operator"]  == "Peak & Northern Footpaths Society"   )  or
        ( keyvalues["operator"]  == "Peak and Northern Footpaths Society" )  or
        ( keyvalues["operator"]  == "Peak District & Northern Counties Footpaths Preservation Society" ))) then
      keyvalues["tourism"] = "informationpnfs"
   end

-- ----------------------------------------------------------------------------
-- Some information boards don't have a "tourism" tag
-- ----------------------------------------------------------------------------
   if (( keyvalues["information"]     == "board" ) and
       ( keyvalues["disused:tourism"] == nil     ) and
       ( keyvalues["ruins:tourism"]   == nil     ) and
       ( keyvalues["historic"]        == nil     )) then
      if ( keyvalues["board_type"] == "public_transport" ) then
         keyvalues["tourism"] = "informationpublictransport"
      else
         keyvalues["tourism"] = "informationboard"
      end
   end

-- ----------------------------------------------------------------------------
-- Information boards
-- ----------------------------------------------------------------------------
   if ((   keyvalues["amenity"]     == "notice_board"                       )  or
       (   keyvalues["tourism"]     == "village_sign"                       )  or
       (   keyvalues["man_made"]    == "village_sign"                       )  or
       ((  keyvalues["tourism"]     == "information"                       )   and
        (( keyvalues["information"] == "board"                            )    or
         ( keyvalues["information"] == "board;map"                        )    or
         ( keyvalues["information"] == "citymap"                          )    or
         ( keyvalues["information"] == "departure times and destinations" )    or
         ( keyvalues["information"] == "electronic_board"                 )    or
         ( keyvalues["information"] == "estate_map"                       )    or
         ( keyvalues["information"] == "former_telephone_box"             )    or
         ( keyvalues["information"] == "hikingmap"                        )    or
         ( keyvalues["information"] == "history"                          )    or
         ( keyvalues["information"] == "hospital map"                     )    or
         ( keyvalues["information"] == "information_board"                )    or
         ( keyvalues["information"] == "interpretation"                   )    or
         ( keyvalues["information"] == "interpretive_board"               )    or
         ( keyvalues["information"] == "leaflet_board"                    )    or
         ( keyvalues["information"] == "leaflets"                         )    or
         ( keyvalues["information"] == "map and posters"                  )    or
         ( keyvalues["information"] == "map"                              )    or
         ( keyvalues["information"] == "map;board"                        )    or
         ( keyvalues["information"] == "map_board"                        )    or
         ( keyvalues["information"] == "nature"                           )    or
         ( keyvalues["information"] == "notice_board"                     )    or
         ( keyvalues["information"] == "noticeboard"                      )    or
         ( keyvalues["information"] == "orientation_map"                  )    or
         ( keyvalues["information"] == "sitemap"                          )    or
         ( keyvalues["information"] == "tactile_map"                      )    or
         ( keyvalues["information"] == "tactile_model"                    )    or
         ( keyvalues["information"] == "terminal"                         )    or
         ( keyvalues["information"] == "wildlife"                         )))) then
      if ( keyvalues["board_type"] == "public_transport" ) then
         keyvalues["tourism"] = "informationpublictransport"
      else
         keyvalues["tourism"] = "informationboard"
      end
   end

   if ((  keyvalues["amenity"]     == "notice_board"       )  or
       (  keyvalues["tourism"]     == "sign"               )  or
       (  keyvalues["emergency"]   == "beach_safety_sign"  )  or
       (( keyvalues["tourism"]     == "information"       )   and
        ( keyvalues["information"] == "sign"              ))) then
      if ( keyvalues["operator:type"] == "military" ) then
         keyvalues["tourism"] = "militarysign"
      else
         keyvalues["tourism"] = "informationsign"
      end
   end

   if ((( keyvalues["tourism"]     == "informationboard"           )   or
        ( keyvalues["tourism"]     == "informationpublictransport" )   or
        ( keyvalues["tourism"]     == "informationsign"            )   or
        ( keyvalues["tourism"]     == "militarysign"               ))  and
       (  keyvalues["name"]        == nil                           )  and
       (  keyvalues["board:title"] ~= nil                           )) then
      keyvalues["name"] = keyvalues["board:title"]
   end

   if (((  keyvalues["tourism"]     == "information"                       )  and
        (( keyvalues["information"] == "guidepost"                        )   or
         ( keyvalues["information"] == "fingerpost"                       )   or
         ( keyvalues["information"] == "marker"                           ))) or
       (   keyvalues["man_made"]    == "signpost"                           )) then
      if ( keyvalues["guide_type"] == "intermediary" ) then
         keyvalues["tourism"] = "informationroutemarker"
      else
         keyvalues["tourism"] = "informationmarker"
         keyvalues["ele"] = nil

	 if ( keyvalues["name"] ~= nil ) then
	    keyvalues["ele"] = keyvalues["name"]
	 end

         append_directions(keyvalues)
      end
   end

   if (((  keyvalues["tourism"]     == "information"                       )   and
        (( keyvalues["information"] == "route_marker"                     )    or
         ( keyvalues["information"] == "trail_blaze"                      )))  or
       (   keyvalues["highway"]     == "trailhead"                          )) then
      keyvalues["tourism"] = "informationroutemarker"
   end

   if ((  keyvalues["tourism"]     == "information"                       )  and
       (( keyvalues["information"] == "office"                           )   or
        ( keyvalues["information"] == "kiosk"                            )   or
        ( keyvalues["information"] == "visitor_centre"                   ))) then
      keyvalues["tourism"] = "informationoffice"
   end

   if ((  keyvalues["tourism"]     == "information"                       )  and
       (( keyvalues["information"] == "blue_plaque"                      )   or
        ( keyvalues["information"] == "plaque"                           ))) then
      keyvalues["tourism"] = "informationplaque"
   end

   if (( keyvalues["tourism"]     == "information"                       )  and
       ( keyvalues["information"] == "audioguide"                        )) then
      keyvalues["tourism"] = "informationear"
   end


-- ----------------------------------------------------------------------------
-- NCN Route markers
-- ----------------------------------------------------------------------------
   if ( keyvalues["ncn_milepost"] == "dudgeon" ) then
      keyvalues["tourism"] = "informationncndudgeon"
      keyvalues["name"]    = keyvalues["sustrans_ref"]
   end

   if ( keyvalues["ncn_milepost"] == "mccoll" ) then
      keyvalues["tourism"] = "informationncnmccoll"
      keyvalues["name"]    = keyvalues["sustrans_ref"]
   end

   if ( keyvalues["ncn_milepost"] == "mills" ) then
      keyvalues["tourism"] = "informationncnmills"
      keyvalues["name"]    = keyvalues["sustrans_ref"]
   end

   if ( keyvalues["ncn_milepost"] == "rowe" ) then
      keyvalues["tourism"] = "informationncnrowe"
      keyvalues["name"]    = keyvalues["sustrans_ref"]
   end

   if (( keyvalues["ncn_milepost"] == "unknown" )  or
       ( keyvalues["ncn_milepost"] == "yes"     )) then
      keyvalues["tourism"] = "informationncnunknown"
      keyvalues["name"]    = keyvalues["sustrans_ref"]
   end


-- ----------------------------------------------------------------------------
-- Change some common semicolon values to the first in the list.
-- ----------------------------------------------------------------------------
   if ( keyvalues["amenity"] == "bar;restaurant" ) then
      keyvalues["amenity"] = "bar"
   end

   if ( keyvalues["shop"] == "butcher;greengrocer" ) then
      keyvalues["shop"] = "butcher"
   end

-- ----------------------------------------------------------------------------
-- Things that are both peaks and memorials should render as the latter.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["natural"]   == "hill"     )  or
        ( keyvalues["natural"]   == "peak"     )) and
       (  keyvalues["historic"]  == "memorial"  )) then
      keyvalues["natural"] = nil
   end

-- ----------------------------------------------------------------------------
-- Things that are both peaks and cairns should render as the former.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["natural"]   == "hill"     )  or
        ( keyvalues["natural"]   == "peak"     )) and
       (  keyvalues["man_made"]  == "cairn"     )) then
      keyvalues["man_made"] = nil
   end

-- ----------------------------------------------------------------------------
-- Beacons - render historic ones, not radio ones.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["man_made"] == "beacon"        )  or
        ( keyvalues["man_made"] == "signal_beacon" )  or
        ( keyvalues["landmark"] == "beacon"        )  or
        ( keyvalues["historic"] == "beacon"        )) and
       (  keyvalues["airmark"]  == nil              ) and
       (  keyvalues["aeroway"]  == nil              ) and
       (  keyvalues["natural"]  ~= "hill"           ) and
       (  keyvalues["natural"]  ~= "peak"           )) then
      keyvalues["historic"] = "nonspecific"
   end

-- ----------------------------------------------------------------------------
-- Render historic railway stations.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["abandoned:railway"] == "station"         )  or
        ( keyvalues["disused:railway"]   == "station"         )  or
        ( keyvalues["historic:railway"]  == "station"         )  or
        ( keyvalues["historic"]          == "railway_station" )) and
       (  keyvalues["tourism"]           ~= "information"      )) then
      keyvalues["historic"] = "nonspecific"
   end

-- ----------------------------------------------------------------------------
-- Add landuse=military to some military things.
-- ----------------------------------------------------------------------------
   if (( keyvalues["military"] == "office"                             ) or
       ( keyvalues["military"] == "offices"                            ) or
       ( keyvalues["military"] == "barracks"                           ) or
       ( keyvalues["military"] == "naval_base"                         ) or
       ( keyvalues["military"] == "depot"                              ) or
       ( keyvalues["military"] == "registration_and_enlistment_office" ) or
       ( keyvalues["military"] == "checkpoint"                         ) or
       ( keyvalues["hazard"]   == "shooting_range"                     ) or
       ( keyvalues["sport"]    == "shooting"                           ) or
       ( keyvalues["sport"]    == "shooting_range"                     )) then
      keyvalues["landuse"] = "military"
   end

-- ----------------------------------------------------------------------------
-- Nightclubs now have their own icon - do not change to bar.
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- Render concert hall theatres as concert halls with the
-- old OSM Carto "nightclub" icon
-- ----------------------------------------------------------------------------
   if ((( keyvalues["amenity"] == "theatre"      )  and
        ( keyvalues["theatre"] == "concert_hall" )) or
       (  keyvalues["amenity"] == "music_venue"   )) then
      keyvalues["amenity"] = "concert_hall"
   end

-- ----------------------------------------------------------------------------
-- Show natural=embankment as man_made=embankment.
-- Where it is used in UK/IE (which is rarely) it seems to be for single-sided
-- ones.
-- ----------------------------------------------------------------------------
   if ( keyvalues["natural"] == "embankment"   ) then
      keyvalues["man_made"] = "embankment"
   end

-- ----------------------------------------------------------------------------
-- man_made=embankment and natural=cliff displays as a non-sided cliff 
-- (from z13 for cliff, z17 for embankment, direction is important)
-- man_made=levee displays as a two-sided cliff (from z14).
-- Often it's combined with highway though, and that is handled separately.
-- In that case it's passed through to the stylesheet as bridge=levee.
-- embankment handling is asymmetric for railways currently - it's checked
-- before we apply the "man_made=levee" tag, but "bridge=levee" is not applied.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["barrier"]    == "flood_bank"    )  or
        ( keyvalues["barrier"]    == "bund"          )  or
        ( keyvalues["barrier"]    == "mound"         )  or
        ( keyvalues["barrier"]    == "ridge"         )  or
        ( keyvalues["barrier"]    == "embankment"    )  or
        ( keyvalues["man_made"]   == "dyke"          )  or
        ( keyvalues["man_made"]   == "levee"         )  or
        ( keyvalues["embankment"] == "yes"           )  or
        ( keyvalues["barrier"]    == "berm"          )  or
        ( keyvalues["natural"]    == "ridge"         )  or
        ( keyvalues["natural"]    == "earth_bank"    )  or
        ( keyvalues["natural"]    == "arete"         )) and
       (( keyvalues["highway"]    == nil             )  or
        ( keyvalues["highway"]    == "badpathwide"   )  or
        ( keyvalues["highway"]    == "badpathnarrow" )) and
       (  keyvalues["railway"]    == nil              ) and
       (  keyvalues["waterway"]   == nil              )) then
      keyvalues["man_made"] = "levee"
      keyvalues["barrier"] = nil
      keyvalues["embankment"] = nil
   end

-- ----------------------------------------------------------------------------
-- Re the "bridge" check below, we've already changed valid ones to "yes"
-- above.
-- ----------------------------------------------------------------------------
   if (((  keyvalues["barrier"]    == "flood_bank"     )  or
        (  keyvalues["man_made"]   == "dyke"           )  or
        (  keyvalues["man_made"]   == "levee"          )  or
        (  keyvalues["embankment"] == "yes"            )  or
        (  keyvalues["natural"]    == "ridge"          )  or
        (  keyvalues["natural"]    == "arete"          )) and
       ((( keyvalues["highway"]    ~= nil             )   and
         ( keyvalues["highway"]    ~= "badpathwide"   )   and
         ( keyvalues["highway"]    ~= "badpathnarrow" )) or
        (  keyvalues["railway"]    ~= nil              ) or
        (  keyvalues["waterway"]   ~= nil              )) and
       (   keyvalues["bridge"]     ~= "yes"             ) and
       (   keyvalues["tunnel"]     ~= "yes"             )) then
      keyvalues["bridge"] = "levee"
      keyvalues["barrier"] = nil
      keyvalues["man_made"] = nil
      keyvalues["embankment"] = nil
   end

-- ----------------------------------------------------------------------------
-- Assume "natural=hedge" should be "barrier=hedge".
-- ----------------------------------------------------------------------------
   if ( keyvalues["natural"] == "hedge" ) then
      keyvalues["barrier"] = "hedge"
   end

-- ----------------------------------------------------------------------------
-- map "fences that are really hedges" as fences.
-- ----------------------------------------------------------------------------
   if (( keyvalues["barrier"]    == "fence" ) and
       ( keyvalues["fence_type"] == "hedge" )) then
      keyvalues["barrier"] = "hedge"
   end

-- ----------------------------------------------------------------------------
-- At this point let's try and handle hedge tags on other area features as
-- linear hedges.
-- "hedge" can be either a linear or an area feature in this style.
-- "hedgeline" can only be a linear feature in this style.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["barrier"]    == "hedge"             ) and
       (( keyvalues["landuse"]    ~= nil                )  or
        ( keyvalues["natural"]    ~= nil                )  or
        ( keyvalues["leisure"]    ~= nil                )  or
        ( keyvalues["amenity"]    ~= nil                )  or
        ( keyvalues["historic"]   ~= nil                )  or
        ( keyvalues["landcover"]  ~= nil                )  or
        ( keyvalues["tourism"]    ~= nil                )  or
        ( keyvalues["man_made"]   == "wastewater_plant" )  or
        ( keyvalues["surface"]    ~= nil                ))) then
      keyvalues["barrier"] = "hedgeline"
   end

-- ----------------------------------------------------------------------------
-- map "alleged shrubberies" as hedge areas.
-- ----------------------------------------------------------------------------
   if (( keyvalues["natural"] == "shrubbery" ) and
       ( keyvalues["barrier"] == nil         )) then
      keyvalues["natural"] = nil
      keyvalues["barrier"] = "hedge"
      keyvalues["area"] = "yes"
   end

-- ----------------------------------------------------------------------------
-- barrier=horse_jump is used almost exclusively on ways, so map to fence.
-- Also some other barriers.
-- ----------------------------------------------------------------------------
   if (( keyvalues["barrier"] == "horse_jump"     ) or
       ( keyvalues["barrier"] == "traffic_island" ) or
       ( keyvalues["barrier"] == "wire_fence"     ) or
       ( keyvalues["barrier"] == "wood_fence"     ) or
       ( keyvalues["barrier"] == "guard_rail"     ) or
       ( keyvalues["barrier"] == "railing"        )) then
      keyvalues["barrier"] = "fence"
   end

-- ----------------------------------------------------------------------------
-- barrier=ditch; handle as waterway=ditch.
-- ----------------------------------------------------------------------------
   if ( keyvalues["barrier"] == "ditch" ) then
      keyvalues["waterway"] = "ditch"
      keyvalues["barrier"]  = nil
   end

-- ----------------------------------------------------------------------------
-- There's now a barrier=kissing_gate icon.
-- For gates, choose which of the two gate icons to used based on tagging.
-- "sally_port" is mapped to gate largely because of misuse in the data.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["barrier"]   == "turnstile"              )  or
       (  keyvalues["barrier"]   == "full-height_turnstile"  )  or
       (  keyvalues["barrier"]   == "kissing_gate;gate"      )  or
       (( keyvalues["barrier"]   == "gate"                  )   and
        ( keyvalues["gate"]      == "kissing"               ))) then
      keyvalues["barrier"] = "kissing_gate"
   end

-- ----------------------------------------------------------------------------
-- gates
-- ----------------------------------------------------------------------------
   if (( keyvalues["barrier"]   == "gate"                  )  or
       ( keyvalues["barrier"]   == "swing_gate"            )  or
       ( keyvalues["barrier"]   == "footgate"              )  or
       ( keyvalues["barrier"]   == "wicket_gate"           )  or
       ( keyvalues["barrier"]   == "hampshire_gate"        )  or
       ( keyvalues["barrier"]   == "bump_gate"             )  or
       ( keyvalues["barrier"]   == "lych_gate"             )  or
       ( keyvalues["barrier"]   == "lytch_gate"            )  or
       ( keyvalues["barrier"]   == "flood_gate"            )  or
       ( keyvalues["barrier"]   == "sally_port"            )  or
       ( keyvalues["barrier"]   == "pengate"               )  or
       ( keyvalues["barrier"]   == "pengates"              )  or
       ( keyvalues["barrier"]   == "gate;stile"            )  or
       ( keyvalues["barrier"]   == "cattle_grid;gate"      )  or
       ( keyvalues["barrier"]   == "gate;kissing_gate"     )  or
       ( keyvalues["barrier"]   == "pull_apart_gate"       )  or
       ( keyvalues["barrier"]   == "snow_gate"             )) then
      if (( keyvalues["locked"] == "yes"         ) or
          ( keyvalues["locked"] == "permanently" ) or
          ( keyvalues["status"] == "locked"      ) or
          ( keyvalues["gate"]   == "locked"      )) then
         keyvalues["barrier"] = "gate_locked"
      else
         keyvalues["barrier"] = "gate"
      end
   end

-- ----------------------------------------------------------------------------
-- lift gates
-- ----------------------------------------------------------------------------
   if (( keyvalues["barrier"]    == "border_control"   ) or
       ( keyvalues["barrier"]    == "ticket_barrier"   ) or
       ( keyvalues["barrier"]    == "ticket"           ) or
       ( keyvalues["barrier"]    == "security_control" ) or
       ( keyvalues["barrier"]    == "checkpoint"       ) or
       ( keyvalues["industrial"] == "checkpoint"       ) or
       ( keyvalues["barrier"]    == "gatehouse"        )) then
      keyvalues["barrier"] = "lift_gate"
   end

-- ----------------------------------------------------------------------------
-- render barrier=bar as barrier=horse_stile (Norfolk)
-- ----------------------------------------------------------------------------
   if ( keyvalues["barrier"] == "bar" ) then
      keyvalues["barrier"] = "horse_stile"
   end

-- ----------------------------------------------------------------------------
-- render various cycle barrier synonyms
-- ----------------------------------------------------------------------------
   if (( keyvalues["barrier"]   == "chicane"               )  or
       ( keyvalues["barrier"]   == "squeeze"               )  or
       ( keyvalues["barrier"]   == "motorcycle_barrier"    )  or
       ( keyvalues["barrier"]   == "horse_barrier"         )  or
       ( keyvalues["barrier"]   == "a_frame"               )) then
      keyvalues["barrier"] = "cycle_barrier"
   end

-- ----------------------------------------------------------------------------
-- render various synonyms for stile as barrier=stile
-- ----------------------------------------------------------------------------
   if (( keyvalues["barrier"]   == "squeeze_stile"   )  or
       ( keyvalues["barrier"]   == "ramblers_gate"   )  or
       ( keyvalues["barrier"]   == "squeeze_point"   )  or
       ( keyvalues["barrier"]   == "step_over"       )  or
       ( keyvalues["barrier"]   == "stile;gate"      )) then
      keyvalues["barrier"] = "stile"
   end

-- ----------------------------------------------------------------------------
-- Has this stile got a dog gate?
-- ----------------------------------------------------------------------------
   if (( keyvalues["barrier"]  == "stile" ) and
       ( keyvalues["dog_gate"] == "yes"   )) then
      keyvalues["barrier"] = "dog_gate_stile"
   end

-- ----------------------------------------------------------------------------
-- remove barrier=entrance as it's not really a barrier.
-- ----------------------------------------------------------------------------
   if ( keyvalues["barrier"]   == "entrance" ) then
      keyvalues["barrier"] = nil
   end

-- ----------------------------------------------------------------------------
-- Render main entrances
-- Note that "railway=train_station_entrance" isn't shown as a subway entrance.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["entrance"]         == "main"                   )  or
        ( keyvalues["building"]         == "entrance"               )  or
        ( keyvalues["entrance"]         == "entrance"               )  or
        ( keyvalues["public_transport"] == "entrance"               )  or
        ( keyvalues["railway"]          == "entrance"               )  or
        ( keyvalues["railway"]          == "train_station_entrance" )  or
        ( keyvalues["school"]           == "entrance"               )) and
       (  keyvalues["amenity"]          == nil                       ) and
       (  keyvalues["barrier"]          == nil                       ) and
       (  keyvalues["building"]         == nil                       ) and
       (  keyvalues["craft"]            == nil                       ) and
       (  keyvalues["highway"]          == nil                       ) and
       (  keyvalues["office"]           == nil                       ) and
       (  keyvalues["shop"]             == nil                       ) and
       (  keyvalues["tourism"]          == nil                       )) then
      keyvalues["amenity"] = "entrancemain"
   end

-- ----------------------------------------------------------------------------
-- natural=tree_row was added to the standard style file after my version.
-- I'm not convinced that it makes sense to distinguish from hedge, so I'll
-- just display as hedge.
-- ----------------------------------------------------------------------------
   if ( keyvalues["natural"]   == "tree_row" ) then
      keyvalues["barrier"] = "hedgeline"
   end

-- ----------------------------------------------------------------------------
-- Render castle_wall as city_wall
-- ----------------------------------------------------------------------------
   if (( keyvalues["barrier"]   == "wall"        )  and
       ( keyvalues["wall"]      == "castle_wall" )) then
      keyvalues["historic"] = "citywalls"
   end

-- ----------------------------------------------------------------------------
-- Render lines on sports pitches
-- ----------------------------------------------------------------------------
   if ( keyvalues["pitch"] == "line" ) then
      keyvalues["barrier"] = "pitchline"
   end

-- ----------------------------------------------------------------------------
-- Climbing features (boulders, stones, etc.)
-- Deliberately only use this for outdoor features that would not otherwise
-- display, so not cliffs etc.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["sport"]    == "climbing"            )  or
        ( keyvalues["sport"]    == "climbing;bouldering" )  or
        ( keyvalues["climbing"] == "boulder"             )) and
       (  keyvalues["natural"]  ~= "hill"           ) and
       (  keyvalues["natural"]  ~= "peak"           ) and
       (  keyvalues["natural"]  ~= "cliff"          ) and
       (  keyvalues["leisure"]  ~= "sports_centre"  ) and
       (  keyvalues["leisure"]  ~= "climbing_wall"  ) and
       (  keyvalues["shop"]     ~= "sports"         ) and
       (  keyvalues["tourism"]  ~= "attraction"     ) and
       (  keyvalues["building"] == nil              ) and
       (  keyvalues["man_made"] ~= "tower"          ) and
       (  keyvalues["barrier"]  ~= "wall"           ) and
       (  keyvalues["amenity"]  ~= "pitch_climbing" )) then
      keyvalues["natural"] = "climbing"
   end

-- ----------------------------------------------------------------------------
-- Big peaks and big prominent peaks
-- ----------------------------------------------------------------------------
   if ((  keyvalues["natural"]              == "peak"     ) and
       (( tonumber(keyvalues["ele"]) or 0 ) >  914        )) then
      if (( tonumber(keyvalues["prominence"]) or 0 ) == 0 ) then
         if ( keyvalues["munro"] == "yes" ) then
            keyvalues["prominence"] = "0"
         else
            keyvalues["prominence"] = keyvalues["ele"]
	 end
      end
      if (( tonumber(keyvalues["prominence"]) or 0 ) >  500 ) then
         keyvalues["natural"] = "bigprompeak"
      else
         keyvalues["natural"] = "bigpeak"
      end
   end

-- ----------------------------------------------------------------------------
-- natural=fell is used for all sorts of things, but render as heath, except
-- where someone's mapped it on a footpath.
-- ----------------------------------------------------------------------------
   if ( keyvalues["natural"] == "fell" ) then
      if ( keyvalues["highway"] == nil ) then
         keyvalues["natural"] = "heath"
      else
         keyvalues["natural"] = nil
      end
   end

-- ----------------------------------------------------------------------------
-- Do show loungers as benches.
-- ----------------------------------------------------------------------------
   if ( keyvalues["amenity"] == "lounger" ) then
      keyvalues["amenity"] = "bench"
   end

-- ----------------------------------------------------------------------------
-- Don't show "standing benches" as benches.
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "bench"          ) and
       ( keyvalues["bench"]   == "stand_up_bench" )) then
      keyvalues["amenity"] = nil
   end

-- ----------------------------------------------------------------------------
-- Get rid of landuse=conservation if we can.  It's a bit of a special case;
-- it has a label like grass but no green fill.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["landuse"]  == "conservation"  ) and
       (( keyvalues["historic"] ~= nil            )  or
        ( keyvalues["leisure"]  ~= nil            )  or
        ( keyvalues["natural"]  ~= nil            ))) then
      keyvalues["landuse"] = nil
   end

-- ----------------------------------------------------------------------------
-- "wayside_shrine" and various memorial crosses.
-- ----------------------------------------------------------------------------
   if ((   keyvalues["historic"]   == "wayside_shrine"   ) or
       ((  keyvalues["historic"]   == "memorial"        )  and
        (( keyvalues["memorial"]   == "mercat_cross"   )   or
         ( keyvalues["memorial"]   == "cross"          )   or
         ( keyvalues["memorial"]   == "celtic_cross"   )   or
         ( keyvalues["memorial"]   == "cross;stone"    )))) then
      keyvalues["historic"] = "memorialcross"
   end

   if (( keyvalues["historic"]   == "memorial"     ) and
       ( keyvalues["memorial"]   == "war_memorial" )) then
      keyvalues["historic"] = "warmemorial"
   end

   if ((  keyvalues["historic"]      == "memorial"     ) and
       (( keyvalues["memorial"]      == "plaque"      )  or
        ( keyvalues["memorial"]      == "blue_plaque" )  or
        ( keyvalues["memorial:type"] == "plaque"      ))) then
      keyvalues["historic"] = "memorialplaque"
   end

   if ((  keyvalues["historic"]   == "memorial"         ) and
       (( keyvalues["memorial"]   == "pavement plaque" )  or
        ( keyvalues["memorial"]   == "pavement_plaque" ))) then
      keyvalues["historic"] = "memorialpavementplaque"
   end

   if ((  keyvalues["historic"]      == "memorial"  ) and
       (( keyvalues["memorial"]      == "statue"   )  or
        ( keyvalues["memorial:type"] == "statue"   ))) then
      keyvalues["historic"] = "memorialstatue"
   end

   if (( keyvalues["historic"]   == "memorial"    ) and
       ( keyvalues["memorial"]   == "sculpture"   )) then
      keyvalues["historic"] = "memorialsculpture"
   end

   if (( keyvalues["historic"]   == "memorial"    ) and
       ( keyvalues["memorial"]   == "stone"       )) then
      keyvalues["historic"] = "memorialstone"
   end

-- ----------------------------------------------------------------------------
-- Ogham stones mapped without other tags
-- ----------------------------------------------------------------------------
   if ( keyvalues["historic"]   == "ogham_stone" ) then
      keyvalues["historic"] = "oghamstone"
   end

-- ----------------------------------------------------------------------------
-- Stones that are not boundary stones.
-- Note that "marker=boundary_stone" are handled elsewhere.
-- ----------------------------------------------------------------------------
   if (( keyvalues["marker"]   == "stone"          ) or
       ( keyvalues["natural"]  == "stone"          ) or
       ( keyvalues["man_made"] == "stone"          ) or
       ( keyvalues["man_made"] == "standing_stone" )) then
      keyvalues["historic"] = "naturalstone"

      append_inscription(keyvalues)
   end

-- ----------------------------------------------------------------------------
-- stones and standing stones
-- The latter is intended to look proper ancient history; 
-- the former more recent,
-- See also historic=archaeological_site, especially megalith, below
-- ----------------------------------------------------------------------------
   if (( keyvalues["historic"] == "stone"         ) or
       ( keyvalues["historic"] == "bullaun_stone" )) then
      keyvalues["historic"] = "historicstone"
   end

   if ( keyvalues["historic"]   == "standing_stone" ) then
      keyvalues["historic"] = "historicstandingstone"
   end

-- ----------------------------------------------------------------------------
-- Show earthworks as archaeological rather than historic.
-- ----------------------------------------------------------------------------
   if ( keyvalues["historic"] == "earthworks"        ) then
      keyvalues["historic"] = "archaeological_site"
   end

-- ----------------------------------------------------------------------------
-- archaeological sites
--
-- The subtag of archaeological_site was traditionally site_type, but after
-- some tagfiddling to and fro was then both archaeological_site and site_type
-- and then (July 2023) just archaeological_site; I handle both.
--
-- If something is tagged as both an archaeological site and a place or a 
-- tourist attraction, lose the other tag.
-- Add historic landuse if there isn't already something 
-- that would set an area fill such as landuse or natural.
--
-- Then handle different types of archaeological sites.
-- fortification
-- tumulus
--
-- megalith / standing stone
-- The default icon for a megalith / standing stone is one standing stone.
-- Stone circles are shown as such 
-- Some groups of stones are shown with two stones.
-- ----------------------------------------------------------------------------
   if ( keyvalues["historic"] == "archaeological_site" ) then
      keyvalues["place"] = nil
      keyvalues["tourism"] = nil

      if (( keyvalues["landuse"]               == nil      ) and
          ( keyvalues["leisure"]               == nil      ) and
          ( keyvalues["natural"]               == nil      )  and
          ( keyvalues["historic:civilization"] ~= "modern" )) then
         keyvalues["landuse"] = "historic"
      end

      if (( keyvalues["archaeological_site"] == "fortification" ) or 
          ( keyvalues["site_type"]           == "fortification" )) then
-- ----------------------------------------------------------------------------
-- Is the fortification a ringfort?
-- There are 9k of them in Ireland
-- ----------------------------------------------------------------------------
         if ( keyvalues["fortification_type"] == "ringfort" ) then
            keyvalues["historic"] = "historicringfort"
         else
-- ----------------------------------------------------------------------------
-- Is the fortification a hill fort (either spelling)?
-- Confusingly, some of these are mapped as fortification_type and some as
-- archaeological_site.
-- Also look for "hilltop_enclosure" here - see e.g. 
-- https://www.openstreetmap.org/changeset/145424438 and
-- comments in https://www.openstreetmap.org/changeset/145424213 .
-- ----------------------------------------------------------------------------
            if (( keyvalues["fortification_type"] == "hill_fort"          ) or
                ( keyvalues["fortification_type"] == "hillfort"           ) or
                ( keyvalues["fortification_type"] == "hilltop_enclosure"  )) then
               keyvalues["historic"] = "historichillfort"
            else
-- ----------------------------------------------------------------------------
-- Is the fortification a motte?
-- ----------------------------------------------------------------------------
               if (( keyvalues["fortification_type"] == "motte"             ) or
                   ( keyvalues["fortification_type"] == "motte_and_bailey"  )) then
                  keyvalues["historic"] = "historicarchmotte"
               else
-- ----------------------------------------------------------------------------
-- Is the fortification a castle?
-- Confusingly, some of these are mapped as fortification_type and some as
-- archaeological_site.
-- ----------------------------------------------------------------------------
                  if ( keyvalues["fortification_type"] == "castle" ) then
                     keyvalues["historic"] = "historicarchcastle"
                  else
-- ----------------------------------------------------------------------------
-- Is the fortification a promontory fort?
-- ----------------------------------------------------------------------------
                     if ( keyvalues["fortification_type"] == "promontory_fort" ) then
                        keyvalues["historic"] = "historicpromontoryfort"
                     else
-- ----------------------------------------------------------------------------
-- Show as a generic fortification
-- ----------------------------------------------------------------------------
                        keyvalues["historic"] = "historicfortification"
                     end  -- promontory fort
                  end  -- castle
               end  -- motte
            end  -- hill_fort
         end  -- ringfort
      else
-- ----------------------------------------------------------------------------
-- Not a fortification.  Check for tumulus
-- ----------------------------------------------------------------------------
         if ((  keyvalues["archaeological_site"] == "tumulus"  ) or 
             (  keyvalues["site_type"]           == "tumulus"  ) or
             (( keyvalues["archaeological_site"] == "tomb"    )  and
              ( keyvalues["tomb"]                == "tumulus" ))) then
            keyvalues["historic"] = "historictumulus"
         else
-- ----------------------------------------------------------------------------
-- Not a fortification or tumulus.  Check for megalith or standing stone.
-- ----------------------------------------------------------------------------
            if (( keyvalues["archaeological_site"] == "megalith"       ) or 
                ( keyvalues["site_type"]           == "megalith"       ) or
                ( keyvalues["archaeological_site"] == "standing_stone" ) or 
                ( keyvalues["site_type"]           == "standing_stone" )) then
               if (( keyvalues["megalith_type"] == "stone_circle" ) or
                   ( keyvalues["megalith_type"] == "ring_cairn"   ) or
                   ( keyvalues["megalith_type"] == "henge"        )) then
                  keyvalues["historic"] = "historicstonecircle"
               else
-- ----------------------------------------------------------------------------
-- We have a megalith or standing stone. Check megalith_type for dolmen etc.
-- ----------------------------------------------------------------------------
                  if (( keyvalues["megalith_type"] == "dolmen"          ) or
                      ( keyvalues["megalith_type"] == "long_barrow"     ) or
                      ( keyvalues["megalith_type"] == "passage_grave"   ) or
                      ( keyvalues["megalith_type"] == "court_tomb"      ) or
                      ( keyvalues["megalith_type"] == "cist"            ) or
                      ( keyvalues["megalith_type"] == "wedge_tomb"      ) or
                      ( keyvalues["megalith_type"] == "tholos"          ) or
                      ( keyvalues["megalith_type"] == "chamber"         ) or
                      ( keyvalues["megalith_type"] == "cairn"           ) or
                      ( keyvalues["megalith_type"] == "round_barrow"    ) or
                      ( keyvalues["megalith_type"] == "gallery_grave"   ) or
                      ( keyvalues["megalith_type"] == "tomb"            ) or
                      ( keyvalues["megalith_type"] == "chambered_cairn" ) or
                      ( keyvalues["megalith_type"] == "chamber_cairn"   ) or
                      ( keyvalues["megalith_type"] == "portal_tomb"     )) then
                     keyvalues["historic"] = "historicmegalithtomb"
                  else
-- ----------------------------------------------------------------------------
-- We have a megalith or standing stone. Check megalith_type for stone_row
-- ----------------------------------------------------------------------------
                     if (( keyvalues["megalith_type"] == "alignment"  ) or
                         ( keyvalues["megalith_type"] == "stone_row"  ) or
                         ( keyvalues["megalith_type"] == "stone_line" )) then
                           keyvalues["historic"] = "historicstonerow"
                     else
-- ----------------------------------------------------------------------------
-- We have a megalith or standing stone, but megalith_type says it is not a 
-- dolmen etc., stone circle or stone row.  
-- Just use the normal standing stone icon.
-- ----------------------------------------------------------------------------
                        keyvalues["historic"] = "historicstandingstone"
                     end  -- if alignment
                  end  -- if dolmen
               end  -- if stone circle
            else
-- ----------------------------------------------------------------------------
-- Not a fortification, tumulus, megalith or standing stone.
-- Check for hill fort (either spelling) or "hilltop_enclosure"
-- (see https://www.openstreetmap.org/changeset/145424213 )
-- ----------------------------------------------------------------------------
               if (( keyvalues["archaeological_site"] == "hill_fort"         ) or
                   ( keyvalues["site_type"]           == "hill_fort"         ) or
                   ( keyvalues["archaeological_site"] == "hillfort"          ) or
                   ( keyvalues["site_type"]           == "hillfort"          ) or
                   ( keyvalues["archaeological_site"] == "hilltop_enclosure" )) then
                  keyvalues["historic"] = "historichillfort"
               else
-- ----------------------------------------------------------------------------
-- Check for castle
-- Confusingly, some of these are mapped as fortification_type and some as
-- archaeological_site.
-- ----------------------------------------------------------------------------
                  if ( keyvalues["archaeological_site"] == "castle" ) then
                     keyvalues["historic"] = "historicarchcastle"
                  else
-- ----------------------------------------------------------------------------
-- Is the archaeological site a crannog?
-- ----------------------------------------------------------------------------
                     if ( keyvalues["archaeological_site"] == "crannog" ) then
                        keyvalues["historic"] = "historiccrannog"
                     else
                        if (( keyvalues["archaeological_site"] == "settlement" ) and
                            ( keyvalues["fortification_type"]  == "ringfort"   )) then
                           keyvalues["historic"] = "historicringfort"
-- ----------------------------------------------------------------------------
-- There's no code an an "else" here, just this comment:
--                      else
--
-- If set, archaeological_site is not fortification, tumulus, 
-- megalith / standing stone, hill fort, castle or settlement that is also 
-- a ringfort.  Most will not have archaeological_site set.
-- The standard icon for historic=archaeological_site will be used in the .mss
-- ----------------------------------------------------------------------------
                        end -- settlement that is also ringfort
                     end  -- crannog
                  end  -- if castle
               end  -- if hill fort
            end  -- if megalith
         end  -- if tumulus
      end  -- if fortification
   end  -- if archaeological site

   if ( keyvalues["historic"]   == "rune_stone" ) then
      keyvalues["historic"] = "runestone"
   end

   if ( keyvalues["place_of_worship"]   == "mass_rock" ) then
      keyvalues["amenity"] = nil
      keyvalues["historic"] = "massrock"
   end

-- ----------------------------------------------------------------------------
-- Memorial plates
-- ----------------------------------------------------------------------------
   if ((  keyvalues["historic"]      == "memorial"  ) and
       (( keyvalues["memorial"]      == "plate"    )  or
        ( keyvalues["memorial:type"] == "plate"    ))) then
      keyvalues["historic"] = "memorialplate"
   end

-- ----------------------------------------------------------------------------
-- Memorial benches
-- ----------------------------------------------------------------------------
   if (( keyvalues["historic"]   == "memorial"    ) and
       ( keyvalues["memorial"]   == "bench"       )) then
      keyvalues["historic"] = "memorialbench"
   end

-- ----------------------------------------------------------------------------
-- Historic graves, and memorial graves and graveyards
-- ----------------------------------------------------------------------------
   if ((   keyvalues["historic"]   == "grave"         ) or
       ((  keyvalues["historic"]   == "memorial"     )  and
        (( keyvalues["memorial"]   == "grave"       )   or
         ( keyvalues["memorial"]   == "graveyard"   )))) then
      keyvalues["historic"] = "memorialgrave"
   end

-- ----------------------------------------------------------------------------
-- Memorial obelisks
-- ----------------------------------------------------------------------------
   if ((   keyvalues["man_made"]      == "obelisk"     ) or
       (   keyvalues["landmark"]      == "obelisk"     ) or
       ((  keyvalues["historic"]      == "memorial"   ) and
        (( keyvalues["memorial"]      == "obelisk"   )  or
         ( keyvalues["memorial:type"] == "obelisk"   )))) then
      keyvalues["historic"] = "memorialobelisk"
   end

-- ----------------------------------------------------------------------------
-- Other memorials go straight through, even though there are some area ones.
-- We don't add "landuse=historic", even if no other landuse or natural tags
-- are set, because sometimes these overlay other landuse, such as cemetaries.
-- ----------------------------------------------------------------------------
--   if ( keyvalues["historic"] == "memorial" ) then
--      if (( keyvalues["landuse"] == nil ) and
--          ( keyvalues["leisure"] == nil ) and
--          ( keyvalues["natural"] == nil )) then
--         keyvalues["landuse"] = "historic"
--      end
--   end
   
-- ----------------------------------------------------------------------------
-- Render shop=newsagent as shop=convenience
-- It's near enough in meaning I think.  Likewise kiosk (bit of a stretch,
-- but nearer than anything else)
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]   == "newsagent"           ) or
       ( keyvalues["shop"]   == "kiosk"               ) or
       ( keyvalues["shop"]   == "forecourt"           ) or
       ( keyvalues["shop"]   == "food"                ) or
       ( keyvalues["shop"]   == "grocery"             ) or
       ( keyvalues["shop"]   == "grocer"              ) or
       ( keyvalues["shop"]   == "frozen_food"         ) or
       ( keyvalues["shop"]   == "convenience;alcohol" )) then
      keyvalues["shop"] = "convenience"
   end

-- ----------------------------------------------------------------------------
-- Render "eco" shops with their own icons
-- ----------------------------------------------------------------------------
   if ((   keyvalues["shop"]               == "zero_waste"          ) or
       (   keyvalues["shop"]               == "eco_refill"          ) or
       (   keyvalues["shop"]               == "refill"              ) or
       ((( keyvalues["shop"]               == "convenience"        )  or
         ( keyvalues["shop"]               == "general"            )  or
         ( keyvalues["shop"]               == "grocer"             )  or
         ( keyvalues["shop"]               == "grocery"            )  or
         ( keyvalues["shop"]               == "yes"                )  or
         ( keyvalues["shop"]               == "food"               )) and
        (( keyvalues["zero_waste"]         == "yes"                )  or
         ( keyvalues["zero_waste"]         == "only"               )  or
         ( keyvalues["bulk_purchase"]      == "yes"                )  or
         ( keyvalues["bulk_purchase"]      == "only"               )  or
         ( keyvalues["reusable_packaging"] == "yes"                )))) then
      keyvalues["shop"] = "ecoconv"
   end

   if ((  keyvalues["shop"]               == "supermarket"         ) and
       (( keyvalues["zero_waste"]         == "yes"                )  or
        ( keyvalues["zero_waste"]         == "only"               )  or
        ( keyvalues["bulk_purchase"]      == "yes"                )  or
        ( keyvalues["bulk_purchase"]      == "only"               )  or
        ( keyvalues["reusable_packaging"] == "yes"                ))) then
      keyvalues["shop"] = "ecosupermarket"
   end

   if ((  keyvalues["shop"]               == "greengrocer"         ) and
       (( keyvalues["zero_waste"]         == "yes"                )  or
        ( keyvalues["zero_waste"]         == "only"               )  or
        ( keyvalues["bulk_purchase"]      == "yes"                )  or
        ( keyvalues["bulk_purchase"]      == "only"               )  or
        ( keyvalues["reusable_packaging"] == "yes"                ))) then
      keyvalues["shop"] = "ecogreengrocer"
   end

-- ----------------------------------------------------------------------------
-- Render shop=variety etc. with a "pound" icon.  "variety_store" is the most 
-- popular tagging but "variety" is also used.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]   == "variety"       ) or
       ( keyvalues["shop"]   == "pound"         ) or
       ( keyvalues["shop"]   == "thrift"        ) or
       ( keyvalues["shop"]   == "variety_store" )) then
      keyvalues["shop"] = "discount"
   end

-- ----------------------------------------------------------------------------
-- shoe shops
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"] == "shoes"        ) or
       ( keyvalues["shop"] == "footwear"     )) then
      keyvalues["shop"] = "shoes"
   end

-- ----------------------------------------------------------------------------
-- "clothes" consolidation.  "baby_goods" is here because there will surely
-- be some clothes there!
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"] == "fashion"      ) or
       ( keyvalues["shop"] == "boutique"     ) or
       ( keyvalues["shop"] == "vintage"      ) or
       ( keyvalues["shop"] == "bridal"       ) or
       ( keyvalues["shop"] == "wedding"      ) or
       ( keyvalues["shop"] == "baby_goods"   ) or
       ( keyvalues["shop"] == "baby"         ) or
       ( keyvalues["shop"] == "dance"        ) or
       ( keyvalues["shop"] == "clothes_hire" ) or
       ( keyvalues["shop"] == "clothing"     ) or
       ( keyvalues["shop"] == "hat"          ) or
       ( keyvalues["shop"] == "hats"         ) or
       ( keyvalues["shop"] == "wigs"         )) then
      keyvalues["shop"] = "clothes"
   end

-- ----------------------------------------------------------------------------
-- "electronics"
-- Looking at the tagging of shop=electronics, there's a fair crossover with 
-- electrical.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "electronics"             ) or
       ( keyvalues["craft"]   == "electronics_repair"      ) or
       ( keyvalues["shop"]    == "electronics_repair"      ) or
       ( keyvalues["amenity"] == "electronics_repair"      )) then
      keyvalues["shop"] = "electronics"
   end

-- ----------------------------------------------------------------------------
-- "electrical" consolidation
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "radiotechnics"           ) or
       ( keyvalues["shop"]    == "appliance"               ) or
       ( keyvalues["shop"]    == "electrical_supplies"     ) or
       ( keyvalues["shop"]    == "electrical_repair"       ) or
       ( keyvalues["shop"]    == "tv_repair"               ) or
       ( keyvalues["shop"]    == "gadget"                  ) or
       ( keyvalues["shop"]    == "appliances"              ) or
       ( keyvalues["shop"]    == "vacuum_cleaner"          ) or
       ( keyvalues["shop"]    == "sewing_machines"         ) or
       ( keyvalues["shop"]    == "domestic_appliances"     ) or
       ( keyvalues["shop"]    == "white_goods"             ) or
       ( keyvalues["shop"]    == "electricals"             ) or
       ( keyvalues["trade"]   == "electrical"              ) or
       ( keyvalues["name"]    == "City Electrical Factors" )) then
      keyvalues["shop"] = "electrical"
   end

-- ----------------------------------------------------------------------------
-- Show industrial=distributor as offices.
-- This sounds odd, but matches how this is used UK/IE
-- ----------------------------------------------------------------------------
   if (( keyvalues["industrial"] == "distributor" ) and
       ( keyvalues["office"]     == nil           )) then
      keyvalues["office"] = "yes"
   end

-- ----------------------------------------------------------------------------
-- "funeral" consolidation.  All of these spellings currently in use in the UK
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "funeral"             ) or
       ( keyvalues["office"]  == "funeral_director"    ) or
       ( keyvalues["office"]  == "funeral_directors"   ) or
       ( keyvalues["amenity"] == "funeral"             ) or
       ( keyvalues["amenity"] == "funeral_directors"   ) or
       ( keyvalues["amenity"] == "undertaker"          )) then
      keyvalues["shop"] = "funeral_directors"
   end

-- ----------------------------------------------------------------------------
-- "jewellery" consolidation.  "jewelry" is in the database, until recently
-- "jewellery" was too.  The style handles "jewellery", hence the change here.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]  == "jewelry"                 ) or
       ( keyvalues["shop"]  == "jewelry;pawnbroker"      ) or
       ( keyvalues["shop"]  == "yes;jewelry;e-cigarette" ) or
       ( keyvalues["shop"]  == "jewelry;sunglasses"      ) or
       ( keyvalues["shop"]  == "yes;jewelry"             ) or
       ( keyvalues["shop"]  == "jewelry;art;crafts"      ) or
       ( keyvalues["shop"]  == "jewelry;fabric"          ) or
       ( keyvalues["shop"]  == "watch"                   ) or
       ( keyvalues["shop"]  == "watches"                 ) or
       ( keyvalues["craft"] == "jeweller"                ) or
       ( keyvalues["craft"] == "jewellery_repair"        ) or
       ( keyvalues["craft"] == "engraver"                )) then
      keyvalues["shop"]  = "jewellery"
      keyvalues["craft"] = nil
   end

-- ----------------------------------------------------------------------------
-- "department_store" consolidation.
-- ----------------------------------------------------------------------------
   if ( keyvalues["shop"] == "department" ) then
      keyvalues["shop"] = "department_store"
   end

-- ----------------------------------------------------------------------------
-- "catalogue shop" consolidation.
-- ----------------------------------------------------------------------------
   if ( keyvalues["shop"] == "outpost"  ) then
      keyvalues["shop"] = "catalogue"
   end

-- ----------------------------------------------------------------------------
-- man_made=flagpole
-- Non-MOD ones are passed straight through to be rendered.  MOD ones are
-- changed to flagpole_red so that they can be rendered differently.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["man_made"] == "flagpole"             )  and
       (( keyvalues["operator"] == "Ministry of Defence" )   or
        ( keyvalues["operator"] == "MOD"                 ))) then
      keyvalues["man_made"] = "flagpole_red"
      keyvalues["operator"] = nil
   end

-- ----------------------------------------------------------------------------
-- Windsocks
-- ----------------------------------------------------------------------------
   if (( keyvalues["aeroway"]  == "windsock" ) or
       ( keyvalues["landmark"] == "windsock" )) then
      keyvalues["man_made"] = "windsock"
   end
   
-- ----------------------------------------------------------------------------
-- Before potentially using brand or operator as a bracketed suffix after the
-- name, explicitly exclude some "non-brands" - "Independent", etc.
-- ----------------------------------------------------------------------------
   if (( keyvalues["brand"]   == "Independant"            ) or
       ( keyvalues["brand"]   == "Independent"            ) or
       ( keyvalues["brand"]   == "Traditional Free House" ) or
       ( keyvalues["brand"]   == "independant"            ) or
       ( keyvalues["brand"]   == "independent"            )) then
      keyvalues["brand"] = nil
   end

   if (( keyvalues["operator"]   == "(free_house)"            ) or
       ( keyvalues["operator"]   == "Free Brewery"            ) or
       ( keyvalues["operator"]   == "Free House"              ) or
       ( keyvalues["operator"]   == "Free house"              ) or
       ( keyvalues["operator"]   == "Free"                    ) or
       ( keyvalues["operator"]   == "Freehold"                ) or
       ( keyvalues["operator"]   == "Freehouse"               ) or
       ( keyvalues["operator"]   == "Independant"             ) or
       ( keyvalues["operator"]   == "Independent"             ) or
       ( keyvalues["operator"]   == "free house"              ) or
       ( keyvalues["operator"]   == "free"                    ) or
       ( keyvalues["operator"]   == "free_house"              ) or
       ( keyvalues["operator"]   == "freehouse"               ) or
       ( keyvalues["operator"]   == "independant"             ) or
       ( keyvalues["operator"]   == "independent free house"  ) or
       ( keyvalues["operator"]   == "independent"             )) then
      keyvalues["operator"] = nil
   end

-- ----------------------------------------------------------------------------
-- Handle these as bicycle_rental:
-- ----------------------------------------------------------------------------
   if ( keyvalues["amenity"] == "bicycle_parking;bicycle_rental" ) then
      keyvalues["amenity"] = "bicycle_rental"
   end

-- ----------------------------------------------------------------------------
-- If no name use brand or operator on amenity=fuel, among others.  
-- If there is brand or operator, use that with name.
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"]   == "atm"              ) or
       ( keyvalues["amenity"]   == "fuel"             ) or
       ( keyvalues["amenity"]   == "fuel_e"           ) or
       ( keyvalues["amenity"]   == "fuel_h"           ) or
       ( keyvalues["amenity"]   == "fuel_l"           ) or
       ( keyvalues["amenity"]   == "fuel_w"           ) or
       ( keyvalues["amenity"]   == "charging_station" ) or
       ( keyvalues["amenity"]   == "bicycle_rental"   ) or
       ( keyvalues["amenity"]   == "scooter_rental"   ) or
       ( keyvalues["amenity"]   == "vending_machine"   ) or
       (( keyvalues["amenity"]  ~= nil                )  and
        ( string.match( keyvalues["amenity"], "pub_" ))) or
       ( keyvalues["amenity"]   == "pub"               ) or
       ( keyvalues["amenity"]   == "cafe"             ) or
       ( keyvalues["amenity"]   == "cafe_dld"         ) or
       ( keyvalues["amenity"]   == "cafe_dnd"         ) or
       ( keyvalues["amenity"]   == "cafe_dyd"         ) or
       ( keyvalues["amenity"]   == "cafe_ydd"         ) or
       ( keyvalues["amenity"]   == "cafe_yld"         ) or
       ( keyvalues["amenity"]   == "cafe_ynd"         ) or
       ( keyvalues["amenity"]   == "cafe_yyd"         ) or
       ( keyvalues["amenity"]   == "restaurant"       ) or
       ( keyvalues["amenity"]   == "restaccomm"       ) or
       ( keyvalues["amenity"]   == "doctors"          ) or
       ( keyvalues["amenity"]   == "pharmacy"         ) or
       ( keyvalues["amenity"]   == "pharmacy_l"       ) or
       ( keyvalues["amenity"]   == "pharmacy_n"       ) or
       ( keyvalues["amenity"]   == "pharmacy_y"       ) or
       ( keyvalues["amenity"]   == "parcel_locker"    ) or
       ( keyvalues["amenity"]   == "veterinary"       ) or
       ( keyvalues["amenity"]   == "animal_boarding"  ) or
       ( keyvalues["amenity"]   == "cattery"          ) or
       ( keyvalues["amenity"]   == "kennels"          ) or
       ( keyvalues["amenity"]   == "animal_shelter"   ) or
       ( keyvalues["animal"]    == "shelter"          ) or
       ( keyvalues["craft"]      ~= nil               ) or
       ( keyvalues["emergency"]  ~= nil               ) or
       ( keyvalues["industrial"] ~= nil               ) or
       ( keyvalues["man_made"]   ~= nil               ) or
       ( keyvalues["office"]     ~= nil               ) or
       ( keyvalues["shop"]       ~= nil               ) or
       ( keyvalues["tourism"]    == "hotel"           ) or
       ( keyvalues["military"]   == "barracks"        )) then
      if ( keyvalues["name"] == nil ) then
         if ( keyvalues["brand"] ~= nil ) then
            keyvalues["name"] = keyvalues["brand"]
            keyvalues["brand"] = nil
         else
            if ( keyvalues["operator"] ~= nil ) then
               keyvalues["name"] = keyvalues["operator"]
               keyvalues["operator"] = nil
            end
         end
      else
         if (( keyvalues["brand"] ~= nil                                ) and
             ( not string.match( keyvalues["name"], keyvalues["brand"] )) and
             ( not string.match( keyvalues["brand"], keyvalues["name"] ))) then
            keyvalues["name"] = keyvalues["name"] .. " (" .. keyvalues["brand"] .. ")"
            keyvalues["brand"] = nil
	 else
            if (( keyvalues["operator"] ~= nil                                ) and
                ( not string.match( keyvalues["name"], keyvalues["operator"] )) and
                ( not string.match( keyvalues["operator"], keyvalues["name"] ))) then
               keyvalues["name"] = keyvalues["name"] .. " (" .. keyvalues["operator"] .. ")"
               keyvalues["operator"] = nil
            end
         end
      end
   end

-- ----------------------------------------------------------------------------
-- office=estate_agent.  There's now an icon for "shop", so use that.
-- Also letting_agent
-- ----------------------------------------------------------------------------
   if (( keyvalues["office"]  == "estate_agent"      ) or
       ( keyvalues["amenity"] == "estate_agent"      ) or
       ( keyvalues["shop"]    == "letting_agent"     ) or
       ( keyvalues["shop"]    == "council_house"     ) or
       ( keyvalues["office"]  == "letting_agent"     )) then
      keyvalues["shop"] = "estate_agent"
   end

-- ----------------------------------------------------------------------------
-- plant_nursery and lawnmower etc. to garden_centre
-- Add unnamedcommercial landuse to give non-building areas a background.
-- Usage suggests shop=nursery means plant_nursery.
-- ----------------------------------------------------------------------------
   if (( keyvalues["landuse"] == "plant_nursery"              ) or
       ( keyvalues["shop"]    == "plant_nursery"              ) or
       ( keyvalues["shop"]    == "plant_centre"               ) or
       ( keyvalues["shop"]    == "nursery"                    ) or
       ( keyvalues["shop"]    == "lawn_mower"                 ) or
       ( keyvalues["shop"]    == "lawnmowers"                 ) or
       ( keyvalues["shop"]    == "garden_furniture"           ) or
       ( keyvalues["shop"]    == "garden_machinery"           ) or
       ( keyvalues["shop"]    == "gardening"                  ) or
       ( keyvalues["shop"]    == "garden_equipment"           ) or
       ( keyvalues["shop"]    == "garden_tools"               ) or
       ( keyvalues["shop"]    == "garden"                     ) or
       ( keyvalues["shop"]    == "doityourself;garden_centre" ) or
       ( keyvalues["shop"]    == "garden_machines"            )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["shop"]    = "garden_centre"
   end

-- ----------------------------------------------------------------------------
-- "fast_food" consolidation of lesser used tags.  
-- Also render fish and chips etc. with a unique icon.
-- ----------------------------------------------------------------------------
   if ( keyvalues["shop"] == "fast_food" ) then
      keyvalues["amenity"] = "fast_food"
   end

   if ((  keyvalues["amenity"] == "fast_food"                            )  and
       (( keyvalues["cuisine"] == "american"                            )   or
        ( keyvalues["cuisine"] == "argentinian"                         )   or
        ( keyvalues["cuisine"] == "brazilian"                           )   or
        ( keyvalues["cuisine"] == "burger"                              )   or
        ( keyvalues["cuisine"] == "burger;chicken"                      )   or
        ( keyvalues["cuisine"] == "burger;chicken;fish_and_chips;kebab" )   or
        ( keyvalues["cuisine"] == "burger;chicken;indian;kebab;pizza"   )   or
        ( keyvalues["cuisine"] == "burger;chicken;kebab"                )   or
        ( keyvalues["cuisine"] == "burger;chicken;kebab;pizza"          )   or
        ( keyvalues["cuisine"] == "burger;chicken;pizza"                )   or
        ( keyvalues["cuisine"] == "burger;fish_and_chips"               )   or
        ( keyvalues["cuisine"] == "burger;fish_and_chips;kebab;pizza"   )   or
        ( keyvalues["cuisine"] == "burger;indian;kebab;pizza"           )   or
        ( keyvalues["cuisine"] == "burger;kebab"                        )   or
        ( keyvalues["cuisine"] == "burger;kebab;pizza"                  )   or
        ( keyvalues["cuisine"] == "burger;pizza"                        )   or
        ( keyvalues["cuisine"] == "burger;pizza;kebab"                  )   or
        ( keyvalues["cuisine"] == "burger;sandwich"                     )   or
        ( keyvalues["cuisine"] == "diner"                               )   or
        ( keyvalues["cuisine"] == "grill"                               )   or
        ( keyvalues["cuisine"] == "steak_house"                         ))) then
      keyvalues["amenity"] = "fast_food_burger"
   end

   if ((  keyvalues["amenity"] == "fast_food"               )  and
       (( keyvalues["cuisine"] == "chicken"                )   or
        ( keyvalues["cuisine"] == "chicken;burger;pizza"   )   or
        ( keyvalues["cuisine"] == "chicken;fish_and_chips" )   or
        ( keyvalues["cuisine"] == "chicken;grill"          )   or
        ( keyvalues["cuisine"] == "chicken;kebab"          )   or
        ( keyvalues["cuisine"] == "chicken;pizza"          )   or
        ( keyvalues["cuisine"] == "chicken;portuguese"     )   or
        ( keyvalues["cuisine"] == "fried_chicken"          )   or
        ( keyvalues["cuisine"] == "wings"                  ))) then
      keyvalues["amenity"] = "fast_food_chicken"
   end

   if ((  keyvalues["amenity"] == "fast_food"               )  and
       (( keyvalues["cuisine"] == "chinese"                )   or
        ( keyvalues["cuisine"] == "thai"                   )   or
        ( keyvalues["cuisine"] == "chinese;thai"           )   or
        ( keyvalues["cuisine"] == "chinese;thai;malaysian" )   or
        ( keyvalues["cuisine"] == "thai;chinese"           )   or
        ( keyvalues["cuisine"] == "asian"                  )   or
        ( keyvalues["cuisine"] == "japanese"               )   or
        ( keyvalues["cuisine"] == "japanese;sushi"         )   or
        ( keyvalues["cuisine"] == "sushi;japanese"         )   or
        ( keyvalues["cuisine"] == "japanese;korean"        )   or
        ( keyvalues["cuisine"] == "korean;japanese"        )   or
        ( keyvalues["cuisine"] == "vietnamese"             )   or
        ( keyvalues["cuisine"] == "korean"                 )   or
        ( keyvalues["cuisine"] == "ramen"                  )   or
        ( keyvalues["cuisine"] == "noodle"                 )   or
        ( keyvalues["cuisine"] == "noodle;ramen"           )   or
        ( keyvalues["cuisine"] == "malaysian"              )   or
        ( keyvalues["cuisine"] == "malaysian;chinese"      )   or
        ( keyvalues["cuisine"] == "indonesian"             )   or
        ( keyvalues["cuisine"] == "cantonese"              )   or
        ( keyvalues["cuisine"] == "chinese;cantonese"      )   or
        ( keyvalues["cuisine"] == "chinese;asian"          )   or
        ( keyvalues["cuisine"] == "oriental"               )   or
        ( keyvalues["cuisine"] == "chinese;english"        )   or
        ( keyvalues["cuisine"] == "chinese;japanese"       )   or
        ( keyvalues["cuisine"] == "sushi"                  ))) then
      keyvalues["amenity"] = "fast_food_chinese"
   end

   if ((  keyvalues["amenity"] == "fast_food"                  )  and
       (( keyvalues["cuisine"] == "coffee"                    )   or
        ( keyvalues["cuisine"] == "coffee_shop"               )   or
        ( keyvalues["cuisine"] == "coffee_shop;sandwich"      )   or
        ( keyvalues["cuisine"] == "coffee_shop;local"         )   or
        ( keyvalues["cuisine"] == "coffee_shop;regional"      )   or
        ( keyvalues["cuisine"] == "coffee_shop;cake"          )   or
        ( keyvalues["cuisine"] == "coffee_shop;sandwich;cake" )   or
        ( keyvalues["cuisine"] == "coffee_shop;breakfast"     )   or
        ( keyvalues["cuisine"] == "coffee_shop;italian"       )   or
        ( keyvalues["cuisine"] == "cake;coffee_shop"          )   or
        ( keyvalues["cuisine"] == "coffee_shop;ice_cream"     ))) then
      keyvalues["amenity"] = "fast_food_coffee"
   end

   if ((  keyvalues["amenity"] == "fast_food"                          ) and
       (( keyvalues["cuisine"] == "fish_and_chips"                    )  or
        ( keyvalues["cuisine"] == "chinese;fish_and_chips"            )  or
        ( keyvalues["cuisine"] == "fish"                              )  or
        ( keyvalues["cuisine"] == "fish_and_chips;chinese"            )  or
        ( keyvalues["cuisine"] == "fish_and_chips;indian"             )  or
        ( keyvalues["cuisine"] == "fish_and_chips;kebab"              )  or
        ( keyvalues["cuisine"] == "fish_and_chips;pizza;kebab"        )  or
        ( keyvalues["cuisine"] == "fish_and_chips;pizza;burger;kebab" )  or
        ( keyvalues["cuisine"] == "fish_and_chips;pizza"              ))) then
      keyvalues["amenity"] = "fast_food_fish_and_chips"
   end

   if ((( keyvalues["amenity"] == "fast_food"                        )  and
        ( keyvalues["cuisine"] == "ice_cream"                       )   or
        ( keyvalues["cuisine"] == "ice_cream;cake;coffee"           )   or
        ( keyvalues["cuisine"] == "ice_cream;cake;sandwich"         )   or
        ( keyvalues["cuisine"] == "ice_cream;coffee_shop"           )   or
        ( keyvalues["cuisine"] == "ice_cream;coffee;waffle"         )   or
        ( keyvalues["cuisine"] == "ice_cream;donut"                 )   or
        ( keyvalues["cuisine"] == "ice_cream;pizza"                 )   or
        ( keyvalues["cuisine"] == "ice_cream;sandwich"              )   or
        ( keyvalues["cuisine"] == "ice_cream;tea;coffee"            ))  or
       (  keyvalues["shop"]    == "ice_cream"                        )  or
       (  keyvalues["amenity"] == "ice_cream"                        )) then
      keyvalues["amenity"] = "fast_food_ice_cream"
   end

   if ((  keyvalues["amenity"] == "fast_food"            ) and
       (( keyvalues["cuisine"] == "indian"              )  or
        ( keyvalues["cuisine"] == "curry"               )  or
        ( keyvalues["cuisine"] == "nepalese"            )  or
        ( keyvalues["cuisine"] == "nepalese;indian"     )  or
        ( keyvalues["cuisine"] == "indian;nepalese"     )  or
        ( keyvalues["cuisine"] == "bangladeshi"         )  or
        ( keyvalues["cuisine"] == "indian;bangladeshi"  )  or
        ( keyvalues["cuisine"] == "bangladeshi;indian"  )  or
        ( keyvalues["cuisine"] == "indian;curry"        )  or
        ( keyvalues["cuisine"] == "indian;kebab"        )  or
        ( keyvalues["cuisine"] == "indian;kebab;burger" )  or
        ( keyvalues["cuisine"] == "indian;thai"         )  or
        ( keyvalues["cuisine"] == "curry;indian"        )  or
        ( keyvalues["cuisine"] == "pakistani"           )  or
        ( keyvalues["cuisine"] == "indian;pakistani"    )  or
        ( keyvalues["cuisine"] == "tandoori"            )  or
        ( keyvalues["cuisine"] == "afghan"              )  or
        ( keyvalues["cuisine"] == "sri_lankan"          )  or
        ( keyvalues["cuisine"] == "punjabi"             )  or
        ( keyvalues["cuisine"] == "indian;pizza"        ))) then
      keyvalues["amenity"] = "fast_food_indian"
   end

   if ((  keyvalues["amenity"] == "fast_food"             ) and
       (( keyvalues["cuisine"] == "kebab"                )  or
        ( keyvalues["cuisine"] == "kebab;pizza"          )  or
        ( keyvalues["cuisine"] == "kebab;pizza;burger"   )  or
        ( keyvalues["cuisine"] == "kebab;burger;pizza"   )  or
        ( keyvalues["cuisine"] == "kebab;burger;chicken" )  or
        ( keyvalues["cuisine"] == "kebab;burger"         )  or
        ( keyvalues["cuisine"] == "kebab;fish_and_chips" )  or
        ( keyvalues["cuisine"] == "turkish"              ))) then
      keyvalues["amenity"] = "fast_food_kebab"
   end

   if ((  keyvalues["amenity"] == "fast_food"      )  and
       (( keyvalues["cuisine"] == "pasties"       )   or
        ( keyvalues["cuisine"] == "pasty"         )   or
        ( keyvalues["cuisine"] == "cornish_pasty" )   or
        ( keyvalues["cuisine"] == "pie"           )   or
        ( keyvalues["cuisine"] == "pies"          ))) then
      keyvalues["amenity"] = "fast_food_pie"
   end

   if ((  keyvalues["amenity"] == "fast_food"                   )  and
       (( keyvalues["cuisine"] == "italian"                    )   or
        ( keyvalues["cuisine"] == "italian;pizza"              )   or
        ( keyvalues["cuisine"] == "italian_pizza"              )   or
        ( keyvalues["cuisine"] == "mediterranean"              )   or
        ( keyvalues["cuisine"] == "pasta"                      )   or
        ( keyvalues["cuisine"] == "pizza"                      )   or
        ( keyvalues["cuisine"] == "pizza;burger"               )   or
        ( keyvalues["cuisine"] == "pizza;burger;kebab"         )   or
        ( keyvalues["cuisine"] == "pizza;chicken"              )   or
        ( keyvalues["cuisine"] == "pizza;fish_and_chips"       )   or
        ( keyvalues["cuisine"] == "pizza;indian"               )   or
        ( keyvalues["cuisine"] == "pizza;italian"              )   or
        ( keyvalues["cuisine"] == "pizza;kebab"                )   or
        ( keyvalues["cuisine"] == "pizza;kebab;burger"         )   or
        ( keyvalues["cuisine"] == "pizza;kebab;burger;chicken" )   or
        ( keyvalues["cuisine"] == "pizza;kebab;chicken"        )   or
        ( keyvalues["cuisine"] == "pizza;pasta"                ))) then
      keyvalues["amenity"] = "fast_food_pizza"
   end

   if ((  keyvalues["amenity"] == "fast_food"             )  and
       (( keyvalues["cuisine"] == "sandwich"             )   or
        ( keyvalues["cuisine"] == "sandwich;bakery"      )   or
        ( keyvalues["cuisine"] == "sandwich;coffee_shop" ))) then
      keyvalues["amenity"] = "fast_food_sandwich"
   end

-- ----------------------------------------------------------------------------
-- Sundials
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "clock"   )  and
       ( keyvalues["display"] == "sundial" )) then
      keyvalues["amenity"] = "sundial"
   end

-- ----------------------------------------------------------------------------
-- Render shop=hardware stores etc. as shop=doityourself
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "hardware"             ) or
       ( keyvalues["shop"]    == "tool_hire"            ) or
       ( keyvalues["shop"]    == "equipment_hire"       ) or
       ( keyvalues["shop"]    == "tools"                ) or
       ( keyvalues["shop"]    == "hardware_rental"      ) or
       ( keyvalues["shop"]    == "builders_merchant"    ) or
       ( keyvalues["shop"]    == "builders_merchants"   ) or
       ( keyvalues["shop"]    == "timber"               ) or
       ( keyvalues["shop"]    == "fencing"              ) or
       ( keyvalues["shop"]    == "plumbers_merchant"    ) or
       ( keyvalues["shop"]    == "building_supplies"    ) or
       ( keyvalues["shop"]    == "industrial_supplies"  ) or
       ( keyvalues["office"]  == "industrial_supplies"  ) or
       ( keyvalues["shop"]    == "plant_hire"           ) or
       ( keyvalues["amenity"] == "plant_hire;tool_hire" ) or
       ( keyvalues["shop"]    == "signs"                ) or
       ( keyvalues["shop"]    == "sign"                 ) or
       ( keyvalues["shop"]    == "signwriter"           ) or
       ( keyvalues["craft"]   == "signmaker"            ) or
       ( keyvalues["craft"]   == "roofer"               ) or
       ( keyvalues["shop"]    == "roofing"              ) or
       ( keyvalues["craft"]   == "floorer"              ) or
       ( keyvalues["shop"]    == "building_materials"   ) or
       ( keyvalues["craft"]   == "builder"              )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["shop"]    = "doityourself"
      keyvalues["amenity"] = nil
   end

-- ----------------------------------------------------------------------------
-- Consolidate "lenders of last resort" as pawnbroker
-- "money_transfer" and down from there is perhaps a bit of a stretch; 
-- as there is a distinctive pawnbroker icon, so generic is used for those.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"] == "money"              ) or
       ( keyvalues["shop"] == "money_lender"       ) or
       ( keyvalues["shop"] == "loan_shark"         ) or
       ( keyvalues["shop"] == "cash"               )) then
      keyvalues["shop"] = "pawnbroker"
   end

-- ----------------------------------------------------------------------------
-- Deli is quite popular and has its own icon
-- ----------------------------------------------------------------------------
   if ( keyvalues["shop"] == "delicatessen" ) then
      keyvalues["shop"] = "deli"
   end

-- ----------------------------------------------------------------------------
-- Other money shops
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "money_transfer"      ) or
       ( keyvalues["shop"]    == "finance"             ) or
       ( keyvalues["office"]  == "finance"             ) or
       ( keyvalues["shop"]    == "financial"           ) or
       ( keyvalues["shop"]    == "mortgage"            ) or
       ( keyvalues["shop"]    == "financial_services"  ) or
       ( keyvalues["office"]  == "financial_services"  ) or
       ( keyvalues["office"]  == "financial_advisor"   ) or
       ( keyvalues["shop"]    == "financial_advisors"  ) or
       ( keyvalues["amenity"] == "financial_advice"    ) or
       ( keyvalues["amenity"] == "bureau_de_change"    )) then
      keyvalues["shop"] = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- hairdresser;beauty
-- ----------------------------------------------------------------------------
   if ( keyvalues["shop"] == "hairdresser;beauty" ) then
      keyvalues["shop"] = "hairdresser"
   end

-- ----------------------------------------------------------------------------
-- sports
-- the name is usually characteristic, but try and use an icon.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]   == "golf"              ) or
       ( keyvalues["shop"]   == "scuba_diving"      ) or
       ( keyvalues["shop"]   == "water_sports"      ) or
       ( keyvalues["shop"]   == "fishing"           ) or
       ( keyvalues["shop"]   == "fishing_tackle"    ) or
       ( keyvalues["shop"]   == "angling"           ) or
       ( keyvalues["shop"]   == "fitness_equipment" )) then
      keyvalues["shop"] = "sports"
   end

-- ----------------------------------------------------------------------------
-- e-cigarette
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]   == "vaping"               ) or
       ( keyvalues["shop"]   == "vape_shop"            )) then
      keyvalues["shop"] = "e-cigarette"
   end

-- ----------------------------------------------------------------------------
-- Various not-really-clothes things best rendered as clothes shops
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "tailor"                  ) or
       ( keyvalues["craft"]   == "tailor"                  ) or
       ( keyvalues["craft"]   == "dressmaker"              )) then
      keyvalues["shop"] = "clothes"
   end

-- ----------------------------------------------------------------------------
-- Currently handle beauty salons etc. as just generic beauty.  Also "chemist"
-- Mostly these have names that describe the business, so less need for a
-- specific icon.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]         == "beauty_salon"      ) or
       ( keyvalues["leisure"]      == "spa"               ) or
       ( keyvalues["shop"]         == "spa"               ) or
       ( keyvalues["amenity"]      == "spa"               ) or
       ( keyvalues["tourism"]      == "spa"               ) or
       (( keyvalues["club"]    == "health"               )  and
        ( keyvalues["leisure"] == nil                    )  and
        ( keyvalues["amenity"] == nil                    )  and
        ( keyvalues["name"]    ~= nil                    )) or
       ( keyvalues["shop"]         == "salon"             ) or
       ( keyvalues["shop"]         == "nails"             ) or
       ( keyvalues["shop"]         == "nail_salon"        ) or
       ( keyvalues["shop"]         == "nail"              ) or
       ( keyvalues["shop"]         == "chemist"           ) or
       ( keyvalues["shop"]         == "soap"              ) or
       ( keyvalues["shop"]         == "toiletries"        ) or
       ( keyvalues["shop"]         == "beauty_products"   ) or
       ( keyvalues["shop"]         == "beauty_treatment"  ) or
       ( keyvalues["shop"]         == "perfumery"         ) or
       ( keyvalues["shop"]         == "cosmetics"         ) or
       ( keyvalues["shop"]         == "tanning"           ) or
       ( keyvalues["shop"]         == "tan"               ) or
       ( keyvalues["shop"]         == "suntan"            ) or
       ( keyvalues["leisure"]      == "tanning_salon"     ) or
       ( keyvalues["shop"]         == "health_and_beauty" )) then
      keyvalues["shop"] = "beauty"
   end

-- ----------------------------------------------------------------------------
-- "Non-electrical" electronics (i.e. ones for which the "electrical" icon
-- is inappropriate).
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]  == "security"         ) or
       ( keyvalues["shop"]  == "survey"           ) or
       ( keyvalues["shop"]  == "survey_equipment" ) or       
       ( keyvalues["shop"]  == "hifi"             )) then
      keyvalues["shop"] = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- Computer
-- ----------------------------------------------------------------------------
   if ( keyvalues["shop"]  == "computer_repair" ) then
      keyvalues["shop"] = "computer"
   end

-- ----------------------------------------------------------------------------
-- Betting Shops etc.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "betting"             ) or
       ( keyvalues["amenity"] == "betting"             ) or
       ( keyvalues["shop"]    == "gambling"            ) or
       ( keyvalues["amenity"] == "gambling"            ) or
       ( keyvalues["leisure"] == "gambling"            ) or
       ( keyvalues["shop"]    == "lottery"             ) or
       ( keyvalues["amenity"] == "lottery"             ) or
       ( keyvalues["shop"]    == "amusements"          ) or
       ( keyvalues["amenity"] == "amusements"          ) or
       ( keyvalues["amenity"] == "amusement"           ) or
       ( keyvalues["leisure"] == "amusement_arcade"    ) or
       ( keyvalues["leisure"] == "video_arcade"        ) or
       ( keyvalues["leisure"] == "adult_gaming_centre" ) or
       ( keyvalues["amenity"] == "casino"              )) then
      keyvalues["shop"] = "bookmaker"
   end

-- ----------------------------------------------------------------------------
-- mobile_phone shops 
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]   == "phone"        ) or
       ( keyvalues["shop"]   == "phone_repair" ) or
       ( keyvalues["shop"]   == "telephone"    )) then
      keyvalues["shop"] = "mobile_phone"
   end

-- ----------------------------------------------------------------------------
-- gift and other tat shops
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]   == "souvenir"            ) or
       ( keyvalues["shop"]   == "souvenirs"           ) or
       ( keyvalues["shop"]   == "leather"             ) or
       ( keyvalues["shop"]   == "luxury"              ) or
       ( keyvalues["shop"]   == "candle"              ) or
       ( keyvalues["shop"]   == "candles"             ) or
       ( keyvalues["shop"]   == "sunglasses"          ) or
       ( keyvalues["shop"]   == "tourist"             ) or
       ( keyvalues["shop"]   == "tourism"             ) or
       ( keyvalues["shop"]   == "bag"                 ) or
       ( keyvalues["shop"]   == "balloon"             ) or
       ( keyvalues["shop"]   == "accessories"         ) or
       ( keyvalues["shop"]   == "beach"               ) or
       ( keyvalues["shop"]   == "magic"               ) or
       ( keyvalues["shop"]   == "party"               ) or
       ( keyvalues["shop"]   == "party_goods"         ) or
       ( keyvalues["shop"]   == "christmas"           ) or
       ( keyvalues["shop"]   == "fashion_accessories" ) or
       ( keyvalues["shop"]   == "duty_free"           )) then
      keyvalues["shop"] = "gift"
   end

-- ----------------------------------------------------------------------------
-- Various alcohol shops
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "beer"            ) or
       ( keyvalues["shop"]    == "off_licence"     ) or
       ( keyvalues["shop"]    == "off_license"     ) or
       ( keyvalues["shop"]    == "wine"            ) or
       ( keyvalues["shop"]    == "whisky"          ) or
       ( keyvalues["craft"]   == "winery"          ) or
       ( keyvalues["shop"]    == "winery"          ) or
       ( keyvalues["tourism"] == "wine_cellar"     )) then
      keyvalues["shop"] = "alcohol"
   end

   if (( keyvalues["shop"]    == "sweets"          ) or
       ( keyvalues["shop"]    == "sweet"           )) then
      keyvalues["shop"] = "confectionery"
   end

-- ----------------------------------------------------------------------------
-- Show pastry shops as bakeries
-- ----------------------------------------------------------------------------
   if ( keyvalues["shop"] == "pastry" ) then
      keyvalues["shop"] = "bakery"
   end

-- ----------------------------------------------------------------------------
-- Fresh fish shops
-- ----------------------------------------------------------------------------
   if ( keyvalues["shop"] == "fish" ) then
      keyvalues["shop"] = "seafood"
   end

   if (( keyvalues["shop"]    == "camera"             ) or
       ( keyvalues["shop"]    == "photo_studio"       ) or
       ( keyvalues["shop"]    == "photography"        ) or
       ( keyvalues["office"]  == "photography"        ) or
       ( keyvalues["shop"]    == "photographic"       ) or
       ( keyvalues["shop"]    == "photographer"       ) or
       ( keyvalues["craft"]   == "photographer"       )) then
      keyvalues["shop"] = "photo"
   end

-- ----------------------------------------------------------------------------
-- Various "homeware" shops.  The icon for these is a generic "room interior".
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]   == "floor"                       ) or
       ( keyvalues["shop"]   == "flooring"                    ) or
       ( keyvalues["shop"]   == "floors"                      ) or
       ( keyvalues["shop"]   == "floor_covering"              ) or
       ( keyvalues["shop"]   == "homeware"                    ) or
       ( keyvalues["shop"]   == "homewares"                   ) or
       ( keyvalues["shop"]   == "home"                        ) or
       ( keyvalues["shop"]   == "carpet"                      ) or
       ( keyvalues["shop"]   == "carpet;bed"                  ) or
       ( keyvalues["shop"]   == "interior_decoration"         ) or
       ( keyvalues["shop"]   == "household"                   ) or
       ( keyvalues["shop"]   == "houseware"                   ) or
       ( keyvalues["shop"]   == "bathroom_furnishing"         ) or
       ( keyvalues["shop"]   == "paint"                       ) or
       ( keyvalues["shop"]   == "curtain"                     ) or
       ( keyvalues["shop"]   == "furnishings"                 ) or
       ( keyvalues["shop"]   == "furnishing"                  ) or
       ( keyvalues["shop"]   == "fireplace"                   ) or
       ( keyvalues["shop"]   == "lighting"                    ) or
       ( keyvalues["shop"]   == "blinds"                      ) or
       ( keyvalues["shop"]   == "window_blind"                ) or
       ( keyvalues["shop"]   == "kitchenware"                 ) or
       ( keyvalues["shop"]   == "interior_design"             ) or
       ( keyvalues["shop"]   == "interior"                    ) or
       ( keyvalues["shop"]   == "interiors"                   ) or
       ( keyvalues["shop"]   == "stoves"                      ) or
       ( keyvalues["shop"]   == "stove"                       ) or
       ( keyvalues["shop"]   == "tiles"                       ) or
       ( keyvalues["shop"]   == "tile"                        ) or
       ( keyvalues["shop"]   == "ceramics"                    ) or
       ( keyvalues["shop"]   == "windows"                     ) or
       ( keyvalues["craft"]  == "window_construction"         ) or
       ( keyvalues["shop"]   == "frame"                       ) or
       ( keyvalues["shop"]   == "framing"                     ) or
       ( keyvalues["shop"]   == "picture_framing"             ) or
       ( keyvalues["shop"]   == "picture_framer"              ) or
       ( keyvalues["craft"]  == "framing"                     ) or
       ( keyvalues["shop"]   == "frame;restoration"           ) or
       ( keyvalues["shop"]   == "bedding"                     ) or
       ( keyvalues["shop"]   == "cookware"                    ) or
       ( keyvalues["shop"]   == "glassware"                   ) or
       ( keyvalues["shop"]   == "cookery"                     ) or
       ( keyvalues["shop"]   == "catering_supplies"           ) or
       ( keyvalues["craft"]  == "upholsterer"                 )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["shop"] = "homeware"
   end

-- ----------------------------------------------------------------------------
-- Other "homeware-like" shops.  These get the furniture icon.
-- Some are a bit of a stretch.
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]   == "upholsterer"                 ) or
       ( keyvalues["shop"]   == "chair"                       ) or
       ( keyvalues["shop"]   == "luggage"                     ) or
       ( keyvalues["shop"]   == "clock"                       ) or
       ( keyvalues["shop"]   == "clocks"                      ) or
       ( keyvalues["shop"]   == "home_improvement"            ) or
       ( keyvalues["shop"]   == "decorating"                  ) or
       ( keyvalues["shop"]   == "bed;carpet"                  ) or
       ( keyvalues["shop"]   == "country_store"               ) or
       ( keyvalues["shop"]   == "equestrian"                  ) or
       ( keyvalues["shop"]   == "kitchen"                     ) or
       ( keyvalues["shop"]   == "kitchen;bathroom"            ) or
       ( keyvalues["shop"]   == "kitchen;bathroom_furnishing" ) or
       ( keyvalues["shop"]   == "bedroom"                     ) or
       ( keyvalues["shop"]   == "bathroom"                    ) or
       ( keyvalues["shop"]   == "glaziery"                    ) or
       ( keyvalues["craft"]  == "glaziery"                    ) or
       ( keyvalues["shop"]   == "glazier"                     ) or
       ( keyvalues["shop"]   == "glazing"                     ) or
       ( keyvalues["shop"]   == "stone"                       ) or
       ( keyvalues["shop"]   == "brewing"                     ) or
       ( keyvalues["shop"]   == "gates"                       ) or
       ( keyvalues["shop"]   == "sheds"                       ) or
       ( keyvalues["shop"]   == "shed"                        ) or
       ( keyvalues["shop"]   == "ironmonger"                  ) or
       ( keyvalues["shop"]   == "furnace"                     ) or
       ( keyvalues["shop"]   == "plumbing"                    ) or
       ( keyvalues["craft"]  == "plumber"                     ) or
       ( keyvalues["craft"]  == "carpenter"                   ) or
       ( keyvalues["craft"]  == "decorator"                   ) or
       ( keyvalues["shop"]   == "bed"                         ) or
       ( keyvalues["shop"]   == "mattress"                    ) or
       ( keyvalues["shop"]   == "waterbed"                    ) or
       ( keyvalues["shop"]   == "glass"                       ) or
       ( keyvalues["shop"]   == "garage"                      ) or
       ( keyvalues["shop"]   == "conservatory"                ) or
       ( keyvalues["shop"]   == "conservatories"              ) or
       ( keyvalues["shop"]   == "bathrooms"                   ) or
       ( keyvalues["shop"]   == "swimming_pool"               ) or
       ( keyvalues["shop"]   == "fitted_furniture"            ) or
       ( keyvalues["shop"]   == "upholstery"                  ) or
       ( keyvalues["shop"]   == "saddlery"                    )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["shop"] = "furniture"
   end

-- ----------------------------------------------------------------------------
-- Shops that sell coffee etc.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "beverages"       ) or
       ( keyvalues["shop"]    == "coffee"          ) or
       ( keyvalues["shop"]    == "tea"             )) then
      keyvalues["shop"] = "coffee"
   end

-- ----------------------------------------------------------------------------
-- Copyshops
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "printing"       ) or
       ( keyvalues["shop"]    == "print"          ) or
       ( keyvalues["shop"]    == "printer"        )) then
      keyvalues["shop"] = "copyshop"
      keyvalues["amenity"] = nil
      keyvalues["craft"] = nil
      keyvalues["office"] = nil
   end

-- ----------------------------------------------------------------------------
-- This category used to be larger, but the values have been consolidated.
-- Difficult to do an icon for.
-- ----------------------------------------------------------------------------
   if ( keyvalues["shop"]    == "printer_ink" ) then
      keyvalues["shop"] = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- Various single food item and other food shops
-- Unnamed egg honesty boxes have been dealt with above.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "cake"            ) or
       ( keyvalues["shop"]    == "chocolate"       ) or
       ( keyvalues["shop"]    == "milk"            ) or
       ( keyvalues["shop"]    == "cheese"          ) or
       ( keyvalues["shop"]    == "cheese;wine"     ) or
       ( keyvalues["shop"]    == "wine;cheese"     ) or
       ( keyvalues["shop"]    == "dairy"           ) or
       ( keyvalues["shop"]    == "eggs"            ) or
       ( keyvalues["shop"]    == "honey"           ) or
       ( keyvalues["shop"]    == "catering"        ) or
       ( keyvalues["shop"]    == "fishmonger"      ) or
       ( keyvalues["shop"]    == "spices"           ) or
       ( keyvalues["shop"]    == "nuts"            )) then
      keyvalues["shop"] = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- fabric and wool etc.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]   == "fabric"               ) or
       ( keyvalues["shop"]   == "linen"                ) or
       ( keyvalues["shop"]   == "linens"               ) or
       ( keyvalues["shop"]   == "haberdashery"         ) or
       ( keyvalues["shop"]   == "sewing"               ) or
       ( keyvalues["shop"]   == "needlecraft"          ) or
       ( keyvalues["shop"]   == "embroidery"           ) or
       ( keyvalues["shop"]   == "knitting"             ) or
       ( keyvalues["shop"]   == "wool"                 ) or
       ( keyvalues["shop"]   == "yarn"                 ) or
       ( keyvalues["shop"]   == "alteration"           ) or
       ( keyvalues["shop"]   == "clothing_alterations" ) or
       ( keyvalues["craft"]  == "embroiderer"          )) then
      keyvalues["shop"] = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- health_food etc., and also "non-medical medical" and "woo" shops.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]       == "health_food"             ) or
       ( keyvalues["shop"]       == "health"                  ) or
       ( keyvalues["shop"]       == "organic"                 ) or
       ( keyvalues["shop"]       == "supplements"             ) or
       ( keyvalues["shop"]       == "nutrition_supplements"   ) or
       ( keyvalues["shop"]       == "dietary_supplements"     ) or
       ( keyvalues["name"]       == "Holland and Barrett"     )) then
      if (( keyvalues["zero_waste"]         == "yes"                )  or
          ( keyvalues["zero_waste"]         == "only"               )  or
          ( keyvalues["bulk_purchase"]      == "yes"                )  or
          ( keyvalues["bulk_purchase"]      == "only"               )  or
          ( keyvalues["reusable_packaging"] == "yes"                )) then
         keyvalues["shop"] = "ecohealth_food"
      else
         keyvalues["shop"] = "health_food"
      end
   end

   if (( keyvalues["shop"]       == "alternative_medicine"    ) or
       ( keyvalues["shop"]       == "massage"                 ) or
       ( keyvalues["shop"]       == "herbalist"               ) or
       ( keyvalues["shop"]       == "herbal_medicine"         ) or
       ( keyvalues["shop"]       == "chinese_medicine"        ) or
       ( keyvalues["shop"]       == "new_age"                 ) or
       ( keyvalues["shop"]       == "alternative_health"      ) or
       ( keyvalues["healthcare"] == "alternative"             ) or
       ( keyvalues["shop"]       == "acupuncture"             ) or
       ( keyvalues["healthcare"] == "acupuncture"             ) or
       ( keyvalues["shop"]       == "aromatherapy"            ) or
       ( keyvalues["shop"]       == "meditation"              ) or
       ( keyvalues["shop"]       == "esoteric"                )) then
      keyvalues["shop"] = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- travel agents
-- the name is usually characteristic
-- ----------------------------------------------------------------------------
   if (( keyvalues["office"] == "travel_agent"  ) or
       ( keyvalues["shop"]   == "travel_agency" ) or
       ( keyvalues["shop"]   == "travel"        )) then
      keyvalues["shop"] = "travel_agent"
   end

-- ----------------------------------------------------------------------------
-- books and stationery
-- the name is often characteristic
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]   == "comics"          ) or
       ( keyvalues["shop"]   == "comic"           ) or
       ( keyvalues["shop"]   == "anime"           ) or
       ( keyvalues["shop"]   == "maps"            )) then
      keyvalues["shop"] = "books"
   end

   if ( keyvalues["shop"]   == "office_supplies" ) then
      keyvalues["shop"] = "stationery"
   end

-- ----------------------------------------------------------------------------
-- toys and games etc.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]   == "model"          ) or
       ( keyvalues["shop"]   == "games"          ) or
       ( keyvalues["shop"]   == "computer_games" ) or
       ( keyvalues["shop"]   == "video_games"    ) or
       ( keyvalues["shop"]   == "hobby"          ) or
       ( keyvalues["shop"]   == "fancy_dress"    )) then
      keyvalues["shop"] = "toys"
   end

-- ----------------------------------------------------------------------------
-- Art etc.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]   == "craft"          ) or
       ( keyvalues["shop"]   == "art_supplies"   ) or
       ( keyvalues["shop"]   == "pottery"        ) or
       ( keyvalues["craft"]  == "artist"         ) or
       ( keyvalues["craft"]  == "pottery"        ) or
       ( keyvalues["craft"]  == "sculptor"       )) then
      keyvalues["shop"]  = "art"
      keyvalues["craft"] = nil
   end

-- ----------------------------------------------------------------------------
-- pets and pet services
-- Normally the names are punningly characteristic (e.g. "Bark-in-Style" 
-- dog grooming).
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "pet;garden"              ) or
       ( keyvalues["shop"]    == "aquatics"                ) or
       ( keyvalues["shop"]    == "aquarium"                ) or
       ( keyvalues["shop"]    == "pet;corn"                )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["shop"] = "pet"
   end

-- ----------------------------------------------------------------------------
-- Pet and animal food
-- ----------------------------------------------------------------------------
   if (((  keyvalues["shop"]     == "agrarian"                        )  and
        (( keyvalues["agrarian"] == "feed"                           )  or
         ( keyvalues["agrarian"] == "yes"                            )  or
         ( keyvalues["agrarian"] == "feed;fertilizer;seed;pesticide" )  or
         ( keyvalues["agrarian"] == "feed;seed"                      )  or
         ( keyvalues["agrarian"] == "feed;pesticide;seed"            )  or
         ( keyvalues["agrarian"] == "feed;tools"                     )  or
         ( keyvalues["agrarian"] == "feed;tools;fuel;firewood"       ))) or
       ( keyvalues["shop"]    == "pet_supplies"            ) or
       ( keyvalues["shop"]    == "pet_care"                ) or
       ( keyvalues["shop"]    == "pet_food"                ) or
       ( keyvalues["shop"]    == "petfood"                 ) or
       ( keyvalues["shop"]    == "animal_feed"             )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["shop"] = "pet_food"
   end

-- ----------------------------------------------------------------------------
-- Pet grooming
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "pet_grooming"            ) or
       ( keyvalues["shop"]    == "dog_grooming"            ) or
       ( keyvalues["amenity"] == "dog_grooming"            ) or
       ( keyvalues["craft"]   == "dog_grooming"            ) or
       ( keyvalues["animal"]  == "wellness"                )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["shop"] = "pet_grooming"
   end

-- ----------------------------------------------------------------------------
-- amenity=veterinary goes through as is
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- Animal boarding
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "animal_boarding"         ) or
       ( keyvalues["amenity"] == "cattery"                 ) or
       ( keyvalues["amenity"] == "kennels"                 )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["amenity"] = "animal_boarding"
   end

-- ----------------------------------------------------------------------------
-- Animal shelters
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "animal_shelter"          ) or
       ( keyvalues["animal"]  == "shelter"                 )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["amenity"] = "animal_shelter"
   end

-- ----------------------------------------------------------------------------
-- Car parts
-- ----------------------------------------------------------------------------
   if ((( keyvalues["shop"]    == "trade"                       )  and
        ( keyvalues["trade"]   == "car_parts"                   )) or
       (  keyvalues["shop"]    == "car_accessories"              )  or
       (  keyvalues["shop"]    == "tyres"                        )  or
       (  keyvalues["shop"]    == "automotive"                   )  or
       (  keyvalues["shop"]    == "battery"                      )  or
       (  keyvalues["shop"]    == "batteries"                    )  or
       (  keyvalues["shop"]    == "number_plate"                 )  or
       (  keyvalues["shop"]    == "number_plates"                )  or
       (  keyvalues["shop"]    == "license_plates"               )  or
       (  keyvalues["shop"]    == "car_audio"                    )  or
       (  keyvalues["shop"]    == "motor"                        )  or
       (  keyvalues["shop"]    == "motor_spares"                 )  or
       (  keyvalues["shop"]    == "motor_accessories"            )  or
       (  keyvalues["shop"]    == "car_parts;car_repair"         )  or
       (  keyvalues["shop"]    == "bicycle;car_parts"            )  or
       (  keyvalues["shop"]    == "car_parts;bicycle"            )) then
      keyvalues["shop"] = "car_parts"
   end

-- ----------------------------------------------------------------------------
-- Shopmobility
-- Note that "shop=mobility" is something that _sells_ mobility aids, and is
-- handled as shop=nonspecific for now.
-- We handle some specific cases of shop=mobility here; the rest below.
-- ----------------------------------------------------------------------------
   if ((   keyvalues["amenity"]  == "mobility"                 ) or
       (   keyvalues["amenity"]  == "mobility_equipment_hire"  ) or
       (   keyvalues["amenity"]  == "mobility_aids_hire"       ) or
       (   keyvalues["amenity"]  == "shop_mobility"            ) or
       ((  keyvalues["amenity"]  == "social_facility"         )  and
        (  keyvalues["social_facility"] == "shopmobility"     )) or
       ((( keyvalues["shop"]     == "yes"                    )   or
         ( keyvalues["shop"]     == "mobility"               )   or
         ( keyvalues["shop"]     == "mobility_hire"          )   or
         ( keyvalues["building"] == "yes"                    )   or
         ( keyvalues["building"] == "unit"                   ))  and
        (( keyvalues["name"]     == "Shopmobility"           )   or
         ( keyvalues["name"]     == "Shop Mobility"          )))) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["amenity"] = "shopmobility"
   end

-- ----------------------------------------------------------------------------
-- Music
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "music;video"             ) or
       ( keyvalues["shop"]    == "records"                 ) or
       ( keyvalues["shop"]    == "record"                  )) then
      keyvalues["shop"] = "music"
   end

-- ----------------------------------------------------------------------------
-- Motorcycle
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "motorcycle_repair"            ) or
       ( keyvalues["shop"]    == "motorcycle_parts"             ) or
       ( keyvalues["amenity"] == "motorcycle_rental"            ) or
       ( keyvalues["shop"]    == "atv"                          )) then
      keyvalues["shop"] = "motorcycle"
   end

-- ----------------------------------------------------------------------------
-- Tattoo
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "piercing"                ) or
       ( keyvalues["shop"]    == "tattoo;piercing"         )) then
      keyvalues["shop"] = "tattoo"
   end

-- ----------------------------------------------------------------------------
-- Musical Instrument
-- ----------------------------------------------------------------------------
   if ( keyvalues["shop"]    == "piano" ) then
      keyvalues["shop"] = "musical_instrument"
   end

-- ----------------------------------------------------------------------------
-- Locksmith
-- ----------------------------------------------------------------------------
   if ( keyvalues["craft"] == "locksmith" ) then
      keyvalues["shop"] = "locksmith"
   end

-- ----------------------------------------------------------------------------
-- Storage Rental
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "storage"              ) or
       ( keyvalues["amenity"] == "self_storage"         ) or
       ( keyvalues["office"]  == "storage_rental"       ) or
       ( keyvalues["shop"]    == "storage"              )) then
      keyvalues["shop"] = "storage_rental"
   end

-- ----------------------------------------------------------------------------
-- car and van rental.
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "car_rental"                   ) or
       ( keyvalues["amenity"] == "van_rental"                   ) or
       ( keyvalues["amenity"] == "car_rental;bicycle_rental"    ) or
       ( keyvalues["shop"]    == "car_rental"                   ) or
       ( keyvalues["shop"]    == "van_rental"                   )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["amenity"]    = "car_rental"
   end

-- ----------------------------------------------------------------------------
-- Nonspecific car and related shops.
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "caravan"                      ) or
       ( keyvalues["shop"]    == "motorhome"                    ) or
       ( keyvalues["shop"]    == "boat"                         ) or
       ( keyvalues["shop"]    == "truck"                        ) or
       ( keyvalues["shop"]    == "commercial_vehicles"          ) or
       ( keyvalues["shop"]    == "commercial_vehicle"           ) or
       ( keyvalues["shop"]    == "agricultural_vehicles"        ) or
       ((  keyvalues["shop"]    == "agrarian"                                           ) and
        (( keyvalues["agrarian"] == "agricultural_machinery"                           )  or
         ( keyvalues["agrarian"] == "machine_parts;agricultural_machinery;tools"       )  or
         ( keyvalues["agrarian"] == "agricultural_machinery;machine_parts;tools"       )  or
         ( keyvalues["agrarian"] == "agricultural_machinery;feed"                      )  or
         ( keyvalues["agrarian"] == "agricultural_machinery;machine_parts;tools;signs" )  or
         ( keyvalues["agrarian"] == "agricultural_machinery;machine_parts"             )  or
         ( keyvalues["agrarian"] == "agricultural_machinery;seed"                      )  or
         ( keyvalues["agrarian"] == "machine_parts;agricultural_machinery"             ))) or
       ( keyvalues["shop"]    == "tractor"                      ) or
       ( keyvalues["shop"]    == "tractors"                     ) or
       ( keyvalues["shop"]    == "tractor_repair"               ) or
       ( keyvalues["shop"]    == "tractor_parts"                ) or
       ( keyvalues["shop"]    == "van"                          ) or
       ( keyvalues["shop"]    == "truck_repair"                 ) or
       ( keyvalues["industrial"] == "truck_repair"              ) or
       ( keyvalues["shop"]    == "forklift_repair"              ) or
       ( keyvalues["amenity"] == "driving_school"               ) or
       ( keyvalues["shop"]    == "chandler"                     ) or
       ( keyvalues["shop"]    == "chandlery"                    ) or
       ( keyvalues["shop"]    == "ship_chandler"                ) or
       ( keyvalues["craft"]   == "boatbuilder"                  ) or
       ( keyvalues["shop"]    == "marine"                       ) or
       ( keyvalues["shop"]    == "boat_repair"                  )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["shop"]    = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- Timpson and similar shops.
-- Timpson is brand:wikidata=Q7807658, but all of those are name=Timpson.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "shoe_repair"                        ) or
       ( keyvalues["shop"]    == "keys"                               ) or
       ( keyvalues["shop"]    == "key"                                ) or
       ( keyvalues["shop"]    == "cobblers"                           ) or
       ( keyvalues["shop"]    == "cobbler"                            ) or
       ( keyvalues["shop"]    == "key_cutting"                        ) or
       ( keyvalues["shop"]    == "key_cutting;shoe_repair"            ) or
       ( keyvalues["shop"]    == "shoe_repair;key_cutting"            ) or
       ( keyvalues["shop"]    == "locksmith;dry_cleaning;shoe_repair" ) or
       ( keyvalues["craft"]   == "key_cutter"                         ) or
       ( keyvalues["craft"]   == "shoe_repair"                        ) or
       ( keyvalues["craft"]   == "key_cutter;shoe_repair"             )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["shop"]    = "shoe_repair_etc"
   end

-- ----------------------------------------------------------------------------
-- Taxi offices
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "taxi"                    ) or
       ( keyvalues["office"]  == "taxi"                    ) or
       ( keyvalues["office"]  == "minicab"                 ) or
       ( keyvalues["shop"]    == "minicab"                 ) or
       ( keyvalues["amenity"] == "minicab"                 )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["amenity"] = "taxi_office"
      keyvalues["shop"]    = nil
      keyvalues["office"]  = nil
   end

-- ----------------------------------------------------------------------------
-- Other shops that don't have a specific icon are handled here. including
-- variations.
--
-- Shops are in this list either because they tend to have a characteristic
-- name (e.g. the various card shops), they're difficult to do an icon for
-- or they're rare.
--
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "card"                    ) or
       ( keyvalues["shop"]    == "cards"                   ) or
       ( keyvalues["shop"]    == "greeting_card"           ) or
       ( keyvalues["shop"]    == "greeting_cards"          ) or
       ( keyvalues["shop"]    == "greetings_cards"         ) or
       ( keyvalues["shop"]    == "greetings"               ) or
       ( keyvalues["shop"]    == "card;gift"               ) or
       ( keyvalues["craft"]   == "cobbler"                 ) or
       ( keyvalues["craft"]   == "shoemaker"               ) or
       ( keyvalues["shop"]    == "shoemaker"               ) or
       ( keyvalues["shop"]    == "watch_repair"            ) or
       ( keyvalues["shop"]    == "cleaning"                ) or
       ( keyvalues["shop"]    == "collector"               ) or
       ( keyvalues["shop"]    == "coins"                   ) or
       ( keyvalues["shop"]    == "video"                   ) or
       ( keyvalues["shop"]    == "audio_video"             ) or
       ( keyvalues["shop"]    == "erotic"                  ) or
       ( keyvalues["shop"]    == "service"                 ) or
       ( keyvalues["shop"]    == "tobacco"                 ) or
       ( keyvalues["shop"]    == "tobacconist"             ) or
       ( keyvalues["shop"]    == "ticket"                  ) or
       ( keyvalues["shop"]    == "insurance"               ) or
       ( keyvalues["shop"]    == "gallery"                 ) or
       ( keyvalues["tourism"] == "gallery"                 ) or
       ( keyvalues["amenity"] == "gallery"                 ) or
       ( keyvalues["amenity"] == "art_gallery"             ) or
       ( keyvalues["shop"]    == "plumber"                 ) or
       ( keyvalues["shop"]    == "builder"                 ) or
       ( keyvalues["shop"]    == "builders"                ) or
       ( keyvalues["shop"]    == "trophy"                  ) or
       ( keyvalues["shop"]    == "communication"           ) or
       ( keyvalues["shop"]    == "communications"          ) or
       ( keyvalues["shop"]    == "internet"                ) or
       ( keyvalues["amenity"] == "internet_cafe"           ) or
       ( keyvalues["shop"]    == "internet_cafe"           ) or
       ( keyvalues["shop"]    == "recycling"               ) or
       ( keyvalues["shop"]    == "gun"                     ) or
       ( keyvalues["craft"]   == "gunsmith"                ) or
       ( keyvalues["shop"]    == "weapons"                 ) or
       ( keyvalues["shop"]    == "pyrotechnics"            ) or
       ( keyvalues["shop"]    == "hunting"                 ) or
       ( keyvalues["shop"]    == "military_surplus"        ) or
       ( keyvalues["shop"]    == "fireworks"               ) or
       ( keyvalues["shop"]    == "auction"                 ) or
       ( keyvalues["shop"]    == "auction_house"           ) or
       ( keyvalues["office"]  == "auctioneer"              ) or
       ( keyvalues["shop"]    == "religion"                ) or
       ( keyvalues["shop"]    == "gas"                     ) or
       ( keyvalues["shop"]    == "fuel"                    ) or
       ( keyvalues["shop"]    == "energy"                  ) or
       ( keyvalues["shop"]    == "coal_merchant"           ) or
       ( keyvalues["amenity"] == "training"                ) or
       ((  keyvalues["amenity"]  == nil                   )  and
        (( keyvalues["training"] == "dance"              )   or
         ( keyvalues["training"] == "language"           )   or
         ( keyvalues["training"] == "performing_arts"    ))) or
       ( keyvalues["amenity"] == "tutoring_centre"         ) or
       ( keyvalues["office"]  == "tutoring"                ) or
       ( keyvalues["shop"]    == "ironing"                 ) or
       ( keyvalues["amenity"] == "stripclub"               ) or
       ( keyvalues["amenity"] == "courier"                 )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["shop"] = "shopnonspecific"
   end

   if (( keyvalues["shop"]    == "launderette"             ) or
       ( keyvalues["shop"]    == "dry_cleaning"            ) or
       ( keyvalues["shop"]    == "dry_cleaning;laundry"    )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["shop"] = "laundry"
   end

-- ----------------------------------------------------------------------------
-- Stonemasons etc.
-- ----------------------------------------------------------------------------
   if (( keyvalues["craft"]   == "stonemason"        ) or
       ( keyvalues["shop"]    == "gravestone"        ) or
       ( keyvalues["shop"]    == "monumental_mason"  ) or
       ( keyvalues["shop"]    == "memorials"         )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["shop"]    = "funeral_directors"
   end

-- ----------------------------------------------------------------------------
-- Specific handling for incompletely tagged "Howdens".
-- Unfortunately there are a few of these.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["name"]     == "Howdens"             )  or
        ( keyvalues["name"]     == "Howdens Joinery"     )  or
        ( keyvalues["name"]     == "Howdens Joinery Co"  )  or
        ( keyvalues["name"]     == "Howdens Joinery Co." )  or
        ( keyvalues["name"]     == "Howdens Joinery Ltd" )) and
       (  keyvalues["shop"]     == nil                    ) and
       (  keyvalues["craft"]    == nil                    ) and
       (  keyvalues["highway"]  == nil                    ) and
       (  keyvalues["landuse"]  == nil                    ) and
       (  keyvalues["man_made"] == nil                    )) then
      keyvalues["shop"] = "trade"
   end

-- ----------------------------------------------------------------------------
-- Shops that we don't know the type of.  Things such as "hire" are here 
-- because we don't know "hire of what".
-- "wood" is here because it's used for different sorts of shops.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "yes"             ) or
       ( keyvalues["craft"]   == "yes"             ) or
       ( keyvalues["shop"]    == "other"           ) or
       ( keyvalues["shop"]    == "hire"            ) or
       ( keyvalues["shop"]    == "rental"          ) or
       ( keyvalues["office"]  == "rental"          ) or
       ( keyvalues["amenity"] == "rental"          ) or
       ( keyvalues["shop"]    == "second_hand"     ) or
       ( keyvalues["shop"]    == "junk"            ) or
       ( keyvalues["shop"]    == "general"         ) or
       ( keyvalues["shop"]    == "general_store"   ) or
       ( keyvalues["shop"]    == "retail"          ) or
       ( keyvalues["shop"]    == "trade"           ) or
       ( keyvalues["shop"]    == "cash_and_carry"  ) or
       ( keyvalues["shop"]    == "fixme"           ) or
       ( keyvalues["shop"]    == "wholesale"       ) or
       ( keyvalues["shop"]    == "wood"            ) or
       ( keyvalues["shop"]    == "childrens"       ) or
       ( keyvalues["shop"]    == "factory_outlet"  ) or
       ( keyvalues["shop"]    == "specialist"      ) or
       ( keyvalues["shop"]    == "specialist_shop" )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["shop"]    = "shopnonspecific"
   end

   if (( keyvalues["amenity"]     == "optician"                     ) or
       ( keyvalues["craft"]       == "optician"                     ) or
       ( keyvalues["office"]      == "optician"                     ) or
       ( keyvalues["shop"]        == "optometrist"                  ) or
       ( keyvalues["amenity"]     == "optometrist"                  ) or
       ( keyvalues["healthcare"]  == "optometrist"                  )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["shop"]    = "optician"
   end

-- ----------------------------------------------------------------------------
-- chiropodists etc. - render as "nonspecific health".
-- Add unnamedcommercial landuse to give non-building areas a background.
--
-- Places that _sell_ mobility aids are in here.  Shopmobility handled
-- seperately.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]        == "hearing_aids"                 ) or
       ( keyvalues["healthcare"]  == "hearing_care"                 ) or
       ( keyvalues["shop"]        == "medical_supply"               ) or
       ( keyvalues["office"]      == "medical_supply"               ) or
       ( keyvalues["shop"]        == "mobility"                     ) or
       ( keyvalues["shop"]        == "disability"                   ) or
       ( keyvalues["shop"]        == "chiropodist"                  ) or
       ( keyvalues["amenity"]     == "chiropodist"                  ) or
       ( keyvalues["healthcare"]  == "chiropodist"                  ) or
       ( keyvalues["amenity"]     == "chiropractor"                 ) or
       ( keyvalues["healthcare"]  == "chiropractor"                 ) or
       ( keyvalues["healthcare"]  == "department"                   ) or
       ( keyvalues["healthcare"]  == "diagnostics"                  ) or
       ( keyvalues["healthcare"]  == "dialysis"                     ) or
       ( keyvalues["healthcare"]  == "osteopath"                    ) or
       ( keyvalues["shop"]        == "osteopath"                    ) or
       ( keyvalues["amenity"]     == "physiotherapist"              ) or
       ( keyvalues["healthcare"]  == "physiotherapist"              ) or
       ( keyvalues["healthcare"]  == "physiotherapist;podiatrist"   ) or
       ( keyvalues["shop"]        == "physiotherapist"              ) or
       ( keyvalues["healthcare"]  == "physiotherapy"                ) or
       ( keyvalues["shop"]        == "physiotherapy"                ) or
       ( keyvalues["healthcare"]  == "psychotherapist"              ) or
       ( keyvalues["healthcare"]  == "therapy"                      ) or
       ( keyvalues["healthcare"]  == "podiatrist"                   ) or
       ( keyvalues["healthcare"]  == "podiatrist;chiropodist"       ) or
       ( keyvalues["amenity"]     == "podiatrist"                   ) or
       ( keyvalues["healthcare"]  == "podiatry"                     ) or
       ( keyvalues["amenity"]     == "healthcare"                   ) or
       ( keyvalues["amenity"]     == "clinic"                       ) or
       ( keyvalues["healthcare"]  == "clinic"                       ) or
       ( keyvalues["healthcare"]  == "clinic;doctor"                ) or
       ( keyvalues["shop"]        == "clinic"                       ) or
       ( keyvalues["amenity"]     == "social_facility"              ) or
       ((  keyvalues["amenity"]         == nil                     )  and
        (( keyvalues["social_facility"] == "group_home"           )   or
         ( keyvalues["social_facility"] == "nursing_home"         )   or
         ( keyvalues["social_facility"] == "assisted_living"      )   or
         ( keyvalues["social_facility"] == "care_home"            )   or
         ( keyvalues["social_facility"] == "shelter"              )   or
         ( keyvalues["social_facility"] == "day_care"             )   or
         ( keyvalues["social_facility"] == "day_centre"           )   or
         ( keyvalues["social_facility"] == "residential_home"     ))) or
       ( keyvalues["amenity"]     == "nursing_home"                 ) or
       ( keyvalues["healthcare"]  == "nursing_home"                 ) or
       ( keyvalues["residential"] == "nursing_home"                 ) or
       ( keyvalues["building"]    == "nursing_home"                 ) or
       ( keyvalues["amenity"]     == "care_home"                    ) or
       ( keyvalues["residential"] == "care_home"                    ) or
       ( keyvalues["amenity"]     == "retirement_home"              ) or
       ( keyvalues["amenity"]     == "residential_home"             ) or
       ( keyvalues["residential"] == "residential_home"             ) or
       ( keyvalues["amenity"]     == "sheltered_housing"            ) or
       ( keyvalues["residential"] == "sheltered_housing"            ) or
       ( keyvalues["amenity"]     == "childcare"                    ) or
       ( keyvalues["amenity"]     == "childrens_centre"             ) or
       ( keyvalues["amenity"]     == "preschool"                    ) or
       ( keyvalues["building"]    == "preschool"                    ) or
       ( keyvalues["amenity"]     == "nursery"                      ) or
       ( keyvalues["amenity"]     == "nursery_school"               ) or
       ( keyvalues["amenity"]     == "health_centre"                ) or
       ( keyvalues["healthcare"]  == "health_centre"                ) or
       ( keyvalues["building"]    == "health_centre"                ) or
       ( keyvalues["amenity"]     == "medical_centre"               ) or
       ( keyvalues["building"]    == "medical_centre"               ) or
       ( keyvalues["healthcare"]  == "centre"                       ) or
       ( keyvalues["healthcare"]  == "counselling"                  ) or
       ( keyvalues["craft"]       == "counsellor"                   ) or
       ( keyvalues["amenity"]     == "hospice"                      ) or
       ( keyvalues["healthcare"]  == "hospice"                      ) or
       ( keyvalues["healthcare"]  == "cosmetic"                     ) or
       ( keyvalues["healthcare"]  == "cosmetic_surgery"             ) or
       ( keyvalues["healthcare"]  == "dentures"                     ) or
       ( keyvalues["shop"]        == "dentures"                     ) or
       ( keyvalues["shop"]        == "denture"                      ) or
       ( keyvalues["healthcare"]  == "blood_donation"               ) or
       ( keyvalues["healthcare"]  == "blood_bank"                   ) or
       ( keyvalues["healthcare"]  == "sports_massage_therapist"     ) or
       ( keyvalues["healthcare"]  == "massage"                      ) or
       ( keyvalues["healthcare"]  == "rehabilitation"               ) or
       ( keyvalues["healthcare"]  == "drug_rehabilitation"          ) or
       ( keyvalues["healthcare"]  == "medical_imaging"              ) or
       ( keyvalues["healthcare"]  == "midwife"                      ) or
       ( keyvalues["healthcare"]  == "occupational_therapist"       ) or
       ( keyvalues["healthcare"]  == "speech_therapist"             ) or
       ( keyvalues["healthcare"]  == "tattoo_removal"               ) or
       ( keyvalues["healthcare"]  == "trichologist"                 ) or
       ( keyvalues["healthcare"]  == "ocular_prosthetics"           ) or
       ( keyvalues["healthcare"]  == "audiologist"                  ) or
       ( keyvalues["healthcare"]  == "hearing"                      ) or
       ( keyvalues["healthcare"]  == "mental_health"                ) or
       ( keyvalues["amenity"]     == "daycare"                      )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["shop"]    = "healthnonspecific"
   end

-- ----------------------------------------------------------------------------
-- Defibrillators etc.
-- Move these to the "amenity" key to reduce the code needed to render them.
-- Ones with an non-public, non-yes access value will be rendered less opaque,
-- like other private items such as car parks.
-- ----------------------------------------------------------------------------
   if ( keyvalues["emergency"] == "defibrillator" ) then
      keyvalues["amenity"] = "defibrillator"
      if ( keyvalues["indoor"] == "yes" ) then
         keyvalues["access"] = "customers"
      end
   end

   if ((  keyvalues["emergency"]        == "life_ring"         ) or
       (  keyvalues["emergency"]        == "lifevest"          ) or
       (  keyvalues["emergency"]        == "flotation device"  ) or
       (( keyvalues["emergency"]        == "rescue_equipment" )  and
        ( keyvalues["rescue_equipment"] == "lifering"         ))) then
      keyvalues["amenity"] = "life_ring"
   end

   if ( keyvalues["emergency"] == "fire_extinguisher" ) then
      keyvalues["amenity"] = "fire_extinguisher"
   end

   if ( keyvalues["emergency"] == "fire_hydrant" ) then
      keyvalues["amenity"] = "fire_hydrant"
   end

-- ----------------------------------------------------------------------------
-- Craft cider
-- Also remove tourism tag (we want to display brewery in preference to
-- attraction or museum).
-- ----------------------------------------------------------------------------
   if ((  keyvalues["craft"]   == "cider"    ) or
       (( keyvalues["craft"]   == "brewery" )  and
        ( keyvalues["product"] == "cider"   ))) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["office"]  = "craftcider"
      keyvalues["craft"]  = nil
      keyvalues["tourism"]  = nil
   end

-- ----------------------------------------------------------------------------
-- Craft breweries
-- Also remove tourism tag (we want to display brewery in preference to
-- attraction or museum).
-- ----------------------------------------------------------------------------
   if (( keyvalues["craft"] == "brewery"       ) or
       ( keyvalues["craft"] == "brewery;cider" )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["office"]  = "craftbrewery"
      keyvalues["craft"]  = nil
      keyvalues["tourism"]  = nil
   end

-- ----------------------------------------------------------------------------
-- Various "printer" offices
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "printers"          ) or
       ( keyvalues["amenity"] == "printer"           ) or
       ( keyvalues["craft"]   == "printer"           ) or
       ( keyvalues["office"]  == "printer"           ) or
       ( keyvalues["office"]  == "design"            ) or
       ( keyvalues["craft"]   == "printmaker"        ) or
       ( keyvalues["craft"]   == "print_shop"        )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["office"]  = "nonspecific"
   end

-- ----------------------------------------------------------------------------
-- Various crafts that should appear as at least a nonspecific office.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["amenity"] == nil                        )  and
       (  keyvalues["shop"]    == nil                        )  and
       (  keyvalues["tourism"] == nil                        )  and
       (( keyvalues["craft"]   == "agricultural_engines"    )   or
        ( keyvalues["craft"]   == "atelier"                 )   or
        ( keyvalues["craft"]   == "blacksmith"              )   or
        ( keyvalues["craft"]   == "beekeeper"               )   or
        ( keyvalues["craft"]   == "bookbinder"              )   or
        ( keyvalues["craft"]   == "carpet_layer"            )   or
        ( keyvalues["craft"]   == "cabinet_maker"           )   or
        ( keyvalues["craft"]   == "caterer"                 )   or
        ( keyvalues["craft"]   == "cleaning"                )   or
        ( keyvalues["craft"]   == "clockmaker"              )   or
        ( keyvalues["craft"]   == "confectionery"           )   or
        ( keyvalues["craft"]   == "dental_technician"       )   or
        ( keyvalues["craft"]   == "engineering"             )   or
        ( keyvalues["craft"]   == "furniture"               )   or
        ( keyvalues["craft"]   == "furniture_maker"         )   or
        ( keyvalues["craft"]   == "gardener"                )   or
        ( keyvalues["craft"]   == "handicraft"              )   or
        ( keyvalues["craft"]   == "insulation"              )   or
        ( keyvalues["craft"]   == "joiner"                  )   or
        ( keyvalues["craft"]   == "metal_construction"      )   or
        ( keyvalues["craft"]   == "painter"                 )   or
        ( keyvalues["craft"]   == "plasterer"               )   or
        ( keyvalues["craft"]   == "photographic_laboratory" )   or
        ( keyvalues["craft"]   == "saddler"                 )   or
        ( keyvalues["craft"]   == "sailmaker"               )   or
        ( keyvalues["craft"]   == "scaffolder"              )   or
        ( keyvalues["craft"]   == "tiler"                   )   or
        ( keyvalues["craft"]   == "watchmaker"              ))) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["office"]  = "nonspecific"
      keyvalues["craft"]   = nil
   end

-- ----------------------------------------------------------------------------
-- Telephone Exchanges
-- ----------------------------------------------------------------------------
   if ((   keyvalues["man_made"]   == "telephone_exchange"  )  or
       (   keyvalues["amenity"]    == "telephone_exchange"  )  or
       ((  keyvalues["building"]   == "telephone_exchange" )   and
        (( keyvalues["amenity"]    == nil                 )    and
         ( keyvalues["man_made"]   == nil                 )    and
         ( keyvalues["office"]     == nil                 ))   or
        (  keyvalues["telecom"]    == "exchange"           ))) then
      if ( keyvalues["name"] == nil ) then
         keyvalues["name"]  = "Telephone Exchange"
      end

      keyvalues["office"]  = "nonspecific"
   end

-- ----------------------------------------------------------------------------
-- If we know that something is a building=office, and it has a name, but is
-- not already known as an amenity, office or shop, add office=nonspecific.
-- ----------------------------------------------------------------------------
   if (( keyvalues["building"] == "office" ) and
       ( keyvalues["name"]     ~= nil      ) and
       ( keyvalues["amenity"]  == nil      ) and
       ( keyvalues["office"]   == nil      ) and
       ( keyvalues["shop"]     == nil      )) then
      keyvalues["office"]  = "nonspecific"
   end

-- ----------------------------------------------------------------------------
-- Offices that we don't know the type of.  
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( keyvalues["office"]     == "company"           ) or
       ( keyvalues["shop"]       == "office"            ) or
       ( keyvalues["amenity"]    == "office"            ) or
       ( keyvalues["office"]     == "private"           ) or
       ( keyvalues["office"]     == "research"          ) or
       ( keyvalues["office"]     == "yes"               ) or
       ( keyvalues["commercial"] == "office"            )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["office"]  = "nonspecific"
   end

-- ----------------------------------------------------------------------------
-- emergency=water_rescue is a poorly-designed key that makes it difficult to
-- tell e.g. lifeboats from lifeboat stations.
-- However, if we've got one of various buildings, it's a lifeboat station.
-- ----------------------------------------------------------------------------
   if (  keyvalues["emergency"] == "water_rescue" ) then
      if (( keyvalues["building"]  == "boathouse"        ) or
          ( keyvalues["building"]  == "commercial"       ) or
          ( keyvalues["building"]  == "container"        ) or
          ( keyvalues["building"]  == "house"            ) or
          ( keyvalues["building"]  == "industrial"       ) or
          ( keyvalues["building"]  == "lifeboat_station" ) or
          ( keyvalues["building"]  == "no"               ) or
          ( keyvalues["building"]  == "office"           ) or
          ( keyvalues["building"]  == "public"           ) or
          ( keyvalues["building"]  == "retail"           ) or
          ( keyvalues["building"]  == "roof"             ) or
          ( keyvalues["building"]  == "ruins"            ) or
          ( keyvalues["building"]  == "service"          ) or
          ( keyvalues["building"]  == "yes"              )) then
         keyvalues["emergency"] = "lifeboat_station"
      else
         if (( keyvalues["building"]                         == "ship"                ) or
             ( keyvalues["seamark:rescue_station:category"]  == "lifeboat_on_mooring" )) then
            keyvalues["amenity"]   = "lifeboat"
            keyvalues["emergency"] = nil
         else
            keyvalues["emergency"] = "lifeboat_station"
         end
      end
   end

-- ----------------------------------------------------------------------------
-- Handling of objects not (yet) tagfiddled to "emergency=water_rescue":
-- Sometimes lifeboats are mapped in the see separately to the 
-- lifeboat station, and sometimes they're tagged _on_ the lifeboat station.
-- If the latter, show the lifeboat station.
-- Also detect lifeboats and coastguards tagged only as seamarks.
--
-- See below for the similar but different tag "emergency=water_rescue_station"
-- which seems to be used on buildings, huts, etc. (not lifeboats).
-- ----------------------------------------------------------------------------
   if (( keyvalues["seamark:rescue_station:category"] == "lifeboat_on_mooring" ) and
       ( keyvalues["amenity"]                         == nil                   )) then
      keyvalues["amenity"]  = "lifeboat"
   end

   if (( keyvalues["seamark:type"] == "coastguard_station" ) and
       ( keyvalues["amenity"]      == nil                  )) then
      keyvalues["amenity"]  = "coast_guard"
   end

   if (( keyvalues["amenity"]   == "lifeboat"         ) and
       ( keyvalues["emergency"] == "lifeboat_station" )) then
      keyvalues["amenity"]  = nil
   end

-- ----------------------------------------------------------------------------
-- Similarly, various government offices.  Job Centres first.
-- Lifeboat stations are also in here.
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["amenity"]    == "job_centre"               ) or
       (  keyvalues["amenity"]    == "jobcentre"                ) or
       (  keyvalues["name"]       == "Jobcentre Plus"           ) or
       (  keyvalues["name"]       == "JobCentre Plus"           ) or
       (  keyvalues["name"]       == "Job Centre Plus"          ) or
       (  keyvalues["office"]     == "government"               ) or
       (  keyvalues["office"]     == "police"                   ) or
       (  keyvalues["government"] == "police"                   ) or
       (  keyvalues["amenity"]    == "public_building"          ) or
       (  keyvalues["office"]     == "administrative"           ) or
       (  keyvalues["office"]     == "register"                 ) or
       (  keyvalues["amenity"]    == "register_office"          ) or
       (  keyvalues["office"]     == "council"                  ) or
       (  keyvalues["office"]     == "drainage_board"           ) or
       (  keyvalues["office"]     == "forestry"                 ) or
       (  keyvalues["amenity"]    == "courthouse"               ) or
       (  keyvalues["office"]     == "justice"                  ) or
       (  keyvalues["amenity"]    == "townhall"                 ) or
       (  keyvalues["amenity"]    == "village_hall"             ) or
       (  keyvalues["building"]   == "village_hall"             ) or
       (  keyvalues["amenity"]    == "crematorium"              ) or
       (  keyvalues["amenity"]    == "hall"                     ) or
       (  keyvalues["amenity"]    == "fire_station"             ) or
       (  keyvalues["emergency"]  == "fire_station"             ) or
       (  keyvalues["amenity"]    == "lifeboat_station"         ) or
       (  keyvalues["emergency"]  == "lifeboat_station"         ) or
       (  keyvalues["emergency"]  == "lifeguard_tower"          ) or
       (  keyvalues["emergency"]  == "water_rescue_station"     ) or
       (( keyvalues["emergency"]  == "lifeguard"               )  and
        (( keyvalues["lifeguard"] == "base"                   )   or
         ( keyvalues["lifeguard"] == "tower"                  ))) or
       (  keyvalues["amenity"]    == "coast_guard"              ) or
       (  keyvalues["emergency"]  == "coast_guard"              ) or
       (  keyvalues["emergency"]  == "ses_station"              ) or
       (  keyvalues["amenity"]    == "archive"                  )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["office"]  = "nonspecific"
      keyvalues["government"]  = nil
      keyvalues["tourism"]  = nil
   end

-- ----------------------------------------------------------------------------
-- Ambulance stations
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"]   == "ambulance_station"       ) or
       ( keyvalues["emergency"] == "ambulance_station"       )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["amenity"]  = "ambulance_station"
   end

   if (( keyvalues["amenity"]   == "mountain_rescue"       ) or
       ( keyvalues["emergency"] == "mountain_rescue"       )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["amenity"]  = "mountain_rescue"

      if ( keyvalues["name"] == nil ) then
         keyvalues["name"] = "Mountain Rescue"
      end
   end

   if (( keyvalues["amenity"]   == "mountain_rescue_box"       ) or
       ( keyvalues["emergency"] == "rescue_box"                )) then
      keyvalues["amenity"]  = "mountain_rescue_box"

      if ( keyvalues["name"] == nil ) then
         keyvalues["name"] = "Mountain Rescue Supplies"
      end
   end

-- ----------------------------------------------------------------------------
-- Current monasteries et al go through as "amenity=monastery"
-- Note that historic=gate are generally much smaller and are not included here.
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "monastery" ) or
       ( keyvalues["amenity"] == "convent"   )) then
      keyvalues["amenity"] = "monastery"

      if ( keyvalues["landuse"] == nil ) then
         keyvalues["landuse"] = "unnamedcommercial"
      end
   end

-- ----------------------------------------------------------------------------
-- Non-government (commercial) offices that you might visit for a service.
-- "communication" below seems to be used for marketing / commercial PR.
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( keyvalues["office"]      == "it"                      ) or
       ( keyvalues["office"]      == "computer"                ) or
       ( keyvalues["office"]      == "consulting"              ) or
       ( keyvalues["office"]      == "construction_company"    ) or
       ( keyvalues["office"]      == "courier"                 ) or
       ( keyvalues["office"]      == "advertising"             ) or
       ( keyvalues["office"]      == "advertising_agency"      ) or
       ( keyvalues["amenity"]     == "post_depot"              ) or
       ( keyvalues["office"]      == "lawyer"                  ) or
       ( keyvalues["shop"]        == "lawyer"                  ) or
       ( keyvalues["amenity"]     == "lawyer"                  ) or
       ( keyvalues["shop"]        == "legal"                   ) or
       ( keyvalues["office"]      == "solicitor"               ) or
       ( keyvalues["shop"]        == "solicitor"               ) or
       ( keyvalues["amenity"]     == "solicitor"               ) or
       ( keyvalues["office"]      == "solicitors"              ) or
       ( keyvalues["amenity"]     == "solicitors"              ) or
       ( keyvalues["office"]      == "accountant"              ) or
       ( keyvalues["shop"]        == "accountant"              ) or
       ( keyvalues["office"]      == "accountants"             ) or
       ( keyvalues["amenity"]     == "accountants"             ) or
       ( keyvalues["office"]      == "tax_advisor"             ) or
       ( keyvalues["amenity"]     == "tax_advisor"             ) or
       ( keyvalues["office"]      == "employment_agency"       ) or
       ( keyvalues["office"]      == "home_care"               ) or
       ( keyvalues["healthcare"]  == "home_care"               ) or
       ( keyvalues["shop"]        == "employment_agency"       ) or
       ( keyvalues["shop"]        == "employment"              ) or
       ( keyvalues["shop"]        == "jobs"                    ) or
       ( keyvalues["office"]      == "recruitment_agency"      ) or
       ( keyvalues["office"]      == "recruitment"             ) or
       ( keyvalues["shop"]        == "recruitment"             ) or
       ( keyvalues["office"]      == "insurance"               ) or
       ( keyvalues["office"]      == "architect"               ) or
       ( keyvalues["office"]      == "telecommunication"       ) or
       ( keyvalues["office"]      == "financial"               ) or
       ( keyvalues["office"]      == "newspaper"               ) or
       ( keyvalues["office"]      == "delivery"                ) or
       ( keyvalues["amenity"]     == "delivery_office"         ) or
       ( keyvalues["amenity"]     == "sorting_office"          ) or
       ( keyvalues["office"]      == "parcel"                  ) or
       ( keyvalues["office"]      == "therapist"               ) or
       ( keyvalues["office"]      == "surveyor"                ) or
       ( keyvalues["office"]      == "geodesist"               ) or
       ( keyvalues["office"]      == "marketing"               ) or
       ( keyvalues["office"]      == "graphic_design"          ) or
       ( keyvalues["office"]      == "interior_design"         ) or
       ( keyvalues["office"]      == "builder"                 ) or
       ( keyvalues["office"]      == "training"                ) or
       ( keyvalues["office"]      == "web_design"              ) or
       ( keyvalues["office"]      == "design"                  ) or
       ( keyvalues["shop"]        == "design"                  ) or
       ( keyvalues["office"]      == "communication"           ) or
       ( keyvalues["office"]      == "security"                ) or
       ( keyvalues["office"]      == "engineer"                ) or
       ( keyvalues["office"]      == "engineering"             ) or
       ( keyvalues["craft"]       == "hvac"                    ) or
       ( keyvalues["office"]      == "hvac"                    ) or
       ( keyvalues["shop"]        == "heating"                 ) or
       ( keyvalues["office"]      == "laundry"                 ) or
       ( keyvalues["amenity"]     == "coworking_space"         ) or
       ( keyvalues["office"]      == "coworking"               ) or
       ( keyvalues["office"]      == "coworking_space"         ) or
       ( keyvalues["office"]      == "serviced_offices"        ) or
       ( keyvalues["amenity"]     == "studio"                  ) or
       ( keyvalues["amenity"]     == "prison"                  ) or
       ( keyvalues["amenity"]     == "music_school"            ) or
       ( keyvalues["amenity"]     == "cooking_school"          ) or
       ( keyvalues["craft"]       == "electrician"             ) or
       ( keyvalues["craft"]       == "electrician;plumber"     ) or
       ( keyvalues["office"]      == "electrician"             ) or
       ( keyvalues["shop"]        == "electrician"             )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["office"] = "nonspecific"
   end

-- ----------------------------------------------------------------------------
-- Other nonspecific offices.  
-- If any of the "diplomatic" ones should be shown as embassies, the "office"
-- tag will have been removed above.
-- ----------------------------------------------------------------------------
   if (( keyvalues["office"]     == "it"                      ) or
       ( keyvalues["office"]     == "ngo"                     ) or
       ( keyvalues["office"]     == "organization"            ) or
       ( keyvalues["office"]     == "diplomatic"              ) or
       ( keyvalues["office"]     == "educational_institution" ) or
       ( keyvalues["office"]     == "university"              ) or
       ( keyvalues["office"]     == "charity"                 ) or
       ((  keyvalues["office"]          == nil               )  and
        (( keyvalues["social_facility"] == "outreach"       )  or
         ( keyvalues["social_facility"] == "food_bank"      ))) or
       ( keyvalues["office"]     == "religion"                ) or
       ( keyvalues["office"]     == "marriage_guidance"       ) or
       ( keyvalues["amenity"]    == "education_centre"        ) or
       ( keyvalues["man_made"]   == "observatory"             ) or
       ( keyvalues["man_made"]   == "telescope"               ) or
       ( keyvalues["amenity"]    == "laboratory"              ) or
       ( keyvalues["healthcare"] == "laboratory"              ) or
       ( keyvalues["amenity"]    == "medical_laboratory"      ) or
       ( keyvalues["amenity"]    == "research_institute"      ) or
       ( keyvalues["office"]     == "political_party"         ) or
       ( keyvalues["office"]     == "politician"              ) or
       ( keyvalues["office"]     == "political"               ) or
       ( keyvalues["office"]     == "property_maintenance"    ) or
       ( keyvalues["office"]     == "quango"                  ) or
       ( keyvalues["office"]     == "association"             ) or
       ( keyvalues["amenity"]    == "advice"                  ) or
       ( keyvalues["amenity"]    == "advice_service"          )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["office"]  = "nonspecific"
   end

-- ----------------------------------------------------------------------------
-- Similarly, nonspecific leisure facilities.
-- Non-private swimming pools:
--
-- Note - this is an old tag that was often used for the whole area 
-- (building etc.) of a swimming pool, although the wiki documentation wasn't 
-- explicit.  It corresponds best with "leisure=sports_centre" 
-- (rendered in its own right).  "leisure=swimming_pool" is for the wet bit;
-- that is also rendered in its own right (in blue).
-- Note there's no explicit "if private" check on the wet bit.
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "swimming_pool" ) and
       ( keyvalues["access"]  ~= "no"            )) then
      keyvalues["leisure"] = "leisurenonspecific"
   end

-- ----------------------------------------------------------------------------
-- Render outdoor swimming areas with blue names (if named)
-- leisure=pool is either a turkish bath, a hot spring or a private 
-- swimming pool.
-- leisure=swimming is either a mistagged swimming area or a 
-- mistagged swimming pool
-- ----------------------------------------------------------------------------
   if (( keyvalues["leisure"] == "swimming_area" ) or
       ( keyvalues["leisure"] == "pool"          ) or
       ( keyvalues["leisure"] == "swimming"      )) then
      keyvalues["leisure"] = "swimming_pool"
   end

-- ----------------------------------------------------------------------------
-- A couple of odd sports taggings:
-- ----------------------------------------------------------------------------
   if ( keyvalues["leisure"] == "sport" ) then
      if ( keyvalues["sport"]   == "golf"  ) then
         keyvalues["leisure"] = "golf_course"
      else
         keyvalues["leisure"] = "leisurenonspecific"
      end
   end

-- ----------------------------------------------------------------------------
-- Try and catch grass on horse_riding
-- ----------------------------------------------------------------------------
   if ( keyvalues["leisure"] == "horse_riding" ) then
      keyvalues["leisure"] = "leisurenonspecific"

      if (( keyvalues["surface"] == "grass" ) and
          ( keyvalues["landuse"] == nil     )) then
         keyvalues["landuse"] = "unnamedgrass"
      end
   end

-- ----------------------------------------------------------------------------
-- If we have any named leisure=outdoor_seating left, 
-- change it to "leisurenonspecific", but don't set landuse.
-- ----------------------------------------------------------------------------
   if (( keyvalues["leisure"] == "outdoor_seating" ) and
       ( keyvalues["name"]    ~= nil               )) then
      keyvalues["leisure"] = "leisurenonspecific"
   end

-- ----------------------------------------------------------------------------
-- Mazes
-- ----------------------------------------------------------------------------
   if ((( keyvalues["leisure"]    == "maze" ) or
        ( keyvalues["attraction"] == "maze" )) and
       (  keyvalues["historic"]   == nil     )) then
      keyvalues["leisure"] = "leisurenonspecific"
      keyvalues["tourism"] = nil
   end

-- ----------------------------------------------------------------------------
-- Other nonspecific leisure.  We add an icon and label via "leisurenonspecific".
-- In most cases we also add unnamedcommercial landuse 
-- to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"]  == "arts_centre"              ) or
       ( keyvalues["amenity"]  == "bingo"                    ) or
       ( keyvalues["amenity"]  == "boat_rental"              ) or
       ( keyvalues["amenity"]  == "brothel"                  ) or
       ( keyvalues["amenity"]  == "church_hall"              ) or
       ( keyvalues["amenity"]  == "club"                     ) or
       ( keyvalues["amenity"]  == "club_house"               ) or
       ( keyvalues["amenity"]  == "clubhouse"                ) or
       ( keyvalues["amenity"]  == "community_centre"         ) or
       ( keyvalues["amenity"]  == "community_hall"           ) or
       ( keyvalues["amenity"]  == "conference_centre"        ) or
       ( keyvalues["amenity"]  == "dancing_school"           ) or
       ( keyvalues["amenity"]  == "dojo"                     ) or
       ( keyvalues["amenity"]  == "escape_game"              ) or
       ( keyvalues["amenity"]  == "events_venue"             ) or
       ( keyvalues["amenity"]  == "exhibition_centre"        ) or
       ( keyvalues["amenity"]  == "function_room"            ) or
       ( keyvalues["amenity"]  == "gym"                      ) or
       ( keyvalues["amenity"]  == "outdoor_education_centre" ) or
       ( keyvalues["amenity"]  == "public_bath"              ) or
       ( keyvalues["amenity"]  == "scout_hall"               ) or
       ( keyvalues["amenity"]  == "scout_hut"                ) or
       ( keyvalues["amenity"]  == "social_centre"            ) or
       ( keyvalues["amenity"]  == "social_club"              ) or
       ( keyvalues["amenity"]  == "working_mens_club"        ) or
       ( keyvalues["amenity"]  == "youth_centre"             ) or
       ( keyvalues["amenity"]  == "youth_club"               ) or
       ( keyvalues["building"] == "club_house"               ) or
       ( keyvalues["building"] == "clubhouse"                ) or
       ( keyvalues["building"] == "community_centre"         ) or
       ( keyvalues["building"] == "scout_hut"                ) or
       ( keyvalues["club"]     == "scout"                    ) or
       ( keyvalues["club"]     == "scouts"                   ) or
       ( keyvalues["club"]     == "sport"                    ) or
       ((( keyvalues["club"]    == "yes"                   )   or
         ( keyvalues["club"]    == "social"                )   or
         ( keyvalues["club"]    == "freemasonry"           )   or
         ( keyvalues["club"]    == "sailing"               )   or
         ( keyvalues["club"]    == "youth"                 )   or
         ( keyvalues["club"]    == "politics"              )   or
         ( keyvalues["club"]    == "veterans"              )   or
         ( keyvalues["club"]    == "social_club"           )   or
         ( keyvalues["club"]    == "music"                 )   or
         ( keyvalues["club"]    == "working_men"           )   or
         ( keyvalues["club"]    == "yachting"              )   or
         ( keyvalues["club"]    == "tennis"                )   or
         ( keyvalues["club"]    == "army_cadets"           )   or
         ( keyvalues["club"]    == "sports"                )   or
         ( keyvalues["club"]    == "rowing"                )   or
         ( keyvalues["club"]    == "football"              )   or
         ( keyvalues["club"]    == "snooker"               )   or
         ( keyvalues["club"]    == "fishing"               )   or
         ( keyvalues["club"]    == "sea_scout"             )   or
         ( keyvalues["club"]    == "conservative"          )   or
         ( keyvalues["club"]    == "golf"                  )   or
         ( keyvalues["club"]    == "cadet"                 )   or
         ( keyvalues["club"]    == "youth_movement"        )   or
         ( keyvalues["club"]    == "bridge"                )   or
         ( keyvalues["club"]    == "bowling"               )   or
         ( keyvalues["club"]    == "air_cadets"            )   or
         ( keyvalues["club"]    == "scuba_diving"          )   or
         ( keyvalues["club"]    == "model_railway"         )   or
         ( keyvalues["club"]    == "boat"                  )   or
         ( keyvalues["club"]    == "card_games"            )   or
         ( keyvalues["club"]    == "girlguiding"           )   or
         ( keyvalues["club"]    == "guide"                 )   or
         ( keyvalues["club"]    == "photography"           )   or
         ( keyvalues["club"]    == "sea_cadets"            )   or
         ( keyvalues["club"]    == "theatre"               )   or
         ( keyvalues["club"]    == "women"                 )   or
         ( keyvalues["club"]    == "charity"               )   or
         ( keyvalues["club"]    == "bowls"                 )   or
         ( keyvalues["club"]    == "military"              )   or
         ( keyvalues["club"]    == "model_aircraft"        )   or
         ( keyvalues["club"]    == "labour_club"           )   or
         ( keyvalues["club"]    == "boxing"                )   or
         ( keyvalues["club"]    == "game"                  )   or
         ( keyvalues["club"]    == "automobile"            ))  and
        (  keyvalues["leisure"] == nil                      )  and
        (  keyvalues["amenity"] == nil                      )  and
        (  keyvalues["shop"]    == nil                      )  and
        (  keyvalues["name"]    ~= nil                      )) or
       ((  keyvalues["club"]    == "cricket"                )  and
        (  keyvalues["leisure"] == nil                      )  and
        (  keyvalues["amenity"] == nil                      )  and
        (  keyvalues["shop"]    == nil                      )  and
        (  keyvalues["landuse"] == nil                      )  and
        (  keyvalues["name"]    ~= nil                      )) or
       ( keyvalues["gambling"] == "bingo"                    ) or
       ( keyvalues["leisure"]  == "adventure_park"           ) or
       ( keyvalues["leisure"]  == "beach_resort"             ) or
       ( keyvalues["leisure"]  == "bingo"                    ) or
       ( keyvalues["leisure"]  == "bingo_hall"               ) or
       ( keyvalues["leisure"]  == "bowling_alley"            ) or
       ( keyvalues["leisure"]  == "climbing"                 ) or
       ( keyvalues["leisure"]  == "club"                     ) or
       ( keyvalues["leisure"]  == "dance"                    ) or
       ( keyvalues["leisure"]  == "dojo"                     ) or
       ( keyvalues["leisure"]  == "escape_game"              ) or
       ( keyvalues["leisure"]  == "firepit"                  ) or
       ( keyvalues["leisure"]  == "fitness_centre"           ) or
       ( keyvalues["leisure"]  == "hackerspace"              ) or
       ( keyvalues["leisure"]  == "high_ropes_course"        ) or
       ( keyvalues["leisure"]  == "horse_riding"             ) or
       ( keyvalues["leisure"]  == "ice_rink"                 ) or
       (( keyvalues["leisure"] == "indoor_golf"             )  and
        ( keyvalues["amenity"] == nil                       )) or
       ( keyvalues["leisure"]  == "indoor_play"              ) or
       ( keyvalues["leisure"]  == "inflatable_park"          ) or
       ( keyvalues["leisure"]  == "miniature_golf"           ) or
       ( keyvalues["leisure"]  == "resort"                   ) or
       ( keyvalues["leisure"]  == "sailing_club"             ) or
       ( keyvalues["leisure"]  == "sauna"                    ) or
       ( keyvalues["leisure"]  == "social_club"              ) or
       ( keyvalues["leisure"]  == "soft_play"                ) or
       ( keyvalues["leisure"]  == "summer_camp"              ) or
       ( keyvalues["leisure"]  == "trampoline"               ) or
       ( keyvalues["playground"]  == "trampoline"            ) or
       ( keyvalues["leisure"]  == "trampoline_park"          ) or
       ( keyvalues["leisure"]  == "water_park"               ) or
       ( keyvalues["leisure"]  == "yoga"                     ) or
       (( keyvalues["leisure"]        == nil                )  and
        ( keyvalues["amenity"]        == nil                )  and
        ( keyvalues["shop"]           == nil                )  and
        ( keyvalues["dance:teaching"] == "yes"              )) or
       ( keyvalues["name"]     == "Bingo Hall"               ) or
       ( keyvalues["name"]     == "Castle Bingo"             ) or
       ( keyvalues["name"]     == "Gala Bingo"               ) or
       ( keyvalues["name"]     == "Mecca Bingo"              ) or
       ( keyvalues["name"]     == "Scout Hall"               ) or
       ( keyvalues["name"]     == "Scout Hut"                ) or
       ( keyvalues["name"]     == "Scout hut"                ) or
       ( keyvalues["shop"]     == "boat_rental"              ) or
       ( keyvalues["shop"]     == "fitness"                  ) or
       ( keyvalues["sport"]    == "laser_tag"                ) or
       ( keyvalues["sport"]    == "model_aerodrome"          ) or
       ((( keyvalues["sport"]   == "yoga"                  )   or
         ( keyvalues["sport"]   == "yoga;pilates"          ))  and
        ( keyvalues["shop"]     == nil                      )  and
        ( keyvalues["amenity"]  == nil                      )) or
       ( keyvalues["tourism"]  == "cabin"                    ) or
       ( keyvalues["tourism"]  == "resort"                   ) or
       ( keyvalues["tourism"]  == "trail_riding_station"     ) or
       ( keyvalues["tourism"]  == "wilderness_hut"           ) or
       (( keyvalues["building"] == "yes"                    )  and
        ( keyvalues["amenity"]  == nil                      )  and
        ( keyvalues["leisure"]  == nil                      )  and
        ( keyvalues["sport"]    ~= nil                      ))) then
      if ( keyvalues["landuse"] == nil ) then
         keyvalues["landuse"] = "unnamedcommercial"
      end

      keyvalues["leisure"] = "leisurenonspecific"
      keyvalues["disused:amenity"] = nil
   end

-- ----------------------------------------------------------------------------
-- Some museum / leisure combinations are likely more "leisury" than "museumy"
-- ----------------------------------------------------------------------------
   if (( keyvalues["tourism"] == "museum"             ) and 
       ( keyvalues["leisure"] == "leisurenonspecific" )) then
      keyvalues["tourism"] = nil
   end

-- ----------------------------------------------------------------------------
-- Emergency phones
-- ----------------------------------------------------------------------------
   if (( keyvalues["emergency"] == "phone" ) and
       ( keyvalues["amenity"]   == nil     )) then
      keyvalues["amenity"] = "emergency_phone"
   end

-- ----------------------------------------------------------------------------
-- A special case to check before the "vacant shops" check at the end - 
-- potentially remove disused:amenity=grave_yard
-- ----------------------------------------------------------------------------
   if (( keyvalues["disused:amenity"] == "grave_yard" ) and
       ( keyvalues["landuse"]         == "cemetery"   )) then
      keyvalues["disused:amenity"] = nil
   end

-- ----------------------------------------------------------------------------
-- Cemeteries are separated by religion here.
-- "unnamed" is potentially set lower down.  All 6 are selected in project.mml.
--
-- There is a special case for Jehovahs Witnesses - don't use the normal Christian
-- symbol (a cross)
-- ----------------------------------------------------------------------------
   if ( keyvalues["landuse"] == "cemetery" ) then
      if ( keyvalues["religion"] == "christian" ) then
         if ( keyvalues["denomination"] == "jehovahs_witness" ) then
            keyvalues["landuse"] = "othercemetery"
         else
            keyvalues["landuse"] = "christiancemetery"
         end
      else
         if ( keyvalues["religion"] == "jewish" ) then
            keyvalues["landuse"] = "jewishcemetery"
         else
            keyvalues["landuse"] = "othercemetery"
         end
      end
   end

-- ----------------------------------------------------------------------------
-- Treat heliports as aerodromes.
-- Done before the "disused" logic below and the "large/small" logic 
-- further down.
--
-- Heliports are similar to airports, except an icao code (present on many
-- more airports) can also determine that a heliport is "public".
-- ----------------------------------------------------------------------------
   if ( keyvalues["aeroway"] == "heliport" ) then
      keyvalues["aeroway"] = "aerodrome"

      if (( keyvalues["iata"]  == nil )  and
          ( keyvalues["icao"]  ~= nil )) then
         keyvalues["iata"] = keyvalues["icao"]
      end
   end

-- ----------------------------------------------------------------------------
-- Disused aerodromes etc. - handle disused=yes.
-- ----------------------------------------------------------------------------
   if (( keyvalues["aeroway"]        == "aerodrome" ) and
       ( keyvalues["disused"]        == "yes"       )) then
      keyvalues["aeroway"] = nil
      keyvalues["disused:aeroway"] = "aerodrome"
   end

   if (( keyvalues["aeroway"]        == "runway" ) and
       ( keyvalues["disused"]        == "yes"       )) then
      keyvalues["aeroway"] = nil
      keyvalues["disused:aeroway"] = "runway"
   end

   if (( keyvalues["aeroway"]        == "taxiway" ) and
       ( keyvalues["disused"]        == "yes"       )) then
      keyvalues["aeroway"] = nil
      keyvalues["disused:aeroway"] = "taxiway"
   end

-- ----------------------------------------------------------------------------
-- If a quarry is disused or historic, it's still likely a hole in the ground, 
-- so render it as something.
-- However, if there's a natural tag, that should take precendence, and 
-- landuse is cleared.
-- ----------------------------------------------------------------------------
   if (((  keyvalues["disused:landuse"] == "quarry"  )  and
        (  keyvalues["landuse"]         == nil       )) or
       ((  keyvalues["historic"]        == "quarry"  )  and
        (  keyvalues["landuse"]         == nil       )) or
       ((  keyvalues["landuse"]         == "quarry"  )  and
        (( keyvalues["disused"]         == "yes"    )   or
         ( keyvalues["historic"]        == "yes"    )))) then
      if ( keyvalues["natural"] == nil ) then
         keyvalues["landuse"] = "historicquarry"
      else
         keyvalues["landuse"] = nil
      end
   end

-- ----------------------------------------------------------------------------
-- Where both historic and natural might carry a name, we need to change some
-- natural tags to unnamed versions
-- ----------------------------------------------------------------------------
   if (( keyvalues["historic"] == "archaeological_site"   ) or
       ( keyvalues["historic"] == "battlefield"           ) or
       ( keyvalues["historic"] == "castle"                ) or
       ( keyvalues["historic"] == "church"                ) or
       ( keyvalues["historic"] == "historicfortification" ) or
       ( keyvalues["historic"] == "historichillfort"      ) or
       ( keyvalues["historic"] == "historicmegalithtomb"  ) or
       ( keyvalues["historic"] == "historicringfort"      ) or
       ( keyvalues["historic"] == "historicstandingstone" ) or
       ( keyvalues["historic"] == "historicstonecircle"   ) or
       ( keyvalues["historic"] == "historictumulus"       ) or
       ( keyvalues["historic"] == "manor"                 ) or
       ( keyvalues["historic"] == "memorial"              ) or
       ( keyvalues["historic"] == "memorialobelisk"       ) or
       ( keyvalues["historic"] == "monastery"             ) or
       ( keyvalues["historic"] == "mineshaft"             ) or
       ( keyvalues["historic"] == "nonspecific"           ) or
       ( keyvalues["leisure"]  == "nature_reserve"        )) then
      if ( keyvalues["natural"] == "wood" ) then
         keyvalues["natural"] = "unnamedwood"
      end

      if ( keyvalues["natural"] == "broadleaved" ) then
         keyvalues["natural"] = "unnamedbroadleaved"
      end

      if ( keyvalues["natural"] == "mixedleaved" ) then
         keyvalues["natural"] = "unnamedmixedleaved"
      end

      if ( keyvalues["natural"] == "needleleaved" ) then
         keyvalues["natural"] = "unnamedneedleleaved"
      end

      if ( keyvalues["natural"] == "heath" ) then
         keyvalues["natural"] = "unnamedheath"
      end

      if ( keyvalues["natural"] == "scrub" ) then
         keyvalues["natural"] = "unnamedscrub"
      end
   end

-- ----------------------------------------------------------------------------
-- Change commercial landuse from aerodromes so that no name is displayed 
-- from that.
-- There's a similar issue with e.g. leisure=fishing / landuse=grass, which has
-- already been rewritten to "park" by now.
-- Some combinations are incompatible so we "just need to pick one".
-- ----------------------------------------------------------------------------
   if (( keyvalues["aeroway"]  == "aerodrome"             ) or
       ( keyvalues["historic"] == "archaeological_site"   ) or
       ( keyvalues["historic"] == "battlefield"           ) or
       ( keyvalues["historic"] == "castle"                ) or
       ( keyvalues["historic"] == "church"                ) or
       ( keyvalues["historic"] == "historicfortification" ) or
       ( keyvalues["historic"] == "historichillfort"      ) or
       ( keyvalues["historic"] == "historicmegalithtomb"  ) or
       ( keyvalues["historic"] == "historicringfort"      ) or
       ( keyvalues["historic"] == "historicstandingstone" ) or
       ( keyvalues["historic"] == "historicstonecircle"   ) or
       ( keyvalues["historic"] == "historictumulus"       ) or
       ( keyvalues["historic"] == "manor"                 ) or
       ( keyvalues["historic"] == "memorial"              ) or
       ( keyvalues["historic"] == "memorialobelisk"       ) or
       ( keyvalues["historic"] == "monastery"             ) or
       ( keyvalues["historic"] == "mineshaft"             ) or
       ( keyvalues["historic"] == "nonspecific"           ) or
       ( keyvalues["leisure"]  == "common"                ) or
       ( keyvalues["leisure"]  == "garden"                ) or
       ( keyvalues["leisure"]  == "nature_reserve"        ) or
       ( keyvalues["leisure"]  == "park"                  ) or
       ( keyvalues["leisure"]  == "pitch"                 ) or
       ( keyvalues["leisure"]  == "sports_centre"         ) or
       ( keyvalues["leisure"]  == "track"                 )) then
      if ( keyvalues["landuse"] == "allotments" ) then
         keyvalues["landuse"] = "unnamedallotments"
      end

      if ( keyvalues["landuse"] == "christiancemetery" ) then
         keyvalues["landuse"] = "unnamedchristiancemetery"
      end

      if ( keyvalues["landuse"] == "jewishcemetery" ) then
         keyvalues["landuse"] = "unnamedjewishcemetery"
      end

      if ( keyvalues["landuse"] == "othercemetery" ) then
         keyvalues["landuse"] = "unnamedothercemetery"
      end

      if ( keyvalues["landuse"] == "commercial" ) then
         keyvalues["landuse"] = "unnamedcommercial"
      end

      if (( keyvalues["landuse"] == "construction" )  or
          ( keyvalues["landuse"] == "brownfield"   )  or
          ( keyvalues["landuse"] == "greenfield"   )) then
         keyvalues["landuse"] = "unnamedconstruction"
      end

      if ( keyvalues["landuse"] == "farmland" ) then
         keyvalues["landuse"] = "unnamedfarmland"
      end

      if ( keyvalues["landuse"] == "farmgrass" ) then
         keyvalues["landuse"] = "unnamedfarmgrass"
      end

      if ( keyvalues["landuse"] == "farmyard" ) then
         keyvalues["landuse"] = "unnamedfarmyard"
      end

      if ( keyvalues["landuse"] == "forest" ) then
         keyvalues["landuse"] = "unnamedforest"
      end

      if ( keyvalues["landuse"] == "grass" ) then
         keyvalues["landuse"] = "unnamedgrass"
      end

      if ( keyvalues["landuse"] == "industrial" ) then
         keyvalues["landuse"] = "unnamedindustrial"
      end

      if ( keyvalues["landuse"] == "landfill" ) then
         keyvalues["landuse"] = "unnamedlandfill"
      end

      if ( keyvalues["landuse"] == "meadow" ) then
         keyvalues["landuse"] = "unnamedmeadow"
      end

      if ( keyvalues["landuse"] == "meadowwildflower" ) then
         keyvalues["landuse"] = "unnamedmeadowwildflower"
      end

      if ( keyvalues["landuse"] == "meadowperpetual" ) then
         keyvalues["landuse"] = "unnamedmeadowperpetual"
      end

      if ( keyvalues["landuse"] == "meadowtransitional" ) then
         keyvalues["landuse"] = "unnamedmeadowtransitional"
      end

      if ( keyvalues["landuse"] == "orchard" ) then
         keyvalues["landuse"] = "unnamedorchard"
      end

      if ( keyvalues["landuse"]  == "quarry" ) then
         keyvalues["landuse"] = "unnamedquarry"
      end

      if ( keyvalues["landuse"]  == "historicquarry" ) then
         keyvalues["landuse"] = "unnamedhistoricquarry"
      end

      if ( keyvalues["landuse"] == "residential" ) then
         keyvalues["landuse"] = "unnamedresidential"
      end
   end

-- ----------------------------------------------------------------------------
-- Aerodrome size.
-- Large public airports should have an airport icon.  Others should not.
-- ----------------------------------------------------------------------------
   if ( keyvalues["aeroway"] == "aerodrome" ) then
      if (( keyvalues["iata"]           ~= nil         ) and
          ( keyvalues["aerodrome:type"] ~= "military"  ) and
          ( keyvalues["military"]       == nil         )) then
         keyvalues["aeroway"] = "large_aerodrome"

         if ( keyvalues["name"] == nil ) then
            keyvalues["name"] = keyvalues["iata"]
         else
            keyvalues["name"] = keyvalues["name"] .. " (" .. keyvalues["iata"] .. ")"
         end
      else
         if (( keyvalues["aerodrome:type"] == "military"  ) or
             ( keyvalues["military"]       ~= nil         )) then
            keyvalues["aeroway"] = "military_aerodrome"
         end
      end
   end

-- ----------------------------------------------------------------------------
-- Grass runways
-- These are rendered less prominently.
-- ----------------------------------------------------------------------------
   if (( keyvalues["aeroway"] == "runway" ) and
       ( keyvalues["surface"] == "grass"  )) then
      keyvalues["aeroway"] = "grass_runway"
   end

   if (( keyvalues["aeroway"] == "apron"  ) and
       ( keyvalues["surface"] == "grass"  )) then
      keyvalues["landuse"] = "grass"
      keyvalues["aeroway"] = nil
   end

   if (( keyvalues["aeroway"] == "taxiway"  ) and
       ( keyvalues["surface"] == "grass"    )) then
      keyvalues["highway"] = "track"
      keyvalues["aeroway"] = nil
   end


-- ----------------------------------------------------------------------------
-- Render airport parking positions as gates.
-- ----------------------------------------------------------------------------
   if ( keyvalues["aeroway"] == "parking_position" ) then
      keyvalues["aeroway"] = "gate"

      if ( keyvalues["ref"] ~= nil ) then
         keyvalues["ref"] = "(" .. keyvalues["ref"] .. ")"
      end
   end


-- ----------------------------------------------------------------------------
-- Masts etc.  Consolidate various sorts of masts and towers into the "mast"
-- group.  Note that this includes "tower" temporarily, and "campanile" is in 
-- here as a sort of tower (only 2 mapped in UK currently).
-- Also remove any "tourism" tags (which may be semi-valid mapping but are
-- often just "for the renderer").
-- ----------------------------------------------------------------------------
   if ((  keyvalues["man_made"]   == "tower"    ) and
       (( keyvalues["tower:type"] == "cooling" )  or
        ( keyvalues["tower:type"] == "chimney" ))) then
      if (( tonumber(keyvalues["height"]) or 0 ) >  100 ) then
         keyvalues["man_made"] = "bigchimney"
      else
         keyvalues["man_made"] = "chimney"
      end
      keyvalues["tourism"] = nil
   end

   if (( keyvalues["man_made"]   == "tower"    ) and
       ( keyvalues["tower:type"] == "lighting" )) then
      keyvalues["man_made"] = "illuminationtower"
      keyvalues["tourism"] = nil
   end

   if ((   keyvalues["man_made"]           == "tower"       ) and
       ((  keyvalues["tower:type"]         == "defensive"  )  or
        (( keyvalues["tower:type"]         == nil         )   and
         ( keyvalues["tower:construction"] == "stone"     )))) then
      keyvalues["man_made"] = "defensivetower"
      keyvalues["tourism"] = nil
   end

   if (( keyvalues["man_made"]   == "tower"       ) and
       ( keyvalues["tower:type"] == "observation" )) then
      if (( tonumber(keyvalues["height"]) or 0 ) >  100 ) then
         keyvalues["man_made"] = "bigobservationtower"
      else
         keyvalues["man_made"] = "observationtower"
      end
      keyvalues["tourism"] = nil
   end

-- ----------------------------------------------------------------------------
-- Clock towers
-- ----------------------------------------------------------------------------
   if (((  keyvalues["man_made"]   == "tower"        )  and
        (( keyvalues["tower:type"] == "clock"       )   or
         ( keyvalues["building"]   == "clock_tower" )   or
         ( keyvalues["amenity"]    == "clock"       ))) or
       ((  keyvalues["amenity"]    == "clock"        )  and
        (  keyvalues["support"]    == "tower"        ))) then
      keyvalues["man_made"] = "clocktower"
      keyvalues["tourism"] = nil
   end

   if ((  keyvalues["amenity"]    == "clock"         )  and
       (( keyvalues["support"]    == "pedestal"     )   or
        ( keyvalues["support"]    == "pole"         )   or
        ( keyvalues["support"]    == "stone_pillar" )   or
        ( keyvalues["support"]    == "plinth"       )   or
        ( keyvalues["support"]    == "column"       ))) then
      keyvalues["man_made"] = "clockpedestal"
      keyvalues["tourism"] = nil
   end

-- ----------------------------------------------------------------------------
-- Aircraft control towers
-- ----------------------------------------------------------------------------
   if (((  keyvalues["man_made"]   == "tower"             )   and
        (( keyvalues["tower:type"] == "aircraft_control" )    or
         ( keyvalues["service"]    == "aircraft_control" )))  or
       (   keyvalues["aeroway"]    == "control_tower"      )) then
      keyvalues["man_made"] = "aircraftcontroltower"
      keyvalues["building"] = "yes"
      keyvalues["tourism"] = nil
   end

   if ((( keyvalues["man_made"]   == "tower"              )   or
        ( keyvalues["man_made"]   == "monitoring_station" ))  and
       (( keyvalues["tower:type"] == "radar"              )   or
        ( keyvalues["tower:type"] == "weather_radar"      ))) then
      keyvalues["man_made"] = "radartower"
      keyvalues["building"] = "yes"
      keyvalues["tourism"] = nil
   end

-- ----------------------------------------------------------------------------
-- All the domes in the UK are radomes.
-- ----------------------------------------------------------------------------
   if (( keyvalues["man_made"]            == "tower"   ) and
       (( keyvalues["tower:construction"] == "dome"   )  or
        ( keyvalues["tower:construction"] == "dish"   ))) then
      keyvalues["man_made"] = "radartower"
      keyvalues["building"] = "yes"
      keyvalues["tourism"] = nil
   end

   if (( keyvalues["man_made"]   == "tower"                ) and
       ( keyvalues["tower:type"] == "firefighter_training" )) then
      keyvalues["man_made"] = "squaretower"
      keyvalues["building"] = "yes"
      keyvalues["tourism"] = nil
   end

   if ((((  keyvalues["man_made"]    == "tower"             )  and
         (( keyvalues["tower:type"]  == "church"           )   or
          ( keyvalues["tower:type"]  == "square"           )   or
          ( keyvalues["tower:type"]  == "campanile"        )   or
          ( keyvalues["tower:type"]  == "bell_tower"       ))) or
        (   keyvalues["man_made"]    == "campanile"          )) and
       ((   keyvalues["amenity"]     == nil                  )  or
        (   keyvalues["amenity"]     ~= "place_of_worship"   ))) then
      keyvalues["man_made"] = "churchtower"
      keyvalues["tourism"] = nil
   end

   if ((( keyvalues["man_made"]      == "tower"            ) or
        ( keyvalues["building"]      == "tower"            ) or
        ( keyvalues["building:part"] == "yes"              )) and
       ((  keyvalues["tower:type"]   == "spire"            )  or
        (  keyvalues["tower:type"]   == "steeple"          )  or
        (  keyvalues["tower:type"]   == "minaret"          )  or
        (  keyvalues["tower:type"]   == "round"            )) and
       (( keyvalues["amenity"]       == nil                )  or
        ( keyvalues["amenity"]       ~= "place_of_worship" ))) then
      keyvalues["man_made"] = "churchspire"
      keyvalues["building"] = "yes"
      keyvalues["tourism"] = nil
   end

   if (( keyvalues["man_made"] == "phone_mast"           ) or
       ( keyvalues["man_made"] == "radio_mast"           ) or
       ( keyvalues["man_made"] == "communications_mast"  ) or
       ( keyvalues["man_made"] == "tower"                ) or
       ( keyvalues["man_made"] == "communications_tower" ) or
       ( keyvalues["man_made"] == "transmitter"          ) or
       ( keyvalues["man_made"] == "antenna"              ) or
       ( keyvalues["man_made"] == "mast"                 )) then
      if (( tonumber(keyvalues["height"]) or 0 ) >  300 ) then
         keyvalues["man_made"] = "bigmast"
      else
         keyvalues["man_made"] = "mast"
      end
      keyvalues["tourism"] = nil
   end

-- ----------------------------------------------------------------------------
-- Drinking water and water that's not OK for drinking
-- "amenity=drinking_water" is shown as "tap_drinking.p.20.png"
-- "amenity=nondrinking_water" is shown as "tap_nondrinking.p.20.png"
--
-- First, catch any mistagged fountains:
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"]        == "fountain" ) and
       ( keyvalues["drinking_water"] == "yes"      )) then
      keyvalues["amenity"] = "drinking_water"
   end

   if (((( keyvalues["man_made"] == "water_tap"   )   or
         ( keyvalues["waterway"] == "water_point" ))  and
        (  keyvalues["amenity"]  == nil            )) or
       (   keyvalues["amenity"]  == "water_point"   ) or
       (   keyvalues["amenity"]  == "dish_washing"  ) or
       (   keyvalues["amenity"]  == "washing_area"  ) or
       (   keyvalues["amenity"]  == "utilities"     )) then
      if ( keyvalues["drinking_water"] == "yes" ) then
         keyvalues["amenity"] = "drinking_water"
      else
         keyvalues["amenity"] = "nondrinking_water"
      end
   end

-- ----------------------------------------------------------------------------
-- man_made=maypole
-- ----------------------------------------------------------------------------
   if ((  keyvalues["man_made"] == "maypole"   ) or
       (  keyvalues["man_made"] == "may_pole"  ) or
       (  keyvalues["historic"] == "maypole"   )) then
      keyvalues["man_made"] = "maypole"
      keyvalues["tourism"] = nil
   end

-- ----------------------------------------------------------------------------
-- highway=streetlamp
-- ----------------------------------------------------------------------------
   if ( keyvalues["highway"] == "street_lamp" ) then
      if ( keyvalues["lamp_type"] == "gaslight" ) then
         keyvalues["highway"] = "streetlamp_gas"
      else
         keyvalues["highway"] = "streetlamp_electric"
      end
   end

-- ----------------------------------------------------------------------------
-- Departure boards not associated with bus stops etc.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["highway"]                       == nil                             ) and
       (  keyvalues["railway"]                       == nil                             ) and
       (  keyvalues["public_transport"]              == nil                             ) and
       (  keyvalues["building"]                      == nil                             ) and
       (( keyvalues["departures_board"]              == "realtime"                     ) or
        ( keyvalues["departures_board"]              == "timetable; realtime"          ) or
        ( keyvalues["departures_board"]              == "realtime;timetable"           ) or
        ( keyvalues["departures_board"]              == "timetable;realtime"           ) or
        ( keyvalues["departures_board"]              == "realtime_multiline"           ) or
        ( keyvalues["departures_board"]              == "realtime,timetable"           ) or
        ( keyvalues["departures_board"]              == "multiline"                    ) or
        ( keyvalues["departures_board"]              == "realtime_multiline;timetable" ) or
        ( keyvalues["passenger_information_display"] == "realtime"                     ))) then
         keyvalues["highway"] = "board_realtime"
   end

-- ----------------------------------------------------------------------------
-- If a bus stop pole exists but it's known to be disused, indicate that.
--
-- We also show bus stands as disused bus stops - they are somewhere where you
-- might expect to be able to get on a bus, but cannot.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["disused:highway"]    == "bus_stop"  )  and
        ( keyvalues["physically_present"] == "yes"       )) or
       (  keyvalues["highway"]            == "bus_stand"  ) or
       (  keyvalues["amenity"]            == "bus_stand"  )) then
      keyvalues["highway"] = "bus_stop_disused_pole"
      keyvalues["disused:highway"] = nil
      keyvalues["amenity"] = nil

      if ( keyvalues["name"] ~= nil ) then
         keyvalues["ele"] = keyvalues["name"]
      end
   end

-- ----------------------------------------------------------------------------
-- Some people tag waste_basket on bus_stop.  We render just bus_stop.
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"] == "bus_stop"     ) and
       ( keyvalues["amenity"] == "waste_basket" )) then
      keyvalues["amenity"] = nil
   end

-- ----------------------------------------------------------------------------
-- Many "naptan:Indicator" are "opp" or "adj", but some are "Stop XYZ" or
-- various other bits and pieces.  See 
-- https://taginfo.openstreetmap.org/keys/naptan%3AIndicator#values
-- We remove overly long ones.
-- Similarly, long "ref" values.
-- ----------------------------------------------------------------------------
   if (( keyvalues["naptan:Indicator"] ~= nil           ) and
       ( string.len( keyvalues["naptan:Indicator"]) > 3 )) then
      keyvalues["naptan:Indicator"] = nil
   end

   if (( keyvalues["highway"] == "bus_stop" ) and
       ( keyvalues["ref"]     ~= nil        ) and
       ( string.len( keyvalues["ref"]) > 3  )) then
      keyvalues["ref"] = nil
   end

-- ----------------------------------------------------------------------------
-- Concatenate a couple of names for bus stops so that the most useful ones
-- are displayed.
-- ----------------------------------------------------------------------------
   if ( keyvalues["highway"] == "bus_stop" ) then
      if ( keyvalues["name"] ~= nil ) then
         if (( keyvalues["bus_speech_output_name"] ~= nil                                ) and
             ( not string.match( keyvalues["name"], keyvalues["bus_speech_output_name"] ))) then
            keyvalues["name"] = keyvalues["name"] .. " / " .. keyvalues["bus_speech_output_name"]
         end

         if (( keyvalues["bus_display_name"] ~= nil                                ) and
             ( not string.match( keyvalues["name"], keyvalues["bus_display_name"] ))) then
            keyvalues["name"] = keyvalues["name"] .. " / " .. keyvalues["bus_display_name"]
         end
      end

      if ( keyvalues["name"] == nil ) then
         if ( keyvalues["ref"] == nil ) then
            if ( keyvalues["naptan:Indicator"] ~= nil ) then
               keyvalues["name"] = keyvalues["naptan:Indicator"]
            end
         else -- ref not nil
            if ( keyvalues["naptan:Indicator"] == nil ) then
               keyvalues["name"] = keyvalues["ref"]
            else
               keyvalues["name"] = keyvalues["ref"] .. " " .. keyvalues["naptan:Indicator"]
            end
         end
      else -- name not nil
         if ( keyvalues["ref"] == nil ) then
            if ( keyvalues["naptan:Indicator"] ~= nil ) then
               keyvalues["name"] = keyvalues["name"] .. " " .. keyvalues["naptan:Indicator"]
            end
         else -- neither name nor ref nil
            if ( keyvalues["naptan:Indicator"] == nil ) then
               keyvalues["name"] = keyvalues["name"] .. " " .. keyvalues["ref"]
            else -- naptan:Indicator not nil
               keyvalues["name"] = keyvalues["name"] .. " " .. keyvalues["ref"] .. " " .. keyvalues["naptan:Indicator"]
            end
         end
      end

      if ( keyvalues["name"] == nil ) then
         if ( keyvalues["website"] ~= nil ) then
            keyvalues["ele"] = keyvalues["website"]
         end
      else -- name not nil
         if ( keyvalues["website"] == nil ) then
            keyvalues["ele"] = keyvalues["name"]
         else -- website not nil
            keyvalues["ele"] = keyvalues["name"] .. " " .. keyvalues["website"]
         end
      end

-- ----------------------------------------------------------------------------
-- Can we set a "departures_board" value based on a "timetable" value?
-- ----------------------------------------------------------------------------
      if (( keyvalues["departures_board"] == nil         ) and
          ( keyvalues["timetable"]        == "real_time" )) then
         keyvalues["departures_board"] = "realtime"
      end

      if (( keyvalues["departures_board"] == nil         ) and
          ( keyvalues["timetable"]        == "yes" )) then
         keyvalues["departures_board"] = "timetable"
      end

-- ----------------------------------------------------------------------------
-- Based on the other tags that are set, 
-- let's use different symbols for bus stops
-- ----------------------------------------------------------------------------
      if (( keyvalues["departures_board"]              == "realtime"                     ) or
          ( keyvalues["departures_board"]              == "timetable; realtime"          ) or
          ( keyvalues["departures_board"]              == "realtime;timetable"           ) or
          ( keyvalues["departures_board"]              == "timetable;realtime"           ) or
          ( keyvalues["departures_board"]              == "realtime_multiline"           ) or
          ( keyvalues["departures_board"]              == "realtime,timetable"           ) or
          ( keyvalues["departures_board"]              == "multiline"                    ) or
          ( keyvalues["departures_board"]              == "realtime_multiline;timetable" ) or
          ( keyvalues["passenger_information_display"] == "realtime"                     )) then
         if (( keyvalues["departures_board:speech_output"]              == "yes" ) or
             ( keyvalues["passenger_information_display:speech_output"] == "yes" )) then
            keyvalues["highway"] = "bus_stop_speech_realtime"
         else
            keyvalues["highway"] = "bus_stop_realtime"
         end
      else
         if (( keyvalues["departures_board"]              == "timetable"        ) or
             ( keyvalues["departures_board"]              == "schedule"         ) or
             ( keyvalues["departures_board"]              == "separate"         ) or
             ( keyvalues["departures_board"]              == "paper timetable"  ) or
             ( keyvalues["departures_board"]              == "yes"              ) or
             ( keyvalues["passenger_information_display"] == "timetable"        ) or
             ( keyvalues["passenger_information_display"] == "yes"              )) then
            if (( keyvalues["departures_board:speech_output"]              == "yes" ) or
                ( keyvalues["passenger_information_display:speech_output"] == "yes" )) then
               keyvalues["highway"] = "bus_stop_speech_timetable"
            else
               keyvalues["highway"] = "bus_stop_timetable"
            end
         else
            if (( keyvalues["flag"]               == "no"  ) or
                ( keyvalues["pole"]               == "no"  ) or
                ( keyvalues["physically_present"] == "no"  ) or
                ( keyvalues["naptan:BusStopType"] == "CUS" )) then
               keyvalues["highway"] = "bus_stop_nothing"
            else
               keyvalues["highway"] = "bus_stop_pole"
            end
         end
      end
   end

-- ----------------------------------------------------------------------------
-- Let's send amenity=grave_yard and landuse=cemetery through as
-- landuse=cemetery.
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "grave_yard" ) or
       ( keyvalues["landuse"] == "grave_yard" )) then
      keyvalues["amenity"] = nil
      keyvalues["landuse"] = "cemetery"
   end


-- ----------------------------------------------------------------------------
-- Names for vacant shops
-- ----------------------------------------------------------------------------
   if (((( keyvalues["disused:shop"]    ~= nil        )   or
         ( keyvalues["disused:amenity"] ~= nil        ))  and
         ( keyvalues["disused:amenity"] ~= "fountain"  )  and
         ( keyvalues["disused:amenity"] ~= "parking"   )  and
         ( keyvalues["shop"]            == nil         )  and
         ( keyvalues["amenity"]         == nil         )) or
       (   keyvalues["office"]          == "vacant"     ) or
       (   keyvalues["office"]          == "disused"    ) or
       (   keyvalues["shop"]            == "disused"    ) or
       (   keyvalues["shop"]            == "abandoned"  ) or
       ((  keyvalues["shop"]            ~= nil         )  and
        (  keyvalues["opening_hours"]   == "closed"    ))) then
      keyvalues["shop"] = "vacant"
   end

   if ( keyvalues["shop"] == "vacant" ) then
      if (( keyvalues["name"]     == nil ) and
          ( keyvalues["old_name"] ~= nil )) then
         keyvalues["name"]     = keyvalues["old_name"]
         keyvalues["old_name"] = nil
      end

      if (( keyvalues["name"]     == nil ) and
          ( keyvalues["former_name"] ~= nil )) then
         keyvalues["name"]     = keyvalues["former_name"]
         keyvalues["former_name"] = nil
      end

      if ( keyvalues["name"] == nil ) then
         keyvalues["ref"] = "(vacant)"
      else
         keyvalues["ref"] = "(vacant: " .. keyvalues["name"] .. ")"
         keyvalues["name"] = nil
      end
   end

-- ----------------------------------------------------------------------------
-- Remove icon for public transport and animal field shelters and render as
-- "roof" (if they are a way).
-- "roof" isn't rendered for nodes, so this has the effect of suppressing
-- public_transport shelters and shopping_cart shelters on nodes.
-- shopping_cart, parking and animal_shelter aren't really a "shelter" type 
-- that we are interested in (for humans).  There are no field or parking 
-- shelters on nodes in GB/IE.
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"]      == "shelter"            ) and
       (( keyvalues["shelter_type"] == "public_transport" )  or
        ( keyvalues["shelter_type"] == "field_shelter"    )  or
        ( keyvalues["shelter_type"] == "shopping_cart"    )  or
        ( keyvalues["shelter_type"] == "trolley_park"     )  or
        ( keyvalues["shelter_type"] == "parking"          )  or
        ( keyvalues["shelter_type"] == "animal_shelter"   ))) then
      keyvalues["amenity"] = nil
      if ( keyvalues["building"] == nil ) then
         keyvalues["building"] = "roof"
      end
   end

  if (( keyvalues["amenity"]      == "shelter"            ) and
      ( keyvalues["shelter_type"] == "bicycle_parking"    )) then
      keyvalues["amenity"] = "bicycle_parking"
      if ( keyvalues["building"] == nil ) then
         keyvalues["building"] = "roof"
      end
   end

-- ----------------------------------------------------------------------------
-- Prevent highway=raceway from appearing in the polygon table.
-- ----------------------------------------------------------------------------
   if ( keyvalues["highway"] == "raceway" ) then
      keyvalues["area"] = "no"
   end


-- ----------------------------------------------------------------------------
-- Drop some highway areas - "track" etc. areas wherever I have seen them are 
-- garbage.
-- "footway" (pedestrian areas) and "service" (e.g. petrol station forecourts)
-- tend to be OK.  Other options tend not to occur.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["highway"] == "track"          )  or
        ( keyvalues["highway"] == "leisuretrack"   )  or
        ( keyvalues["highway"] == "gallop"         )  or
        ( keyvalues["highway"] == "residential"    )  or
        ( keyvalues["highway"] == "unclassified"   )  or
        ( keyvalues["highway"] == "tertiary"       )) and
       (  keyvalues["area"]    == "yes"             )) then
      keyvalues["highway"] = nil
   end

-- ----------------------------------------------------------------------------
-- Show traffic islands as kerbs
-- ----------------------------------------------------------------------------
   if (( keyvalues["area:highway"] == "traffic_island" )  or
       ( keyvalues["landuse"]      == "traffic_island" )) then
      keyvalues["barrier"] = "kerb"
   end

-- ----------------------------------------------------------------------------
-- name and addr:housename
-- If a building that isn't something else has a name but no addr:housename,
-- use that there.
--
-- There are some odd combinations of "place" and "building" - we remove 
-- "place" in those cases
-- ----------------------------------------------------------------------------
   if (( keyvalues["building"]       ~= nil  ) and
       ( keyvalues["building"]       ~= "no" ) and
       ( keyvalues["addr:housename"] == nil  ) and
       ( keyvalues["name"]           ~= nil  ) and
       ( keyvalues["aeroway"]        == nil  ) and
       ( keyvalues["amenity"]        == nil  ) and
       ( keyvalues["barrier"]        == nil  ) and
       ( keyvalues["craft"]          == nil  ) and
       ( keyvalues["emergency"]      == nil  ) and
       ( keyvalues["highway"]        == nil  ) and
       ( keyvalues["historic"]       == nil  ) and
       ( keyvalues["landuse"]        == nil  ) and
       ( keyvalues["leisure"]        == nil  ) and
       ( keyvalues["man_made"]       == nil  ) and
       ( keyvalues["natural"]        == nil  ) and
       ( keyvalues["office"]         == nil  ) and
       ( keyvalues["railway"]        == nil  ) and
       ( keyvalues["shop"]           == nil  ) and
       ( keyvalues["sport"]          == nil  ) and
       ( keyvalues["tourism"]        == nil  ) and
       ( keyvalues["waterway"]       == nil  )) then
      keyvalues["addr:housename"] = keyvalues["name"]
      keyvalues["name"]  = nil
      keyvalues["place"] = nil
   end

-- ----------------------------------------------------------------------------
-- addr:unit
-- ----------------------------------------------------------------------------
   if ( keyvalues["addr:unit"] ~= nil ) then
      if ( keyvalues["addr:housenumber"] ~= nil ) then
         keyvalues["addr:housenumber"] = keyvalues["addr:unit"] .. ", " .. keyvalues["addr:housenumber"]
      else
         keyvalues["addr:housenumber"] = keyvalues["addr:unit"]
      end
   end

-- ----------------------------------------------------------------------------
-- Shops etc. with icons already - just add "unnamedcommercial" landuse.
-- The exception is where landuse is set to something we want to keep.
-- ----------------------------------------------------------------------------
   if (((  keyvalues["shop"]       ~= nil                  )  or
        (( keyvalues["amenity"]    ~= nil                 )   and
         ( keyvalues["amenity"]    ~= "holy_well"         )   and
         ( keyvalues["amenity"]    ~= "holy_spring"       )   and
         ( keyvalues["amenity"]    ~= "biergarten"        )   and
         ( keyvalues["amenity"]    ~= "pitch_baseball"    )   and
         ( keyvalues["amenity"]    ~= "pitch_basketball"  )   and
         ( keyvalues["amenity"]    ~= "pitch_chess"       )   and
         ( keyvalues["amenity"]    ~= "pitch_cricket"     )   and
         ( keyvalues["amenity"]    ~= "pitch_climbing"    )   and
         ( keyvalues["amenity"]    ~= "pitch_athletics"   )   and
         ( keyvalues["amenity"]    ~= "pitch_boules"      )   and
         ( keyvalues["amenity"]    ~= "pitch_bowls"       )   and
         ( keyvalues["amenity"]    ~= "pitch_croquet"     )   and
         ( keyvalues["amenity"]    ~= "pitch_cycling"     )   and
         ( keyvalues["amenity"]    ~= "pitch_equestrian"  )   and
         ( keyvalues["amenity"]    ~= "pitch_gaa"         )   and
         ( keyvalues["amenity"]    ~= "pitch_hockey"      )   and
         ( keyvalues["amenity"]    ~= "pitch_multi"       )   and
         ( keyvalues["amenity"]    ~= "pitch_netball"     )   and
         ( keyvalues["amenity"]    ~= "pitch_polo"        )   and
         ( keyvalues["amenity"]    ~= "pitch_shooting"    )   and
         ( keyvalues["amenity"]    ~= "pitch_rugby"       )   and
         ( keyvalues["amenity"]    ~= "pitch_skateboard"  )   and
         ( keyvalues["amenity"]    ~= "pitch_soccer"      )   and
         ( keyvalues["amenity"]    ~= "pitch_tabletennis" )   and
         ( keyvalues["amenity"]    ~= "pitch_tennis"      ))  or
        (  keyvalues["tourism"]    == "hotel"              )  or
        (  keyvalues["tourism"]    == "guest_house"        )  or
        (  keyvalues["tourism"]    == "attraction"         )  or
        (  keyvalues["tourism"]    == "viewpoint"          )  or
        (  keyvalues["tourism"]    == "museum"             )  or
        (  keyvalues["tourism"]    == "hostel"             )  or
        (  keyvalues["tourism"]    == "gallery"            )  or
        (  keyvalues["tourism"]    == "apartment"          )  or
        (  keyvalues["tourism"]    == "bed_and_breakfast"  )  or
        (  keyvalues["tourism"]    == "motel"              )  or
        (  keyvalues["tourism"]    == "theme_park"         )) and
       (   keyvalues["leisure"]    ~= "garden"              )) then
      if ( keyvalues["landuse"] == nil ) then
         keyvalues["landuse"] = "unnamedcommercial"
      end
   end

-- ----------------------------------------------------------------------------
-- End of AJT generic additions.
-- ----------------------------------------------------------------------------

   return filter, keyvalues
end


function append_accommodation(keyvalues)
   if (( keyvalues["accommodation"] ~= nil  ) and
       ( keyvalues["accommodation"] ~= "no" )) then
      keyvalues["amenity"] = keyvalues["amenity"] .. "y"
   else
      keyvalues["amenity"] = keyvalues["amenity"] .. "n"
   end
end

function append_wheelchair(keyvalues)
   if ( keyvalues["wheelchair"] == "yes" ) then
      keyvalues["amenity"] = keyvalues["amenity"] .. "y"
   else
      if ( keyvalues["wheelchair"] == "limited" ) then
         keyvalues["amenity"] = keyvalues["amenity"] .. "l"
      else
         if ( keyvalues["wheelchair"] == "no" ) then
            keyvalues["amenity"] = keyvalues["amenity"] .. "n"
         else
            keyvalues["amenity"] = keyvalues["amenity"] .. "d"
         end
      end
   end
end


function append_beer_garden(keyvalues)
   if ( keyvalues["beer_garden"] == "yes" ) then
      keyvalues["amenity"] = keyvalues["amenity"] .. "g"
   else
      if ( keyvalues["outdoor_seating"] == "yes" ) then
         keyvalues["amenity"] = keyvalues["amenity"] .. "o"
      else
         keyvalues["amenity"] = keyvalues["amenity"] .. "d"
      end
   end
end

-- ----------------------------------------------------------------------------
-- Designed to set "ele" to a new value
-- ----------------------------------------------------------------------------
function append_inscription(keyvalues)
   if ( keyvalues["name"] ~= nil ) then
      keyvalues["ele"] = keyvalues["name"]
   else
      keyvalues["ele"] = nil
   end

   if ( keyvalues["inscription"] ~= nil ) then
       if ( keyvalues["ele"] == nil ) then
           keyvalues["ele"] = keyvalues["inscription"]
       else
           keyvalues["ele"] = keyvalues["ele"] .. " " .. keyvalues["inscription"]
       end
   end
end

-- ----------------------------------------------------------------------------
-- Designed to append any directions to an "ele" that might already have
-- "inscription" in it.
-- ----------------------------------------------------------------------------
function append_directions(keyvalues)
   if ( keyvalues["direction_north"] ~= nil ) then
      if ( keyvalues["ele"] == nil ) then
         keyvalues["ele"] = "N: " .. keyvalues["direction_north"]
      else
         keyvalues["ele"] = keyvalues["ele"] .. ", N: " .. keyvalues["direction_north"]
      end
   end

   if ( keyvalues["direction_northeast"] ~= nil ) then
      if ( keyvalues["ele"] == nil ) then
         keyvalues["ele"] = "NE: " .. keyvalues["direction_northeast"]
      else
         keyvalues["ele"] = keyvalues["ele"] .. ", NE: " .. keyvalues["direction_northeast"]
      end
   end

   if ( keyvalues["direction_east"] ~= nil ) then
      if ( keyvalues["ele"] == nil ) then
         keyvalues["ele"] = "E: " .. keyvalues["direction_east"]
      else
         keyvalues["ele"] = keyvalues["ele"] .. ", E: " .. keyvalues["direction_east"]
      end
   end

   if ( keyvalues["direction_southeast"] ~= nil ) then
      if ( keyvalues["ele"] == nil ) then
         keyvalues["ele"] = "SE: " .. keyvalues["direction_southeast"]
      else
         keyvalues["ele"] = keyvalues["ele"] .. ", SE: " .. keyvalues["direction_southeast"]
      end
   end

   if ( keyvalues["direction_south"] ~= nil ) then
      if ( keyvalues["ele"] == nil ) then
         keyvalues["ele"] = "S: " .. keyvalues["direction_south"]
      else
         keyvalues["ele"] = keyvalues["ele"] .. ", S: " .. keyvalues["direction_south"]
      end
   end

   if ( keyvalues["direction_southwest"] ~= nil ) then
      if ( keyvalues["ele"] == nil ) then
         keyvalues["ele"] = "SW: " .. keyvalues["direction_southwest"]
      else
         keyvalues["ele"] = keyvalues["ele"] .. ", SW: " .. keyvalues["direction_southwest"]
      end
   end

   if ( keyvalues["direction_west"] ~= nil ) then
      if ( keyvalues["ele"] == nil ) then
         keyvalues["ele"] = "W: " .. keyvalues["direction_west"]
      else
         keyvalues["ele"] = keyvalues["ele"] .. ", W: " .. keyvalues["direction_west"]
      end
   end

   if ( keyvalues["direction_northwest"] ~= nil ) then
      if ( keyvalues["ele"] == nil ) then
         keyvalues["ele"] = "NW: " .. keyvalues["direction_northwest"]
      else
         keyvalues["ele"] = keyvalues["ele"] .. ", NW: " .. keyvalues["direction_northwest"]
      end
   end
end

function filter_tags_node (keyvalues, nokeys)

-- ----------------------------------------------------------------------------
-- AJT node-only additions.
--
-- Consolidate some "ford" values into "yes".
-- This is here rather than in "generic" because "generic" is called after this
-- There is a similar section in way-only.
-- ----------------------------------------------------------------------------
   if (( keyvalues["ford"] == "Tidal_Causeway" ) or
       ( keyvalues["ford"] == "ford"           ) or 
       ( keyvalues["ford"] == "intermittent"   ) or
       ( keyvalues["ford"] == "seasonal"       ) or
       ( keyvalues["ford"] == "stream"         ) or
       ( keyvalues["ford"] == "tidal"          )) then
      keyvalues["ford"] = "yes"
   end

   if ( keyvalues["ford"] == "yes" ) then
      keyvalues["highway"] = "ford"
      keyvalues["ford"]    = nil
   end

   if ( keyvalues["ford"]    == "stepping_stones" ) then
      keyvalues["barrier"] = "stepping_stones"
      keyvalues["ford"]    = nil
   end

-- ----------------------------------------------------------------------------
-- Map non-linear unknown (and some known) barriers to bollard
-- ----------------------------------------------------------------------------
   if (( keyvalues["barrier"]  == "yes"            ) or
       ( keyvalues["barrier"]  == "barrier"        ) or
       ( keyvalues["barrier"]  == "tank_trap"      ) or
       ( keyvalues["barrier"]  == "dragons_teeth"  ) or
       ( keyvalues["barrier"]  == "bollards"       ) or
       ( keyvalues["barrier"]  == "bus_trap"       ) or
       ( keyvalues["barrier"]  == "car_trap"       ) or
       ( keyvalues["barrier"]  == "rising_bollard" ) or
       ( keyvalues["barrier"]  == "steps"          ) or
       ( keyvalues["barrier"]  == "step"           ) or
       ( keyvalues["barrier"]  == "post"           ) or
       ( keyvalues["man_made"] == "post"           ) or
       ( keyvalues["man_made"] == "marker_post"    ) or
       ( keyvalues["man_made"] == "boundary_post"  ) or
       ( keyvalues["man_made"] == "concrete_post"  ) or
       ( keyvalues["barrier"]  == "stone"          ) or
       ( keyvalues["barrier"]  == "hoarding"       ) or
       ( keyvalues["barrier"]  == "sump_buster"    ) or
       ( keyvalues["barrier"]  == "gate_pier"      ) or
       ( keyvalues["barrier"]  == "gate_post"      ) or
       ( keyvalues["man_made"] == "gate_post"      ) or
       ( keyvalues["man_made"] == "gatepost"       ) or
       ( keyvalues["barrier"]  == "pole"           )) then
      keyvalues["barrier"] = "bollard"
   end

-- ----------------------------------------------------------------------------
-- Render barrier=chain on nodes as horse_stile.  At least sone of the time 
-- it's correct.
-- ----------------------------------------------------------------------------
   if ( keyvalues["barrier"] == "chain" ) then
      keyvalues["barrier"] = "horse_stile"
   end

-- ----------------------------------------------------------------------------
-- Render barrier=v_stile on nodes as stile.  
-- ----------------------------------------------------------------------------
   if ( keyvalues["barrier"] == "v_stile" ) then
      keyvalues["barrier"] = "stile"
   end

-- ----------------------------------------------------------------------------
-- highway=turning_loop on nodes to turning_circle
-- "turning_loop" is mostly used on nodes, with one way in UK/IE data.
-- ----------------------------------------------------------------------------
   if ( keyvalues["highway"] == "turning_loop" ) then
      keyvalues["highway"] = "turning_circle"
   end

-- ----------------------------------------------------------------------------
-- Change natural=bare_rock and natural=rocks on nodes to natural=rock
-- So that an icon (the all-black, non-climbing boulder one) is displayed
-- ----------------------------------------------------------------------------
   if (( keyvalues["natural"] == "bare_rock" ) or
       ( keyvalues["natural"] == "rocks"     ) or
       ( keyvalues["natural"] == "stones"    )) then
      keyvalues["natural"] = "rock"
   end

-- ----------------------------------------------------------------------------
-- If lcn_ref exists (for example as a location in a local cycling network),
-- render it via a "man_made" tag if there's no other tags on that node.
-- ----------------------------------------------------------------------------
   if (( keyvalues["lcn_ref"] ~= nil ) and
       ( keyvalues["ref"]     == nil )) then
      keyvalues["man_made"] = "lcn_ref"
      keyvalues["ref"]     = keyvalues["lcn_ref"]
      keyvalues["lcn_ref"] = nil
   end

-- ----------------------------------------------------------------------------
-- End of AJT node-only additions.
-- ----------------------------------------------------------------------------

   return filter_tags_generic(keyvalues, nokeys)
end

function filter_basic_tags_rel (keyvalues, nokeys)

-- ----------------------------------------------------------------------------
-- AJT relation-only additions.
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- End of AJT relation-only additions.
-- ----------------------------------------------------------------------------
   filter, keyvalues = filter_tags_generic(keyvalues, nokeys)

   if filter == 1 then
      return filter, keyvalues
   end

   if ((keyvalues["type"] ~= "route") and (keyvalues["type"] ~= "multipolygon") and (keyvalues["type"] ~= "boundary")) then
      filter = 1
      return filter, keyvalues
   end

   return filter, keyvalues
end

function filter_tags_way (keyvalues, nokeys)
   filter = 0
   poly = 0
   tagcount = 0
   roads = 0

-- ----------------------------------------------------------------------------
-- AJT way-only additions.
--
-- Consolidate some "ford" values into "yes".
-- This is here rather than in "generic" because "generic" is called after this
-- There is a similar section in way-only.
-- ----------------------------------------------------------------------------
   if (( keyvalues["ford"] == "Tidal_Causeway" ) or
       ( keyvalues["ford"] == "ford"           ) or 
       ( keyvalues["ford"] == "intermittent"   ) or
       ( keyvalues["ford"] == "seasonal"       ) or
       ( keyvalues["ford"] == "stream"         ) or
       ( keyvalues["ford"] == "tidal"          )) then
      keyvalues["ford"] = "yes"
   end

-- ----------------------------------------------------------------------------
-- If a highway has tidal=yes but not yet a ford or bridge tag, add ford=yes
-- ----------------------------------------------------------------------------
   if (( keyvalues["tidal"]   == "yes" ) and
       ( keyvalues["highway"] ~= nil   ) and
       ( keyvalues["ford"]    == nil   ) and
       ( keyvalues["bridge"]  == nil   )) then
      keyvalues["ford"] = "yes"
   end

-- ----------------------------------------------------------------------------
-- "barrier=gate" on a way is a dark line; on bridleways it looks 
-- "sufficiently different" to mark fords out.
-- ----------------------------------------------------------------------------
   if (( keyvalues["ford"] == "yes"             ) or
       ( keyvalues["ford"] == "stepping_stones" ))then
      keyvalues["barrier"] = "ford"
   end

-- ----------------------------------------------------------------------------
-- Treat a linear "door" and some other linear barriers as "gate"
--
-- A "lock_gate" mapped as a node gets its own "locks" layer in 
-- water-features.mss (for historical reasons that no longer make sense).
-- There's no explicit node or generic code for lock_gate.
-- ----------------------------------------------------------------------------
   if (( keyvalues["barrier"]  == "door"       ) or
       ( keyvalues["barrier"]  == "swing_gate" ) or
       ( keyvalues["waterway"] == "lock_gate"  )) then
      keyvalues["barrier"]  = "gate"
      keyvalues["waterway"] = nil
   end

-- ----------------------------------------------------------------------------
-- Map linear tank traps, and some others, to wall
-- ----------------------------------------------------------------------------
   if (( keyvalues["barrier"] == "tank_trap"      ) or
       ( keyvalues["barrier"] == "dragons_teeth"  ) or
       ( keyvalues["barrier"] == "obstruction"    ) or
       ( keyvalues["barrier"] == "sea_wall"       ) or
       ( keyvalues["barrier"] == "flood_wall"     ) or
       ( keyvalues["barrier"] == "block"          ) or
       ( keyvalues["barrier"] == "haha"           ) or
       ( keyvalues["barrier"] == "jersey_barrier" ) or
       ( keyvalues["barrier"] == "retaining_wall" )) then
      keyvalues["barrier"] = "wall"
   end

-- ----------------------------------------------------------------------------
-- Map linear unknown and other barriers to fence.
-- In some cases this is a bit of a stretch - you can walk up some steps, or
-- through a cycle barrier for example.  Fence was chosen as the "current
-- minimal thickness linear barrier".  If a narrower one is introduced it
-- would make sense to make traversable ones in this list to that.
-- ----------------------------------------------------------------------------
   if (( keyvalues["barrier"] == "yes"             ) or
       ( keyvalues["barrier"] == "barrier"         ) or
       ( keyvalues["barrier"] == "bollard"         ) or
       ( keyvalues["barrier"] == "steps"           ) or
       ( keyvalues["barrier"] == "step"            ) or
       ( keyvalues["barrier"] == "hoarding"        ) or
       ( keyvalues["barrier"] == "hand_rail_fence" ) or
       ( keyvalues["barrier"] == "horse_stile"     ) or
       ( keyvalues["barrier"] == "chain"           ) or
       ( keyvalues["barrier"] == "stile"           ) or
       ( keyvalues["barrier"] == "v_stile"         ) or
       ( keyvalues["barrier"] == "cycle_barrier"   )) then
      keyvalues["barrier"] = "fence"
   end

   if (( keyvalues["public_transport"] == "platform" ) and
       ( keyvalues["highway"]          ~= "platform" ) and
       ( keyvalues["highway"]          ~= "bus_stop" ) and
       ( keyvalues["railway"]          ~= "platform" )) then
      keyvalues["highway"] = "platform"
   end

-- ----------------------------------------------------------------------------
-- Map sinkholes mapped as ways to a non-area cliff.
-- It's pot luck whether the triangles will appear on the right side of the
-- cliff, but by chance most of the few UK ones do seem to be drawn the 
-- "correct" way around.
-- ----------------------------------------------------------------------------
   if ( keyvalues["natural"] == "sinkhole" ) then
      keyvalues["natural"] = "cliff"
      keyvalues["area"] = "no"
   end

-- ----------------------------------------------------------------------------
-- Add building=roof on shelter and bicycle_parking ways if no building tag 
-- already.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["amenity"]  == "shelter"          )   or
        ( keyvalues["amenity"]  == "bicycle_parking"  ))  and
       ( keyvalues["building"] == nil                  )  and
       ( keyvalues["covered"]  ~= "no"                 )) then
      keyvalues["building"] = "roof"
   end

-- ----------------------------------------------------------------------------
-- A "leisure=track" can be either a linear or an area feature
-- https://wiki.openstreetmap.org/wiki/Tag%3Aleisure%3Dtrack
-- Assign a highway tag (gallop or leisuretrack) so that linear features can
-- be explicitly rendered.
-- "sport" is often (but not always) used to separate different types of
-- leisure tracks.
--
-- If on an area, the way will go into planet_osm_polygon and the highway
-- feature won't be rendered (because both leisuretrack and gallop are only 
-- processed as linear features) but the leisure=track will be (as an area).
--
-- Additionally force anything that is "oneway" to not be an area feature
-- ----------------------------------------------------------------------------
   if ( keyvalues["leisure"]  == "track" ) then
      if (( keyvalues["sport"]    == "equestrian"   )  or
          ( keyvalues["sport"]    == "horse_racing" )) then
         keyvalues["highway"] = "gallop"
      else
         if ((( keyvalues["sport"]    == "motor"         )  or
              ( keyvalues["sport"]    == "karting"       )  or
              ( keyvalues["sport"]    == "motor;karting" )) and
             (( keyvalues["area"]     == nil              )  or
              ( keyvalues["area"]     == "no"             ))) then
            keyvalues["highway"] = "raceway"
         else
            keyvalues["highway"] = "leisuretrack"
         end
      end

      if ( keyvalues["oneway"] == "yes" ) then
         keyvalues["area"] = "no"
      end
   end

-- ----------------------------------------------------------------------------
-- highway=turning_loop on ways to service road
-- "turning_loop" is mostly used on nodes, with one way in UK/IE data.
-- ----------------------------------------------------------------------------
   if ( keyvalues["highway"] == "turning_loop" ) then
      keyvalues["highway"] = "service"
      keyvalues["service"] = "driveway"
   end

-- ----------------------------------------------------------------------------
-- natural=rock on ways to natural=bare_rock
-- ----------------------------------------------------------------------------
   if ( keyvalues["natural"] == "rock" ) then
      keyvalues["natural"] = "bare_rock"
   end

-- ----------------------------------------------------------------------------
-- Where amenity=watering_place has been used on a way and there's no
-- "natural" tag already, apply "natural=water".
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "watering_place" ) and
       ( keyvalues["natural"] == nil              )) then
      keyvalues["amenity"] = nil
      keyvalues["natural"] = "water"
   end

-- ----------------------------------------------------------------------------
-- End of AJT way-only additions.
-- ----------------------------------------------------------------------------

   filter, keyvalues = filter_tags_generic(keyvalues, nokeys)
   if filter == 1 then
      return filter, keyvalues, poly, roads
   end


   for i,k in ipairs(polygon_keys) do
      if keyvalues[k] then
         poly=1
         break
      end
   end
   

   if ((keyvalues["area"] == "yes") or (keyvalues["area"] == "1") or (keyvalues["area"] == "true")) then
      poly = 1;
   elseif ((keyvalues["area"] == "no") or (keyvalues["area"] == "0") or (keyvalues["area"] == "false")) then
      poly = 0;
   end

   keyvalues, roads = add_z_order(keyvalues)


   return filter, keyvalues, poly, roads
end

function filter_tags_relation_member (keyvalues, keyvaluemembers, roles, membercount)
   
   filter = 0
   boundary = 0
   polygon = 0
   roads = 0
   membersuperseeded = {}
   for i = 1, membercount do
      membersuperseeded[i] = 0
   end

-- ----------------------------------------------------------------------------
-- AJT relation-only additions.
-- ----------------------------------------------------------------------------
   if (( keyvalues["type"]     == "multipolygon" ) and
       ( keyvalues["junction"] == "yes"          )) then
      keyvalues["type"] = nil
   end
   
   type = keyvalues["type"]
   keyvalues["type"] = nil

-- ----------------------------------------------------------------------------
-- Note that we're not doing any per-member processing for routes - we just
-- add a highway type to the relation and ensure that the style rules for it
-- handle it sensibly, as it's going to be overlaid over other highway types.
-- "ldpnwn" is used to allow for future different processing of different 
-- relations.
--
-- Name handling for cycle routes makes a special case of the National Byway.
--
-- MTB routes are processed only if they are not also another type of cycle
-- route (including LCN, which isn't actually shown in this rendering).
--
-- Processing routes,
-- Walking networks first.
-- We use "ref" rather than "name" on IWNs but not others.
-- We use "colour" as "name" if "colour" is set and "name" is not.
-- ----------------------------------------------------------------------------
   if (type == "route") then
      if (( keyvalues["network"] == "iwn" ) and
          ( keyvalues["ref"]     ~= nil   )) then
         keyvalues["name"] = keyvalues["ref"]
      end

      if ((( keyvalues["network"] == "iwn"         ) or
           ( keyvalues["network"] == "nwn"         ) or
           ( keyvalues["network"] == "rwn"         ) or
           ( keyvalues["network"] == "lwn"         ) or
           ( keyvalues["network"] == "lwn;lcn"     ) or
           ( keyvalues["network"] == "lwn;lcn;lhn" )) and
          (( keyvalues["name"]    ~= nil           )  or
           ( keyvalues["colour"]  ~= nil           ))) then
         if (( keyvalues["name"]   == nil ) and
             ( keyvalues["colour"] ~= nil )) then
            keyvalues["name"] = keyvalues["colour"]
         end

         keyvalues["highway"] = "ldpnwn"
      end  -- walking

-- ----------------------------------------------------------------------------
-- Cycle networks
-- We exclude some obviously silly refs.
-- We use "ref" rather than "name".
-- We handle loops on the National Byway and append (r) on other RCNs.
-- ----------------------------------------------------------------------------
      if (((  keyvalues["network"] == "ncn"           )  or
           (  keyvalues["network"] == "rcn"           )) and
          ((  keyvalues["state"]   == nil             )  or
           (( keyvalues["state"]   ~= "proposed"     )   and
            ( keyvalues["state"]   ~= "construction" )   and
            ( keyvalues["state"]   ~= "abandoned"    )))) then
         keyvalues["highway"] = "ldpncn"

         if ( keyvalues["ref"] == "N/A" ) then
            keyvalues["ref"] = nil
         end

         if (( keyvalues["name"] ~= nil                 ) and
             ( keyvalues["ref"]  == "NB"                ) and
             ( string.match( keyvalues["name"], "Loop" ))) then
            keyvalues["ref"] = keyvalues["ref"] .. " (loop)"
         end

         if ( keyvalues["ref"] ~= nil ) then
            keyvalues["name"] = keyvalues["ref"]
         end

         if (( keyvalues["network"] == "rcn"       )  and
             ( keyvalues["name"]    ~= "NB"        )  and
             ( keyvalues["name"]    ~= "NB (loop)" )) then
            if ( keyvalues["name"] == nil ) then
               keyvalues["name"] = "(r)"
            else
               keyvalues["name"] = keyvalues["name"] .. " (r)"
            end
         end
      end -- cycle

-- ----------------------------------------------------------------------------
-- MTB networks
-- As long as there is a name, we append (m) here.
-- We don't show unnamed MTB "routes" as routes.
-- ----------------------------------------------------------------------------
      if (( keyvalues["route"]   == "mtb" ) and
          ( keyvalues["network"] ~= "ncn" ) and
          ( keyvalues["network"] ~= "rcn" ) and
          ( keyvalues["network"] ~= "lcn" )) then
         keyvalues["highway"] = "ldpmtb"

         if ( keyvalues["name"] == nil ) then
            keyvalues["highway"] = nil
         else
            keyvalues["name"] = keyvalues["name"] .. " (m)"
         end
      end -- MTB

-- ----------------------------------------------------------------------------
-- Horse networks
-- ----------------------------------------------------------------------------
      if (( keyvalues["network"] == "nhn"         ) or
          ( keyvalues["network"] == "rhn"         )  or
          ( keyvalues["network"] == "ncn;nhn;nwn" )) then
         keyvalues["highway"] = "ldpnhn"
      end

-- ----------------------------------------------------------------------------
-- Check for signage - remove unsigned networks
-- ----------------------------------------------------------------------------
      if (( keyvalues["highway"] == "ldpnwn" ) or
          ( keyvalues["highway"] == "ldpncn" ) or
          ( keyvalues["highway"] == "ldpmtb" ) or
          ( keyvalues["highway"] == "ldpnhn" )) then
         if ((  keyvalues["name"]        ~= nil     ) and
             (( keyvalues["name:signed"] == "no"   )  or
              ( keyvalues["name:absent"] == "yes"  )  or
              ( keyvalues["unsigned"]    == "yes"  )  or
              ( keyvalues["unsigned"]    == "name" ))) then
            keyvalues["name"] = nil
            keyvalues["name:signed"] = nil
            keyvalues["highway"] = nil
         end -- no name

         if ((  keyvalues["ref"]        ~= nil     ) and
             (( keyvalues["ref:signed"] == "no"   )  or
              ( keyvalues["unsigned"]   == "yes"  ))) then
            keyvalues["ref"] = nil
            keyvalues["ref:signed"] = nil
            keyvalues["unsigned"] = nil
            keyvalues["highway"] = nil
         end -- no ref
      end -- check for signage
   end -- route

   if (type == "boundary") then
      boundary = 1
   end
   if ((type == "multipolygon") and keyvalues["boundary"]) then
      boundary = 1
   elseif (type == "multipolygon") then
      polygon = 1
   end

-- ----------------------------------------------------------------------------
-- emergency=water_rescue is a poorly-designed key that makes it difficult to
-- tell e.g. lifeboats from lifeboat stations.
-- However, if we've got a multipolygon relation, it's a lifeboat station.
-- ----------------------------------------------------------------------------
   if (( type                   == "multipolygon" ) and
       ( keyvalues["emergency"] == "water_rescue" )) then
      keyvalues["emergency"] = "lifeboat_station"
   end

   keyvalues, roads = add_z_order(keyvalues)

   return filter, keyvalues, membersuperseeded, boundary, polygon, roads
end
