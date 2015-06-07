polygon_keys = { 'building', 'landuse', 'amenity', 'harbour', 'historic', 'leisure', 
      'man_made', 'military', 'natural', 'office', 'place', 'power',
      'public_transport', 'shop', 'sport', 'tourism', 'waterway',
      'wetland', 'water', 'aeroway' }

generic_keys = {'access','addr:housename','addr:housenumber','addr:interpolation','admin_level','aerialway','aeroway','amenity','area','barrier',
   'bicycle','brand','bridge','boundary','building','capital','construction','covered','culvert','cutting','denomination','designation','disused','ele',
   'embarkment','foot','generation:source','harbour','highway','historic','hours','intermittent','junction','landuse','layer','leisure','lock',
   'man_made','military','motor_car','name','natural','office','oneway','operator','place','poi','population','power','power_source','public_transport',
   'railway','ref','religion','route','service','shop','sport','surface','toll','tourism','tower:type', 'tracktype','tunnel','water','waterway',
   'wetland','width','wood','type'}

function add_z_order(keyvalues)
   z_order = 0
   if (keyvalues["layer"] ~= nil ) then
      z_order = 10*keyvalues["layer"]
   end

   
   zordering_tags = {{ 'railway', nil, 5, 1}, { 'boundary', 'administrative', 0, 1}, 
      { 'bridge', 'yes', 10, 0 }, { 'bridge', 'true', 10, 0 }, { 'bridge', 1, 10, 0 },
      { 'tunnel', 'yes', -10, 0}, { 'tunnel', 'true', -10, 0}, { 'tunnel', 1, -10, 0}, 
      { 'highway', 'minor', 3, 0}, { 'highway', 'road', 3, 0 }, { 'highway', 'unclassified', 3, 0 },
      { 'highway', 'residential', 3, 0 }, { 'highway', 'tertiary_link', 4, 0}, { 'highway', 'tertiary', 4, 0},
      { 'highway', 'secondary_link', 6, 1}, { 'highway', 'secondary', 6, 1},
      { 'highway', 'primary_link', 7, 1}, { 'highway', 'primary', 7, 1},
      { 'highway', 'trunk_link', 8, 1}, { 'highway', 'trunk', 8, 1},
      { 'highway', 'motorway_link', 9, 1}, { 'highway', 'motorway', 9, 1},
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
-- Designation processing
--
-- The "standard" stylesheet contains rules for different sorts of tracks 
-- (tracktype), but doesn't contain rules for English/Welsh rights of way
-- designations.
--
-- The changes here do the following:
-- 1) Render any non-designated footway, bridleway or track as "path" 
--    (grey dashes in the "standard" style)
-- 2) Render anything designated as "public_footpath" as a "footway" (dotted 
--    salmon)
-- 3) Render anything designated as "public_bridleway" as a "footway" (dotted 
--    green)
-- 4) Render anything designated as "restricted_byway" as a "grade4 track" 
--    (dashed and dotted brown).
-- 5) Render anything designated as "byway_open_to_all_traffic" as a 
--    "grade3 track" (dashed brown)
-- 6) Render anything designated as "unclassified_county_road" or a 
--    misspelling as a "grade2 track" (long dashed brown)
--
-- These changes do mean that the the resulting database isn't any use for
-- anything other than rendering, but they do allow designations to be 
-- displayed without any stylesheet changes.  Also, some information is
-- lost in the process (e.g. track or steps vs path).
-- ----------------------------------------------------------------------------

   keyvalues["tracktype"] = nil

   if ((keyvalues["highway"] == "footway") or 
       (keyvalues["highway"] == "bridleway") or 
       (keyvalues["highway"] == "track")) then
      keyvalues["highway"] = "path"
   end

-- ----------------------------------------------------------------------------
-- This currently doesn't work - seems to be processed twice?
-- ----------------------------------------------------------------------------
   if ((keyvalues["highway"] == "unclassified") and
       (keyvalues["surface"] == "unpaved"     )) then
      keyvalues["highway"] = "track"
      keyvalues["tracktype"] = "grade1"
   end

   if ((keyvalues["designation"] == "unclassified_county_road") or
       (keyvalues["designation"] == "unclassified_country_road") or
       (keyvalues["designation"] == "unclassified_highway")) then
      keyvalues["highway"] = "track"
      keyvalues["tracktype"] = "grade2"
   end

   if (keyvalues["designation"] == "byway_open_to_all_traffic") then
      keyvalues["highway"] = "track"
      keyvalues["tracktype"] = "grade3"
   end

   if (keyvalues["designation"] == "restricted_byway") then
      keyvalues["highway"] = "track"
      keyvalues["tracktype"] = "grade4"
   end

   if (keyvalues["designation"] == "public_bridleway") then
      keyvalues["highway"] = "bridleway"
   end

   if (keyvalues["designation"] == "public_footpath") then
      keyvalues["highway"] = "footway"
   end

-- ----------------------------------------------------------------------------
-- Remove admin boundaries from the map
-- I do this because I'm simply not interest in admin boundaries and I'm lucky
-- enough to live in a place where I don't have to be.
-- ----------------------------------------------------------------------------
   if (keyvalues["boundary"] == "administrative") then
      keyvalues["boundary"] = nil
   end

-- ----------------------------------------------------------------------------
-- Remove leisure=common from the map.  It's well-defined in the wiki but
-- (at least in the UK) used so inconsistently as to be useless.
-- ----------------------------------------------------------------------------
   if (keyvalues["leisure"] == "common") then
      keyvalues["leisure"] = nil
   end

-- ----------------------------------------------------------------------------
-- Pretend add landuse=industrial to some industrial sub-types to force 
-- name rendering.  Similarly, some commercial and leisure.
-- ----------------------------------------------------------------------------
   if ((keyvalues["man_made"]   == "works") or 
       (keyvalues["man_made"]   == "wastewater_plant") or 
       (keyvalues["industrial"] == "depot") or 
       (keyvalues["industrial"] == "warehouse") or
       (keyvalues["amenity"]    == "recycling") or
       (keyvalues["amenity"]    == "animal_shelter")) then
      keyvalues["landuse"] = "industrial"
   end

   if ((keyvalues["amenity"]    == "car_wash") or
       (keyvalues["amenity"]    == "conference_centre") or
       (keyvalues["amenity"]    == "nursing_home") or
       (keyvalues["amenity"]    == "care_home") or
       (keyvalues["shop"]       == "truck") or
       (keyvalues["shop"]       == "garden_centre") or
       (keyvalues["shop"]       == "gates") or
       (keyvalues["commercial"] == "office") or
       (keyvalues["office"]     == "hvac") or
       (keyvalues["office"]     == "auctioneer") or
       (keyvalues["landuse"]     == "churchyard")) then
      keyvalues["landuse"] = "commercial"
   end

   if (keyvalues["leisure"]   == "fishing") then
      keyvalues["leisure"] = "park"
   end

-- ----------------------------------------------------------------------------
-- landuse=field is rarely used.  I tried unsuccessfully to change the colour 
-- in the stylesheet so am mapping it here.
-- ----------------------------------------------------------------------------
   if (keyvalues["landuse"]   == "field") then
      keyvalues["landuse"] = "farmland"
   end

-- ----------------------------------------------------------------------------
-- As of 21st May 2014, abandoned ralways are no longer rendered in the 
-- standard style.  I'll pretend that they're "disused" so that they appear
-- on the map.  Abandoned railways are often major landscape features.
-- ----------------------------------------------------------------------------
   if (( keyvalues["railway"]   == "dismantled" ) or
       ( keyvalues["railway"]   == "abandoned"  )) then
      keyvalues["railway"] = "disused"
   end

-- ----------------------------------------------------------------------------
-- Railway construction
-- This is done mostly to make the HS2 show up.
-- ----------------------------------------------------------------------------
   if ( keyvalues["railway"]   == "proposed" ) then
      keyvalues["railway"] = "construction"
   end

-- ----------------------------------------------------------------------------
-- Historic canal
-- A former canal can, like an abandoned railway, still be a major
-- physical feature.
-- ----------------------------------------------------------------------------
   if ( keyvalues["historic"]   == "canal" ) then
      keyvalues["waterway"] = "derelict_canal"
   end

-- ----------------------------------------------------------------------------
-- Supermarkets as normal buildings
-- In the version of OSM-carto that I use this with, Supermarkets would 
-- otherwise display as pink, which does not show up over pink retail landuse.
-- ----------------------------------------------------------------------------
   if ( keyvalues["building"]   == "supermarket" ) then
      keyvalues["building"] = "yes"
   end

-- ----------------------------------------------------------------------------
-- highway=byway to track
-- The "bywayness" of something should be handled by designation now.  byway
-- isn't otherwise rendered (and really should no longer be used), so change 
-- to track (which is what it probably will be).
-- ----------------------------------------------------------------------------
   if ( keyvalues["highway"]   == "byway" ) then
      keyvalues["highway"] = "track"
   end

-- ----------------------------------------------------------------------------
-- highway=living_street to residential
-- This is done because it's a difference I don't want to draw attention to -
-- they aren't "different enough to make them render differently".
-- ----------------------------------------------------------------------------
   if ( keyvalues["highway"]   == "living_street" ) then
      keyvalues["highway"] = "residential"
   end

-- ----------------------------------------------------------------------------
-- highway=escape to service
-- There aren't many escape lanes mapped, but they do exist
-- ----------------------------------------------------------------------------
   if ( keyvalues["highway"]   == "escape" ) then
      keyvalues["highway"] = "service"
   end

-- ----------------------------------------------------------------------------
-- tourism=bed_and_breakfast was removed by the "style police" in
-- https://github.com/gravitystorm/openstreetmap-carto/pull/695
-- I'll pretend that they're "guest_house".
-- ----------------------------------------------------------------------------
   if ( keyvalues["tourism"]   == "bed_and_breakfast" ) then
      keyvalues["tourism"] = "guest_house"
   end

-- ----------------------------------------------------------------------------
-- Things that are both hotels and pubs should render as pubs, because I'm 
-- far more likely to be looking for the latter than the former.
-- This is done by removing the tourism tag for them.
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"]   == "pub"   ) and
       ( keyvalues["tourism"]   == "hotel" )) then
      keyvalues["tourism"] = nil
   end

-- ----------------------------------------------------------------------------
-- render barrier=kissing_gate as barrier=gate for now
-- render barrier=swing_gate as barrier=gate (it's a gate)
-- render barrier=footgate as barrier=gate, since that's what it means
-- ----------------------------------------------------------------------------
   if (( keyvalues["barrier"]   == "kissing_gate"          )  or
       ( keyvalues["barrier"]   == "swing_gate"            )  or
       ( keyvalues["barrier"]   == "footgate"              )  or
       ( keyvalues["barrier"]   == "hampshire_gate"        )  or
       ( keyvalues["barrier"]   == "turnstile"             )  or
       ( keyvalues["barrier"]   == "full-height_turnstile" )  or
       ( keyvalues["barrier"]   == "bump_gate"             )  or
       ( keyvalues["barrier"]   == "lytch_gate"            )  or
       ( keyvalues["barrier"]   == "horse_jump"            )  or
       ( keyvalues["barrier"]   == "flood_gate"            )) then
      keyvalues["barrier"] = "gate"
   end

-- ----------------------------------------------------------------------------
-- render barrier=bar as barrier=horse_stile (Norfolk)
-- ----------------------------------------------------------------------------
   if (( keyvalues["barrier"]   == "bar"                   )  or
       ( keyvalues["barrier"]   == "chain"                 )) then
      keyvalues["barrier"] = "horse_stile"
   end

-- ----------------------------------------------------------------------------
-- render barrier=bar as barrier=horse_stile (Norfolk)
-- ----------------------------------------------------------------------------
   if (( keyvalues["barrier"]   == "chicane"               )  or
       ( keyvalues["barrier"]   == "squeeze"               )  or
       ( keyvalues["barrier"]   == "motorcycle_barrier"    )) then
      keyvalues["barrier"] = "cycle_barrier"
   end

-- ----------------------------------------------------------------------------
-- Note that there is a catch-all for barriers so there's no need to 
-- specifically catch e.g. "barrier=wire_fence" on ways
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- render barrier=v_stile as barrier=stile
-- ----------------------------------------------------------------------------
   if (( keyvalues["barrier"]   == "v_stile"         )  or
       ( keyvalues["barrier"]   == "squeeze_stile"   )  or
       ( keyvalues["barrier"]   == "squeeze_point"   )  or
       ( keyvalues["barrier"]   == "step_over"       )) then
      keyvalues["barrier"] = "stile"
   end

-- ----------------------------------------------------------------------------
-- remove barrier=entrance as it's not really a barrier.
-- ----------------------------------------------------------------------------
   if ( keyvalues["barrier"]   == "entrance" ) then
      keyvalues["barrier"] = nil
   end

-- ----------------------------------------------------------------------------
-- natural=tree_row was added to the standard style file after my version.
-- I'm not convinced that it makes sense to distinguish from hedge, so I'll
-- just display as hedge.
-- ----------------------------------------------------------------------------
   if ( keyvalues["natural"]   == "tree_row" ) then
      keyvalues["barrier"] = "hedge"
   end

-- ----------------------------------------------------------------------------
-- Remove road names that are not signed on the ground
-- ----------------------------------------------------------------------------
   if (keyvalues["name:signed"] == "no") then
      keyvalues["name"] = nil
   end

-- ----------------------------------------------------------------------------
-- Remove road refs that are not signed on the ground
-- ----------------------------------------------------------------------------
   if (keyvalues["ref:signed"] == "no") then
      keyvalues["ref"] = nil
   end

-- ----------------------------------------------------------------------------
-- Handle dodgy access tags.  Note that this doesn't affect my "designation"
-- processing, but may be used by the main style, as "foot", "bicycle" and 
-- "horse" are all in as columns.
-- ----------------------------------------------------------------------------
   if (keyvalues["access:foot"] == "yes") then
      keyvalues["foot"] = "yes"
   end

   if (keyvalues["access:bicycle"] == "yes") then
      keyvalues["bicycle"] = "yes"
   end

   if (keyvalues["access:horse"] == "yes") then
      keyvalues["horse"] = "yes"
   end

-- ----------------------------------------------------------------------------
-- Masts etc.  Consolidate various sorts of masts and towers into the "mast"
-- group.  Note that this includes "tower" temporarily.
-- ----------------------------------------------------------------------------
   if (( keyvalues["man_made"] == "phone_mast"          )  or
       ( keyvalues["man_made"] == "radio_mast"          )  or
       ( keyvalues["man_made"] == "communications_mast" )  or
       ( keyvalues["man_made"] == "communication_mast"  )  or
       ( keyvalues["man_made"] == "tower"               )  or
       ( keyvalues["man_made"] == "communications_tower" )) then
      keyvalues["man_made"] = "mast"
   end


-- ----------------------------------------------------------------------------
-- End of AJT additions.
-- ----------------------------------------------------------------------------

   return filter, keyvalues
end

function filter_tags_node (keyvalues, nokeys)
   return filter_tags_generic(keyvalues, nokeys)
end

function filter_basic_tags_rel (keyvalues, nokeys)

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

   type = keyvalues["type"]
   keyvalues["type"] = nil
  

   if (type == "boundary") then
      boundary = 1
   end
   if ((type == "multipolygon") and keyvalues["boundary"]) then
      boundary = 1
   elseif (type == "multipolygon") then
      polygon = 1
      polytagcount = 0;
      for i,k in ipairs(polygon_keys) do
         if keyvalues[k] then
            polytagcount = polytagcount + 1
         end
      end
      if (polytagcount == 0) then
         for i = 1,membercount do
            if (roles[i] == "outer") then
               for k,v in pairs(keyvaluemembers[i]) do
                  keyvalues[k] = v
               end
            end
         end
      end
      for i = 1,membercount do
         superseeded = 1
         for k,v in pairs(keyvaluemembers[i]) do
            if ((keyvalues[k] == nil) or (keyvalues[k] ~= v)) then
               for j,k2 in ipairs(generic_keys) do
                  if (k == k2) then
                     superseeded = 0;
                     break
                  end
               end
            end
         end
         membersuperseeded[i] = superseeded
      end
   end

   keyvalues, roads = add_z_order(keyvalues)

   return filter, keyvalues, membersuperseeded, boundary, polygon, roads
end
