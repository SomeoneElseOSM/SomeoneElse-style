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


function consolidate_lua_01_t( passedt )
-- ----------------------------------------------------------------------------
-- Show natural=bracken as scrub
-- ----------------------------------------------------------------------------
   if ( passedt.natural  == "bracken" ) then
      passedt.natural = "scrub"
   end

-- ----------------------------------------------------------------------------
-- Show natural=col as natural=saddle
-- ----------------------------------------------------------------------------
   if ( passedt.natural  == "col" ) then
      passedt.natural = "saddle"
   end
 
-- ----------------------------------------------------------------------------
-- Render old names on farmland etc.
-- ----------------------------------------------------------------------------
   if ((( passedt.landuse  == "farmland"       )  or
        ( passedt.natural  == "grassland"      )  or
        ( passedt.natural  == "scrub"          )) and
       (( passedt.name     == nil              )  or
        ( passedt.name     == ""               )) and
       (  passedt.old_name ~= nil               ) and
       (  passedt.old_name ~= ""                )) then
      passedt.name = "(" .. passedt.old_name .. ")"
      passedt.old_name = nil
   end

-- ----------------------------------------------------------------------------
-- If "visibility" is set but "trail_visibility" is not, use "visibility".
-- ----------------------------------------------------------------------------
   if ((  passedt.visibility       ~= nil  ) and
       (  passedt.visibility       ~= ""   ) and
       (( passedt.trail_visibility == nil )  or
        ( passedt.trail_visibility == ""  ))) then
      passedt.trail_visibility = passedt.visibility
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
   if (( passedt.trail_visibility == "no"         )  or
       ( passedt.trail_visibility == "none"       )  or
       ( passedt.trail_visibility == "nil"        )  or
       ( passedt.trail_visibility == "horrible"   )  or
       ( passedt.trail_visibility == "very_bad"   )  or
       ( passedt.trail_visibility == "bad"        )  or
       ( passedt.trail_visibility == "poor"       )  or
       ( passedt["foot:physical"]    == "no"         )) then
      passedt.trail_visibility = "bad"
   end

   if ((   passedt.trail_visibility == "intermediate"  )  or
       (   passedt.trail_visibility == "intermittent"  )  or
       (   passedt.trail_visibility == "indistinct"    )  or
       (   passedt.trail_visibility == "medium"        )  or
       (   passedt.trail_visibility == "low"           )  or
       (   passedt.overgrown        == "yes"           )  or
       (   passedt.obstacle         == "vegetation"    )  or
       ((( passedt.trail_visibility == nil           )    or
         ( passedt.trail_visibility == ""            ))   and
        (  passedt.informal         == "yes"          ))) then
      passedt.trail_visibility = "intermediate"
   end

-- ----------------------------------------------------------------------------
-- If we have an est_width but no width, use the est_width
-- ----------------------------------------------------------------------------
   if ((  passedt.est_width ~= nil   ) and
       (  passedt.est_width ~= ""    ) and
       (( passedt.width     == nil  )  or
        ( passedt.width     == ""   ))) then
      passedt.width = passedt.est_width
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
   if ( passedt.highway == "scramble"  ) then
      passedt.highway = "path"

      if ( passedt.sac_scale == nil  ) then
         passedt.sac_scale = "demanding_alpine_hiking"
      end
   end

   if ((  passedt.highway          ~= nil    ) and
       (  passedt.highway          ~= ""     ) and
       (  passedt.scramble         == "yes"  ) and
       (( passedt.sac_scale        == nil   )  or
        ( passedt.sac_scale        == ""    )) and
       (( passedt.trail_visibility == nil   )  or
        ( passedt.trail_visibility == ""    ))) then
      passedt.trail_visibility = "intermediate"
   end

-- ----------------------------------------------------------------------------
-- Suppress non-designated very low-visibility paths
-- Various low-visibility trail_visibility values have been set to "bad" above
-- to suppress from normal display.
-- The "bridge" check (on trail_visibility, not sac_scale) is because if 
-- there's really a bridge there, surely you can see it?
-- ----------------------------------------------------------------------------
   if ((  passedt.highway          ~= nil    ) and
       (  passedt.highway          ~= ""     ) and
       (( passedt.designation      == nil   )  or
        ( passedt.designation      == ""    )) and
       (  passedt.trail_visibility == "bad"  )) then
      if ((( tonumber(passedt.width) or 0 ) >=  2 ) or
          ( passedt.width == "2 m"                ) or
          ( passedt.width == "2.5 m"              ) or
          ( passedt.width == "3 m"                ) or
          ( passedt.width == "4 m"                )) then
         if ( passedt.bridge == nil ) then
            passedt.highway = "badpathwide"
         else
            passedt.highway = "intpathwide"
         end
      else
         if ( passedt.bridge == nil ) then
            passedt.highway = "badpathnarrow"
         else
            passedt.highway = "intpathnarrow"
         end
      end
   end

-- ----------------------------------------------------------------------------
-- Various low-visibility trail_visibility values have been set to "bad" above.
-- ----------------------------------------------------------------------------
   if (( passedt.highway ~= nil   ) and
       ( passedt.highway ~= ""    ) and
       ( passedt.ladder  == "yes" )) then
      passedt.highway = "steps"
      passedt.ladder  = nil
   end

-- ----------------------------------------------------------------------------
-- Where a wide width is specified on a normally narrow path, render as wider
--
-- Note that "steps" and "footwaysteps" are unchanged by the 
-- pathwide / path choice below:
-- ----------------------------------------------------------------------------
   if (( passedt.highway == "footway"   ) or 
       ( passedt.highway == "bridleway" ) or 
       ( passedt.highway == "cycleway"  ) or
       ( passedt.highway == "path"      )) then
      if ((( tonumber(passedt.width) or 0 ) >=  2 ) or
          ( passedt.width == "2 m"                ) or
          ( passedt.width == "2.5 m"              ) or
          ( passedt.width == "3 m"                ) or
          ( passedt.width == "4 m"                )) then
         if (( passedt.trail_visibility == "bad"          )  or
             ( passedt.trail_visibility == "intermediate" )) then
            passedt.highway = "intpathwide"
         else
            passedt.highway = "pathwide"
         end
      else
         if (( passedt.trail_visibility == "bad"          )  or
             ( passedt.trail_visibility == "intermediate" )) then
            passedt.highway = "intpathnarrow"
         else
            passedt.highway = "pathnarrow"
         end
      end
   end

-- ----------------------------------------------------------------------------
-- Where a narrow width is specified on a normally wide track, render as
-- narrower
-- ----------------------------------------------------------------------------
   if ( passedt.highway == "track" ) then
      if (( passedt.width == nil ) or
          ( passedt.width == ""  )) then
         passedt.width = "2"
      end

      if ((( tonumber(passedt.width) or 0 ) >= 2 ) or
          (  passedt.width == "2 m"              ) or
          (  passedt.width == "2.5 m"            ) or
          (  passedt.width == "2.5m"             ) or
          (  passedt.width == "3 m"              ) or
          (  passedt.width == "3 metres"         ) or
          (  passedt.width == "3.5 m"            ) or
          (  passedt.width == "4 m"              ) or
          (  passedt.width == "5m"               )) then
         if (( passedt.trail_visibility == "bad"          )  or
             ( passedt.trail_visibility == "intermediate" )) then
            passedt.highway = "intpathwide"
         else
            passedt.highway = "pathwide"
         end
      else
         if (( passedt.trail_visibility == "bad"          )  or
             ( passedt.trail_visibility == "intermediate" )) then
            passedt.highway = "intpathnarrow"
         else
            passedt.highway = "pathnarrow"
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
   if ((  passedt.designation == nil                        ) and
       (( passedt.sac_scale   == "demanding_alpine_hiking" )  or
        ( passedt.sac_scale   == "difficult_alpine_hiking" ))) then
      if ((( tonumber(passedt.width) or 0 ) >=  2 ) or
          ( passedt.width == "2 m"                ) or
          ( passedt.width == "2.5 m"              ) or
          ( passedt.width == "3 m"                ) or
          ( passedt.width == "4 m"                )) then
         passedt.highway = "badpathwide"
      else
         passedt.highway = "badpathnarrow"
      end
   end

-- ----------------------------------------------------------------------------
-- Consolidate some access values to make later processing easier.
-- This code is used for both raster and vector processing.
-- On raster, the OSM Carto derivative that I'm using still tries to
-- second-guess paths as footway or cycleway.  We don't want to do this - set
-- "designated" to "yes"
--
-- First - lose "access=designated", which is meaningless.
-- ----------------------------------------------------------------------------
   if ( passedt.access == "designated" ) then
      passedt.access = nil
   end

   if ( passedt.foot == "designated" ) then
      passedt.foot = "yes"
   end

   if ( passedt.bicycle == "designated" ) then
      passedt.bicycle = "yes"
   end

   if ( passedt.horse == "designated" ) then
      passedt.horse = "yes"
   end

-- ----------------------------------------------------------------------------
-- Handle dodgy access tags.  Note that this doesn't affect my "designation"
-- processing, but may be used by the main style, as "foot", "bicycle" and 
-- "horse" are all in as columns.
-- ----------------------------------------------------------------------------
   if (passedt["access:foot"] == "yes") then
      passedt["access:foot"] = nil
      passedt.foot = "yes"
   end

   if (passedt["access:bicycle"] == "yes") then
      passedt["access:bicycle"] = nil
      passedt.bicycle = "yes"
   end

   if (passedt["access:horse"] == "yes") then
      passedt["access:horse"] = nil
      passedt.horse = "yes"
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
   if ((  passedt.highway == "pathnarrow" ) and
       (( passedt.foot    == "private"   )  or
        ( passedt.foot    == "no"        )) and
       (( passedt.bicycle == nil         )  or
        ( passedt.bicycle == ""          )  or
        ( passedt.bicycle == "private"   )  or
        ( passedt.bicycle == "no"        )) and
       (( passedt.horse   == nil         )  or
        ( passedt.horse   == ""          )  or
        ( passedt.horse   == "private"   )  or
        ( passedt.horse   == "no"        ))) then
      passedt.access = "no"
   end

-- ----------------------------------------------------------------------------
-- When handling TROs etc. we test for "no", not private, hence this change:
-- ----------------------------------------------------------------------------
   if ( passedt.access == "private" ) then
      passedt.access = "no"
   end

   if ( passedt.foot == "private" ) then
      passedt.foot = "no"
   end

   if ( passedt.bicycle == "private" ) then
      passedt.bicycle = "no"
   end

   if ( passedt.horse == "private" ) then
      passedt.horse = "no"
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
   if ((  passedt.highway == "unclassified"  ) and
       (( passedt.surface == "unpaved"      )  or 
        ( passedt.surface == "gravel"       ))) then
      passedt.highway = "unpaved"
   end

   if ((( passedt.highway == "residential"  )  or
        ( passedt.highway == "service"      )) and
       (( passedt.surface == "unpaved"      )  or 
        ( passedt.surface == "gravel"       ))) then
      passedt.highway = "track"
   end

   if (( passedt.designation == "unclassified_county_road"                       ) or
       ( passedt.designation == "unclassified_country_road"                      ) or
       ( passedt.designation == "unclassified_highway"                           ) or
       ( passedt.designation == "unclassified_road"                              ) or
       ( passedt.designation == "unmade_road"                                    ) or
       ( passedt.designation == "public_highway"                                 ) or 
       ( passedt.designation == "unclassified_highway;public_footpath"           ) or 
       ( passedt.designation == "unmade_road"                                    ) or 
       ( passedt.designation == "adopted"                                        ) or 
       ( passedt.designation == "unclassified_highway;public_bridleway"          ) or 
       ( passedt.designation == "adopted highway"                                ) or 
       ( passedt.designation == "adopted_highway"                                ) or 
       ( passedt.designation == "unclassified_highway;byway_open_to_all_traffic" ) or 
       ( passedt.designation == "adopted_highway;public_footpath"                ) or 
       ( passedt.designation == "tertiary_highway"                               ) or 
       ( passedt.designation == "public_road"                                    ) or
       ( passedt.designation == "quiet_lane;unclassified_highway"                ) or
       ( passedt.designation == "unclassified_highway;quiet_lane"                )) then
      if (( passedt.highway == "steps"         ) or 
          ( passedt.highway == "intpathnarrow" ) or
          ( passedt.highway == "pathnarrow"    )) then
          passedt.highway = "ucrnarrow"
      else
         if (( passedt.highway == "service"     ) or 
             ( passedt.highway == "road"        ) or
             ( passedt.highway == "track"       ) or
             ( passedt.highway == "intpathwide" ) or
             ( passedt.highway == "pathwide"    )) then
             passedt.highway = "ucrwide"
         end
      end

      append_prow_ref_t( passedt )
   end

   if (( passedt.designation == "byway_open_to_all_traffic" ) or
       ( passedt.designation == "public_byway"              ) or 
       ( passedt.designation == "byway"                     ) or
       ( passedt.designation == "carriageway"               )) then
      if (( passedt.highway == "steps"         ) or 
          ( passedt.highway == "intpathnarrow" ) or
          ( passedt.highway == "pathnarrow"    )) then
          passedt.highway = "boatnarrow"
          passedt.designation = "byway_open_to_all_traffic"
      else
         if (( passedt.highway == "service"     ) or 
             ( passedt.highway == "road"        ) or
             ( passedt.highway == "track"       ) or
             ( passedt.highway == "intpathwide" ) or
             ( passedt.highway == "pathwide"    )) then
             passedt.highway = "boatwide"
             passedt.designation = "byway_open_to_all_traffic"
         end
      end

      append_prow_ref_t( passedt )
   end

-- ----------------------------------------------------------------------------
-- Note that a designated restricted_byway up some steps would be rendered
-- as a restricted_byway.  I've never seen one though.
-- There is special processing for "public footpath" and "public_bridleway"
-- steps (see below) and non-designated steps are rendered as is by the
-- stylesheet.
-- ----------------------------------------------------------------------------
   if (( passedt.designation == "restricted_byway"                        ) or
       ( passedt.designation == "public_right_of_way"                     ) or
       ( passedt.designation == "unclassified_highway;restricted_byway"   ) or 
       ( passedt.designation == "unknown_byway"                           ) or 
       ( passedt.designation == "public_way"                              ) or 
       ( passedt.designation == "tertiary_highway;restricted_byway"       ) or 
       ( passedt.designation == "orpa"                                    ) or
       ( passedt.designation == "restricted_byway;quiet_lane"             )) then
      if (( passedt.highway == "steps"         ) or 
          ( passedt.highway == "intpathnarrow" ) or
          ( passedt.highway == "pathnarrow"    )) then
         passedt.highway = "rbynarrow"
         passedt.designation = "restricted_byway"
      else
         if (( passedt.highway == "service"     ) or 
             ( passedt.highway == "road"        ) or
             ( passedt.highway == "track"       ) or
             ( passedt.highway == "intpathwide" ) or
             ( passedt.highway == "pathwide"    )) then
            passedt.highway = "rbywide"
            passedt.designation = "restricted_byway"
         end
      end

      append_prow_ref_t( passedt )
   end

-- ----------------------------------------------------------------------------
-- If called from raster, when a value is changed we get called again.  
-- That's why there's a check for "bridlewaysteps" below
-- "before the only place that it can be set".
-- ----------------------------------------------------------------------------
   if (( passedt.designation == "public_bridleway"                    ) or
       ( passedt.designation == "bridleway"                           ) or 
       ( passedt.designation == "tertiary_highway;public_bridleway"   ) or 
       ( passedt.designation == "public_bridleway;public_cycleway"    ) or 
       ( passedt.designation == "public_cycleway;public_bridleway"    ) or 
       ( passedt.designation == "public_bridleway;public_footpath"    )) then
      if (( passedt.highway == "intpathnarrow" ) or
          ( passedt.highway == "pathnarrow"    )) then
         if (( passedt.trail_visibility == "bad"          )  or
             ( passedt.trail_visibility == "intermediate" )) then
            passedt.highway = "intbridlewaynarrow"
         else
            passedt.highway = "bridlewaynarrow"
         end
      else
         if (( passedt.highway == "steps"          ) or
             ( passedt.highway == "bridlewaysteps" )) then
            passedt.highway = "bridlewaysteps"
         else
            if (( passedt.highway == "service"     ) or 
                ( passedt.highway == "road"        ) or
                ( passedt.highway == "track"       ) or
                ( passedt.highway == "intpathwide" ) or
                ( passedt.highway == "pathwide"    )) then
               if (( passedt.trail_visibility == "bad"          )  or
                   ( passedt.trail_visibility == "intermediate" )) then
                  passedt.highway = "intbridlewaywide"
               else
                  passedt.highway = "bridlewaywide"
               end
            end
         end
      end

      append_prow_ref_t( passedt )
   end

-- ----------------------------------------------------------------------------
-- On raster, when a value is changed we get called again.  That's why there's
-- a check for "footwaysteps" below "before the only place that it can be set".
--
-- Rights of way for people on foot are designated as:
-- England and Wales: public_footpath
-- Scotland: core_path (ish - more general acess rights exist)
-- Northern Ireland: public_footpath or PROW (actually "footpath" in law)
-- ----------------------------------------------------------------------------
   if (( passedt.designation == "public_footpath"                        ) or
       ( passedt.designation == "core_path"                              ) or 
       ( passedt.designation == "footpath"                               ) or 
       ( passedt.designation == "public_footway"                         ) or 
       ( passedt.designation == "public_footpath;permissive_bridleway"   ) or 
       ( passedt.designation == "public_footpath;public_cycleway"        ) or
       ( passedt.designation == "PROW"                                   ) or
       ( passedt.designation == "access_land"                            )) then
      if (( passedt.highway == "intpathnarrow" ) or
          ( passedt.highway == "pathnarrow"    )) then
         if (( passedt.trail_visibility == "bad"          )  or
             ( passedt.trail_visibility == "intermediate" )) then
            passedt.highway = "intfootwaynarrow"
         else
            passedt.highway = "footwaynarrow"
         end
      else
         if (( passedt.highway == "steps"        ) or
             ( passedt.highway == "footwaysteps" )) then
            passedt.highway = "footwaysteps"
         else
            if (( passedt.highway == "service"     ) or 
                ( passedt.highway == "road"        ) or
                ( passedt.highway == "track"       ) or
                ( passedt.highway == "intpathwide" ) or
                ( passedt.highway == "pathwide"    )) then
               if (( passedt.trail_visibility == "bad"          )  or
                   ( passedt.trail_visibility == "intermediate" )) then
                  passedt.highway = "intfootwaywide"
               else
                  passedt.highway = "footwaywide"
               end
            end
         end
      end

      append_prow_ref_t( passedt )
   end

-- ----------------------------------------------------------------------------
-- If something is still "track" by this point change it to pathwide.
-- ----------------------------------------------------------------------------
   if ( passedt.highway == "track" ) then
      if (( passedt.trail_visibility == "bad"          )  or
          ( passedt.trail_visibility == "intermediate" )) then
         passedt.highway = "intpathwide"
      else
         passedt.highway = "pathwide"
      end
   end

-- ----------------------------------------------------------------------------
-- Treat access=permit as access=no (which is what we have set "private" to 
-- above).
-- ----------------------------------------------------------------------------
   if (( passedt.access  == "permit"       ) or
       ( passedt.access  == "agricultural" ) or
       ( passedt.access  == "forestry"     ) or
       ( passedt.access  == "delivery"     ) or
       ( passedt.access  == "military"     )) then
      passedt.access = "no"
   end

   if ( passedt.access  == "customers" ) then
      passedt.access = "destination"
   end

-- ----------------------------------------------------------------------------
-- Don't make driveways with a designation disappear.
-- ----------------------------------------------------------------------------
   if ((    passedt.service     == "driveway"                     ) and
       ((   passedt.designation == "public_footpath"             )  or
        (   passedt.designation == "public_bridleway"            )  or
        (   passedt.designation == "restricted_byway"            )  or
        (   passedt.designation == "byway_open_to_all_traffic"   )  or
        (   passedt.designation == "unclassified_county_road"    )  or
        (   passedt.designation == "unclassified_country_road"   )  or
        (   passedt.designation == "unclassified_highway"        ))) then
      passedt.service = nil
   end

-- ----------------------------------------------------------------------------
-- If motor_vehicle=no is set on a BOAT, it's probably a TRO, so display as
-- an RBY instead
-- ----------------------------------------------------------------------------
   if (( passedt.highway       == "boatwide"    )  and
       ( passedt.motor_vehicle == "no"          )) then
      passedt.highway = "rbywide"
   end

   if (( passedt.highway       == "boatnarrow"  )  and
       ( passedt.motor_vehicle == "no"          )) then
      passedt.highway = "rbynarrow"
   end

-- ----------------------------------------------------------------------------
-- Try and detect genuinely closed public footpaths, bridleways (not just those
-- closed to motor traffic etc.).  Examples with "access=no/private" are
-- picked up below; we need to make sure that those that do not get an
-- access=private tag first.
-- ----------------------------------------------------------------------------
   if ((( passedt.access      == nil                         )   or
        ( passedt.access      == ""                          ))  and
       (( passedt.designation == "public_footpath"           )   or
        ( passedt.designation == "public_bridleway"          )   or
        ( passedt.designation == "restricted_byway"          )   or
        ( passedt.designation == "byway_open_to_all_traffic" )   or
        ( passedt.designation == "unclassified_county_road"  )   or
        ( passedt.designation == "unclassified_country_road" )   or
        ( passedt.designation == "unclassified_highway"      ))  and
       (  passedt.foot        == "no"                         )) then
      passedt.access  = "no"
   end

-- ----------------------------------------------------------------------------
-- The extra information "and"ed with "public_footpath" below checks that
-- "It's access=private and designation=public_footpath, and ordinarily we'd
-- just remove the access=private tag as you ought to be able to walk there,
-- unless there isn't foot=yes/designated to say you can, or there is an 
-- explicit foot=no".
-- ----------------------------------------------------------------------------
   if (((   passedt.access      == "no"                          )  or
        (   passedt.access      == "destination"                 )) and
       (((( passedt.designation == "public_footpath"           )    or
          ( passedt.designation == "public_bridleway"          )    or
          ( passedt.designation == "restricted_byway"          )    or
          ( passedt.designation == "byway_open_to_all_traffic" )    or
          ( passedt.designation == "unclassified_county_road"  )    or
          ( passedt.designation == "unclassified_country_road" )    or
          ( passedt.designation == "unclassified_highway"      ))   and
         (  passedt.foot        ~= nil                          )   and
         (  passedt.foot        ~= ""                           )   and
         (  passedt.foot        ~= "no"                         ))  or
        ((( passedt.highway     == "pathnarrow"                )    or
          ( passedt.highway     == "pathwide"                  )    or
          ( passedt.highway     == "intpathnarrow"             )    or
          ( passedt.highway     == "intpathwide"               )    or
          ( passedt.highway     == "service"                   ))   and
         (( passedt.foot        == "permissive"                )    or
          ( passedt.foot        == "yes"                       ))))) then
      passedt.access  = nil
   end
end -- consolidate_lua_01_t( passedt )


function consolidate_lua_02_t( passedt )
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
   if ((   passedt.boundary      == "protected_area"                      ) and
       ((  passedt.designation   == "national_park"                      )  or 
        (  passedt.designation   == "area_of_outstanding_natural_beauty" )  or
        (  passedt.designation   == "national_scenic_area"               ))) then
      passedt.boundary = "national_park"
      passedt.protect_class = nil
   end

-- ----------------------------------------------------------------------------
-- Access land is shown with a high-zoom yellow border (to contrast with the 
-- high-zoom green border of nature reserves) and with a low-opacity 
-- yellow fill at all zoom levels (to contrast with the low-opacity green fill
-- at low zoom levels of nature reserves).
-- ----------------------------------------------------------------------------
   if ((   passedt.designation   == "access_land"      )  and
       ((( passedt.boundary      == nil              )    or
         ( passedt.boundary      == ""               ))   or
        (  passedt.boundary      == "protected_area"  ))  and
       ((  passedt.highway       == nil               )   or
        (  passedt.highway       == ""                ))) then
      passedt.boundary = "access_land"
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
   if (((  passedt.boundary      == "protected_area"            )   and
        (( passedt.protect_class == "1"                        )    or
         ( passedt.protect_class == "2"                        )    or
         ( passedt.protect_class == "4"                        )    or
         ( passedt.designation   == "national_nature_reserve"  )    or
         ( passedt.designation   == "local_nature_reserve"     )    or
         ( passedt.designation   == "Nature Reserve"           )    or
         ( passedt.designation   == "Marine Conservation Zone" ))) and
       (   passedt.leisure       == nil                          )) then
      passedt.leisure = "nature_reserve"
   end

-- ----------------------------------------------------------------------------
-- Show grass schoolyards as green
-- ----------------------------------------------------------------------------
   if (( passedt.leisure == "schoolyard" ) and
       ( passedt.surface == "grass"      )) then
      passedt.landuse = "grass"
      passedt.leisure = nil
      passedt.surface = nil
   end

-- ----------------------------------------------------------------------------
-- "Nature reserve" doesn't say anything about what's inside; but one UK OSMer 
-- changed "landuse" to "surface" (changeset 98859964).  This undoes that.
-- ----------------------------------------------------------------------------
   if (( passedt.leisure == "nature_reserve" ) and
       ( passedt.surface == "grass"          )) then
      passedt.landuse = "grass"
      passedt.surface = nil
   end

-- ----------------------------------------------------------------------------
-- Treat landcover=grass as landuse=grass
-- Also landuse=college_court, flowerbed
-- ----------------------------------------------------------------------------
   if (( passedt.landcover == "grass"         ) or
       ( passedt.landuse   == "college_court" ) or
       ( passedt.landuse   == "flowerbed"     )) then
      passedt.landcover = nil
      passedt.landuse = "grass"
   end

-- ----------------------------------------------------------------------------
-- Treat natural=grass as landuse=grass 
-- if there is no other more appropriate tag
-- ----------------------------------------------------------------------------
   if (( passedt.natural  == "grass"  ) and
       ((( passedt.landuse == nil    )  or
         ( passedt.landuse == ""     )) and
        (( passedt.leisure == nil    )  or
         ( passedt.leisure == ""     )) and
        (( passedt.aeroway == nil    )  or
         ( passedt.aeroway == ""     )))) then
      passedt.landuse = "grass"
   end

-- ----------------------------------------------------------------------------
-- Treat natural=garden and natural=plants as leisure=garden
-- if there is no other more appropriate tag.
-- The "barrier" check is to avoid linear barriers with this tag as well 
-- becoming area ones unexpectedly
-- ----------------------------------------------------------------------------
   if ((( passedt.natural == "garden"     )   or
        ( passedt.natural == "plants"     )   or
        ( passedt.natural == "flower_bed" ))  and
       (( passedt.landuse == nil          )   and
        ( passedt.leisure == nil          )   and
        ( passedt.barrier == nil          ))) then
      passedt.leisure = "garden"
   end

-- ----------------------------------------------------------------------------
-- Render various synonyms for leisure=common.
-- ----------------------------------------------------------------------------
   if (( passedt.landuse          == "common"   ) or
       ( passedt.leisure          == "common"   ) or
       ( passedt.designation      == "common"   ) or
       ( passedt.amenity          == "common"   ) or
       ( passedt.protection_title == "common"   )) then
      passedt.leisure = "common"
      passedt.landuse = nil
      passedt.amenity = nil
   end

-- ----------------------------------------------------------------------------
-- Render quiet lanes as living streets.
-- This is done because it's a difference I don't want to draw attention to -
-- they aren't "different enough to make them render differently".
-- ----------------------------------------------------------------------------
   if ((( passedt.highway     == "tertiary"                          )  or
        ( passedt.highway     == "unclassified"                      )  or
        ( passedt.highway     == "residential"                       )) and
       (( passedt.designation == "quiet_lane"                        )  or
        ( passedt.designation == "quiet_lane;unclassified_highway"   )  or
        ( passedt.designation == "unclassified_highway;quiet_lane"   ))) then
      passedt.highway = "living_street"
   end

end -- consolidate_lua_02_t( passedt )


function consolidate_lua_03_t( passedt )
-- ----------------------------------------------------------------------------
-- Render narrow tertiary roads as unclassified
-- ----------------------------------------------------------------------------
   if ((  passedt.highway    == "tertiary"  )  and
       (( passedt.oneway     == nil        )   or
        ( passedt.oneway     == ""         ))  and
       (( passedt.junction   == nil        )   or
        ( passedt.junction   == ""         ))  and
       ((( tonumber(passedt.width)    or 4 ) <=  3 ) or
        (( tonumber(passedt.maxwidth) or 4 ) <=  3 ))) then
      passedt.highway = "unclassified"
   end

-- ----------------------------------------------------------------------------
-- Render bus guideways as "a sort of railway" rather than in their own
-- highway layer.
-- ----------------------------------------------------------------------------
   if (passedt.highway == "bus_guideway") then
      passedt.highway = nil
      passedt.railway = "bus_guideway"
   end

-- ----------------------------------------------------------------------------
-- Render bus-only service roads tagged as "highway=busway" as service roads.
-- ----------------------------------------------------------------------------
   if ( passedt.highway == "busway" ) then
      passedt.highway = "service"
   end

-- ----------------------------------------------------------------------------
-- Bridge types - only some types (including "yes") are selected
-- ----------------------------------------------------------------------------
   if (( passedt.bridge == "aqueduct"           ) or
       ( passedt.bridge == "bailey"             ) or
       ( passedt.bridge == "boardwalk"          ) or
       ( passedt.bridge == "building_passage"   ) or
       ( passedt.bridge == "cantilever"         ) or
       ( passedt.bridge == "chain"              ) or
       ( passedt.bridge == "covered"            ) or
       ( passedt.bridge == "foot"               ) or
       ( passedt.bridge == "footbridge"         ) or
       ( passedt.bridge == "gangway"            ) or
       ( passedt.bridge == "low_water_crossing" ) or
       ( passedt.bridge == "movable"            ) or
       ( passedt.bridge == "pier"               ) or
       ( passedt.bridge == "plank"              ) or
       ( passedt.bridge == "plank_bridge"       ) or
       ( passedt.bridge == "pontoon"            ) or
       ( passedt.bridge == "rope"               ) or
       ( passedt.bridge == "swing"              ) or
       ( passedt.bridge == "trestle"            ) or
       ( passedt.bridge == "undefined"          ) or
       ( passedt.bridge == "viaduct"            )) then
      passedt.bridge = "yes"
   end

-- ----------------------------------------------------------------------------
-- Remove some combinations of bridge
-- ----------------------------------------------------------------------------
   if ((  passedt.bridge  == "yes"          ) and
       (( passedt.barrier == "cattle_grid" )  or
        ( passedt.barrier == "stile"       ))) then
      passedt.barrier = nil
   end

-- ----------------------------------------------------------------------------
-- Tunnel values - render as "yes" if appropriate.
-- ----------------------------------------------------------------------------
   if (( passedt.tunnel == "culvert"             ) or
       ( passedt.tunnel == "covered"             ) or
       ( passedt.tunnel == "avalanche_protector" ) or
       ( passedt.tunnel == "passage"             ) or
       ( passedt.tunnel == "1"                   ) or
       ( passedt.tunnel == "cave"                ) or
       ( passedt.tunnel == "flooded"             ) or
       ( passedt.tunnel == "building_passage"    )) then
      passedt.tunnel = "yes"
   end

-- ----------------------------------------------------------------------------
-- Covered values - render as "yes" if appropriate.
-- ----------------------------------------------------------------------------
   if (( passedt.covered == "arcade"           ) or
       ( passedt.covered == "covered"          ) or
       ( passedt.covered == "colonnade"        ) or
       ( passedt.covered == "building_passage" ) or
       ( passedt.covered == "building_arcade"  ) or
       ( passedt.covered == "roof"             ) or
       ( passedt.covered == "portico"          )) then
      passedt.covered = "yes"
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
   if (( passedt.amenity          == "fuel" ) and
       ( passedt["fuel:electricity"] == "yes"  )  and
       ( passedt["fuel:diesel"]      == nil    )) then
      passedt.amenity = "charging_station"
   end

   if (( passedt.waterway         == "fuel" ) and
       ( passedt["fuel:electricity"] == "yes"  )) then
      passedt.amenity = "charging_station"
      passedt.waterway = nil
   end

   if (( passedt.amenity == "vending_machine" ) and
       ( passedt.vending == "fuel"            )  and
       ( passedt.fuel    == "UL91"            )) then
      passedt.amenity = "fuel"
   end

   if ( passedt.aeroway == "fuel" ) then
      passedt.aeroway = nil
      passedt.amenity = "fuel"
   end

   if ( passedt.waterway == "fuel" ) then
      passedt.amenity = "fuel_w"
      passedt.waterway = nil
   end

   if (( passedt.amenity             == "fuel" ) and
       ( passedt["fuel:electricity"] == "yes"  )  and
       ( passedt["fuel:diesel"]      == "yes"  )) then
      passedt.amenity = "fuel_e"
   end

   if ((  passedt.amenity     == "fuel"  ) and
       (( passedt["fuel:H2"]  == "yes"  )  or
        ( passedt["fuel:LH2"] == "yes"  ))) then
      passedt.amenity = "fuel_h"
   end

   if ((  passedt.amenity     == "fuel"  ) and
       (( passedt.LPG         == "yes"  )  or
        ( passedt.fuel        == "lpg"  )  or
        ( passedt["fuel:lpg"] == "yes"  ))) then
      passedt.amenity = "fuel_l"
   end

-- ----------------------------------------------------------------------------
-- Aviaries in UK / IE seem to be always within a zoo or larger attraction, 
-- and not "zoos" in their own right.
-- ----------------------------------------------------------------------------
   if ((  passedt.zoo     == "aviary"  )  and
       (( passedt.amenity == nil      )   or
        ( passedt.amenity == ""       ))) then
      passedt.amenity = "zooaviary"
      passedt.tourism = nil
      passedt.zoo = nil
   end

-- ----------------------------------------------------------------------------
-- Some zoos are mistagged with extra "animal=attraction" or "zoo=enclosure" 
-- tags, so remove those.
-- ----------------------------------------------------------------------------
   if ((( passedt.attraction == "animal"    )  or
        ( passedt.zoo        == "enclosure" )) and
       (  passedt.tourism == "zoo"           )) then
      passedt.attraction = nil
      passedt.zoo = nil
   end

-- ----------------------------------------------------------------------------
-- Retag any remaining animal attractions or zoo enclosures for rendering.
-- ----------------------------------------------------------------------------
   if ((( passedt.attraction == "animal"    )  or
        ( passedt.zoo        == "enclosure" )) and
       (( passedt.amenity    == nil         )  or
        ( passedt.amenity    == ""          ))) then
      passedt.amenity = "zooenclosure"
      passedt.attraction = nil
      passedt.zoo = nil
   end

-- ----------------------------------------------------------------------------
-- Bridge structures - display as building=roof.
-- Also farmyard "bunker silos" and canopies, and natural arches.
-- Also railway traversers and more.
-- ----------------------------------------------------------------------------
   if ((    passedt.man_made         == "bridge"          ) or
       (    passedt.natural          == "arch"            ) or
       (    passedt.man_made         == "bunker_silo"     ) or
       (    passedt.amenity          == "feeding_place"   ) or
       (    passedt.railway          == "traverser"       ) or
       (    passedt.railway          == "wash"            ) or
       (    passedt.building         == "canopy"          ) or
       (    passedt.building         == "car_port"        ) or
       (((( passedt["disused:building"] ~= nil            )    and
          ( passedt["disused:building"] ~= ""             ))   or
         (  passedt.amenity          == "parcel_locker" )   or
         (  passedt.amenity          == "zooaviary"     )   or
         (  passedt.animal           == "horse_walker"  )   or
         (  passedt.leisure          == "bleachers"     )   or
         (  passedt.leisure          == "bandstand"     )) and
        ((  passedt.building         == nil             )  and
         (  passedt.building         == ""              ))) or
       (    passedt["building:type"]    == "canopy"          ) or
       ((   passedt.covered          == "roof"           )  and
        ((  passedt.building         == nil             )   or
         (  passedt.building         == ""              ))  and
        ((  passedt.highway          == nil             )   or
         (  passedt.highway          == ""              ))  and
        ((  passedt.tourism          == nil             )   or
         (  passedt.tourism          == ""              )))) then
      passedt.building      = "roof"
      passedt["building:type"] = nil
   end

-- ----------------------------------------------------------------------------
-- Ensure that allegedly operational windmills are treated as such and not as
-- "historic".
-- ----------------------------------------------------------------------------
   if (( passedt.man_made == "watermill") or
       ( passedt.man_made == "windmill" )) then
      if (( passedt.disused              == "yes"  ) or
          ( passedt["watermill:disused"] == "yes"  ) or
          ( passedt["windmill:disused"]  == "yes"  )) then
         passedt.historic = passedt.man_made
         passedt.man_made = nil
      else
         passedt.historic = nil
      end
   end

   if ((( passedt["disused:man_made"] == "watermill")  or
        ( passedt["disused:man_made"] == "windmill" )) and
       (( passedt.amenity          == nil        )  or
        ( passedt.amenity          == ""         )) and
       (( passedt.man_made         == nil        )  or
        ( passedt.man_made         == ""         )) and
       (( passedt.shop             == nil        )  or
        ( passedt.shop             == ""         ))) then
      passedt.historic = passedt["disused:man_made"]
      passedt["disused:man_made"] = nil
   end

-- ----------------------------------------------------------------------------
-- Render (windmill buildings and former windmills) that are not something 
-- else as historic windmills.
-- ----------------------------------------------------------------------------
   if ((  passedt.historic == "ruins"      ) and
       (( passedt.ruins    == "watermill" )  or
        ( passedt.ruins    == "windmill"  ))) then
      passedt.historic = passedt.ruins
      passedt.ruins = "yes"
   end

   if (((   passedt.building == "watermill"        )  or
        (   passedt.building == "former_watermill" )) and
       (((  passedt.amenity  == nil                )  or
         (  passedt.amenity  == ""                 )) and
        ((  passedt.man_made == nil                )  or
         (  passedt.man_made == ""                 )) and
        ((  passedt.historic == nil                )  or
         (  passedt.historic == ""                 )  or
         (  passedt.historic == "restoration"      )  or
         (  passedt.historic == "heritage"         )  or
         (  passedt.historic == "industrial"       )  or
         (  passedt.historic == "tower"            )))) then
      passedt.historic = "watermill"
   end

   if (((   passedt.building == "windmill"        )  or
        (   passedt.building == "former_windmill" )) and
       (((  passedt.amenity  == nil               )  or
         (  passedt.amenity  == ""                )) and
        ((  passedt.man_made == nil               )  or
         (  passedt.man_made == ""                )) and
        ((  passedt.historic == nil               )  or
         (  passedt.historic == ""                )  or
         (  passedt.historic == "restoration"     )  or
         (  passedt.historic == "heritage"        )  or
         (  passedt.historic == "industrial"      )  or
         (  passedt.historic == "tower"           )))) then
      passedt.historic = "windmill"
   end

-- ----------------------------------------------------------------------------
-- Render ruined mills and mines etc. that are not something else as historic.
-- Items in this list are assumed to be not operational, so the "man_made" 
-- tag is cleared.
-- ----------------------------------------------------------------------------
   if (( passedt.historic  == "ruins"        ) and
       (( passedt.ruins    == "lime_kiln"   )  or
        ( passedt.ruins    == "manor"       )  or
        ( passedt.ruins    == "mill"        )  or
        ( passedt.ruins    == "mine"        )  or
        ( passedt.ruins    == "round_tower" )  or
        ( passedt.ruins    == "village"     )  or
        ( passedt.ruins    == "well"        ))) then
      passedt.historic = passedt.ruins
      passedt.ruins = "yes"
      passedt.man_made = nil
   end

-- ----------------------------------------------------------------------------
-- We can assume that any allegedly non-historic ice_houses are actually 
-- historic.  Any coexisting historic keys will just be stuff like "building".
-- ----------------------------------------------------------------------------
   if ( passedt.man_made == "ice_house" ) then
      passedt.historic = "ice_house"
      passedt.man_made = nil
   end

-- ----------------------------------------------------------------------------
-- Sound mirrors
-- ----------------------------------------------------------------------------
   if ( passedt.man_made == "sound mirror" ) then

      if ( passedt.historic == "ruins" ) then
         passedt.ruins = "yes"
      end

      passedt.historic = "sound_mirror"
      passedt.man_made = nil
   end

-- ----------------------------------------------------------------------------
-- Specific defensive_works not mapped as something else
-- ----------------------------------------------------------------------------
   if ((  passedt.defensive_works == "battery"  ) and
       (( passedt.barrier         == nil       )  or
        ( passedt.barrier         == ""        )) and
       (( passedt.building        == nil       )  or
        ( passedt.building        == ""        )) and
       (( passedt.historic        == nil       )  or
        ( passedt.historic        == ""        )) and
       (( passedt.landuse         == nil       )  or
        ( passedt.landuse         == ""        )) and
       (( passedt.man_made        == nil       )  or
        ( passedt.man_made        == ""        )) and
       (( passedt.place           == nil       )  or
        ( passedt.place           == ""        ))) then
      passedt.historic = "battery"
      passedt.defensive_works = nil
   end

-- ----------------------------------------------------------------------------
-- Remove name from footway=sidewalk (we expect it to be rendered via the
-- road that this is a sidewalk for), or "is_sidepath=yes" etc.
-- ----------------------------------------------------------------------------
   if (((  passedt.footway             == "sidewalk" )  or
        (  passedt.cycleway            == "sidewalk" )  or
        (  passedt.is_sidepath         == "yes"      )  or
        (( passedt["is_sidepath:of"]      ~= nil       )   and
         ( passedt["is_sidepath:of"]      ~= ""        ))  or
        (( passedt["is_sidepath:of:name"] ~= nil       )   and
         ( passedt["is_sidepath:of:name"] ~= ""        ))  or
        (( passedt["is_sidepath:of:ref"]  ~= nil       )   and
         ( passedt["is_sidepath:of:ref"]  ~= ""        ))) and
       ( passedt.name                ~= nil           ) and
       ( passedt.name                ~= ""            )) then
      passedt.name = nil
   end

-- ----------------------------------------------------------------------------
-- Waste transfer stations
-- First, try and identify mistagged ones.
-- ----------------------------------------------------------------------------
   if (( passedt.amenity == "waste_transfer_station" ) and
       ( passedt.recycling_type == "centre"          )) then
      passedt.amenity = "recyclingcentre"
      passedt.landuse = "industrial"
   end

-- ----------------------------------------------------------------------------
-- Next, treat "real" waste transfer stations as industrial.  We remove the 
-- amenity tag here because there's no icon for amenity=waste_transfer_station;
-- an amenity tag would see it treated as landuse=unnamedcommercial with the
-- amenity tag bringing the name (which it won't here).  The "industrial" tag
-- forces it through the brand/operator logic.
-- ----------------------------------------------------------------------------
   if ( passedt.amenity == "waste_transfer_station" ) then
      passedt.amenity = nil
      passedt.landuse = "industrial"
      passedt.industrial = "waste_transfer_station"
   end

-- ----------------------------------------------------------------------------
-- Recycling bins and recycling centres.
-- Recycling bins are only shown from z19.  Recycling centres are shown from
-- z16 and have a characteristic icon.  Any object without recycling_type, or
-- with a different value, is assumed to be a bin, apart from one rogue
-- "scrap_yard".
-- ----------------------------------------------------------------------------
   if (( passedt.amenity == "recycling"         ) and
       ( passedt.recycling_type == "scrap_yard" )) then
         passedt.amenity = "scrapyard"
   end

   if ( passedt.amenity == "recycling" ) then
      if ( passedt.recycling_type == "centre" ) then
         passedt.amenity = "recyclingcentre"
         passedt.landuse = "industrial"
      end
   end

-- ----------------------------------------------------------------------------
-- Mistaggings for wastewater_plant
-- ----------------------------------------------------------------------------
   if (( passedt.man_made   == "sewage_works"      ) or
       ( passedt.man_made   == "wastewater_works"  )) then
      passedt.man_made = "wastewater_plant"
   end

-- ----------------------------------------------------------------------------
-- Outfalls, sewage and otherwise.  We process "man_made=outfall", but also
-- catch outlets not tagged with that.
-- ----------------------------------------------------------------------------
   if (( passedt.outlet ~= nil  ) and
       ( passedt.outlet ~= ""   ) and
       ( passedt.outlet ~= "no" )) then
      passedt.man_made = "outfall"
   end

-- ----------------------------------------------------------------------------
-- Electricity substations
-- ----------------------------------------------------------------------------
   if (( passedt.power == "substation"  )  or
       ( passedt.power == "sub_station" )) then
      passedt.power   = nil

      if (( passedt.building == nil  ) or
          ( passedt.building == ""   ) or
          ( passedt.building == "no" )) then
         passedt.landuse = "industrial"
      else
         passedt.building = "yes"
         passedt.landuse = "industrialbuilding"
      end

      if (( passedt.name == nil ) or
          ( passedt.name == ""  )) then
         passedt.name = "(el.sub.)"
      else
         passedt.name = passedt.name .. " (el.sub.)"
      end
   end

-- ----------------------------------------------------------------------------
-- Pretend add landuse=industrial to some industrial sub-types to force 
-- name rendering.  Similarly, some commercial and leisure.
-- man_made=works drops the man_made tag to avoid duplicate labelling.
-- "parking=depot" is a special case - drop the parking tag there too.
-- ----------------------------------------------------------------------------
   if ( passedt.man_made   == "wastewater_plant" ) then
      passedt.man_made = nil
      passedt.landuse = "industrial"
      if (( passedt.name == nil ) or
          ( passedt.name == ""  )) then
         passedt.name = "(sewage)"
      else
         passedt.name = passedt.name .. " (sewage)"
      end
   end

   if (( passedt.amenity    == "bus_depot"              ) or
       ( passedt.amenity    == "depot"                  ) or
       ( passedt.amenity    == "fuel_depot"             ) or
       ( passedt.amenity    == "scrapyard"              ) or 
       ( passedt.craft      == "bakery"                 ) or
       ( passedt.craft      == "distillery"             ) or
       ( passedt.craft      == "sawmill"                ) or
       ( passedt.industrial == "auto_wrecker"           ) or 
       ( passedt.industrial == "automotive_industry"    ) or
       ( passedt.industrial == "bakery"                 ) or
       ( passedt.industrial == "brewery"                ) or 
       ( passedt.industrial == "bus_depot"              ) or
       ( passedt.industrial == "chemical"               ) or
       ( passedt.industrial == "concrete_plant"         ) or
       ( passedt.industrial == "construction"           ) or
       ( passedt.industrial == "depot"                  ) or 
       ( passedt.industrial == "distillery"             ) or 
       ( passedt.industrial == "electrical"             ) or
       ( passedt.industrial == "engineering"            ) or
       ( passedt.industrial == "factory"                ) or 
       ( passedt.industrial == "furniture"              ) or
       ( passedt.industrial == "gas"                    ) or
       ( passedt.industrial == "haulage"                ) or
       ( passedt.industrial == "machine_shop"           ) or
       ( passedt.industrial == "machinery"              ) or
       ( passedt.industrial == "metal_finishing"        ) or
       ( passedt.industrial == "mobile_equipment"       ) or
       ( passedt.industrial == "oil"                    ) or
       ( passedt.industrial == "packaging"              ) or
       ( passedt.industrial == "sawmill"                ) or
       ( passedt.industrial == "scaffolding"            ) or
       ( passedt.industrial == "scrap_yard"             ) or 
       ( passedt.industrial == "shop_fitters"           ) or
       ( passedt.industrial == "warehouse"              ) or
       ( passedt.industrial == "waste_handling"         ) or
       ( passedt.industrial == "woodworking"            ) or
       ( passedt.industrial == "yard"                   ) or 
       ( passedt.industrial == "yes"                    ) or 
       ( passedt.landuse    == "depot"                  ) or
       ( passedt.man_made   == "gas_station"            ) or
       ( passedt.man_made   == "gas_works"              ) or
       ( passedt.man_made   == "petroleum_well"         ) or 
       ( passedt.man_made   == "pumping_station"        ) or
       ( passedt.man_made   == "water_treatment"        ) or
       ( passedt.man_made   == "water_works"            ) or
       ( passedt.power      == "plant"                  )) then
      passedt.landuse = "industrial"
   end

-- ----------------------------------------------------------------------------
-- Sometimes covered reservoirs are "basically buildings", sometimes they have
-- e.g. landuse=grass set.  If the latter, don't show them as buildings.
-- The name will still appear via landuse.
-- ----------------------------------------------------------------------------
   if ((  passedt.man_made   == "reservoir_covered"  ) and
       (( passedt.landuse    == nil                 )  or
        ( passedt.landuse    == ""                  ))) then
      passedt.building = "roof"
      passedt.landuse  = "industrialbuilding"
   end

   if (( passedt.building   == "industrial"             ) or
       ( passedt.building   == "depot"                  ) or 
       ( passedt.building   == "warehouse"              ) or
       ( passedt.building   == "works"                  ) or
       ( passedt.building   == "manufacture"            )) then
      passedt.landuse = "industrialbuilding"
   end

   if ( passedt.man_made   == "works" ) then
      passedt.man_made = nil

      if (( passedt.building == nil  ) or
          ( passedt.building == ""   ) or
          ( passedt.building == "no" )) then
         passedt.landuse = "industrial"
      else
         passedt.building = "yes"
         passedt.landuse = "industrialbuilding"
      end
   end

   if ( passedt.man_made   == "water_tower" ) then
      if ( passedt.building == "no" ) then
         passedt.landuse = "industrial"
      else
         passedt.building = "yes"
         passedt.landuse = "industrialbuilding"
      end
   end

   if ( passedt.parking   == "depot" ) then
      passedt.parking = nil
      passedt.landuse = "industrial"
   end

-- ----------------------------------------------------------------------------
-- Handle spoil heaps as landfill
-- ----------------------------------------------------------------------------
   if ( passedt.man_made == "spoil_heap" ) then
      passedt.landuse = "landfill"
   end

-- ----------------------------------------------------------------------------
-- Handle place=islet as place=island
-- Handle place=quarter
-- Handle natural=cape etc. as place=locality if no other place tag.
-- ----------------------------------------------------------------------------
   consolidate_place_t( passedt )

-- ----------------------------------------------------------------------------
-- Handle shoals, either as mud or reef
-- ----------------------------------------------------------------------------
   if ( passedt.natural == "shoal" ) then
      if ( passedt.surface == "mud" ) then
         passedt.natural = "mud"
         passedt.surface = nil
      else
         passedt.natural = "reef"
      end
   end

-- ----------------------------------------------------------------------------
-- Show sandy reefs as more sandy than rocky reefs
-- ----------------------------------------------------------------------------
   if (( passedt.natural == "reef" ) and
       ( passedt.reef    == "sand" )) then
         passedt.natural = "reefsand"
   end

-- ----------------------------------------------------------------------------
-- Convert "natural=saltmarsh" into something we can handle below
-- ----------------------------------------------------------------------------
   if ( passedt.natural == "saltmarsh" ) then
      if ( passedt.wetland == "tidalflat" ) then
         passedt.tidal = "yes"
      else
         passedt.tidal = "no"
      end

      passedt.natural = "wetland"
      passedt.wetland = "saltmarsh"
   end

-- ----------------------------------------------------------------------------
-- Detect wetland not tagged with "natural=wetland".
-- Other combinations include
-- natural=water, natural=scrub, landuse=meadow, leisure=nature_reserve,
-- leisure=park, and no natural, landuse or leisure tags.
-- In many cases we don't set natural=wetland, but in some we do.
-- ----------------------------------------------------------------------------
   if ((  passedt.wetland == "wet_meadow"  ) and
       (( passedt.natural == nil          )  or
        ( passedt.natural == ""           )  or
        ( passedt.natural == "grassland"  )) and
       (( passedt.leisure == nil          )  or
        ( passedt.leisure == ""           ))  and
       (( passedt.landuse == nil          )  or
        ( passedt.landuse == ""           )  or
        ( passedt.landuse == "meadow"     ))) then
      passedt.natural = "wetland"
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
   if ((  passedt.natural == "wetland"    ) and
       (( passedt.wetland == nil         ) or
        ( passedt.wetland == ""          ) or
        ( passedt.wetland == "tidalflat" ))) then
      if ( passedt.surface == "mud" ) then
         passedt.natural = "mud"
      end

      if (( passedt.surface == "sand"      ) or
          ( passedt.surface == "dirt/sand" )) then
         passedt.natural = "sand"
      end

      if (( passedt.surface == "shingle"     ) or
          ( passedt.surface == "gravel"      ) or
          ( passedt.surface == "fine_gravel" ) or
          ( passedt.surface == "pebblestone" )) then
         passedt.natural = "shingle"
      end

      if (( passedt.surface == "rock"      ) or
          ( passedt.surface == "bare_rock" ) or
          ( passedt.surface == "concrete"  )) then
         passedt.natural = "bare_rock"
      end
   end

-- ----------------------------------------------------------------------------
-- Also, if "natural" is still "wetland", what "wetland" values should be 
-- handled as some other tag?
-- ----------------------------------------------------------------------------
   if ( passedt.natural == "wetland" ) then
      if (( passedt.wetland == "tidalflat" ) or
          ( passedt.wetland == "mud"       )) then
         passedt.natural = "mud"
         passedt.tidal = "yes"
      end

      if ( passedt.wetland == "wet_meadow" ) then
         passedt.landuse = "wetmeadow"
         passedt.natural = nil
      end

      if ( passedt.wetland == "saltmarsh" ) then
         passedt.landuse = "saltmarsh"
         passedt.natural = nil
      end

      if ( passedt.wetland == "reedbed" ) then
         passedt.landuse = "reedbed"
         passedt.natural = nil
      end
   end

-- ----------------------------------------------------------------------------
-- Render tidal mud with more blue
-- ----------------------------------------------------------------------------
   if ((  passedt.natural   == "mud"        ) and
       (( passedt.tidal     == "yes"       ) or
        ( passedt.wetland   == "tidalflat" ))) then
      passedt.natural = "tidal_mud"
   end

-- ----------------------------------------------------------------------------
-- Handle various sorts of milestones.
-- ----------------------------------------------------------------------------
   if (( passedt.highway  == "milestone" )  or
       ( passedt.historic == "milestone" )  or
       ( passedt.historic == "milepost"  )  or
       ( passedt.waterway == "milestone" )  or
       ( passedt.railway  == "milestone" )  or
       ( passedt.man_made == "mile_post" )) then
      passedt.highway = "milestone"

      append_inscription( passedt )
      append_directions( passedt )
   end

-- ----------------------------------------------------------------------------
-- Aerial markers for pipelines etc.
-- ----------------------------------------------------------------------------
   if ((   passedt.marker   == "aerial"          ) or
       (   passedt.marker   == "pipeline"        ) or
       (   passedt.man_made == "marker"          ) or
       (   passedt.man_made == "pipeline_marker" ) or
       (   passedt.pipeline == "marker"          ) or
       ((( passedt.marker   == "post"          )   or
         ( passedt.marker   == "yes"           )   or
         ( passedt.marker   == "pedestal"      )   or
         ( passedt.marker   == "plate"         )   or
         ( passedt.marker   == "pole"          ))  and
        (  passedt.utility  ~= nil              )  and
        (  passedt.utility  ~= "yes"            ))) then
      passedt.man_made = "markeraerial"
   end

-- ----------------------------------------------------------------------------
-- Boundary stones.  If they're already tagged as tourism=attraction, remove
-- that tag.
-- Note that "marker=stone" (for "non boundary stones") are handled elsewhere.
-- For March Stones see https://en.wikipedia.org/wiki/March_Stones_of_Aberdeen
-- ----------------------------------------------------------------------------
   if (( passedt.historic    == "boundary_stone"  )  or
       ( passedt.historic    == "boundary_marker" )  or
       ( passedt.man_made    == "boundary_marker" )  or
       ( passedt.marker      == "boundary_stone"  )  or
       ( passedt.boundary    == "marker"          )  or
       ( passedt.designation == "March Stone"     )) then
      passedt.man_made = "boundary_stone"
      passedt.tourism  = nil

      append_inscription( passedt )
   end

-- ----------------------------------------------------------------------------
-- Former telephone boxes
-- ----------------------------------------------------------------------------
   if ((( passedt.covered         == "booth"          )   and
        ( passedt.booth           ~= "K1"             )   and
        ( passedt.booth           ~= "KX100"          )   and
        ( passedt.booth           ~= "KX200"          )   and
        ( passedt.booth           ~= "KX300"          )   and
        ( passedt.booth           ~= "KXPlus"         )   and
        ( passedt.booth           ~= "KX410"          )   and
        ( passedt.booth           ~= "KX420"          )   and
        ( passedt.booth           ~= "KX520"          )   and
        ( passedt.booth           ~= "oakham"         )   and
        ( passedt.booth           ~= "ST6"            ))  or
       (  passedt.booth           == "K2"              )  or
       (  passedt.booth           == "K4 Post Office"  )  or
       (  passedt.booth           == "K6"              )  or
       (  passedt.booth           == "K8"              )  or
       (  passedt.telephone_kiosk == "K6"              )  or
       (  passedt.man_made        == "telephone_box"   )  or
       (  passedt.building        == "telephone_box"   )  or
       (  passedt.historic        == "telephone"       )  or
       (  passedt["disused:amenity"] == "telephone"       )  or
       (  passedt["removed:amenity"] == "telephone"       )) then
      if ((( passedt.amenity   == "telephone"    )  or
           ( passedt.amenity   == "phone"        )) and
          (  passedt.emergency ~= "defibrillator" ) and
          (  passedt.emergency ~= "phone"         ) and
          (  passedt.tourism   ~= "information"   ) and
          (  passedt.tourism   ~= "artwork"       ) and
          (  passedt.tourism   ~= "museum"        )) then
	 if ( passedt.colour == "black" ) then
            passedt.amenity = "boothtelephoneblack"
	 else
	    if (( passedt.colour == "white" ) or
	        ( passedt.colour == "cream" )) then
               passedt.amenity = "boothtelephonewhite"
	    else
    	       if ( passedt.colour == "blue" ) then
                  passedt.amenity = "boothtelephoneblue"
	       else
    	          if ( passedt.colour == "green" ) then
                     passedt.amenity = "boothtelephonegreen"
		  else
    	             if ( passedt.colour == "grey" ) then
                        passedt.amenity = "boothtelephonegrey"
		     else
    	                if ( passedt.colour == "gold" ) then
                           passedt.amenity = "boothtelephonegold"
			else
                           passedt.amenity = "boothtelephonered"
			end
		     end
		  end
	       end
	    end
	 end
	    
         passedt.tourism = nil
         passedt.emergency = nil
      else
         if ( passedt.emergency == "defibrillator" ) then
             passedt.amenity   = "boothdefibrillator"
             passedt["disused:amenity"] = nil
             passedt.emergency = nil
         else
            if (( passedt.amenity == "public_bookcase" )  or
                ( passedt.amenity == "library"         )) then
               passedt.amenity = "boothlibrary"
               passedt["disused:amenity"] = nil
            else
               if ( passedt.amenity == "bicycle_repair_station" ) then
                  passedt.amenity = "boothbicyclerepairstation"
                  passedt["disused:amenity"] = nil
               else
                  if ( passedt.amenity == "atm" ) then
                     passedt.amenity = "boothatm"
                     passedt["disused:amenity"] = nil
                  else
                     if ( passedt.tourism == "information" ) then
                        passedt.amenity = "boothinformation"
                        passedt["disused:amenity"] = nil
                        passedt.tourism = nil
                     else
                        if ( passedt.tourism == "artwork" ) then
                           passedt.amenity = "boothartwork"
                           passedt["disused:amenity"] = nil
                           passedt.tourism = nil
                        else
                           if ( passedt.tourism == "museum" ) then
                              passedt.amenity = "boothmuseum"
                              passedt["disused:amenity"] = nil
                              passedt.tourism = nil
		  	   else
                              if (( passedt["disused:amenity"]    == "telephone"        )  or
                                  ( passedt["removed:amenity"]    == "telephone"        )  or
                                  ( passedt["abandoned:amenity"]  == "telephone"        )  or
                                  ( passedt["demolished:amenity"] == "telephone"        )  or
                                  ( passedt["razed:amenity"]      == "telephone"        )  or
                                  ( passedt.old_amenity        == "telephone"        )  or
                                  ( passedt["historic:amenity"]   == "telephone"        )  or
                                  ( passedt.disused            == "telephone"        )  or
                                  ( passedt["was:amenity"]        == "telephone"        )  or
                                  ( passedt["old:amenity"]        == "telephone"        )  or
                                  ( passedt.amenity            == "former_telephone" )  or
                                  ( passedt.historic           == "telephone"        )) then
                                 passedt.amenity         = "boothdisused"
                                 passedt["disused:amenity"] = nil
                                 passedt.historic        = nil
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
   if ((( passedt.business   ~= nil  )  and
        ( passedt.business   ~= ""   )) and
       (( passedt.office     == nil  )  or
        ( passedt.office     == ""   )) and
       (( passedt.shop       == nil  )  or
        ( passedt.shop       == ""   ))) then
      passedt.office = "yes"
      passedt.business = nil
   end

   if ((( passedt.company   ~= nil  )  and
        ( passedt.company   ~= ""   )) and
       (( passedt.man_made  == nil  )  or
        ( passedt.man_made  == ""   )) and
       (( passedt.office    == nil  )  or
        ( passedt.office    == ""   )) and
       (( passedt.shop      == nil  )  or
        ( passedt.shop      == ""   ))) then
      passedt.office = "yes"
      passedt.company = nil
   end

-- ----------------------------------------------------------------------------
-- Remove generic offices if shop is set.
-- ----------------------------------------------------------------------------
   if ((  passedt.shop   ~= nil        )  and
       (  passedt.shop   ~= ""         )  and
       (  passedt.shop   ~= "no"       )  and
       (  passedt.shop   ~= "vacant"   )  and
       (( passedt.office == "company" )   or
        ( passedt.office == "vacant"  )   or
        ( passedt.office == "yes"     ))) then
      passedt.office = nil
   end

-- ----------------------------------------------------------------------------
-- Mappings to shop=car
-- ----------------------------------------------------------------------------
   if (( passedt.shop    == "car;car_repair"  )  or
       ( passedt.shop    == "car_showroom"    )  or
       ( passedt.shop    == "vehicle"         )) then
      passedt.shop = "car"
   end

-- ----------------------------------------------------------------------------
-- Mappings to shop=bicycle
-- ----------------------------------------------------------------------------
   if ( passedt.shop == "bicycle_repair"   ) then
      passedt.shop = "bicycle"
   end

-- ----------------------------------------------------------------------------
-- Map craft=car_repair etc. to shop=car_repair
-- ----------------------------------------------------------------------------
   if (( passedt.craft   == "car_repair"         )  or
       ( passedt.craft   == "coachbuilder"       )  or
       ( passedt.shop    == "car_service"        )  or
       ( passedt.amenity == "vehicle_inspection" )  or
       ( passedt.shop    == "car_bodyshop"       )  or
       ( passedt.shop    == "vehicle_inspection" )  or
       ( passedt.shop    == "mechanic"           )  or
       ( passedt.shop    == "car_repair;car"     )  or
       ( passedt.shop    == "car_repair;tyres"   )  or
       ( passedt.shop    == "vehicle_repair"     )) then
      passedt.shop    = "car_repair"
      passedt.amenity = nil
      passedt.craft   = nil
   end

-- ----------------------------------------------------------------------------
-- Map various diplomatic things to embassy.
-- Pedants may claim that some of these aren't legally embassies, and they'd
-- be correct, but I use the same icon for all of these currently.
-- ----------------------------------------------------------------------------
   if (((  passedt.diplomatic == "embassy"            )  and
        (( passedt.embassy    == nil                 )   or
         ( passedt.embassy    == ""                  )   or
         ( passedt.embassy    == "yes"               )   or
         ( passedt.embassy    == "high_commission"   )   or
         ( passedt.embassy    == "nunciature"        )   or
         ( passedt.embassy    == "delegation"        ))) or
       ((  passedt.diplomatic == "consulate"          )  and
        (( passedt.consulate  == nil                 )   or
         ( passedt.consulate  == ""                  )   or
         ( passedt.consulate  == "consulate_general" )   or
         ( passedt.consulate  == "yes"               ))) or
       ( passedt.diplomatic == "embassy;consulate"     ) or
       ( passedt.diplomatic == "embassy;mission"       ) or
       ( passedt.diplomatic == "consulate;embassy"     )) then
      passedt.amenity    = "embassy"
      passedt.diplomatic = nil
      passedt.office     = nil
   end

   if (((  passedt.diplomatic == "embassy"              )  and
        (( passedt.embassy    == "residence"           )   or
         ( passedt.embassy    == "branch_embassy"      )   or
         ( passedt.embassy    == "mission"             ))) or
       ((  passedt.diplomatic == "consulate"            )  and
        (( passedt.consulate  == "consular_office"     )   or
         ( passedt.consulate  == "residence"           )   or
         ( passedt.consulate  == "consular_agency"     ))) or
       (   passedt.diplomatic == "permanent_mission"     ) or
       (   passedt.diplomatic == "trade_delegation"      ) or
       (   passedt.diplomatic == "liaison"               ) or
       (   passedt.diplomatic == "non_diplomatic"        ) or
       (   passedt.diplomatic == "mission"               ) or
       (   passedt.diplomatic == "trade_mission"         )) then
      if ( passedt.amenity == "embassy" ) then
         passedt.amenity = nil
      end

      passedt.diplomatic = nil

-- ----------------------------------------------------------------------------
-- "office" is set to something that will definitely display here, just in case
-- it was set to some value that would not.
-- ----------------------------------------------------------------------------
      passedt.office = "yes"
   end

-- ----------------------------------------------------------------------------
-- Don't show extinct volcanos as volcanos, just as peaks.
-- That's still iffy in some cases (e.g. Rockall), but better than nothing.
-- ----------------------------------------------------------------------------
   if ((  passedt.natural           == "volcano" ) and
       (  passedt["volcano:status"] == "extinct" )) then
      passedt.natural = "peak"
   end

-- ----------------------------------------------------------------------------
-- Things that are both localities and peaks or hills 
-- should render as the latter.
-- Also, some other combinations (most amenities, some man_made, etc.)
-- Note that "hill" is handled by the rendering code as similar to "peak" but
-- only at higher zooms.  See 19/03/2023 in changelog.html .
-- ----------------------------------------------------------------------------
   if ((   passedt.place    == "locality"       ) and
       ((  passedt.natural  == "peak"          )  or
        (  passedt.natural  == "hill"          )  or
        (( passedt.amenity  ~= nil            )   and
         ( passedt.amenity  ~= ""             ))  or
        (( passedt.man_made ~= nil            )   and
         ( passedt.man_made ~= ""             ))  or
        (( passedt.historic ~= nil            )   and
         ( passedt.historic ~= ""             )))) then
      passedt.place = nil
   end

-- ----------------------------------------------------------------------------
-- Various tags are used for milk churn stands
-- They're extracted as "historic".
-- ----------------------------------------------------------------------------
   if ((  passedt.man_made == "milk_churn_stand" ) or
       (  passedt.memorial == "milk_churn_stand" )) then
      passedt.historic = "milk_churn_stand"
   end

-- ----------------------------------------------------------------------------
-- Detect some sport facilities that have been only partially tagged.
-- For example, something with a name that is "sport=10pin" but isn't anything
-- else must be a bowling alley.
-- ----------------------------------------------------------------------------
   if ((( passedt.sport           == "10pin"   )  or
        ( passedt.sport           == "9pin"    )  or
        ( passedt.sport           == "bowling" )) and
       (( passedt.leisure         == nil       )  or
        ( passedt.leisure         == ""        )) and
       (( passedt.disusedCleisure == nil       )  or
        ( passedt.disusedCleisure == ""        )) and
       (( passedt.amenity         == nil       )  or
        ( passedt.amenity         == ""        )) and
       (( passedt.shop            == nil       )  or
        ( passedt.shop            == ""        )) and
       (( passedt.office          == nil       )  or
        ( passedt.office          == ""        )) and
       (( passedt.club            == nil       )  or
        ( passedt.club            == ""        )) and
       (  passedt.name            ~= nil        ) and
       (  passedt.name            ~= ""         )) then
      passedt.leisure = "bowling_alley"
   end

   if ((  passedt.sport           == "skiing"  ) and
       (( passedt.leisure         == nil      )  or
        ( passedt.leisure         == ""       )) and
       (( passedt.disusedCleisure == nil      )  or
        ( passedt.disusedCleisure == ""       )) and
       (( passedt.amenity         == nil      )  or
        ( passedt.amenity         == ""       )) and
       (( passedt.shop            == nil      )  or
        ( passedt.shop            == ""       )) and
       (( passedt.office          == nil      )  or
        ( passedt.office          == ""       )) and
       (( passedt.club            == nil      )  or
        ( passedt.club            == ""       )) and
       (  passedt.name            ~= nil       ) and
       (  passedt.name            ~= ""        )) then
      passedt.leisure = "pitch"
   end

-- ----------------------------------------------------------------------------
-- Things that are both viewpoints or attractions and monuments or memorials 
-- should render as the latter.  Some are handled further down too.
-- Also handle some other combinations.
-- ----------------------------------------------------------------------------
   if ((( passedt.tourism   == "viewpoint"                 )  or
        ( passedt.tourism   == "attraction"                )) and
       (( passedt.historic  == "abbey"                     )  or
        ( passedt.historic  == "aircraft"                  )  or
        ( passedt.historic  == "almshouse"                 )  or
        ( passedt.historic  == "anchor"                    )  or
        ( passedt.historic  == "archaeological_site"       )  or
        ( passedt.historic  == "bakery"                    )  or
        ( passedt.historic  == "barrow"                    )  or
        ( passedt.historic  == "baths"                     )  or
        ( passedt.historic  == "battlefield"               )  or
        ( passedt.historic  == "battery"                   )  or
        ( passedt.historic  == "bullaun_stone"             )  or
        ( passedt.historic  == "boundary_stone"            )  or
        ( passedt.historic  == "building"                  )  or
        ( passedt.historic  == "bridge_site"               )  or
        ( passedt.historic  == "bunker"                    )  or
        ( passedt.historic  == "camp"                      )  or
        ( passedt.historic  == "cannon"                    )  or
        ( passedt.historic  == "castle"                    )  or
        ( passedt.historic  == "chapel"                    )  or
        ( passedt.historic  == "church"                    )  or
        ( passedt.historic  == "city_gate"                 )  or
        ( passedt.historic  == "citywalls"                 )  or
        ( passedt.historic  == "chlochan"                  )  or
        ( passedt.historic  == "cross"                     )  or
        ( passedt.historic  == "deserted_medieval_village" )  or
        ( passedt.historic  == "drinking_fountain"         )  or
        ( passedt.historic  == "folly"                     )  or
        ( passedt.historic  == "fort"                      )  or
        ( passedt.historic  == "fortification"             )  or
        ( passedt.historic  == "gate"                      )  or
        ( passedt.historic  == "grinding_mill"             )  or
        ( passedt.historic  == "hall"                      )  or
        ( passedt.historic  == "high_cross"                )  or
        ( passedt.historic  == "house"                     )  or
        ( passedt.historic  == "ice_house"                 )  or
        ( passedt.historic  == "jail"                      )  or
        ( passedt.historic  == "locomotive"                )  or
        ( passedt.historic  == "locomotive"                )  or
        ( passedt.historic  == "martello_tower"            )  or
        ( passedt.historic  == "martello_tower;bunker"     )  or
        ( passedt.historic  == "maypole"                   )  or
        ( passedt.historic  == "memorial"                  )  or
        ( passedt.historic  == "mill"                      )  or
        ( passedt.historic  == "millstone"                 )  or
        ( passedt.historic  == "mine"                      )  or
        ( passedt.historic  == "monastery"                 )  or
        ( passedt.historic  == "monastic_grange"           )  or
        ( passedt.historic  == "monument"                  )  or
        ( passedt.historic  == "mound"                     )  or
	( passedt.historic  == "naval_mine"                )  or
        ( passedt.historic  == "oratory"                   )  or
        ( passedt.historic  == "pillory"                   )  or
        ( passedt.historic  == "place_of_worship"          )  or
        ( passedt.historic  == "police_call_box"           )  or
        ( passedt.historic  == "prison"                    )  or
        ( passedt.historic  == "residence"                 )  or
        ( passedt.historic  == "roundhouse"                )  or
        ( passedt.historic  == "ruins"                     )  or
        ( passedt.historic  == "sawmill"                   )  or
        ( passedt.historic  == "shelter"                   )  or
        ( passedt.historic  == "ship"                      )  or
        ( passedt.historic  == "smithy"                    )  or
        ( passedt.historic  == "sound_mirror"              )  or
        ( passedt.historic  == "standing_stone"            )  or
        ( passedt.historic  == "statue"                    )  or
        ( passedt.historic  == "stocks"                    )  or
        ( passedt.historic  == "stone"                     )  or
        ( passedt.historic  == "tank"                      )  or
        ( passedt.historic  == "theatre"                   )  or
        ( passedt.historic  == "tomb"                      )  or
        ( passedt.historic  == "tower"                     )  or
        ( passedt.historic  == "tower_house"               )  or
        ( passedt.historic  == "tumulus"                   )  or
        ( passedt.historic  == "village"                   )  or
        ( passedt.historic  == "village_pump"              )  or
        ( passedt.historic  == "water_crane"               )  or
        ( passedt.historic  == "water_pump"                )  or
        ( passedt.historic  == "wayside_cross"             )  or
        ( passedt.historic  == "wayside_shrine"            )  or
        ( passedt.historic  == "well"                      )  or
        ( passedt.historic  == "watermill"                 )  or
        ( passedt.historic  == "windmill"                  )  or
        ( passedt.historic  == "workhouse"                 )  or
        ( passedt.historic  == "wreck"                     )  or
        ( passedt.historic  == "yes"                       )  or
        ( passedt.natural   == "beach"                     )  or
        ( passedt.natural   == "cave_entrance"             )  or
        ( passedt.natural   == "cliff"                     )  or
        ( passedt.natural   == "grassland"                 )  or
        ( passedt.natural   == "heath"                     )  or
        ( passedt.natural   == "sand"                      )  or
        ( passedt.natural   == "scrub"                     )  or
        ( passedt.natural   == "spring"                    )  or
        ( passedt.natural   == "tree"                      )  or
        ( passedt.natural   == "water"                     )  or
        ( passedt.natural   == "wood"                      )  or
        ( passedt.leisure   == "garden"                    )  or
        ( passedt.leisure   == "nature_reserve"            )  or
        ( passedt.leisure   == "park"                      )  or
        ( passedt.leisure   == "sports_centre"             ))) then
      passedt.tourism = nil
   end

   if ((   passedt.tourism == "attraction"   ) and
       ((( passedt.shop    ~= nil          )   and
         ( passedt.shop    ~= ""           ))  or
        (( passedt.amenity ~= nil          )   and
         ( passedt.amenity ~= ""           ))  or
        (( passedt.highway ~= nil          )   and
         ( passedt.highway ~= ""           ))  or
        (  passedt.leisure == "park"       ))) then
      passedt.tourism = nil
   end

-- ----------------------------------------------------------------------------
-- There's a bit of "tagging for the renderer" going on with some large museums
-- ----------------------------------------------------------------------------
   if ((  passedt.tourism == "museum"          ) and 
       (( passedt.leisure == "garden"         )  or
        ( passedt.leisure == "nature_reserve" )  or
        ( passedt.leisure == "park"           ))) then
      passedt.leisure = nil
   end

-- ----------------------------------------------------------------------------
-- Detect unusual taggings of hills
-- ----------------------------------------------------------------------------
   if (( passedt.natural == "peak" ) and
       ( passedt.peak    == "hill" )) then
      passedt.natural = "hill"
   end

-- ----------------------------------------------------------------------------
-- Holy wells might be natural=spring or something else.
-- Make sure that we set "amenity" to something other than "place_of_worship"
-- The one existing "holy_well" is actually a spring.
-- ----------------------------------------------------------------------------
   if (( passedt.amenity == "holy_well" ) and
       ( passedt.natural == "spring"    )) then
      passedt.amenity = "holy_spring"
      passedt.natural = nil
   end

   if ( passedt.place_of_worship == "holy_well" ) then
      passedt.man_made = nil
      if ( passedt.natural == "spring" ) then
         passedt.amenity = "holy_spring"
         passedt.natural = nil
      else
         passedt.amenity = "holy_well"
         passedt.natural = nil
      end
   end

-- ----------------------------------------------------------------------------
-- Springs - lose a historic tag, if set.
-- ----------------------------------------------------------------------------
   if (( passedt.natural == "spring" ) and
       ( passedt.historic ~= nil     ) and
       ( passedt.historic ~= ""      )) then
      passedt.historic = nil
   end

-- ----------------------------------------------------------------------------
-- Inverse springs - where water seeps below ground
-- We already show "dry" sinkholes; show these in the same way.
-- ----------------------------------------------------------------------------
   if ( passedt.waterway == "cave_of_debouchement" ) then
      passedt.natural = "sinkhole"
   end

-- ----------------------------------------------------------------------------
-- Boatyards
-- ----------------------------------------------------------------------------
   if (( passedt.waterway   == "boatyard" ) or
       ( passedt.industrial == "boatyard" )) then
      passedt.amenity = "boatyard"
      passedt.waterway = nil
      passedt.industrial = nil
   end

-- ----------------------------------------------------------------------------
-- Beer gardens etc.
-- ----------------------------------------------------------------------------
   if (( passedt.amenity == "beer_garden" ) or
       ( passedt.leisure == "beer_garden" )) then
      passedt.amenity = nil
      passedt.leisure = "garden"
      passedt.garden = "beer_garden"
   end

-- ----------------------------------------------------------------------------
-- Render biergartens as gardens, which is all they likely are.
-- Remove the symbol from unnamed ones - they're likely just pub beer gardens.
-- ----------------------------------------------------------------------------
   if (  passedt.amenity == "biergarten" ) then
      if (( passedt.name == nil           )   or
          ( passedt.name == ""            )   or
          ( passedt.name == "Beer Garden" )) then
         passedt.amenity = nil
      end

      passedt.landuse = "unnamedgrass"
   end

-- ----------------------------------------------------------------------------
-- Treat natural=meadow as a synonym for landuse=meadow, if no other landuse
-- ----------------------------------------------------------------------------
   if (( passedt.natural == "meadow" ) and
       ( passedt.landuse == nil      )) then
      passedt.landuse = "meadow"
   end

-- ----------------------------------------------------------------------------
-- "historic=bunker" and "historic=ruins;ruins=bunker"
-- This is set here to prevent unnamedcommercial being set just below.
-- 3 selections make up our "historic" bunkers, "or"ed together.
-- The first "or" includes "building=pillbox" because they are all historic.
-- In the "disused" check we also include "building=bunker".
-- ----------------------------------------------------------------------------
   if ((((  passedt.historic == "bunker"                      )   or
         (( passedt.historic == "ruins"                      )    and
          ( passedt.ruins    == "bunker"                     ))   or
         (  passedt.historic == "pillbox"                     )   or
         (  passedt.building == "pillbox"                     ))  and
        (   passedt.military == nil                            )) or
       ((   passedt["disused:military"] == "bunker"               )  and
        ((  passedt.military         == nil                   )   or
         (  passedt.military         == ""                    ))) or
       (((  passedt.military         == "bunker"              )   or
         (  passedt.building         == "bunker"              ))  and
        ((  passedt.disused          == "yes"                 )   or
         (( passedt.historic         ~= nil                  )   and
          ( passedt.historic         ~= ""                   )   and
          ( passedt.historic         ~= "no"                 ))))) then
      passedt.historic = "bunker"
      passedt.disused = nil
      passedt["disused:military"] = nil
      passedt.military = nil
      passedt.ruins = nil
      passedt.tourism  = nil

      if ((( passedt.landuse == nil )  or
           ( passedt.landuse == ""  )) and
          (( passedt.leisure == nil )  or
           ( passedt.leisure == ""  )) and
          (( passedt.natural == nil )  or
           ( passedt.natural == ""  ))) then
         passedt.landuse = "historic"
      end
   end

-- ----------------------------------------------------------------------------
-- highway=services is translated to commercial landuse - any overlaid parking
-- can then be seen.
--
-- highway=rest_area is translated lower down to amenity=parking.
-- ----------------------------------------------------------------------------
   if (  passedt.highway == "services" ) then
      passedt.highway = nil
      passedt.landuse = "commercial"
   end

-- ----------------------------------------------------------------------------
-- Things without icons - add "commercial" landuse to include a name 
-- (if one exists) too.
-- ----------------------------------------------------------------------------
   if (( passedt.landuse      == "churchyard"               ) or
       ( passedt.landuse      == "religious"                ) or
       ( passedt.leisure      == "racetrack"                ) or
       ( passedt.landuse      == "aquaculture"              ) or
       ( passedt.landuse      == "fishfarm"                 ) or
       ( passedt.industrial   == "fish_farm"                ) or
       ( passedt["seamark:type"] == "marine_farm"              )) then
      passedt.landuse = "commercial"
   end

-- ----------------------------------------------------------------------------
-- Shop groups - just treat as retail landuse.
-- ----------------------------------------------------------------------------
   if (( passedt.shop    == "mall"            ) or
       ( passedt.amenity == "marketplace"     ) or
       ( passedt.shop    == "market"          ) or
       ( passedt.amenity == "market"          ) or
       ( passedt.amenity == "food_court"      ) or
       ( passedt.shop    == "shopping_centre" )) then
      passedt.landuse = "retail"
   end

-- ----------------------------------------------------------------------------
-- Scout camps etc.
-- ----------------------------------------------------------------------------
   if (( passedt.amenity   == "scout_camp"     ) or
       ( passedt.landuse   == "scout_camp"     ) or	
       ( passedt.leisure   == "fishing"        ) or
       ( passedt.leisure   == "outdoor_centre" )) then
      passedt.leisure = "park"
   end

-- ----------------------------------------------------------------------------
-- Some people tag beach resorts as beaches - remove "beach_resort" there.
-- ----------------------------------------------------------------------------
   if (( passedt.leisure == "beach_resort" ) and
       ( passedt.natural == "beach"        )) then
      passedt.leisure = nil
   end

-- ----------------------------------------------------------------------------
-- Remove tourism=attraction from rock features that are rendered as rock(s)
-- ----------------------------------------------------------------------------
   if ((  passedt.tourism   == "attraction"     ) and
       (( passedt.natural   == "bare_rock"     ) or
        ( passedt.natural   == "boulder"       ) or
        ( passedt.natural   == "rock"          ) or
        ( passedt.natural   == "rocks"         ) or
        ( passedt.natural   == "stone"         ) or
        ( passedt.natural   == "stones"        ) or
        ( passedt.climbing  == "boulder"       ))) then
      passedt.tourism = nil
   end

-- ----------------------------------------------------------------------------
-- There is at least one closed "natural=couloir" with "surface=scree".
-- ----------------------------------------------------------------------------
   if (( passedt.natural ~= nil     ) and
       ( passedt.natural ~= ""      ) and
       ( passedt.surface == "scree" )) then
      passedt.natural = "scree"
   end

-- ----------------------------------------------------------------------------
-- Render tidal beaches with more blue
-- ----------------------------------------------------------------------------
   if ((  passedt.natural   == "beach"      ) and
       (( passedt.tidal     == "yes"       )  or
        ( passedt.wetland   == "tidalflat" ))) then
      passedt.natural = "tidal_beach"
   end

-- ----------------------------------------------------------------------------
-- Render tidal scree with more blue
-- ----------------------------------------------------------------------------
   if (( passedt.natural   == "scree" ) and
       ( passedt.tidal     == "yes"   )) then
      passedt.natural = "tidal_scree"
   end

-- ----------------------------------------------------------------------------
-- Render tidal shingle with more blue
-- ----------------------------------------------------------------------------
   if (( passedt.natural   == "shingle" ) and
       ( passedt.tidal     == "yes"     )) then
      passedt.natural = "tidal_shingle"
   end

-- ----------------------------------------------------------------------------
-- Change natural=rocks on non-nodes to natural=bare_rock
-- ----------------------------------------------------------------------------
   if (( passedt.natural   == "rocks"  ) or
       ( passedt.natural   == "stones" )) then
      passedt.natural = "bare_rock"
   end

-- ----------------------------------------------------------------------------
-- Render tidal rocks with more blue
-- ----------------------------------------------------------------------------
   if ((  passedt.natural   == "bare_rock"  ) and
       (( passedt.tidal     == "yes"       )  or
        ( passedt.wetland   == "tidalflat" ))) then
      passedt.natural = "tidal_rock"
   end

-- ----------------------------------------------------------------------------
-- Boulders - are they climbing boulders or not?
-- If yes, let them get detected as "climbing pitches" ("amenity=pitch_climbing") 
-- or non-pitch climbing features ("natural=climbing")
-- ----------------------------------------------------------------------------
   if ((  passedt.natural    == "boulder"          ) or
       (( passedt.natural    == "stone"           )  and
        ( passedt.geological == "glacial_erratic" ))) then
      if (( passedt.sport    ~= "climbing"            ) and
          ( passedt.sport    ~= "climbing;bouldering" ) and
          ( passedt.climbing ~= "boulder"             )) then
         passedt.natural = "rock"
      end
   end

-- ----------------------------------------------------------------------------
-- Some things are rendered line pitch to differentiate from any underlying park.
-- "cricket_nets" is an oddity.  See https://lists.openstreetmap.org/pipermail/tagging/2023-January/thread.html#66908 .
-- ----------------------------------------------------------------------------
   if (( passedt.sport   == "cricket_nets"       ) or
       ( passedt.sport   == "cricket_nets;multi" ) or
       ( passedt.leisure == "practice_pitch"     )) then
      passedt.leisure = "pitch"
   end

-- ----------------------------------------------------------------------------
-- Show skate parks etc. (that aren't skate shops, or some other leisure 
-- already) as pitches.
-- ----------------------------------------------------------------------------
   if ((( passedt.sport    == "skateboard"     )  or
        ( passedt.sport    == "skateboard;bmx" )) and
       (( passedt.shop     == nil              )  or
        ( passedt.shop     == ""               )) and
       (( passedt.leisure  == nil              )  or
        ( passedt.leisure  == ""               ))) then
      passedt.leisure = "pitch"
   end

-- ----------------------------------------------------------------------------
-- Map leisure=wildlife_hide to bird_hide etc.  Many times it will be.
-- ----------------------------------------------------------------------------
   if (( passedt.leisure      == "wildlife_hide" ) or
       ( passedt.amenity      == "wildlife_hide" ) or
       ( passedt.man_made     == "wildlife_hide" ) or
       ( passedt.amenity      == "bird_hide"     )) then
      passedt.leisure  = "bird_hide"
      passedt.amenity  = nil
      passedt.man_made = nil
   end

   if ((( passedt.amenity       == "hunting_stand" )   and
        ( passedt.hunting_stand == "grouse_butt"   ))  or
       ( passedt.man_made       == "grouse_butt"    )) then
      passedt.leisure = "grouse_butt"
      passedt.amenity = nil
      passedt.man_made = nil
   end

   if ( passedt.amenity == "hunting_stand" ) then
      passedt.leisure = "hunting_stand"
      passedt.amenity = nil
   end

-- ----------------------------------------------------------------------------
-- Treat harbour=yes as landuse=harbour, if not already landuse.
-- ----------------------------------------------------------------------------
   if ((  passedt.harbour == "yes"  ) and
       (( passedt.landuse == nil   )  or
        ( passedt.landuse == ""    ))) then
      passedt.landuse = "harbour"
   end

end -- consolidate_lua_03_t( passedt )

function append_prow_ref_t( passedt )
    if (( passedt.prow_ref ~= nil ) and
        ( passedt.prow_ref ~= ""  )) then
       if (( passedt.name == nil )  or
           ( passedt.name == "" )) then
          passedt.name     = "(" .. passedt.prow_ref .. ")"
          passedt.prow_ref = nil
       else
          passedt.name     = passedt.name .. " (" .. passedt.prow_ref .. ")"
          passedt.prow_ref = nil
       end
    end
end -- append_prow_ref_t

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