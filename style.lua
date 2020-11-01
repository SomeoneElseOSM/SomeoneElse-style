polygon_keys = { 'building', 'landcover', 'landuse', 'amenity', 'harbour', 'historic', 'leisure', 
      'man_made', 'military', 'natural', 'office', 'place', 'power',
      'public_transport', 'seamark:type', 'shop', 'sport', 'tourism', 'waterway',
      'wetland', 'water', 'aeroway' }

generic_keys = {'access','addr:housename','addr:housenumber','addr:interpolation','admin_level','advertising','aerialway','aeroway','amenity','area','barrier',
   'bicycle','brand','bridge','bridleway','booth','boundary','building','capital','construction','covered','culvert','cutting','denomination','designation','disused','disused:shop','ele',
   'embankment','emergency','foot','generation:source','golf','harbour','highway','historic','horse','hours','intermittent','junction','landcover','landuse','layer','leisure','lcn_ref','lock',
   'man_made','military','motor_car','name','natural','ncn_milepost','office','oneway','operator','opening_hours:covid19','place','playground','poi','population','power','power_source','public_transport','seamark:type',
   'railway','ref','religion','rescue_equipment','route','service','shop','sport','surface','toll','tourism','tower:type', 'tracktype','tunnel','water','waterway',
   'wetland','width','wood','type'}

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
-- Treat "was:" as "disused:"
-- ----------------------------------------------------------------------------
   if (( keyvalues["was:amenity"]     ~= nil ) and
       ( keyvalues["disused:amenity"] == nil )) then
      keyvalues["disused:amenity"] = keyvalues["was:amenity"]
   end

   if (( keyvalues["was:pub"]     ~= nil ) and
       ( keyvalues["disused:pub"] == nil )) then
      keyvalues["disused:pub"] = keyvalues["was:pub"]
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

   if ( keyvalues["highway"] ~= "track_graded" ) then
      keyvalues["tracktype"] = nil
   end

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
      keyvalues["highway"] = "path"
   end

-- ----------------------------------------------------------------------------
-- Different names on each side of the street
-- ----------------------------------------------------------------------------
   if (( keyvalues["name:left"]  ~= nil ) and
       ( keyvalues["name:right"] ~= nil )) then
      keyvalues["name"] = keyvalues["name:left"] .. " / " .. keyvalues["name:right"]
   end

-- ----------------------------------------------------------------------------
-- If name does not exist but name:en does, use it.
-- ----------------------------------------------------------------------------
   if (( keyvalues["name"]    == nil ) and
       ( keyvalues["name:en"] ~= nil )) then
      keyvalues["name"] = keyvalues["name:en"]
   end

-- ----------------------------------------------------------------------------
-- If lcn_ref exists, render it.
-- ----------------------------------------------------------------------------
   if (( keyvalues["lcn_ref"] ~= nil ) and
       ( keyvalues["ref"]     == nil )) then
      keyvalues["man_made"] = "lcn_ref"
      keyvalues["ref"]     = keyvalues["lcn_ref"]
      keyvalues["lcn_ref"] = nil
   end

-- ----------------------------------------------------------------------------
-- Move refs to consider as "official" to official_ref
-- ----------------------------------------------------------------------------
   if (( keyvalues["official_ref"]          == nil ) and
       ( keyvalues["highway_authority_ref"] ~= nil )) then
      keyvalues["official_ref"]          = keyvalues["highway_authority_ref"]
      keyvalues["highway_authority_ref"] = nil
   end

   if (( keyvalues["official_ref"] == nil ) and
       ( keyvalues["highway_ref"]  ~= nil )) then
      keyvalues["official_ref"] = keyvalues["highway_ref"]
      keyvalues["highway_ref"]  = nil
   end

   if (( keyvalues["official_ref"] == nil ) and
       ( keyvalues["admin_ref"]    ~= nil )) then
      keyvalues["official_ref"] = keyvalues["admin_ref"]
      keyvalues["admin_ref"]    = nil
   end

   if (( keyvalues["official_ref"] == nil ) and
       ( keyvalues["admin:ref"]    ~= nil )) then
      keyvalues["official_ref"] = keyvalues["admin:ref"]
      keyvalues["admin:ref"]    = nil
   end

   if (( keyvalues["official_ref"] == nil              ) and
       ( keyvalues["loc_ref"]      ~= nil              ) and
       ( keyvalues["loc_ref"]      ~= keyvalues["ref"] )) then
      keyvalues["official_ref"] = keyvalues["loc_ref"]
      keyvalues["loc_ref"]    = nil
   end

-- ----------------------------------------------------------------------------
-- Consolidate some rare highway types into track
--
-- The "bywayness" of something should be handled by designation now.  byway
-- isn't otherwise rendered (and really should no longer be used), so change 
-- to track (which is what it probably will be).
--
-- "gallop" makes sense as a tag (it really isn't like anything else), but for
-- rendering change to "track".  "unsurfaced" makes less sense; change to
-- "track" also.
--
-- "track" will be changed into something else lower down 
-- (path, pathwide or track_graded).
-- ----------------------------------------------------------------------------
   if ((  keyvalues["highway"] == "byway"       ) or
       (  keyvalues["highway"] == "gallop"      ) or
       (  keyvalues["highway"] == "unsurfaced"  ) or
       (( keyvalues["golf"]    == "track"      )  and
        ( keyvalues["highway"] == nil         ))) then
      keyvalues["highway"] = "track"
   end

   if ((( keyvalues["golf"]    == "path"      )  or
        ( keyvalues["golf"]    == "cartpath"  )) and
       (( keyvalues["highway"] == nil         )  or
        ( keyvalues["highway"] == "service"   ))) then
      keyvalues["highway"] = "pathnarrow"
   end

-- ----------------------------------------------------------------------------
-- Move unsigned road refs to the name, in brackets.
-- ----------------------------------------------------------------------------
   if (( keyvalues["highway"] == "motorway"          ) or
       ( keyvalues["highway"] == "motorway_link"     ) or
       ( keyvalues["highway"] == "trunk"             ) or
       ( keyvalues["highway"] == "trunk_link"        ) or
       ( keyvalues["highway"] == "primary"           ) or
       ( keyvalues["highway"] == "primary_link"      ) or
       ( keyvalues["highway"] == "secondary"         ) or
       ( keyvalues["highway"] == "secondary_link"    ) or
       ( keyvalues["highway"] == "tertiary"          ) or
       ( keyvalues["highway"] == "tertiary_link"     ) or
       ( keyvalues["highway"] == "unclassified"      ) or
       ( keyvalues["highway"] == "unclassified_link" ) or
       ( keyvalues["highway"] == "residential"       ) or
       ( keyvalues["highway"] == "residential_link"  ) or
       ( keyvalues["highway"] == "service"           ) or
       ( keyvalues["highway"] == "road"              ) or
       ( keyvalues["highway"] == "track"             ) or
       ( keyvalues["highway"] == "cycleway"          ) or
       ( keyvalues["highway"] == "bridleway"         ) or
       ( keyvalues["highway"] == "footway"           ) or
       ( keyvalues["highway"] == "intfootway"        ) or
       ( keyvalues["highway"] == "path"              ) or
       ( keyvalues["highway"] == "intpath"           )) then
      if ( keyvalues["name"] == nil   ) then
         if (( keyvalues["ref"]        ~= nil  ) and
             ( keyvalues["ref:signed"] == "no" )) then
            keyvalues["name"]       = "(" .. keyvalues["ref"] .. ")"
            keyvalues["ref"]        = nil
            keyvalues["ref:signed"] = nil
	 else
            if ( keyvalues["official_ref"] ~= nil  ) then
               keyvalues["name"]         = "(" .. keyvalues["official_ref"] .. ")"
               keyvalues["official_ref"] = nil
            end
         end
      else
         if (( keyvalues["name:signed"] == "no"   ) or
             ( keyvalues["unsigned"]    == "yes"  ) or
             ( keyvalues["unsigned"]    == "true" )) then
            keyvalues["name"] = "(" .. keyvalues["name"]
            keyvalues["name:signed"] = nil

            if ( keyvalues["ref:signed"] == "no" ) then
               keyvalues["name"]       = keyvalues["name"] .. ", " .. keyvalues["ref"]
               keyvalues["ref"]        = nil
               keyvalues["ref:signed"] = nil
            else
               if ( keyvalues["official_ref"] ~= nil  ) then
                  keyvalues["name"]         = keyvalues["name"] .. ", " .. keyvalues["official_ref"]
                  keyvalues["official_ref"] = nil
               end
            end

            keyvalues["name"] = keyvalues["name"] .. ")"
         else
            if (( keyvalues["ref"]        ~= nil  ) and
                ( keyvalues["ref:signed"] == "no" )) then
               keyvalues["name"]       = keyvalues["name"] .. " (" .. keyvalues["ref"] .. ")"
               keyvalues["ref"]        = nil
               keyvalues["ref:signed"] = nil
            else
               if ( keyvalues["official_ref"] ~= nil  ) then
                  keyvalues["name"]         = keyvalues["name"] .. " (" .. keyvalues["official_ref"] .. ")"
                  keyvalues["official_ref"] = nil
               end
            end
         end
      end
   end

-- ----------------------------------------------------------------------------
-- Rationalise the various trail_visibility values
-- Also treat "overgrown=yes" as intermittent.  A discussion on talk-gb was
-- largely inconclusive, but "overgrown" is the "most renderable" way to deal
-- with things like this.
-- ----------------------------------------------------------------------------
   if (( keyvalues["trail_visibility"] == "no"       )  or
       ( keyvalues["trail_visibility"] == "none"     )  or
       ( keyvalues["trail_visibility"] == "nil"      )  or
       ( keyvalues["trail_visibility"] == "horrible" )  or
       ( keyvalues["trail_visibility"] == "very_bad" )  or
       ( keyvalues["trail_visibility"] == "bad"      )  or
       ( keyvalues["trail_visibility"] == "poor"     )) then
      keyvalues["trail_visibility"] = "bad"
   end

   if (( keyvalues["trail_visibility"] == "intermittent" )  or
       ( keyvalues["trail_visibility"] == "intermediate" )  or
       ( keyvalues["overgrown"]        == "yes"          )) then
      keyvalues["trail_visibility"] = "intermediate"
   end

-- ----------------------------------------------------------------------------
-- Supress non-designated very low-visibility paths
-- Various low-visibility trail_visibility values have been set to "bad" above.
-- ----------------------------------------------------------------------------
   if (( keyvalues["designation"]      == nil   ) and
       ( keyvalues["trail_visibility"] == "bad" )) then
      keyvalues["highway"] = nil
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
      if (( keyvalues["width"] == "2"   ) or
          ( keyvalues["width"] == "2.5" ) or
          ( keyvalues["width"] == "3"   ) or
          ( keyvalues["width"] == "4"   )) then
         if (( keyvalues["trail_visibility"] == "bad"          )  or
             ( keyvalues["trail_visibility"] == "intermediate" )) then
            keyvalues["highway"] = "intpathwide"
         else
            keyvalues["highway"] = "pathwide"
         end
      else
         if (( keyvalues["trail_visibility"] == "bad"          )  or
             ( keyvalues["trail_visibility"] == "intermediate" )) then
            keyvalues["highway"] = "intpath"
         else
            keyvalues["highway"] = "pathnarrow"
         end
      end
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
-- Consolidate various prow_ref variants
-- ----------------------------------------------------------------------------
   if (( keyvalues["prow:ref"] ~= nil ) and
       ( keyvalues["prow_ref"] == nil )) then
      keyvalues["prow_ref"] = keyvalues["prow:ref"]
      keyvalues["prow:ref"] = nil
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
-- "track_graded" is a means of getting to the renderer without going through
-- this code again.
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
       ( keyvalues["designation"] == "public_road"                                    )) then
      if (( keyvalues["highway"] == "steps"      ) or 
	  ( keyvalues["highway"] == "intpath"    ) or
	  ( keyvalues["highway"] == "pathnarrow" )) then
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
       ( keyvalues["designation"] == "byway"                     )) then
      if (( keyvalues["highway"] == "steps"      ) or 
	  ( keyvalues["highway"] == "intpath"    ) or
	  ( keyvalues["highway"] == "pathnarrow" )) then
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
       ( keyvalues["designation"] == "orpa"                                    )) then
      if (( keyvalues["highway"] == "steps"      ) or 
	  ( keyvalues["highway"] == "intpath"    ) or
	  ( keyvalues["highway"] == "pathnarrow" )) then
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
      if (( keyvalues["highway"] == "intpath"    ) or
	  ( keyvalues["highway"] == "pathnarrow" )) then
         if (( keyvalues["trail_visibility"] == "bad"          )  or
             ( keyvalues["trail_visibility"] == "intermediate" )) then
            keyvalues["highway"] = "intbridleway"
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
-- ----------------------------------------------------------------------------
   if (( keyvalues["designation"] == "public_footpath"                        ) or
       ( keyvalues["designation"] == "core_path"                              ) or 
       ( keyvalues["designation"] == "public_footway"                         ) or 
       ( keyvalues["designation"] == "public_footpath;permissive_bridleway"   ) or 
       ( keyvalues["designation"] == "public_footpath;public_cycleway"        )) then
      if (( keyvalues["highway"] == "intpath"    ) or
          ( keyvalues["highway"] == "pathnarrow" )) then
         if (( keyvalues["trail_visibility"] == "bad"          )  or
             ( keyvalues["trail_visibility"] == "intermediate" )) then
            keyvalues["highway"] = "intfootway"
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
          ( keyvalues["highway"]     == "intpath"                   )    or
          ( keyvalues["highway"]     == "intpathwide"               )    or
          ( keyvalues["highway"]     == "service"                   ))   and
         (( keyvalues["foot"]        == "permissive"                )    or
          ( keyvalues["foot"]        == "yes"                       ))))) then
      keyvalues["access"]  = nil
   end

-- ----------------------------------------------------------------------------
-- Render national parks and AONBs as such no matter how they are tagged.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["boundary"]      == "protected_area"                      ) and
       (( keyvalues["designation"]   == "national_park"                      )  or 
        ( keyvalues["designation"]   == "area_of_outstanding_natural_beauty" )  or
        ( keyvalues["designation"]   == "Area of Outstanding Natural Beauty" )  or
        ( keyvalues["protect_class"] == "5"                                  ))) then
      keyvalues["boundary"] = "national_park"
   end

-- ----------------------------------------------------------------------------
-- Render Access land the same as nature reserve / national park currently is
-- ----------------------------------------------------------------------------
   if ((   keyvalues["designation"]   == "access_land"                ) or
       ((  keyvalues["boundary"]      == "protected_area"            )  and
        (( keyvalues["protect_class"] == "1"                        )   or
         ( keyvalues["protect_class"] == "4"                        )   or
         ( keyvalues["designation"]   == "national_nature_reserve"  )   or
         ( keyvalues["designation"]   == "local_nature_reserve"     )   or
         ( keyvalues["designation"]   == "Nature Reserve"           )   or
         ( keyvalues["designation"]   == "Marine Conservation Zone" )))) then
      keyvalues["leisure"] = "nature_reserve"
   end

-- ----------------------------------------------------------------------------
-- Render various synonyms for leisure=common.
-- ----------------------------------------------------------------------------
   if (( keyvalues["landuse"]          == "common"   ) or
       ( keyvalues["designation"]      == "common"   ) or
       ( keyvalues["amenity"]          == "common"   ) or
       ( keyvalues["protection_title"] == "common"   )) then
      keyvalues["leisure"] = "common"
      keyvalues["amenity"] = nil
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
          ( keyvalues["shoulder"] == "both"           ) or
          ( keyvalues["shoulder"] == "left"           ) or 
          ( keyvalues["shoulder"] == "right"          ) or 
          ( keyvalues["shoulder"] == "yes"            ) or
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
          ( keyvalues["shoulder"] == "both"           ) or
          ( keyvalues["shoulder"] == "left"           ) or 
          ( keyvalues["shoulder"] == "right"          ) or 
          ( keyvalues["shoulder"] == "yes"            ) or
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
          ( keyvalues["shoulder"] == "both"           ) or
          ( keyvalues["shoulder"] == "left"           ) or 
          ( keyvalues["shoulder"] == "right"          ) or 
          ( keyvalues["shoulder"] == "yes"            ) or
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
          ( keyvalues["shoulder"] == "both"           ) or
          ( keyvalues["shoulder"] == "left"           ) or 
          ( keyvalues["shoulder"] == "right"          ) or 
          ( keyvalues["shoulder"] == "yes"            ) or
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
   if (( keyvalues["highway"]    == "tertiary_sidewalk"  )  and
       (( keyvalues["width"]     == "2"                 )   or
        ( keyvalues["width"]     == "3"                 )   or
        ( keyvalues["maxwidth"]  == "2"                 )   or
        ( keyvalues["maxwidth"]  == "3"                 ))) then
      keyvalues["highway"] = "unclassified_sidewalk"
   end

   if (( keyvalues["highway"]    == "tertiary_verge"  )  and
       (( keyvalues["width"]     == "2"              )   or
        ( keyvalues["width"]     == "3"              )   or
        ( keyvalues["maxwidth"]  == "2"              )   or
        ( keyvalues["maxwidth"]  == "3"              ))) then
      keyvalues["highway"] = "unclassified_verge"
   end

   if (( keyvalues["highway"]    == "tertiary"   )  and
       (( keyvalues["width"]     == "2"         )   or
        ( keyvalues["width"]     == "3"         )   or
        ( keyvalues["maxwidth"]  == "2"         )   or
        ( keyvalues["maxwidth"]  == "3"         ))) then
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
-- Also farmyard "bunker silos" and canopies, and natural arches.
-- Also railway traversers.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["man_made"]         == "bridge"        ) or
       (  keyvalues["natural"]          == "arch"          ) or
       (  keyvalues["man_made"]         == "bunker_silo"   ) or
       (  keyvalues["amenity"]          == "feeding_place" ) or
       (  keyvalues["railway"]          == "traverser"     ) or
       (  keyvalues["animal"]           == "horse_walker"  ) or
       (  keyvalues["building"]         == "canopy"        ) or
       (( keyvalues["disused:building"] ~= nil            )  and
        ( keyvalues["building"]         == nil            )) or
       (  keyvalues["building:type"] == "canopy"           )) then
      keyvalues["building"]      = "roof"
      keyvalues["building:type"] = nil
   end

-- ----------------------------------------------------------------------------
-- Render windmill buildings and former windmills as windmills.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["building"] == "windmill"        )  or
        ( keyvalues["building"] == "former_windmill" )) and
       (  keyvalues["amenity"]  == nil                )) then
      keyvalues["man_made"] = "windmill"
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
       ( keyvalues["tunnel"] == "flooded"             )) then
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
-- Remove name from footway=sidewalk (we expect it to be rendered via the
-- road that this is a sidewalk for).
-- ----------------------------------------------------------------------------
   if (( keyvalues["footway"] == "sidewalk" ) and
       ( keyvalues["name"]    ~= nil        )) then
      keyvalues["name"] = nil
   end

-- ----------------------------------------------------------------------------
-- Recycling bins and recycling centres.
-- Recycling bins are only shown from z19.  Recycling centres are shown from
-- z16 and have a characteristic icon.  Any object without recycling_type
-- is assumed to be a bin.
-- ----------------------------------------------------------------------------
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
-- Electricity substations
-- ----------------------------------------------------------------------------
   if (( keyvalues["power"] == "substation"  )  or
       ( keyvalues["power"] == "sub_station" )) then
      keyvalues["power"]   = nil
      keyvalues["landuse"] = "industrial"
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
   if ( keyvalues["man_made"]   == "wastewater_plant"       ) then
      keyvalues["man_made"] = nil
      keyvalues["landuse"] = "industrial"
      if ( keyvalues["name"] == nil ) then
         keyvalues["name"] = "(sewage)"
      else
         keyvalues["name"] = keyvalues["name"] .. " (sewage)"
      end
   end

   if (( keyvalues["man_made"]   == "reservoir_covered"      ) or 
       ( keyvalues["man_made"]   == "petroleum_well"         ) or 
       ( keyvalues["industrial"] == "warehouse"              ) or
       ( keyvalues["building"]   == "warehouse"              ) or
       ( keyvalues["industrial"] == "brewery"                ) or 
       ( keyvalues["industrial"] == "distillery"             ) or 
       ( keyvalues["craft"]      == "distillery"             ) or
       ( keyvalues["craft"]      == "bakery"                 ) or
       ( keyvalues["craft"]      == "sawmill"                ) or
       ( keyvalues["industrial"] == "sawmill"                ) or
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
-- Handle natural=cape
-- ----------------------------------------------------------------------------
   if ( keyvalues["natural"] == "cape" ) then
      keyvalues["place"] = "locality"
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
-- Boundary stones.  If they're already tagged as tourism=attraction, remove
-- that tag.
-- ----------------------------------------------------------------------------
   if (( keyvalues["historic"] == "boundary_stone"  )  or
       ( keyvalues["historic"] == "boundary_marker" )  or
       ( keyvalues["historic"] == "boundary_post"   )  or
       ( keyvalues["marker"]   == "boundary_stone"  )  or
       ( keyvalues["historic"] == "standing_stone"  )  or
       ( keyvalues["boundary"] == "marker"          )) then
      keyvalues["man_made"] = "boundary_stone"
      keyvalues["tourism"]  = nil
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
       (  keyvalues["man_made"]        == "telephone_box"   )  or
       (  keyvalues["building"]        == "telephone_kiosk" )  or
       (  keyvalues["building"]        == "telephone_box"   )  or
       (  keyvalues["historic"]        == "telephone"       )  or
       (  keyvalues["disused:amenity"] == "telephone"       )) then
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
                        if ( keyvalues["tourism"] == "artwork" ) then
                           keyvalues["amenity"] = "boothartwork"
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
   end
   
-- ----------------------------------------------------------------------------
-- Mappings to shop=car
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "car;car_repair"  )  or
       ( keyvalues["shop"]    == "car;bicycle"     )  or
       ( keyvalues["shop"]    == "cars"            )  or
       ( keyvalues["shop"]    == "car_showroom"    )  or
       ( keyvalues["shop"]    == "vehicle"         )) then
      keyvalues["shop"] = "car"
   end

-- ----------------------------------------------------------------------------
-- Mappings to shop=bicycle
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"] == "bicycle_repair"   ) or
       ( keyvalues["shop"] == "electric_bicycle" )) then
      keyvalues["shop"] = "bicycle"
   end

-- ----------------------------------------------------------------------------
-- Map amenity=car_repair etc. to shop=car_repair
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "car_repair"         )  or
       ( keyvalues["craft"]   == "car_repair"         )  or
       ( keyvalues["craft"]   == "coachbuilder"       )  or
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
-- Map various diplomatic things to embassy.
-- Pedants may claim that some of these aren't legally embassies, and they'd
-- be correct, but I use the same icon for all of these currently.
-- ----------------------------------------------------------------------------
   if (( keyvalues["diplomatic"] == "embassy"            ) or
       ( keyvalues["diplomatic"] == "consulate"          ) or
       ( keyvalues["diplomatic"] == "consulate_general"  ) or
       ( keyvalues["diplomatic"] == "honorary_consulate" ) or
       ( keyvalues["diplomatic"] == "high_commission"    )) then
      keyvalues["amenity"] = "embassy"
   end

   if (( keyvalues["diplomatic"] == "permanent_mission"     ) or
       ( keyvalues["diplomatic"] == "ambassadors_residence" ) or
       ( keyvalues["diplomatic"] == "trade_delegation"      )) then
      if ( keyvalues["amenity"] == "embassy" ) then
         keyvalues["amenity"] = nil
      end
      keyvalues["office"] = "yes"
   end

-- ----------------------------------------------------------------------------
-- Things that are both viewpoints or attractions and monuments or memorials 
-- should render as the latter.
-- Also handle some other combinations.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["tourism"]   == "viewpoint"     )  or
        ( keyvalues["tourism"]   == "attraction"    )) and
       (( keyvalues["historic"]  == "memorial"      )  or
        ( keyvalues["historic"]  == "monument"      )  or
        ( keyvalues["natural"]   == "tree"          )  or
        ( keyvalues["leisure"]   == "park"          ))) then
      keyvalues["tourism"] = nil
   end

-- ----------------------------------------------------------------------------
-- Shops etc. with icons already - just add "unnamedcommercial" landuse.
-- The exception is where landuse is set to something we want to keep.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["shop"]       ~= nil                 )  or
        ( keyvalues["amenity"]    ~= nil                 )  or
        ( keyvalues["tourism"]    == "hotel"             )  or
        ( keyvalues["tourism"]    == "guest_house"       )  or
        ( keyvalues["tourism"]    == "attraction"        )  or
        ( keyvalues["tourism"]    == "viewpoint"         )  or
        ( keyvalues["tourism"]    == "museum"            )  or
        ( keyvalues["tourism"]    == "hostel"            )  or
        ( keyvalues["tourism"]    == "gallery"           )  or
        ( keyvalues["tourism"]    == "apartment"         )  or
        ( keyvalues["tourism"]    == "bed_and_breakfast" )  or
        ( keyvalues["tourism"]    == "zoo"               )  or
        ( keyvalues["tourism"]    == "motel"             )  or
        ( keyvalues["tourism"]    == "theme_park"        )) and
       (  keyvalues["landuse"]    ~= "meadow"             ) and
       (  keyvalues["landuse"]    ~= "village_green"      ) and
       (  keyvalues["landuse"]    ~= "cemetery"           ) and
       (  keyvalues["leisure"]    ~= "garden"             )) then
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
-- Show skate parks etc. (that aren't skate shops) as pitches.
-- ----------------------------------------------------------------------------
   if (( keyvalues["sport"] == "skateboard" ) and
       ( keyvalues["shop"]  == nil          )) then
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
-- Various tags for showgrounds
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "showground"       )  or
       ( keyvalues["leisure"] == "showground"       )  or
       ( keyvalues["amenity"] == "show_ground"      )  or
       ( keyvalues["amenity"] == "show_grounds"     )  or
       ( keyvalues["amenity"] == "festival_grounds" )  or
       ( keyvalues["amenity"] == "car_boot_sale"    )) then
      keyvalues["amenity"] = nil
      keyvalues["leisure"] = nil
      keyvalues["landuse"] = "meadow"
   end

-- ----------------------------------------------------------------------------
-- Some kinds of farmland and meadow should be changed to "landuse=farmgrass", 
-- which is rendered slightly greener than the normal farmland (and less green 
-- than landuse=meadow)
-- ----------------------------------------------------------------------------
   if ((  keyvalues["landuse"]  == "farmland"         ) and
       (( keyvalues["farmland"] == "pasture"         )  or
        ( keyvalues["farmland"] == "paddock"         )  or
        ( keyvalues["farmland"] == "turf_production" )  or
        ( keyvalues["farmland"] == "meadow"          )  or
        ( keyvalues["farmland"] == "diary"           )  or
        ( keyvalues["farmland"] == "animal_keeping"  )  or
        ( keyvalues["animal"]   == "cow"             )  or
        ( keyvalues["animal"]   == "cattle"          )  or
        ( keyvalues["animal"]   == "chicken"         )  or
        ( keyvalues["animal"]   == "horse"           ))) then
      keyvalues["landuse"] = "farmgrass"
   end

   if ((  keyvalues["landuse"] == "meadow"        ) and
       (( keyvalues["meadow"]  == "agricultural" )  or
        ( keyvalues["meadow"]  == "paddock"      )  or
        ( keyvalues["meadow"]  == "pasture"      )  or
        ( keyvalues["meadow"]  == "agriculture"  )  or
        ( keyvalues["meadow"]  == "hay"          )  or
        ( keyvalues["meadow"]  == "managed"      )  or
        ( keyvalues["meadow"]  == "cut"          )  or
        ( keyvalues["animal"]  == "pig"          )  or
        ( keyvalues["animal"]  == "sheep"        )  or
        ( keyvalues["animal"]  == "cattle"       )  or
        ( keyvalues["animal"]  == "chicken"      )  or
        ( keyvalues["animal"]  == "horse"        ))) then
      keyvalues["landuse"] = "farmgrass"
   end

   if (( keyvalues["landuse"] == "paddock"        ) or
       ( keyvalues["landuse"] == "animal_keeping" )) then
      keyvalues["landuse"] = "farmgrass"
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

  if ((( keyvalues["landuse"]   == "forest" )  and
       ( keyvalues["leaf_type"] ~= nil      )) or
      (  keyvalues["natural"]   == "forest"  ) or
      (  keyvalues["landuse"]   == "wood"    ) or
      (  keyvalues["landcover"] == "trees"   )) then
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
-- Treat landcover=grass as landuse=grass
-- Also landuse=college_court
-- ----------------------------------------------------------------------------
   if (( keyvalues["landcover"] == "grass"         ) or
       ( keyvalues["landuse"]   == "college_court" )) then
      keyvalues["landcover"] = nil
      keyvalues["landuse"] = "grass"
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
-- Handle mistagged pubs
-- ----------------------------------------------------------------------------
   if ( keyvalues["tourism"]  == "pub;hotel" ) then
      keyvalues["amenity"] = "pub"
      keyvalues["tourism"] = nil
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
      if (( keyvalues["tourism"]   == "hotel"       ) or
          ( keyvalues["tourism"]   == "guest_house" )) then
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

   if (( keyvalues["leisure"]     == "outdoor_seating" ) and
       ( keyvalues["beer_garden"] == "yes"             )) then
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

   if ((  keyvalues["amenity"]           == "closed_pub"      )   or
       (  keyvalues["amenity"]           == "dead_pub"        )   or
       (  keyvalues["amenity"]           == "disused_pub"     )   or
       (  keyvalues["amenity"]           == "former_pub"      )   or
       (  keyvalues["amenity"]           == "old_pub"         )   or
       (( keyvalues["amenity"]           == "pub"            )    and
        ( keyvalues["disused"]           == "yes"            ))) then
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
        ( keyvalues["office"]            ~= nil     ))) then
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
-- Live or dead pub?  y or n
-- Real ale?          y n or d (for don't know)
-- Food 	      y or d
-- Noncarpeted floor  y or d
-- Microbrewery	      y n or d
-- Micropub	      y n or d
-- Accommodation      y n or d
-- ----------------------------------------------------------------------------
   if (( keyvalues["description:floor"] ~= nil                ) or
       ( keyvalues["floor:material"]    == "tiles"            ) or
       ( keyvalues["floor:material"]    == "stone"            ) or
       ( keyvalues["floor:material"]    == "lino"             ) or
       ( keyvalues["floor:material"]    == "slate"            ) or
       ( keyvalues["floor:material"]    == "brick"            ) or
       ( keyvalues["floor:material"]    == "rough_wood"       ) or
       ( keyvalues["floor:material"]    == "rough wood"       ) or
       ( keyvalues["floor:material"]    == "concrete"         ) or
       ( keyvalues["floor:material"]    == "lino;tiles;stone" )) then
      keyvalues["noncarpeted"] = "yes"
   end

   if (( keyvalues["micropub"] == "yes"   ) or
       ( keyvalues["pub"]      == "micro" )) then
      keyvalues["micropub"] = nil
      keyvalues["pub"]      = "micropub"
   end

-- ----------------------------------------------------------------------------
-- The misspelling "accomodation" is quite common.
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
        ( keyvalues["opening_hours:covid19"] == "Mu-Su off" ) or
        ( keyvalues["access:covid19"]        == "no"        ))) then
      keyvalues["amenity"] = "pub_cddddddd"
      keyvalues["real_ale"] = nil
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
               if (( keyvalues["accommodation"] ~= nil  ) and
                   ( keyvalues["accommodation"] ~= "no" )) then
                  keyvalues["amenity"] = "pub_yyyyydy"
	       else
                  keyvalues["amenity"] = "pub_yyyyydn"
	       end
            else
	       if ( keyvalues["pub"] == "micropub" ) then
                  keyvalues["amenity"] = "pub_yyyynyd"
               else
                  if (( keyvalues["accommodation"] ~= nil  ) and
                      ( keyvalues["accommodation"] ~= "no" )) then
		     if ( keyvalues["beer_garden"] == "yes" ) then
		        if ( keyvalues["wheelchair"] == "yes" ) then
                           keyvalues["amenity"] = "pub_yyyynnyyg"
		        else
		           if ( keyvalues["wheelchair"] == "limited" ) then
                              keyvalues["amenity"] = "pub_yyyynnylg"
			   else
			      if ( keyvalues["wheelchair"] == "no" ) then
                                 keyvalues["amenity"] = "pub_yyyynnyng"
			      else
                                 keyvalues["amenity"] = "pub_yyyynnydg"
			      end
			   end
		        end
		     else
		        if ( keyvalues["outdoor_seating"] == "yes" ) then
		           if ( keyvalues["wheelchair"] == "yes" ) then
                              keyvalues["amenity"] = "pub_yyyynnyyo"
		           else
		              if ( keyvalues["wheelchair"] == "limited" ) then
                                 keyvalues["amenity"] = "pub_yyyynnylo"
			      else
			         if ( keyvalues["wheelchair"] == "no" ) then
                                    keyvalues["amenity"] = "pub_yyyynnyno"
			         else
                                    keyvalues["amenity"] = "pub_yyyynnydo"
			         end
			      end
		           end
			else
		           if ( keyvalues["wheelchair"] == "yes" ) then
                              keyvalues["amenity"] = "pub_yyyynnyyd"
		           else
		              if ( keyvalues["wheelchair"] == "limited" ) then
                                 keyvalues["amenity"] = "pub_yyyynnyld"
			      else
			         if ( keyvalues["wheelchair"] == "no" ) then
                                    keyvalues["amenity"] = "pub_yyyynnynd"
			         else
                                    keyvalues["amenity"] = "pub_yyyynnydd"
			         end
			      end
			   end
			end
		     end
		  else
		     if ( keyvalues["beer_garden"] == "yes" ) then
		        if ( keyvalues["wheelchair"] == "yes" ) then
                           keyvalues["amenity"] = "pub_yyyynnnyg"
		        else
		           if ( keyvalues["wheelchair"] == "limited" ) then
                              keyvalues["amenity"] = "pub_yyyynnnlg"
			   else
			      if ( keyvalues["wheelchair"] == "no" ) then
                                 keyvalues["amenity"] = "pub_yyyynnnng"
			      else
                                 keyvalues["amenity"] = "pub_yyyynnndg"
			      end
			   end
		        end
		     else
		        if ( keyvalues["outdoor_seating"] == "yes" ) then
		           if ( keyvalues["wheelchair"] == "yes" ) then
                              keyvalues["amenity"] = "pub_yyyynnnyo"
		           else
		              if ( keyvalues["wheelchair"] == "limited" ) then
                                 keyvalues["amenity"] = "pub_yyyynnnlo"
			      else
			         if ( keyvalues["wheelchair"] == "no" ) then
                                    keyvalues["amenity"] = "pub_yyyynnnno"
			         else
                                    keyvalues["amenity"] = "pub_yyyynnndo"
			         end
			      end
		           end
			else
		           if ( keyvalues["wheelchair"] == "yes" ) then
                              keyvalues["amenity"] = "pub_yyyynnnyd"
		           else
		              if ( keyvalues["wheelchair"] == "limited" ) then
                                 keyvalues["amenity"] = "pub_yyyynnnld"
			      else
			         if ( keyvalues["wheelchair"] == "no" ) then
                                    keyvalues["amenity"] = "pub_yyyynnnnd"
			         else
                                    keyvalues["amenity"] = "pub_yyyynnndd"
			         end
			      end
			   end
			end
		     end
		  end
               end
	    end
         else
            if ( keyvalues["microbrewery"] == "yes"  ) then
               if (( keyvalues["accommodation"] ~= nil  ) and
                   ( keyvalues["accommodation"] ~= "no" )) then
                  keyvalues["amenity"] = "pub_yyydydy"
	       else
                  keyvalues["amenity"] = "pub_yyydydn"
	       end
	    else
	       if ( keyvalues["pub"] == "micropub" ) then
                  keyvalues["amenity"] = "pub_yyydnyd"
               else
                  if (( keyvalues["accommodation"] ~= nil  ) and
                      ( keyvalues["accommodation"] ~= "no" )) then
		     if ( keyvalues["beer_garden"] == "yes" ) then
		        if ( keyvalues["wheelchair"] == "yes" ) then
                           keyvalues["amenity"] = "pub_yyydnnyyg"
		        else
		           if ( keyvalues["wheelchair"] == "limited" ) then
                              keyvalues["amenity"] = "pub_yyydnnylg"
			   else
			      if ( keyvalues["wheelchair"] == "no" ) then
                                 keyvalues["amenity"] = "pub_yyydnnyng"
			      else
                                 keyvalues["amenity"] = "pub_yyydnnydg"
			      end
			   end
		        end
		     else
		        if ( keyvalues["outdoor_seating"] == "yes" ) then
		           if ( keyvalues["wheelchair"] == "yes" ) then
                              keyvalues["amenity"] = "pub_yyydnnyyo"
		           else
		              if ( keyvalues["wheelchair"] == "limited" ) then
                                 keyvalues["amenity"] = "pub_yyydnnylo"
			      else
			         if ( keyvalues["wheelchair"] == "no" ) then
                                    keyvalues["amenity"] = "pub_yyydnnyno"
			         else
                                    keyvalues["amenity"] = "pub_yyydnnydo"
			         end
			      end
		           end
			else
		           if ( keyvalues["wheelchair"] == "yes" ) then
                              keyvalues["amenity"] = "pub_yyydnnyyd"
		           else
		              if ( keyvalues["wheelchair"] == "limited" ) then
                                 keyvalues["amenity"] = "pub_yyydnnyld"
			      else
			         if ( keyvalues["wheelchair"] == "no" ) then
                                    keyvalues["amenity"] = "pub_yyydnnynd"
			         else
                                    keyvalues["amenity"] = "pub_yyydnnydd"
			         end
			      end
			   end
			end
		     end
		  else
		     if ( keyvalues["beer_garden"] == "yes" ) then
		        if ( keyvalues["wheelchair"] == "yes" ) then
                           keyvalues["amenity"] = "pub_yyydnnnyg"
		        else
		           if ( keyvalues["wheelchair"] == "limited" ) then
                              keyvalues["amenity"] = "pub_yyydnnnlg"
			   else
			      if ( keyvalues["wheelchair"] == "no" ) then
                                 keyvalues["amenity"] = "pub_yyydnnnng"
			      else
                                 keyvalues["amenity"] = "pub_yyydnnndg"
			      end
			   end
		        end
		     else
		        if ( keyvalues["outdoor_seating"] == "yes" ) then
		           if ( keyvalues["wheelchair"] == "yes" ) then
                              keyvalues["amenity"] = "pub_yyydnnnyo"
		           else
		              if ( keyvalues["wheelchair"] == "limited" ) then
                                 keyvalues["amenity"] = "pub_yyydnnnlo"
			      else
			         if ( keyvalues["wheelchair"] == "no" ) then
                                    keyvalues["amenity"] = "pub_yyydnnnno"
			         else
                                    keyvalues["amenity"] = "pub_yyydnnndo"
			         end
			      end
		           end
			else
		           if ( keyvalues["wheelchair"] == "yes" ) then
                              keyvalues["amenity"] = "pub_yyydnnnyd"
		           else
		              if ( keyvalues["wheelchair"] == "limited" ) then
                                 keyvalues["amenity"] = "pub_yyydnnnld"
			      else
			         if ( keyvalues["wheelchair"] == "no" ) then
                                    keyvalues["amenity"] = "pub_yyydnnnnd"
			         else
                                    keyvalues["amenity"] = "pub_yyydnnndd"
			         end
			      end
			   end
			end
		     end
		  end
               end
	    end
         end
      else
         if ( keyvalues["noncarpeted"] == "yes"  ) then
            if ( keyvalues["microbrewery"] == "yes"  ) then
               if (( keyvalues["accommodation"] ~= nil  ) and
                   ( keyvalues["accommodation"] ~= "no" )) then
	          if ( keyvalues["wheelchair"] == "yes" ) then
                     keyvalues["amenity"] = "pub_yydyydyy"
     		  else
	             if ( keyvalues["wheelchair"] == "limited" ) then
                        keyvalues["amenity"] = "pub_yydyydyl"
		     else
		        if ( keyvalues["wheelchair"] == "no" ) then
                           keyvalues["amenity"] = "pub_yydyydyn"
		        else
                           keyvalues["amenity"] = "pub_yydyydyd"
		        end
		     end
	          end
	       else
	          if ( keyvalues["wheelchair"] == "yes" ) then
                     keyvalues["amenity"] = "pub_yydyydny"
     		  else
	             if ( keyvalues["wheelchair"] == "limited" ) then
                        keyvalues["amenity"] = "pub_yydyydnl"
		     else
		        if ( keyvalues["wheelchair"] == "no" ) then
                           keyvalues["amenity"] = "pub_yydyydnn"
		        else
                           keyvalues["amenity"] = "pub_yydyydnd"
		        end
		     end
	          end
	       end
	    else
	       if ( keyvalues["pub"] == "micropub" ) then
		  if ( keyvalues["wheelchair"] == "yes" ) then
                     keyvalues["amenity"] = "pub_yydynydy"
		  else
		     if ( keyvalues["wheelchair"] == "limited" ) then
                        keyvalues["amenity"] = "pub_yydynydl"
	             else
			if ( keyvalues["wheelchair"] == "no" ) then
                           keyvalues["amenity"] = "pub_yydynydn"
			else
                           keyvalues["amenity"] = "pub_yydynydd"
			end
	             end
		  end
	       else
                  if (( keyvalues["accommodation"] ~= nil  ) and
                      ( keyvalues["accommodation"] ~= "no" )) then
		     if ( keyvalues["beer_garden"] == "yes" ) then
		        if ( keyvalues["wheelchair"] == "yes" ) then
                           keyvalues["amenity"] = "pub_yydynnyyg"
		        else
		           if ( keyvalues["wheelchair"] == "limited" ) then
                              keyvalues["amenity"] = "pub_yydynnylg"
			   else
			      if ( keyvalues["wheelchair"] == "no" ) then
                                 keyvalues["amenity"] = "pub_yydynnyng"
			      else
                                 keyvalues["amenity"] = "pub_yydynnydg"
			      end
			   end
		        end
		     else
		        if ( keyvalues["outdoor_seating"] == "yes" ) then
		           if ( keyvalues["wheelchair"] == "yes" ) then
                              keyvalues["amenity"] = "pub_yydynnyyo"
		           else
		              if ( keyvalues["wheelchair"] == "limited" ) then
                                 keyvalues["amenity"] = "pub_yydynnylo"
			      else
			         if ( keyvalues["wheelchair"] == "no" ) then
                                    keyvalues["amenity"] = "pub_yydynnyno"
			         else
                                    keyvalues["amenity"] = "pub_yydynnydo"
			         end
			      end
		           end
			else
		           if ( keyvalues["wheelchair"] == "yes" ) then
                              keyvalues["amenity"] = "pub_yydynnyyd"
		           else
		              if ( keyvalues["wheelchair"] == "limited" ) then
                                 keyvalues["amenity"] = "pub_yydynnyld"
			      else
			         if ( keyvalues["wheelchair"] == "no" ) then
                                    keyvalues["amenity"] = "pub_yydynnynd"
			         else
                                    keyvalues["amenity"] = "pub_yydynnydd"
			         end
			      end
			   end
			end
		     end
		  else
		     if ( keyvalues["beer_garden"] == "yes" ) then
		        if ( keyvalues["wheelchair"] == "yes" ) then
                           keyvalues["amenity"] = "pub_yydynnnyg"
		        else
		           if ( keyvalues["wheelchair"] == "limited" ) then
                              keyvalues["amenity"] = "pub_yydynnnlg"
			   else
			      if ( keyvalues["wheelchair"] == "no" ) then
                                 keyvalues["amenity"] = "pub_yydynnnng"
			      else
                                 keyvalues["amenity"] = "pub_yydynnndg"
			      end
			   end
		        end
		     else
		        if ( keyvalues["outdoor_seating"] == "yes" ) then
		           if ( keyvalues["wheelchair"] == "yes" ) then
                              keyvalues["amenity"] = "pub_yydynnnyo"
		           else
		              if ( keyvalues["wheelchair"] == "limited" ) then
                                 keyvalues["amenity"] = "pub_yydynnnlo"
			      else
			         if ( keyvalues["wheelchair"] == "no" ) then
                                    keyvalues["amenity"] = "pub_yydynnnno"
			         else
                                    keyvalues["amenity"] = "pub_yydynnndo"
			         end
			      end
		           end
			else
		           if ( keyvalues["wheelchair"] == "yes" ) then
                              keyvalues["amenity"] = "pub_yydynnnyd"
		           else
		              if ( keyvalues["wheelchair"] == "limited" ) then
                                 keyvalues["amenity"] = "pub_yydynnnld"
			      else
			         if ( keyvalues["wheelchair"] == "no" ) then
                                    keyvalues["amenity"] = "pub_yydynnnnd"
			         else
                                    keyvalues["amenity"] = "pub_yydynnndd"
			         end
			      end
			   end
			end
		     end
		  end
	       end
	    end
         else
            if ( keyvalues["microbrewery"] == "yes"  ) then
	       if ( keyvalues["beer_garden"] == "yes" ) then
	          if ( keyvalues["wheelchair"] == "yes" ) then
                     keyvalues["amenity"] = "pub_yyddyddyg"
		  else
		     if ( keyvalues["wheelchair"] == "limited" ) then
                        keyvalues["amenity"] = "pub_yyddyddlg"
		     else
		        if ( keyvalues["wheelchair"] == "no" ) then
                           keyvalues["amenity"] = "pub_yyddyddng"
			else
                           keyvalues["amenity"] = "pub_yyddydddg"
			end
		     end
	          end
	       else
	          if ( keyvalues["outdoor_seating"] == "yes" ) then
	             if ( keyvalues["wheelchair"] == "yes" ) then
                        keyvalues["amenity"] = "pub_yyddyddyo"
	             else
	                if ( keyvalues["wheelchair"] == "limited" ) then
                           keyvalues["amenity"] = "pub_yyddyddlo"
	                else
		           if ( keyvalues["wheelchair"] == "no" ) then
                              keyvalues["amenity"] = "pub_yyddyddno"
			   else
                              keyvalues["amenity"] = "pub_yyddydddo"
			   end
			end
		     end
		  else
		     if ( keyvalues["wheelchair"] == "yes" ) then
                        keyvalues["amenity"] = "pub_yyddyddyd"
		     else
		        if ( keyvalues["wheelchair"] == "limited" ) then
                           keyvalues["amenity"] = "pub_yyddyddld"
		        else
		           if ( keyvalues["wheelchair"] == "no" ) then
                              keyvalues["amenity"] = "pub_yyddyddnd"
		           else
                              keyvalues["amenity"] = "pub_yyddydddd"
			   end
			end
		     end
		  end
	       end
	    else
	       if ( keyvalues["pub"] == "micropub" ) then
		  if ( keyvalues["wheelchair"] == "yes" ) then
                     keyvalues["amenity"] = "pub_yyddnydy"
		  else
		     if ( keyvalues["wheelchair"] == "limited" ) then
                        keyvalues["amenity"] = "pub_yyddnydl"
		     else
			if ( keyvalues["wheelchair"] == "no" ) then
                           keyvalues["amenity"] = "pub_yyddnydn"
			else
                           keyvalues["amenity"] = "pub_yyddnydd"
			end
		     end
		  end
               else
                  if (( keyvalues["accommodation"] ~= nil  ) and
                      ( keyvalues["accommodation"] ~= "no" )) then
		     if ( keyvalues["beer_garden"] == "yes" ) then
		        if ( keyvalues["wheelchair"] == "yes" ) then
                           keyvalues["amenity"] = "pub_yyddnnyyg"
		        else
		           if ( keyvalues["wheelchair"] == "limited" ) then
                              keyvalues["amenity"] = "pub_yyddnnylg"
			   else
			      if ( keyvalues["wheelchair"] == "no" ) then
                                 keyvalues["amenity"] = "pub_yyddnnyng"
			      else
                                 keyvalues["amenity"] = "pub_yyddnnydg"
			      end
			   end
		        end
		     else
		        if ( keyvalues["outdoor_seating"] == "yes" ) then
		           if ( keyvalues["wheelchair"] == "yes" ) then
                              keyvalues["amenity"] = "pub_yyddnnyyo"
		           else
		              if ( keyvalues["wheelchair"] == "limited" ) then
                                 keyvalues["amenity"] = "pub_yyddnnylo"
			      else
			         if ( keyvalues["wheelchair"] == "no" ) then
                                    keyvalues["amenity"] = "pub_yyddnnyno"
			         else
                                    keyvalues["amenity"] = "pub_yyddnnydo"
			         end
			      end
		           end
			else
		           if ( keyvalues["wheelchair"] == "yes" ) then
                              keyvalues["amenity"] = "pub_yyddnnyyd"
		           else
		              if ( keyvalues["wheelchair"] == "limited" ) then
                                 keyvalues["amenity"] = "pub_yyddnnyld"
			      else
			         if ( keyvalues["wheelchair"] == "no" ) then
                                    keyvalues["amenity"] = "pub_yyddnnynd"
			         else
                                    keyvalues["amenity"] = "pub_yyddnnydd"
			         end
			      end
			   end
			end
		     end
		  else
		     if ( keyvalues["beer_garden"] == "yes" ) then
		        if ( keyvalues["wheelchair"] == "yes" ) then
                           keyvalues["amenity"] = "pub_yyddnnnyg"
		        else
		           if ( keyvalues["wheelchair"] == "limited" ) then
                              keyvalues["amenity"] = "pub_yyddnnnlg"
			   else
			      if ( keyvalues["wheelchair"] == "no" ) then
                                 keyvalues["amenity"] = "pub_yyddnnnng"
			      else
                                 keyvalues["amenity"] = "pub_yyddnnndg"
			      end
			   end
		        end
		     else
		        if ( keyvalues["outdoor_seating"] == "yes" ) then
		           if ( keyvalues["wheelchair"] == "yes" ) then
                              keyvalues["amenity"] = "pub_yyddnnnyo"
		           else
		              if ( keyvalues["wheelchair"] == "limited" ) then
                                 keyvalues["amenity"] = "pub_yyddnnnlo"
			      else
			         if ( keyvalues["wheelchair"] == "no" ) then
                                    keyvalues["amenity"] = "pub_yyddnnnno"
			         else
                                    keyvalues["amenity"] = "pub_yyddnnndo"
			         end
			      end
		           end
			else
		           if ( keyvalues["wheelchair"] == "yes" ) then
                              keyvalues["amenity"] = "pub_yyddnnnyd"
		           else
		              if ( keyvalues["wheelchair"] == "limited" ) then
                                 keyvalues["amenity"] = "pub_yyddnnnld"
			      else
			         if ( keyvalues["wheelchair"] == "no" ) then
                                    keyvalues["amenity"] = "pub_yyddnnnnd"
			         else
                                    keyvalues["amenity"] = "pub_yyddnnndd"
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
   end

   if (( keyvalues["real_ale"] == "no" ) and
       ( keyvalues["amenity"] == "pub" )) then
      if (( keyvalues["food"] ~= nil  ) and
          ( keyvalues["food"] ~= "no" )) then
         if ( keyvalues["noncarpeted"] == "yes"  ) then
            if ( keyvalues["wheelchair"] == "yes" ) then
               keyvalues["amenity"] = "pub_ynyydddy"
	    else
	       if ( keyvalues["wheelchair"] == "limited" ) then
                  keyvalues["amenity"] = "pub_ynyydddl"
	       else
	          if ( keyvalues["wheelchair"] == "no" ) then
                     keyvalues["amenity"] = "pub_ynyydddn"
		  else
                     keyvalues["amenity"] = "pub_ynyydddd"
	          end
	       end
	    end
         else
            if (( keyvalues["accommodation"] ~= nil  ) and
                ( keyvalues["accommodation"] ~= "no" )) then
               keyvalues["amenity"] = "pub_ynydddy"
	    else
               if ( keyvalues["wheelchair"] == "yes" ) then
                  keyvalues["amenity"] = "pub_ynydddny"
	       else
	          if ( keyvalues["wheelchair"] == "limited" ) then
                     keyvalues["amenity"] = "pub_ynydddnl"
	          else
	             if ( keyvalues["wheelchair"] == "no" ) then
                        keyvalues["amenity"] = "pub_ynydddnn"
		     else
                        keyvalues["amenity"] = "pub_ynydddnd"
	             end
	          end
	       end
	    end
         end
      else
         if ( keyvalues["noncarpeted"] == "yes"  ) then
            if (( keyvalues["accommodation"] ~= nil  ) and
                ( keyvalues["accommodation"] ~= "no" )) then
               if ( keyvalues["wheelchair"] == "yes" ) then
                  keyvalues["amenity"] = "pub_yndyddyy"
	       else
	          if ( keyvalues["wheelchair"] == "limited" ) then
                     keyvalues["amenity"] = "pub_yndyddyl"
	          else
	             if ( keyvalues["wheelchair"] == "no" ) then
                        keyvalues["amenity"] = "pub_yndyddyn"
		     else
                        keyvalues["amenity"] = "pub_yndyddyd"
	             end
	          end
	       end
	    else
	       if ( keyvalues["beer_garden"] == "yes" ) then
		  if ( keyvalues["wheelchair"] == "yes" ) then
                     keyvalues["amenity"] = "pub_yndyddnyg"
		  else
		     if ( keyvalues["wheelchair"] == "limited" ) then
                        keyvalues["amenity"] = "pub_yndyddnlg"
		     else
			if ( keyvalues["wheelchair"] == "no" ) then
                           keyvalues["amenity"] = "pub_yndyddnng"
			else
                           keyvalues["amenity"] = "pub_yndyddndg"
			end
		     end
		  end
	       else
		  if ( keyvalues["outdoor_seating"] == "yes" ) then
		     if ( keyvalues["wheelchair"] == "yes" ) then
                        keyvalues["amenity"] = "pub_yndyddnyo"
		     else
		        if ( keyvalues["wheelchair"] == "limited" ) then
                           keyvalues["amenity"] = "pub_yndyddnlo"
		        else
		           if ( keyvalues["wheelchair"] == "no" ) then
                              keyvalues["amenity"] = "pub_yndyddnno"
			   else
                              keyvalues["amenity"] = "pub_yndyddndo"
			   end
			end
		     end
		  else
		     if ( keyvalues["wheelchair"] == "yes" ) then
                        keyvalues["amenity"] = "pub_yndyddnyd"
		     else
		        if ( keyvalues["wheelchair"] == "limited" ) then
                           keyvalues["amenity"] = "pub_yndyddnld"
		        else
		           if ( keyvalues["wheelchair"] == "no" ) then
                              keyvalues["amenity"] = "pub_yndyddnnd"
		           else
                              keyvalues["amenity"] = "pub_yndyddndd"
		           end
		        end
		     end
		  end
	       end
	    end
         else
            if (( keyvalues["accommodation"] ~= nil  ) and
                ( keyvalues["accommodation"] ~= "no" )) then
               keyvalues["amenity"] = "pub_ynddddy"
	    else
               if ( keyvalues["wheelchair"] == "yes" ) then
                  keyvalues["amenity"] = "pub_ynddddny"
	       else
	          if ( keyvalues["wheelchair"] == "limited" ) then
                     keyvalues["amenity"] = "pub_ynddddnl"
	          else
	             if ( keyvalues["wheelchair"] == "no" ) then
                        keyvalues["amenity"] = "pub_ynddddnn"
		     else
                        keyvalues["amenity"] = "pub_ynddddnd"
	             end
	          end
	       end
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
	    else
               keyvalues["amenity"] = "pub_ydyyndd"
	    end
         else
            if ( keyvalues["microbrewery"] == "yes"  ) then
               keyvalues["amenity"] = "pub_ydydydd"
	    else
	       if ( keyvalues["pub"] == "micropub" ) then
                  keyvalues["amenity"] = "pub_ydydnyd"
	       else
                  if (( keyvalues["accommodation"] ~= nil  ) and
                      ( keyvalues["accommodation"] ~= "no" )) then
                     if ( keyvalues["wheelchair"] == "yes" ) then
                        keyvalues["amenity"] = "pub_ydydnnyy"
	             else
	                if ( keyvalues["wheelchair"] == "limited" ) then
                           keyvalues["amenity"] = "pub_ydydnnyl"
	                else
	                   if ( keyvalues["wheelchair"] == "no" ) then
                              keyvalues["amenity"] = "pub_ydydnnyn"
		           else
                              keyvalues["amenity"] = "pub_ydydnnyd"
	                   end
	                end
	             end
		  else
                     if ( keyvalues["wheelchair"] == "yes" ) then
                        keyvalues["amenity"] = "pub_ydydnnny"
	             else
	                if ( keyvalues["wheelchair"] == "limited" ) then
                           keyvalues["amenity"] = "pub_ydydnnnl"
	                else
	                   if ( keyvalues["wheelchair"] == "no" ) then
                              keyvalues["amenity"] = "pub_ydydnnnn"
		           else
                              keyvalues["amenity"] = "pub_ydydnnnd"
	                   end
	                end
	             end
		  end
	       end
	    end
         end
      else
         if ( keyvalues["noncarpeted"] == "yes"  ) then
            if ( keyvalues["microbrewery"] == "yes"  ) then
               if (( keyvalues["accommodation"] ~= nil  ) and
                   ( keyvalues["accommodation"] ~= "no" )) then
                  keyvalues["amenity"] = "pub_yddyydy"
	       else
                  keyvalues["amenity"] = "pub_yddyydn"
	       end
	    else
	       if ( keyvalues["pub"] == "micropub" ) then
                  keyvalues["amenity"] = "pub_yddynyd"
	       else
                  keyvalues["amenity"] = "pub_yddynnd"
	       end
	    end
	 else
            if ( keyvalues["microbrewery"] == "yes"  ) then
               if (( keyvalues["accommodation"] ~= nil  ) and
                   ( keyvalues["accommodation"] ~= "no" )) then
                  keyvalues["amenity"] = "pub_ydddydy"
               else
                  if ( keyvalues["wheelchair"] == "yes" ) then
                     keyvalues["amenity"] = "pub_ydddydny"
                  else
                     if ( keyvalues["wheelchair"] == "limited" ) then
                        keyvalues["amenity"] = "pub_ydddydnl"
                     else
                        if ( keyvalues["wheelchair"] == "no" ) then
                           keyvalues["amenity"] = "pub_ydddydnn"
                        else
                           keyvalues["amenity"] = "pub_ydddydnd"
                        end
                     end
                  end
               end
            else
	       if ( keyvalues["pub"] == "micropub" ) then
                  if ( keyvalues["wheelchair"] == "yes" ) then
                     keyvalues["amenity"] = "pub_ydddnydy"
                  else
                     if ( keyvalues["wheelchair"] == "limited" ) then
                        keyvalues["amenity"] = "pub_ydddnydl"
                     else
                        if ( keyvalues["wheelchair"] == "no" ) then
                           keyvalues["amenity"] = "pub_ydddnydn"
                        else
                           keyvalues["amenity"] = "pub_ydddnydd"
                        end
                     end
                  end
               else
                  if (( keyvalues["accommodation"] ~= nil  ) and
                      ( keyvalues["accommodation"] ~= "no" )) then
                     if ( keyvalues["wheelchair"] == "yes" ) then
                        keyvalues["amenity"] = "pub_ydddnnyy"
	             else
	                if ( keyvalues["wheelchair"] == "limited" ) then
                           keyvalues["amenity"] = "pub_ydddnnyl"
	                else
	                   if ( keyvalues["wheelchair"] == "no" ) then
                              keyvalues["amenity"] = "pub_ydddnnyn"
		           else
                              keyvalues["amenity"] = "pub_ydddnnyd"
	                   end
	                end
	             end
		  else
		     if ( keyvalues["beer_garden"] == "yes" ) then
		        if ( keyvalues["wheelchair"] == "yes" ) then
                           keyvalues["amenity"] = "pub_ydddnnnyg"
		        else
		           if ( keyvalues["wheelchair"] == "limited" ) then
                              keyvalues["amenity"] = "pub_ydddnnnlg"
			   else
			      if ( keyvalues["wheelchair"] == "no" ) then
                                 keyvalues["amenity"] = "pub_ydddnnnng"
			      else
                                 keyvalues["amenity"] = "pub_ydddnnndg"
			      end
			   end
		        end
		     else
		        if ( keyvalues["outdoor_seating"] == "yes" ) then
		           if ( keyvalues["wheelchair"] == "yes" ) then
                              keyvalues["amenity"] = "pub_ydddnnnyo"
		           else
		              if ( keyvalues["wheelchair"] == "limited" ) then
                                 keyvalues["amenity"] = "pub_ydddnnnlo"
			      else
			         if ( keyvalues["wheelchair"] == "no" ) then
                                    keyvalues["amenity"] = "pub_ydddnnnno"
			         else
                                    keyvalues["amenity"] = "pub_ydddnnndo"
			         end
			      end
		           end
			else
		           if ( keyvalues["wheelchair"] == "yes" ) then
                              keyvalues["amenity"] = "pub_ydddnnnyd"
		           else
		              if ( keyvalues["wheelchair"] == "limited" ) then
                                 keyvalues["amenity"] = "pub_ydddnnnld"
			      else
			         if ( keyvalues["wheelchair"] == "no" ) then
                                    keyvalues["amenity"] = "pub_ydddnnnnd"
			         else
                                    keyvalues["amenity"] = "pub_ydddnnndd"
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
   end


-- ----------------------------------------------------------------------------
-- Render unnamed amenity=biergarten as gardens, which is all they likely are.
-- ----------------------------------------------------------------------------
   if ((  keyvalues["amenity"] == "biergarten"   )  and
       (( keyvalues["name"]    == nil           )   or
        ( keyvalues["name"]    == "Beer Garden" ))) then
      keyvalues["amenity"] = nil
      keyvalues["leisure"] = "garden"
      keyvalues["garden"]  = "beer_garden"
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
            keyvalues["amenity"] = "cafe_yy"
         else
            if ( keyvalues["wheelchair"] == "limited" ) then
               keyvalues["amenity"] = "cafe_yl"
	    else
	       if ( keyvalues["wheelchair"] == "no" ) then
                  keyvalues["amenity"] = "cafe_yn"
	       else
                  keyvalues["amenity"] = "cafe_yd"
	       end
	    end
         end
      else
         if ( keyvalues["wheelchair"] == "yes" ) then
            keyvalues["amenity"] = "cafe_dy"
         else
            if ( keyvalues["wheelchair"] == "limited" ) then
               keyvalues["amenity"] = "cafe_dl"
	    else
	       if ( keyvalues["wheelchair"] == "no" ) then
                  keyvalues["amenity"] = "cafe_dn"
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
            keyvalues["amenity"] = "bar_yy"
         else
            if ( keyvalues["wheelchair"] == "limited" ) then
               keyvalues["amenity"] = "bar_yl"
	    else
	       if ( keyvalues["wheelchair"] == "no" ) then
                  keyvalues["amenity"] = "bar_yn"
	       else
                  keyvalues["amenity"] = "bar_yd"
	       end
	    end
         end
      else
         if ( keyvalues["wheelchair"] == "yes" ) then
            keyvalues["amenity"] = "bar_dy"
         else
            if ( keyvalues["wheelchair"] == "limited" ) then
               keyvalues["amenity"] = "bar_dl"
	    else
	       if ( keyvalues["wheelchair"] == "no" ) then
                  keyvalues["amenity"] = "bar_dn"
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
   if (( keyvalues["amenity"] == "doctors; pharmacy"       ) or
       ( keyvalues["amenity"] == "doctors;social_facility" ) or
       ( keyvalues["amenity"] == "surgery"                 ) or
       ( keyvalues["amenity"] == "general_practitioner"    ) or
       ( keyvalues["amenity"] == "doctor"                  )) then
      keyvalues["amenity"] = "doctors"
   end

   if (( keyvalues["healthcare"] == "dentist" ) and
       ( keyvalues["amenity"]    == nil       )) then
      keyvalues["amenity"] = "dentist"
   end

   if (( keyvalues["healthcare"] == "hospital" ) and
       ( keyvalues["amenity"]    == nil        )) then
      keyvalues["amenity"] = "hospital"
   end

-- ----------------------------------------------------------------------------
-- If something is mapped both as a supermarket and a pharmacy, suppress the
-- tags for the latter.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "supermarket" ) and
       ( keyvalues["amenity"] == "pharmacy"    )) then
      keyvalues["amenity"] = nil
   end

   if ((  keyvalues["amenity"]    == "pharmacy, doctors, dentist"  ) or
       (( keyvalues["healthcare"] == "pharmacy"                   )  and
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
-- Public bookcases are displayed as a small L, except for those in phone
-- boxes
-- ----------------------------------------------------------------------------
   if ( keyvalues["amenity"] == "book_exchange" ) then
      keyvalues["amenity"] = "public_bookcase"
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
-- Other vending machines have their own icon
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "vending_machine" ) and
       ( keyvalues["vending"] == "excrement_bags"  )) then
      keyvalues["amenity"]  = "vending_excrement"
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
-- Render for-pay toilets differently.
-- Also use different icons for male and female, if these are separate.
-- ----------------------------------------------------------------------------
   if ( keyvalues["amenity"] == "toilets" ) then
      if (( keyvalues["fee"]     ~= nil       )  and
          ( keyvalues["fee"]     ~= "no"      )  and
          ( keyvalues["fee"]     ~= "No"      )  and
          ( keyvalues["fee"]     ~= "none"    )  and
          ( keyvalues["fee"]     ~= "None"    )  and
          ( keyvalues["fee"]     ~= "Free"    )  and
          ( keyvalues["fee"]     ~= "free"    )  and
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
-- Render parking spaces as parking.  Most in the UK are not part of larger
-- parking areas, and most do not have an access tag, but many should have.
-- ----------------------------------------------------------------------------
   if ( keyvalues["amenity"] == "parking_space" ) then
      keyvalues["amenity"] = "parking"

      if ( keyvalues["access"] == nil  ) then
         keyvalues["access"] = "no"
      end
   end


-- ----------------------------------------------------------------------------
-- Render amenity=leisure_centre as leisure=sports_centre
-- ----------------------------------------------------------------------------
   if ( keyvalues["amenity"] == "leisure_centre" ) then
      keyvalues["leisure"] = "sports_centre"
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
      keyvalues["name"] = keyvalues["ref"]
   end

   if ( keyvalues["golf"] == "green" ) then
      keyvalues["leisure"] = "golfgreen"
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
      keyvalues["highway"] = "pathnarrow"
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
-- Playground stuff
-- ----------------------------------------------------------------------------
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

   if (( keyvalues["leisure"]    == nil             )  and
       ( keyvalues["playground"] == "slide" )) then
      keyvalues["amenity"] = "playground_slide"
   end

   if (( keyvalues["leisure"]    == nil             )  and
       ( keyvalues["playground"] == "springy" )) then
      keyvalues["amenity"] = "playground_springy"
   end

   if (( keyvalues["leisure"]    == nil             )  and
       ( keyvalues["playground"] == "zipwire" )) then
      keyvalues["amenity"] = "playground_zipwire"
   end

   if (( keyvalues["leisure"]    == nil             )  and
       ( keyvalues["playground"] == "seesaw" )) then
      keyvalues["amenity"] = "playground_seesaw"
   end

   if (( keyvalues["leisure"]    == nil             )  and
       ( keyvalues["playground"] == "roundabout" )) then
      keyvalues["amenity"] = "playground_roundabout"
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
       (  keyvalues["natural"]      == "waterfall"     ) or
       (  keyvalues["water"]        == "waterfall"     ) or
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
-- man_made=spillway tends to be used on areas, hence show as natural=water.
-- ----------------------------------------------------------------------------
   if ((   keyvalues["waterway"] == "leat"        )  or
       (   keyvalues["waterway"] == "spillway"    )  or
       (   keyvalues["waterway"] == "aqueduct"    )  or
       (   keyvalues["waterway"] == "fish_pass"   )  or
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
-- Display "location=underground" waterways as tunnels.
-- ----------------------------------------------------------------------------
   if (( keyvalues["waterway"] ~= nil           )  and
       ( keyvalues["location"] == "underground" ) and
       ( keyvalues["tunnel"]   == nil           )) then
      keyvalues["tunnel"] = "yes"
   end

-- ----------------------------------------------------------------------------
-- Display pipelines
-- ----------------------------------------------------------------------------
   if ( keyvalues["man_made"] == "pipeline" ) then
      keyvalues["man_made"] = nil
      keyvalues["waterway"] = "pipeline"
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
       ( keyvalues["man_made"]   == "lighthouse"       ) or
       ( keyvalues["man_made"]   == "telescope"        ) or
       ( keyvalues["man_made"]   == "radio_telescope"  ) or
       ( keyvalues["man_made"]   == "street_cabinet"   ) or
       ( keyvalues["man_made"]   == "aeroplane"        ) or
       ( keyvalues["man_made"]   == "helicopter"       )) then
      keyvalues["building"] = "yes"
   end

-- ----------------------------------------------------------------------------
-- building=ruins is rendered as a half-dark building.
-- The wiki tries to guide building=ruins towards follies only but ruins=yes
-- "not a folly but falling down".  That doesn't match what mappers do but 
-- render both as half-dark.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["building"]        ~= nil         )   and
        ( keyvalues["ruins"]           == "yes"       ))  or
       (  keyvalues["ruins:building"]  == "yes"        )  or
       (  keyvalues["building:ruins"]  == "yes"        )  or
       (  keyvalues["ruined:building"] == "yes"        )  or
       (  keyvalues["building"]        == "collapsed"  )) then
      keyvalues["building"] = "ruins"
   end
   
-- ----------------------------------------------------------------------------
-- Map man_made=monument to historic=monument (handled below) if no better tag
-- exists.
-- Also handle geoglyphs in this way.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["man_made"] == "monument" )  and
        ( keyvalues["tourism"]  == nil        )) or
       (  keyvalues["man_made"] == "geoglyph"  )) then
      keyvalues["historic"] = "monument"
      keyvalues["man_made"] = nil
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
-- First make sure that we treat historic ones as historic
-- ----------------------------------------------------------------------------
   if ((( keyvalues["man_made"] == "mine"       )  or
        ( keyvalues["man_made"] == "mineshaft"  )  or
        ( keyvalues["man_made"] == "mine_shaft" )) and
       (( keyvalues["historic"] == "yes"        )  or
        ( keyvalues["historic"] == "mine"       )  or
        ( keyvalues["historic"] == "mineshaft"  )  or
        ( keyvalues["historic"] == "mine_shaft" ))) then
      keyvalues["historic"] = "nonspecific"
      keyvalues["man_made"] = nil
      keyvalues["tourism"]  = nil
   end

-- ----------------------------------------------------------------------------
-- Then other spellings of mineshaft
-- ----------------------------------------------------------------------------
   if (( keyvalues["man_made"] == "mine"       )  or
       ( keyvalues["man_made"] == "mine_shaft" )) then
      keyvalues["man_made"] = "mineshaft"
   end

-- ----------------------------------------------------------------------------
-- Add a building tag to historic items that are likely buildings so that
-- buildings.mss can process it.  Some shouldn't assume buildings (e.g. "fort"
-- below).  Some use "roof" (which I use for "nearly a building" elsewhere).
-- It's sent through as "nonspecific".
-- "stone" has a building tag added because some are mapped as closed ways.
--
-- "historic=monument" is here rather than under e.g. obelisk because it's 
-- used for all sorts of features.
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
       ( keyvalues["historic"] == "roundhouse"         ) or
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
      keyvalues["tourism"] = nil
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
       ( keyvalues["historic"] == "mill"              ) or
       ( keyvalues["historic"] == "mound"             ) or
       ( keyvalues["historic"] == "manor"             ) or
       ( keyvalues["historic"] == "country_mansion"   ) or
       ( keyvalues["historic"] == "mansion"           ) or
       ( keyvalues["historic"] == "mansion;castle"    ) or
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
       ( keyvalues["historic"] == "city_gate"         ) or
       ( keyvalues["historic"] == "gate"              ) or
       ( keyvalues["historic"] == "pinfold"           ) or
       ( keyvalues["historic"] == "prison"            ) or
       ( keyvalues["historic"] == "theatre"           ) or
       ( keyvalues["historic"] == "shelter"           ) or
       ( keyvalues["historic"] == "grave"             ) or
       ( keyvalues["historic"] == "grave_yard"        ) or
       ( keyvalues["historic"] == "statue"            ) or
       ( keyvalues["historic"] == "cross"             ) or
       ( keyvalues["historic"] == "market_cross"      ) or
       ( keyvalues["historic"] == "stocks"            ) or
       ( keyvalues["historic"] == "folly"             ) or
       ( keyvalues["historic"] == "drinking_fountain" ) or
       ( keyvalues["historic"] == "mine_adit"         ) or
       ( keyvalues["historic"] == "mine"              ) or
       ( keyvalues["historic"] == "sawmill"           ) or
       ( keyvalues["historic"] == "well"              ) or
       ( keyvalues["historic"] == "cannon"            )) then
      keyvalues["historic"] = "nonspecific"
      keyvalues["tourism"] = nil

      if ( keyvalues["landuse"] == nil ) then
         keyvalues["landuse"] = "historic"
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

   if (( keyvalues["historic"] == "chimney" ) or
       ( keyvalues["man_made"] == "chimney" )) then
      if (( tonumber(keyvalues["height"]) or 0 ) >  100 ) then
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
       (( keyvalues["species"] == "giant_hogweed"            )  or
        ( keyvalues["species"] == "Heracleum mantegazzianum" )  or
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
-- Supress Underground railway platforms
-- ----------------------------------------------------------------------------
   if (( keyvalues["railway"]  == "platform"    ) and
       ( keyvalues["location"] == "underground" )) then
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
       ( keyvalues["man_made"]   == "reservoir"             )) then
      keyvalues["natural"] = "water"
   end

-- ----------------------------------------------------------------------------
-- Supress "name" on riverbanks mapped as "natural=water"
-- ----------------------------------------------------------------------------
   if (( keyvalues["natural"]   == "water"  ) and
       ( keyvalues["water"]     == "river"  )) then
      keyvalues["name"] = nil
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
-- Change solar panels to "roof"
-- ----------------------------------------------------------------------------
   if (( keyvalues["power"]            == "generator"    ) and
       ( keyvalues["generator:method"] == "photovoltaic" )) then
      keyvalues["power"]    = nil
      keyvalues["building"] = "roof"
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
   if (( keyvalues["amenity"]   == "mounting_block"       ) or
       ( keyvalues["bridleway"] == "mounting_block"       ) or
       ( keyvalues["historic"]  == "mounting_block"       ) or
       ( keyvalues["horse"]     == "mounting_block"       ) or
       ( keyvalues["horse"]     == "mounting block"       ) or
       ( keyvalues["amenity"]   == "mounting_step"        ) or
       ( keyvalues["amenity"]   == "mounting_steps"       ) or
       ( keyvalues["amenity"]   == "horse_dismount_block" )) then
      keyvalues["man_made"] = "mounting_block"
   end

-- ----------------------------------------------------------------------------
-- Water monitoring stations
-- ----------------------------------------------------------------------------
   if (( keyvalues["man_made"]               == "monitoring_station" ) and
       ( keyvalues["monitoring:water_level"] == "yes"                )) then
      keyvalues["man_made"] = "monitoringwater"
   end

-- ----------------------------------------------------------------------------
-- Air quality monitoring stations
-- ----------------------------------------------------------------------------
   if (( keyvalues["man_made"]               == "monitoring_station" ) and
       ( keyvalues["monitoring:air_quality"] == "yes"                )) then
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
-- Render guest houses subtagged as B&B as B&B
-- ----------------------------------------------------------------------------
   if (( keyvalues["tourism"]     == "guest_house"       ) and
       ( keyvalues["guest_house"] == "bed_and_breakfast" )) then
      keyvalues["tourism"] = "bed_and_breakfast"
   end

-- ----------------------------------------------------------------------------
-- tourism=bed_and_breakfast was removed by the "style police" in
-- https://github.com/gravitystorm/openstreetmap-carto/pull/695
-- That now has its own icon.
-- Also "self_catering" et al (used occasionally) as guest_house.
-- ----------------------------------------------------------------------------
   if (( keyvalues["tourism"]   == "self_catering"           ) or
       ( keyvalues["tourism"]   == "apartment"               ) or
       ( keyvalues["tourism"]   == "apartments"              ) or
       ( keyvalues["tourism"]   == "holiday_cottage"         ) or
       ( keyvalues["tourism"]   == "cottage"                 ) or
       ( keyvalues["tourism"]   == "holiday_village"         ) or
       ( keyvalues["tourism"]   == "holiday_park"            ) or
       ( keyvalues["tourism"]   == "spa_resort"              ) or
       ( keyvalues["tourism"]   == "accommodation"           ) or
       ( keyvalues["tourism"]   == "holiday_accommodation"   ) or
       ( keyvalues["tourism"]   == "holiday_lets"            ) or
       ( keyvalues["tourism"]   == "holiday_let"             ) or
       ( keyvalues["tourism"]   == "Holiday Lodges"          ) or
       ( keyvalues["tourism"]   == "guesthouse"              ) or
       ( keyvalues["tourism"]   == "aparthotel"              )) then
      keyvalues["tourism"] = "guest_house"
   end

-- ----------------------------------------------------------------------------
-- Render alternative taggings of camp_site etc.
-- ----------------------------------------------------------------------------
   if ( keyvalues["tourism"] == "camping"  ) then
      keyvalues["tourism"] = "camp_site"
   end

   if (( keyvalues["tourism"] == "caravan_site;camp_site"    ) or
       ( keyvalues["tourism"] == "caravan_site;camping_site" )) then
      keyvalues["tourism"] = "caravan_site"
   end

   if ( keyvalues["tourism"] == "adventure_holiday"  ) then
      keyvalues["tourism"] = "hostel"
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
       (   keyvalues["man_made"]    == "village_sign"                       )  or
       (   keyvalues["tourism"]     == "sign"                               )  or
       (   keyvalues["emergency"]   == "beach_safety_sign"                  )  or
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
      if ( keyvalues["guide_type"] == "intermediary" ) then
         keyvalues["tourism"] = "informationroutemarker"
      else
         keyvalues["tourism"] = "informationmarker"
      end
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
-- Change some common semicolon values to the first in the list.
-- ----------------------------------------------------------------------------
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
   if ((( keyvalues["natural"]   == "wood"        )  or
        ( keyvalues["landuse"]   == "forest"      )) and
       (  keyvalues["military"]  == "danger_area"  )) then
      keyvalues["military"] = nil
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
       ( keyvalues["military"] == "ta centre"                          ) or
       ( keyvalues["military"] == "checkpoint"                         ) or
       ( keyvalues["hazard"]   == "shooting_range"                     ) or
       ( keyvalues["sport"]    == "shooting_range"                     )) then
      keyvalues["landuse"] = "military"
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
-- (from z13 for cliff, z17 for embankment, direction is important)
-- man_made=levee displays as a two-sided cliff (from z14).
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
-- Climbing features (boulders, stones, etc.)
-- Deliberately only use this for outdoor features that would not otherwise
-- display, so not cliffs etc.
-- ----------------------------------------------------------------------------
   if (( keyvalues["sport"]    == "climbing"      ) and
       ( keyvalues["natural"]  ~= "peak"          ) and
       ( keyvalues["natural"]  ~= "cliff"         ) and
       ( keyvalues["leisure"]  ~= "sports_centre" ) and
       ( keyvalues["leisure"]  ~= "climbing_wall" ) and
       ( keyvalues["shop"]     ~= "sports"        ) and
       ( keyvalues["tourism"]  ~= "attraction"    ) and
       ( keyvalues["building"] == nil             ) and
       ( keyvalues["man_made"] ~= "tower"         ) and
       ( keyvalues["barrier"]  ~= "wall"          )) then
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
-- Render historic=wayside_cross and wayside_shrine as historic=memorialcross
-- ----------------------------------------------------------------------------
   if ((   keyvalues["historic"]   == "wayside_cross"    ) or
       (   keyvalues["historic"]   == "wayside_shrine"   ) or
       ((  keyvalues["historic"]   == "memorial"        )  and
        (( keyvalues["memorial"]   == "cross"          )   or
         ( keyvalues["memorial"]   == "mercat_cross"   )))) then
      keyvalues["historic"] = "memorialcross"
   end

   if (( keyvalues["historic"]   == "memorial"     ) and
       ( keyvalues["memorial"]   == "war_memorial" )) then
      keyvalues["historic"] = "warmemorial"
   end

   if ((  keyvalues["historic"]      == "memorial"     ) and
       (( keyvalues["memorial"]      == "plaque"      )  or
        ( keyvalues["memorial"]      == "blue_plaque" )  or
        ( keyvalues["memorial:type"] == "plaque"      )  or
        ( keyvalues["memorial:type"] == "blue_plaque" ))) then
      keyvalues["historic"] = "memorialplaque"
   end

   if (( keyvalues["historic"]   == "memorial"        ) and
       ( keyvalues["memorial"]   == "pavement plaque" )) then
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

   if ((  keyvalues["historic"]      == "memorial"  ) and
       (( keyvalues["memorial"]      == "plate"    )  or
        ( keyvalues["memorial:type"] == "plate"    ))) then
      keyvalues["historic"] = "memorialplate"
   end

   if (( keyvalues["historic"]   == "memorial"    ) and
       ( keyvalues["memorial"]   == "bench"       )) then
      keyvalues["historic"] = "memorialbench"
   end

   if ((  keyvalues["historic"]   == "memorial"     ) and
       (( keyvalues["memorial"]   == "grave"       )  or
        ( keyvalues["memorial"]   == "graveyard"   ))) then
      keyvalues["historic"] = "memorialgrave"
   end

   if ((   keyvalues["man_made"]      == "obelisk"     ) or
       (   keyvalues["landmark"]      == "obelisk"     ) or
       ((  keyvalues["historic"]      == "memorial"   ) and
        (( keyvalues["memorial"]      == "obelisk"   )  or
         ( keyvalues["memorial:type"] == "obelisk"   )))) then
      keyvalues["historic"] = "memorialobelisk"
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
   if (( keyvalues["shop"]    == "electronics"             ) or
       ( keyvalues["craft"]   == "electronics_repair"      ) or
       ( keyvalues["shop"]    == "electronics_repair"      ) or
       ( keyvalues["amenity"] == "electronics_repair"      ) or
       ( keyvalues["shop"]    == "radiotechnics"           ) or
       ( keyvalues["shop"]    == "appliance"               ) or
       ( keyvalues["shop"]    == "electrical_supplies"     ) or
       ( keyvalues["shop"]    == "electrical_repair"       ) or
       ( keyvalues["shop"]    == "tv_repair"               ) or
       ( keyvalues["shop"]    == "alarm"                   ) or
       ( keyvalues["shop"]    == "gadget"                  ) or
       ( keyvalues["shop"]    == "appliances"              ) or
       ( keyvalues["shop"]    == "vacuum_cleaner"          ) or
       ( keyvalues["shop"]    == "sewing_machines"         ) or
       ( keyvalues["shop"]    == "domestic_appliances"     ) or
       ( keyvalues["shop"]    == "white_goods"             ) or
       ( keyvalues["shop"]    == "electricial"             ) or
       ( keyvalues["shop"]    == "electricals"             ) or
       ( keyvalues["trade"]   == "electrical"              ) or
       ( keyvalues["name"]    == "City Electrical Factors" )) then
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
-- If no name use brand or operator on amenity=fuel, among others.  
-- If there is brand or operator, use that with name.
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"]   == "atm"              ) or
       ( keyvalues["amenity"]   == "fuel"             ) or
       ( keyvalues["amenity"]   == "charging_station" ) or
       ( keyvalues["amenity"]   == "vending_machine"  ) or
       ( keyvalues["amenity"]   == "pub_yyyyydy"      ) or
       ( keyvalues["amenity"]   == "pub_yyyyydn"      ) or
       ( keyvalues["amenity"]   == "pub_yyyynyd"      ) or
       ( keyvalues["amenity"]   == "pub_yyyynnydd"    ) or
       ( keyvalues["amenity"]   == "pub_yyyynnydg"    ) or
       ( keyvalues["amenity"]   == "pub_yyyynnydo"    ) or
       ( keyvalues["amenity"]   == "pub_yyyynnyld"    ) or
       ( keyvalues["amenity"]   == "pub_yyyynnylg"    ) or
       ( keyvalues["amenity"]   == "pub_yyyynnylo"    ) or
       ( keyvalues["amenity"]   == "pub_yyyynnynd"    ) or
       ( keyvalues["amenity"]   == "pub_yyyynnyng"    ) or
       ( keyvalues["amenity"]   == "pub_yyyynnyno"    ) or
       ( keyvalues["amenity"]   == "pub_yyyynnyyd"    ) or
       ( keyvalues["amenity"]   == "pub_yyyynnyyg"    ) or
       ( keyvalues["amenity"]   == "pub_yyyynnyyo"    ) or
       ( keyvalues["amenity"]   == "pub_yyyynnndd"    ) or
       ( keyvalues["amenity"]   == "pub_yyyynnndg"    ) or
       ( keyvalues["amenity"]   == "pub_yyyynnndo"    ) or
       ( keyvalues["amenity"]   == "pub_yyyynnnld"    ) or
       ( keyvalues["amenity"]   == "pub_yyyynnnlg"    ) or
       ( keyvalues["amenity"]   == "pub_yyyynnnlo"    ) or
       ( keyvalues["amenity"]   == "pub_yyyynnnnd"    ) or
       ( keyvalues["amenity"]   == "pub_yyyynnnng"    ) or
       ( keyvalues["amenity"]   == "pub_yyyynnnno"    ) or
       ( keyvalues["amenity"]   == "pub_yyyynnnyd"    ) or
       ( keyvalues["amenity"]   == "pub_yyyynnnyg"    ) or
       ( keyvalues["amenity"]   == "pub_yyyynnnyo"    ) or
       ( keyvalues["amenity"]   == "pub_yyydydy"      ) or
       ( keyvalues["amenity"]   == "pub_yyydydn"      ) or
       ( keyvalues["amenity"]   == "pub_yyydnyd"      ) or
       ( keyvalues["amenity"]   == "pub_yyydnnydd"    ) or
       ( keyvalues["amenity"]   == "pub_yyydnnydg"    ) or
       ( keyvalues["amenity"]   == "pub_yyydnnydo"    ) or
       ( keyvalues["amenity"]   == "pub_yyydnnyld"    ) or
       ( keyvalues["amenity"]   == "pub_yyydnnylg"    ) or
       ( keyvalues["amenity"]   == "pub_yyydnnylo"    ) or
       ( keyvalues["amenity"]   == "pub_yyydnnynd"    ) or
       ( keyvalues["amenity"]   == "pub_yyydnnyng"    ) or
       ( keyvalues["amenity"]   == "pub_yyydnnyno"    ) or
       ( keyvalues["amenity"]   == "pub_yyydnnyyd"    ) or
       ( keyvalues["amenity"]   == "pub_yyydnnyyg"    ) or
       ( keyvalues["amenity"]   == "pub_yyydnnyyo"    ) or
       ( keyvalues["amenity"]   == "pub_yyydnnndd"    ) or
       ( keyvalues["amenity"]   == "pub_yyydnnndg"    ) or
       ( keyvalues["amenity"]   == "pub_yyydnnndo"    ) or
       ( keyvalues["amenity"]   == "pub_yyydnnnld"    ) or
       ( keyvalues["amenity"]   == "pub_yyydnnnlg"    ) or
       ( keyvalues["amenity"]   == "pub_yyydnnnlo"    ) or
       ( keyvalues["amenity"]   == "pub_yyydnnnnd"    ) or
       ( keyvalues["amenity"]   == "pub_yyydnnnng"    ) or
       ( keyvalues["amenity"]   == "pub_yyydnnnno"    ) or
       ( keyvalues["amenity"]   == "pub_yyydnnnyd"    ) or
       ( keyvalues["amenity"]   == "pub_yyydnnnyg"    ) or
       ( keyvalues["amenity"]   == "pub_yyydnnnyo"    ) or
       ( keyvalues["amenity"]   == "pub_yydyydyd"     ) or
       ( keyvalues["amenity"]   == "pub_yydyydyl"     ) or
       ( keyvalues["amenity"]   == "pub_yydyydyn"     ) or
       ( keyvalues["amenity"]   == "pub_yydyydyy"     ) or
       ( keyvalues["amenity"]   == "pub_yydyydnd"     ) or
       ( keyvalues["amenity"]   == "pub_yydyydnl"     ) or
       ( keyvalues["amenity"]   == "pub_yydyydnn"     ) or
       ( keyvalues["amenity"]   == "pub_yydyydny"     ) or
       ( keyvalues["amenity"]   == "pub_yydynydd"     ) or
       ( keyvalues["amenity"]   == "pub_yydynydl"     ) or
       ( keyvalues["amenity"]   == "pub_yydynydn"     ) or
       ( keyvalues["amenity"]   == "pub_yydynydy"     ) or
       ( keyvalues["amenity"]   == "pub_yydynnydd"    ) or
       ( keyvalues["amenity"]   == "pub_yydynnydg"    ) or
       ( keyvalues["amenity"]   == "pub_yydynnydo"    ) or
       ( keyvalues["amenity"]   == "pub_yydynnyld"    ) or
       ( keyvalues["amenity"]   == "pub_yydynnylg"    ) or
       ( keyvalues["amenity"]   == "pub_yydynnylo"    ) or
       ( keyvalues["amenity"]   == "pub_yydynnynd"    ) or
       ( keyvalues["amenity"]   == "pub_yydynnyng"    ) or
       ( keyvalues["amenity"]   == "pub_yydynnyno"    ) or
       ( keyvalues["amenity"]   == "pub_yydynnyyd"    ) or
       ( keyvalues["amenity"]   == "pub_yydynnyyg"    ) or
       ( keyvalues["amenity"]   == "pub_yydynnyyo"    ) or
       ( keyvalues["amenity"]   == "pub_yydynnndd"    ) or
       ( keyvalues["amenity"]   == "pub_yydynnndg"    ) or
       ( keyvalues["amenity"]   == "pub_yydynnndo"    ) or
       ( keyvalues["amenity"]   == "pub_yydynnnld"    ) or
       ( keyvalues["amenity"]   == "pub_yydynnnlg"    ) or
       ( keyvalues["amenity"]   == "pub_yydynnnlo"    ) or
       ( keyvalues["amenity"]   == "pub_yydynnnnd"    ) or
       ( keyvalues["amenity"]   == "pub_yydynnnng"    ) or
       ( keyvalues["amenity"]   == "pub_yydynnnno"    ) or
       ( keyvalues["amenity"]   == "pub_yydynnnyd"    ) or
       ( keyvalues["amenity"]   == "pub_yydynnnyg"    ) or
       ( keyvalues["amenity"]   == "pub_yydynnnyo"    ) or
       ( keyvalues["amenity"]   == "pub_yyddydddd"    ) or
       ( keyvalues["amenity"]   == "pub_yyddydddg"    ) or
       ( keyvalues["amenity"]   == "pub_yyddydddo"    ) or
       ( keyvalues["amenity"]   == "pub_yyddyddld"    ) or
       ( keyvalues["amenity"]   == "pub_yyddyddlg"    ) or
       ( keyvalues["amenity"]   == "pub_yyddyddlo"    ) or
       ( keyvalues["amenity"]   == "pub_yyddyddnd"    ) or
       ( keyvalues["amenity"]   == "pub_yyddyddng"    ) or
       ( keyvalues["amenity"]   == "pub_yyddyddno"    ) or
       ( keyvalues["amenity"]   == "pub_yyddyddyd"    ) or
       ( keyvalues["amenity"]   == "pub_yyddyddyg"    ) or
       ( keyvalues["amenity"]   == "pub_yyddyddyo"    ) or
       ( keyvalues["amenity"]   == "pub_yyddnydd"     ) or
       ( keyvalues["amenity"]   == "pub_yyddnydl"     ) or
       ( keyvalues["amenity"]   == "pub_yyddnydn"     ) or
       ( keyvalues["amenity"]   == "pub_yyddnydy"     ) or
       ( keyvalues["amenity"]   == "pub_yyddnnydd"    ) or
       ( keyvalues["amenity"]   == "pub_yyddnnydg"    ) or
       ( keyvalues["amenity"]   == "pub_yyddnnydo"    ) or
       ( keyvalues["amenity"]   == "pub_yyddnnyld"    ) or
       ( keyvalues["amenity"]   == "pub_yyddnnylg"    ) or
       ( keyvalues["amenity"]   == "pub_yyddnnylo"    ) or
       ( keyvalues["amenity"]   == "pub_yyddnnynd"    ) or
       ( keyvalues["amenity"]   == "pub_yyddnnyng"    ) or
       ( keyvalues["amenity"]   == "pub_yyddnnyno"    ) or
       ( keyvalues["amenity"]   == "pub_yyddnnyyd"    ) or
       ( keyvalues["amenity"]   == "pub_yyddnnyyg"    ) or
       ( keyvalues["amenity"]   == "pub_yyddnnyyo"    ) or
       ( keyvalues["amenity"]   == "pub_yyddnnndd"    ) or
       ( keyvalues["amenity"]   == "pub_yyddnnndg"    ) or
       ( keyvalues["amenity"]   == "pub_yyddnnndo"    ) or
       ( keyvalues["amenity"]   == "pub_yyddnnnld"    ) or
       ( keyvalues["amenity"]   == "pub_yyddnnnlg"    ) or
       ( keyvalues["amenity"]   == "pub_yyddnnnlo"    ) or
       ( keyvalues["amenity"]   == "pub_yyddnnnnd"    ) or
       ( keyvalues["amenity"]   == "pub_yyddnnnng"    ) or
       ( keyvalues["amenity"]   == "pub_yyddnnnno"    ) or
       ( keyvalues["amenity"]   == "pub_yyddnnnyd"    ) or
       ( keyvalues["amenity"]   == "pub_yyddnnnyg"    ) or
       ( keyvalues["amenity"]   == "pub_yyddnnnyo"    ) or
       ( keyvalues["amenity"]   == "pub_ynyydddd"     ) or
       ( keyvalues["amenity"]   == "pub_ynyydddl"     ) or
       ( keyvalues["amenity"]   == "pub_ynyydddn"     ) or
       ( keyvalues["amenity"]   == "pub_ynyydddy"     ) or
       ( keyvalues["amenity"]   == "pub_ynydddy"      ) or
       ( keyvalues["amenity"]   == "pub_ynydddnd"     ) or
       ( keyvalues["amenity"]   == "pub_ynydddnl"     ) or
       ( keyvalues["amenity"]   == "pub_ynydddnn"     ) or
       ( keyvalues["amenity"]   == "pub_ynydddny"     ) or
       ( keyvalues["amenity"]   == "pub_yndyddyd"     ) or
       ( keyvalues["amenity"]   == "pub_yndyddyl"     ) or
       ( keyvalues["amenity"]   == "pub_yndyddyn"     ) or
       ( keyvalues["amenity"]   == "pub_yndyddyy"     ) or
       ( keyvalues["amenity"]   == "pub_yndyddndd"    ) or
       ( keyvalues["amenity"]   == "pub_yndyddndg"    ) or
       ( keyvalues["amenity"]   == "pub_yndyddndo"    ) or
       ( keyvalues["amenity"]   == "pub_yndyddnld"    ) or
       ( keyvalues["amenity"]   == "pub_yndyddnlg"    ) or
       ( keyvalues["amenity"]   == "pub_yndyddnlo"    ) or
       ( keyvalues["amenity"]   == "pub_yndyddnnd"    ) or
       ( keyvalues["amenity"]   == "pub_yndyddnng"    ) or
       ( keyvalues["amenity"]   == "pub_yndyddnno"    ) or
       ( keyvalues["amenity"]   == "pub_yndyddnyd"    ) or
       ( keyvalues["amenity"]   == "pub_yndyddnyg"    ) or
       ( keyvalues["amenity"]   == "pub_yndyddnyo"    ) or
       ( keyvalues["amenity"]   == "pub_ynddddy"      ) or
       ( keyvalues["amenity"]   == "pub_ynddddnd"     ) or
       ( keyvalues["amenity"]   == "pub_ynddddnl"     ) or
       ( keyvalues["amenity"]   == "pub_ynddddnn"     ) or
       ( keyvalues["amenity"]   == "pub_ynddddny"     ) or
       ( keyvalues["amenity"]   == "pub_cddddddd"     ) or
       ( keyvalues["amenity"]   == "pub_nddddddd"     ) or
       ( keyvalues["amenity"]   == "pub_ydyyydd"      ) or
       ( keyvalues["amenity"]   == "pub_ydyyndd"      ) or
       ( keyvalues["amenity"]   == "pub_ydydydd"      ) or
       ( keyvalues["amenity"]   == "pub_ydydnyd"      ) or
       ( keyvalues["amenity"]   == "pub_ydydnnyd"     ) or
       ( keyvalues["amenity"]   == "pub_ydydnnyl"     ) or
       ( keyvalues["amenity"]   == "pub_ydydnnyn"     ) or
       ( keyvalues["amenity"]   == "pub_ydydnnyy"     ) or
       ( keyvalues["amenity"]   == "pub_ydydnnnd"     ) or
       ( keyvalues["amenity"]   == "pub_ydydnnnl"     ) or
       ( keyvalues["amenity"]   == "pub_ydydnnnn"     ) or
       ( keyvalues["amenity"]   == "pub_ydydnnny"     ) or
       ( keyvalues["amenity"]   == "pub_yddyydy"      ) or
       ( keyvalues["amenity"]   == "pub_yddyydn"      ) or
       ( keyvalues["amenity"]   == "pub_yddynyd"      ) or
       ( keyvalues["amenity"]   == "pub_yddynnd"      ) or
       ( keyvalues["amenity"]   == "pub_ydddydy"      ) or
       ( keyvalues["amenity"]   == "pub_ydddydnd"     ) or
       ( keyvalues["amenity"]   == "pub_ydddydnl"     ) or
       ( keyvalues["amenity"]   == "pub_ydddydnn"     ) or
       ( keyvalues["amenity"]   == "pub_ydddydny"     ) or
       ( keyvalues["amenity"]   == "pub_ydddnydd"     ) or
       ( keyvalues["amenity"]   == "pub_ydddnydl"     ) or
       ( keyvalues["amenity"]   == "pub_ydddnydn"     ) or
       ( keyvalues["amenity"]   == "pub_ydddnydy"     ) or
       ( keyvalues["amenity"]   == "pub_ydddnnyd"     ) or
       ( keyvalues["amenity"]   == "pub_ydddnnyl"     ) or
       ( keyvalues["amenity"]   == "pub_ydddnnyn"     ) or
       ( keyvalues["amenity"]   == "pub_ydddnnyy"     ) or
       ( keyvalues["amenity"]   == "pub_ydddnnndd"    ) or
       ( keyvalues["amenity"]   == "pub_ydddnnndg"    ) or
       ( keyvalues["amenity"]   == "pub_ydddnnndo"    ) or
       ( keyvalues["amenity"]   == "pub_ydddnnnld"    ) or
       ( keyvalues["amenity"]   == "pub_ydddnnnlg"    ) or
       ( keyvalues["amenity"]   == "pub_ydddnnnlo"    ) or
       ( keyvalues["amenity"]   == "pub_ydddnnnnd"    ) or
       ( keyvalues["amenity"]   == "pub_ydddnnnng"    ) or
       ( keyvalues["amenity"]   == "pub_ydddnnnno"    ) or
       ( keyvalues["amenity"]   == "pub_ydddnnnyd"    ) or
       ( keyvalues["amenity"]   == "pub_ydddnnnyg"    ) or
       ( keyvalues["amenity"]   == "pub_ydddnnnyo"    ) or
       ( keyvalues["amenity"]   == "pub"              ) or
       ( keyvalues["amenity"]   == "cafe"             ) or
       ( keyvalues["amenity"]   == "cafe_dl"          ) or
       ( keyvalues["amenity"]   == "cafe_dn"          ) or
       ( keyvalues["amenity"]   == "cafe_dy"          ) or
       ( keyvalues["amenity"]   == "cafe_yd"          ) or
       ( keyvalues["amenity"]   == "cafe_yl"          ) or
       ( keyvalues["amenity"]   == "cafe_yn"          ) or
       ( keyvalues["amenity"]   == "cafe_yy"          ) or
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
         if (( keyvalues["brand"] ~= nil                )  and
             ( keyvalues["brand"] ~= keyvalues["name"]  )) then
            keyvalues["name"] = keyvalues["name"] .. " (" .. keyvalues["brand"] .. ")"
            keyvalues["brand"] = nil
	 else
            if (( keyvalues["operator"] ~= nil                )  and
                ( keyvalues["operator"] ~= keyvalues["name"]  )) then
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
-- "fast_food" consolidation of lesser used tags.  
-- Also render fish and chips etc. with a unique icon.
-- ----------------------------------------------------------------------------
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
        ( keyvalues["cuisine"] == "pizza;italian" )   or
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
       ( keyvalues["shop"]   == "hardware_rental"      ) or
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

-- ----------------------------------------------------------------------------
-- Deli is quite popular and has its own icon
-- ----------------------------------------------------------------------------
   if ( keyvalues["shop"] == "delicatessen" ) then
      keyvalues["shop"] = "deli"
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
       ( keyvalues["shop"]         == "spa"               ) or
       ( keyvalues["amenity"]      == "spa"               ) or
       ( keyvalues["tourism"]      == "spa"               ) or
       ( keyvalues["shop"]         == "salon"             ) or
       ( keyvalues["shop"]         == "nails"             ) or
       ( keyvalues["shop"]         == "nailbar"           ) or
       ( keyvalues["shop"]         == "nail_salon"        ) or
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
       ( keyvalues["shop"]         == "tan"               ) or
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
       ( keyvalues["shop"]   == "party"               ) or
       ( keyvalues["shop"]   == "party_goods"         ) or
       ( keyvalues["shop"]   == "christmas"           ) or
       ( keyvalues["shop"]   == "fashion_accessories" )) then
      keyvalues["shop"] = "gift"
   end

-- ----------------------------------------------------------------------------
-- Various alcohol shops
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "beer"            ) or
       ( keyvalues["shop"]    == "off_licence"     ) or
       ( keyvalues["shop"]    == "off_license"     ) or
       ( keyvalues["shop"]    == "offlicence"      ) or
       ( keyvalues["shop"]    == "wine"            ) or
       ( keyvalues["shop"]    == "whisky"          )) then
      keyvalues["shop"] = "alcohol"
   end

   if (( keyvalues["shop"]    == "sweets"          ) or
       ( keyvalues["shop"]    == "sweet"           )) then
      keyvalues["shop"] = "confectionery"
   end

   if ( keyvalues["shop"] == "farm_shop" ) then
      keyvalues["shop"] = "farm"
   end

   if (( keyvalues["shop"]    == "camera"             ) or
       ( keyvalues["shop"]    == "photo_studio"       ) or
       ( keyvalues["office"]  == "photo_studio"       ) or
       ( keyvalues["shop"]    == "photography"        ) or
       ( keyvalues["office"]  == "photography"        ) or
       ( keyvalues["shop"]    == "photographic"       ) or
       ( keyvalues["shop"]    == "photographer"       )) then
      keyvalues["shop"] = "photo"
   end

-- ----------------------------------------------------------------------------
-- Various photo, camera, copy and print shops
-- Difficult to do an icon for.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "copyshop"           ) or
       ( keyvalues["office"]  == "design"             ) or
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
       ( keyvalues["shop"]    == "catering"        ) or
       ( keyvalues["shop"]    == "patissery"       ) or
       ( keyvalues["shop"]    == "pastry"          ) or
       ( keyvalues["shop"]    == "fishmonger"      ) or
       ( keyvalues["shop"]    == "spice"           ) or
       ( keyvalues["shop"]    == "nuts"            )) then
      keyvalues["shop"] = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- Various "homeware" shops.  Some of these, e.g. chandlery, are a bit of a 
-- stretch.
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]   == "floor"                       ) or
       ( keyvalues["shop"]   == "flooring"                    ) or
       ( keyvalues["shop"]   == "floors"                      ) or
       ( keyvalues["shop"]   == "floor_covering"              ) or
       ( keyvalues["shop"]   == "homeware"                    ) or
       ( keyvalues["shop"]   == "homewares"                   ) or
       ( keyvalues["shop"]   == "home"                        ) or
       ( keyvalues["shop"]   == "upholsterer"                 ) or
       ( keyvalues["shop"]   == "chair"                       ) or
       ( keyvalues["shop"]   == "luggage"                     ) or
       ( keyvalues["shop"]   == "clock"                       ) or
       ( keyvalues["shop"]   == "clocks"                      ) or
       ( keyvalues["shop"]   == "home_improvement"            ) or
       ( keyvalues["shop"]   == "interior_decoration"         ) or
       ( keyvalues["shop"]   == "decorating"                  ) or
       ( keyvalues["shop"]   == "interior_design"             ) or
       ( keyvalues["shop"]   == "interior"                    ) or
       ( keyvalues["shop"]   == "interiors"                   ) or
       ( keyvalues["shop"]   == "carpet"                      ) or
       ( keyvalues["shop"]   == "carpets"                     ) or
       ( keyvalues["shop"]   == "carpet;bed"                  ) or
       ( keyvalues["shop"]   == "bed;carpet"                  ) or
       ( keyvalues["shop"]   == "carpet; bed"                 ) or
       ( keyvalues["shop"]   == "country"                     ) or
       ( keyvalues["shop"]   == "country_store"               ) or
       ( keyvalues["shop"]   == "equestrian"                  ) or
       ( keyvalues["shop"]   == "kitchen"                     ) or
       ( keyvalues["shop"]   == "kitchen;bathroom"            ) or
       ( keyvalues["shop"]   == "kitchen;bathroom_furnishing" ) or
       ( keyvalues["shop"]   == "kitchens"                    ) or
       ( keyvalues["shop"]   == "stoves"                      ) or
       ( keyvalues["shop"]   == "stove"                       ) or
       ( keyvalues["shop"]   == "lamps"                       ) or
       ( keyvalues["shop"]   == "bedroom"                     ) or
       ( keyvalues["shop"]   == "houseware"                   ) or
       ( keyvalues["shop"]   == "bathroom_furnishing"         ) or
       ( keyvalues["shop"]   == "household"                   ) or
       ( keyvalues["shop"]   == "bathroom"                    ) or
       ( keyvalues["shop"]   == "glaziery"                    ) or
       ( keyvalues["craft"]  == "glaziery"                    ) or
       ( keyvalues["shop"]   == "glazier"                     ) or
       ( keyvalues["craft"]  == "glazier"                     ) or
       ( keyvalues["shop"]   == "glazing"                     ) or
       ( keyvalues["shop"]   == "tiles"                       ) or
       ( keyvalues["shop"]   == "tile"                        ) or
       ( keyvalues["shop"]   == "stone"                       ) or
       ( keyvalues["shop"]   == "ceramics"                    ) or
       ( keyvalues["shop"]   == "paint"                       ) or
       ( keyvalues["shop"]   == "brewing"                     ) or
       ( keyvalues["shop"]   == "lighting"                    ) or
       ( keyvalues["shop"]   == "windows"                     ) or
       ( keyvalues["shop"]   == "window"                      ) or
       ( keyvalues["craft"]  == "window_construction"         ) or
       ( keyvalues["shop"]   == "gates"                       ) or
       ( keyvalues["shop"]   == "sheds"                       ) or
       ( keyvalues["shop"]   == "shed"                        ) or
       ( keyvalues["shop"]   == "ironmonger"                  ) or
       ( keyvalues["shop"]   == "fireplace"                   ) or
       ( keyvalues["shop"]   == "fireplaces"                  ) or
       ( keyvalues["shop"]   == "furnace"                     ) or
       ( keyvalues["shop"]   == "plumbing"                    ) or
       ( keyvalues["craft"]  == "plumber"                     ) or
       ( keyvalues["craft"]  == "carpenter"                   ) or
       ( keyvalues["craft"]  == "decorator"                   ) or
       ( keyvalues["shop"]   == "blinds"                      ) or
       ( keyvalues["shop"]   == "window_blind"                ) or
       ( keyvalues["shop"]   == "bed"                         ) or
       ( keyvalues["shop"]   == "beds"                        ) or
       ( keyvalues["shop"]   == "mattress"                    ) or
       ( keyvalues["shop"]   == "waterbed"                    ) or
       ( keyvalues["shop"]   == "frame"                       ) or
       ( keyvalues["shop"]   == "framing"                     ) or
       ( keyvalues["shop"]   == "picture_framing"             ) or
       ( keyvalues["shop"]   == "picture_frames"              ) or
       ( keyvalues["shop"]   == "picture_framer"              ) or
       ( keyvalues["craft"]  == "framing"                     ) or
       ( keyvalues["shop"]   == "curtain"                     ) or
       ( keyvalues["shop"]   == "furnishings"                 ) or
       ( keyvalues["shop"]   == "furnishing"                  ) or
       ( keyvalues["shop"]   == "bedding"                     ) or
       ( keyvalues["shop"]   == "glass"                       ) or
       ( keyvalues["shop"]   == "garage"                      ) or
       ( keyvalues["shop"]   == "conservatory"                ) or
       ( keyvalues["shop"]   == "conservatories"              ) or
       ( keyvalues["shop"]   == "bathrooms"                   ) or
       ( keyvalues["shop"]   == "swimming_pool"               ) or
       ( keyvalues["shop"]   == "fitted_furniture"            ) or
       ( keyvalues["shop"]   == "kitchenware"                 ) or
       ( keyvalues["shop"]   == "cookware"                    ) or
       ( keyvalues["shop"]   == "glassware"                   ) or
       ( keyvalues["shop"]   == "cookery"                     ) or
       ( keyvalues["shop"]   == "upholstery"                  ) or
       ( keyvalues["shop"]   == "chandler"                    ) or
       ( keyvalues["shop"]   == "chandlers"                   ) or
       ( keyvalues["shop"]   == "chandlery"                   ) or
       ( keyvalues["shop"]   == "ship_chandler"               ) or
       ( keyvalues["craft"]  == "boatbuilder"                 ) or
       ( keyvalues["shop"]   == "saddlery"                    )) then
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
       ( keyvalues["shop"]   == "embroidery"           ) or
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
       ( keyvalues["shop"]       == "alternative_health"      ) or
       ( keyvalues["healthcare"] == "alternative"             ) or
       ( keyvalues["shop"]       == "acupuncture"             ) or
       ( keyvalues["heathcare"]  == "acupuncture"             ) or
       ( keyvalues["shop"]       == "aromatherapy"            ) or
       ( keyvalues["shop"]       == "meditation"              )) then
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
-- the name is usually characteristic
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]   == "stationery"      ) or
       ( keyvalues["shop"]   == "comics"          ) or
       ( keyvalues["shop"]   == "comic"           ) or
       ( keyvalues["shop"]   == "anime"           ) or
       ( keyvalues["shop"]   == "maps"            ) or
       ( keyvalues["shop"]   == "office_supplies" )) then
      keyvalues["shop"] = "books"
   end

-- ----------------------------------------------------------------------------
-- toys and games etc.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]   == "model"          ) or
       ( keyvalues["shop"]   == "models"         ) or
       ( keyvalues["shop"]   == "games"          ) or
       ( keyvalues["shop"]   == "game"           ) or
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
       ( keyvalues["shop"]   == "crafts"         ) or
       ( keyvalues["shop"]   == "art_supplies"   ) or
       ( keyvalues["shop"]   == "pottery"        ) or
       ( keyvalues["craft"]  == "pottery"        )) then
      keyvalues["shop"] = "art"
   end

-- ----------------------------------------------------------------------------
-- pets and pet services
-- Normally the names are punningly characteristic (e.g. "Bark-in-Style" 
-- dog grooming).
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]    == "pets"                    ) or
       ( keyvalues["shop"]    == "pet;garden"              ) or
       ( keyvalues["shop"]    == "pet;florist"             ) or
       ( keyvalues["shop"]    == "aquatics"                ) or
       ( keyvalues["shop"]    == "aquarium"                ) or
       ( keyvalues["shop"]    == "pet_supplies"            ) or
       ( keyvalues["shop"]    == "pet_care"                ) or
       ( keyvalues["shop"]    == "pet_food"                ) or
       ( keyvalues["shop"]    == "petfood"                 ) or
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
       ( keyvalues["amenity"] == "animal_shelter"          ) or
       ( keyvalues["animal"]  == "shelter"                 )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["shop"] = "pet"
   end

-- ----------------------------------------------------------------------------
-- Car parts
-- ----------------------------------------------------------------------------
   if ((( keyvalues["shop"]    == "trade"                       )  and
        ( keyvalues["trade"]   == "car_parts"                   )) or
       (  keyvalues["shop"]    == "car_accessories"              )  or
       (  keyvalues["shop"]    == "tyres"                        )  or
       (  keyvalues["shop"]    == "car_tyres"                    )  or
       (  keyvalues["shop"]    == "automotive"                   )  or
       (  keyvalues["shop"]    == "battery"                      )  or
       (  keyvalues["shop"]    == "batteries"                    )  or
       (  keyvalues["shop"]    == "number_plate"                 )  or
       (  keyvalues["shop"]    == "licence_plates"               )  or
       (  keyvalues["shop"]    == "car_audio"                    )  or
       (  keyvalues["shop"]    == "motor"                        )  or
       (  keyvalues["shop"]    == "motoring"                     )  or
       (  keyvalues["shop"]    == "motor_spares"                 )  or
       (  keyvalues["shop"]    == "motor_accessories"            )  or
       (  keyvalues["shop"]    == "car_parts;car_repair"         )  or
       (  keyvalues["shop"]    == "bicycle;car_parts"            )  or
       (  keyvalues["shop"]    == "car_parts;bicycle"            )  or
       (  keyvalues["shop"]    == "car_parts;bicycle;hardware"   )  or
       (  keyvalues["shop"]    == "car_parts;bicycle;outdoor"    )  or
       (  keyvalues["shop"]    == "bicycle;car_repair;car_parts" )) then
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
       ( keyvalues["shop"]    == "motorcycle_parts"             )) then
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
-- Nonspecific car and related shops.
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"] == "car_rental"                   ) or
       ( keyvalues["amenity"] == "van_rental"                   ) or
       ( keyvalues["amenity"] == "car_rental;bicycle_rental"    ) or
       ( keyvalues["amenity"] == "scooter_rental"               ) or
       ( keyvalues["amenity"] == "vehicle_rental"               ) or
       ( keyvalues["shop"]    == "car_rental"                   ) or
       ( keyvalues["shop"]    == "van_rental"                   ) or
       ( keyvalues["shop"]    == "caravan"                      ) or
       ( keyvalues["shop"]    == "caravans"                     ) or
       ( keyvalues["shop"]    == "motorhome"                    ) or
       ( keyvalues["shop"]    == "boat"                         ) or
       ( keyvalues["shop"]    == "truck"                        ) or
       ( keyvalues["shop"]    == "commercial_vehicles"          ) or
       ( keyvalues["shop"]    == "commercial_vehicle"           ) or
       ( keyvalues["shop"]    == "agricultural_vehicles"        ) or
       ( keyvalues["shop"]    == "tractor"                      ) or
       ( keyvalues["shop"]    == "tractors"                     ) or
       ( keyvalues["shop"]    == "tractor_repair"               ) or
       ( keyvalues["shop"]    == "tractor_parts"                ) or
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
       ( keyvalues["shop"]    == "cleaning"                ) or
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
       ( keyvalues["shop"]    == "locksmiths"              ) or
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
       ( keyvalues["shop"]    == "guns"                    ) or
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

   if (( keyvalues["shop"]    == "launderette"             ) or
       ( keyvalues["shop"]    == "dry_cleaning"            ) or
       ( keyvalues["shop"]    == "dry_cleaning;laundry"    ) or
       ( keyvalues["shop"]    == "dry_cleaner"             ) or
       ( keyvalues["shop"]    == "dry_cleaners"            )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["shop"] = "laundry"
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
       ( keyvalues["office"]  == "rental"          ) or
       ( keyvalues["amenity"] == "rental"          ) or
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
-- opticians etc. - render as "nonspecific health".
-- Add unnamedcommercial landuse to give non-building areas a background.
--
-- Places that _sell_ mobility aids are in here.  Shopmobility handled
-- seperately.
-- ----------------------------------------------------------------------------
   if (( keyvalues["shop"]        == "optician"                     ) or
       ( keyvalues["amenity"]     == "optician"                     ) or
       ( keyvalues["craft"]       == "optician"                     ) or
       ( keyvalues["office"]      == "optician"                     ) or
       ( keyvalues["shop"]        == "opticians"                    ) or
       ( keyvalues["shop"]        == "optometrist"                  ) or
       ( keyvalues["amenity"]     == "optometrist"                  ) or
       ( keyvalues["healthcare"]  == "optometrist"                  ) or
       ( keyvalues["shop"]        == "hearing_aids"                 ) or
       ( keyvalues["shop"]        == "medical_supply"               ) or
       ( keyvalues["shop"]        == "mobility"                     ) or
       ( keyvalues["shop"]        == "disability"                   ) or
       ( keyvalues["shop"]        == "chiropodist"                  ) or
       ( keyvalues["amenity"]     == "chiropodist"                  ) or
       ( keyvalues["healthcare"]  == "chiropodist"                  ) or
       ( keyvalues["amenity"]     == "chiropractor"                 ) or
       ( keyvalues["healthcare"]  == "chiropractor"                 ) or
       ( keyvalues["healthcare"]  == "chiropractor;physiotherapist" ) or
       ( keyvalues["amenity"]     == "osteopath"                    ) or
       ( keyvalues["healthcare"]  == "osteopath"                    ) or
       ( keyvalues["shop"]        == "osteopath"                    ) or
       ( keyvalues["amenity"]     == "physiotherapist"              ) or
       ( keyvalues["healthcare"]  == "physiotherapist"              ) or
       ( keyvalues["shop"]        == "physiotherapist"              ) or
       ( keyvalues["healthcare"]  == "physiotherapy"                ) or
       ( keyvalues["shop"]        == "physiotherapy"                ) or
       ( keyvalues["healthcare"]  == "psychotherapist"              ) or
       ( keyvalues["healthcare"]  == "therapy"                      ) or
       ( keyvalues["healthcare"]  == "footcare"                     ) or
       ( keyvalues["healthcare"]  == "podiatrist"                   ) or
       ( keyvalues["healthcare"]  == "podiatrist;chiropodist"       ) or
       ( keyvalues["amenity"]     == "podiatrist"                   ) or
       ( keyvalues["amenity"]     == "healthcare"                   ) or
       ( keyvalues["amenity"]     == "clinic"                       ) or
       ( keyvalues["healthcare"]  == "clinic"                       ) or
       ( keyvalues["shop"]        == "clinic"                       ) or
       ( keyvalues["amenity"]     == "social_facility"              ) or
       ( keyvalues["amenity"]     == "nursing_home"                 ) or
       ( keyvalues["residential"] == "nursing_home"                 ) or
       ( keyvalues["building"]    == "nursing_home"                 ) or
       ( keyvalues["amenity"]     == "care_home"                    ) or
       ( keyvalues["residential"] == "care_home"                    ) or
       ( keyvalues["amenity"]     == "retirement_home"              ) or
       ( keyvalues["amenity"]     == "residential_home"             ) or
       ( keyvalues["building"]    == "residential_home"             ) or
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
       ( keyvalues["healthcare"]  == "cosmetic_treatments"          ) or
       ( keyvalues["healthcare"]  == "dentures"                     ) or
       ( keyvalues["shop"]        == "dentures"                     ) or
       ( keyvalues["shop"]        == "denture"                      ) or
       ( keyvalues["healthcare"]  == "blood_donation"               ) or
       ( keyvalues["healthcare"]  == "blood_bank"                   ) or
       ( keyvalues["healthcare"]  == "sports_massage_therapist"     ) or
       ( keyvalues["healthcare"]  == "massage"                      ) or
       ( keyvalues["healthcare"]  == "rehabilitation"               ) or
       ( keyvalues["healthcare"]  == "drug_rehabilitation"          ) or
       ( keyvalues["healthcare"]  == "occupational_therapist"       ) or
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

   if ((   keyvalues["emergency"]        == "life_ring"          ) or
       (   keyvalues["waterway"]         == "life_ring"          ) or
       (   keyvalues["emergency"]        == "lifebuoy"           ) or
       (   keyvalues["emergency"]        == "life_belt"          ) or
       (   keyvalues["waterway"]         == "life_belt"          ) or
       ((  keyvalues["emergency"]        == "rescue_equipment"  )  and
        (( keyvalues["rescue_equipment"] == "lifering"         )   or
         ( keyvalues["rescue_equipment"] == "lifebuoy"         )))) then
      keyvalues["amenity"] = "life_ring"
   end

   if ( keyvalues["emergency"] == "fire_extinguisher" ) then
      keyvalues["amenity"] = "fire_extinguisher"
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
-- Offices that we don't know the type of.  
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( keyvalues["office"]     == "company"           ) or
       ( keyvalues["shop"]       == "office"            ) or
       ( keyvalues["amenity"]    == "office"            ) or
       ( keyvalues["office"]     == "research"          ) or
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
       ( keyvalues["amenity"]   == "fire_station"            ) or
       ( keyvalues["emergency"] == "fire_station"            ) or
       ( keyvalues["amenity"]   == "lifeboat_station"        ) or
       ( keyvalues["emergency"] == "lifeboat_station"        ) or
       ( keyvalues["emergency"] == "lifeboat_base"           ) or
       ( keyvalues["emergency"] == "lifeguard_tower"         ) or
       ( keyvalues["amenity"]   == "coast_guard"             ) or
       ( keyvalues["emergency"] == "coast_guard"             ) or
       ( keyvalues["amenity"]   == "archive"                 )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["office"]  = "nonspecific"
      keyvalues["tourism"]  = nil
   end

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
       ( keyvalues["emergency"] == "mountain_rescue_box"       )) then
      keyvalues["amenity"]  = "mountain_rescue_box"

      if ( keyvalues["name"] == nil ) then
         keyvalues["name"] = "Mountain Rescue Supplies"
      end
   end

-- ----------------------------------------------------------------------------
-- Non-government (commercial) offices that you might visit for a service.
-- "communication" below seems to be used for marketing / commercial PR.
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( keyvalues["office"]      == "it"                      ) or
       ( keyvalues["office"]      == "computer"                ) or
       ( keyvalues["office"]      == "lawyer"                  ) or
       ( keyvalues["shop"]        == "lawyer"                  ) or
       ( keyvalues["amenity"]     == "lawyer"                  ) or
       ( keyvalues["shop"]        == "legal"                   ) or
       ( keyvalues["office"]      == "solicitor"               ) or
       ( keyvalues["shop"]        == "solicitor"               ) or
       ( keyvalues["amenity"]     == "solicitor"               ) or
       ( keyvalues["office"]      == "solicitors"              ) or
       ( keyvalues["shop"]        == "solicitors"              ) or
       ( keyvalues["amenity"]     == "solicitors"              ) or
       ( keyvalues["office"]      == "accountant"              ) or
       ( keyvalues["shop"]        == "accountant"              ) or
       ( keyvalues["office"]      == "accountants"             ) or
       ( keyvalues["amenity"]     == "accountants"             ) or
       ( keyvalues["shop"]        == "accountants"             ) or
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
       ( keyvalues["office"]      == "engineering"             ) or
       ( keyvalues["craft"]       == "hvac"                    ) or
       ( keyvalues["office"]      == "hvac"                    ) or
       ( keyvalues["shop"]        == "heating"                 ) or
       ( keyvalues["office"]      == "laundry"                 ) or
       ( keyvalues["amenity"]     == "telephone_exchange"      ) or
       ( keyvalues["amenity"]     == "coworking_space"         ) or
       ( keyvalues["office"]      == "coworking"               ) or
       ( keyvalues["office"]      == "coworking_space"         ) or
       ( keyvalues["office"]      == "serviced_offices"        ) or
       ( keyvalues["amenity"]     == "studio"                  ) or
       ( keyvalues["amenity"]     == "prison"                  ) or
       ( keyvalues["amenity"]     == "monastery"               ) or
       ( keyvalues["amenity"]     == "convent"                 ) or
       ( keyvalues["amenity"]     == "music_school"            ) or
       ( keyvalues["amenity"]     == "cooking_school"          ) or
       ( keyvalues["amenity"]     == "flying_school"           )) then
      keyvalues["landuse"] = "unnamedcommercial"
      keyvalues["office"] = "nonspecific"
   end

-- ----------------------------------------------------------------------------
-- Other nonspecific offices.  
-- ----------------------------------------------------------------------------
   if (( keyvalues["office"]     == "it"                      ) or
       ( keyvalues["office"]     == "ngo"                     ) or
       ( keyvalues["office"]     == "educational_institution" ) or
       ( keyvalues["office"]     == "educational"             ) or
       ( keyvalues["office"]     == "university"              ) or
       ( keyvalues["office"]     == "charity"                 ) or
       ( keyvalues["office"]     == "marriage_guidance"       ) or
       ( keyvalues["amenity"]    == "education_centre"        ) or
       ( keyvalues["amenity"]    == "college"                 ) or
       ( keyvalues["man_made"]   == "observatory"             ) or
       ( keyvalues["man_made"]   == "telescope"               ) or
       ( keyvalues["man_made"]   == "radio_telescope"         ) or
       ( keyvalues["amenity"]    == "laboratory"              ) or
       ( keyvalues["healthcare"] == "laboratory"              ) or
       ( keyvalues["amenity"]    == "medical_laboratory"      ) or
       ( keyvalues["amenity"]    == "research_institute"      ) or
       ( keyvalues["office"]     == "political_party"         ) or
       ( keyvalues["office"]     == "quango"                  ) or
       ( keyvalues["office"]     == "association"             ) or
       ( keyvalues["amenity"]    == "advice"                  ) or
       ( keyvalues["amenity"]    == "advice_service"          ) or
       ( keyvalues["amenity"]    == "citizens_advice_bureau"  )) then
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
       ( keyvalues["leisure"]  == "soft_play"            ) or
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
       ( keyvalues["amenity"]  == "bingo"                ) or
       ( keyvalues["leisure"]  == "bingo"                ) or
       ( keyvalues["leisure"]  == "bingo_hall"           ) or
       ( keyvalues["gambing"]  == "bingo"                ) or
       ( keyvalues["name"]     == "Bingo Hall"           ) or
       ( keyvalues["name"]     == "Gala Bingo"           ) or
       ( keyvalues["name"]     == "Gala Bingo Hall"      ) or
       ( keyvalues["name"]     == "Mecca Bingo"          ) or
       ( keyvalues["name"]     == "Castle Bingo"         ) or
       ( keyvalues["leisure"]  == "escape_game"          ) or
       ( keyvalues["amenity"]  == "escape_game"          ) or
       ( keyvalues["sport"]    == "laser_tag"            ) or
       ( keyvalues["leisure"]  == "hackerspace"          ) or
       ( keyvalues["leisure"]  == "summer_camp"          ) or
       ( keyvalues["leisure"]  == "sailing_club"         ) or
       ( keyvalues["sport"]    == "model_aerodrome"      ) or
       ( keyvalues["leisure"]  == "trampoline_park"      ) or
       ( keyvalues["leisure"]  == "trampoline"           ) or
       ( keyvalues["leisure"]  == "inflatable_park"      ) or
       ( keyvalues["leisure"]  == "water_park"           ) or
       ( keyvalues["amenity"]  == "boat_rental"          ) or
       ( keyvalues["shop"]     == "boat_rental"          ) or
       ( keyvalues["leisure"]  == "firepit"              ) or
       ( keyvalues["amenity"]  == "public_bath"          ) or
       ( keyvalues["amenity"]  == "brothel"              ) or
       ( keyvalues["amenity"]  == "sauna"                ) or
       ( keyvalues["leisure"]  == "sauna"                ) or
       ( keyvalues["leisure"]  == "horse_riding"         ) or
       ( keyvalues["leisure"]  == "ice_rink"             ) or
       ( keyvalues["tourism"]  == "wilderness_hut"       ) or
       ( keyvalues["tourism"]  == "cabin"                ) or
       ( keyvalues["tourism"]  == "trail_riding_station" ) or
       ( keyvalues["tourism"]  == "resort"               ) or
       ( keyvalues["leisure"]  == "resort"               ) or
       ( keyvalues["leisure"]  == "beach_resort"         ) or
       ( keyvalues["leisure"]  == "adventure_park"       ) or
       ( keyvalues["leisure"]  == "miniature_golf"       ) or
       (( keyvalues["leisure"] == "indoor_golf"         )  and
        ( keyvalues["amenity"]  == nil                  )) or
       (( keyvalues["building"] == "yes"                )  and
        ( keyvalues["amenity"]  == nil                  )  and
        ( keyvalues["sport"]    ~= nil                  )) or
       (( keyvalues["sport"]    == "yoga"               )  and
        ( keyvalues["shop"]     == nil                  )  and
        ( keyvalues["amenity"]  == nil                  ))) then
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
-- Special case for Jehovahs Witnesses - don't use the normal Christian
-- symbol (a cross)
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"]      == "place_of_worship" ) and
       ( keyvalues["religion"]     == "christian"        ) and
       ( keyvalues["denomination"] == "jehovahs_witness" )) then
      keyvalues["religion"] = nil
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

      if ( keyvalues["name"] == nil ) then
         keyvalues["name"] = keyvalues["iata"]
      else
         keyvalues["name"] = keyvalues["name"] .. " (" .. keyvalues["iata"] .. ")"
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
-- If a quarry is disused, it's still likely a hole in the ground, so render it
-- ----------------------------------------------------------------------------
   if (( keyvalues["disused:landuse"] == "quarry" ) and
       ( keyvalues["landuse"]         == nil      )) then
      keyvalues["landuse"] = "quarry"
   end

-- ----------------------------------------------------------------------------
-- Masts etc.  Consolidate various sorts of masts and towers into the "mast"
-- group.  Note that this includes "tower" temporarily, and "campanile" is in 
-- here as a sort of tower (only 2 mapped in UK currently).
-- Also remove any "tourism" tags (which may be semi-valid mapping but are
-- often just "for the renderer").
-- ----------------------------------------------------------------------------
   if (( keyvalues["man_made"]   == "tower"   ) and
       ( keyvalues["tower:type"] == "cooling" )) then
      if (( tonumber(keyvalues["height"]) or 0 ) >  100 ) then
         keyvalues["man_made"] = "bigchimney"
      else
         keyvalues["man_made"] = "chimney"
      end
      keyvalues["tourism"] = nil
   end

   if (( keyvalues["man_made"]   == "tower"          ) and
       (( keyvalues["tower:type"] == "illumination" )  or
        ( keyvalues["tower:type"] == "lighting"     ))) then
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

   if (( keyvalues["man_made"]   == "tower"            ) and
       ( keyvalues["tower:type"] == "aircraft_control" )) then
      keyvalues["man_made"] = "aircraftcontroltower"
      keyvalues["building"] = "yes"
      keyvalues["tourism"] = nil
   end

   if ((( keyvalues["man_made"]   == "tower"              ) or
        ( keyvalues["man_made"]   == "monitoring_station" )) and
       (  keyvalues["tower:type"] == "radar"               )) then
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
       ( keyvalues["man_made"] == "communication_mast"   ) or
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
-- man_made=water_tap
-- ----------------------------------------------------------------------------
   if (( keyvalues["man_made"] == "water_tap" ) and
       ( keyvalues["amenity"]  == nil         )) then
      keyvalues["amenity"] = "drinking_water"
   end
   
-- ----------------------------------------------------------------------------
-- man_made=maypole
-- ----------------------------------------------------------------------------
   if ((  keyvalues["man_made"] == "maypole"   ) or
       (  keyvalues["man_made"] == "may_pole"  ) or
       (( keyvalues["man_made"] == "pole"     )  and
        ( keyvalues["pole"]      == "maypole" )) or
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
       (   keyvalues["office"]          == "vacant"    ) or
       (   keyvalues["office"]          == "disused"   ) or
       (   keyvalues["shop"]            == "disused"   ) or
       (   keyvalues["shop"]            == "empty"     ) or
       (   keyvalues["shop"]            == "closed"    ) or
       (   keyvalues["shop"]            == "abandoned" )) then
      keyvalues["shop"] = "vacant"
   end

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
-- Remove icon for public transport and animal field shelters and render as
-- "roof" (if they are a way).
-- ----------------------------------------------------------------------------
   if (( keyvalues["amenity"]      == "shelter"            ) and
       (( keyvalues["shelter_type"] == "public_transport" )  or
        ( keyvalues["shelter_type"] == "field_shelter"    ))) then
      keyvalues["amenity"] = nil
      if ( keyvalues["building"] == nil ) then
         keyvalues["building"] = "roof"
      end
   end

-- ----------------------------------------------------------------------------
-- Drop some highway areas - "track" etc. areas wherever I have seen them are 
-- garbage.
-- "footway" (pedestrian areas) and "service" (e.g. petrol station forecourts)
-- tend to be OK.  Other options tend not to occur.
-- ----------------------------------------------------------------------------
   if ((( keyvalues["highway"] == "track"          )  or
        ( keyvalues["highway"] == "track_graded"   )  or
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
       ( keyvalues["barrier"] == "flood_wall"     ) or
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
-- ----------------------------------------------------------------------------
   if (type == "route") then
      if (( keyvalues["network"] == "iwn" ) or
          ( keyvalues["network"] == "nwn" ) or
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

      if (( keyvalues["route"]   == "mtb" ) and
          ( keyvalues["network"] ~= "ncn" ) and
          ( keyvalues["network"] ~= "rcn" ) and
          ( keyvalues["network"] ~= "lcn" )) then
         keyvalues["highway"] = "ldpmtb"
      end

      if ( keyvalues["network"] == "nhn" ) then
         keyvalues["highway"] = "ldpnhn"
      end

      if (( keyvalues["highway"] == "ldpnwn" ) or
          ( keyvalues["highway"] == "ldpncn" ) or
          ( keyvalues["highway"] == "ldpmtb" ) or
          ( keyvalues["highway"] == "ldpnhn" )) then
         if ((  keyvalues["name"]        ~= nil     ) and
             (( keyvalues["name:signed"] == "no"   )  or
              ( keyvalues["unsigned"]    == "yes"  )  or
              ( keyvalues["unsigned"]    == "true" ))) then
            keyvalues["name"] = nil
            keyvalues["name:signed"] = nil
            keyvalues["highway"] = nil
         end

         if ((  keyvalues["ref"]        ~= nil     ) and
             (( keyvalues["ref:signed"] == "no"   )  or
              ( keyvalues["unsigned"]   == "yes"  )  or
              ( keyvalues["unsigned"]   == "true" ))) then
            keyvalues["ref"] = nil
            keyvalues["ref:signed"] = nil
            keyvalues["highway"] = nil
         end
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
