-- ----------------------------------------------------------------------------
-- shared_lua.lua
--
-- Copyright (C) 2024  Andy Townsend
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
-- Code common to several projects is in this file.
-- That file is in the "SomeoneElse-style" repository, but needs to be 
-- available on the standard lua path when a script that uses it is invoked.  
-- An easy way to do that is to copy it to a local shared area on that path:
--
-- cp /home/${local_filesystem_user}/src/SomeoneElse-style/shared_lua.lua -
--      /usr/local/share/lua/5.3/
-- ----------------------------------------------------------------------------
function fix_invalid_layer_values( passed_layer, passed_bridge, passed_embankment )
   local returned_layer = passed_layer

   if ( passed_layer == "-0.5" ) then
      returned_layer = "-1"
   end

   if ( passed_layer == "covered" ) then
      returned_layer = "0"
   end

   if ((( passed_bridge     == "yes" )   or
        ( passed_embankment == "yes" ))  and
       (( passed_layer      == "-3"  )   or
        ( passed_layer      == "-2"  )   or
        ( passed_layer      == "-1"  ))) then
      returned_layer = "0"
   end

   if (( passed_layer == "01"       ) or
       ( passed_layer == "+1"       ) or
       ( passed_layer == "yes"      ) or
       ( passed_layer == "0.5"      ) or
       ( passed_layer == "0-1"      ) or
       ( passed_layer == "0;1"      ) or
       ( passed_layer == "0;2"      ) or
       ( passed_layer == "0;1;2"    ) or
       ( passed_layer == "pipeline" )) then
      returned_layer = "1"
   end
   
   if ( passed_layer == "2;4" ) then
      returned_layer = "2"
   end

   if (( passed_layer == "6"  )  or
       ( passed_layer == "7"  )  or
       ( passed_layer == "8"  )  or
       ( passed_layer == "9"  )  or
       ( passed_layer == "10" )  or
       ( passed_layer == "15" )  or
       ( passed_layer == "16" )) then
      returned_layer = "5"
   end

   return returned_layer
end -- fix_invalid_layer_values()


-- ----------------------------------------------------------------------------
-- Before processing footways, turn certain corridors into footways
--
-- Note that https://wiki.openstreetmap.org/wiki/Key:indoor defines
-- indoor=corridor as a closed way.  highway=corridor is not documented there
-- but is used for corridors.  We'll only process layer or level 0 (or nil)
-- ----------------------------------------------------------------------------
function fix_corridors( passed_highway, passed_layer, passed_level )
    local returned_highway = passed_highway

    if ((  passed_highway == "corridor"   ) and
        (( passed_level   == nil         )  or
         ( passed_level   == ""          )  or
         ( passed_level   == "0"         )) and
        (( passed_layer   == nil         )  or
         ( passed_layer   == ""          )  or
         ( passed_layer   == "0"         ))) then
       returned_highway = "path"
    end

    return returned_highway
end -- fix_corridors()

-- ----------------------------------------------------------------------------
-- "Different names on each side of the street" and
-- "name:en" is set by "name" is not.
-- ----------------------------------------------------------------------------
function set_name_left_right_en( passed_name, passed_nameCleft, passed_nameCright, passed_nameCen )
    local returned_name = passed_name

    if (( passed_nameCleft  ~= nil ) and
        ( passed_nameCright ~= nil )) then
       returned_name = passed_nameCleft .. " / " .. passed_nameCright
    end

    if (( returned_name  == nil ) and
        ( passed_nameCen ~= nil )) then
       passed_name = passed_nameCen
    end

    return returned_name
end -- set_name_left_right_en

-- ----------------------------------------------------------------------------
-- Move refs to consider as "official" to official_ref
-- ----------------------------------------------------------------------------
function set_official_ref( passed_official_ref, passed_highway_authority_ref, passed_highway_ref, passed_admin_ref, passed_adminCref, passed_loc_ref, passed_ref )
    local returned_official_ref = passed_official_ref

    if (( passed_official_ref          == nil ) and
        ( passed_highway_authority_ref ~= nil )) then
       returned_official_ref          = passed_highway_authority_ref
    end

    if (( returned_official_ref == nil ) and
        ( passed_highway_ref    ~= nil )) then
       returned_official_ref = passed_highway_ref
    end

    if (( returned_official_ref == nil ) and
        ( passed_admin_ref      ~= nil )) then
       returned_official_ref = passed_admin_ref
    end

    if (( returned_official_ref == nil ) and
        ( passed_adminCref      ~= nil )) then
       returned_official_ref = passed_adminCref
    end

    if (( returned_official_ref == nil        ) and
        ( passed_loc_ref        ~= nil        ) and
        ( passed_loc_ref        ~= passed_ref )) then
       returned_official_ref = passed_loc_ref
    end

    return returned_official_ref
end -- set_official_ref()

-- ----------------------------------------------------------------------------
-- Consolidate some rare highway types into ones we can display.
-- ----------------------------------------------------------------------------
function process_golf_tracks( passed_highway, passed_golf )
    local returned_highway = passed_highway

    if (( passed_golf    == "track"      )   and
        ( passed_highway == nil          )) then
       returned_highway = "track"
    end

    if ((  passed_golf      == "path"       ) and
        (( returned_highway == nil         )  or
         ( returned_highway == "service"   ))) then
       returned_highway = "path"
    end

    if ((  passed_golf      == "cartpath"   ) and
        (( returned_highway == nil         )  or
         ( returned_highway == "service"   ))) then
       returned_highway = "track"
    end

    return returned_highway
end -- process_golf_tracks()

-- ----------------------------------------------------------------------------
-- "Sabristas" sometimes add dubious names to motorway junctions.  Don't show
-- them if they're not signed.
-- ----------------------------------------------------------------------------
function suppress_unsigned_motorway_junctions( passed_name, passed_highway, passed_nameCsigned, passed_nameCabsent, passed_unsigned )
    local returned_name = passed_name

    if ((( passed_highway == "motorway_junction"  ) and
         ( passed_nameCsigned == "no"            )  or
         ( passed_nameCabsent == "yes"           )  or
         ( passed_unsigned    == "yes"           )  or
         ( passed_unsigned    == "name"          ))) then
       returned_name = ""
    end

    return returned_name
end -- suppress_unsigned_motorway_junctions()

-- ----------------------------------------------------------------------------
-- Move unsigned road refs to the name, in brackets.
-- ----------------------------------------------------------------------------
function suppress_unsigned_road_refs( t )
    local passed_name = t[1]
    local passed_highway = t[2]
    local passed_nameCsigned = t[3]
    local passed_nameCabsent = t[4]
    local passed_official_ref = t[5]
    local passed_ref = t[6]
    local passed_refCsigned = t[7]
    local passed_unsigned = t[8]

    if (( passed_highway == "motorway"          ) or
        ( passed_highway == "motorway_link"     ) or
        ( passed_highway == "trunk"             ) or
        ( passed_highway == "trunk_link"        ) or
        ( passed_highway == "primary"           ) or
        ( passed_highway == "primary_link"      ) or
        ( passed_highway == "secondary"         ) or
        ( passed_highway == "secondary_link"    ) or
        ( passed_highway == "tertiary"          ) or
        ( passed_highway == "tertiary_link"     ) or
        ( passed_highway == "unclassified"      ) or
        ( passed_highway == "unclassified_link" ) or
        ( passed_highway == "residential"       ) or
        ( passed_highway == "residential_link"  ) or
        ( passed_highway == "service"           ) or
        ( passed_highway == "road"              ) or
        ( passed_highway == "track"             ) or
        ( passed_highway == "cycleway"          ) or
        ( passed_highway == "bridleway"         ) or
        ( passed_highway == "footway"           ) or
        ( passed_highway == "intfootwaynarrow"  ) or
        ( passed_highway == "path"              ) or
        ( passed_highway == "intpathnarrow"     )) then
       if (( passed_name == nil   ) or
           ( passed_name == ""    )) then
          if ((  passed_ref        ~= nil    )  and
              (( passed_refCsigned == "no"  )   or
               ( passed_unsigned   == "ref" ))) then
             passed_name       = "(" .. passed_ref .. ")"
             passed_ref        = nil
             passed_refCsigned = nil
             passed_unsigned   = nil
 	 else
             if ( passed_official_ref ~= nil  ) then
                passed_name         = "(" .. passed_official_ref .. ")"
                passed_official_ref = nil
             end
          end
       else
          if (( passed_nameCsigned == "no"   ) or
              ( passed_nameCabsent == "yes"  ) or
              ( passed_unsigned    == "yes"  ) or
              ( passed_unsigned    == "name" )) then
             passed_name = "(" .. passed_name
             passed_nameCsigned = nil

             if (( passed_refCsigned == "no"  ) or
                 ( passed_unsigned   == "ref" )) then
                if ( passed_ref ~= nil ) then
                   passed_name       = passed_name .. ", " .. passed_ref
                end

                passed_ref        = nil
                passed_refCsigned = nil
                passed_unsigned   = nil
             else
                if ( passed_official_ref ~= nil  ) then
                   passed_name         = passed_name .. ", " .. passed_official_ref
                   passed_official_ref = nil
                end
             end

             passed_name = passed_name .. ")"
          else
             if ((  passed_ref        ~= nil    ) and
                 (( passed_refCsigned == "no"  ) or
                  ( passed_unsigned   == "ref" ))) then
                passed_name       = passed_name .. " (" .. passed_ref .. ")"
                passed_ref        = nil
                passed_refCsigned = nil
                passed_unsigned   = nil
             else
                if ( passed_official_ref ~= nil  ) then
                   passed_name         = passed_name .. " (" .. passed_official_ref .. ")"
                   passed_official_ref = nil
                end
             end
          end
       end
    end

    t[1] = passed_name
    t[2] = passed_highway
    t[3] = passed_nameCsigned
    t[4] = passed_nameCabsent
    t[5] = passed_official_ref
    t[6] = passed_ref
    t[7] = passed_refCsigned
    t[8] = passed_unsigned

end -- suppress_unsigned_road_refs()

function consolidate_place( passed_place, passed_natural )
    local returned_place = passed_place

-- ----------------------------------------------------------------------------
-- Handle place=islet as place=island
-- ----------------------------------------------------------------------------
    if ( returned_place == "islet" ) then
       returned_place = "island"
    end

-- ----------------------------------------------------------------------------
-- Handle place=quarter
-- ----------------------------------------------------------------------------
    if ( returned_place == "quarter" ) then
       returned_place = "neighbourhood"
    end

-- ----------------------------------------------------------------------------
-- Handle natural=cape etc. as place=locality if no other place tag.
-- ----------------------------------------------------------------------------
    if ((( passed_natural == "cape"      ) or
         ( passed_natural == "headland"  ) or
         ( passed_natural == "peninsula" ) or
         ( passed_natural == "sound"     ) or
         ( passed_natural == "point"     )) and
        (( returned_place == nil         ) or
         ( returned_place == ""          ))) then
       returned_place = "locality"
    end

    return returned_place
end -- consolidate_place()