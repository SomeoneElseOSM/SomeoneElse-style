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
function fix_invalid_layer_values_t( passedt )
   if ( passedt.layer == "-0.5" ) then
      passedt.layer = "-1"
   end

   if ( passedt.layer == "covered" ) then
      passedt.layer = "0"
   end

   if ((( passedt.bridge     == "yes" )   or
        ( passedt.embankment == "yes" ))  and
       (( passedt.layer      == "-3"  )   or
        ( passedt.layer      == "-2"  )   or
        ( passedt.layer      == "-1"  ))) then
      passedt.layer = "0"
   end

   if (( passedt.layer == "01"       ) or
       ( passedt.layer == "+1"       ) or
       ( passedt.layer == "yes"      ) or
       ( passedt.layer == "0.5"      ) or
       ( passedt.layer == "0-1"      ) or
       ( passedt.layer == "0;1"      ) or
       ( passedt.layer == "0;2"      ) or
       ( passedt.layer == "0;1;2"    ) or
       ( passedt.layer == "pipeline" )) then
      passedt.layer = "1"
   end
   
   if ( passedt.layer == "2;4" ) then
      passedt.layer = "2"
   end

   if (( passedt.layer == "6"  )  or
       ( passedt.layer == "7"  )  or
       ( passedt.layer == "8"  )  or
       ( passedt.layer == "9"  )  or
       ( passedt.layer == "10" )  or
       ( passedt.layer == "15" )  or
       ( passedt.layer == "16" )) then
      passedt.layer = "5"
   end

end -- fix_invalid_layer_values_t()


function treat_was_as_disused_t( passedt )
   if ((  passedt["was:amenity"]     ~= nil  ) and
       (  passedt["was:amenity"]     ~= ""   ) and
       (( passedt["disused:amenity"] == nil )  or
        ( passedt["disused:amenity"] == ""  ))) then
      passedt["disused:amenity"] = passedt["was:amenity"]
   end

   if ((  passedt["was:waterway"]     ~= nil  ) and
       (  passedt["was:waterway"]     ~= ""   ) and
       (( passedt["disused:waterway"] == nil )  or
        ( passedt["disused:waterway"] == ""  ))) then
      passedt["disused:waterway"] = passedt["was:waterway"]
   end

   if ((  passedt["was:railway"]     ~= nil  ) and
       (  passedt["was:railway"]     ~= ""   ) and
       (( passedt["disused:railway"] == nil )  or
        ( passedt["disused:railway"] == ""  ))) then
      passedt["disused:railway"] = passedt["was:railway"]
   end

   if ((  passedt["was:aeroway"]     ~= nil  ) and
       (  passedt["was:aeroway"]     ~= ""   ) and
       (( passedt["disused:aeroway"] == nil )  or
        ( passedt["disused:aeroway"] == ""  ))) then
      passedt["disused:aeroway"] = passedt["was:aeroway"]
   end

   if ((  passedt["was:landuse"]     ~= nil  ) and
       (  passedt["was:landuse"]     ~= ""   ) and
       (( passedt["disused:landuse"] == nil )  or
        ( passedt["disused:landuse"] == ""  ))) then
      passedt["disused:landuse"] = passedt["was:landuse"]
   end

   if ((  passedt["was:shop"]     ~= nil  ) and
       (  passedt["was:shop"]     ~= ""   ) and
       (( passedt["disused:shop"] == nil )  or
        ( passedt["disused:shop"] == ""  ))) then
      passedt["disused:shop"] = passedt["was:shop"]
   end

-- ----------------------------------------------------------------------------
-- Treat "closed:" as "disused:" in some cases too.
-- ----------------------------------------------------------------------------
   if ((  passedt["closed:amenity"]  ~= nil  ) and
       (  passedt["closed:amenity"]  ~= ""   ) and
       (( passedt["disused:amenity"] == nil )  or
        ( passedt["disused:amenity"] == ""  ))) then
      passedt["disused:amenity"] = passedt["closed:amenity"]
   end

   if ((  passedt["closed:shop"]  ~= nil  ) and
       (  passedt["closed:shop"]  ~= ""   ) and
       (( passedt["disused:shop"] == nil )  or
        ( passedt["disused:shop"] == ""  ))) then
      passedt["disused:shop"] = passedt["closed:shop"]
   end

-- ----------------------------------------------------------------------------
-- Treat "status=abandoned" as "disused=yes"
-- ----------------------------------------------------------------------------
   if ( passedt.status == "abandoned" ) then
      passedt.disused = "yes"
   end

end -- treat_was_as_disused_t( passedt )

-- ----------------------------------------------------------------------------
-- Before processing footways, turn certain corridors into footways
--
-- Note that https://wiki.openstreetmap.org/wiki/Key:indoor defines
-- indoor=corridor as a closed way.  highway=corridor is not documented there
-- but is used for corridors.  We'll only process layer or level 0 (or nil)
-- ----------------------------------------------------------------------------
function fix_corridors_t( passedt )
    if ((  passedt.highway == "corridor"   ) and
        (( passedt.level   == nil         )  or
         ( passedt.level   == ""          )  or
         ( passedt.level   == "0"         )) and
        (( passedt.layer   == nil         )  or
         ( passedt.layer   == ""          )  or
         ( passedt.layer   == "0"         ))) then
       passedt.highway = "path"
    end
end -- fix_corridors_t()

-- ----------------------------------------------------------------------------
-- "Different names on each side of the street" and
-- "name:en" is set by "name" is not.
-- ----------------------------------------------------------------------------
function set_name_left_right_en_t( passedt )
    if (( passedt["name:left"]  ~= nil ) and
        ( passedt["name:left"]  ~= ""  ) and
        ( passedt["name:right"] ~= nil ) and
        ( passedt["name:right"] ~= ""  )) then
       passedt.name = passedt["name:left"] .. " / " .. passedt["name:right"]
    end

    if ((( passedt["name"]  == nil )  or
         ( passedt["name"]  == ""  )) and
        (  passedt["name:en"] ~= nil  ) and
        (  passedt["name:en"] ~= ""   )) then
       passedt.name = passedt["name:en"]
    end
end -- set_name_left_right_en_t

-- ----------------------------------------------------------------------------
-- Move refs to consider as "official" to official_ref
-- ----------------------------------------------------------------------------
function set_official_ref_t( passedt )
    if ((( passedt.official_ref        == nil )   or
         ( passedt.official_ref        == ""  ))  and
        (  passedt.highway_authority_ref ~= nil  )) then
       passedt.official_ref          = passedt.highway_authority_ref
    end

    if ((( passedt.official_ref == nil )   or
         ( passedt.official_ref == ""  ))  and
        (  passedt.highway_ref  ~= nil  )) then
       passedt.official_ref = passedt.highway_ref
    end

    if ((( passedt.official_ref == nil )   or
         ( passedt.official_ref == ""  ))  and
        (  passedt.admin_ref    ~= nil  )) then
       passedt.official_ref = passedt.admin_ref
    end

    if ((( passedt.official_ref == nil )   or
         ( passedt.official_ref == ""  ))  and
        ( passedt["admin:ref"]     ~= nil   )) then
       passedt.official_ref = passedt["admin:ref"]
    end

    if ((( passedt.official_ref == nil       )   or
         ( passedt.official_ref == ""        ))  and
        (  passedt.loc_ref      ~= nil        )  and
        (  passedt.loc_ref      ~= ""         )  and
        (  passedt.loc_ref      ~= passedt.ref )) then
       passedt.official_ref = passedt.loc_ref
    end
end -- set_official_ref_t()

-- ----------------------------------------------------------------------------
-- Consolidate some rare highway types into ones we can display.
-- ----------------------------------------------------------------------------
function process_golf_tracks( passed_highway, passed_golf )
    local returned_highway = passed_highway

    if ((  passed_golf    == "track"       )  and
        (( passed_highway == nil          )   or
         ( passed_highway == ""           ))) then
       returned_highway = "track"
    end

    if ((  passed_golf      == "path"       ) and
        (( returned_highway == nil         )  or
         ( returned_highway == ""          )  or
         ( returned_highway == "service"   ))) then
       returned_highway = "path"
    end

    if ((  passed_golf      == "cartpath"   ) and
        (( returned_highway == nil         )  or
         ( returned_highway == ""          )  or
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
          if (( passed_ref        ~= nil    )  and
              ( passed_ref        ~= ""     )  and
              (( passed_refCsigned == "no"  )   or
               ( passed_unsigned   == "ref" ))) then
             passed_name       = "(" .. passed_ref .. ")"
             passed_ref        = nil
             passed_refCsigned = nil
             passed_unsigned   = nil
 	 else
             if (( passed_official_ref ~= nil  )  and
                 ( passed_official_ref ~= ""   )) then
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
                if (( passed_ref ~= nil )  and
                    ( passed_ref ~= ""  )) then
                   passed_name       = passed_name .. ", " .. passed_ref
                end

                passed_ref        = nil
                passed_refCsigned = nil
                passed_unsigned   = nil
             else
                if (( passed_official_ref ~= nil ) and
                    ( passed_official_ref ~= ""  )) then
                   passed_name         = passed_name .. ", " .. passed_official_ref
                   passed_official_ref = nil
                end
             end

             passed_name = passed_name .. ")"
          else
             if ((  passed_ref        ~= nil    ) and
                 (  passed_ref        ~= ""     ) and
                 (( passed_refCsigned == "no"  ) or
                  ( passed_unsigned   == "ref" ))) then
                passed_name       = passed_name .. " (" .. passed_ref .. ")"
                passed_ref        = nil
                passed_refCsigned = nil
                passed_unsigned   = nil
             else
                if (( passed_official_ref ~= nil ) and
                    ( passed_official_ref ~= ""  )) then
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