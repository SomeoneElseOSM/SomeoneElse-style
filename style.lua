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
-- ----------------------------------------------------------------------------
   if (keyvalues["boundary"] == "administrative") then
      keyvalues["boundary"] = nil
   end

-- ----------------------------------------------------------------------------
-- Pretend add landuse=industrial to some industrial sub-types to force 
-- name rendering.
-- ----------------------------------------------------------------------------
   if ((keyvalues["man_made"]   == "works") or 
       (keyvalues["man_made"]   == "wastewater_plant") or 
       (keyvalues["industrial"] == "warehouse")) then
      keyvalues["landuse"] = "industrial"
   end

   if (keyvalues["amenity"]   == "car_wash") then
      keyvalues["landuse"] = "commercial"
   end

-- ----------------------------------------------------------------------------
-- As of 21st May, abandoned ralways are no longer rendered in the standard
-- style.  I'll pretend that they're "disused".
-- ----------------------------------------------------------------------------
   if (( keyvalues["railway"]   == "dismantled" ) or
       ( keyvalues["railway"]   == "abandoned"  )) then
      keyvalues["railway"] = "disused"
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
