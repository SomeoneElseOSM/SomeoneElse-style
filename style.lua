-- ----------------------------------------------------------------------------
-- style.lua
--
-- Copyright (C) 2018-2025  Andy Townsend
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
require "shared_lua_raster"

polygon_keys = { 'area:aeroway', 'boundary', 'building', 'landcover', 'landuse', 'amenity', 'harbour', 'historic', 'leisure', 
      'man_made', 'military', 'natural', 'office', 'place', 'police', 'power',
      'public_transport', 'seamark:type', 'shop', 'sport', 'tourism', 'waterway',
      'wetland', 'water', 'aeroway' }

generic_keys = {'access','addr:housename','addr:housenumber','addr:interpolation','admin_level','advertising','aerialway',
   'aeroway','amenity','animal','area','area:aeroway', 'area:highway','barrier',
   'bicycle','brand','bridge','bridleway','booth','boundary','building', 'canoe', 'capital','construction','covered',
   'culvert','cutting','denomination','departures_board','designation','disused',
   'disused:amenity','disused:highway','disused:man_made',
   'disused:military','disused:railway','disused:shop','ele',
   'embankment','emergency','entrance','foot','flood_prone','generation:source','geological','golf','government',
   'harbour','hazard_prone','hazard_type','highway','historic','horse','hours','information','intermittent',
   'junction','landcover','landuse','layer','leisure','lcn_ref','lock','locked',
   'man_made','marker','military','motor_car','name','natural','ncn_milepost','office','oneway','operator',
   'opening_hours:covid19','outlet','passenger_information_display','pipeline','pitch','place','playground',
   'poi','population','police', 'power','power_source','public_transport',
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
   fix_invalid_layer_values_t( keyvalues )

-- ----------------------------------------------------------------------------
-- Treat "was:" as "disused:"
-- ----------------------------------------------------------------------------
   treat_was_as_disused_t( keyvalues )

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
   fix_corridors_t( keyvalues )

-- ----------------------------------------------------------------------------
-- If there are different names on each side of the street, we create one name
-- containing both.
-- If "name" does not exist but "name:en" does, use that.
-- ----------------------------------------------------------------------------
   set_name_left_right_en_t( keyvalues )

-- ----------------------------------------------------------------------------
-- Move refs to consider as "official" to official_ref
-- ----------------------------------------------------------------------------
   set_official_ref_t( keyvalues )

-- ----------------------------------------------------------------------------
-- Consolidate some rare highway types into ones we can display.
-- ----------------------------------------------------------------------------
   process_golf_tracks_t( keyvalues )

-- ----------------------------------------------------------------------------
-- "Sabristas" sometimes add dubious names to motorway junctions.  Don't show
-- them if they're not signed.
-- ----------------------------------------------------------------------------
   suppress_unsigned_motorway_junctions_t( keyvalues )

-- ----------------------------------------------------------------------------
-- Move unsigned road refs to the name, in brackets.
-- ----------------------------------------------------------------------------
    suppress_unsigned_road_refs_t( keyvalues )

-- ----------------------------------------------------------------------------
-- Consolidate more values for extraction / display
-- ----------------------------------------------------------------------------
   consolidate_lua_01_t( keyvalues )
   consolidate_lua_02_t( keyvalues )

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
          ( keyvalues["sidewalk:right"] == "separate"  ) or 
          ( keyvalues["sidewalk:right"] == "yes"       ) or
          ( keyvalues["sidewalk:both"] == "separate"   ) or 
          ( keyvalues["sidewalk:both"] == "yes"        ) or
          ( keyvalues["footway"]  == "separate"        ) or 
          ( keyvalues["footway"]  == "yes"             ) or
          ((( keyvalues["shoulder"] == "both"        )   or
            ( keyvalues["shoulder"] == "left"        )   or 
            ( keyvalues["shoulder"] == "right"       )   or 
            ( keyvalues["shoulder"] == "yes"         )   or
            ( keyvalues["shoulder:both"] == "yes"    )   or
            ( keyvalues["shoulder:left"] == "yes"    )   or
            ( keyvalues["shoulder:right"] == "yes"   )   or
            ( keyvalues["hard_shoulder"] == "yes"    ))  and
           (  keyvalues["expressway"] ~= "yes"        )  and
           (  keyvalues["motorroad"] ~= "yes"         )) or
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
      if (( keyvalues["verge"]       == "both"            ) or 
          ( keyvalues["verge"]       == "left"            ) or 
          ( keyvalues["verge"]       == "separate"        ) or 
          ( keyvalues["verge"]       == "right"           ) or 
          ( keyvalues["verge"]       == "yes"             ) or
          ( keyvalues["verge:both"]  == "separate"        ) or
          ( keyvalues["verge:both"]  == "yes"             ) or
          ( keyvalues["verge:left"]  == "separate"        ) or
          ( keyvalues["verge:left"]  == "yes"             ) or
          ( keyvalues["verge:right"] == "separate"        ) or
          ( keyvalues["verge:right"] == "yes"             )) then
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
          ( keyvalues["sidewalk:right"] == "separate"  ) or 
          ( keyvalues["sidewalk:right"] == "yes"       ) or
          ( keyvalues["sidewalk:both"] == "separate"   ) or 
          ( keyvalues["sidewalk:both"] == "yes"        ) or
          ( keyvalues["footway"]  == "separate"        ) or 
          ( keyvalues["footway"]  == "yes"             ) or
          ((( keyvalues["shoulder"] == "both"        )   or
            ( keyvalues["shoulder"] == "left"        )   or 
            ( keyvalues["shoulder"] == "right"       )   or 
            ( keyvalues["shoulder"] == "yes"         )   or
            ( keyvalues["shoulder:both"] == "yes"    )   or
            ( keyvalues["shoulder:left"] == "yes"    )   or
            ( keyvalues["shoulder:right"] == "yes"   )   or
            ( keyvalues["hard_shoulder"] == "yes"    ))  and
           (  keyvalues["expressway"] ~= "yes"        )  and
           (  keyvalues["motorroad"] ~= "yes"         )) or
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
      if (( keyvalues["verge"]       == "both"           ) or 
          ( keyvalues["verge"]       == "left"           ) or 
          ( keyvalues["verge"]       == "separate"       ) or 
          ( keyvalues["verge"]       == "right"          ) or 
          ( keyvalues["verge"]       == "yes"            ) or
          ( keyvalues["verge:both"]  == "separate"       ) or
          ( keyvalues["verge:both"]  == "yes"            ) or
          ( keyvalues["verge:left"]  == "separate"       ) or
          ( keyvalues["verge:left"]  == "yes"            ) or
          ( keyvalues["verge:right"] == "separate"       ) or
          ( keyvalues["verge:right"] == "yes"            )) then
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
          ( keyvalues["sidewalk:right"] == "separate"  ) or 
          ( keyvalues["sidewalk:right"] == "yes"       ) or
          ( keyvalues["sidewalk:both"] == "separate"   ) or 
          ( keyvalues["sidewalk:both"] == "yes"        ) or
          ( keyvalues["footway"]  == "separate"        ) or 
          ( keyvalues["footway"]  == "yes"             ) or
          ((( keyvalues["shoulder"] == "both"        )   or
            ( keyvalues["shoulder"] == "left"        )   or 
            ( keyvalues["shoulder"] == "right"       )   or 
            ( keyvalues["shoulder"] == "yes"         )   or
            ( keyvalues["shoulder:both"] == "yes"    )   or
            ( keyvalues["shoulder:left"] == "yes"    )   or
            ( keyvalues["shoulder:right"] == "yes"   )   or
            ( keyvalues["hard_shoulder"] == "yes"    ))  and
           (  keyvalues["expressway"] ~= "yes"        )  and
           (  keyvalues["motorroad"] ~= "yes"         )) or
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
      if (( keyvalues["verge"]       == "both"           ) or 
          ( keyvalues["verge"]       == "left"           ) or 
          ( keyvalues["verge"]       == "separate"       ) or 
          ( keyvalues["verge"]       == "right"          ) or 
          ( keyvalues["verge"]       == "yes"            ) or
          ( keyvalues["verge:both"]  == "separate"       ) or
          ( keyvalues["verge:both"]  == "yes"            ) or
          ( keyvalues["verge:left"]  == "separate"       ) or
          ( keyvalues["verge:left"]  == "yes"            ) or
          ( keyvalues["verge:right"] == "separate"       ) or
          ( keyvalues["verge:right"] == "yes"            )) then
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
          ( keyvalues["sidewalk:right"] == "separate"  ) or 
          ( keyvalues["sidewalk:right"] == "yes"       ) or
          ( keyvalues["sidewalk:both"] == "separate"   ) or 
          ( keyvalues["sidewalk:both"] == "yes"        ) or
          ( keyvalues["footway"]  == "separate"        ) or 
          ( keyvalues["footway"]  == "yes"             ) or
          ((( keyvalues["shoulder"] == "both"        )   or
            ( keyvalues["shoulder"] == "left"        )   or 
            ( keyvalues["shoulder"] == "right"       )   or 
            ( keyvalues["shoulder"] == "yes"         )   or
            ( keyvalues["shoulder:both"] == "yes"    )   or
            ( keyvalues["shoulder:left"] == "yes"    )   or
            ( keyvalues["shoulder:right"] == "yes"   )   or
            ( keyvalues["hard_shoulder"] == "yes"    ))  and
           (  keyvalues["expressway"] ~= "yes"        )  and
           (  keyvalues["motorroad"] ~= "yes"         )) or
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
      if (( keyvalues["verge"]       == "both"           ) or 
          ( keyvalues["verge"]       == "left"           ) or 
          ( keyvalues["verge"]       == "separate"       ) or 
          ( keyvalues["verge"]       == "right"          ) or 
          ( keyvalues["verge"]       == "yes"            ) or
          ( keyvalues["verge:both"]  == "separate"       ) or
          ( keyvalues["verge:both"]  == "yes"            ) or
          ( keyvalues["verge:left"]  == "separate"       ) or
          ( keyvalues["verge:left"]  == "yes"            ) or
          ( keyvalues["verge:right"] == "separate"       ) or
          ( keyvalues["verge:right"] == "yes"            )) then
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
          ( keyvalues["sidewalk:right"] == "separate"  ) or 
          ( keyvalues["sidewalk:right"] == "yes"       ) or
          ( keyvalues["sidewalk:both"] == "separate"   ) or 
          ( keyvalues["sidewalk:both"] == "yes"        ) or
          ( keyvalues["footway"]  == "separate"        ) or 
          ( keyvalues["footway"]  == "yes"             ) or
          ((( keyvalues["shoulder"] == "both"        )   or
            ( keyvalues["shoulder"] == "left"        )   or 
            ( keyvalues["shoulder"] == "right"       )   or 
            ( keyvalues["shoulder"] == "yes"         )   or
            ( keyvalues["shoulder:both"] == "yes"    )   or
            ( keyvalues["shoulder:left"] == "yes"    )   or
            ( keyvalues["shoulder:right"] == "yes"   )   or
            ( keyvalues["hard_shoulder"] == "yes"    ))  and
           (  keyvalues["expressway"] ~= "yes"        )  and
           (  keyvalues["motorroad"] ~= "yes"         )) or
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
      if (( keyvalues["verge"]       == "both"           ) or 
          ( keyvalues["verge"]       == "left"           ) or 
          ( keyvalues["verge"]       == "separate"       ) or 
          ( keyvalues["verge"]       == "right"          ) or 
          ( keyvalues["verge"]       == "yes"            ) or
          ( keyvalues["verge:both"]  == "separate"       ) or
          ( keyvalues["verge:both"]  == "yes"            ) or
          ( keyvalues["verge:left"]  == "separate"       ) or
          ( keyvalues["verge:left"]  == "yes"            ) or
          ( keyvalues["verge:right"] == "separate"       ) or
          ( keyvalues["verge:right"] == "yes"            )) then
          keyvalues["highway"] = "primary_verge"
      end
   end

-- ----------------------------------------------------------------------------
-- Consolidate more values for extraction / display
-- ----------------------------------------------------------------------------
   consolidate_lua_03_t( keyvalues )

-- ----------------------------------------------------------------------------
-- We set 'access = "no"' here on all parking spaces and highway emergency
-- bays, for raster rendering purposes.
-- It's not done in the shared code in case other consumers of the schema want
-- to do something else.
-- ----------------------------------------------------------------------------
      if (( keyvalues["parking_space"] ~= nil  ) and
          ( keyvalues["parking_space"] ~= ""   )) then
         keyvalues["access"] = "no"
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
-- Slipways - render ways as miniature railway in addition to slipway icon
-- ----------------------------------------------------------------------------
   if ( keyvalues["leisure"] == "slipway" ) then
      keyvalues["railway"] = "miniature"
   end

-- ----------------------------------------------------------------------------
-- Sluice gates - various alternative keys for these four may have been
-- consolidated in the shared lua.  Here we send through as man_made, and also
-- display as building=roof.
-- Also waterfall (the dot or line is generic enough to work there too).
-- The change of waterway to weir ensures line features appear too.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["waterway"]     == "sluice_gate"      ) or
       (  keyvalues["waterway"]     == "waterfall"        ) or
       (  keyvalues["waterway"]     == "weir"             ) or
       (  keyvalues["waterway"]     == "floating_barrier" )) then
      keyvalues["man_made"] = "sluice_gate"
      keyvalues["building"] = "roof"
      keyvalues["waterway"] = "weir"
   end

-- ----------------------------------------------------------------------------
-- Consolidate more values for extraction / display
-- ----------------------------------------------------------------------------
   consolidate_lua_04_t( keyvalues )
-- ----------------------------------------------------------------------------
-- End of AJT generic additions.
-- ----------------------------------------------------------------------------

   return filter, keyvalues
end


function filter_tags_node (keyvalues, nokeys)

-- ----------------------------------------------------------------------------
-- AJT node-only additions.
-- ----------------------------------------------------------------------------
   keyvalues["sport"] = trim_after_semicolon( keyvalues["sport"] )

-- ----------------------------------------------------------------------------
-- Consolidate some "ford" values into "yes".
-- This is here rather than in "generic" because "generic" is called after this
-- There is a similar section in way-only.
-- ----------------------------------------------------------------------------
   if (( keyvalues["ford"] == "tidal_causeway" ) or
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
-- A natural=cliff et al node can't be drawn as a linear cliff, but we can
-- treat it as a locality.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["natural"] == "cliff"          )  or
        ( keyvalues["natural"] == "ridge"          )  or
        ( keyvalues["natural"] == "arch"           )  or
        ( keyvalues["natural"] == "strait"         )  or
        ( keyvalues["natural"] == "mountain_range" )  or
        ( keyvalues["natural"] == "gully"          )) and
       (( keyvalues["place"]   == nil              )  or
        ( keyvalues["place"]   == ""               ))) then
      keyvalues["place"]   = "locality"
      keyvalues["natural"] = nil
   end

-- ----------------------------------------------------------------------------
-- We treat node islands as just localities.
-- ----------------------------------------------------------------------------
   if (( keyvalues["place"] == "island" )  or
       ( keyvalues["place"] == "islet"  )) then
      keyvalues["place"] = "locality"
   end

-- ----------------------------------------------------------------------------
-- All node highway=platform are actually highway=bus_stop
-- ----------------------------------------------------------------------------
   if ( keyvalues["highway"] == "platform" ) then
      keyvalues["highway"] = "bus_stop"
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
-- ----------------------------------------------------------------------------
   keyvalues["sport"] = trim_after_semicolon( keyvalues["sport"] )

-- ----------------------------------------------------------------------------
-- Consolidate some "ford" values into "yes".
-- This is here rather than in "generic" because "generic" is called after this
-- There is a similar section in way-only.
-- ----------------------------------------------------------------------------
   if (( keyvalues["ford"] == "tidal_causeway" ) or
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
              ( keyvalues["sport"]    == "motocross"     )  or
              ( keyvalues["sport"]    == "karting"       )) and
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
-- With vector processing we need to explicitly decide whether a feature should
-- be treated as an area or not.  With raster we generally speaking don't -
-- "aeroway" is defined above as a polygon key so osm2pgsql will treat one as
-- an area if it it is closed, and not otherwise.
--
-- If something is a runway and is a closed way we can assume that what has
-- been mapped is the outline of the area of the linear runway (because
-- although "circular runways" are a concept -
-- https://en.wikipedia.org/wiki/Endless_runway - they are not not a thing
-- right now.  However, closed circular taxiways are very much a thing, and
-- so we must check the "area" tag there.  Unless area=yes is explicitly set,
-- we assume that a taxiway is linear.
-- ----------------------------------------------------------------------------
    if (( keyvalues["aeroway"] == "taxiway"  ) and
        ( keyvalues["area"]    ~= "yes"      )) then
        keyvalues["area"] = "no"
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
   keyvalues["sport"] = trim_after_semicolon( keyvalues["sport"] )

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
-- ----------------------------------------------------------------------------
-- For the English/Welsh National trails:
-- These have a known operator, and there are a limited number of them.
-- * We add a "ref" here designed to be shown withing a black and white 
--   "shield".
-- * We also consolidate names so that "names" like "King Charles III
--   England  Coast Path: Folkestone to Ramsgate" get changed to just 
--   "England Coast Path"
--
-- This is done in code shared with raster.
-- ----------------------------------------------------------------------------
         fix_silly_nt_names_t( keyvalues )

-- ----------------------------------------------------------------------------
-- Some "regional" trails are also split into portions and given silly names
-- such as "Trans-Pennine Trail (Warrington to Ashton-upon-Mersey)".
-- We remove the silly part of the name, also in code shared with raster.
-- ----------------------------------------------------------------------------
         fix_silly_rwn_names_t( keyvalues )

      end  -- walking

-- ----------------------------------------------------------------------------
-- Cycle networks
-- We exclude some obviously silly refs.
-- We use "ref" rather than "name".
-- We handle loops on the National Byway and append (r) on other RCNs.
-- ----------------------------------------------------------------------------
      if (((  keyvalues["network"]  == "ncn"                   )  or
           (  keyvalues["network"]  == "rcn"                   )  or
           ((  keyvalues["network"] == "lcn"                 )  and
            (( keyvalues["name"]    == "Solar System Route"  )   or
             ( keyvalues["name"]    == "Orbital Route"       )))) and
          ((  keyvalues["state"]    == nil                     )  or
           (( keyvalues["state"]    ~= "proposed"             )   and
            ( keyvalues["state"]    ~= "construction"         )   and
            ( keyvalues["state"]    ~= "abandoned"            )))) then
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
