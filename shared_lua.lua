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
function process_golf_tracks_t( passedt )
    if ((  passedt.golf    == "track"       )  and
        (( passedt.highway == nil          )   or
         ( passedt.highway == ""           ))) then
       passedt.highway = "track"
    end

    if ((  passedt.golf      == "path"       ) and
        (( passedt.highway == nil         )  or
         ( passedt.highway == ""          )  or
         ( passedt.highway == "service"   ))) then
       passedt.highway = "path"
    end

    if ((  passedt.golf      == "cartpath"   ) and
        (( passedt.highway == nil         )  or
         ( passedt.highway == ""          )  or
         ( passedt.highway == "service"   ))) then
       passedt.highway = "track"
    end
end -- process_golf_tracks_t()


-- ----------------------------------------------------------------------------
-- "Sabristas" sometimes add dubious names to motorway junctions.  Don't show
-- them if they're not signed.
-- ----------------------------------------------------------------------------
function suppress_unsigned_motorway_junctions_t( passedt )
    if ((( passedt.highway    == "motorway_junction"  ) and
         ( passedt["name:signed"] == "no"            )  or
         ( passedt["name:absent"] == "yes"           )  or
         ( passedt.unsigned       == "yes"           )  or
         ( passedt.unsigned       == "name"          ))) then
       passedt.name = ""
    end
end -- suppress_unsigned_motorway_junctions_t()

-- ----------------------------------------------------------------------------
-- Move unsigned road refs to the name, in brackets.
-- ----------------------------------------------------------------------------
function suppress_unsigned_road_refs_t( passedt )
    if (( passedt.highway == "motorway"          ) or
        ( passedt.highway == "motorway_link"     ) or
        ( passedt.highway == "trunk"             ) or
        ( passedt.highway == "trunk_link"        ) or
        ( passedt.highway == "primary"           ) or
        ( passedt.highway == "primary_link"      ) or
        ( passedt.highway == "secondary"         ) or
        ( passedt.highway == "secondary_link"    ) or
        ( passedt.highway == "tertiary"          ) or
        ( passedt.highway == "tertiary_link"     ) or
        ( passedt.highway == "unclassified"      ) or
        ( passedt.highway == "unclassified_link" ) or
        ( passedt.highway == "residential"       ) or
        ( passedt.highway == "residential_link"  ) or
        ( passedt.highway == "service"           ) or
        ( passedt.highway == "road"              ) or
        ( passedt.highway == "track"             ) or
        ( passedt.highway == "cycleway"          ) or
        ( passedt.highway == "bridleway"         ) or
        ( passedt.highway == "footway"           ) or
        ( passedt.highway == "intfootwaynarrow"  ) or
        ( passedt.highway == "path"              ) or
        ( passedt.highway == "intpathnarrow"     )) then
       if (( passedt.name == nil   ) or
           ( passedt.name == ""    )) then
          if (( passedt.ref        ~= nil    )  and
              ( passedt.ref        ~= ""     )  and
              (( passedt["ref:signed"] == "no"  )   or
               ( passedt.unsigned   == "ref" ))) then
             passedt.name       = "(" .. passedt.ref .. ")"
             passedt.ref        = nil
             passedt["ref:signed"] = nil
             passedt.unsigned   = nil
 	 else
             if (( passedt.official_ref ~= nil  )  and
                 ( passedt.official_ref ~= ""   )) then
                passedt.name         = "(" .. passedt.official_ref .. ")"
                passedt.official_ref = nil
             end
          end
       else
          if (( passedt["name:signed"] == "no"   ) or
              ( passedt["name:absent"] == "yes"  ) or
              ( passedt.unsigned       == "yes"  ) or
              ( passedt.unsigned       == "name" )) then
             passedt.name = "(" .. passedt.name
             passedt["name:signed"] = nil

             if (( passedt["ref:signed"] == "no"  ) or
                 ( passedt.unsigned      == "ref" )) then
                if (( passedt.ref ~= nil )  and
                    ( passedt.ref ~= ""  )) then
                   passedt.name       = passedt.name .. ", " .. passedt.ref
                end

                passedt.ref           = nil
                passedt["ref:signed"] = nil
                passedt.unsigned      = nil
             else
                if (( passedt.official_ref ~= nil ) and
                    ( passedt.official_ref ~= ""  )) then
                   passedt.name         = passedt.name .. ", " .. passedt.official_ref
                   passedt.official_ref = nil
                end
             end

             passedt.name = passedt.name .. ")"
          else
             if ((  passedt.ref           ~= nil    ) and
                 (  passedt.ref           ~= ""     ) and
                 (( passedt["ref:signed"] == "no"  ) or
                  ( passedt.unsigned      == "ref" ))) then
                passedt.name       = passedt.name .. " (" .. passedt.ref .. ")"
                passedt.ref        = nil
                passedt["ref:signed"] = nil
                passedt.unsigned   = nil
             else
                if (( passedt.official_ref ~= nil ) and
                    ( passedt.official_ref ~= ""  )) then
                   passedt.name         = passedt.name .. " (" .. passedt.official_ref .. ")"
                   passedt.official_ref = nil
                end
             end
          end
       end
    end
end -- suppress_unsigned_road_refs_t()


function consolidate_place_t( passedt )
-- ----------------------------------------------------------------------------
-- Handle place=islet as place=island
-- ----------------------------------------------------------------------------
    if ( passedt.place == "islet" ) then
       passedt.place = "island"
    end

-- ----------------------------------------------------------------------------
-- Handle place=quarter
-- ----------------------------------------------------------------------------
    if ( passedt.place == "quarter" ) then
       passedt.place = "neighbourhood"
    end

-- ----------------------------------------------------------------------------
-- Handle natural=cape etc. as place=locality if no other place tag.
-- ----------------------------------------------------------------------------
    if ((( passedt.natural == "cape"      ) or
         ( passedt.natural == "headland"  ) or
         ( passedt.natural == "peninsula" ) or
         ( passedt.natural == "sound"     ) or
         ( passedt.natural == "point"     )) and
        (( passedt.place == nil         ) or
         ( passedt.place == ""          ))) then
       passedt.place = "locality"
    end
end -- consolidate_place_t()