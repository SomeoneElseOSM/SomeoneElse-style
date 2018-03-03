polygon_keys = { 'building', 'landcover', 'landuse', 'amenity', 'harbour', 'historic', 'leisure', 
      'man_made', 'military', 'natural', 'office', 'place', 'power',
      'public_transport', 'seamark:type', 'shop', 'sport', 'tourism', 'waterway',
      'wetland', 'water', 'aeroway' }

generic_keys = {'access','addr:housename','addr:housenumber','addr:interpolation','admin_level','advertising','aerialway','aeroway','amenity','area','barrier',
   'bicycle','brand','bridge','bridleway','booth','boundary','building','capital','construction','covered','culvert','cutting','denomination','designation','disused','ele',
   'embankment','emergency','foot','generation:source','golf','harbour','highway','historic','horse','hours','intermittent','junction','landcover','landuse','layer','leisure','lock',
   'man_made','military','motor_car','name','natural','ncn_milepost','office','oneway','operator','place','poi','population','power','power_source','public_transport','seamark:type',
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
      { 'highway', 'road', 2, 0 }, 
      { 'highway', 'unclassified', 3, 0 }, { 'highway', 'unclassified_sidewalk', 3, 0 }, { 'highway', 'unclassified_verge', 3, 0 }, { 'highway', 'unclassified_ford', 3, 0 },
      { 'highway', 'residential', 3, 0 }, 
      { 'highway', 'tertiary_link', 4, 0}, { 'highway', 'tertiary', 4, 0}, { 'highway', 'tertiary_sidewalk', 4, 0}, { 'highway', 'tertiary_verge', 4, 0},
      { 'highway', 'secondary_link', 6, 1}, { 'highway', 'secondary', 6, 1}, { 'highway', 'secondary_sidewalk', 6, 1}, { 'highway', 'secondary_verge', 6, 1},
      { 'highway', 'primary_link', 7, 1}, { 'highway', 'primary', 7, 1},{ 'highway', 'primary_sidewalk', 7, 1},{ 'highway', 'primary_verge', 7, 1},
      { 'highway', 'trunk_link', 8, 1}, { 'highway', 'trunk', 8, 1},
      { 'highway', 'motorway_link', 9, 1}, { 'highway', 'motorway', 9, 1},
      { 'highway', 'ldpnwn', 91, 1}, { 'highway', 'ldpncn', 91, 1},{ 'highway', 'ldpnhn', 91, 1},
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
-- Invalid layer values
-- ----------------------------------------------------------------------------
   if ( keyvalues["layer"] == "-0.5" ) then
      keyvalues["layer"] = "-1"
   end

   if ( keyvalues["layer"] == "covered" ) then
      keyvalues["layer"] = "0"
   end

   if ((( keyvalues["bridge"]     == "yes" )   or
        ( keyvalues["embankment"] == "yes" ))  and
       (( keyvalues["layer"]      == "-3"  )   or
        ( keyvalues["layer"]      == "-2"  )   or
        ( keyvalues["layer"]      == "-1"  ))) then
      keyvalues["layer"] = "0"
   end

   if (( keyvalues["layer"] == "01"       ) or
       ( keyvalues["layer"] == "+1"       ) or
       ( keyvalues["layer"] == "yes"      ) or
       ( keyvalues["layer"] == "0.5"      ) or
       ( keyvalues["layer"] == "0-1"      ) or
       ( keyvalues["layer"] == "0;1"      ) or
       ( keyvalues["layer"] == "0;2"      ) or
       ( keyvalues["layer"] == "0;1;2"    ) or
       ( keyvalues["layer"] == "pipeline" )) then
      keyvalues["layer"] = "1"
   end
   
   if ( keyvalues["layer"] == "2;4" ) then
      keyvalues["layer"] = "2"
   end

   if (( keyvalues["layer"] == "6"  )  or
       ( keyvalues["layer"] == "7"  )  or
       ( keyvalues["layer"] == "8"  )  or
       ( keyvalues["layer"] == "9"  )  or
       ( keyvalues["layer"] == "10" )  or
       ( keyvalues["layer"] == "15" )  or
       ( keyvalues["layer"] == "16" )) then
      keyvalues["layer"] = "5"
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
   if ((  keyvalues["highway"] == "corridor"   ) and
       (( keyvalues["level"]   == nil         )  or
        ( keyvalues["level"]   == "0"         )) and
       (( keyvalues["layer"]   == nil         )  or
        ( keyvalues["layer"]   == "0"         ))) then
      keyvalues["highway"] = "footway"
   end

-- ----------------------------------------------------------------------------
-- Note that "steps" and "footwaysteps" are unchanged by the 
-- pathwide / path choice below:
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"] == "footway"   ) or 
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

   if (( keyvalues["highway"] == "track"      ) or
       ( keyvalues["highway"] == "gallop"     ) or
       ( keyvalues["highway"] == "unsurfaced" )) then
      keyvalues["highway"] = "pathwide"
   end

   if ((  keyvalues["designation"]      == nil         ) and
       (( keyvalues["trail_visibility"] == "no"       )  or
        ( keyvalues["trail_visibility"] == "horrible" )  or
        ( keyvalues["trail_visibility"] == "bad"      ))) then
      keyvalues["highway"] = nil
   end

-- ----------------------------------------------------------------------------
-- Supress some "demanding" paths.  UK examples with sac_scale:
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

   if ((  keyvalues["highway"] == "unclassified"  ) and
       (( keyvalues["surface"] == "unpaved"      )  or 
        ( keyvalues["surface"] == "gravel"       ))) then
      keyvalues["highway"] = "track_graded"
      keyvalues["tracktype"] = "grade1"
   end

   if (( keyvalues["designation"] == "unclassified_county_road"  ) or
       ( keyvalues["designation"] == "unclassified_country_road" ) or
       ( keyvalues["designation"] == "unclassified_highway"      ) or
       ( keyvalues["designation"] == "unmade_road"               )) then
      if (( keyvalues["highway"] == "footway"   ) or 
          ( keyvalues["highway"] == "steps"     ) or 
          ( keyvalues["highway"] == "bridleway" ) or 
	  ( keyvalues["highway"] == "cycleway"  ) or
	  ( keyvalues["highway"] == "path"      )) then
	  keyvalues["tracktype"] = "grade5"
      else
          keyvalues["highway"] = "track_graded"
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
          keyvalues["highway"] = "track_graded"
	  keyvalues["tracktype"] = "grade3"
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
   if (( keyvalues["designation"] == "restricted_byway"    ) or
       ( keyvalues["designation"] == "public_right_of_way" )) then
      if (( keyvalues["highway"] == "footway"   ) or 
          ( keyvalues["highway"] == "steps"     ) or 
          ( keyvalues["highway"] == "bridleway" ) or 
	  ( keyvalues["highway"] == "cycleway"  ) or
	  ( keyvalues["highway"] == "path"      )) then
	  keyvalues["tracktype"] = "grade5"
      else
          keyvalues["highway"] = "track_graded"
	  keyvalues["tracktype"] = "grade4"
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
   if (keyvalues["designation"] == "public_bridleway") then
      if (( keyvalues["highway"] == "footway"   ) or 
          ( keyvalues["highway"] == "bridleway" ) or 
	  ( keyvalues["highway"] == "cycleway"  ) or
	  ( keyvalues["highway"] == "path"      )) then
	  keyvalues["highway"] = "bridleway"
      else
         if (( keyvalues["highway"] == "steps" ) or
             ( keyvalues["highway"] == "bridlewaysteps" )) then
            keyvalues["highway"] = "bridlewaysteps"
         else
            keyvalues["highway"] = "bridlewaywide"
         end
      end
   end

-- ----------------------------------------------------------------------------
-- When a value is changed we get called again.  That's why there's a check
-- for "footwaysteps" below "before the only place that it can be set".
-- ----------------------------------------------------------------------------
   if (keyvalues["designation"] == "public_footpath") then
      if (( keyvalues["highway"] == "footway"   ) or 
          ( keyvalues["highway"] == "bridleway" ) or 
          ( keyvalues["highway"] == "cycleway"  ) or
          ( keyvalues["highway"] == "path"      )) then
         keyvalues["highway"] = "footway"
      else
         if (( keyvalues["highway"] == "steps" ) or
             ( keyvalues["highway"] == "footwaysteps" )) then
            keyvalues["highway"] = "footwaysteps"
         else
            keyvalues["highway"] = "footwaywide"
         end
      end
   end

-- ----------------------------------------------------------------------------
-- Treat access=permit as access-private
-- Also access=no for the benefit of the "foot access" check below.
-- ----------------------------------------------------------------------------
   if (( keyvalues["access"]  == "permit"       ) or
       ( keyvalues["access"]  == "agricultural" ) or
       ( keyvalues["access"]  == "forestry"     ) or
       ( keyvalues["access"]  == "delivery"     ) or
       ( keyvalues["access"]  == "no"           )) then
      keyvalues["access"] = "private"
   end

   if ( keyvalues["access"]  == "customers" ) then
      keyvalues["access"] = "destination"
   end

   if ((    keyvalues["access"]      == "private"                      ) and
       ((   keyvalues["designation"] == "public_footpath"             )  or
        (   keyvalues["designation"] == "public_bridleway"            )  or
        (   keyvalues["designation"] == "restricted_byway"            )  or
        (   keyvalues["designation"] == "byway_open_to_all_traffic"   )  or
        (   keyvalues["designation"] == "unclassified_county_road"    )  or
        (   keyvalues["designation"] == "unclassified_country_road"   )  or
        (   keyvalues["designation"] == "unclassified_highway"        )  or
        ((( keyvalues["highway"]     == "path"                      )    or
          ( keyvalues["highway"]     == "pathwide"                  ))   and
         (( keyvalues["foot"]        == "permissive"                )    or
          ( keyvalues["foot"]        == "yes"                       ))))) then
      keyvalues["access"] = nil
   end

-- ----------------------------------------------------------------------------
-- Render Access land the same as nature reserve / national park currently is
-- ----------------------------------------------------------------------------
   if (keyvalues["designation"] == "access_land") then
      keyvalues["leisure"] = "nature_reserve"
   end

-- ----------------------------------------------------------------------------
-- Use unclassified_sidewalk to indicate sidewalk
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"] == "unclassified"      ) or 
       ( keyvalues["highway"] == "unclassified_link" ) or
       ( keyvalues["highway"] == "residential"       ) or
       ( keyvalues["highway"] == "residential_link"  )) then
      if (( keyvalues["sidewalk"] == "both"           ) or 
          ( keyvalues["sidewalk"] == "left"           ) or 
          ( keyvalues["sidewalk"] == "mapped"         ) or 
          ( keyvalues["sidewalk"] == "separate"       ) or 
          ( keyvalues["sidewalk"] == "right"          ) or 
          ( keyvalues["sidewalk"] == "shared"         ) or 
          ( keyvalues["sidewalk"] == "yes"            ) or
          ( keyvalues["footway"]  == "both"           ) or 
          ( keyvalues["footway"]  == "left"           ) or 
          ( keyvalues["footway"]  == "mapped"         ) or 
          ( keyvalues["footway"]  == "separate"       ) or 
          ( keyvalues["footway"]  == "right"          ) or 
          ( keyvalues["footway"]  == "shared"         ) or 
          ( keyvalues["footway"]  == "yes"            ) or
          ( keyvalues["cycleway"] == "track"          ) or
          ( keyvalues["cycleway"] == "opposite_track" ) or
          ( keyvalues["cycleway"] == "yes"            ) or
          ( keyvalues["cycleway"] == "separate"       ) or
          ( keyvalues["cycleway"] == "sidewalk"       ) or
          ( keyvalues["cycleway"] == "sidepath"       )) then
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
          ( keyvalues["verge"] == "mapped"         ) or 
          ( keyvalues["verge"] == "separate"       ) or 
          ( keyvalues["verge"] == "right"          ) or 
          ( keyvalues["verge"] == "shared"         ) or 
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
      if (( keyvalues["sidewalk"] == "both"           ) or 
          ( keyvalues["sidewalk"] == "left"           ) or 
          ( keyvalues["sidewalk"] == "mapped"         ) or 
          ( keyvalues["sidewalk"] == "separate"       ) or 
          ( keyvalues["sidewalk"] == "right"          ) or 
          ( keyvalues["sidewalk"] == "shared"         ) or 
          ( keyvalues["sidewalk"] == "yes"            ) or
          ( keyvalues["footway"]  == "both"           ) or 
          ( keyvalues["footway"]  == "left"           ) or 
          ( keyvalues["footway"]  == "mapped"         ) or 
          ( keyvalues["footway"]  == "separate"       ) or 
          ( keyvalues["footway"]  == "right"          ) or 
          ( keyvalues["footway"]  == "shared"         ) or 
          ( keyvalues["footway"]  == "yes"            ) or
          ( keyvalues["cycleway"] == "track"          ) or
          ( keyvalues["cycleway"] == "opposite_track" ) or
          ( keyvalues["cycleway"] == "yes"            ) or
          ( keyvalues["cycleway"] == "separate"       ) or
          ( keyvalues["cycleway"] == "sidewalk"       ) or
          ( keyvalues["cycleway"] == "sidepath"       )) then
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
          ( keyvalues["verge"] == "mapped"         ) or 
          ( keyvalues["verge"] == "separate"       ) or 
          ( keyvalues["verge"] == "right"          ) or 
          ( keyvalues["verge"] == "shared"         ) or 
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
      if (( keyvalues["sidewalk"] == "both"           ) or 
          ( keyvalues["sidewalk"] == "left"           ) or 
          ( keyvalues["sidewalk"] == "mapped"         ) or 
          ( keyvalues["sidewalk"] == "separate"       ) or 
          ( keyvalues["sidewalk"] == "right"          ) or 
          ( keyvalues["sidewalk"] == "shared"         ) or 
          ( keyvalues["sidewalk"] == "yes"            ) or
          ( keyvalues["footway"]  == "both"           ) or 
          ( keyvalues["footway"]  == "left"           ) or 
          ( keyvalues["footway"]  == "mapped"         ) or 
          ( keyvalues["footway"]  == "separate"       ) or 
          ( keyvalues["footway"]  == "right"          ) or 
          ( keyvalues["footway"]  == "shared"         ) or 
          ( keyvalues["footway"]  == "yes"            ) or
          ( keyvalues["cycleway"] == "track"          ) or
          ( keyvalues["cycleway"] == "opposite_track" ) or
          ( keyvalues["cycleway"] == "yes"            ) or
          ( keyvalues["cycleway"] == "separate"       ) or
          ( keyvalues["cycleway"] == "sidewalk"       ) or
          ( keyvalues["cycleway"] == "sidepath"       )) then
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
          ( keyvalues["verge"] == "mapped"         ) or 
          ( keyvalues["verge"] == "separate"       ) or 
          ( keyvalues["verge"] == "right"          ) or 
          ( keyvalues["verge"] == "shared"         ) or 
          ( keyvalues["verge"] == "yes"            )) then
          keyvalues["highway"] = "secondary_verge"
      end
   end

-- ----------------------------------------------------------------------------
-- Use primary_sidewalk to indicate sidewalk
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"] == "primary"      ) or 
       ( keyvalues["highway"] == "primary_link" )) then
      if (( keyvalues["sidewalk"] == "both"           ) or 
          ( keyvalues["sidewalk"] == "left"           ) or 
          ( keyvalues["sidewalk"] == "mapped"         ) or 
          ( keyvalues["sidewalk"] == "separate"       ) or 
          ( keyvalues["sidewalk"] == "right"          ) or 
          ( keyvalues["sidewalk"] == "shared"         ) or 
          ( keyvalues["sidewalk"] == "yes"            ) or
          ( keyvalues["footway"]  == "both"           ) or 
          ( keyvalues["footway"]  == "left"           ) or 
          ( keyvalues["footway"]  == "mapped"         ) or 
          ( keyvalues["footway"]  == "separate"       ) or 
          ( keyvalues["footway"]  == "right"          ) or 
          ( keyvalues["footway"]  == "shared"         ) or 
          ( keyvalues["footway"]  == "yes"            ) or
          ( keyvalues["cycleway"] == "track"          ) or
          ( keyvalues["cycleway"] == "opposite_track" ) or
          ( keyvalues["cycleway"] == "yes"            ) or
          ( keyvalues["cycleway"] == "separate"       ) or
          ( keyvalues["cycleway"] == "sidewalk"       ) or
          ( keyvalues["cycleway"] == "sidepath"       )) then
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
          ( keyvalues["verge"] == "mapped"         ) or 
          ( keyvalues["verge"] == "separate"       ) or 
          ( keyvalues["verge"] == "right"          ) or 
          ( keyvalues["verge"] == "shared"         ) or 
          ( keyvalues["verge"] == "yes"            )) then
          keyvalues["highway"] = "primary_verge"
      end
   end

-- ----------------------------------------------------------------------------
-- Render narrow tertiary roads as unclassified
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"] == "tertiary_sidewalk"   )  and
       (( keyvalues["width"]  == "2"         )   or
        ( keyvalues["width"]  == "3"         ))) then
      keyvalues["highway"] = "unclassified_sidewalk"
   end

   if (( keyvalues["highway"] == "tertiary_verge"   )  and
       (( keyvalues["width"]  == "2"         )   or
        ( keyvalues["width"]  == "3"         ))) then
      keyvalues["highway"] = "unclassified_verge"
   end

   if (( keyvalues["highway"] == "tertiary"   )  and
       (( keyvalues["width"]  == "2"         )   or
        ( keyvalues["width"]  == "3"         ))) then
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
   if (( keyvalues["bridge"] == "viaduct"     ) or
       ( keyvalues["bridge"] == "aqueduct"    ) or
       ( keyvalues["bridge"] == "movable"     ) or
       ( keyvalues["bridge"] == "boadwalk"    ) or
       ( keyvalues["bridge"] == "suspension"  ) or
       ( keyvalues["bridge"] == "swing"       ) or
       ( keyvalues["bridge"] == "lift"        ) or
       ( keyvalues["bridge"] == "cantilever"  ) or
       ( keyvalues["bridge"] == "footbridge"  ) or
       ( keyvalues["bridge"] == "undefined"   ) or
       ( keyvalues["bridge"] == "covered"     ) or
       ( keyvalues["bridge"] == "duck_boards" ) or
       ( keyvalues["bridge"] == "duckboards"  ) or
       ( keyvalues["bridge"] == "duckboard"   ) or
       ( keyvalues["bridge"] == "footplank"   ) or
       ( keyvalues["bridge"] == "clapper"     ) or
       ( keyvalues["bridge"] == "cantilever"  ) or
       ( keyvalues["bridge"] == "gangway"     ) or
       ( keyvalues["bridge"] == "foot"        ) or
       ( keyvalues["bridge"] == "lock_gate"   ) or
       ( keyvalues["bridge"] == "sleepers"    ) or
       ( keyvalues["bridge"] == "plank"       ) or
       ( keyvalues["bridge"] == "rope"        ) or
       ( keyvalues["bridge"] == "pontoon"     ) or
       ( keyvalues["bridge"] == "footpath"    ) or
       ( keyvalues["bridge"] == "wire"        ) or
       ( keyvalues["bridge"] == "pier"        ) or
       ( keyvalues["bridge"] == "chain"       ) or
       ( keyvalues["bridge"] == "trestle"     )) then
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
-- Bridge structures - display as building=roof.
-- Also farmyard "bunker silos" and canopies.
-- ----------------------------------------------------------------------------
   if (( keyvalues["man_made"]      == "bridge"      ) or
       ( keyvalues["man_made"]      == "bunker_silo" ) or
       ( keyvalues["building"]      == "canopy"      ) or
       ( keyvalues["building:type"] == "canopy"      )) then
      keyvalues["building"]      = "roof"
      keyvalues["building:type"] = nil
   end

-- ----------------------------------------------------------------------------
-- Tunnel values - render as "yes" if appropriate.
-- ----------------------------------------------------------------------------
   if (( keyvalues["tunnel"] == "culvert"             ) or
       ( keyvalues["tunnel"] == "covered"             ) or
       ( keyvalues["tunnel"] == "avalanche_protector" ) or
       ( keyvalues["tunnel"] == "passage"             ) or
       ( keyvalues["tunnel"] == "1"                   ) or
       ( keyvalues["tunnel"] == "cave"                )) then
      keyvalues["tunnel"] = "yes"
   end

-- ----------------------------------------------------------------------------
-- Remove name from footway=sidewalk (we expect it to be rendered via the
-- road that this is a sidewalk for).
-- ----------------------------------------------------------------------------
   if (( keyvalues["footway"] == "sidewalk" ) and
       ( keyvalues["name"]    ~= nil        )) then
      keyvalues["name"] = nil
   end

-- ----------------------------------------------------------------------------
-- Pretend add landuse=industrial to some industrial sub-types to force 
-- name rendering.  Similarly, some commercial and leisure.
-- man_made=works drops the man_made tag to avoid duplicate labelling.
-- "parking=depot" is a special case - drop the parking tag there too.
-- ----------------------------------------------------------------------------
   if (( keyvalues["man_made"]   == "wastewater_plant"       ) or 
       ( keyvalues["man_made"]   == "reservoir_covered"      ) or 
       ( keyvalues["man_made"]   == "petroleum_well"         ) or 
       ( keyvalues["industrial"] == "warehouse"              ) or
       ( keyvalues["building"]   == "warehouse"              ) or
       ( keyvalues["industrial"] == "brewery"                ) or 
       ( keyvalues["industrial"] == "distillery"             ) or 
       ( keyvalues["craft"]      == "brewery"                ) or
       ( keyvalues["craft"]      == "distillery"             ) or
       ( keyvalues["craft"]      == "bakery"                 ) or
       ( keyvalues["industrial"] == "factory"                ) or 
       ( keyvalues["industrial"] == "yes"                    ) or 
       ( keyvalues["industrial"] == "depot"                  ) or 
       ( keyvalues["building"]   == "depot"                  ) or 
       ( keyvalues["landuse"]    == "depot"                  ) or
       ( keyvalues["amenity"]    == "depot"                  ) or
       ( keyvalues["amenity"]    == "bus_depot"              ) or
       ( keyvalues["amenity"]    == "fuel_depot"             ) or
       ( keyvalues["amenity"]    == "scrap_yard"             ) or 
       ( keyvalues["amenity"]    == "scrapyard"              ) or 
       ( keyvalues["industrial"] == "scrap_yard"             ) or 
       ( keyvalues["industrial"] == "scrapyard"              ) or 
       ( keyvalues["industrial"] == "yard"                   ) or 
       ( keyvalues["industrial"] == "engineering"            ) or
       ( keyvalues["industrial"] == "machine_shop"           ) or
       ( keyvalues["industrial"] == "packaging"              ) or
       ( keyvalues["industrial"] == "haulage"                ) or
       ( keyvalues["building"]   == "industrial"             ) or
       ( keyvalues["amenity"]    == "recycling"              ) or
       ( keyvalues["power"]      == "plant"                  ) or
       ( keyvalues["building"]   == "works"                  ) or
       ( keyvalues["building"]   == "manufacture"            ) or
       ( keyvalues["man_made"]   == "gas_station"            ) or
       ( keyvalues["man_made"]   == "gas_works"              ) or
       ( keyvalues["man_made"]   == "water_treatment"        ) or
       ( keyvalues["man_made"]   == "pumping_station"        ) or
       ( keyvalues["man_made"]   == "water_works"            ) or
       ( keyvalues["amenity"]    == "waste_transfer_station" )) then
      keyvalues["landuse"] = "industrial"
   end

   if ( keyvalues["man_made"]   == "works" ) then
      keyvalues["man_made"] = nil
      keyvalues["landuse"] = "industrial"
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
-- Handle place=quarter
-- ----------------------------------------------------------------------------
   if ( keyvalues["place"] == "quarter" ) then
      keyvalues["place"] = "neighbourhood"
   end

-- ----------------------------------------------------------------------------
-- Handle various sorts of milestones.
-- ----------------------------------------------------------------------------
   if (( keyvalues["historic"] == "milestone" )  or
       ( keyvalues["historic"] == "milepost"  )  or
       ( keyvalues["waterway"] == "milestone" )  or
       ( keyvalues["railway"]  == "milestone" )) then
      keyvalues["highway"] = "milestone"
   end

-- ----------------------------------------------------------------------------
-- Boundary stones
-- ----------------------------------------------------------------------------
   if (( keyvalues["historic"] == "boundary_stone"  )  or
       ( keyvalues["historic"] == "boundary_marker" )  or
       ( keyvalues["historic"] == "boundary_post"   )  or
       ( keyvalues["marker"]   == "boundary_stone"  )  or
       ( keyvalues["historic"] == "standing_stone"  )  or
       ( keyvalues["boundary"] == "marker"          )) then
      keyvalues["man_made"] = "boundary_stone"
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
        ( keyvalues["booth"]           ~= "ST6"            ))  or
       (  keyvalues["booth"]           == "K2"              )  or
       (  keyvalues["booth"]           == "K4_Post_Office"  )  or
       (  keyvalues["booth"]           == "K6"              )  or
       (  keyvalues["booth"]           == "k6"              )  or
       (  keyvalues["booth"]           == "K8"              )  or
       (  keyvalues["telephone_kiosk"] == "K4"              )  or
       (  keyvalues["telephone_kiosk"] == "K6"              )  or
       (  keyvalues["man_made"]        == "telephone_kiosk" )  or
       (  keyvalues["building"]        == "telephone_kiosk" )  or
       (  keyvalues["building"]        == "telephone_box"   )  or
       (  keyvalues["historic"]        == "telephone"       )) then
      if (( keyvalues["amenity"] == "telephone" )  or
          ( keyvalues["amenity"] == "phone"     )) then
         keyvalues["amenity"] = "boothtelephone"
      else
         if ( keyvalues["emergency"] == "defibrillator" ) then
             keyvalues["amenity"]   = "boothdefibrillator"
             keyvalues["disused:amenity"] = nil
             keyvalues["emergency"] = nil
         else
            if (( keyvalues["amenity"] == "public_bookcase" )  or
                ( keyvalues["amenity"] == "book_exchange"   )  or
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
                        if (( keyvalues["disused:amenity"]    == "telephone"        )  or
                            ( keyvalues["abandoned:amenity"]  == "telephone"        )  or
                            ( keyvalues["demolished:amenity"] == "telephone"        )  or
                            ( keyvalues["razed:amenity"]      == "telephone"        )  or
                            ( keyvalues["old_amenity"]        == "telephone"        )  or
                            ( keyvalues["historic:amenity"]   == "telephone"        )  or
                            ( keyvalues["disused"]            == "telephone"        )  or
                            ( keyvalues["was:amenity"]        == "telephone"        )  or
                            ( keyvalues["old:amenity"]        == "telephone"        )  or
                            ( keyvalues["amenity"]            == "old_telephone"    )  or
                            ( keyvalues["amenity"]            == "former_telephone" )  or
                            ( keyvalues["amenity:old"]        == "telephone"        )  or
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
   
-- ----------------------------------------------------------------------------
-- Mappings to shop=car
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "car;car_repair"  )  or
       ( keyvalues["shop"]    == "car;bicycle"     )  or
       ( keyvalues["shop"]    == "cars"            )  or
       ( keyvalues["shop"]    == "vehicle"         )) then
      keyvalues["shop"] = "car"
   end

-- ----------------------------------------------------------------------------
-- Mappings to shop=bicycle
-- ----------------------------------------------------------------------------
   if ( keyvalues["shop"] == "bicycle_repair" ) then
      keyvalues["shop"] = "bicycle"
   end

-- ----------------------------------------------------------------------------
-- Map amenity=car_repair etc. to shop=car_repair
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "car_repair"         )  or
       ( keyvalues["craft"]   == "car_repair"         )  or
       ( keyvalues["shop"]    == "car_service"        )  or
       ( keyvalues["shop"]    == "car_inspection"     )  or
       ( keyvalues["shop"]    == "car_bodyshop"       )  or
       ( keyvalues["shop"]    == "vehicle_inspection" )  or
       ( keyvalues["shop"]    == "mechanic"           )  or
       ( keyvalues["shop"]    == "car_repair;car"     )  or
       ( keyvalues["shop"]    == "car_repair;tyres"   )  or
       ( keyvalues["shop"]    == "auto_repair"        )) then
      keyvalues["shop"] = "car_repair"
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
   if (( keyvalues["building"]     == "commercial"               ) or
       ( keyvalues["building"]     == "office"                   ) or
       ( keyvalues["man_made"]     == "telephone_exchange"       ) or
       ( keyvalues["amenity"]      == "telephone_exchange"       ) or
       ( keyvalues["building"]     == "telephone_exchange"       ) or
       ( keyvalues["utility"]      == "telephone_exchange"       ) or
       ( keyvalues["amenity"]      == "ferry_terminal"           ) or
       ( keyvalues["landuse"]      == "ferry_terminal"           ) or
       ( keyvalues["highway"]      == "services"                 ) or
       ( keyvalues["landuse"]      == "churchyard"               ) or
       ( keyvalues["landuse"]      == "religious"                ) or
       ( keyvalues["leisure"]      == "racetrack"                ) or
       ( keyvalues["club"]         == "sport"                    ) or
       ( keyvalues["office"]       == "courier"                  ) or
       ( keyvalues["office"]       == "advertising"              ) or
       ( keyvalues["amenity"]      == "post_depot"               ) or
       ( keyvalues["landuse"]      == "aquaculture"              ) or
       ( keyvalues["landuse"]      == "fish_farm"                ) or
       ( keyvalues["landuse"]      == "fishfarm"                 ) or
       ( keyvalues["seamark:type"] == "marine_farm" )) then
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
-- leisure=dog_park is used a few times.  Map to pitch to differentiate from
-- underlying park.
-- Also "court" often means "pitch" (tennis, basketball).
-- ----------------------------------------------------------------------------
   if (( keyvalues["leisure"] == "dog_park" ) or
       ( keyvalues["leisure"] == "court"    )) then
      keyvalues["leisure"] = "pitch"
   end

-- ----------------------------------------------------------------------------
-- Map leisure=wildlife_hide to bird_hide.  Many times it will be
-- ----------------------------------------------------------------------------
   if (keyvalues["leisure"] == "wildlife_hide") then
      keyvalues["leisure"] = "bird_hide"
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
-- Change landuse=greenhouse_horticulture to farmyard.
-- ----------------------------------------------------------------------------
   if (keyvalues["landuse"]   == "greenhouse_horticulture") then
      keyvalues["landuse"] = "farmyard"
   end

-- ----------------------------------------------------------------------------
-- Attempt to do something sensible with trees
--
-- There are a few 10s of landuse=wood and natural=forest; treat them the same
-- as other woodland.  If we have landuse=forest on its own without
-- leaf_type, then we don't change it - we'll handle that separately in the
-- rss file.
-- ----------------------------------------------------------------------------
  if ( keyvalues["landuse"] == "forestry" ) then
      keyvalues["landuse"] = "forest"
  end

  if ((( keyvalues["landuse"]   == "forest" )  and
       ( keyvalues["leaf_type"] ~= nil      )) or
      (  keyvalues["natural"]   == "forest"  ) or
      (  keyvalues["landuse"]   == "wood"    ) or
      (  keyvalues["landcover"] == "trees"   )) then
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
-- Treat landcover=grass as landuse=grass
-- ----------------------------------------------------------------------------
   if ( keyvalues["landcover"] == "grass" ) then
      keyvalues["landcover"] = nil
      keyvalues["landuse"] = "grass"
   end

-- ----------------------------------------------------------------------------
-- Don't show pubs if you can't actually get to them.
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "pub"     ) and
       ( keyvalues["access"]  == "private" )) then
      keyvalues["amenity"] = nil
   end

-- ----------------------------------------------------------------------------
-- Attempt to do something sensible with pubs
-- Pubs that serve real_ale get a nice IPA, ones that don't a yellowy lager,
-- closed pubs an "X".  Others get the default empty glass.
--
-- Pub flags:
-- Live or dead pub?  y or n
-- Real ale?          y n or d (for don't know)
-- Food 	      y or d (don't know)
-- Floor	      y or d (don't know)
-- ----------------------------------------------------------------------------
   if (( keyvalues["description:floor"] ~= nil                ) or
       ( keyvalues["floor:material"]    == "tiles"            ) or
       ( keyvalues["floor:material"]    == "stone"            ) or
       ( keyvalues["floor:material"]    == "lino"             ) or
       ( keyvalues["floor:material"]    == "slate"            ) or
       ( keyvalues["floor:material"]    == "brick"            ) or
       ( keyvalues["floor:material"]    == "concrete"         ) or
       ( keyvalues["floor:material"]    == "lino;tiles;stone" )) then
      keyvalues["noncarpeted"] = "yes"
   end

   if (( keyvalues["real_ale"] ~= nil     ) and
       ( keyvalues["real_ale"] ~= "maybe" ) and
       ( keyvalues["real_ale"] ~= "no"    )) then
      if (( keyvalues["food"] ~= nil  ) and
          ( keyvalues["food"] ~= "no" )) then
         if ( keyvalues["noncarpeted"] == "yes"  ) then
            if ( keyvalues["microbrewery"] == "yes"  ) then
               keyvalues["amenity"] = "pub_yyyyy"
            else
               keyvalues["amenity"] = "pub_yyyy"
	    end
         else
            if ( keyvalues["microbrewery"] == "yes"  ) then
               keyvalues["amenity"] = "pub_yyydy"
	    else
               keyvalues["amenity"] = "pub_yyyd"
	    end
         end
      else
         if ( keyvalues["noncarpeted"] == "yes"  ) then
            if ( keyvalues["microbrewery"] == "yes"  ) then
               keyvalues["amenity"] = "pub_yydyy"
	    else
               keyvalues["amenity"] = "pub_yydy"
	    end
         else
            if ( keyvalues["microbrewery"] == "yes"  ) then
               keyvalues["amenity"] = "pub_yyddy"
	    else
               keyvalues["amenity"] = "pub_yydd"
	    end
         end
      end
   end

   if (keyvalues["real_ale"] == "no") then
      if (( keyvalues["food"] ~= nil  ) and
          ( keyvalues["food"] ~= "no" )) then
         if ( keyvalues["noncarpeted"] == "yes"  ) then
            keyvalues["amenity"] = "pub_ynyy"
         else
            keyvalues["amenity"] = "pub_ynyd"
         end
      else
         if ( keyvalues["noncarpeted"] == "yes"  ) then
            keyvalues["amenity"] = "pub_yndy"
         else
            keyvalues["amenity"] = "pub_yndd"
         end
      end
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
      keyvalues["amenity"] = "pub_nddd"
   end

-- ----------------------------------------------------------------------------
-- The catch-all here is still "pub" (leaving the tag unchanged)
-- ----------------------------------------------------------------------------
   if ( keyvalues["amenity"] == "pub" ) then
      if (( keyvalues["food"] ~= nil  ) and
          ( keyvalues["food"] ~= "no" )) then
         if ( keyvalues["noncarpeted"] == "yes"  ) then
            if ( keyvalues["microbrewery"] == "yes"  ) then
               keyvalues["amenity"] = "pub_ydyyy"
	    else
               keyvalues["amenity"] = "pub_ydyy"
	    end
         else
            if ( keyvalues["microbrewery"] == "yes"  ) then
               keyvalues["amenity"] = "pub_ydydy"
	    else
               keyvalues["amenity"] = "pub_ydyd"
	    end
         end
      else
         if ( keyvalues["noncarpeted"] == "yes"  ) then
            if ( keyvalues["microbrewery"] == "yes"  ) then
               keyvalues["amenity"] = "pub_yddyy"
	    else
               keyvalues["amenity"] = "pub_yddy"
	    end
	 else
            if ( keyvalues["microbrewery"] == "yes"  ) then
               keyvalues["amenity"] = "pub_ydddy"
	    end
         end
      end
   end


-- ----------------------------------------------------------------------------
-- Render building societies as banks.  Also shop=bank.
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "building_society" ) or
       ( keyvalues["shop"]    == "bank"             )) then
      keyvalues["amenity"] = "bank"
   end


-- ----------------------------------------------------------------------------
-- ATMs - use operator if set (even if name is set).
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"]  == "atm" ) and
       ( keyvalues["operator"] ~= nil   )) then
      keyvalues["name"] = keyvalues["operator"]
      keyvalues["operator"] = nil
   end


-- ----------------------------------------------------------------------------
-- If no name use brand or operator on amenity=fuel.  If there is brand or
-- operator use that with name.
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "fuel"             ) or
       ( keyvalues["amenity"] == "charging_station" ) or
       ( keyvalues["tourism"] == "hotel"            )) then
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
         if ( keyvalues["brand"] ~= nil ) then
            keyvalues["name"] = keyvalues["name"] .. " (" .. keyvalues["brand"] .. ")"
            keyvalues["brand"] = nil
	 else
            if ( keyvalues["operator"] ~= nil ) then
               keyvalues["name"] = keyvalues["name"] .. " (" .. keyvalues["operator"] .. ")"
               keyvalues["operator"] = nil
            end
         end
      end
   end

-- ----------------------------------------------------------------------------
-- Left luggage
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "luggage_locker"  ) or
       ( keyvalues["amenity"] == "luggage_lockers" ) or
       ( keyvalues["shop"]    == "luggage_locker"  ) or
       ( keyvalues["shop"]    == "luggage_lockers" )) then
      keyvalues["amenity"] = "left_luggage"
      keyvalues["shop"]    = nil
   end


-- ----------------------------------------------------------------------------
-- Parcel lockers
-- Other vending machines have their own icon
-- ----------------------------------------------------------------------------
   if ((  keyvalues["amenity"] == "vending_machine"                ) and
       (( keyvalues["vending"] == "parcel_pickup;parcel_mail_in"  )  or
        ( keyvalues["vending"] == "parcel_mail_in;parcel_pickup"  )  or
        ( keyvalues["vending"] == "parcel_mail_in"                )  or
        ( keyvalues["vending"] == "parcel_pickup"                 ))) then
      keyvalues["amenity"]  = "parcel_locker"
      keyvalues["name"]     = keyvalues["operator"]
      keyvalues["operator"] = nil
   end


-- ----------------------------------------------------------------------------
-- Render amenity=layby as parking
-- ----------------------------------------------------------------------------
   if ( keyvalues["amenity"] == "layby" ) then
      keyvalues["amenity"] = "parking"
   end


-- ----------------------------------------------------------------------------
-- Render for-pay parking areas differently.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["amenity"] == "parking"  ) and
       (( keyvalues["fee"]     ~= nil       )  and
        ( keyvalues["fee"]     ~= "no"      )  and
        ( keyvalues["fee"]     ~= "No"      )  and
        ( keyvalues["fee"]     ~= "none"    )  and
        ( keyvalues["fee"]     ~= "None"    )  and
        ( keyvalues["fee"]     ~= "Free"    )  and
        ( keyvalues["fee"]     ~= "free"    )  and
        ( keyvalues["fee"]     ~= "0"       ))) then
      keyvalues["amenity"] = "parking_pay"
   end


-- ----------------------------------------------------------------------------
-- Render parking spaces as parking.  Most in the UK are not part of larger
-- parking areas, and most do not have an access tag, but many should have.
-- ----------------------------------------------------------------------------
   if ( keyvalues["amenity"] == "parking_space" ) then
      keyvalues["amenity"] = "parking"

      if ( keyvalues["access"] == nil  ) then
         keyvalues["access"] = "private"
      end
   end


-- ----------------------------------------------------------------------------
-- Render amenity=leisure_centre as leisure=sports_centre
-- ----------------------------------------------------------------------------
   if ( keyvalues["amenity"] == "leisure_centre" ) then
      keyvalues["leisure"] = "sports_centre"
   end

-- ----------------------------------------------------------------------------
-- Golf 
-- ----------------------------------------------------------------------------
   if (( keyvalues["golf"]    == "bunker" ) and
       ( keyvalues["natural"] == nil      )) then
      keyvalues["natural"] = "sand"
   end

   if ( keyvalues["golf"] == "tee" ) then
      keyvalues["leisure"] = "garden"
      keyvalues["name"] = keyvalues["ref"]
   end

   if ( keyvalues["golf"] == "green" ) then
      keyvalues["leisure"] = "garden"
      keyvalues["name"] = keyvalues["ref"]
   end

   if ( keyvalues["golf"] == "fairway" ) then
      keyvalues["leisure"] = "garden"
      keyvalues["name"] = keyvalues["ref"]
   end

   if ( keyvalues["golf"] == "pin" ) then
      keyvalues["leisure"] = "nonspecific"
      keyvalues["name"] = keyvalues["ref"]
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
      keyvalues["highway"] = "path"
   end

   if (( keyvalues["golf"]    == "practice" ) and
       ( keyvalues["leisure"] == nil        )) then
      keyvalues["leisure"] = "garden"
   end

-- ----------------------------------------------------------------------------
-- Beer gardens etc.
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "beer_garden" ) or
       ( keyvalues["landuse"] == "beer_garden" ) or
       ( keyvalues["leisure"] == "beer_garden" )) then
      keyvalues["leisure"] = "garden"
   end


-- ----------------------------------------------------------------------------
-- Handle razed railways and old inclined_planes as dismantled.
-- dismantled, abandoned are now handled separately to disused in roads.mss
-- ----------------------------------------------------------------------------
   if (( keyvalues["railway"]  == "razed"          ) or
       ( keyvalues["historic"] == "inclined_plane" )) then
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
-- Goods Conveyors - render as miniature railway.
-- ----------------------------------------------------------------------------
   if ( keyvalues["man_made"] == "goods_conveyor" ) then
      keyvalues["railway"] = "miniature"
   end

-- ----------------------------------------------------------------------------
-- Slipways - render as miniature railway
-- ----------------------------------------------------------------------------
   if ( keyvalues["leisure"] == "slipway" ) then
      keyvalues["railway"] = "miniature"
   end

-- ----------------------------------------------------------------------------
-- Sluice gates - send through as man_made, also display as building=roof.
-- Also waterfall (the dot or line is generic enough to work there too)
-- The change of waterway to weir ensires line features appear too.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["waterway"]     == "sluice_gate"   ) or
       (  keyvalues["waterway"]     == "sluice"        ) or
       (( keyvalues["waterway"]     == "flow_control" )  and
        ( keyvalues["flow_control"] == "sluice_gate"  )) or
       (  keyvalues["waterway"]     == "waterfall"     ) or
       (  keyvalues["waterway"]     == "weir"          )) then
      keyvalues["man_made"] = "sluice_gate"
      keyvalues["building"] = "roof"
      keyvalues["waterway"] = "weir"
   end

-- ----------------------------------------------------------------------------
-- Historic canal
-- A former canal can, like an abandoned railway, still be a major
-- physical feature.
-- ----------------------------------------------------------------------------
   if (( keyvalues["historic"]           == "canal"           ) or
       ( keyvalues["historic:waterway"]  == "canal"           ) or
       ( keyvalues["historic"]           == "leat"            ) or
       ( keyvalues["disused:waterway"]   == "canal"           ) or
       ( keyvalues["disused"]            == "canal"           ) or
       ( keyvalues["abandoned:waterway"] == "canal"           ) or
       ( keyvalues["waterway"]           == "disused_canal"   ) or
       ( keyvalues["waterway"]           == "historic_canal"  ) or
       ( keyvalues["waterway"]           == "abandoned_canal" ) or
       ( keyvalues["waterway"]           == "former_canal"    ) or
       ( keyvalues["waterway:historic"]  == "canal"           ) or
       ( keyvalues["waterway:abandoned"] == "canal"           ) or
       ( keyvalues["abandoned"]          == "waterway=canal"  )) then
      keyvalues["waterway"] = "derelict_canal"
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
-- ----------------------------------------------------------------------------
   if (( keyvalues["waterway"] == "leat"      )  or
       ( keyvalues["waterway"] == "spillway"  )  or
       ( keyvalues["waterway"] == "aqueduct"  )  or
       ( keyvalues["waterway"] == "fish_pass" )) then
      keyvalues["waterway"] = "drain"
   end

-- ----------------------------------------------------------------------------
-- Display "waterway=mill_pond" as dock.
-- ----------------------------------------------------------------------------
   if ( keyvalues["waterway"] == "mill_pond" ) then
      keyvalues["waterway"] = "dock"
   end

-- ----------------------------------------------------------------------------
-- Display intermittent waterways as "wadi"
-- ----------------------------------------------------------------------------
   if ((( keyvalues["waterway"]     == "river"  )  or
        ( keyvalues["waterway"]     == "stream" )) and
       (  keyvalues["intermittent"] == "yes"     )) then
      keyvalues["waterway"] = "wadi"
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
       ( keyvalues["man_made"]   == "waste_treatment"  ) or
       ( keyvalues["man_made"]   == "lighthouse"       )) then
      keyvalues["building"] = "yes"
   end

-- ----------------------------------------------------------------------------
-- Map man_made=monument to historic=monument (handled below) if no better tag
-- exists.
-- ----------------------------------------------------------------------------
   if (( keyvalues["man_made"] == "monument" ) and
       ( keyvalues["tourism"]  == nil        )) then
      keyvalues["historic"] = "monument"
      keyvalues["man_made"] = nil
   end
   
-- ----------------------------------------------------------------------------
-- Add a building tag to historic items that are likely buildings so that
-- buildings.mss can process it.  Some shouldn't assume buildings (e.g. "fort"
-- below).  Some use "roof" (which I use for "nearly a building" elsewhere).
-- It's sent through as "nonspecific".
-- "stone" has a building tag added because some are mapped as closed ways.
-- ----------------------------------------------------------------------------
   if (( keyvalues["historic"] == "monument"           ) or
       ( keyvalues["historic"] == "building"           ) or
       ( keyvalues["historic"] == "heritage_building"  ) or
       ( keyvalues["historic"] == "protected_building" ) or
       ( keyvalues["historic"] == "watermill"          ) or
       ( keyvalues["historic"] == "windmill"           ) or
       ( keyvalues["historic"] == "church"             ) or
       ( keyvalues["historic"] == "wayside_chapel"     ) or
       ( keyvalues["historic"] == "chapel"             ) or
       ( keyvalues["historic"] == "gate_house"         ) or
       ( keyvalues["historic"] == "aircraft"           ) or
       ( keyvalues["historic"] == "locomotive"         ) or
       ( keyvalues["historic"] == "ship"               ) or
       ( keyvalues["historic"] == "tank"               ) or
       ( keyvalues["historic"] == "house"              ) or
       ( keyvalues["historic"] == "mine_shaft"         ) or
       ( keyvalues["historic"] == "lime_kiln"          ) or
       ( keyvalues["historic"] == "lime_kilns"         ) or
       ( keyvalues["historic"] == "limekiln"           ) or
       ( keyvalues["historic"] == "kiln"               ) or
       ( keyvalues["historic"] == "trough"             ) or
       ( keyvalues["historic"] == "stone"              )) then
      keyvalues["building"] = "yes"
      keyvalues["historic"] = "nonspecific"
   end

   if ( keyvalues["historic"] == "wreck" ) then
      keyvalues["building"] = "roof"
      keyvalues["historic"] = "nonspecific"
   end
   
   if (( keyvalues["historic"] == "ruins"             ) or
       ( keyvalues["historic"] == "fort"              ) or
       ( keyvalues["historic"] == "ringfort"          ) or
       ( keyvalues["historic"] == "earthworks"        ) or
       ( keyvalues["historic"] == "motte"             ) or
       ( keyvalues["historic"] == "barrow"            ) or
       ( keyvalues["historic"] == "tumulus"           ) or
       ( keyvalues["historic"] == "tomb"              ) or
       ( keyvalues["historic"] == "fortification"     ) or
       ( keyvalues["historic"] == "camp"              ) or
       ( keyvalues["historic"] == "menhir"            ) or
       ( keyvalues["historic"] == "stone_circle"      ) or
       ( keyvalues["historic"] == "castle"            ) or
       ( keyvalues["historic"] == "mound"             ) or
       ( keyvalues["historic"] == "manor"             ) or
       ( keyvalues["historic"] == "mansion"           ) or
       ( keyvalues["historic"] == "hall"              ) or
       ( keyvalues["historic"] == "stately_home"      ) or
       ( keyvalues["historic"] == "tower_house"       ) or
       ( keyvalues["historic"] == "almshouse"         ) or
       ( keyvalues["historic"] == "police_box"        ) or
       ( keyvalues["historic"] == "bakery"            ) or
       ( keyvalues["historic"] == "battlefield"       ) or
       ( keyvalues["historic"] == "monastery"         ) or
       ( keyvalues["historic"] == "monastic_grange"   ) or
       ( keyvalues["historic"] == "abbey"             ) or
       ( keyvalues["historic"] == "priory"            ) or
       ( keyvalues["historic"] == "palace"            ) or
       ( keyvalues["historic"] == "tower"             ) or
       ( keyvalues["historic"] == "dovecote"          ) or
       ( keyvalues["historic"] == "toll_house"        ) or
       ( keyvalues["historic"] == "pinfold"           ) or
       ( keyvalues["historic"] == "prison"            ) or
       ( keyvalues["historic"] == "theatre"           ) or
       ( keyvalues["historic"] == "shelter"           ) or
       ( keyvalues["historic"] == "grave"             ) or
       ( keyvalues["historic"] == "grave_yard"        ) or
       ( keyvalues["historic"] == "statue"            ) or
       ( keyvalues["historic"] == "cross"             ) or
       ( keyvalues["historic"] == "market_cross"      ) or
       ( keyvalues["historic"] == "folly"             ) or
       ( keyvalues["historic"] == "drinking_fountain" ) or
       ( keyvalues["historic"] == "mine_adit"         ) or
       ( keyvalues["historic"] == "mine"              ) or
       ( keyvalues["historic"] == "sawmill"           ) or
       ( keyvalues["historic"] == "well"              ) or
       ( keyvalues["historic"] == "cannon"            )) then
      keyvalues["historic"] = "nonspecific"

      if ( keyvalues["landuse"] == nil ) then
         keyvalues["landuse"] = "historic"
         keyvalues["tourism"] = nil
      end
   end

   if (( keyvalues["historic"] == "archaeological_site" )  and
       ( keyvalues["landuse"]  == nil                   )) then
      keyvalues["landuse"] = "historic"
      keyvalues["tourism"] = nil
   end

-- ----------------------------------------------------------------------------
-- historic=icon shouldn't supersede amenity or tourism tags.
-- ----------------------------------------------------------------------------
   if (( keyvalues["historic"] == "icon" ) and
       ( keyvalues["amenity"]  == nil    ) and
       ( keyvalues["tourism"]  == nil    )) then
      keyvalues["historic"] = "nonspecific"
   end

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

   if ( keyvalues["historic"] == "chimney" ) then
      keyvalues["man_made"] = "chimney"
      keyvalues["historic"] = nil
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
-- If something has a "tpuk_ref", use it in preference to "name".
-- It's in brackets because it's likely not signed.
-- ----------------------------------------------------------------------------
   if ( keyvalues["tpuk_ref"] ~= nil ) then
      keyvalues["name"] = "(" .. keyvalues["tpuk_ref"] .. ")"
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
        ( keyvalues["generator:type"]   == "wind"         )  or
        ( keyvalues["generator:method"] == "wind"         ))) then
      keyvalues["man_made"] = nil
   end

-- ----------------------------------------------------------------------------
-- Railway ventilation shaft nodes.
-- Nodes of these are rendered as a stubby black tower
-- ----------------------------------------------------------------------------
   if (( keyvalues["building"]   == "air_shaft"         ) or
       ( keyvalues["man_made"]   == "air_shaft"         ) or
       ( keyvalues["tunnel"]     == "air_shaft"         ) or
       ( keyvalues["historic"]   == "air_shaft"         ) or
       ( keyvalues["railway"]    == "ventilation_shaft" ) or
       ( keyvalues["tunnel"]     == "ventilation_shaft" ) or
       ( keyvalues["tunnel"]     == "ventilation shaft" ) or
       ( keyvalues["building"]   == "ventilation_shaft" ) or
       ( keyvalues["building"]   == "vent_shaft"        ) or
       ( keyvalues["man_made"]   == "vent_shaft"        ) or
       ( keyvalues["tower:type"] == "vent"              ) or
       ( keyvalues["man_made"]   == "tunnel_vent"       )) then
      keyvalues["man_made"] = "ventilation_shaft"
   end

-- ----------------------------------------------------------------------------
-- Horse mounting blocks
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"]   == "mounting_block" ) or
       ( keyvalues["bridleway"] == "mounting_block" ) or
       ( keyvalues["historic"]  == "mounting_block" ) or
       ( keyvalues["horse"]     == "mounting_block" ) or
       ( keyvalues["amenity"]   == "mounting_step"  ) or
       ( keyvalues["amenity"]   == "mounting_steps" )) then
      keyvalues["man_made"] = "mounting_block"
   end

-- ----------------------------------------------------------------------------
-- Advertising Columns
-- ----------------------------------------------------------------------------
   if ( keyvalues["advertising"] == "column" ) then
      keyvalues["tourism"] = "advertising_column"
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
   if (( keyvalues["crossing"] == "traffic_signals"         ) or
       ( keyvalues["crossing"] == "toucan"                  ) or
       ( keyvalues["crossing"] == "puffin"                  ) or
       ( keyvalues["crossing"] == "traffic_signals;island"  ) or
       ( keyvalues["crossing"] == "traffic_lights"          ) or
       ( keyvalues["crossing"] == "island;traffic_signals"  ) or
       ( keyvalues["crossing"] == "signals"                 ) or
       ( keyvalues["crossing"] == "pegasus"                 ) or
       ( keyvalues["crossing"] == "pedestrian_signals"      ) or
       ( keyvalues["crossing"] == "traffic_signals; island" ) or
       ( keyvalues["crossing"] == "light_controlled"        ) or
       ( keyvalues["crossing"] == "pelican;island"          ) or
       ( keyvalues["crossing"] == "light controlled"        ) or
       ( keyvalues["crossing"] == "traffic_signals;pelican" )) then
      keyvalues["highway"] = "traffic_signals"
      keyvalues["crossing"] = nil
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
-- highway=passing_place and turning_loop to turning_circle
-- Not really the same thing, but a "widening of the road" should be good 
-- enough.  "turning_loop" seems only to be used on nodes locally.
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"]   == "passing_place" )  or
       ( keyvalues["highway"]   == "turning_loop"  )) then
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
-- That now has its own icon.
-- Also "self_catering" et al (used occasionally) as guest_house.
-- ----------------------------------------------------------------------------
   if (( keyvalues["tourism"]   == "self_catering"     ) or
       ( keyvalues["tourism"]   == "apartment"         ) or
       ( keyvalues["tourism"]   == "apartments"        ) or
       ( keyvalues["tourism"]   == "holiday_cottage"   )) then
      keyvalues["tourism"] = "guest_house"
   end

-- ----------------------------------------------------------------------------
-- Render amenity=information as tourism
-- ----------------------------------------------------------------------------
   if ( keyvalues["tourism"] == "camping"  ) then
      keyvalues["tourism"] = "camp_site"
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
        ( keyvalues["operator"]  == "Peak District & Northern Counties Footpaths Preservation Sciety"  ) or
        ( keyvalues["operator"]  == "Peak District & Northern Counties Footpaths Preservation Society" ))) then
      keyvalues["tourism"] = "informationpnfs"
   end

-- ----------------------------------------------------------------------------
-- Various types of information
-- ----------------------------------------------------------------------------
   if ((   keyvalues["amenity"]     == "notice_board"                       )  or
       (   keyvalues["tourism"]     == "village_sign"                       )  or
       (   keyvalues["tourism"]     == "sign"                               )  or
       ((  keyvalues["tourism"]     == "information"                       )   and
        (( keyvalues["information"] == "board"                            )    or
         ( keyvalues["information"] == "map"                              )    or
         ( keyvalues["information"] == "history"                          )    or
         ( keyvalues["information"] == "terminal"                         )    or
         ( keyvalues["information"] == "nature"                           )    or
         ( keyvalues["information"] == "noticeboard"                      )    or
         ( keyvalues["information"] == "sign"                             )    or
         ( keyvalues["information"] == "tactile_model"                    )    or
         ( keyvalues["information"] == "map_board"                        )    or
         ( keyvalues["information"] == "wildlife"                         )    or
         ( keyvalues["information"] == "sitemap"                          )    or
         ( keyvalues["information"] == "notice_board"                     )    or
         ( keyvalues["information"] == "tactile_map"                      )    or
         ( keyvalues["information"] == "electronic_board"                 )    or
         ( keyvalues["information"] == "hikingmap"                        )    or
         ( keyvalues["information"] == "interpretation"                   )    or
         ( keyvalues["information"] == "map;board"                        )    or
         ( keyvalues["information"] == "former_telephone_box"             )    or
         ( keyvalues["information"] == "leaflets"                         )    or
         ( keyvalues["information"] == "departure times and destinations" )    or
         ( keyvalues["information"] == "board;map"                        )))) then
      keyvalues["tourism"] = "informationboard"
   end

   if ((  keyvalues["tourism"]     == "information"                       )  and
       (( keyvalues["information"] == "guidepost"                        )   or
        ( keyvalues["information"] == "fingerpost"                       )   or
        ( keyvalues["information"] == "marker"                           ))) then
      keyvalues["tourism"] = "informationmarker"
   end

   if (((  keyvalues["tourism"]     == "information"                       )   and
        (( keyvalues["information"] == "route_marker"                     )    or
         ( keyvalues["information"] == "trail_blaze"                      )))  or
       (   keyvalues["highway"]     == "waymarker"                          )) then
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
-- Things that are both hotels and pubs should render as pubs, because I'm 
-- far more likely to be looking for the latter than the former.
-- This is done by removing the tourism tag for them.
-- Likewise, "bar;restaurant" to "bar".
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"]   == "pub"   ) and
       ( keyvalues["tourism"]   == "hotel" )) then
      keyvalues["tourism"] = nil
   end

   if ( keyvalues["amenity"] == "bar;restaurant" ) then
      keyvalues["amenity"] = "bar"
   end

   if ( keyvalues["shop"] == "greengrocer;florist" ) then
      keyvalues["shop"] = "greengrocer"
   end

   if ( keyvalues["shop"] == "butcher;greengrocer" ) then
      keyvalues["shop"] = "butcher"
   end

-- ----------------------------------------------------------------------------
-- Things that are both peaks and memorials should render as the latter.
-- ----------------------------------------------------------------------------
   if (( keyvalues["natural"]   == "peak"     ) and
       ( keyvalues["historic"]  == "memorial" )) then
      keyvalues["natural"] = nil
   end

-- ----------------------------------------------------------------------------
-- Things that are both peaks and cairns should render as the former.
-- ----------------------------------------------------------------------------
   if (( keyvalues["natural"]   == "peak"     ) and
       ( keyvalues["man_made"]  == "cairn" )) then
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
       (  keyvalues["natural"]  ~= "peak"           )) then
      keyvalues["historic"] = "nonspecific"
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
-- man_made=embankment and natural=cliff displays as a non-sided cliff
-- (direction is important)
-- man_made=levee displays as a two-sided cliff.  
-- Often it's combined with highway though, and that is handled separately.
-- In that case it's passed through to the stylesheet as bridge=levee.
-- embankment handling is asymmetric for railways currently - it's checked
-- before we apply the "man_made=levee" tag, but "bridge=levee" is not applied.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["barrier"]    == "flood_bank" )  or
        ( keyvalues["barrier"]    == "bund"       )  or
        ( keyvalues["barrier"]    == "mound"      )  or
        ( keyvalues["barrier"]    == "ridge"      )  or
        ( keyvalues["barrier"]    == "embankment" )  or
        ( keyvalues["man_made"]   == "dyke"       )  or
        ( keyvalues["man_made"]   == "levee"      )  or
        ( keyvalues["embankment"] == "yes"        )) and
       (  keyvalues["highway"]    == nil           ) and
       (  keyvalues["railway"]    == nil           ) and
       (  keyvalues["waterway"]   == nil           )) then
      keyvalues["man_made"] = "levee"
      keyvalues["barrier"] = nil
      keyvalues["embankment"] = nil
   end

-- ----------------------------------------------------------------------------
-- Re the "bridge" check below, we've already changed valid ones to "yes"
-- above.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["barrier"]    == "flood_bank" )  or
        ( keyvalues["man_made"]   == "dyke"       )  or
        ( keyvalues["man_made"]   == "levee"      )  or
        ( keyvalues["embankment"] == "yes"        )) and
       (( keyvalues["highway"]    ~= nil          ) or
        ( keyvalues["railway"]    ~= nil          ) or
        ( keyvalues["waterway"]   ~= nil          )) and
       (  keyvalues["bridge"]     ~= "yes"         ) and
       (  keyvalues["tunnel"]     ~= "yes"         )) then
      keyvalues["bridge"] = "levee"
      keyvalues["barrier"] = nil
      keyvalues["man_made"] = nil
      keyvalues["embankment"] = nil
   end

-- ----------------------------------------------------------------------------
-- barrier=horse_jump is used almost exclusively on ways, so map to fence.
-- Also some other barriers.
-- ----------------------------------------------------------------------------
   if (( keyvalues["barrier"]    == "fence" ) and
       ( keyvalues["fence_type"] == "hedge" )) then
      keyvalues["barrier"] = "hedge"
   end

-- ----------------------------------------------------------------------------
-- barrier=horse_jump is used almost exclusively on ways, so map to fence.
-- Also some other barriers.
-- ----------------------------------------------------------------------------
   if (( keyvalues["barrier"] == "horse_jump"     ) or
       ( keyvalues["barrier"] == "guard_retail"   ) or
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
-- Choose which of the two gate icons to used based on tagging.
-- "sally_port" is mapped to gate largely because of misuse in the data.
-- ----------------------------------------------------------------------------
   if (( keyvalues["barrier"]   == "swing_gate"            )  or
       ( keyvalues["barrier"]   == "footgate"              )  or
       ( keyvalues["barrier"]   == "hampshire_gate"        )  or
       ( keyvalues["barrier"]   == "bump_gate"             )  or
       ( keyvalues["barrier"]   == "lych_gate"             )  or
       ( keyvalues["barrier"]   == "lytch_gate"            )  or
       ( keyvalues["barrier"]   == "flood_gate"            )  or
       ( keyvalues["barrier"]   == "ramblers_gate"         )  or
       ( keyvalues["barrier"]   == "sally_port"            )  or
       ( keyvalues["barrier"]   == "pengate"               )  or
       ( keyvalues["barrier"]   == "pengates"              )  or
       ( keyvalues["barrier"]   == "gate;stile"            )  or
       ( keyvalues["barrier"]   == "cattle_grid;gate"      )  or
       ( keyvalues["barrier"]   == "gate;kissing_gate"     )  or
       ( keyvalues["barrier"]   == "pull_apart_gate"       )  or
       ( keyvalues["barrier"]   == "snow_gate"             )) then
      keyvalues["barrier"] = "gate"
   end

   if (( keyvalues["barrier"]   == "turnstile"             )  or
       ( keyvalues["barrier"]   == "full-height_turnstile" )  or
       ( keyvalues["barrier"]   == "kissing_gate;gate"     )) then
      keyvalues["barrier"] = "kissing_gate"
   end

   if (( keyvalues["barrier"] == "border_control"   ) or
       ( keyvalues["barrier"] == "ticket_barrier"   ) or
       ( keyvalues["barrier"] == "ticket"           ) or
       ( keyvalues["barrier"] == "lift_gate,lights" ) or
       ( keyvalues["barrier"] == "security_control" ) or
       ( keyvalues["barrier"] == "checkpoint"       ) or
       ( keyvalues["barrier"] == "gatehouse"        )) then
      keyvalues["barrier"] = "lift_gate"
   end

-- ----------------------------------------------------------------------------
-- render barrier=bar as barrier=horse_stile (Norfolk)
-- ----------------------------------------------------------------------------
   if ( keyvalues["barrier"] == "bar" ) then
      keyvalues["barrier"] = "horse_stile"
   end

-- ----------------------------------------------------------------------------
-- render barrier=bar as barrier=horse_stile (Norfolk)
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
       ( keyvalues["barrier"]   == "squeeze_point"   )  or
       ( keyvalues["barrier"]   == "step_over"       )  or
       ( keyvalues["barrier"]   == "stile;gate"      )) then
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
-- Render historic=wayside_cross and wayside_shrine as historic=memorial
-- Also man_made=obelisk and landmark=obelisk
-- It's near enough in meaning I think.
-- ----------------------------------------------------------------------------
   if (( keyvalues["historic"]   == "wayside_cross"  ) or
       ( keyvalues["historic"]   == "wayside_shrine" ) or
       ( keyvalues["man_made"]   == "obelisk"        ) or
       ( keyvalues["landmark"]   == "obelisk"        )) then
      keyvalues["historic"] = "memorial"
   end

-- ----------------------------------------------------------------------------
-- Render shop=newsagent as shop=convenience
-- It's near enough in meaning I think.  Likewise kiosk (bit of a stretch,
-- but nearer than anything else)
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]   == "newsagent"           ) or
       ( keyvalues["shop"]   == "newsagent;toys"      ) or
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
-- "clothes" consolidation.  "baby_goods" is here because there will surely
-- be some clothes there!
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"] == "fashion"      ) or
       ( keyvalues["shop"] == "boutique"     ) or
       ( keyvalues["shop"] == "vintage"      ) or
       ( keyvalues["shop"] == "bridal"       ) or
       ( keyvalues["shop"] == "wedding"      ) or
       ( keyvalues["shop"] == "lingerie"     ) or
       ( keyvalues["shop"] == "shoes"        ) or
       ( keyvalues["shop"] == "shoe"         ) or
       ( keyvalues["shop"] == "footwear"     ) or
       ( keyvalues["shop"] == "baby_goods"   ) or
       ( keyvalues["shop"] == "baby"         ) or
       ( keyvalues["shop"] == "dance"        ) or
       ( keyvalues["shop"] == "clothes_hire" ) or
       ( keyvalues["shop"] == "clothing"     ) or
       ( keyvalues["shop"] == "hat"          ) or
       ( keyvalues["shop"] == "hats"         ) or
       ( keyvalues["shop"] == "underwear"    ) or
       ( keyvalues["shop"] == "wigs"         )) then
      keyvalues["shop"] = "clothes"
   end

-- ----------------------------------------------------------------------------
-- "electrical" consolidation
-- Looking at the tagging of shop=electronics, there's a fair crossover with 
-- electrical.  "security" is less of a fit here.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]  == "electronics"             ) or
       ( keyvalues["shop"]  == "radiotechnics"           ) or
       ( keyvalues["shop"]  == "appliance"               ) or
       ( keyvalues["shop"]  == "electrical_supplies"     ) or
       ( keyvalues["shop"]  == "electrical_repair"       ) or
       ( keyvalues["shop"]  == "tv_repair"               ) or
       ( keyvalues["shop"]  == "alarm"                   ) or
       ( keyvalues["shop"]  == "gadget"                  ) or
       ( keyvalues["shop"]  == "appliances"              ) or
       ( keyvalues["shop"]  == "vacuum_cleaner"          ) or
       ( keyvalues["shop"]  == "sewing_machines"         ) or
       ( keyvalues["shop"]  == "domestic_appliances"     ) or
       ( keyvalues["shop"]  == "white_goods"             ) or
       ( keyvalues["shop"]  == "electricial"             ) or
       ( keyvalues["shop"]  == "electricals"             ) or
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
       ( keyvalues["amenity"] == "undertaker"          ) or
       ( keyvalues["shop"]    == "undertaker"          )) then
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
   if (( keyvalues["shop"] == "catalogue"  ) or
       ( keyvalues["shop"] == "department" )) then
      keyvalues["shop"] = "department_store"
   end

   if ( keyvalues["shop"] == "flower"  ) then
      keyvalues["shop"] = "florist"
   end

-- ----------------------------------------------------------------------------
-- office=estate_agent.  There's now an icon for "shop", so use that.
-- Also letting_agent
-- ----------------------------------------------------------------------------
   if (( keyvalues["office"]  == "estate_agent"      ) or
       ( keyvalues["office"]  == "estate_agents"     ) or
       ( keyvalues["shop"]    == "estate_agents"     ) or
       ( keyvalues["amenity"] == "estate_agent"      ) or
       ( keyvalues["shop"]    == "letting_agent"     ) or
       ( keyvalues["shop"]    == "lettings_agent"    ) or
       ( keyvalues["shop"]    == "council_house"     ) or
       ( keyvalues["office"]  == "letting_agent"     ) or
       ( keyvalues["shop"]    == "estate_agency"     ) or
       ( keyvalues["office"]  == "property_services" )) then
      keyvalues["shop"] = "estate_agent"
   end

-- ----------------------------------------------------------------------------
-- plant_nursery and lawnmower etc. to garden_centre
-- Add unnamedcommercial landuse to give non-building areas a background.
-- Usage suggests shop=nursery means plant_nursery.
-- ----------------------------------------------------------------------------
   if (( keyvalues["landuse"] == "plant_nursery"              ) or
       ( keyvalues["shop"]    == "plant_nursery"              ) or
       ( keyvalues["shop"]    == "nursery"                    ) or
       ( keyvalues["shop"]    == "lawnmower"                  ) or
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
-- "cafe" and "fast_food" consolidation.  
-- Also render fish and chips with a unique icon.
-- ----------------------------------------------------------------------------
   if ( keyvalues["shop"] == "cafe"       ) then
      keyvalues["amenity"] = "cafe"
   end

   if (( keyvalues["shop"] == "sandwiches" ) or
       ( keyvalues["shop"] == "sandwich"   )) then
      keyvalues["amenity"] = "cafe"
      keyvalues["cuisine"] = "sandwich"
   end

   if (( keyvalues["shop"] == "fast_food" ) or
       ( keyvalues["shop"] == "take_away" ) or
       ( keyvalues["shop"] == "takeaway"  )) then
      keyvalues["amenity"] = "fast_food"
   end

   if ((  keyvalues["amenity"] == "fast_food" )  and
       (( keyvalues["cuisine"] == "burger"   )   or
        ( keyvalues["cuisine"] == "american" )   or
        ( keyvalues["cuisine"] == "diner"    ))) then
      keyvalues["amenity"] = "fast_food_burger"
   end

   if (( keyvalues["amenity"] == "fast_food" )  and
       ( keyvalues["cuisine"] == "chicken"   )) then
      keyvalues["amenity"] = "fast_food_chicken"
   end

   if ((  keyvalues["amenity"] == "fast_food"     )  and
       (( keyvalues["cuisine"] == "chinese"      )   or
        ( keyvalues["cuisine"] == "thai"         )   or
        ( keyvalues["cuisine"] == "chinese;thai" )   or
        ( keyvalues["cuisine"] == "asian"        )   or
        ( keyvalues["cuisine"] == "japanese"     )   or
        ( keyvalues["cuisine"] == "vietnamese"   )   or
        ( keyvalues["cuisine"] == "korean"       )   or
        ( keyvalues["cuisine"] == "ramen"        )   or
        ( keyvalues["cuisine"] == "noodle"       )   or
        ( keyvalues["cuisine"] == "noodle;ramen" )   or
        ( keyvalues["cuisine"] == "malaysian"    )   or
        ( keyvalues["cuisine"] == "indonesian"   )   or
        ( keyvalues["cuisine"] == "sushi"        ))) then
      keyvalues["amenity"] = "fast_food_chinese"
   end

   if ((  keyvalues["amenity"] == "fast_food"    )  and
       (( keyvalues["cuisine"] == "coffee"      )   or
        ( keyvalues["cuisine"] == "coffee_shop" ))) then
      keyvalues["amenity"] = "fast_food_coffee"
   end

   if ((  keyvalues["amenity"] == "fast_food"               ) and
       (( keyvalues["cuisine"] == "fish_and_chips"         )  or
        ( keyvalues["cuisine"] == "chinese;fish_and_chips" )  or
        ( keyvalues["cuisine"] == "fish"                   )  or
        ( keyvalues["cuisine"] == "fish_and_chips;chinese" ))) then
      keyvalues["amenity"] = "fast_food_fish_and_chips"
   end

   if ( keyvalues["shop"] == "fish_and_chips" ) then
      keyvalues["amenity"] = "fast_food_fish_and_chips"
   end

   if ((( keyvalues["amenity"] == "fast_food" )   and
        ( keyvalues["cuisine"] == "ice_cream" ))  or
       (  keyvalues["shop"]    == "ice_cream"  )  or
       (  keyvalues["amenity"] == "ice_cream"  )) then
      keyvalues["amenity"] = "fast_food_ice_cream"
   end

   if ((  keyvalues["amenity"] == "fast_food"   ) and
       (( keyvalues["cuisine"] == "indian"     )  or
        ( keyvalues["cuisine"] == "curry"      ))) then
      keyvalues["amenity"] = "fast_food_indian"
   end

   if ((  keyvalues["amenity"] == "fast_food" )  and
       (( keyvalues["cuisine"] == "kebab"     )  or
        ( keyvalues["cuisine"] == "turkish"   ))) then
      keyvalues["amenity"] = "fast_food_kebab"
   end

   if ((  keyvalues["amenity"] == "fast_food"   )  and
       (( keyvalues["cuisine"] == "pastie"     )   or
        ( keyvalues["cuisine"] == "pasties"    )   or
        ( keyvalues["cuisine"] == "pasty"      )   or
        ( keyvalues["cuisine"] == "pie"        )   or
        ( keyvalues["cuisine"] == "pies"       ))) then
      keyvalues["amenity"] = "fast_food_pie"
   end

   if ((  keyvalues["amenity"] == "fast_food"      )  and
       (( keyvalues["cuisine"] == "pizza"         )   or
        ( keyvalues["cuisine"] == "italian"       )   or
        ( keyvalues["cuisine"] == "italian;pizza" ))) then
      keyvalues["amenity"] = "fast_food_pizza"
   end

   if (( keyvalues["amenity"] == "fast_food" )  and
       ( keyvalues["cuisine"] == "sandwich"  )) then
      keyvalues["amenity"] = "fast_food_sandwich"
   end

   if (( keyvalues["amenity"] == "clock"   )  and
       ( keyvalues["display"] == "sundial" )) then
      keyvalues["amenity"] = "sundial"
   end

-- ----------------------------------------------------------------------------
-- Render shop=hardware stores etc. as shop=doityourself
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]   == "hardware"             ) or
       ( keyvalues["shop"]   == "tool_hire"            ) or
       ( keyvalues["shop"]   == "equipment_hire"       ) or
       ( keyvalues["shop"]   == "diy"                  ) or
       ( keyvalues["shop"]   == "tools"                ) or
       ( keyvalues["shop"]   == "builders_merchant"    ) or
       ( keyvalues["shop"]   == "builders_merchants"   ) or
       ( keyvalues["shop"]   == "timber"               ) or
       ( keyvalues["shop"]   == "fencing"              ) or
       ( keyvalues["shop"]   == "plumbers_merchant"    ) or
       ( keyvalues["shop"]   == "building_supplies"    ) or
       ( keyvalues["shop"]   == "industrial_supplies"  ) or
       ( keyvalues["office"] == "industrial_supplies"  ) or
       ( keyvalues["shop"]   == "plant_hire"           ) or
       ( keyvalues["shop"]   == "plant_hire;tool_hire" ) or
       ( keyvalues["shop"]   == "signs"                ) or
       ( keyvalues["shop"]   == "sign"                 ) or
       ( keyvalues["shop"]   == "signwriter"           ) or
       ( keyvalues["craft"]  == "signmaker"            ) or
       ( keyvalues["craft"]  == "roofer"               ) or
       ( keyvalues["shop"]   == "roofing"              ) or
       ( keyvalues["shop"]   == "building_materials"   )) then
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
       ( keyvalues["shop"] == "moneylender"        ) or
       ( keyvalues["shop"] == "loan_shark"         ) or
       ( keyvalues["shop"] == "cash"               )) then
      keyvalues["shop"] = "pawnbroker"
   end

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
       ( keyvalues["amenity"] == "bureau_de_change"    ) or
       ( keyvalues["shop"]    == "bureau_de_change"    )) then
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
       ( keyvalues["shop"]   == "watersports"       ) or
       ( keyvalues["shop"]   == "fishing"           ) or
       ( keyvalues["shop"]   == "fishing_tackle"    ) or
       ( keyvalues["shop"]   == "angling"           ) or
       ( keyvalues["shop"]   == "fitness_equipment" )) then
      keyvalues["shop"] = "sports"
   end

-- ----------------------------------------------------------------------------
-- e-cigarette
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]   == "veping"               ) or
       ( keyvalues["shop"]   == "vape_shop"            ) or
       ( keyvalues["shop"]   == "e_cigarette"          ) or
       ( keyvalues["shop"]   == "ecigarettes"          ) or
       ( keyvalues["shop"]   == "electronic_cigarette" ) or
       ( keyvalues["shop"]   == "e-cigarettes"         )) then
      keyvalues["shop"] = "e-cigarette"
   end

-- ----------------------------------------------------------------------------
-- Various things best rendered as clothes shops
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "tailor"                  ) or
       ( keyvalues["craft"]   == "tailor"                  ) or
       ( keyvalues["craft"]   == "dressmaker"              )) then
      keyvalues["shop"] = "clothes"
   end

-- ----------------------------------------------------------------------------
-- Currently handle beauty salons etc. as just generic.  Also "chemist"
-- Mostly these have names that describe the business, so less need for a
-- specific icon.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]         == "beauty_salon"      ) or
       ( keyvalues["leisure"]      == "spa"               ) or
       ( keyvalues["shop"]         == "salon"             ) or
       ( keyvalues["shop"]         == "nails"             ) or
       ( keyvalues["shop"]         == "nailbar"           ) or
       ( keyvalues["shop"]         == "nail"              ) or
       ( keyvalues["shop"]         == "chemist"           ) or
       ( keyvalues["shop"]         == "soap"              ) or
       ( keyvalues["shop"]         == "toiletries"        ) or
       ( keyvalues["shop"]         == "beauty_products"   ) or
       ( keyvalues["shop"]         == "beauty_treatment"  ) or
       ( keyvalues["shop"]         == "perfume"           ) or
       ( keyvalues["shop"]         == "perfumery"         ) or
       ( keyvalues["shop"]         == "cosmetics"         ) or
       ( keyvalues["shop"]         == "tanning"           ) or
       ( keyvalues["shop"]         == "suntan"            ) or
       ( keyvalues["shop"]         == "tanning_salon"     ) or
       ( keyvalues["leisure"]      == "tanning_salon"     ) or
       ( keyvalues["shop"]         == "health_and_beauty" ) or
       ( keyvalues["shop"]         == "beautician"        )) then
      keyvalues["shop"] = "beauty"
   end

-- ----------------------------------------------------------------------------
-- "Non-electrical" electronics (i.e. ones for which the "electrical" icon
-- is inappropriate).
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]  == "security"         ) or
       ( keyvalues["shop"]  == "survey"           ) or
       ( keyvalues["shop"]  == "survey_equipment" ) or       
       ( keyvalues["shop"]  == "hifi"             ) or
       ( keyvalues["shop"]  == "computer"         ) or
       ( keyvalues["shop"]  == "computer_repair"  )) then
      keyvalues["shop"] = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- Betting Shops etc.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "bookmakers"          ) or
       ( keyvalues["shop"]    == "betting"             ) or
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
       ( keyvalues["leisure"] == "escape_game"         ) or
       ( keyvalues["sport"]   == "laser_tag"           ) or
       ( keyvalues["amenity"] == "casino"              ) or
       ( keyvalues["amenity"] == "bingo"               ) or
       ( keyvalues["leisure"] == "bingo"               )) then
      keyvalues["shop"] = "bookmaker"
   end

-- ----------------------------------------------------------------------------
-- mobile_phone shops as displayed just generic.
-- Again, the name usually describes the business
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]   == "mobile_phone" ) or
       ( keyvalues["shop"]   == "phone"        ) or
       ( keyvalues["shop"]   == "phone_repair" )) then
      keyvalues["shop"] = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- gift and other tat shops are rendered generically
-- Difficult to do an icon for and often the name describes the business.
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
       ( keyvalues["shop"]   == "bags"                ) or
       ( keyvalues["shop"]   == "balloon"             ) or
       ( keyvalues["shop"]   == "accessories"         ) or
       ( keyvalues["shop"]   == "beach"               ) or
       ( keyvalues["shop"]   == "magic"               ) or
       ( keyvalues["shop"]   == "fashion_accessories" )) then
      keyvalues["shop"] = "gift"
   end

-- ----------------------------------------------------------------------------
-- Various photo, camera, copy and print shops
-- Difficult to do an icon for.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "copyshop"           ) or
       ( keyvalues["office"]  == "design"             ) or
       ( keyvalues["shop"]    == "camera"             ) or
       ( keyvalues["shop"]    == "photo"              ) or
       ( keyvalues["shop"]    == "photo_studio"       ) or
       ( keyvalues["office"]  == "photo_studio"       ) or
       ( keyvalues["shop"]    == "photography"        ) or
       ( keyvalues["office"]  == "photography"        ) or
       ( keyvalues["shop"]    == "photographic"       ) or
       ( keyvalues["shop"]    == "photographer"       ) or
       ( keyvalues["shop"]    == "printing"           ) or
       ( keyvalues["shop"]    == "printer"            ) or
       ( keyvalues["shop"]    == "print"              ) or
       ( keyvalues["shop"]    == "printers"           ) or
       ( keyvalues["craft"]   == "printer"            ) or
       ( keyvalues["shop"]    == "printer_cartridges" ) or
       ( keyvalues["shop"]    == "printer_ink"        ) or
       ( keyvalues["shop"]    == "ink_cartridge"      ) or
       ( keyvalues["amenity"] == "printer"            ) or
       ( keyvalues["office"]  == "printer"            )) then
      keyvalues["shop"] = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- Various single food item and other food shops
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "cake"            ) or
       ( keyvalues["shop"]    == "cakes"           ) or
       ( keyvalues["shop"]    == "fish"            ) or
       ( keyvalues["shop"]    == "farm"            ) or
       ( keyvalues["shop"]    == "farm_shop"       ) or
       ( keyvalues["shop"]    == "seafood"         ) or
       ( keyvalues["shop"]    == "specialist_food" ) or
       ( keyvalues["shop"]    == "beverages"       ) or
       ( keyvalues["shop"]    == "coffee"          ) or
       ( keyvalues["shop"]    == "tea"             ) or
       ( keyvalues["shop"]    == "chocolate"       ) or
       ( keyvalues["shop"]    == "milk"            ) or
       ( keyvalues["shop"]    == "cheese"          ) or
       ( keyvalues["shop"]    == "cheese;wine"     ) or
       ( keyvalues["shop"]    == "wine;cheese"     ) or
       ( keyvalues["shop"]    == "dairy"           ) or
       ( keyvalues["shop"]    == "eggs"            ) or
       ( keyvalues["shop"]    == "deli"            ) or
       ( keyvalues["shop"]    == "delicatessen"    ) or
       ( keyvalues["shop"]    == "catering"        ) or
       ( keyvalues["shop"]    == "patissery"       ) or
       ( keyvalues["shop"]    == "pastry"          ) or
       ( keyvalues["shop"]    == "fishmonger"      ) or
       ( keyvalues["shop"]    == "confectionery"   ) or
       ( keyvalues["shop"]    == "sweets"          ) or
       ( keyvalues["shop"]    == "sweet"           ) or
       ( keyvalues["shop"]    == "spice"           ) or
       ( keyvalues["shop"]    == "nuts"            ) or
       ( keyvalues["shop"]    == "alcohol"         ) or
       ( keyvalues["shop"]    == "beer"            ) or
       ( keyvalues["shop"]    == "off_licence"     ) or
       ( keyvalues["shop"]    == "off_license"     ) or
       ( keyvalues["shop"]    == "offlicence"      ) or
       ( keyvalues["shop"]    == "wine"            ) or
       ( keyvalues["shop"]    == "whisky"          )) then
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
       ( keyvalues["shop"]   == "homewares"           ) or
       ( keyvalues["shop"]   == "home"                ) or
       ( keyvalues["shop"]   == "upholsterer"         ) or
       ( keyvalues["shop"]   == "chair"               ) or
       ( keyvalues["shop"]   == "luggage"             ) or
       ( keyvalues["shop"]   == "clock"               ) or
       ( keyvalues["shop"]   == "clocks"              ) or
       ( keyvalues["shop"]   == "home_improvement"    ) or
       ( keyvalues["shop"]   == "interior_decoration" ) or
       ( keyvalues["shop"]   == "decorating"          ) or
       ( keyvalues["shop"]   == "interior_design"     ) or
       ( keyvalues["shop"]   == "interior"            ) or
       ( keyvalues["shop"]   == "interiors"           ) or
       ( keyvalues["shop"]   == "carpet"              ) or
       ( keyvalues["shop"]   == "carpets"             ) or
       ( keyvalues["shop"]   == "carpet;bed"          ) or
       ( keyvalues["shop"]   == "bed;carpet"          ) or
       ( keyvalues["shop"]   == "carpet; bed"         ) or
       ( keyvalues["shop"]   == "country"             ) or
       ( keyvalues["shop"]   == "country_store"       ) or
       ( keyvalues["shop"]   == "equestrian"          ) or
       ( keyvalues["shop"]   == "kitchen"             ) or
       ( keyvalues["shop"]   == "kitchen;bathroom"    ) or
       ( keyvalues["shop"]   == "kitchens"            ) or
       ( keyvalues["shop"]   == "stoves"              ) or
       ( keyvalues["shop"]   == "stove"               ) or
       ( keyvalues["shop"]   == "lamps"               ) or
       ( keyvalues["shop"]   == "bedroom"             ) or
       ( keyvalues["shop"]   == "houseware"           ) or
       ( keyvalues["shop"]   == "bathroom_furnishing" ) or
       ( keyvalues["shop"]   == "household"           ) or
       ( keyvalues["shop"]   == "bathroom"            ) or
       ( keyvalues["shop"]   == "glaziery"            ) or
       ( keyvalues["craft"]  == "glaziery"            ) or
       ( keyvalues["shop"]   == "glazier"             ) or
       ( keyvalues["craft"]  == "glazier"             ) or
       ( keyvalues["shop"]   == "glazing"             ) or
       ( keyvalues["shop"]   == "tiles"               ) or
       ( keyvalues["shop"]   == "tile"                ) or
       ( keyvalues["shop"]   == "stone"               ) or
       ( keyvalues["shop"]   == "ceramics"            ) or
       ( keyvalues["shop"]   == "paint"               ) or
       ( keyvalues["shop"]   == "brewing"             ) or
       ( keyvalues["shop"]   == "lighting"            ) or
       ( keyvalues["shop"]   == "windows"             ) or
       ( keyvalues["shop"]   == "window"              ) or
       ( keyvalues["craft"]  == "window_construction" ) or
       ( keyvalues["shop"]   == "gates"               ) or
       ( keyvalues["shop"]   == "sheds"               ) or
       ( keyvalues["shop"]   == "shed"                ) or
       ( keyvalues["shop"]   == "ironmonger"          ) or
       ( keyvalues["shop"]   == "fireplace"           ) or
       ( keyvalues["shop"]   == "fireplaces"          ) or
       ( keyvalues["shop"]   == "furnace"             ) or
       ( keyvalues["shop"]   == "plumbing"            ) or
       ( keyvalues["craft"]  == "plumber"             ) or
       ( keyvalues["craft"]  == "carpenter"           ) or
       ( keyvalues["craft"]  == "decorator"           ) or
       ( keyvalues["shop"]   == "blinds"              ) or
       ( keyvalues["shop"]   == "window_blind"        ) or
       ( keyvalues["shop"]   == "bed"                 ) or
       ( keyvalues["shop"]   == "beds"                ) or
       ( keyvalues["shop"]   == "waterbed"            ) or
       ( keyvalues["shop"]   == "frame"               ) or
       ( keyvalues["shop"]   == "framing"             ) or
       ( keyvalues["shop"]   == "picture_framing"     ) or
       ( keyvalues["shop"]   == "picture_framer"      ) or
       ( keyvalues["craft"]  == "framing"             ) or
       ( keyvalues["shop"]   == "curtain"             ) or
       ( keyvalues["shop"]   == "furnishings"         ) or
       ( keyvalues["shop"]   == "furnishing"          ) or
       ( keyvalues["shop"]   == "bedding"             ) or
       ( keyvalues["shop"]   == "glass"               ) or
       ( keyvalues["shop"]   == "garage"              ) or
       ( keyvalues["shop"]   == "conservatory"        ) or
       ( keyvalues["shop"]   == "conservatories"      ) or
       ( keyvalues["shop"]   == "bathrooms"           ) or
       ( keyvalues["shop"]   == "swimming_pool"       ) or
       ( keyvalues["shop"]   == "spa"                 ) or
       ( keyvalues["shop"]   == "fitted_furniture"    ) or
       ( keyvalues["shop"]   == "kitchenware"         ) or
       ( keyvalues["shop"]   == "cookware"            ) or
       ( keyvalues["shop"]   == "glassware"           ) or
       ( keyvalues["shop"]   == "cookery"             ) or
       ( keyvalues["shop"]   == "upholstery"          ) or
       ( keyvalues["shop"]   == "chandler"            ) or
       ( keyvalues["shop"]   == "chandlery"           ) or
       ( keyvalues["craft"]  == "boatbuilder"         ) or
       ( keyvalues["shop"]   == "saddlery"            )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["shop"] = "furniture"
   end

-- ----------------------------------------------------------------------------
-- fabric and wool etc.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]   == "fabric"               ) or
       ( keyvalues["shop"]   == "fabrics"              ) or
       ( keyvalues["shop"]   == "linen"                ) or
       ( keyvalues["shop"]   == "linens"               ) or
       ( keyvalues["shop"]   == "haberdashery"         ) or
       ( keyvalues["shop"]   == "haberdasher"          ) or
       ( keyvalues["shop"]   == "haberdashers"         ) or
       ( keyvalues["shop"]   == "sewing"               ) or
       ( keyvalues["shop"]   == "needlecraft"          ) or
       ( keyvalues["shop"]   == "knitting"             ) or
       ( keyvalues["shop"]   == "wool"                 ) or
       ( keyvalues["shop"]   == "yarn"                 ) or
       ( keyvalues["shop"]   == "alteration"           ) or
       ( keyvalues["shop"]   == "clothing_alterations" )) then
      keyvalues["shop"] = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- health_food etc., and also "non-medical medical" and "woo" shops.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]       == "health_food"             ) or
       ( keyvalues["shop"]       == "healthfood"              ) or
       ( keyvalues["shop"]       == "health"                  ) or
       ( keyvalues["shop"]       == "organic"                 ) or
       ( keyvalues["shop"]       == "supplements"             ) or
       ( keyvalues["shop"]       == "nutrition_supplements"   ) or
       ( keyvalues["shop"]       == "dietary_supplements"     ) or
       ( keyvalues["shop"]       == "alternative_medicine"    ) or
       ( keyvalues["name"]       == "Holland and Barrett"     ) or
       ( keyvalues["shop"]       == "massage"                 ) or
       ( keyvalues["shop"]       == "herbalist"               ) or
       ( keyvalues["shop"]       == "herbal_medicine"         ) or
       ( keyvalues["shop"]       == "chinese_medicine"        ) or
       ( keyvalues["shop"]       == "new_age"                 ) or
       ( keyvalues["amenity"]    == "spa"                     ) or
       ( keyvalues["shop"]       == "alternative_health"      ) or
       ( keyvalues["healthcare"] == "alternative"             ) or
       ( keyvalues["shop"]       == "acupuncture"             ) or
       ( keyvalues["shop"]       == "aromatherapy"            )) then
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
       ( keyvalues["shop"]   == "comics"          ) or
       ( keyvalues["shop"]   == "comic"           ) or
       ( keyvalues["shop"]   == "anime"           ) or
       ( keyvalues["shop"]   == "maps"            ) or
       ( keyvalues["shop"]   == "office_supplies" )) then
      keyvalues["shop"] = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- toys and games etc.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]   == "toys"           ) or
       ( keyvalues["shop"]   == "model"          ) or
       ( keyvalues["shop"]   == "models"         ) or
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
       ( keyvalues["shop"]    == "pet;garden"              ) or
       ( keyvalues["shop"]    == "aquatics"                ) or
       ( keyvalues["shop"]    == "aquarium"                ) or
       ( keyvalues["shop"]    == "pet_supplies"            ) or
       ( keyvalues["shop"]    == "pet_care"                ) or
       ( keyvalues["shop"]    == "pet_food"                ) or
       ( keyvalues["shop"]    == "pet_grooming"            ) or
       ( keyvalues["shop"]    == "dog_grooming"            ) or
       ( keyvalues["shop"]    == "pet;corn"                ) or
       ( keyvalues["shop"]    == "animal_feed"             ) or
       ( keyvalues["amenity"] == "dog_grooming"            ) or
       ( keyvalues["craft"]   == "dog_grooming"            ) or
       ( keyvalues["animal"]  == "wellness"                ) or
       ( keyvalues["amenity"] == "veterinary"              ) or
       ( keyvalues["amenity"] == "animal_boarding"         ) or
       ( keyvalues["amenity"] == "cattery"                 ) or
       ( keyvalues["amenity"] == "kennels"                 ) or
       ( keyvalues["amenity"] == "animal_shelter"          )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["shop"] = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- Car parts
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "car_accessories"              )  or
       ( keyvalues["shop"]    == "tyres"                        )  or
       ( keyvalues["shop"]    == "car_tyres"                    )  or
       ( keyvalues["shop"]    == "automotive"                   )  or
       ( keyvalues["shop"]    == "battery"                      )  or
       ( keyvalues["shop"]    == "batteries"                    )  or
       ( keyvalues["shop"]    == "number_plate"                 )  or
       ( keyvalues["shop"]    == "licence_plates"               )  or
       ( keyvalues["shop"]    == "car_audio"                    )  or
       ( keyvalues["shop"]    == "motor"                        )  or
       ( keyvalues["shop"]    == "motoring"                     )  or
       ( keyvalues["shop"]    == "motor_spares"                 )  or
       ( keyvalues["shop"]    == "bicycle;car_repair;car_parts" )) then
      keyvalues["shop"] = "car_parts"
   end

-- ----------------------------------------------------------------------------
-- Shopmobility
-- Note that "shop=mobility" is something that _sells_ mobility aids, and is
-- handled as shop=nonspecific for now.
-- We handle some specific cases of shop=mobility here; the reset below.
-- ----------------------------------------------------------------------------
   if ((   keyvalues["amenity"]  == "mobility"                 ) or
       (   keyvalues["amenity"]  == "mobility_equipment_hire"  ) or
       (   keyvalues["amenity"]  == "mobility_aids_hire"       ) or
       (   keyvalues["amenity"]  == "shop_mobility"            ) or
       ((( keyvalues["shop"]     == "yes"                    )   or
         ( keyvalues["shop"]     == "mobility"               )   or
         ( keyvalues["building"] == "yes"                    )   or
         ( keyvalues["building"] == "unit"                   ))  and
        (( keyvalues["name"]     == "Shopmobility"           )   or
         (  keyvalues["name"]    == "Shop Mobility"          )))) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["amenity"] = "shopmobility"
   end

-- ----------------------------------------------------------------------------
-- Nonspecific car and related shops.
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "car_rental"                   ) or
       ( keyvalues["amenity"] == "van_rental"                   ) or
       ( keyvalues["shop"]    == "motorcycle"                   ) or
       ( keyvalues["shop"]    == "motorcycle_repair"            ) or
       ( keyvalues["shop"]    == "motorcycle_parts"             ) or
       ( keyvalues["shop"]    == "caravan"                      ) or
       ( keyvalues["shop"]    == "caravans"                     ) or
       ( keyvalues["shop"]    == "motorhome"                    ) or
       ( keyvalues["shop"]    == "boat"                         ) or
       ( keyvalues["shop"]    == "truck"                        ) or
       ( keyvalues["shop"]    == "commercial_vehicles"          ) or
       ( keyvalues["shop"]    == "commercial_vehicle"           ) or
       ( keyvalues["shop"]    == "agricultural_vehicles"        ) or
       ( keyvalues["shop"]    == "tractors"                     ) or
       ( keyvalues["shop"]    == "van"                          ) or
       ( keyvalues["shop"]    == "truck_repair"                 ) or
       ( keyvalues["shop"]    == "forklift_repair"              ) or
       ( keyvalues["amenity"] == "driving_school"               )) then
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
       ( keyvalues["shop"]    == "greetings_cards"         ) or
       ( keyvalues["shop"]    == "greetings"               ) or
       ( keyvalues["shop"]    == "card;gift"               ) or
       ( keyvalues["craft"]   == "cobbler"                 ) or
       ( keyvalues["shop"]    == "cobbler"                 ) or
       ( keyvalues["shop"]    == "cobblers"                ) or
       ( keyvalues["craft"]   == "shoemaker"               ) or
       ( keyvalues["shop"]    == "shoemaker"               ) or
       ( keyvalues["shop"]    == "shoe_repair"             ) or
       ( keyvalues["shop"]    == "shoe_repair;key_cutting" ) or
       ( keyvalues["shop"]    == "key_cutting;shoe_repair" ) or
       ( keyvalues["shop"]    == "watch_repair"            ) or
       ( keyvalues["shop"]    == "key_cutting"             ) or
       ( keyvalues["shop"]    == "keys"                    ) or
       ( keyvalues["shop"]    == "key"                     ) or
       ( keyvalues["shop"]    == "laundry"                 ) or
       ( keyvalues["shop"]    == "launderette"             ) or
       ( keyvalues["shop"]    == "dry_cleaning"            ) or
       ( keyvalues["shop"]    == "dry_cleaning;laundry"    ) or
       ( keyvalues["shop"]    == "cleaning"                ) or
       ( keyvalues["shop"]    == "dry_cleaner"             ) or
       ( keyvalues["shop"]    == "dry_cleaners"            ) or
       ( keyvalues["shop"]    == "art"                     ) or
       ( keyvalues["shop"]    == "tattoo"                  ) or
       ( keyvalues["shop"]    == "piercing"                ) or
       ( keyvalues["shop"]    == "tattoo;piercing"         ) or
       ( keyvalues["shop"]    == "music"                   ) or
       ( keyvalues["shop"]    == "music;video"             ) or
       ( keyvalues["shop"]    == "records"                 ) or
       ( keyvalues["shop"]    == "record"                  ) or
       ( keyvalues["shop"]    == "collector"               ) or
       ( keyvalues["shop"]    == "collectables"            ) or
       ( keyvalues["shop"]    == "coins"                   ) or
       ( keyvalues["shop"]    == "musical_instrument"      ) or
       ( keyvalues["shop"]    == "piano"                   ) or
       ( keyvalues["shop"]    == "video"                   ) or
       ( keyvalues["shop"]    == "audio_video"             ) or
       ( keyvalues["shop"]    == "erotic"                  ) or
       ( keyvalues["shop"]    == "adult"                   ) or
       ( keyvalues["shop"]    == "locksmith"               ) or
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
       ( keyvalues["shop"]    == "army_surplus"            ) or
       ( keyvalues["shop"]    == "fireworks"               ) or
       ( keyvalues["shop"]    == "auction"                 ) or
       ( keyvalues["shop"]    == "auction_house"           ) or
       ( keyvalues["auction"] == "auction_house"           ) or
       ( keyvalues["office"]  == "auctioneer"              ) or
       ( keyvalues["shop"]    == "religion"                ) or
       ( keyvalues["shop"]    == "gas"                     ) or
       ( keyvalues["shop"]    == "fuel"                    ) or
       ( keyvalues["shop"]    == "energy"                  ) or
       ( keyvalues["shop"]    == "coal_merchant"           ) or
       ( keyvalues["shop"]    == "taxi"                    ) or
       ( keyvalues["office"]  == "taxi"                    ) or
       ( keyvalues["amenity"] == "minicab_office"          ) or
       ( keyvalues["shop"]    == "minicab"                 ) or
       ( keyvalues["amenity"] == "training"                ) or
       ( keyvalues["amenity"] == "tutoring_centre"         ) or
       ( keyvalues["office"]  == "tutoring"                ) or
       ( keyvalues["shop"]    == "ironing"                 ) or
       ( keyvalues["amenity"] == "stripclub"               ) or
       ( keyvalues["amenity"] == "self_storage"            ) or
       ( keyvalues["amenity"] == "storage"                 ) or
       ( keyvalues["shop"]    == "storage"                 ) or
       ( keyvalues["shop"]    == "storage_rental"          ) or
       ( keyvalues["amenity"] == "storage_rental"          ) or
       ( keyvalues["amenity"] == "courier"                 )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["shop"] = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- Stonemasons etc.
-- ----------------------------------------------------------------------------
   if (( keyvalues["craft"]   == "stonemason"        ) or
       ( keyvalues["shop"]    == "gravestone"        ) or
       ( keyvalues["shop"]    == "monumental_mason"  ) or
       ( keyvalues["shop"]    == "memorials"         ) or
       ( keyvalues["amenity"] == "funeral_directors" ) or
       ( keyvalues["office"]  == "funeral_directors" )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["shop"]    = "funeral_directors"
   end


-- ----------------------------------------------------------------------------
-- Shops that we don't know the type of.  Things such as "hire" are here 
-- because we don't know "hire of what".
-- "wood" is here because it's used for different sorts of shops.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "yes"             ) or
       ( keyvalues["shop"]    == "other"           ) or
       ( keyvalues["shop"]    == "hire"            ) or
       ( keyvalues["shop"]    == "rental"          ) or
       ( keyvalues["shop"]    == "second_hand"     ) or
       ( keyvalues["shop"]    == "junk"            ) or
       ( keyvalues["shop"]    == "general"         ) or
       ( keyvalues["shop"]    == "general_store"   ) or
       ( keyvalues["shop"]    == "unknown"         ) or
       ( keyvalues["shop"]    == "retail"          ) or
       ( keyvalues["shop"]    == "trade"           ) or
       ( keyvalues["shop"]    == "misc"            ) or
       ( keyvalues["shop"]    == "cash_and_carry"  ) or
       ( keyvalues["shop"]    == "fixme"           ) or
       ( keyvalues["shop"]    == "wholesale"       ) or
       ( keyvalues["shop"]    == "service"         ) or
       ( keyvalues["shop"]    == "wood"            ) or
       ( keyvalues["shop"]    == "childrens"       ) or
       ( keyvalues["shop"]    == "factory_outlet"  ) or
       ( keyvalues["shop"]    == "specialist"      ) or
       ( keyvalues["shop"]    == "specialist_shop" )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["shop"]    = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- Various mistagging, comma and semicolon healthcare
-- Note that health centres currently appear as "health nonspecific".
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "doctors; pharmacy"       ) or
       ( keyvalues["amenity"] == "doctors;social_facility" ) or
       ( keyvalues["amenity"] == "surgery"                 )) then
      keyvalues["amenity"] = "doctors"
   end

   if ( keyvalues["healthcare"] == "dentist" ) then
      keyvalues["amenity"] = "dentist"
   end

   if ( keyvalues["healthcare"] == "hospital" ) then
      keyvalues["amenity"] = "hospital"
   end

   if ( keyvalues["amenity"] == "pharmacy, doctors, dentist" ) then
      keyvalues["amenity"] = "pharmacy"
   end

-- ----------------------------------------------------------------------------
-- opticians etc. - render as "nonspecific health".
-- Add unnamedcommercial landuse to give non-building areas a background.
--
-- Places that _sell_ mobility aids are in here.  Shopmobility handled
-- seperately.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]        == "optician"                 ) or
       ( keyvalues["amenity"]     == "optician"                 ) or
       ( keyvalues["craft"]       == "optician"                 ) or
       ( keyvalues["office"]      == "optician"                 ) or
       ( keyvalues["shop"]        == "opticians"                ) or
       ( keyvalues["shop"]        == "optometrist"              ) or
       ( keyvalues["amenity"]     == "optometrist"              ) or
       ( keyvalues["healthcare"]  == "optometrist"              ) or
       ( keyvalues["shop"]        == "hearing_aids"             ) or
       ( keyvalues["shop"]        == "medical_supply"           ) or
       ( keyvalues["shop"]        == "mobility"                 ) or
       ( keyvalues["shop"]        == "disability"               ) or
       ( keyvalues["shop"]        == "chiropodist"              ) or
       ( keyvalues["amenity"]     == "chiropodist"              ) or
       ( keyvalues["healthcare"]  == "chiropodist"              ) or
       ( keyvalues["amenity"]     == "chiropractor"             ) or
       ( keyvalues["healthcare"]  == "chiropractor"             ) or
       ( keyvalues["amenity"]     == "osteopath"                ) or
       ( keyvalues["healthcare"]  == "osteopath"                ) or
       ( keyvalues["shop"]        == "osteopath"                ) or
       ( keyvalues["amenity"]     == "physiotherapist"          ) or
       ( keyvalues["healthcare"]  == "physiotherapist"          ) or
       ( keyvalues["shop"]        == "physiotherapist"          ) or
       ( keyvalues["healthcare"]  == "physiotherapy"            ) or
       ( keyvalues["shop"]        == "physiotherapy"            ) or
       ( keyvalues["healthcare"]  == "psychotherapist"          ) or
       ( keyvalues["healthcare"]  == "therapy"                  ) or
       ( keyvalues["healthcare"]  == "podiatrist"               ) or
       ( keyvalues["amenity"]     == "podiatrist"               ) or
       ( keyvalues["amenity"]     == "healthcare"               ) or
       ( keyvalues["amenity"]     == "clinic"                   ) or
       ( keyvalues["healthcare"]  == "clinic"                   ) or
       ( keyvalues["shop"]        == "clinic"                   ) or
       ( keyvalues["amenity"]     == "social_facility"          ) or
       ( keyvalues["amenity"]     == "nursing_home"             ) or
       ( keyvalues["residential"] == "nursing_home"             ) or
       ( keyvalues["building"]    == "nursing_home"             ) or
       ( keyvalues["amenity"]     == "care_home"                ) or
       ( keyvalues["residential"] == "care_home"                ) or
       ( keyvalues["amenity"]     == "retirement_home"          ) or
       ( keyvalues["amenity"]     == "residential_home"         ) or
       ( keyvalues["building"]    == "residential_home"         ) or
       ( keyvalues["residential"] == "residential_home"         ) or
       ( keyvalues["amenity"]     == "sheltered_housing"        ) or
       ( keyvalues["residential"] == "sheltered_housing"        ) or
       ( keyvalues["amenity"]     == "childcare"                ) or
       ( keyvalues["amenity"]     == "childrens_centre"         ) or
       ( keyvalues["amenity"]     == "preschool"                ) or
       ( keyvalues["building"]    == "preschool"                ) or
       ( keyvalues["amenity"]     == "nursery"                  ) or
       ( keyvalues["amenity"]     == "health_centre"            ) or
       ( keyvalues["building"]    == "health_centre"            ) or
       ( keyvalues["amenity"]     == "medical_centre"           ) or
       ( keyvalues["building"]    == "medical_centre"           ) or
       ( keyvalues["healthcare"]  == "centre"                   ) or
       ( keyvalues["healthcare"]  == "counselling"              ) or
       ( keyvalues["craft"]       == "counsellor"               ) or
       ( keyvalues["amenity"]     == "hospice"                  ) or
       ( keyvalues["healthcare"]  == "hospice"                  ) or
       ( keyvalues["healthcare"]  == "cosmetic"                 ) or
       ( keyvalues["healthcare"]  == "cosmetic_surgery"         ) or
       ( keyvalues["healthcare"]  == "cosmetic_treatments"      ) or
       ( keyvalues["healthcare"]  == "dentures"                 ) or
       ( keyvalues["shop"]        == "dentures"                 ) or
       ( keyvalues["shop"]        == "denture"                  ) or
       ( keyvalues["healthcare"]  == "blood_donation"           ) or
       ( keyvalues["healthcare"]  == "blood_bank"               ) or
       ( keyvalues["healthcare"]  == "sports_massage_therapist" ) or
       ( keyvalues["healthcare"]  == "rehabilitation"           ) or
       ( keyvalues["amenity"]     == "daycare"                  )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["shop"]    = "healthnonspecific"
   end

-- ----------------------------------------------------------------------------
-- Defibrillators etc.
-- ----------------------------------------------------------------------------
   if ( keyvalues["emergency"] == "defibrillator" ) then
      keyvalues["amenity"] = "defibrillator"
   end

   if ( keyvalues["emergency"] == "fire_extinguisher" ) then
      keyvalues["amenity"] = "fire_extinguisher"
   end

-- ----------------------------------------------------------------------------
-- Offices that we don't know the type of.  
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( keyvalues["office"]     == "company"           ) or
       ( keyvalues["shop"]       == "office"            ) or
       ( keyvalues["amenity"]    == "office"            ) or
       ( keyvalues["office"]     == "yes"               ) or
       ( keyvalues["commercial"] == "office"            )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["office"]  = "nonspecific"
   end

-- ----------------------------------------------------------------------------
-- Similarly, various government offices.  Job Centres first.
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"]   == "job_centre"              ) or
       ( keyvalues["amenity"]   == "jobcentre"               ) or
       ( keyvalues["name"]      == "Jobcentre Plus"          ) or
       ( keyvalues["name"]      == "JobCentre Plus"          ) or
       ( keyvalues["name"]      == "Job Centre Plus"         ) or
       ( keyvalues["office"]    == "government"              ) or
       ( keyvalues["amenity"]   == "public_building"         ) or
       ( keyvalues["office"]    == "administrative"          ) or
       ( keyvalues["office"]    == "register"                ) or
       ( keyvalues["amenity"]   == "register_office"         ) or
       ( keyvalues["office"]    == "drainage_board"          ) or
       ( keyvalues["office"]    == "council"                 ) or
       ( keyvalues["amenity"]   == "courthouse"              ) or
       ( keyvalues["amenity"]   == "townhall"                ) or
       ( keyvalues["amenity"]   == "village_hall"            ) or
       ( keyvalues["building"]  == "village_hall"            ) or
       ( keyvalues["amenity"]   == "crematorium"             ) or
       ( keyvalues["amenity"]   == "hall"                    ) or
       ( keyvalues["amenity"]   == "ambulance_station"       ) or
       ( keyvalues["emergency"] == "ambulance_station"       ) or
       ( keyvalues["amenity"]   == "fire_station"            ) or
       ( keyvalues["emergency"] == "fire_station"            ) or
       ( keyvalues["amenity"]   == "lifeboat_station"        ) or
       ( keyvalues["emergency"] == "lifeboat_station"        ) or
       ( keyvalues["emergency"] == "lifeboat_base"           ) or
       ( keyvalues["amenity"]   == "coast_guard"             ) or
       ( keyvalues["amenity"]   == "archive"                 )) then
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
       ( keyvalues["shop"]    == "legal"                   ) or
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
       ( keyvalues["shop"]    == "accountants"             ) or
       ( keyvalues["office"]  == "employment_agency"       ) or
       ( keyvalues["shop"]    == "employment_agency"       ) or
       ( keyvalues["shop"]    == "employment"              ) or
       ( keyvalues["shop"]    == "jobs"                    ) or
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
       ( keyvalues["office"]  == "parcel"                  ) or
       ( keyvalues["office"]  == "therapist"               ) or
       ( keyvalues["office"]  == "surveyor"                ) or
       ( keyvalues["office"]  == "marketing"               ) or
       ( keyvalues["office"]  == "graphic_design"          ) or
       ( keyvalues["office"]  == "interior_design"         ) or
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
       ( keyvalues["shop"]    == "heating"                 ) or
       ( keyvalues["office"]  == "laundry"                 ) or
       ( keyvalues["amenity"] == "telephone_exchange"      ) or
       ( keyvalues["amenity"] == "coworking_space"         ) or
       ( keyvalues["office"]  == "coworking"               ) or
       ( keyvalues["office"]  == "coworking_space"         ) or
       ( keyvalues["office"]  == "serviced_offices"        ) or
       ( keyvalues["amenity"] == "studio"                  ) or
       ( keyvalues["amenity"] == "prison"                  ) or
       ( keyvalues["amenity"] == "monastery"               ) or
       ( keyvalues["amenity"] == "convent"                 )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["office"] = "nonspecific"
   end

-- ----------------------------------------------------------------------------
-- Other nonspecific offices.  
-- ----------------------------------------------------------------------------
   if (( keyvalues["office"]   == "it"                      ) or
       ( keyvalues["office"]   == "ngo"                     ) or
       ( keyvalues["office"]   == "educational_institution" ) or
       ( keyvalues["office"]   == "educational"             ) or
       ( keyvalues["office"]   == "university"              ) or
       ( keyvalues["office"]   == "charity"                 ) or
       ( keyvalues["amenity"]  == "education_centre"        ) or
       ( keyvalues["amenity"]  == "college"                 ) or
       ( keyvalues["man_made"] == "observatory"             ) or
       ( keyvalues["amenity"]  == "laboratory"              ) or
       ( keyvalues["amenity"]  == "medical_laboratory"      ) or
       ( keyvalues["amenity"]  == "research_institute"      ) or
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
--
-- Note - this is an old tag that was for the whole area (building etc.) of
-- a swimming pool.  It corresponds best with "leisure=sports_centre" 
-- (rendered in its own right).  "leisure=swimming_pool" is for the wet bit;
-- that is also rendered in its own right (in blue).
-- Note there's no explicit "if private" check on the wet bit.
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "swimming_pool" ) and
       ( keyvalues["access"]  ~= "private"       )) then
      keyvalues["leisure"] = "nonspecific"
   end

-- ----------------------------------------------------------------------------
-- Render outdoor swimming areas with blue names (if named)
-- leisure=pool is eithr a turkish bath, a hot spring or a private 
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
-- A counple of odd sports taggings:
-- ----------------------------------------------------------------------------
   if ( keyvalues["leisure"] == "sport" ) then
      if ( keyvalues["sport"]   == "golf"  ) then
         keyvalues["leisure"] = "golf_course"
      else
         keyvalues["leisure"] = "nonspecific"
      end
   end

-- ----------------------------------------------------------------------------
-- Other nonspecific leisure.  Add an icon and label via "nonspecific".
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"]  == "events_venue"         ) or
       ( keyvalues["amenity"]  == "conference_centre"    ) or
       ( keyvalues["amenity"]  == "exhibition_centre"    ) or
       ( keyvalues["amenity"]  == "function_room"        ) or
       ( keyvalues["amenity"]  == "arts_centre"          ) or
       ( keyvalues["amenity"]  == "community_hall"       ) or
       ( keyvalues["amenity"]  == "church_hall"          ) or
       ( keyvalues["amenity"]  == "community_centre"     ) or
       ( keyvalues["building"] == "community_centre"     ) or
       ( keyvalues["amenity"]  == "dojo"                 ) or
       ( keyvalues["leisure"]  == "indoor_play"          ) or
       ( keyvalues["amenity"]  == "youth_club"           ) or
       ( keyvalues["amenity"]  == "youth_centre"         ) or
       ( keyvalues["amenity"]  == "social_club"          ) or
       ( keyvalues["leisure"]  == "social_club"          ) or
       ( keyvalues["amenity"]  == "working_mens_club"    ) or
       ( keyvalues["amenity"]  == "social_centre"        ) or
       ( keyvalues["amenity"]  == "club"                 ) or
       ( keyvalues["amenity"]  == "gym"                  ) or
       ( keyvalues["leisure"]  == "fitness_centre"       ) or
       ( keyvalues["shop"]     == "fitness"              ) or
       ( keyvalues["amenity"]  == "scout_hut"            ) or
       ( keyvalues["building"] == "scout_hut"            ) or
       ( keyvalues["name"]     == "Scout Hut"            ) or
       ( keyvalues["name"]     == "Scout hut"            ) or
       ( keyvalues["amenity"]  == "scout_hall"           ) or
       ( keyvalues["name"]     == "Scout Hall"           ) or
       ( keyvalues["amenity"]  == "scouts"               ) or
       ( keyvalues["club"]     == "scout"                ) or
       ( keyvalues["club"]     == "sport"                ) or
       ( keyvalues["amenity"]  == "clubhouse"            ) or
       ( keyvalues["building"] == "clubhouse"            ) or
       ( keyvalues["amenity"]  == "club_house"           ) or
       ( keyvalues["building"] == "club_house"           ) or
       ( keyvalues["amenity"]  == "dancing_school"       ) or
       ( keyvalues["leisure"]  == "club"                 ) or
       ( keyvalues["leisure"]  == "dance"                ) or
       ( keyvalues["leisure"]  == "climbing"             ) or
       ( keyvalues["leisure"]  == "high_ropes_course"    ) or
       ( keyvalues["leisure"]  == "bowling_alley"        ) or
       ( keyvalues["leisure"]  == "hackerspace"          ) or
       ( keyvalues["leisure"]  == "summer_camp"          ) or
       ( keyvalues["leisure"]  == "sailing_club"         ) or
       ( keyvalues["sport"]    == "model_Aerodrome"      ) or
       ( keyvalues["leisure"]  == "trampoline_park"      ) or
       ( keyvalues["leisure"]  == "trampoline"           ) or
       ( keyvalues["leisure"]  == "water_park"           ) or
       ( keyvalues["leisure"]  == "firepit"              ) or
       ( keyvalues["amenity"]  == "public_bath"          ) or
       ( keyvalues["amenity"]  == "brothel"              ) or
       ( keyvalues["amenity"]  == "sauna"                ) or
       ( keyvalues["leisure"]  == "sauna"                ) or
       ( keyvalues["leisure"]  == "horse_riding"         ) or
       ( keyvalues["leisure"]  == "miniature_golf"       ) or
       ( keyvalues["leisure"]  == "ice_rink"             ) or
       ( keyvalues["tourism"]  == "wilderness_hut"       ) or
       ( keyvalues["tourism"]  == "cabin"                ) or
       ( keyvalues["tourism"]  == "trail_riding_station" ) or
       ( keyvalues["tourism"]  == "resort"               ) or
       ( keyvalues["leisure"]  == "resort"               ) or
       ( keyvalues["leisure"]  == "beach_resort"         ) or
       (( keyvalues["building"] == "yes"                )  and
        ( keyvalues["amenity"]  == nil                  )  and
        ( keyvalues["sport"]    ~= nil                  ))) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["leisure"] = "nonspecific"
   end

-- ----------------------------------------------------------------------------
-- Emergency phones
-- ----------------------------------------------------------------------------
   if (( keyvalues["emergency"] == "phone" ) and
       ( keyvalues["amenity"]   == nil     )) then
      keyvalues["amenity"] = "emergency_phone"
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
-- Aerodrome size.
-- Large public airports should have an airport icon.  Others should not.
-- ----------------------------------------------------------------------------
   if (( keyvalues["aeroway"]        == "aerodrome" ) and
       ( keyvalues["iata"]           ~= nil         ) and
       ( keyvalues["aerodrome:type"] ~= "military"  ) and
       ( keyvalues["military"]       == nil         )) then
      keyvalues["aeroway"] = "large_aerodrome"
   end

-- ----------------------------------------------------------------------------
-- Grass runways
-- These are rendered less prominently.
-- ----------------------------------------------------------------------------
   if (( keyvalues["aeroway"] == "runway" ) and
       ( keyvalues["surface"] == "grass"  )) then
      keyvalues["aeroway"] = "grass_runway"
   end

-- ----------------------------------------------------------------------------
-- If a quarry is disused, it's still likely a hole in the ground, so render it
-- ----------------------------------------------------------------------------
   if (( keyvalues["disused:landuse"] == "quarry" ) and
       ( keyvalues["landuse"]         == nil      )) then
      keyvalues["landuse"] = "quarry"
   end

-- ----------------------------------------------------------------------------
-- Different names on each side of the street
-- ----------------------------------------------------------------------------
   if (( keyvalues["name:left"]  ~= nil ) and
       ( keyvalues["name:right"] ~= nil )) then
      keyvalues["name"] = keyvalues["name:left"] .. " / " .. keyvalues["name:right"]
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
-- If name does not exist but name:en does, use it.
-- ----------------------------------------------------------------------------
   if (( keyvalues["name"]    == nil ) and
       ( keyvalues["name:en"] ~= nil )) then
      keyvalues["name"] = keyvalues["name:en"]
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
   if (( keyvalues["man_made"]   == "tower"   ) and
       ( keyvalues["tower:type"] == "cooling" )) then
      keyvalues["man_made"] = "chimney"
   end

   if (( keyvalues["man_made"]   == "tower"        ) and
       ( keyvalues["tower:type"] == "illumination" )) then
      keyvalues["man_made"] = "illuminationtower"
   end

   if (( keyvalues["man_made"]   == "tower"     ) and
       ( keyvalues["tower:type"] == "defensive" )) then
      keyvalues["man_made"] = "defensivetower"
   end

   if (( keyvalues["man_made"]   == "tower"       ) and
       ( keyvalues["tower:type"] == "observation" )) then
      keyvalues["man_made"] = "observationtower"
   end

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

-- ----------------------------------------------------------------------------
-- man_made=water_tap
-- ----------------------------------------------------------------------------
   if (( keyvalues["man_made"] == "water_tap" ) and
       ( keyvalues["amenity"]  == nil         )) then
      keyvalues["amenity"] = "drinking_water"
   end
   
-- ----------------------------------------------------------------------------
-- Concatenate a couple of names for bus stops so that the most useful ones
-- are displayed.
-- ----------------------------------------------------------------------------
   if ( keyvalues["highway"] == "bus_stop" ) then
      if (( keyvalues["name"]             ~= nil ) and
          ( keyvalues["naptan:Indicator"] ~= nil )) then
         keyvalues["name"] = keyvalues["name"] .. " " .. keyvalues["naptan:Indicator"]
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
-- Names for vacant shops
-- ----------------------------------------------------------------------------
   if (((( keyvalues["disused:shop"]    ~= nil       )   or
         ( keyvalues["disused:amenity"] ~= nil       ))  and
         ( keyvalues["shop"]            == nil        )  and
         ( keyvalues["amenity"]         == nil        )) or
       (   keyvalues["shop"]            == "disused"   ) or
       (   keyvalues["shop"]            == "empty"     ) or
       (   keyvalues["shop"]            == "closed"    ) or
       (   keyvalues["shop"]            == "abandoned" )) then
      keyvalues["shop"] = "vacant"
   end

   if ( keyvalues["shop"] == "vacant" ) then
      if (( keyvalues["name"] == nil ) and
          ( keyvalues["ref"]  == nil )) then
         keyvalues["ref"] = "(vacant)"
      else
         if ( keyvalues["ref"] == nil ) then
            keyvalues["ref"] = "(vacant: " .. keyvalues["name"] .. ")"
            keyvalues["name"] = nil
	 end
      end
   end

-- ----------------------------------------------------------------------------
-- Remove public transport shelters (at least until I creat a sensible 
-- rendering for them)
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"]      == "shelter"          ) and
       ( keyvalues["shelter_type"] == "public_transport" )) then
      keyvalues["amenity"] = nil
   end

-- ----------------------------------------------------------------------------
-- Drop tourism=attraction if leisure=park
-- ----------------------------------------------------------------------------
   if (( keyvalues["tourism"] == "attraction" ) and
       ( keyvalues["leisure"] == "park"       )) then
      keyvalues["tourism"] = nil
   end

-- ----------------------------------------------------------------------------
-- Add the prow_ref for PRoWs in brackets, if it exists.
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"] == "footway"       ) or
       ( keyvalues["highway"] == "footwaywide"   ) or
       ( keyvalues["highway"] == "bridleway"     ) or
       ( keyvalues["highway"] == "bridlewaywide" )) then
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
-- Drop some highway areas.
-- "track" and "cycleway" etc. areas wherever I have seen them are garbage.
-- "footway" (pedestrian areas) and "service" (e.g. petrol station forecourts)
-- tend to be OK.  Other options tend not to occur.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["highway"] == "track"          )  or
        ( keyvalues["highway"] == "track_graded"   )  or
        ( keyvalues["highway"] == "cycleway"       )  or
        ( keyvalues["highway"] == "residential"    )  or
        ( keyvalues["highway"] == "unclassified"   )  or
        ( keyvalues["highway"] == "tertiary"       )) and
       (  keyvalues["area"]    == "yes"             )) then
      keyvalues["highway"] = "nil"
   end

   if (( keyvalues["area:highway"] == "traffic_island" )  or
       ( keyvalues["landuse"]      == "traffic_island" )) then
      keyvalues["barrier"] = "kerb"
   end

   if ( keyvalues["addr:unit"] ~= nil ) then
      if ( keyvalues["addr:housenumber"] ~= nil ) then
         keyvalues["addr:housenumber"] = keyvalues["addr:unit"] .. ", " .. keyvalues["addr:housenumber"]
      else
         keyvalues["addr:housenumber"] = keyvalues["addr:unit"]
      end
   end

-- ----------------------------------------------------------------------------
-- End of AJT generic additions.
-- ----------------------------------------------------------------------------

   return filter, keyvalues
end

function filter_tags_node (keyvalues, nokeys)

-- ----------------------------------------------------------------------------
-- AJT node-only additions.
-- ----------------------------------------------------------------------------
   if (( keyvalues["ford"]    == "yes"             ) or
       ( keyvalues["ford"]    == "stepping_stones" ) or
       ( keyvalues["barrier"] == "stepping_stones" ))then
      keyvalues["highway"] = "ford"
      keyvalues["ford"]    = nil
   end

-- ----------------------------------------------------------------------------
-- Map non-linear unknown (and some known) barriers to bollard
-- ----------------------------------------------------------------------------
   if (( keyvalues["barrier"] == "yes"            ) or
       ( keyvalues["barrier"] == "barrier"        ) or
       ( keyvalues["barrier"] == "tank_trap"      ) or
       ( keyvalues["barrier"] == "tank_traps"     ) or
       ( keyvalues["barrier"] == "dragons_teeth"  ) or
       ( keyvalues["barrier"] == "bollards"       ) or
       ( keyvalues["barrier"] == "bus_trap"       ) or
       ( keyvalues["barrier"] == "car_trap"       ) or
       ( keyvalues["barrier"] == "rising_bollard" ) or
       ( keyvalues["barrier"] == "steps"          ) or
       ( keyvalues["barrier"] == "step"           ) or
       ( keyvalues["barrier"] == "post"           ) or
       ( keyvalues["barrier"] == "stone"          ) or
       ( keyvalues["barrier"] == "hoarding"       ) or
       ( keyvalues["barrier"] == "sump_buster"    ) or
       ( keyvalues["barrier"] == "gate_pier"      ) or
       ( keyvalues["barrier"] == "gate_post"      ) or
       ( keyvalues["barrier"] == "pole"           )) then
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
-- End of AJT node-only additions.
-- ----------------------------------------------------------------------------

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

-- ----------------------------------------------------------------------------
-- AJT way-only additions.
--
-- "barrier=gate" on a way is a dark line; on bridleways it looks 
-- "sufficiently different" to mark fords out.
-- ----------------------------------------------------------------------------
   if (( keyvalues["ford"] == "yes"             ) or
       ( keyvalues["ford"] == "stepping_stones" ))then
      keyvalues["barrier"] = "ford"
   end

-- ----------------------------------------------------------------------------
-- Treat a linear "door" as "gate"
-- ----------------------------------------------------------------------------
   if (( keyvalues["barrier"] == "door"       ) or
       ( keyvalues["barrier"] == "swing_gate" )) then
      keyvalues["barrier"] = "gate"
   end

-- ----------------------------------------------------------------------------
-- Map linear tank traps, and some others, to wall
-- ----------------------------------------------------------------------------
   if (( keyvalues["barrier"] == "tank_trap"      ) or
       ( keyvalues["barrier"] == "tank_traps"     ) or
       ( keyvalues["barrier"] == "dragons_teeth"  ) or
       ( keyvalues["barrier"] == "obstruction"    ) or
       ( keyvalues["barrier"] == "sea_wall"       ) or
       ( keyvalues["barrier"] == "block"          ) or
       ( keyvalues["barrier"] == "haha"           ) or
       ( keyvalues["barrier"] == "ha-ha"          ) or
       ( keyvalues["barrier"] == "jersey_barrier" )) then
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
-- Note that we're not doing any per-member processing for routes - which just
-- add a highway type to the relation and ensure that the style rules for it
-- handle it sensibly, as it's going to be overlaid over other highway types.
-- "ldpnwn" is used to allow for future different processing of different 
-- relations.
-- ----------------------------------------------------------------------------
   if (type == "route") then
      if (( keyvalues["network"] == "nwn" ) or
          ( keyvalues["network"] == "rwn" ) or
          ( keyvalues["network"] == "lwn" )) then
         keyvalues["highway"] = "ldpnwn"
      end

      if (( keyvalues["network"] == "ncn" ) or
          ( keyvalues["network"] == "rcn" )) then
         keyvalues["highway"] = "ldpncn"

         if ( keyvalues["ref"] ~= "NB" ) then
            keyvalues["name"] = keyvalues["ref"]
         end
      end

      if ( keyvalues["network"] == "nhn" ) then
         keyvalues["highway"] = "ldpnhn"
      end
   end

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
