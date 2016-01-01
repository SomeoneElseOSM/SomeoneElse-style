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
-- 1) Render any non-designated footway, bridleway, cycleway or track as "path" 
--    (grey dashes in the "standard" style)
-- 2) Render anything designated as "public_footpath" as a "footway" (dotted 
--    salmon)
-- 3) Render anything designated as "public_bridleway" as a "bridleway" (dotted 
--    green).
-- 4) Render anything designated as "restricted_byway" as a "grade4 track" 
--    (dashed and dotted brown).  Likewise "public_right_of_way".
-- 5) Render anything designated as "byway_open_to_all_traffic" as a 
--    "grade3 track" (dashed brown)
-- 6) Render anything designated as "unclassified_county_road" or a 
--    misspelling as a "grade2 track" (long dashed brown)
--
-- These changes do mean that the the resulting database isn't any use for
-- anything other than rendering, but they do allow designations to be 
-- displayed without any stylesheet changes.  Also, some information is
-- lost in the process (e.g. track s path).
-- ----------------------------------------------------------------------------

   keyvalues["tracktype"] = nil

   if (( keyvalues["highway"] == "footway"   ) or 
       ( keyvalues["highway"] == "steps"     ) or 
       ( keyvalues["highway"] == "bridleway" ) or 
       ( keyvalues["highway"] == "cycleway"  )) then
      if (( keyvalues["width"] == "2"   ) or
          ( keyvalues["width"] == "2.5" ) or
          ( keyvalues["width"] == "3"   ) or
          ( keyvalues["width"] == "4"   )) then
          keyvalues["highway"] = "pathwide"
      else
          keyvalues["highway"] = "path"
      end
   end

   if ( keyvalues["highway"] == "track" ) then
      keyvalues["highway"] = "pathwide"
   end

   if ((  keyvalues["designation"]      == nil         ) and
       (( keyvalues["trail_visibility"] == "no"       )  or
        ( keyvalues["trail_visibility"] == "horrible" )  or
        ( keyvalues["trail_visibility"] == "bad"      ))) then
      keyvalues["highway"] = nil
   end

-- ----------------------------------------------------------------------------
-- The OSM Carto derivative that I'm using still tries to second-guess paths
-- as footway or cycleway.  We don't want to do this - set "designated" to
-- "yes"
-- ----------------------------------------------------------------------------
   if ( keyvalues["foot"] == "designated" ) then
      keyvalues["foot"] = "yes"
   end

   if ( keyvalues["bicycle"] == "designated" ) then
      keyvalues["bicycle"] = "yes"
   end

   if ( keyvalues["horse"] == "designated" ) then
      keyvalues["horse"] = "yes"
   end

   if (( keyvalues["highway"] == "unclassified" ) and
       ( keyvalues["surface"] == "unpaved"      )) then
      keyvalues["highway"] = "track"
      keyvalues["tracktype"] = "grade1"
   end

   if ((keyvalues["designation"] == "unclassified_county_road") or
       (keyvalues["designation"] == "unclassified_country_road") or
       (keyvalues["designation"] == "unclassified_highway")) then
      if (( keyvalues["highway"] == "footway"   ) or 
          ( keyvalues["highway"] == "steps"     ) or 
          ( keyvalues["highway"] == "bridleway" ) or 
	  ( keyvalues["highway"] == "cycleway"  ) or
	  ( keyvalues["highway"] == "path"      )) then
	  keyvalues["tracktype"] = "grade5"
      else
          keyvalues["highway"] = "track"
	  keyvalues["tracktype"] = "grade2"
      end
   end

   if (keyvalues["designation"] == "byway_open_to_all_traffic") then
      if (( keyvalues["highway"] == "footway"   ) or 
          ( keyvalues["highway"] == "steps"     ) or 
          ( keyvalues["highway"] == "bridleway" ) or 
	  ( keyvalues["highway"] == "cycleway"  ) or
	  ( keyvalues["highway"] == "path"      )) then
	  keyvalues["tracktype"] = "grade5"
      else
          keyvalues["highway"] = "track"
	  keyvalues["tracktype"] = "grade3"
      end
   end

   if (( keyvalues["designation"] == "restricted_byway"    ) or
       ( keyvalues["designation"] == "public_right_of_way" )) then
      if (( keyvalues["highway"] == "footway"   ) or 
          ( keyvalues["highway"] == "steps"     ) or 
          ( keyvalues["highway"] == "bridleway" ) or 
	  ( keyvalues["highway"] == "cycleway"  ) or
	  ( keyvalues["highway"] == "path"      )) then
	  keyvalues["tracktype"] = "grade5"
      else
          keyvalues["highway"] = "track"
	  keyvalues["tracktype"] = "grade4"
      end
   end

   if (keyvalues["designation"] == "public_bridleway") then
      if (( keyvalues["highway"] == "footway"   ) or 
          ( keyvalues["highway"] == "steps"     ) or 
          ( keyvalues["highway"] == "bridleway" ) or 
	  ( keyvalues["highway"] == "cycleway"  ) or
	  ( keyvalues["highway"] == "path"      )) then
	  keyvalues["highway"] = "bridleway"
      else
	  keyvalues["highway"] = "bridlewaywide"
      end
   end

   if (keyvalues["designation"] == "public_footpath") then
      if (( keyvalues["highway"] == "footway"   ) or 
          ( keyvalues["highway"] == "steps"     ) or 
          ( keyvalues["highway"] == "bridleway" ) or 
	  ( keyvalues["highway"] == "cycleway"  ) or
	  ( keyvalues["highway"] == "path"      )) then
	  keyvalues["highway"] = "footway"
      else
	  keyvalues["highway"] = "footwaywide"
      end
   end

   if ((  keyvalues["access"]      == "private"                    ) and
       (( keyvalues["designation"] == "public_footpath"           )  or
        ( keyvalues["designation"] == "public_bridleway"          )  or
        ( keyvalues["designation"] == "restricted_byway"          )  or
        ( keyvalues["designation"] == "byway_open_to_all_traffic" )  or
        ( keyvalues["designation"] == "unclassified_county_road"  )  or
        ( keyvalues["designation"] == "unclassified_country_road" )  or
        ( keyvalues["designation"] == "unclassified_highway"      ))) then
      keyvalues["access"] = nil
   end

-- ----------------------------------------------------------------------------
-- Render Access land the same as nature reserve / national park currently is
-- ----------------------------------------------------------------------------
   if (keyvalues["designation"] == "access_land") then
      keyvalues["leisure"] = "nature_reserve"
   end

-- ----------------------------------------------------------------------------
-- Render narrow tertiary roads as unclassified
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"] == "tertiary"   )  and
       (( keyvalues["width"]  == "2"         )   or
        ( keyvalues["width"]  == "3"         ))) then
      keyvalues["highway"] = "unclassified"
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
   if (( keyvalues["man_made"]   == "wastewater_plant"    ) or 
       ( keyvalues["man_made"]   == "reservoir_covered"   ) or 
       ( keyvalues["man_made"]   == "petroleum_well"      ) or 
       ( keyvalues["industrial"] == "warehouse"           ) or
       ( keyvalues["building"]   == "warehouse"           ) or
       ( keyvalues["industrial"] == "brewery"             ) or 
       ( keyvalues["industrial"] == "factory"             ) or 
       ( keyvalues["industrial"] == "yes"                 ) or 
       ( keyvalues["industrial"] == "depot"               ) or 
       ( keyvalues["building"]   == "depot"               ) or 
       ( keyvalues["industrial"] == "scrap_yard"          ) or 
       ( keyvalues["industrial"] == "scrapyard"           ) or 
       ( keyvalues["industrial"] == "yard"                ) or 
       ( keyvalues["industrial"] == "engineering"         ) or
       ( keyvalues["industrial"] == "machine_shop"        ) or
       ( keyvalues["industrial"] == "packaging"           ) or
       ( keyvalues["industrial"] == "haulage"             ) or
       ( keyvalues["building"]   == "industrial"          ) or
       ( keyvalues["amenity"]    == "recycling"           ) or
       ( keyvalues["craft"]      == "brewery"             ) or
       ( keyvalues["power"]      == "plant"               ) or
       ( keyvalues["building"]   == "works"               ) or
       ( keyvalues["building"]   == "manufacture"         ) or
       ( keyvalues["man_made"]   == "gas_station"         ) or
       ( keyvalues["man_made"]   == "gas_works"           ) or
       ( keyvalues["man_made"]   == "water_treatment"     ) or
       ( keyvalues["man_made"]   == "pumping_station"     ) or
       ( keyvalues["man_made"]   == "water_works"         )) then
      keyvalues["landuse"] = "industrial"
   end

   if ( keyvalues["man_made"]   == "works" ) then
      keyvalues["man_made"] = nil
      keyvalues["landuse"] = "industrial"
   end

-- ----------------------------------------------------------------------------
-- Shops etc. with icons already - just add "unnamedcommercial" landuse.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]       == "car"           ) or
       ( keyvalues["shop"]       == "car_repair"    ) or
       ( keyvalues["shop"]       == "garden_centre" ) or
       ( keyvalues["amenity"]    == "embassy"       )) then
      keyvalues["landuse"] = "unnamedcommercial"
   end

-- ----------------------------------------------------------------------------
-- Things without icons - add "commercial" landuse to include name too.
-- ----------------------------------------------------------------------------
   if (( keyvalues["building"]   == "commercial"         ) or
       ( keyvalues["building"]   == "office"             ) or
       ( keyvalues["man_made"]   == "telephone_exchange" ) or
       ( keyvalues["amenity"]    == "telephone_exchange" ) or
       ( keyvalues["building"]   == "telephone_exchange" ) or
       ( keyvalues["utility"]    == "telephone_exchange" ) or
       ( keyvalues["highway"]    == "services"           ) or
       ( keyvalues["landuse"]    == "churchyard"         ) or
       ( keyvalues["club"]       == "sport"              )) then
      keyvalues["landuse"] = "commercial"
   end

-- ----------------------------------------------------------------------------
-- Shop groups - just treat as retail landuse.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "mall"            ) or
       ( keyvalues["amenity"] == "marketplace"     ) or
       ( keyvalues["shop"]    == "market"          ) or
       ( keyvalues["amenity"] == "market"          ) or
       ( keyvalues["shop"]    == "shopping_centre" )) then
      keyvalues["landuse"] = "retail"
   end

   if (( keyvalues["amenity"]   == "scout_camp"     ) or
       ( keyvalues["landuse"]   == "scout_camp"     ) or	
       ( keyvalues["leisure"]   == "fishing"        ) or
       ( keyvalues["leisure"]   == "outdoor_centre" )) then
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
-- Attempt to do something sensible with trees
-- ----------------------------------------------------------------------------
   if (keyvalues["landuse"]   == "forest") then
      keyvalues["landuse"] = nil
      keyvalues["natural"] = "wood"
   end

   if (keyvalues["leaf_type"]   == "broadleaved") then
      keyvalues["landuse"] = nil
      keyvalues["natural"] = "broadleaved"
   end

   if (keyvalues["leaf_type"]   == "needleleaved") then
      keyvalues["landuse"] = nil
      keyvalues["natural"] = "needleleaved"
   end

   if (keyvalues["leaf_type"]   == "mixed") then
      keyvalues["landuse"] = nil
      keyvalues["natural"] = "mixedleaved"
   end

-- ----------------------------------------------------------------------------
-- Attempt to do something sensible with pubs
-- Pubs that serve real_ale get a nice IPA, ones that don't a yellowy lager,
-- closed pubs an "X".  Others get the default empty glass.
-- ----------------------------------------------------------------------------
   if (( keyvalues["real_ale"] ~= nil     ) and
       ( keyvalues["real_ale"] ~= "maybe" ) and
       ( keyvalues["real_ale"] ~= "no"    )) then
      keyvalues["amenity"] = "realaleyes"
   end

   if (keyvalues["real_ale"] == "no") then
      keyvalues["amenity"] = "realaleno"
   end

-- ----------------------------------------------------------------------------
-- People have used lots of tags for "former" or "dead" pubs.
-- "disused:amenity=pub" is the most popular.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["disused:amenity"] == "pub"    ) or
       (  keyvalues["abandoned:amenity"] == "pub"  ) or
       (  keyvalues["amenity:disused"] == "pub"    ) or
       (  keyvalues["amenity"] == "closed_pub"     ) or
       (  keyvalues["amenity"] == "dead_pub"       ) or
       (  keyvalues["amenity"] == "disused_pub"    ) or
       (  keyvalues["amenity"] == "former_pub"     ) or
       (  keyvalues["amenity"] == "old_pub"        ) or
       (  keyvalues["disused"] == "pub"            ) or
       (  keyvalues["disused:pub"] == "yes"        ) or
       (  keyvalues["former_amenity"] == "former_pub" ) or
       (  keyvalues["former_amenity"] == "pub"     ) or
       (  keyvalues["former_amenity"] == "old_pub" ) or
       (  keyvalues["former:amenity"] == "pub"     ) or
       (  keyvalues["old_amenity"] == "pub"        ) or
       (( keyvalues["amenity"] == "pub"           )  and
        ( keyvalues["disused"] == "yes"           ))) then
      keyvalues["amenity"] = "pubdead"
   end


-- ----------------------------------------------------------------------------
-- As of 21st May 2014, abandoned railways are no longer rendered in the 
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
   if (( keyvalues["building"]   == "supermarket"      ) or
       ( keyvalues["man_made"]   == "storage_tank"     ) or
       ( keyvalues["man_made"]   == "silo"             ) or
       ( keyvalues["man_made"]   == "tank"             ) or
       ( keyvalues["man_made"]   == "water_tank"       ) or
       ( keyvalues["man_made"]   == "kiln"             ) or
       ( keyvalues["man_made"]   == "gasometer"        ) or
       ( keyvalues["man_made"]   == "oil_tank"         ) or
       ( keyvalues["man_made"]   == "greenhouse"       ) or
       ( keyvalues["man_made"]   == "water_treatment"  ) or
       ( keyvalues["man_made"]   == "trickling_filter" ) or
       ( keyvalues["man_made"]   == "filter_bed"       ) or
       ( keyvalues["man_made"]   == "filtration_bed"   ) or
       ( keyvalues["man_made"]   == "waste_treatment"  )) then
      keyvalues["building"] = "yes"
   end

-- ----------------------------------------------------------------------------
-- Add "water" to some "wet" features for rendering.
-- ----------------------------------------------------------------------------
   if (( keyvalues["man_made"]   == "wastewater_reservoir"  ) or
       ( keyvalues["man_made"]   == "lagoon"                ) or
       ( keyvalues["man_made"]   == "lake"                  ) or
       ( keyvalues["man_made"]   == "reservoir"             )) then
      keyvalues["natural"] = "water"
   end

-- ----------------------------------------------------------------------------
-- Mistaggings for wastewater_plant
-- ----------------------------------------------------------------------------
   if (( keyvalues["man_made"]   == "sewage_works"      ) or
       ( keyvalues["man_made"]   == "wastewater_works"  )) then
      keyvalues["man_made"] = "wastewater_plant"
   end

-- ----------------------------------------------------------------------------
-- Map wind turbines to, er, wind turbines:
-- ----------------------------------------------------------------------------
   if (( keyvalues["man_made"]   == "wind_turbine" ) or
       ( keyvalues["man_made"]   == "windpump"     )) then
      keyvalues["power"]        = "generator"
      keyvalues["power_source"] = "wind"
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
-- highway=passing_place to turning_circle
-- Not really the same thing, but a "widening of the road" should be good 
-- enough.
-- ----------------------------------------------------------------------------
   if ( keyvalues["highway"]   == "passing_place" ) then
      keyvalues["highway"] = "turning_circle"
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
-- Also "self_catering" (used occasionally).
-- ----------------------------------------------------------------------------
   if (( keyvalues["tourism"]   == "bed_and_breakfast" ) or
       ( keyvalues["tourism"]   == "self_catering"     )) then
      keyvalues["tourism"] = "guest_house"
   end

-- ----------------------------------------------------------------------------
-- PNFS guideposts
-- ----------------------------------------------------------------------------
   if (( keyvalues["tourism"]    == "information"                          ) and
       (( keyvalues["operator"]  == "Peak & Northern Footpaths Society"   )  or
        ( keyvalues["operator"]  == "Peak and Northern Footpaths Society" ))) then
      keyvalues["tourism"] = "informationpnfs"
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
-- Things that are both peaks and memorials should render as the latter.
-- ----------------------------------------------------------------------------
   if (( keyvalues["natural"]   == "peak"     ) and
       ( keyvalues["historic"]  == "memorial" )) then
      keyvalues["natural"] = nil
   end

-- ----------------------------------------------------------------------------
-- Where military has been overtagged over natural=wood, remove military.
-- ----------------------------------------------------------------------------
   if (( keyvalues["natural"]   == "wood"        ) and
       ( keyvalues["military"]  == "danger_area" )) then
      keyvalues["military"] = nil
   end

-- ----------------------------------------------------------------------------
-- Nightclubs wouldn't ordinarily be rendered - render them as bar
-- ----------------------------------------------------------------------------
   if ( keyvalues["amenity"]   == "nightclub"   ) then
      keyvalues["amenity"] = "bar"
   end

-- ----------------------------------------------------------------------------
-- Render concert hall theatres as concert halls with the nightclub icon
-- ----------------------------------------------------------------------------
   if ((( keyvalues["amenity"] == "theatre"      )  and
        ( keyvalues["theatre"] == "concert_hall" )) or
       (  keyvalues["amenity"] == "music_venue"   )) then
      keyvalues["amenity"] = "concert_hall"
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
-- Render historic=wayside_cross as historic=memorial
-- It's near enough in meaning I think.
-- ----------------------------------------------------------------------------
   if ( keyvalues["historic"]   == "wayside_cross" ) then
      keyvalues["historic"] = "memorial"
   end

-- ----------------------------------------------------------------------------
-- Render shop=newsagent as shop=convenience
-- It's near enough in meaning I think.  Likewise kiosk (bit of a stretch,
-- but nearer than anything else)
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]   == "newsagent"   ) or
       ( keyvalues["shop"]   == "kiosk"       ) or
       ( keyvalues["shop"]   == "food"        ) or
       ( keyvalues["shop"]   == "frozen_food" )) then
      keyvalues["shop"] = "convenience"
   end

-- ----------------------------------------------------------------------------
-- Render shop=variety as shop=supermarket.  Most UK variety stores (Wilko,
-- Poundstretcher) do have a supermarket element, and most supermarkets have
-- a non-food variety element too.  "variety_store" is the most popular 
-- tagging but "variety" is also used.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]   == "variety"       ) or
       ( keyvalues["shop"]   == "variety_store" ) or
       ( keyvalues["shop"]   == "discount"      )) then
      keyvalues["shop"] = "supermarket"
   end

-- ----------------------------------------------------------------------------
-- "clothes" consolidation.  "baby_goods" is here because there will surely
-- be some clothes there!
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"] == "fashion"    ) or
       ( keyvalues["shop"] == "boutique"   ) or
       ( keyvalues["shop"] == "bridal"     ) or
       ( keyvalues["shop"] == "wedding"    ) or
       ( keyvalues["shop"] == "shoes"      ) or
       ( keyvalues["shop"] == "shoe"       ) or
       ( keyvalues["shop"] == "baby_goods" ) or
       ( keyvalues["shop"] == "baby"       )) then
      keyvalues["shop"] = "clothes"
   end

-- ----------------------------------------------------------------------------
-- "electrical" consolidation
-- Looking at the tagging of shop=electronics, there's a fair crossover with 
-- electrical.  "security" is less of a fit here.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]  == "electronics"             ) or
       ( keyvalues["shop"]  == "appliance"               ) or
       ( keyvalues["shop"]  == "appliances"              ) or
       ( keyvalues["shop"]  == "vacuum_cleaner"          ) or
       ( keyvalues["shop"]  == "domestic_appliances"     ) or
       ( keyvalues["shop"]  == "white_goods"             ) or
       ( keyvalues["trade"] == "electrical"              ) or
       ( keyvalues["name"]  == "City Electrical Factors" )) then
      keyvalues["shop"] = "electrical"
   end

-- ----------------------------------------------------------------------------
-- "funeral" consolidation.  All of these spellings currently in use in the UK
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "funeral"             ) or
       ( keyvalues["office"]  == "funeral_director"    ) or
       ( keyvalues["office"]  == "funeral_directors"   ) or
       ( keyvalues["amenity"] == "funeral"             ) or
       ( keyvalues["amenity"] == "funeral_director"    ) or
       ( keyvalues["amenity"] == "funeral_directors"   ) or
       ( keyvalues["amenity"] == "undertaker"          )) then
      keyvalues["shop"] = "funeral_directors"
   end

-- ----------------------------------------------------------------------------
-- "jewellery" consolidation.  "jewelry" is most popular in the database, 
-- but both are used.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"] == "jewelry" ) or
       ( keyvalues["shop"] == "watch"   ) or
       ( keyvalues["shop"] == "watches" )) then
      keyvalues["shop"] = "jewellery"
   end

-- ----------------------------------------------------------------------------
-- "antiques" consolidation.  "antiques" is most popular in the database, 
-- but both are used.
-- ----------------------------------------------------------------------------
   if ( keyvalues["shop"] == "antique" ) then
      keyvalues["shop"] = "antiques"
   end

-- ----------------------------------------------------------------------------
-- "department_store" consolidation.  "department_store" is chosen for 
-- catalogue due to the range of items for sale rather than the physical 
-- similarity.
-- ----------------------------------------------------------------------------
   if ( keyvalues["shop"] == "catalogue" ) then
      keyvalues["shop"] = "department_store"
   end

-- ----------------------------------------------------------------------------
-- office=estate_agent.  There's now an icon for "shop", so use that.
-- Also letting_agent
-- ----------------------------------------------------------------------------
   if (( keyvalues["office"]  == "estate_agent"      ) or
       ( keyvalues["office"]  == "estate_agents"     ) or
       ( keyvalues["amenity"] == "estate_agent"      ) or
       ( keyvalues["shop"]    == "letting_agent"     ) or
       ( keyvalues["office"]  == "letting_agent"     ) or
       ( keyvalues["shop"]    == "estate_agency"     ) or
       ( keyvalues["office"]  == "property_services" )) then
      keyvalues["shop"] = "estate_agent"
   end

-- ----------------------------------------------------------------------------
-- plant_nursery to garden_centre
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if ( keyvalues["landuse"] == "plant_nursery" ) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["shop"]    = "garden_centre"
   end


-- ----------------------------------------------------------------------------
-- "cafe" and "fast_food" consolidation.  
-- ----------------------------------------------------------------------------
   if ( keyvalues["shop"] == "cafe"       ) then
      keyvalues["amenity"] = "cafe"
   end

   if (( keyvalues["shop"] == "sandwiches" ) or
       ( keyvalues["shop"] == "sandwich"   )) then
      keyvalues["amenity"] = "cafe"
      keyvalues["cuisine"] = "sandwich"
   end

   if ( keyvalues["shop"] == "fish_and_chips" ) then
      keyvalues["amenity"] = "fast_food"
      keyvalues["cuisine"] = "fish_and_chips"
   end

   if (( keyvalues["shop"] == "fast_food" ) or
       ( keyvalues["shop"] == "take_away" )) then
      keyvalues["amenity"] = "fast_food"
   end

-- ----------------------------------------------------------------------------
-- Render shop=hardware stores etc. as shop=doityourself
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]  == "hardware"           ) or
       ( keyvalues["shop"]  == "tool_hire"          ) or
       ( keyvalues["shop"]  == "builders_merchant"  ) or
       ( keyvalues["shop"]  == "plumbers_merchant"  ) or
       ( keyvalues["shop"]  == "building_supplies"  ) or
       ( keyvalues["shop"]  == "plant_hire"         ) or
       ( keyvalues["shop"]  == "signs"              ) or
       ( keyvalues["craft"] == "signmaker"          ) or
       ( keyvalues["shop"]  == "building_materials" )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["shop"]    = "doityourself"
   end

-- ----------------------------------------------------------------------------
-- Consolidate "lenders of last resort" as pawnbroker
-- "money_transfer" and down from there is perhaps a bit of a stretch; 
-- as there is a distinctive pawnbroker icon, so generic is used for those.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"] == "money"              ) or
       ( keyvalues["shop"] == "money_lender"       ) or
       ( keyvalues["shop"] == "cash"               )) then
      keyvalues["shop"] = "pawnbroker"
   end

   if (( keyvalues["shop"]    == "money_transfer"     ) or
       ( keyvalues["shop"]    == "finance"            ) or
       ( keyvalues["office"]  == "finance"            ) or
       ( keyvalues["shop"]    == "financial_services" ) or
       ( keyvalues["office"]  == "financial_services" ) or
       ( keyvalues["office"]  == "financial_advisor"  ) or
       ( keyvalues["amenity"] == "financial_advice"   ) or
       ( keyvalues["amenity"] == "bureau_de_change"   )) then
      keyvalues["shop"] = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- hairdresser;beauty
-- ----------------------------------------------------------------------------
   if ( keyvalues["shop"] == "hairdresser;beauty" ) then
      keyvalues["shop"] = "hairdresser"
   end

-- ----------------------------------------------------------------------------
-- Currently handle beauty salons etc. as just generic.  Also "chemist"
-- Mostly these have names that describe the business, so less need for a
-- specific icon.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]   == "beauty"            ) or
       ( keyvalues["shop"]   == "beauty_salon"      ) or
       ( keyvalues["shop"]   == "salon"             ) or
       ( keyvalues["shop"]   == "nails"             ) or
       ( keyvalues["shop"]   == "chemist"           ) or
       ( keyvalues["shop"]   == "beauty_products"   ) or
       ( keyvalues["shop"]   == "perfume"           ) or
       ( keyvalues["shop"]   == "perfumery"         ) or
       ( keyvalues["shop"]   == "cosmetics"         ) or
       ( keyvalues["shop"]   == "tanning"           ) or
       ( keyvalues["shop"]   == "tanning_salon"     ) or
       ( keyvalues["shop"]   == "health_and_beauty" ) or
       ( keyvalues["shop"]   == "beautician"        )) then
      keyvalues["shop"] = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- "Non-electrical" electronics (i.e. ones for which the "electrical" icon
-- is inappropriate).
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]  == "security"         ) or
       ( keyvalues["shop"]   == "computer"        ) or
       ( keyvalues["shop"]   == "computer_repair" )) then
      keyvalues["shop"] = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- Betting Shops etc.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "bookmaker"           ) or
       ( keyvalues["shop"]    == "bookmakers"          ) or
       ( keyvalues["shop"]    == "betting"             ) or
       ( keyvalues["amenity"] == "betting"             ) or
       ( keyvalues["shop"]    == "gambling"            ) or
       ( keyvalues["amenity"] == "gambling"            ) or
       ( keyvalues["shop"]    == "amusements"          ) or
       ( keyvalues["amenity"] == "amusements"          ) or
       ( keyvalues["amenity"] == "amusement"           ) or
       ( keyvalues["leisure"] == "adult_gaming_centre" ) or
       ( keyvalues["amenity"] == "casino"              ) or
       ( keyvalues["amenity"] == "bingo"               )) then
      keyvalues["shop"] = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- mobile_phone shops as displayed just generic.
-- Again, the name usually describes the business
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]   == "mobile_phone" ) or
       ( keyvalues["shop"]   == "phone"        )) then
      keyvalues["shop"] = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- gift and other tat shops are rendered generically
-- Difficult to do an icon for and often the name describes the business.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]   == "gift"        ) or
       ( keyvalues["shop"]   == "souvenir"    ) or
       ( keyvalues["shop"]   == "leather"     ) or
       ( keyvalues["shop"]   == "luxury"      ) or
       ( keyvalues["shop"]   == "sunglasses"  ) or
       ( keyvalues["shop"]   == "tourist"     ) or
       ( keyvalues["shop"]   == "bag"         ) or
       ( keyvalues["shop"]   == "accessories" )) then
      keyvalues["shop"] = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- Various photo, camera, copy and print shops
-- Difficult to do an icon for.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "copyshop"           ) or
       ( keyvalues["shop"]    == "camera"             ) or
       ( keyvalues["shop"]    == "photo"              ) or
       ( keyvalues["shop"]    == "photo_studio"       ) or
       ( keyvalues["shop"]    == "photography"        ) or
       ( keyvalues["shop"]    == "photographic"       ) or
       ( keyvalues["shop"]    == "printing"           ) or
       ( keyvalues["shop"]    == "printer"            ) or
       ( keyvalues["shop"]    == "print"              ) or
       ( keyvalues["shop"]    == "printers"           ) or
       ( keyvalues["craft"]   == "printer"            ) or
       ( keyvalues["shop"]    == "printer_cartridges" ) or
       ( keyvalues["shop"]    == "printer_ink"        ) or
       ( keyvalues["amenity"] == "printer"            ) or
       ( keyvalues["office"]  == "printer"            )) then
      keyvalues["shop"] = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- Various single food item and other food shops
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "cake"          ) or
       ( keyvalues["shop"]    == "fish"          ) or
       ( keyvalues["shop"]    == "farm"          ) or
       ( keyvalues["shop"]    == "seafood"       ) or
       ( keyvalues["shop"]    == "beverages"     ) or
       ( keyvalues["shop"]    == "ice_cream"     ) or
       ( keyvalues["amenity"] == "ice_cream"     ) or
       ( keyvalues["shop"]    == "coffee"        ) or
       ( keyvalues["shop"]    == "tea"           ) or
       ( keyvalues["shop"]    == "chocolate"     ) or
       ( keyvalues["shop"]    == "cheese"        ) or
       ( keyvalues["shop"]    == "deli"          ) or
       ( keyvalues["shop"]    == "delicatessen"  ) or
       ( keyvalues["shop"]    == "patissery"     ) or
       ( keyvalues["shop"]    == "fishmonger"    ) or
       ( keyvalues["shop"]    == "grocery"       ) or
       ( keyvalues["shop"]    == "grocer"        ) or
       ( keyvalues["shop"]    == "confectionery" ) or
       ( keyvalues["shop"]    == "sweets"        ) or
       ( keyvalues["shop"]    == "sweet"         ) or
       ( keyvalues["shop"]    == "alcohol"       ) or
       ( keyvalues["shop"]    == "off_licence"   ) or
       ( keyvalues["shop"]    == "wine"          )) then
      keyvalues["shop"] = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- Various "homeware" shops.  Some of these, e.g. chandlery, are a bit of a 
-- stretch.
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]   == "floor"               ) or
       ( keyvalues["shop"]   == "flooring"            ) or
       ( keyvalues["shop"]   == "floors"              ) or
       ( keyvalues["shop"]   == "floor_covering"      ) or
       ( keyvalues["shop"]   == "homeware"            ) or
       ( keyvalues["shop"]   == "home"                ) or
       ( keyvalues["shop"]   == "furniture"           ) or
       ( keyvalues["shop"]   == "luggage"             ) or
       ( keyvalues["shop"]   == "interior_decoration" ) or
       ( keyvalues["shop"]   == "interior_design"     ) or
       ( keyvalues["shop"]   == "carpet"              ) or
       ( keyvalues["shop"]   == "carpets"             ) or
       ( keyvalues["shop"]   == "kitchen"             ) or
       ( keyvalues["shop"]   == "kitchen;bathroom"    ) or
       ( keyvalues["shop"]   == "kitchens"            ) or
       ( keyvalues["shop"]   == "houseware"           ) or
       ( keyvalues["shop"]   == "bathroom_furnishing" ) or
       ( keyvalues["shop"]   == "household"           ) or
       ( keyvalues["shop"]   == "bathroom"            ) or
       ( keyvalues["shop"]   == "glaziery"            ) or
       ( keyvalues["shop"]   == "tiles"               ) or
       ( keyvalues["shop"]   == "tile"                ) or
       ( keyvalues["shop"]   == "paint"               ) or
       ( keyvalues["shop"]   == "lighting"            ) or
       ( keyvalues["shop"]   == "windows"             ) or
       ( keyvalues["shop"]   == "window"              ) or
       ( keyvalues["craft"]  == "window_construction" ) or
       ( keyvalues["shop"]   == "gates"               ) or
       ( keyvalues["shop"]   == "fireplace"           ) or
       ( keyvalues["shop"]   == "fireplaces"          ) or
       ( keyvalues["shop"]   == "furnace"             ) or
       ( keyvalues["shop"]   == "plumbing"            ) or
       ( keyvalues["craft"]  == "plumber"             ) or
       ( keyvalues["craft"]  == "bakery"              ) or
       ( keyvalues["craft"]  == "carpenter"           ) or
       ( keyvalues["craft"]  == "decorator"           ) or
       ( keyvalues["shop"]   == "blinds"              ) or
       ( keyvalues["shop"]   == "window_blind"        ) or
       ( keyvalues["shop"]   == "bed"                 ) or
       ( keyvalues["shop"]   == "beds"                ) or
       ( keyvalues["shop"]   == "frame"               ) or
       ( keyvalues["shop"]   == "curtain"             ) or
       ( keyvalues["shop"]   == "furnishings"         ) or
       ( keyvalues["shop"]   == "furnishing"          ) or
       ( keyvalues["shop"]   == "glass"               ) or
       ( keyvalues["shop"]   == "garage"              ) or
       ( keyvalues["shop"]   == "bathrooms"           ) or
       ( keyvalues["shop"]   == "fitted_furniture"    ) or
       ( keyvalues["shop"]   == "kitchenware"         ) or
       ( keyvalues["shop"]   == "upholstery"          ) or
       ( keyvalues["shop"]   == "chandler"            ) or
       ( keyvalues["shop"]   == "chandlery"           ) or
       ( keyvalues["craft"]  == "boatbuilder"         ) or
       ( keyvalues["shop"]   == "saddlery"            )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["shop"] = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- fabric and wool etc.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]   == "fabric"               ) or
       ( keyvalues["shop"]   == "haberdashery"         ) or
       ( keyvalues["shop"]   == "sewing"               ) or
       ( keyvalues["shop"]   == "knitting"             ) or
       ( keyvalues["shop"]   == "wool"                 ) or
       ( keyvalues["shop"]   == "clothing_alterations" )) then
      keyvalues["shop"] = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- health_food etc., and also "non-medical medical".
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]   == "health_food"             ) or
       ( keyvalues["shop"]   == "healthfood"              ) or
       ( keyvalues["shop"]   == "health"                  ) or
       ( keyvalues["shop"]   == "organic"                 ) or
       ( keyvalues["shop"]   == "supplements"             ) or
       ( keyvalues["shop"]   == "alternative_medicine"    ) or
       ( keyvalues["name"]   == "Holland and Barrett"     ) or
       ( keyvalues["shop"]   == "massage"                 ) or
       ( keyvalues["shop"]   == "herbalist"               )) then
      keyvalues["shop"] = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- travel agents
-- the name is usually characteristic
-- ----------------------------------------------------------------------------
   if (( keyvalues["office"] == "travel_agent"  ) or
       ( keyvalues["shop"]   == "travel_agent"  ) or
       ( keyvalues["shop"]   == "travel_agency" )) then
      keyvalues["shop"] = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- books and stationery
-- the name is usually characteristic
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]   == "stationery"      ) or
       ( keyvalues["shop"]   == "books"           ) or
       ( keyvalues["shop"]   == "office_supplies" )) then
      keyvalues["shop"] = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- sports
-- the name is usually characteristic
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]   == "sports"       ) or
       ( keyvalues["shop"]   == "golf"         ) or
       ( keyvalues["shop"]   == "scuba_diving" ) or
       ( keyvalues["shop"]   == "fishing"      ) or
       ( keyvalues["shop"]   == "angling"      )) then
      keyvalues["shop"] = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- toys and games etc.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]   == "toys"           ) or
       ( keyvalues["shop"]   == "model"          ) or
       ( keyvalues["shop"]   == "games"          ) or
       ( keyvalues["shop"]   == "game"           ) or
       ( keyvalues["shop"]   == "computer_games" ) or
       ( keyvalues["shop"]   == "video_games"    ) or
       ( keyvalues["shop"]   == "hobby"          ) or
       ( keyvalues["shop"]   == "craft"          ) or
       ( keyvalues["shop"]   == "crafts"         ) or
       ( keyvalues["shop"]   == "art_supplies"   ) or
       ( keyvalues["shop"]   == "pottery"        ) or
       ( keyvalues["craft"]  == "pottery"        ) or
       ( keyvalues["shop"]   == "party"          ) or
       ( keyvalues["shop"]   == "fancy_dress"    )) then
      keyvalues["shop"] = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- pets and pet services
-- Normally the names are punningly characteristic (e.g. "Bark-in-Style" 
-- dog grooming).
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "pet"                     ) or
       ( keyvalues["shop"]    == "pets"                    ) or
       ( keyvalues["shop"]    == "pet_supplies"            ) or
       ( keyvalues["shop"]    == "pet_grooming"            ) or
       ( keyvalues["shop"]    == "dog_grooming"            ) or
       ( keyvalues["shop"]    == "pet;corn"                ) or
       ( keyvalues["shop"]    == "animal_feed"             ) or
       ( keyvalues["amenity"] == "dog_grooming"            ) or
       ( keyvalues["amenity"] == "veterinary"              ) or
       ( keyvalues["amenity"] == "animal_boarding"         ) or
       ( keyvalues["amenity"] == "cattery"                 ) or
       ( keyvalues["amenity"] == "kennels"                 ) or
       ( keyvalues["amenity"] == "animal_shelter"          )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["shop"] = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- Nonspecific car shops.
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "car_parts"               ) or
       ( keyvalues["shop"]    == "car_accessories"         ) or
       ( keyvalues["amenity"] == "car_rental"              ) or
       ( keyvalues["shop"]    == "motorcycle"              ) or
       ( keyvalues["shop"]    == "caravan"                 ) or
       ( keyvalues["amenity"] == "car_wash"                ) or
       ( keyvalues["shop"]    == "truck"                   ) or
       ( keyvalues["shop"]    == "truck_repair"            ) or
       ( keyvalues["amenity"] == "driving_school"          )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["shop"]    = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- Other shops that don't have a specific icon are handled here. including
-- variations (for example "shoes" is more popular by far than "shoe").
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
       ( keyvalues["shop"]    == "card;gift"               ) or
       ( keyvalues["craft"]   == "cobbler"                 ) or
       ( keyvalues["shop"]    == "cobbler"                 ) or
       ( keyvalues["shop"]    == "shoe_repair"             ) or
       ( keyvalues["shop"]    == "shoe_repair;key_cutting" ) or
       ( keyvalues["shop"]    == "key_cutting"             ) or
       ( keyvalues["shop"]    == "laundry"                 ) or
       ( keyvalues["shop"]    == "dry_cleaning"            ) or
       ( keyvalues["shop"]    == "art"                     ) or
       ( keyvalues["shop"]    == "tattoo"                  ) or
       ( keyvalues["shop"]    == "music"                   ) or
       ( keyvalues["shop"]    == "records"                 ) or
       ( keyvalues["shop"]    == "tyres"                   ) or
       ( keyvalues["shop"]    == "musical_instrument"      ) or
       ( keyvalues["shop"]    == "hifi"                    ) or
       ( keyvalues["shop"]    == "tailor"                  ) or
       ( keyvalues["shop"]    == "video"                   ) or
       ( keyvalues["shop"]    == "erotic"                  ) or
       ( keyvalues["shop"]    == "locksmith"               ) or
       ( keyvalues["shop"]    == "e-cigarette"             ) or
       ( keyvalues["shop"]    == "tobacco"                 ) or
       ( keyvalues["shop"]    == "ticket"                  ) or
       ( keyvalues["shop"]    == "insurance"               ) or
       ( keyvalues["shop"]    == "gallery"                 ) or
       ( keyvalues["amenity"] == "gallery"                 ) or
       ( keyvalues["amenity"] == "art_gallery"             ) or
       ( keyvalues["shop"]    == "plumber"                 ) or
       ( keyvalues["shop"]    == "builder"                 ) or
       ( keyvalues["shop"]    == "trophy"                  ) or
       ( keyvalues["shop"]    == "communication"           ) or
       ( keyvalues["shop"]    == "communications"          ) or
       ( keyvalues["amenity"] == "internet_cafe"           ) or
       ( keyvalues["shop"]    == "recycling"               ) or
       ( keyvalues["shop"]    == "gun"                     ) or
       ( keyvalues["craft"]   == "gunsmith"                ) or
       ( keyvalues["shop"]    == "auction"                 ) or
       ( keyvalues["shop"]    == "auction_house"           ) or
       ( keyvalues["auction"] == "auction_house"           ) or
       ( keyvalues["office"]  == "auctioneer"              ) or
       ( keyvalues["shop"]    == "religion"                ) or
       ( keyvalues["shop"]    == "gas"                     ) or
       ( keyvalues["shop"]    == "taxi"                    ) or
       ( keyvalues["office"]  == "taxi"                    ) or
       ( keyvalues["amenity"] == "minicab_office"          ) or
       ( keyvalues["amenity"] == "training"                ) or
       ( keyvalues["shop"]    == "mobility"                ) or
       ( keyvalues["amenity"] == "stripclub"               ) or
       ( keyvalues["amenity"] == "brothel"                 ) or
       ( keyvalues["amenity"] == "sauna"                   ) or
       ( keyvalues["amenity"] == "self_storage"            ) or
       ( keyvalues["amenity"] == "courier"                 )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["shop"] = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- Shops that we don't know the type of.  Things such as "hire" are here 
-- because we don't know "hire of what".
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "yes"            ) or
       ( keyvalues["shop"]    == "other"          ) or
       ( keyvalues["shop"]    == "hire"           ) or
       ( keyvalues["shop"]    == "second_hand"    ) or
       ( keyvalues["shop"]    == "general"        ) or
       ( keyvalues["shop"]    == "unknown"        ) or
       ( keyvalues["shop"]    == "trade"          ) or
       ( keyvalues["shop"]    == "cash_and_carry" ) or
       ( keyvalues["shop"]    == "fixme"          ) or
       ( keyvalues["shop"]    == "wholesale"      )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["shop"]    = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- Various comma and semicolon healthcare
-- ----------------------------------------------------------------------------
   if ( keyvalues["amenity"] == "doctors; pharmacy" ) then
      keyvalues["amenity"] = "doctors"
   end

   if ( keyvalues["amenity"] == "doctors;social_facility" ) then
      keyvalues["amenity"] = "doctors"
   end

   if ( keyvalues["amenity"] == "pharmacy, doctors, dentist" ) then
      keyvalues["amenity"] = "pharmacy"
   end

-- ----------------------------------------------------------------------------
-- opticians - render as "nonspecific health".
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]       == "optician"          ) or
       ( keyvalues["shop"]       == "opticians"         ) or
       ( keyvalues["amenity"]     == "optician"          ) or
       ( keyvalues["shop"]        == "optometrist"       ) or
       ( keyvalues["amenity"]     == "optometrist"       ) or
       ( keyvalues["shop"]        == "hearing_aids"      ) or
       ( keyvalues["shop"]        == "medical_supply"    ) or
       ( keyvalues["shop"]        == "chiropodist"       ) or
       ( keyvalues["amenity"]     == "chiropodist"       ) or
       ( keyvalues["amenity"]     == "chiropractor"      ) or
       ( keyvalues["amenity"]     == "osteopath"         ) or
       ( keyvalues["amenity"]     == "physiotherapist"   ) or
       ( keyvalues["healthcare"]  == "podiatrist"        ) or
       ( keyvalues["amenity"]     == "healthcare"        ) or
       ( keyvalues["amenity"]     == "clinic"            ) or
       ( keyvalues["amenity"]     == "social_facility"   ) or
       ( keyvalues["amenity"]     == "nursing_home"      ) or
       ( keyvalues["amenity"]     == "care_home"         ) or
       ( keyvalues["amenity"]     == "retirement_home"   ) or
       ( keyvalues["amenity"]     == "residential_home"  ) or
       ( keyvalues["building"]    == "residential_home"  ) or
       ( keyvalues["residential"] == "residential_home"  ) or
       ( keyvalues["amenity"]     == "sheltered_housing" ) or
       ( keyvalues["amenity"]     == "childcare"         ) or
       ( keyvalues["amenity"]     == "childrens_centre"  ) or
       ( keyvalues["amenity"]     == "preschool"         ) or
       ( keyvalues["amenity"]     == "nursery"           ) or
       ( keyvalues["amenity"]     == "health_centre"     ) or
       ( keyvalues["amenity"]     == "medical_centre"    ) or
       ( keyvalues["amenity"]     == "hospice"           ) or
       ( keyvalues["amenity"]     == "daycare"           )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["shop"]    = "healthnonspecific"
   end

-- ----------------------------------------------------------------------------
-- Offices that we don't know the type of.  
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( keyvalues["office"]     == "company" ) or
       ( keyvalues["shop"]       == "office"  ) or
       ( keyvalues["amenity"]    == "office"  ) or
       ( keyvalues["office"]     == "yes"     ) or
       ( keyvalues["commercial"] == "office"  )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["office"]  = "nonspecific"
   end

-- ----------------------------------------------------------------------------
-- Similarly, various government offices.  Job Centres first.
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "job_centre"              ) or
       ( keyvalues["amenity"] == "jobcentre"               ) or
       ( keyvalues["name"]    == "Jobcentre Plus"          ) or
       ( keyvalues["name"]    == "JobCentre Plus"          ) or
       ( keyvalues["name"]    == "Job Centre Plus"         ) or
       ( keyvalues["office"]   == "government"              ) or
       ( keyvalues["office"]   == "administrative"          ) or
       ( keyvalues["office"]   == "register"                ) or
       ( keyvalues["amenity"]  == "register_office"         ) or
       ( keyvalues["office"]   == "drainage_board"          ) or
       ( keyvalues["office"]   == "council"                 ) or
       ( keyvalues["amenity"]  == "courthouse"              ) or
       ( keyvalues["amenity"]  == "townhall"                ) or
       ( keyvalues["amenity"]  == "village_hall"            ) or
       ( keyvalues["building"] == "village_hall"            ) or
       ( keyvalues["amenity"]  == "crematorium"             ) or
       ( keyvalues["amenity"]  == "hall"                    ) or
       ( keyvalues["amenity"]  == "ambulance_station"       ) or
       ( keyvalues["amenity"]  == "lifeboat_station"        ) or
       ( keyvalues["amenity"]  == "coast_guard"             ) or
       ( keyvalues["amenity"]  == "monastery"               ) or
       ( keyvalues["amenity"]  == "convent"                 )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["office"]  = "nonspecific"
   end

-- ----------------------------------------------------------------------------
-- Non-government (commercial) offices that you might visit for a service.
-- "communication" below seems to be used for marketing / commercial PR.
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( keyvalues["office"]  == "it"                      ) or
       ( keyvalues["office"]  == "computer"                ) or
       ( keyvalues["office"]  == "lawyer"                  ) or
       ( keyvalues["shop"]    == "lawyer"                  ) or
       ( keyvalues["amenity"] == "lawyer"                  ) or
       ( keyvalues["office"]  == "solicitor"               ) or
       ( keyvalues["shop"]    == "solicitor"               ) or
       ( keyvalues["amenity"] == "solicitor"               ) or
       ( keyvalues["office"]  == "solicitors"              ) or
       ( keyvalues["shop"]    == "solicitors"              ) or
       ( keyvalues["amenity"] == "solicitors"              ) or
       ( keyvalues["office"]  == "accountant"              ) or
       ( keyvalues["shop"]    == "accountant"              ) or
       ( keyvalues["office"]  == "accountants"             ) or
       ( keyvalues["amenity"] == "accountants"             ) or
       ( keyvalues["office"]  == "employment_agency"       ) or
       ( keyvalues["shop"]    == "employment_agency"       ) or
       ( keyvalues["office"]  == "recruitment_agency"      ) or
       ( keyvalues["office"]  == "recruitment"             ) or
       ( keyvalues["shop"]    == "recruitment"             ) or
       ( keyvalues["office"]  == "insurance"               ) or
       ( keyvalues["office"]  == "architect"               ) or
       ( keyvalues["office"]  == "telecommunication"       ) or
       ( keyvalues["office"]  == "financial"               ) or
       ( keyvalues["office"]  == "newspaper"               ) or
       ( keyvalues["office"]  == "delivery"                ) or
       ( keyvalues["amenity"] == "delivery_office"         ) or
       ( keyvalues["amenity"] == "sorting_office"          ) or
       ( keyvalues["office"]  == "therapist"               ) or
       ( keyvalues["office"]  == "surveyor"                ) or
       ( keyvalues["office"]  == "marketing"               ) or
       ( keyvalues["office"]  == "graphic_design"          ) or
       ( keyvalues["office"]  == "builder"                 ) or
       ( keyvalues["office"]  == "training"                ) or
       ( keyvalues["office"]  == "web_design"              ) or
       ( keyvalues["office"]  == "design"                  ) or
       ( keyvalues["shop"]    == "design"                  ) or
       ( keyvalues["office"]  == "communication"           ) or
       ( keyvalues["office"]  == "security"                ) or
       ( keyvalues["office"]  == "engineering"             ) or
       ( keyvalues["craft"]   == "hvac"                    ) or
       ( keyvalues["office"]  == "hvac"                    ) or
       ( keyvalues["office"]  == "laundry"                 ) or
       ( keyvalues["amenity"] == "telephone_exchange"      ) or
       ( keyvalues["amenity"] == "coworking_space"         )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["office"] = "nonspecific"
   end

-- ----------------------------------------------------------------------------
-- Other nonspecific offices.  
-- ----------------------------------------------------------------------------
   if (( keyvalues["office"]   == "it"                      ) or
       ( keyvalues["office"]   == "ngo"                     ) or
       ( keyvalues["office"]   == "educational_institution" ) or
       ( keyvalues["office"]   == "university"              ) or
       ( keyvalues["office"]   == "charity"                 ) or
       ( keyvalues["amenity"]  == "education_centre"        ) or
       ( keyvalues["amenity"]  == "college"                 ) or
       ( keyvalues["man_made"] == "observatory"            ) or
       ( keyvalues["office"]   == "political_party"         ) or
       ( keyvalues["office"]   == "quango"                  ) or
       ( keyvalues["office"]   == "association"             ) or
       ( keyvalues["amenity"]  == "advice"                  ) or
       ( keyvalues["amenity"]  == "advice_service"          ) or
       ( keyvalues["amenity"]  == "citizens_advice_bureau"  )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["office"]  = "nonspecific"
   end

-- ----------------------------------------------------------------------------
-- Similarly, nonspecific leisure facilities.
-- Non-private swimming pools:
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "swimming_pool" ) and
       ( keyvalues["access"]  ~= "private"       )) then
      keyvalues["leisure"] = "nonspecific"
   end

-- ----------------------------------------------------------------------------
-- Other nonspecific leisure
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"]  == "events_venue"      ) or
       ( keyvalues["amenity"]  == "conference_centre" ) or
       ( keyvalues["amenity"]  == "exhibition_centre" ) or
       ( keyvalues["amenity"]  == "function_room"     ) or
       ( keyvalues["amenity"]  == "arts_centre"       ) or
       ( keyvalues["amenity"]  == "community_hall"    ) or
       ( keyvalues["amenity"]  == "church_hall"       ) or
       ( keyvalues["amenity"]  == "community_centre"  ) or
       ( keyvalues["building"] == "community_centre"  ) or
       ( keyvalues["amenity"]  == "dojo"              ) or
       ( keyvalues["leisure"]  == "indoor_play"       ) or
       ( keyvalues["amenity"]  == "youth_club"        ) or
       ( keyvalues["amenity"]  == "youth_centre"      ) or
       ( keyvalues["amenity"]  == "social_club"       ) or
       ( keyvalues["amenity"]  == "working_mens_club" ) or
       ( keyvalues["amenity"]  == "social_centre"     ) or
       ( keyvalues["amenity"]  == "club"              ) or
       ( keyvalues["amenity"]  == "gym"               ) or
       ( keyvalues["leisure"]  == "fitness_centre"    ) or
       ( keyvalues["amenity"]  == "scout_hut"         ) or
       ( keyvalues["amenity"]  == "scout_hall"        ) or
       ( keyvalues["amenity"]  == "scouts"            ) or
       ( keyvalues["amenity"]  == "clubhouse"         ) or
       ( keyvalues["building"] == "clubhouse"         ) or
       ( keyvalues["amenity"]  == "club_house"        ) or
       ( keyvalues["building"] == "club_house"        )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["leisure"] = "nonspecific"
   end

-- ----------------------------------------------------------------------------
-- Remove road names that are not signed on the ground.
-- "unsigned" tends to apply to road names.
-- ----------------------------------------------------------------------------
   if (( keyvalues["name:signed"] == "no"   ) or
       ( keyvalues["unsigned"]    == "yes"  ) or
       ( keyvalues["unsigned"]    == "true" )) then
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
-- group.  Note that this includes "tower" temporarily, and "campanile" is in 
-- here as a sort of tower (only 2 mapped in UK currently).
-- ----------------------------------------------------------------------------
   if (( keyvalues["man_made"] == "phone_mast"           ) or
       ( keyvalues["man_made"] == "radio_mast"           ) or
       ( keyvalues["man_made"] == "communications_mast"  ) or
       ( keyvalues["man_made"] == "communication_mast"   ) or
       ( keyvalues["man_made"] == "tower"                ) or
       ( keyvalues["man_made"] == "campanile"            ) or
       ( keyvalues["man_made"] == "communications_tower" ) or
       ( keyvalues["man_made"] == "transmitter"          ) or
       ( keyvalues["man_made"] == "antenna"              )) then
      keyvalues["man_made"] = "mast"
   end

   if ( keyvalues["highway"] == "bus_stop" ) then
      if (( keyvalues["name"]             ~= nil ) and
          ( keyvalues["naptan:Indicator"] ~= nil )) then
         keyvalues["name"] = keyvalues["name"] .. " " .. keyvalues["naptan:Indicator"]
      end
   end

-- ----------------------------------------------------------------------------
-- Drop some highway areas.
-- "track" and "cycleway" etc. wherever I have seen them are garbage.
-- "footway" (pedestrian areas) and "service" (e.g. petrol station forecourts)
-- tend to be OK.  Other options tend not to occur.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["highway"] == "track"          )  or
        ( keyvalues["highway"] == "cycleway"       )  or
        ( keyvalues["highway"] == "residential"    )  or
        ( keyvalues["highway"] == "unclassified"   )  or
        ( keyvalues["highway"] == "tertiary"       )) and
       (  keyvalues["area"]    == "yes"             )) then
      keyvalues["highway"] = "nil"
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
