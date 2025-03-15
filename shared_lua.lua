-- ----------------------------------------------------------------------------
-- shared_lua.lua
--
-- Copyright (C) 2024-2025  Andy Townsend
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
   if ((  passedt.highway == "unclassified"   ) and
       (( passedt.surface == "dirt"          )  or
        ( passedt.surface == "dirt/sand"     )  or
        ( passedt.surface == "earth"         )  or
        ( passedt.surface == "fine_gravel"   )  or
        ( passedt.surface == "grass"         )  or
        ( passedt.surface == "grass;sand"    )  or
        ( passedt.surface == "gravel"        )  or
        ( passedt.surface == "ground"        )  or
        ( passedt.surface == "mud"           )  or
        ( passedt.surface == "pebblestone"   )  or
        ( passedt.surface == "sand"          )  or
        ( passedt.surface == "unpaved"       )  or 
        ( passedt.surface == "unpaved/paved" ))) then
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
-- Raster only:
-- Render narrow tertiary roads with a sidewalk as unclassified.
-- On vector, "highway" will only ever be "tertiary" and "edge" will be set.
-- ----------------------------------------------------------------------------
   if ((  passedt.highway    == "tertiary_sidewalk" )  and
       (( passedt.oneway     == nil                )   or
        ( passedt.oneway     == ""                 ))  and
       (( passedt.junction   == nil                )   or
        ( passedt.junction   == ""                 ))  and
       ((( tonumber(passedt.width)    or 4 ) <=  3 ) or
        (( tonumber(passedt.maxwidth) or 4 ) <=  3 ))) then
      passedt.highway = "unclassified_sidewalk"
   end

-- ----------------------------------------------------------------------------
-- Raster only:
-- If a road isn't oneway, junction, doesn't have "lanes" or any width set, 
-- and does have "passing_places", assuming it's narrow.
-- ----------------------------------------------------------------------------
   if ((  passedt.highway        == "tertiary_sidewalk" )  and
       (( passedt.oneway         == nil                )   or
        ( passedt.oneway         == ""                 ))  and
       (( passedt.junction       == nil                )   or
        ( passedt.junction       == ""                 ))  and
       (( passedt.lanes          == nil                )   or
        ( passedt.lanes          == ""                 ))  and
       (( passedt.maxwidth       == nil                )   or
        ( passedt.maxwidth       == ""                 ))  and
       (( passedt.width          == nil                )   or
        ( passedt.width          == ""                 ))  and
       (  passedt.passing_places ~= nil                 )   and
       (  passedt.passing_places ~= ""                  )   and
       (  passedt.passing_places ~= "no"                )   and
       (  passedt.passing_places ~= "unknown"           )) then
      passedt.highway = "unclassified_sidewalk"
   end

-- ----------------------------------------------------------------------------
-- Raster only:
-- Render narrow tertiary roads with a verge as unclassified.
-- On vector, "highway" will only ever be "tertiary" and "edge" will be set.
-- ----------------------------------------------------------------------------
   if ((  passedt.highway    == "tertiary_verge"  )  and
       (( passedt.oneway     == nil              )   or
        ( passedt.oneway     == ""               ))  and
       (( passedt.junction   == nil              )   or
        ( passedt.junction   == ""               ))  and
       ((( tonumber(passedt.width)    or 4 ) <=  3 ) or
        (( tonumber(passedt.maxwidth) or 4 ) <=  3 ))) then
      passedt.highway = "unclassified_verge"
   end

-- ----------------------------------------------------------------------------
-- Raster only:
-- If a road isn't oneway, junction, doesn't have "lanes" or any width set, 
-- and does have "passing_places", assuming it's narrow.
-- ----------------------------------------------------------------------------
   if ((  passedt.highway        == "tertiary_verge"    )  and
       (( passedt.oneway         == nil                )   or
        ( passedt.oneway         == ""                 ))  and
       (( passedt.junction       == nil                )   or
        ( passedt.junction       == ""                 ))  and
       (( passedt.lanes          == nil                )   or
        ( passedt.lanes          == ""                 ))  and
       (( passedt.maxwidth       == nil                )   or
        ( passedt.maxwidth       == ""                 ))  and
       (( passedt.width          == nil                )   or
        ( passedt.width          == ""                 ))  and
       (  passedt.passing_places ~= nil                 )   and
       (  passedt.passing_places ~= ""                  )   and
       (  passedt.passing_places ~= "no"                )   and
       (  passedt.passing_places ~= "unknown"           )) then
      passedt.highway = "unclassified_verge"
   end

-- ----------------------------------------------------------------------------
-- Both raster and vector:
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
-- Raster and vector:
-- If a road isn't oneway, junction, doesn't have "lanes" or any width set, 
-- and does have "passing_places", assuming it's narrow.
-- ----------------------------------------------------------------------------
   if ((  passedt.highway        == "tertiary"          )  and
       (( passedt.oneway         == nil                )   or
        ( passedt.oneway         == ""                 ))  and
       (( passedt.junction       == nil                )   or
        ( passedt.junction       == ""                 ))  and
       (( passedt.lanes          == nil                )   or
        ( passedt.lanes          == ""                 ))  and
       (( passedt.maxwidth       == nil                )   or
        ( passedt.maxwidth       == ""                 ))  and
       (( passedt.width          == nil                )   or
        ( passedt.width          == ""                 ))  and
       (  passedt.passing_places ~= nil                 )   and
       (  passedt.passing_places ~= ""                  )   and
       (  passedt.passing_places ~= "no"                )   and
       (  passedt.passing_places ~= "unknown"           )) then
      passedt.highway = "unclassified"
   end

-- ----------------------------------------------------------------------------
-- Render bus guideways as "a sort of railway" rather than in their own
-- highway layer.
--
-- Also render bus-only service roads tagged as "highway=busway" similarly.
-- "busway" was previously used mostly on bus lanes in bus stations etc.,
-- but now (in UK/IE at least) is used for longer bus service roads, so
-- it makes sense to include busways with bus_guideways rather than
-- service roads now.
-- ----------------------------------------------------------------------------
   if (( passedt.highway == "bus_guideway" ) or
       ( passedt.highway == "busway"       )) then
      passedt.highway = nil
      passedt.railway = "bus_guideway"
   end

-- ----------------------------------------------------------------------------
-- Bridge types
--
-- A "low water crossing" on a waterway is unlikely to be a waterway over a
-- bridge in any normal bridge sense, so remove it.  Leave any tunnel tags on
-- the way or ford tags on nodes.
-- ----------------------------------------------------------------------------
   if (( passedt.bridge   == "low_water_crossing" ) and
       ( passedt.waterway ~= nil                  ) and
       ( passedt.waterway ~= ""                   )) then
      passedt.bridge = "no"
   end

-- ----------------------------------------------------------------------------
-- Something that is allegedly both a bridge and a tunnel on a waterway is 
-- unlikely to be both of those things.
-- ----------------------------------------------------------------------------
   if (( passedt.bridge   ~= nil  ) and
       ( passedt.bridge   ~= ""   ) and
       ( passedt.bridge   ~= "no" ) and
       ( passedt.tunnel   ~= nil  ) and
       ( passedt.tunnel   ~= ""   ) and
       ( passedt.waterway ~= nil  ) and
       ( passedt.waterway ~= ""   )) then
      passedt.bridge = "no"
   end

-- ----------------------------------------------------------------------------
-- Next, convert many bridge types to "yes" and ignore the others.
-- Later "bridge=levee" will be used on highways to mean "this is on an
-- embankment"
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
   if ((  passedt.amenity          == "fuel"     )  and
       (  passedt["fuel:electricity"] == "yes"   )  and
       (( passedt["fuel:diesel"]      == nil    )   or
        ( passedt["fuel:diesel"]      == ""     ))) then
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
-- Bridge structures - display as building=bridge_area.
-- Other "almost buildings - display as building=roof.
-- Also farmyard "bunker silos" and canopies, and natural arches.
-- Also railway traversers and more.
-- ----------------------------------------------------------------------------
   if ( passedt.man_made == "bridge" ) then
      passedt.building = "bridge_area"
   end

   if ((    passedt.natural          == "arch"            ) or
       (    passedt.man_made         == "bunker_silo"     ) or
       (    passedt.man_made         == "crane"           ) or
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
        ((  passedt.building         == nil             )  or
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
-- "historic", and that actual historic ones are treated as historic.
-- "museum" is a bit of a special case many watermills and windmills are
-- historic (but not tagged as such), somewhat operational, and also museums.
-- We treat them as historic mills.
-- ----------------------------------------------------------------------------
   if (( passedt.man_made == "watermill") or
       ( passedt.man_made == "windmill" )) then
      if (( passedt.disused              == "yes"      ) or
          ( passedt["watermill:disused"] == "yes"      ) or
          ( passedt["windmill:disused"]  == "yes"      ) or
          ( passedt.tourism              == "museum"   ) or
          ( passedt.historic             == "building" )) then
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
         (  passedt.historic == "building"        )  or
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
         (  passedt.historic == "building"        )  or
         (  passedt.historic == "restoration"     )  or
         (  passedt.historic == "heritage"        )  or
         (  passedt.historic == "industrial"      )  or
         (  passedt.historic == "tower"           )))) then
      passedt.historic = "windmill"
   end

-- ----------------------------------------------------------------------------
-- Some things that are historic watermills and windmills have other tags that
-- should take priority over the watermill / windmill tags.  Those that don't
-- are listed here.  "museum" is here because many mills and former mills are
-- museums and we want to see them as mills.
-- ----------------------------------------------------------------------------
   if (( passedt.man_made  == "watermill"        )  or
       ( passedt.man_made  == "windmill"         )) then
      if ((  passedt.tourism   ~= nil                 ) and
          (  passedt.tourism   ~= ""                  ) and
          (  passedt.tourism   ~= "attraction"        ) and
          (  passedt.tourism   ~= "information"       ) and
          (  passedt.tourism   ~= "museum"            ) and
          (  passedt.tourism   ~= "viewpoint"         ) and
          (  passedt.tourism   ~= "yes"               )) then
         passedt.man_made = nil
      else
         passedt.tourism = nil
      end
   end

   if (( passedt.historic  == "watermill"        )  or
       ( passedt.historic  == "windmill"         )) then
      if ((  passedt.tourism   ~= nil                 ) and
          (  passedt.tourism   ~= ""                  ) and
          (  passedt.tourism   ~= "attraction"        ) and
          (  passedt.tourism   ~= "information"       ) and
          (  passedt.tourism   ~= "museum"            ) and
          (  passedt.tourism   ~= "viewpoint"         ) and
          (  passedt.tourism   ~= "yes"               )) then
         passedt.historic = nil
      else
         passedt.tourism = nil
      end
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

      if (( passedt.wetland == "swamp"      ) or
          ( passedt.wetland == "bog"        ) or
          ( passedt.wetland == "string_bog" )) then
         passedt.natural = passedt.wetland
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

      append_inscription_t( passedt )
      append_directions_t( passedt )
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

      append_inscription_t( passedt )
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

-- ----------------------------------------------------------------------------
-- landuse=field is rarely used.  I tried unsuccessfully to change the colour 
-- in the stylesheet so am mapping it here.
-- ----------------------------------------------------------------------------
   if (passedt.landuse   == "field") then
      passedt.landuse = "farmland"
   end

-- ----------------------------------------------------------------------------
-- Various tags for showgrounds
-- Other tags are suppressed to prevent them appearing ahead of "landuse"
-- ----------------------------------------------------------------------------
   if ((  passedt.amenity    == "showground"       )  or
       (  passedt.leisure    == "showground"       )  or
       (  passedt.amenity    == "show_ground"      )  or
       (  passedt.amenity    == "show_grounds"     )  or
       (( passedt.tourism    == "attraction"      )   and
        ( passedt.attraction == "showground"      ))  or
       (  passedt.amenity    == "festival_grounds" )  or
       (  passedt.amenity    == "car_boot_sale"    )) then
      passedt.amenity = nil
      passedt.leisure = nil
      passedt.tourism = nil
      passedt.landuse = "meadow"
   end

-- ----------------------------------------------------------------------------
-- Some kinds of farmland and meadow should be changed to "landuse=farmgrass", 
-- which is rendered slightly greener than the normal farmland (and less green 
-- than landuse=meadow)
-- ----------------------------------------------------------------------------
   if ((  passedt.landuse  == "farmland"                    ) and
       (( passedt.farmland == "pasture"                    )  or
        ( passedt.farmland == "heath"                      )  or
        ( passedt.farmland == "paddock"                    )  or
        ( passedt.farmland == "meadow"                     )  or
        ( passedt.farmland == "pasture;heath"              )  or
        ( passedt.farmland == "turf_production"            )  or
        ( passedt.farmland == "grassland"                  )  or
        ( passedt.farmland == "wetland"                    )  or
        ( passedt.farmland == "marsh"                      )  or
        ( passedt.farmland == "turf"                       )  or
        ( passedt.farmland == "animal_keeping"             )  or
        ( passedt.farmland == "grass"                      )  or
        ( passedt.farmland == "crofts"                     )  or
        ( passedt.farmland == "scrub"                      )  or
        ( passedt.farmland == "pasture;wetland"            )  or
        ( passedt.farmland == "equestrian"                 )  or
        ( passedt.animal   == "cow"                        )  or
        ( passedt.animal   == "cattle"                     )  or
        ( passedt.animal   == "chicken"                    )  or
        ( passedt.animal   == "horse"                      )  or
        ( passedt.meadow   == "agricultural"               )  or
        ( passedt.meadow   == "paddock"                    )  or
        ( passedt.meadow   == "pasture"                    )  or
        ( passedt.produce  == "turf"                       )  or
        ( passedt.produce  == "grass"                      )  or
        ( passedt.produce  == "Silage"                     )  or
        ( passedt.produce  == "cow"                        )  or
        ( passedt.produce  == "cattle"                     )  or
        ( passedt.produce  == "milk"                       )  or
        ( passedt.produce  == "dairy"                      )  or
        ( passedt.produce  == "meat"                       )  or
        ( passedt.produce  == "horses"                     )  or
        ( passedt.produce  == "live_animal"                )  or
        ( passedt.produce  == "live_animal;cows"           )  or
        ( passedt.produce  == "live_animal;sheep"          )  or
        ( passedt.produce  == "live_animal;Cattle_&_Sheep" )  or
        ( passedt.produce  == "live_animals"               ))) then
      passedt.landuse = "farmgrass"
   end

   if ((  passedt.landuse  == "meadow"        ) and
       (( passedt.meadow   == "agricultural" )  or
        ( passedt.meadow   == "paddock"      )  or
        ( passedt.meadow   == "pasture"      )  or
        ( passedt.meadow   == "agriculture"  )  or
        ( passedt.meadow   == "hay"          )  or
        ( passedt.meadow   == "managed"      )  or
        ( passedt.meadow   == "cut"          )  or
        ( passedt.animal   == "pig"          )  or
        ( passedt.animal   == "sheep"        )  or
        ( passedt.animal   == "cow"          )  or
        ( passedt.animal   == "cattle"       )  or
        ( passedt.animal   == "chicken"      )  or
        ( passedt.animal   == "horse"        )  or
        ( passedt.farmland == "field"        )  or
        ( passedt.farmland == "pasture"      )  or
        ( passedt.farmland == "crofts"       ))) then
      passedt.landuse = "farmgrass"
   end

   if (( passedt.landuse == "paddock"        ) or
       ( passedt.landuse == "animal_keeping" )) then
      passedt.landuse = "farmgrass"
   end

-- ----------------------------------------------------------------------------
-- As well as agricultural meadows, we show a couple of other subtags of meadow
-- slightly differently.
-- ----------------------------------------------------------------------------
   if (( passedt.landuse  == "meadow"       ) and
       ( passedt.meadow   == "transitional" )) then
      passedt.landuse = "meadowtransitional"
   end

   if (( passedt.landuse  == "meadow"       ) and
       ( passedt.meadow   == "wildflower" )) then
      passedt.landuse = "meadowwildflower"
   end

   if (( passedt.landuse  == "meadow"       ) and
       ( passedt.meadow   == "perpetual" )) then
      passedt.landuse = "meadowperpetual"
   end

-- ----------------------------------------------------------------------------
-- Change landuse=greenhouse_horticulture to farmyard.
-- ----------------------------------------------------------------------------
   if (passedt.landuse   == "greenhouse_horticulture") then
      passedt.landuse = "farmyard"
   end

-- ----------------------------------------------------------------------------
-- Attempt to do something sensible with trees
--
-- "boundary=forest" is the latest attempt to resolve the "landuse=forest is 
-- used for different things" issue.  Unfortunately, it can also be used with 
-- other landuse values.
--
-- There are a few 10s of natural=woodland and natural=forest; treat them the same
-- as other woodland.  If we have landuse=forest on its own without
-- leaf_type, then we don't change it - we'll handle that separately in the
-- mss file.
-- ----------------------------------------------------------------------------
  if ((  passedt.boundary == "forest"  ) and
      (( passedt.landuse  == nil      )  or
       ( passedt.landuse  == ""       ))) then
      passedt.landuse = "forest"
      passedt.boundary = nil
  end

  if ( passedt.landuse == "forestry" ) then
      passedt.landuse = "forest"
  end

  if ( passedt.natural == "woodland" ) then
      passedt.natural = "wood"
  end

-- ----------------------------------------------------------------------------
-- Use operator (but not brand) on various natural objects, always in brackets.
-- (compare with the similar check including "brand" for e.g. "atm" below)
-- This is done before we change tags based on leaf_type.
-- ----------------------------------------------------------------------------
   if (( passedt.landuse == "forest" )  or
       ( passedt.natural == "wood"   )) then
      if (( passedt.name == nil ) or
          ( passedt.name == ""  )) then
         if (( passedt.operator ~= nil ) and
             ( passedt.operator ~= ""  )) then
            passedt.name = "(" .. passedt.operator .. ")"
            passedt.operator = nil
         end
      else
         if (( passedt.operator ~= nil           )  and
             ( passedt.operator ~= ""            )  and
             ( passedt.operator ~= passedt.name  )) then
            passedt.name = passedt.name .. " (" .. passedt.operator .. ")"
            passedt.operator = nil
         end
      end
   end

  if (((  passedt.landuse   == "forest"     )  and
       (  passedt.leaf_type ~= nil          )  and
       (  passedt.leaf_type ~= ""           )) or
      (   passedt.natural   == "forest"      ) or
      (   passedt.landcover == "trees"       ) or
      ((  passedt.natural   == "tree_group" )  and
       (( passedt.landuse   == nil         )   or
        ( passedt.landuse   == ""          ))  and
       (( passedt.leisure   == nil         )   or
        ( passedt.leisure   == ""          )))) then
      passedt.landuse = nil
      passedt.natural = "wood"
   end

-- ----------------------------------------------------------------------------
-- The "landcover" layer considers a whole bunch of tags to incorporate into
-- one layer.  The way that this is done (derived from OSM Carto from some
-- years back) means that an unexpected and unrendered "landuse" tag might
-- prevent a valid "natural" one from being displayed.
-- Other combinations will also be affected, but have not been seen occurring
-- together.
-- ----------------------------------------------------------------------------
   if (( passedt.landuse ~= nil    ) and
       ( passedt.landuse ~= ""     ) and
       ( passedt.natural == "wood" )) then
      passedt.landuse = nil
   end

   if (( passedt.leaf_type   == "broadleaved"  )  and
       ( passedt.natural     == "wood"         )) then
      passedt.landuse = nil
      passedt.natural = "broadleaved"
   end

   if (( passedt.leaf_type   == "needleleaved" )  and
       ( passedt.natural     == "wood"         )) then
      passedt.landuse = nil
      passedt.natural = "needleleaved"
   end

   if (( passedt.leaf_type   == "mixed"        )  and
       ( passedt.natural     == "wood"         )) then
      passedt.landuse = nil
      passedt.natural = "mixedleaved"
   end

-- ----------------------------------------------------------------------------
-- Consolidate some unusual wheelchair tags
-- ----------------------------------------------------------------------------
   if (( passedt.wheelchair == "1"                )  or
       ( passedt.wheelchair == "2"                )  or
       ( passedt.wheelchair == "3"                )  or
       ( passedt.wheelchair == "5"                )  or
       ( passedt.wheelchair == "bell"             )  or
       ( passedt.wheelchair == "customers"        )  or
       ( passedt.wheelchair == "designated"       )  or
       ( passedt.wheelchair == "destination"      )  or
       ( passedt.wheelchair == "friendly"         )  or
       ( passedt.wheelchair == "full"             )  or
       ( passedt.wheelchair == "number of rooms"  )  or
       ( passedt.wheelchair == "official"         )  or
       ( passedt.wheelchair == "on request"       )  or
       ( passedt.wheelchair == "only"             )  or
       ( passedt.wheelchair == "permissive"       )  or
       ( passedt.wheelchair == "ramp"             )  or
       ( passedt.wheelchair == "unisex"           )) then
      passedt.wheelchair = "yes"
   end

   if (( passedt.wheelchair == "difficult"                    )  or
       ( passedt.wheelchair == "limited (No automatic door)"  )  or
       ( passedt.wheelchair == "limited, notice required"     )  or
       ( passedt.wheelchair == "restricted"                   )) then
      passedt.wheelchair = "limited"
   end

   if ( passedt.wheelchair == "impractical" ) then
      passedt.wheelchair = "limited"
   end

-- ----------------------------------------------------------------------------
-- Remove "real_ale" tag on industrial and craft breweries that aren't also
-- a pub, bar, restaurant, cafe etc. or hotel.
-- ----------------------------------------------------------------------------
   if ((( passedt.industrial == "brewery" ) or
        ( passedt.craft      == "brewery" )) and
       (  passedt.real_ale   ~= nil        ) and
       (  passedt.real_ale   ~= ""         ) and
       (  passedt.real_ale   ~= "maybe"    ) and
       (  passedt.real_ale   ~= "no"       ) and
       (( passedt.amenity    == nil       )  or
        ( passedt.amenity    == ""        )) and
       (  passedt.tourism   ~= "hotel"     )) then
      passedt.real_ale = nil
      passedt.real_cider = nil
   end

-- ----------------------------------------------------------------------------
-- Remove "shop" tag on industrial or craft breweries.
-- We pick one thing to display them as, and in this case it's "brewery".
-- ----------------------------------------------------------------------------
   if ((( passedt.industrial == "brewery" ) or
        ( passedt.craft      == "brewery" ) or
        ( passedt.craft      == "cider"   )) and
       (  passedt.shop       ~= nil        ) and
       (  passedt.shop       ~= ""         )) then
      passedt.shop = nil
   end

-- ----------------------------------------------------------------------------
-- Don't show pubs, cafes or restaurants if you can't actually get to them.
-- ----------------------------------------------------------------------------
   if ((( passedt.amenity == "pub"        ) or
        ( passedt.amenity == "cafe"       ) or
        ( passedt.amenity == "restaurant" )) and
       (  passedt.access  == "no"          )) then
      passedt.amenity = nil
   end

-- ----------------------------------------------------------------------------
-- Suppress historic tag on pubs.
-- ----------------------------------------------------------------------------
   if (( passedt.amenity  == "pub"     ) and
       ( passedt.historic ~= nil       ) and
       ( passedt.historic ~= ""        )) then
      passedt.historic = nil
   end

-- ----------------------------------------------------------------------------
-- If "leisure=music_venue" is set try and work out if something should take 
-- precedence.
-- We do this check here rather than at "concert_hall" further down because 
-- "bar" and "pub" can be changed below based on other tags.
-- ----------------------------------------------------------------------------
   if ( passedt.leisure == "music_venue" ) then
      if (( passedt.amenity == "bar" ) or
          ( passedt.amenity == "pub" )) then
         passedt.leisure = nil
      else
         passedt.amenity = "concert_hall"
      end
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
   if (( passedt.amenity   == "pub"   ) and
       ( passedt.tourism   ~= nil     ) and
       ( passedt.tourism   ~= ""      )) then
      if (( passedt.tourism   == "hotel"             ) or
          ( passedt.tourism   == "guest_house"       ) or
          ( passedt.tourism   == "bed_and_breakfast" ) or
          ( passedt.tourism   == "chalet"            ) or
          ( passedt.tourism   == "hostel"            ) or
          ( passedt.tourism   == "motel"             )) then
         passedt.accommodation = "yes"
      end

      passedt.tourism = nil
   end

   if (( passedt.tourism == "hotel" ) and
       ( passedt.pub     == "yes"   )) then
      passedt.accommodation = "yes"
      passedt.amenity = "pub"
      passedt.pub = nil
      passedt.tourism = nil
   end

   if ((( passedt.tourism  == "hotel"       )   or
        ( passedt.tourism  == "guest_house" ))  and
       (  passedt.real_ale ~= nil            )  and
       (  passedt.real_ale ~= ""             )  and
       (  passedt.real_ale ~= "maybe"        )  and
       (  passedt.real_ale ~= "no"           )) then
      passedt.accommodation = "yes"
      passedt.amenity = "pub"
      passedt.tourism = nil
   end

   if ((  passedt.leisure         == "outdoor_seating" ) and
       (( passedt.surface         == "grass"          ) or
        ( passedt.beer_garden     == "yes"            ) or
        ( passedt.outdoor_seating == "garden"         ))) then
      passedt.leisure = "garden"
      passedt.garden = "beer_garden"
   end

   if ((  passedt["abandoned:amenity"] == "pub"             )   or
       (  passedt["amenity:disused"]   == "pub"             )   or
       (  passedt.disused           == "pub"             )   or
       (  passedt["disused:pub"]       == "yes"             )   or
       (  passedt.former_amenity    == "former_pub"      )   or
       (  passedt.former_amenity    == "pub"             )   or
       (  passedt.former_amenity    == "old_pub"         )   or
       (  passedt["former:amenity"]    == "pub"             )   or
       (  passedt.old_amenity       == "pub"             )) then
      passedt["disused:amenity"] = "pub"
      passedt["amenity:disused"] = nil
      passedt.disused = nil
      passedt["disused:pub"] = nil
      passedt.former_amenity = nil
      passedt.old_amenity = nil
   end

   if ((  passedt.historic == "pub"  ) and
       (( passedt.amenity  == nil   )  or
        ( passedt.amenity  == ""    )) and
       (( passedt.shop     == nil   )  or
        ( passedt.shop     == ""    ))) then
      passedt["disused:amenity"] = "pub"
      passedt.historic = nil
   end

   if ((  passedt.amenity           == "closed_pub"      )   or
       (  passedt.amenity           == "dead_pub"        )   or
       (  passedt.amenity           == "disused_pub"     )   or
       (  passedt.amenity           == "former_pub"      )   or
       (  passedt.amenity           == "old_pub"         )   or
       (( passedt.amenity           == "pub"            )    and
        ( passedt.disused           == "yes"            ))   or
       (( passedt.amenity           == "pub"            )    and
        ( passedt.opening_hours     == "closed"         ))) then
      passedt["disused:amenity"] = "pub"
      passedt["amenity:disused"] = nil
      passedt.disused = nil
      passedt["disused:pub"] = nil
      passedt.former_amenity = nil
      passedt.old_amenity = nil
      passedt.amenity = nil
   end

   if ((   passedt["disused:amenity"]   == "pub"     ) and
       ((( passedt.tourism           ~= nil     )   and
         ( passedt.tourism           ~= ""      ))  or
        (( passedt.amenity           ~= nil     )   and
         ( passedt.amenity           ~= ""      ))  or
        (( passedt.leisure           ~= nil     )   and
         ( passedt.leisure           ~= ""      ))  or
        (( passedt.shop              ~= nil     )   and
         ( passedt.shop              ~= ""      ))  or
        (( passedt.office            ~= nil     )   and
         ( passedt.office            ~= ""      ))  or
        (( passedt.craft             ~= nil     )   and
         ( passedt.craft             ~= ""      )))) then
      passedt["disused:amenity"] = nil
   end

   if ((   passedt.real_ale  ~= nil    ) and
       (   passedt.real_ale  ~= ""     ) and
       ((( passedt.amenity   == nil  )   or
         ( passedt.amenity   == ""   ))  and
        (( passedt.shop      == nil  )   or
         ( passedt.shop      == ""   ))  and
        (( passedt.tourism   == nil  )   or
         ( passedt.tourism   == ""   ))  and
        (( passedt.room      == nil  )   or
         ( passedt.room      == ""   ))  and
        (( passedt.leisure   == nil  )   or
         ( passedt.leisure   == ""   ))  and
        (( passedt.club      == nil  )   or
         ( passedt.club      == ""   )))) then
      passedt.real_ale = nil
   end

-- ----------------------------------------------------------------------------
-- If something has been tagged both as a brewery and a pub or bar, render as
-- a pub with a microbrewery.
-- ----------------------------------------------------------------------------
   if ((( passedt.amenity    == "pub"     )  or
        ( passedt.amenity    == "bar"     )) and
       (( passedt.craft      == "brewery" )  or
        ( passedt.industrial == "brewery" ))) then
      passedt.amenity  = "pub"
      passedt.microbrewery  = "yes"
      passedt.craft  = nil
      passedt.industrial  = nil
   end

-- ----------------------------------------------------------------------------
-- If a food place has a real_ale tag, also add a food tag an let the real_ale
-- tag render.
-- ----------------------------------------------------------------------------
   if ((( passedt.amenity  == "cafe"       )  or
        ( passedt.amenity  == "restaurant" )) and
       (( passedt.real_ale ~= nil          )  and
        ( passedt.real_ale ~= ""           )  and
        ( passedt.real_ale ~= "maybe"      )  and
        ( passedt.real_ale ~= "no"         )) and
       (( passedt.food     == nil          )  or
        ( passedt.food     == ""           ))) then
      passedt.food  = "yes"
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
-- Live or dead pub?  y or n, or c (closed due to covid)
-- Real ale?          y n or d (don't know)
-- Food 	      y or d
-- Noncarpeted floor  y or d
-- Microbrewery	      y n or d
-- Micropub	      y n or d
-- Accommodation      y n or d
-- Wheelchair	      y, l, n or d
-- Beer Garden	      g (beer garden), o (outside seating), d (don't know)
-- ----------------------------------------------------------------------------
   if ((( passedt["description:floor"] ~= nil                 )  and
        ( passedt["description:floor"] ~= ""                  )) or
       (  passedt["floor:material"]    == "brick"              ) or
       (  passedt["floor:material"]    == "brick;concrete"     ) or
       (  passedt["floor:material"]    == "concrete"           ) or
       (  passedt["floor:material"]    == "grubby carpet"      ) or
       (  passedt["floor:material"]    == "lino"               ) or
       (  passedt["floor:material"]    == "lino;carpet"        ) or
       (  passedt["floor:material"]    == "lino;rough_wood"    ) or
       (  passedt["floor:material"]    == "lino;tiles;stone"   ) or
       (  passedt["floor:material"]    == "paving_stones"      ) or
       (  passedt["floor:material"]    == "rough_carpet"       ) or
       (  passedt["floor:material"]    == "rough_wood"         ) or
       (  passedt["floor:material"]    == "rough_wood;carpet"  ) or
       (  passedt["floor:material"]    == "rough_wood;lino"    ) or
       (  passedt["floor:material"]    == "rough_wood;stone"   ) or
       (  passedt["floor:material"]    == "rough_wood;tiles"   ) or
       (  passedt["floor:material"]    == "slate"              ) or
       (  passedt["floor:material"]    == "slate;carpet"       ) or
       (  passedt["floor:material"]    == "stone"              ) or
       (  passedt["floor:material"]    == "stone;carpet"       ) or
       (  passedt["floor:material"]    == "stone;rough_carpet" ) or
       (  passedt["floor:material"]    == "stone;rough_wood"   ) or
       (  passedt["floor:material"]    == "tiles"              ) or
       (  passedt["floor:material"]    == "tiles;rough_wood"   )) then
      passedt.noncarpeted = "yes"
   end

   if (( passedt.micropub == "yes"   ) or
       ( passedt.pub      == "micro" )) then
      passedt.micropub = nil
      passedt.pub      = "micropub"
   end

-- ----------------------------------------------------------------------------
-- The misspelling "accomodation" (with one "m") is quite common.
-- ----------------------------------------------------------------------------
   if ((( passedt.accommodation == nil )   or
        ( passedt.accommodation == ""  ))  and
       (  passedt.accomodation  ~= nil  )  and
       (  passedt.accomodation  ~= ""   )) then
      passedt.accommodation = passedt.accomodation
      passedt.accomodation  = nil
   end
		  
-- ----------------------------------------------------------------------------
-- Next, "closed due to covid" pubs
-- ----------------------------------------------------------------------------
   if ((  passedt.amenity               == "pub"        ) and
       (( passedt["opening_hours:covid19"] == "off"       ) or
        ( passedt["opening_hours:covid19"] == "closed"    ) or
        ( passedt["access:covid19"]        == "no"        ))) then
      passedt.amenity = "pub_cddddddd"
      passedt.real_ale = nil
   end

-- ----------------------------------------------------------------------------
-- Does a pub really serve food?
-- Below we check for "any food value but no".
-- Here we exclude certain food values from counting towards displaying the "F"
-- that says a pub serves food.  As far as I am concerned, sandwiches, pies,
-- or even one of Michael Gove's scotch eggs would count as "food" but a packet
-- of crisps would not.
-- ----------------------------------------------------------------------------
   if ((  passedt.amenity == "pub"         ) and
       (( passedt.food    == "snacks"     ) or
        ( passedt.food    == "bar_snacks" ))) then
      passedt.food = "no"
   end

-- ----------------------------------------------------------------------------
-- Main "real_ale icon selection" logic
-- Note that there's no "if pub" here, so any non-pub establishment that serves
-- real ale will get the icon (hotels, restaurants, cafes, etc.)
-- We have explicitly excluded pubs "closed for covid" above.
-- After this large "if" there is no "else" but another "if" for non-real ale
-- pubs (that does check that the thing is actually a pub).
-- ----------------------------------------------------------------------------
   if (( passedt.real_ale ~= nil     ) and
       ( passedt.real_ale ~= ""      ) and
       ( passedt.real_ale ~= "maybe" ) and
       ( passedt.real_ale ~= "no"    )) then
      if (( passedt.food ~= nil  ) and
          ( passedt.food ~= ""   ) and
          ( passedt.food ~= "no" )) then
         if ( passedt.noncarpeted == "yes"  ) then
            if ( passedt.microbrewery == "yes"  ) then
                           -- pub_yyyyy micropub unchecked (no examples yet)
               if (( passedt.accommodation ~= nil  ) and
                   ( passedt.accommodation ~= ""   ) and
                   ( passedt.accommodation ~= "no" )) then
                  passedt.amenity = "pub_yyyyydy"
                  append_wheelchair_t( passedt )
                           -- no beer garden appended (no examples yet)
	       else -- no accommodation
		  if ( passedt.wheelchair == "yes" ) then
                     passedt.amenity = "pub_yyyyydny"
                     append_beer_garden_t( passedt )
                  else
		     if ( passedt.wheelchair == "limited" ) then
                        passedt.amenity = "pub_yyyyydnl"
                        append_beer_garden_t( passedt )
                     else
                        if ( passedt.wheelchair == "no" ) then
                           passedt.amenity = "pub_yyyyydnn"
                                              -- no beer garden appended (no examples yet)
                        else
                           passedt.amenity = "pub_yyyyydnd"
                           append_beer_garden_t( passedt )
                        end
                     end
                  end
	       end -- accommodation
            else -- no microbrewery
	       if ( passedt.pub == "micropub" ) then
                  passedt.amenity = "pub_yyyynyd"
                                              -- accommodation unchecked (no examples yet)
                  append_wheelchair_t( passedt )
                  append_beer_garden_t( passedt )
               else
                  passedt.amenity = "pub_yyyynn"
                  append_accommodation_t( passedt )
                  append_wheelchair_t( passedt )
                  append_beer_garden_t( passedt )
               end
	    end -- microbrewery
         else -- not noncarpeted
            if ( passedt.microbrewery == "yes"  ) then
               if (( passedt.accommodation ~= nil  ) and
                   ( passedt.accommodation ~= ""   ) and
                   ( passedt.accommodation ~= "no" )) then
		  if ( passedt.wheelchair == "yes" ) then
                     passedt.amenity = "pub_yyydydyy"
                                              -- no beer garden appended (no examples yet)
		  else
		     if ( passedt.wheelchair == "limited" ) then
                        passedt.amenity = "pub_yyydydyl"
                                              -- no beer garden appended (no examples yet)
		     else
		        if ( passedt.wheelchair == "no" ) then
                           passedt.amenity = "pub_yyydydyn"
                                              -- no beer garden appended (no examples yet)
			else
                           passedt.amenity = "pub_yyydydyd"
                           append_beer_garden_t( passedt )
			end
		     end
		  end
	       else
		  if ( passedt.wheelchair == "yes" ) then
                     passedt.amenity = "pub_yyydydny"
                                              -- no beer garden appended (no examples yet)
                  else
		     if ( passedt.wheelchair == "limited" ) then
                        passedt.amenity = "pub_yyydydnl"
                        append_beer_garden_t( passedt )
                     else
		        if ( passedt.wheelchair == "no" ) then
                           passedt.amenity = "pub_yyydydnn"
                                              -- no beer garden appended (no examples yet)
                        else
                           passedt.amenity = "pub_yyydydnd"
                           append_beer_garden_t( passedt )
                        end
                     end
                  end
	       end
	    else
	       if ( passedt.pub == "micropub" ) then
                  passedt.amenity = "pub_yyydnyd"
                                              -- accommodation unchecked (no examples yet)
                  append_wheelchair_t( passedt )
                  append_beer_garden_t( passedt )
               else
                  passedt.amenity = "pub_yyydnn"
                  append_accommodation_t( passedt )
                  append_wheelchair_t( passedt )
                  append_beer_garden_t( passedt )
               end
	    end
         end -- noncarpeted
      else -- no food
         if ( passedt.noncarpeted == "yes"  ) then
            if ( passedt.microbrewery == "yes"  ) then
                                              -- micropub unchecked (no examples yet)
               if (( passedt.accommodation ~= nil  ) and
                   ( passedt.accommodation ~= ""   ) and
                   ( passedt.accommodation ~= "no" )) then
                  passedt.amenity = "pub_yydyydy"
                  append_wheelchair_t( passedt )
                                              -- no beer garden appended (no examples yet)
	       else
	          if ( passedt.wheelchair == "yes" ) then
                     passedt.amenity = "pub_yydyydny"
                                              -- no beer garden appended (no examples yet)
     		  else
	             if ( passedt.wheelchair == "limited" ) then
                        passedt.amenity = "pub_yydyydnl"
                        append_beer_garden_t( passedt )
		     else
		        if ( passedt.wheelchair == "no" ) then
                           passedt.amenity = "pub_yydyydnn"
                           append_beer_garden_t( passedt )
		        else
                           passedt.amenity = "pub_yydyydnd"
                           append_beer_garden_t( passedt )
		        end
		     end
	          end
	       end
	    else
	       if ( passedt.pub == "micropub" ) then
		  if ( passedt.wheelchair == "yes" ) then
                     passedt.amenity = "pub_yydynydy"
                                              -- no beer garden appended (no examples yet)
		  else
		     if ( passedt.wheelchair == "limited" ) then
                        passedt.amenity = "pub_yydynydl"
                        append_beer_garden_t( passedt )
	             else
			if ( passedt.wheelchair == "no" ) then
                           passedt.amenity = "pub_yydynydn"
                           append_beer_garden_t( passedt )
			else
                           passedt.amenity = "pub_yydynydd"
                                              -- no beer garden appended (no examples yet)
			end
	             end
		  end
	       else
                  passedt.amenity = "pub_yydynn"
                  append_accommodation_t( passedt )
                  append_wheelchair_t( passedt )
                  append_beer_garden_t( passedt )
	       end
	    end
         else
            if ( passedt.microbrewery == "yes"  ) then
	       if ( passedt.pub == "micropub" ) then
                           -- accommodation unchecked (no examples yet)
		  if ( passedt.wheelchair == "yes" ) then
                     passedt.amenity = "pub_yyddyydy"
                     append_beer_garden_t( passedt )
                  else
		     if ( passedt.wheelchair == "limited" ) then
                        passedt.amenity = "pub_yyddyydl"
                                             -- no beer garden appended (no examples yet)
                     else
		        if ( passedt.wheelchair == "no" ) then
                           passedt.amenity = "pub_yyddyydn"
                                             -- no beer garden appended (no examples yet)
                        else
                           passedt.amenity = "pub_yyddyydd"
                                             -- no beer garden appended (no examples yet)
                        end
                     end
                  end
               else  -- not micropub
                  if (( passedt.accommodation ~= nil  ) and
                      ( passedt.accommodation ~= ""   ) and
                      ( passedt.accommodation ~= "no" )) then
		     if ( passedt.wheelchair == "yes" ) then
                        passedt.amenity = "pub_yyddynyy"
                        append_beer_garden_t( passedt )
                     else
		        if ( passedt.wheelchair == "limited" ) then
                           passedt.amenity = "pub_yyddynyl"
                                             -- no beer garden appended (no examples yet)
                        else
			   if ( passedt.wheelchair == "no" ) then
                              passedt.amenity = "pub_yyddynyn"
                                             -- no beer garden appended (no examples yet)
                           else
                              passedt.amenity = "pub_yyddynyd"
                              append_beer_garden_t( passedt )
                           end
                        end
                     end
                  else  -- no accommodation
                     passedt.amenity = "pub_yyddynn"
                     append_wheelchair_t( passedt )
                     append_beer_garden_t( passedt )
                  end -- accommodation
               end  -- micropub
	    else  -- not microbrewery
	       if ( passedt.pub == "micropub" ) then
		  if ( passedt.wheelchair == "yes" ) then
                     passedt.amenity = "pub_yyddnydy"
                                             -- no beer garden appended (no examples yet)
		  else
		     if ( passedt.wheelchair == "limited" ) then
                        passedt.amenity = "pub_yyddnydl"
                                             -- no beer garden appended (no examples yet)
		     else
			if ( passedt.wheelchair == "no" ) then
                           passedt.amenity = "pub_yyddnydn"
                           append_beer_garden_t( passedt )
			else
                           passedt.amenity = "pub_yyddnydd"
                           append_beer_garden_t( passedt )
			end
		     end
		  end
               else
                  passedt.amenity = "pub_yyddnn"
                  append_accommodation_t( passedt )
                  append_wheelchair_t( passedt )
                  append_beer_garden_t( passedt )
               end
	    end -- microbrewery
         end
      end -- food
   end -- real_ale

   if (( passedt.real_ale == "no" ) and
       ( passedt.amenity == "pub" )) then
      if (( passedt.food ~= nil  ) and
          ( passedt.food ~= ""   ) and
          ( passedt.food ~= "no" )) then
         if ( passedt.noncarpeted == "yes"  ) then
            passedt.amenity = "pub_ynyyddd"
                                              -- accommodation unchecked (no examples yet)
            append_wheelchair_t( passedt )
            append_beer_garden_t( passedt )
         else
            if (( passedt.accommodation ~= nil  ) and
                ( passedt.accommodation ~= ""   ) and
                ( passedt.accommodation ~= "no" )) then
               if ( passedt.wheelchair == "yes" ) then
                  passedt.amenity = "pub_ynydddyy"
                  append_beer_garden_t( passedt )
	       else
	          if ( passedt.wheelchair == "limited" ) then
                     passedt.amenity = "pub_ynydddyl"
                                              -- no beer garden appended (no examples yet)
	          else
	             if ( passedt.wheelchair == "no" ) then
                        passedt.amenity = "pub_ynydddyn"
                                             -- no beer garden appended (no examples yet)
		     else
                        passedt.amenity = "pub_ynydddyd"
                        append_beer_garden_t( passedt )
	             end
	          end
	       end
	    else  -- accommodation
               if ( passedt.wheelchair == "yes" ) then
                  passedt.amenity = "pub_ynydddny"
                  append_beer_garden_t( passedt )
	       else
	          if ( passedt.wheelchair == "limited" ) then
                     passedt.amenity = "pub_ynydddnl"
                                              -- no beer garden appended (no examples yet)
	          else
	             if ( passedt.wheelchair == "no" ) then
                        passedt.amenity = "pub_ynydddnn"
                                              -- no beer garden appended (no examples yet)
		     else
                        passedt.amenity = "pub_ynydddnd"
                        append_beer_garden_t( passedt )
	             end
	          end
	       end
	    end  -- accommodation
         end
      else
         if ( passedt.noncarpeted == "yes"  ) then
            if (( passedt.accommodation ~= nil  ) and
                ( passedt.accommodation ~= ""   ) and
                ( passedt.accommodation ~= "no" )) then
               passedt.amenity = "pub_yndyddy"
               append_wheelchair_t( passedt )
                                              -- no beer garden appended (no examples yet)
	    else
               passedt.amenity = "pub_yndyddn"
               append_wheelchair_t( passedt )
               append_beer_garden_t( passedt )
	    end
         else
            if (( passedt.accommodation ~= nil  ) and
                ( passedt.accommodation ~= ""   ) and
                ( passedt.accommodation ~= "no" )) then
               passedt.amenity = "pub_ynddddy"
                                              -- no wheelchair appended (no examples yet)
                                              -- no beer garden appended (no examples yet)
	    else
               passedt.amenity = "pub_ynddddn"
               append_wheelchair_t( passedt )
               append_beer_garden_t( passedt )
	    end
         end
      end
   end

-- ----------------------------------------------------------------------------
-- The many and varied taggings for former pubs should have been turned into
-- disused:amenity=pub above, unless some other tag applies.
-- ----------------------------------------------------------------------------
   if ( passedt["disused:amenity"] == "pub" ) then
      passedt.amenity = "pub_nddddddd"
                                                 -- no other attributes checked
   end

-- ----------------------------------------------------------------------------
-- The catch-all here is still "pub" (leaving the tag unchanged)
-- ----------------------------------------------------------------------------
   if ( passedt.amenity == "pub" ) then
      if (( passedt.food ~= nil  ) and
          ( passedt.food ~= ""   ) and
          ( passedt.food ~= "no" )) then
         if ( passedt.noncarpeted == "yes"  ) then
            if ( passedt.microbrewery == "yes"  ) then
               passedt.amenity = "pub_ydyyydd"
                                              -- no wheelchair appended (no examples yet)
                                              -- no beer garden appended (no examples yet)
	    else
               passedt.amenity = "pub_ydyyndd"
               append_wheelchair_t( passedt )
               append_beer_garden_t( passedt )
	    end
         else
            if ( passedt.microbrewery == "yes"  ) then
               if ( passedt.wheelchair == "yes" ) then
                  passedt.amenity = "pub_ydydyddy"
                                              -- no beer garden appended (no examples yet)
       	       else
                  if ( passedt.wheelchair == "limited" ) then
                     passedt.amenity = "pub_ydydyddl"
                                              -- no beer garden appended (no examples yet)
                  else
                     if ( passedt.wheelchair == "no" ) then
                        passedt.amenity = "pub_ydydyddn"
                                              -- no beer garden appended (no examples yet)
                     else
                        passedt.amenity = "pub_ydydyddd"
                        append_beer_garden_t( passedt )
                     end
                  end
               end
	    else
	       if ( passedt.pub == "micropub" ) then
                  if ( passedt.wheelchair == "yes" ) then
                     passedt.amenity = "pub_ydydnydy"
                                              -- no beer garden appended (no examples yet)
           	  else
                     if ( passedt.wheelchair == "limited" ) then
                        passedt.amenity = "pub_ydydnydl"
                                              -- no beer garden appended (no examples yet)
                     else
                        if ( passedt.wheelchair == "no" ) then
                           passedt.amenity = "pub_ydydnydn"
                                              -- no beer garden appended (no examples yet)
	                else
                           passedt.amenity = "pub_ydydnydd"
                           append_beer_garden_t( passedt )
                        end
                     end
	          end
	       else
                  passedt.amenity = "pub_ydydnn"
                  append_accommodation_t( passedt )
                  append_wheelchair_t( passedt )
                  append_beer_garden_t( passedt )
	       end
	    end
         end
      else -- food don't know
         if ( passedt.noncarpeted == "yes"  ) then
            if ( passedt.microbrewery == "yes"  ) then
                                              -- micropub unchecked (no examples yet)
               if (( passedt.accommodation ~= nil  ) and
                   ( passedt.accommodation ~= ""   ) and
                   ( passedt.accommodation ~= "no" )) then
                  passedt.amenity = "pub_yddyydy"
                                              -- no wheelchair appended (no examples yet)
                                              -- no beer garden appended (no examples yet)
	       else
                  passedt.amenity = "pub_yddyydn"
                  append_beer_garden_t( passedt )
	       end
	    else
	       if ( passedt.pub == "micropub" ) then
                  passedt.amenity = "pub_yddynyd"
                                              -- no wheelchair appended (no examples yet)
                                              -- no beer garden appended (no examples yet)
	       else
                  passedt.amenity = "pub_yddynnd"
                  append_wheelchair_t( passedt )
                  append_beer_garden_t( passedt )
	       end
	    end
	 else
            if ( passedt.microbrewery == "yes"  ) then
               if (( passedt.accommodation ~= nil  ) and
                   ( passedt.accommodation ~= ""   ) and
                   ( passedt.accommodation ~= "no" )) then
                  passedt.amenity = "pub_ydddydy"
                                              -- no wheelchair appended (no examples yet)
                                              -- no beer garden appended (no examples yet)
               else
                  passedt.amenity = "pub_ydddydn"
                  append_wheelchair_t( passedt )
                  append_beer_garden_t( passedt )
               end
            else
	       if ( passedt.pub == "micropub" ) then
                  passedt.amenity = "pub_ydddnyd"
                  append_wheelchair_t( passedt )
                                            -- no beer garden appended (no examples yet)
               else
                  passedt.amenity = "pub_ydddnn"
                  append_accommodation_t( passedt )
                  append_wheelchair_t( passedt )
                  append_beer_garden_t( passedt )
               end
	    end
         end
      end
   end

-- ----------------------------------------------------------------------------
-- Restaurants with accommodation
-- ----------------------------------------------------------------------------
   if (( passedt.amenity       == "restaurant" )  and
       ( passedt.accommodation == "yes"        )) then
      passedt.amenity = "restaccomm"
   end

-- ----------------------------------------------------------------------------
-- "cafe" - consolidation of lesser used tags
-- ----------------------------------------------------------------------------
   if ( passedt.shop == "cafe"       ) then
      passedt.amenity = "cafe"
   end

   if (( passedt.shop == "sandwiches" ) or
       ( passedt.shop == "sandwich"   )) then
      passedt.amenity = "cafe"
      passedt.cuisine = "sandwich"
   end

-- ----------------------------------------------------------------------------
-- Cafes with accommodation, without, and with wheelchair tags or without
-- ----------------------------------------------------------------------------
   if ( passedt.amenity == "cafe" ) then
      if ( passedt.accommodation == "yes" ) then
         if ( passedt.wheelchair == "yes" ) then
            if ( passedt.outdoor_seating == "yes" ) then
               passedt.amenity = "cafe_yyy"
            else
               passedt.amenity = "cafe_yyd"
            end
         else
            if ( passedt.wheelchair == "limited" ) then
               if ( passedt.outdoor_seating == "yes" ) then
                  passedt.amenity = "cafe_yly"
               else
                  passedt.amenity = "cafe_yld"
               end
	    else
	       if ( passedt.wheelchair == "no" ) then
                  if ( passedt.outdoor_seating == "yes" ) then
                     passedt.amenity = "cafe_yny"
                  else
                     passedt.amenity = "cafe_ynd"
                  end
	       else
                  if ( passedt.outdoor_seating == "yes" ) then
                     passedt.amenity = "cafe_ydy"
                  else
                     passedt.amenity = "cafe_ydd"
                  end
	       end
	    end
         end
      else
         if ( passedt.wheelchair == "yes" ) then
            if ( passedt.outdoor_seating == "yes" ) then
               passedt.amenity = "cafe_dyy"
            else
               passedt.amenity = "cafe_dyd"
            end
         else
            if ( passedt.wheelchair == "limited" ) then
               if ( passedt.outdoor_seating == "yes" ) then
                  passedt.amenity = "cafe_dly"
               else
                  passedt.amenity = "cafe_dld"
               end
	    else
	       if ( passedt.wheelchair == "no" ) then
                  if ( passedt.outdoor_seating == "yes" ) then
                     passedt.amenity = "cafe_dny"
                  else
                     passedt.amenity = "cafe_dnd"
                  end
               else
                  if ( passedt.outdoor_seating == "yes" ) then
                     passedt.amenity = "cafe_ddy"
                  else
                     passedt.amenity = "cafe_ddd"
                  end
	       end
	    end
         end
      end
   end

-- ----------------------------------------------------------------------------
-- Bars with accommodation, without, and with wheelchair tags or without
-- ----------------------------------------------------------------------------
   if ( passedt.amenity == "bar" ) then
      if ( passedt.accommodation == "yes" ) then
         if ( passedt.wheelchair == "yes" ) then
            if ( passedt.outdoor_seating == "yes" ) then
               passedt.amenity = "bar_yyy"
            else
               passedt.amenity = "bar_yyd"
            end
         else
            if ( passedt.wheelchair == "limited" ) then
               if ( passedt.outdoor_seating == "yes" ) then
                  passedt.amenity = "bar_yly"
               else
                  passedt.amenity = "bar_yld"
               end
	    else
	       if ( passedt.wheelchair == "no" ) then
                  if ( passedt.outdoor_seating == "yes" ) then
                     passedt.amenity = "bar_yny"
                  else
                     passedt.amenity = "bar_ynd"
                  end
	       else
                  if ( passedt.outdoor_seating == "yes" ) then
                     passedt.amenity = "bar_ydy"
                  else
                     passedt.amenity = "bar_ydd"
                  end
	       end
	    end
         end
      else
         if ( passedt.wheelchair == "yes" ) then
            if ( passedt.outdoor_seating == "yes" ) then
               passedt.amenity = "bar_dyy"
            else
               passedt.amenity = "bar_dyd"
            end
         else
            if ( passedt.wheelchair == "limited" ) then
               if ( passedt.outdoor_seating == "yes" ) then
                  passedt.amenity = "bar_dly"
               else
                  passedt.amenity = "bar_dld"
               end
	    else
	       if ( passedt.wheelchair == "no" ) then
                  if ( passedt.outdoor_seating == "yes" ) then
                     passedt.amenity = "bar_dny"
                  else
                     passedt.amenity = "bar_dnd"
                  end
               else
                  if ( passedt.outdoor_seating == "yes" ) then
                     passedt.amenity = "bar_ddy"
                  else
                     passedt.amenity = "bar_ddd"
                  end
	       end
	    end
         end
      end
   end

-- ----------------------------------------------------------------------------
-- Render building societies as banks.  Also shop=bank and credit unions.
-- ----------------------------------------------------------------------------
   if (( passedt.amenity == "building_society" ) or
       ( passedt.shop    == "bank"             ) or
       ( passedt.amenity == "credit_union"     )) then
      passedt.amenity = "bank"
   end

-- ----------------------------------------------------------------------------
-- Banks with wheelchair tags or without
-- ----------------------------------------------------------------------------
   if ( passedt.amenity == "bank" ) then
      if ( passedt.wheelchair == "yes" ) then
         passedt.amenity = "bank_y"
      else
         if ( passedt.wheelchair == "limited" ) then
            passedt.amenity = "bank_l"
         else
            if ( passedt.wheelchair == "no" ) then
               passedt.amenity = "bank_n"
            end
          end
      end
   end

-- ----------------------------------------------------------------------------
-- Various mistagging, comma and semicolon healthcare
-- Note that health centres currently appear as "health nonspecific".
-- ----------------------------------------------------------------------------
   if ((   passedt.amenity    == "doctors; pharmacy"       ) or
       (   passedt.amenity    == "surgery"                 ) or
       ((( passedt.healthcare == "doctor"                )   or
         ( passedt.healthcare == "doctor;pharmacy"       )   or
         ( passedt.healthcare == "general_practitioner"  ))  and
        (( passedt.amenity    == nil                     )   or
         ( passedt.amenity    == ""                      )))) then
      passedt.amenity = "doctors"
   end

   if (((   passedt.healthcare            == "dentist"    )  or
        ((  passedt["healthcare:speciality"] == "dentistry" )   and
         (( passedt.healthcare            == "yes"      )    or
          ( passedt.healthcare            == "centre"   )    or
          ( passedt.healthcare            == "clinic"   )))) and
       ((  passedt.amenity    == nil                      )  or
        (  passedt.amenity    == ""                       ))) then
      passedt.amenity = "dentist"
      passedt.healthcare = nil
   end

   if ((  passedt.healthcare == "hospital"  ) and
       (( passedt.amenity    == nil        )  or
        ( passedt.amenity    == ""         ))) then
      passedt.amenity = "hospital"
   end

-- ----------------------------------------------------------------------------
-- Ensure that vaccination centries (e.g. for COVID 19) that aren't already
-- something else get shown as something.
-- Things that _are_ something else get (e.g. community centres) get left as
-- that something else.
-- ----------------------------------------------------------------------------
   if ((( passedt.healthcare               == "vaccination_centre" )  or
        ( passedt.healthcare               == "sample_collection"  )  or
        ( passedt["healthcare:speciality"] == "vaccination"        )) and
       (( passedt.amenity                  == nil                  )  or
        ( passedt.amenity                  == ""                   )) and
       (( passedt.leisure                  == nil                  )  or
        ( passedt.leisure                  == ""                   )) and
       (( passedt.shop                     == nil                  )  or
        ( passedt.shop                     == ""                   ))) then
      passedt.amenity = "clinic"
   end

-- ----------------------------------------------------------------------------
-- If something is mapped both as a supermarket and a pharmacy, suppress the
-- tags for the latter.
-- ----------------------------------------------------------------------------
   if (( passedt.shop    == "supermarket" ) and
       ( passedt.amenity == "pharmacy"    )) then
      passedt.amenity = nil
   end

   if (((( passedt.healthcare == "pharmacy"                  )   or
         ( passedt.shop       == "pharmacy"                  ))  and
        (( passedt.amenity    == nil                         )   or
         ( passedt.amenity    == ""                          ))) or
       ((  passedt.shop       == "cosmetics"                  )  and
        (  passedt.pharmacy   == "yes"                        )  and
        (( passedt.amenity    == nil                         )   or
         ( passedt.amenity    == ""                          ))) or
       ((  passedt.shop       == "chemist"                    )  and
        (  passedt.pharmacy   == "yes"                        )  and
        (( passedt.amenity    == nil                         )   or
         ( passedt.amenity    == ""                          ))) or
       ((  passedt.amenity    == "clinic"                     )  and
        (  passedt.pharmacy   == "yes"                        ))) then
      passedt.amenity = "pharmacy"
   end

-- ----------------------------------------------------------------------------
-- Pharmacies with wheelchair tags or without
-- ----------------------------------------------------------------------------
   if ( passedt.amenity == "pharmacy" ) then
      if ( passedt.wheelchair == "yes" ) then
         passedt.amenity = "pharmacy_y"
      else
         if ( passedt.wheelchair == "limited" ) then
            passedt.amenity = "pharmacy_l"
         else
            if ( passedt.wheelchair == "no" ) then
               passedt.amenity = "pharmacy_n"
            end
          end
      end
   end

-- ----------------------------------------------------------------------------
-- Left luggage
-- ----------------------------------------------------------------------------
   if ( passedt.amenity == "luggage_locker"  ) then
      passedt.amenity = "left_luggage"
      passedt.shop    = nil
   end

-- ----------------------------------------------------------------------------
-- Show photo booths as vending machines
-- ----------------------------------------------------------------------------
   if ( passedt.amenity == "photo_booth" )  then
      passedt.amenity = "vending_machine"
      passedt.vending = "photos"
   end

-- ----------------------------------------------------------------------------
-- Parcel lockers
-- ----------------------------------------------------------------------------
   if (((  passedt.amenity         == "vending_machine"                )  and
        (( passedt.vending         == "parcel_pickup;parcel_mail_in"  )   or
         ( passedt.vending         == "parcel_mail_in;parcel_pickup"  )   or
         ( passedt.vending         == "parcel_mail_in"                )   or
         ( passedt.vending         == "parcel_pickup"                 )   or
         ( passedt.vending_machine == "parcel_pickup"                 )))  or
       (   passedt.amenity         == "parcel_box"                      )  or
       (   passedt.amenity         == "parcel_pickup"                   )) then
      passedt.amenity  = "parcel_locker"
   end

-- ----------------------------------------------------------------------------
-- Excrement bags
-- ----------------------------------------------------------------------------
   if (( passedt.amenity == "vending_machine" ) and
       ( passedt.vending == "excrement_bags"  )) then
      passedt.amenity  = "vending_excrement"
   end

-- ----------------------------------------------------------------------------
-- Reverse vending machines
-- Other vending machines have their own icon
-- ----------------------------------------------------------------------------
   if (( passedt.amenity == "vending_machine" ) and
       ( passedt.vending == "bottle_return"   )) then
      passedt.amenity  = "bottle_return"
   end

-- ----------------------------------------------------------------------------
-- If a farm shop doesn't have a name but does have named produce, map across
-- to vending machine, and also the produce into "vending" for consideration 
-- below.
-- ----------------------------------------------------------------------------
   if ((  passedt.shop                == "farm"   )  and
       (( passedt.name                == nil     )   or
        ( passedt.name                == ""      ))  and
       ((( passedt.produce             ~= nil    )   and
         ( passedt.produce             ~= ""     ))  or
        (  passedt["payment:honesty_box"] == "yes"   ))) then
      passedt.amenity = "vending_machine"

      if (( passedt.produce == nil ) or
          ( passedt.produce == ""  )) then
         if ( passedt["food:eggs"] == "yes" )  then
            passedt.produce = "eggs"
         else
            passedt.produce = "farm shop honesty box"
         end
      end

      passedt.vending = passedt.produce
      passedt.shop    = nil
   end

   if ((  passedt.shop == "eggs"  )  and
       (( passedt.name == nil    )   or
        ( passedt.name == ""     ))) then
      passedt.amenity = "vending_machine"
      passedt.vending = passedt.shop
      passedt.shop    = nil
   end

-- ----------------------------------------------------------------------------
-- Some vending machines get the thing sold as the label.
-- "farm shop honesty box" might have been assigned higher up.
-- ----------------------------------------------------------------------------
   if ((  passedt.amenity == "vending_machine"        ) and
       (( passedt.name    == nil                     )  or
        ( passedt.name    == ""                      )) and
       (( passedt.vending == "milk"                  )  or
        ( passedt.vending == "eggs"                  )  or
        ( passedt.vending == "potatoes"              )  or
        ( passedt.vending == "honey"                 )  or
        ( passedt.vending == "cheese"                )  or
        ( passedt.vending == "vegetables"            )  or
        ( passedt.vending == "fruit"                 )  or
        ( passedt.vending == "food"                  )  or
        ( passedt.vending == "photos"                )  or
        ( passedt.vending == "maps"                  )  or
        ( passedt.vending == "newspapers"            )  or
        ( passedt.vending == "farm shop honesty box" ))) then
      passedt.name = "(" .. passedt.vending .. ")"
   end

-- ----------------------------------------------------------------------------
-- Render amenity=piano as musical_instrument
-- ----------------------------------------------------------------------------
   if ( passedt.amenity == "piano" ) then
      passedt.amenity = "musical_instrument"

      if ( passedt.name == nil ) then
            passedt.name = "Piano"
      end
   end

-- ----------------------------------------------------------------------------
-- Motorcycle parking - if "motorcycle" has been used as a subtag,
-- set main tag.  Rendering (with fee or not) is handled below.
-- ----------------------------------------------------------------------------
   if (( passedt.amenity == "parking"    )  and
       ( passedt.parking == "motorcycle" )) then
      passedt.amenity = "motorcycle_parking"
   end

-- ----------------------------------------------------------------------------
-- Render amenity=layby as parking.
-- highway=rest_area is used a lot in the UK for laybies, so map that over too.
-- ----------------------------------------------------------------------------
   if (( passedt.amenity == "layby"     ) or
       ( passedt.highway == "rest_area" )) then
      passedt.amenity = "parking"
   end

-- ----------------------------------------------------------------------------
-- Scooter rental
-- All legal scooter rental / scooter parking in UK are private; these are the
-- the tags currently used.
-- "network" is a bit of a special case because normally it means "lwn" etc.
-- ----------------------------------------------------------------------------
   if ((   passedt.amenity                == "escooter_rental"         ) or
       (   passedt.amenity                == "scooter_parking"         ) or
       (   passedt.amenity                == "kick-scooter_rental"     ) or
       (   passedt.amenity                == "small_electric_vehicle"  ) or
       ((  passedt.amenity                == "parking"                )  and
        (( passedt.parking                == "e-scooter"             )   or
         ( passedt.small_electric_vehicle == "designated"            ))) or
       ((  passedt.amenity                == "bicycle_parking"        )  and
        (  passedt.small_electric_vehicle == "designated"             ))) then
      passedt.amenity = "scooter_rental"
      passedt.access = nil

      if ((( passedt.name     == nil )  or
           ( passedt.name     == ""  )) and
          (( passedt.operator == nil )  or
           ( passedt.operator == ""  )) and
          (  passedt.network  ~= nil  ) and
          (  passedt.network  ~= ""   )) then
         passedt.name = passedt.network
         passedt.network = nil
      end
   end

-- ----------------------------------------------------------------------------
-- Render for-pay parking areas differently.
-- ----------------------------------------------------------------------------
   if ((  passedt.amenity == "parking"  ) and
       (( passedt.fee     ~= nil       )  and
        ( passedt.fee     ~= ""        )  and
        ( passedt.fee     ~= "no"      )  and
        ( passedt.fee     ~= "0"       ))) then
      passedt.amenity = "parking_pay"
   end

-- ----------------------------------------------------------------------------
-- Render for-pay bicycle_parking areas differently.
-- ----------------------------------------------------------------------------
   if ((  passedt.amenity == "bicycle_parking"  ) and
       (( passedt.fee     ~= nil               )  and
        ( passedt.fee     ~= ""                )  and
        ( passedt.fee     ~= "no"              )  and
        ( passedt.fee     ~= "0"               ))) then
      passedt.amenity = "bicycle_parking_pay"
   end

-- ----------------------------------------------------------------------------
-- Render for-pay motorcycle_parking areas differently.
-- ----------------------------------------------------------------------------
   if ((  passedt.amenity == "motorcycle_parking"  ) and
       (( passedt.fee     ~= nil               )  and
        ( passedt.fee     ~= ""                )  and
        ( passedt.fee     ~= "no"              )  and
        ( passedt.fee     ~= "0"               ))) then
      passedt.amenity = "motorcycle_parking_pay"
   end

-- ----------------------------------------------------------------------------
-- Render for-pay toilets differently.
-- Also use different icons for male and female, if these are separate.
-- ----------------------------------------------------------------------------
   if ( passedt.amenity == "toilets" ) then
      if (( passedt.fee     ~= nil       )  and
          ( passedt.fee     ~= ""        )  and
          ( passedt.fee     ~= "no"      )  and
          ( passedt.fee     ~= "0"       )) then
         if (( passedt.male   == "yes" ) and
             ( passedt.female ~= "yes" )) then
            passedt.amenity = "toilets_pay_m"
         else
            if (( passedt.female == "yes"       ) and
                ( passedt.male   ~= "yes"       )) then
               passedt.amenity = "toilets_pay_w"
            else
               passedt.amenity = "toilets_pay"
            end
         end
      else
         if (( passedt.male   == "yes" ) and
             ( passedt.female ~= "yes" )) then
            passedt.amenity = "toilets_free_m"
         else
            if (( passedt.female == "yes"       ) and
                ( passedt.male   ~= "yes"       )) then
               passedt.amenity = "toilets_free_w"
            end
         end
      end
   end

-- ----------------------------------------------------------------------------
-- Render for-pay shower differently.
-- Also use different icons for male and female, if these are separate.
-- ----------------------------------------------------------------------------
   if ( passedt.amenity == "shower" ) then
      if (( passedt.fee     ~= nil       )  and
          ( passedt.fee     ~= ""        )  and
          ( passedt.fee     ~= "no"      )  and
          ( passedt.fee     ~= "0"       )) then
         if (( passedt.male   == "yes" ) and
             ( passedt.female ~= "yes" )) then
            passedt.amenity = "shower_pay_m"
         else
            if (( passedt.female == "yes"       ) and
                ( passedt.male   ~= "yes"       )) then
               passedt.amenity = "shower_pay_w"
            else
               passedt.amenity = "shower_pay"
            end
         end
      else
         if (( passedt.male   == "yes" ) and
             ( passedt.female ~= "yes" )) then
            passedt.amenity = "shower_free_m"
         else
            if (( passedt.female == "yes"       ) and
                ( passedt.male   ~= "yes"       )) then
               passedt.amenity = "shower_free_w"
            end
         end
      end
   end

-- ----------------------------------------------------------------------------
-- Render parking spaces as parking.  Most in the UK are not part of larger
-- parking areas, and most do not have an access tag, but many should have.
--
-- This does not work where e.g. Supermarket car parks have been mapped:
-- https://github.com/SomeoneElseOSM/SomeoneElse-style/issues/14
--
-- Also map emergency bays (used in place of hard shoulders) in the same way.
-- Although we treat parking spaces as "types of parking", we ensure that
-- "parking_space" is always set to something so that raster- or
-- vector-specific rendering code can adjust it further.(raster will want to
-- set it "no").
-- ----------------------------------------------------------------------------
   if (( passedt.amenity == "parking_space" ) or
       ( passedt.highway == "emergency_bay" )) then
       if (( passedt.fee     ~= nil       )  and
           ( passedt.fee     ~= ""        )  and
           ( passedt.fee     ~= "no"      )  and
           ( passedt.fee     ~= "0"       )) then
         if ( passedt.parking_space == "disabled" ) then
            passedt.amenity = "parking_paydisabled"
         else
            passedt.amenity = "parking_pay"
            passedt.parking_space = "parking_pay"
         end
      else
         if ( passedt.parking_space == "disabled" ) then
            passedt.amenity = "parking_freedisabled"
         else
            passedt.amenity = "parking"
            passedt.parking_space = "parking"
         end
      end
   end

-- ----------------------------------------------------------------------------
-- The code below here doesn't look at "access" directly although:
--
-- * The raster rendering cartocss code still uses "access" and has set that
--   based on "foot" above.
-- * The "access" value is written through to the vector tiles for certain
--   objects (for example, parking areas) so that the vector rendering code
--   can show them differently.
--
-- For the second of those reasons, tidy up "access" values on the following objects:
-- * bicycle_rental
-- * scooter_rental
-- * bicycle_parking and bicycle_parking_pay
-- * motorcycle_parking and motorcycle_parking_pay
-- 
-- that are not one of "no" or "yes" as follows:
-- * yes, permissive, public, foot, fee, boat -> yes
-- * everything else -> no
-- 
-- We don't worry about "designation" here because we've removed that above.
-- "official" is a bit odd; "access=official" on parking seems to usually mean 
-- "no".
-- Some of the less-used access values such as "construction" are a bit 
-- random, so fail safe to "no".
-- ----------------------------------------------------------------------------
    if (( passedt.amenity == "parking"                    ) or
        ( passedt.amenity == "parking_pay"                ) or
        ( passedt.amenity == "parking_freedisabled"       ) or
        ( passedt.amenity == "parking_paydisabled"        ) or
        ( passedt.amenity == "bicycle_rental"             ) or
        ( passedt.amenity == "scooter_rental"             ) or
        ( passedt.amenity == "bicycle_parking"            ) or
        ( passedt.amenity == "bicycle_parking_pay"        ) or
        ( passedt.amenity == "motorcycle_parking"         ) or
        ( passedt.amenity == "motorcycle_parking_pay"     )) then
        if (( passedt.access == nil          ) or
            ( passedt.access == ""           ) or
            ( passedt.access == "yes"        ) or
            ( passedt.access == "permissive" ) or
            ( passedt.access == "public"     ) or
            ( passedt.access == "foot"       ) or
            ( passedt.access == "fee"        ) or
            ( passedt.access == "boat"       )) then
            passedt.access = "yes"
        else
            passedt.access = "no"
        end
    end

-- ----------------------------------------------------------------------------
-- Render amenity=leisure_centre and leisure=leisure_centre 
-- as leisure=sports_centre
-- ----------------------------------------------------------------------------
   if (( passedt.amenity == "leisure_centre" ) or
       ( passedt.leisure == "leisure_centre" )) then
      passedt.leisure = "sports_centre"
   end

-- ----------------------------------------------------------------------------
-- Sand dunes
-- ----------------------------------------------------------------------------
   if (( passedt.natural == "dune"       ) or
       ( passedt.natural == "dunes"      ) or
       ( passedt.natural == "sand_dunes" )) then
      passedt.natural = "sand"
   end

-- ----------------------------------------------------------------------------
-- Render tidal sand with more blue
-- ----------------------------------------------------------------------------
   if ((  passedt.natural   == "sand"       ) and
       (( passedt.tidal     == "yes"       )  or
        ( passedt.wetland   == "tidalflat" ))) then
      passedt.natural = "tidal_sand"
   end

-- ----------------------------------------------------------------------------
-- Golf (and sandpits)
-- ----------------------------------------------------------------------------
   if ((( passedt.golf       == "bunker"  )  or
        ( passedt.playground == "sandpit" )) and
       (( passedt.natural     == nil      )  or
        ( passedt.natural     == ""       ))) then
      passedt.natural = "sand"
   end

   if ( passedt.golf == "tee" ) then
      passedt.leisure = "garden"

      if (( passedt.name == nil ) or
          ( passedt.name == ""  )) then
         passedt.name = passedt.ref
      end
   end

   if ( passedt.golf == "green" ) then
      passedt.leisure = "golfgreen"

      if (( passedt.name == nil ) or
          ( passedt.name == ""  )) then
         passedt.name = passedt.ref
      end
   end

   if ( passedt.golf == "fairway" ) then
      passedt.leisure = "garden"

      if (( passedt.name == nil ) or
          ( passedt.name == ""  )) then
         passedt.name = passedt.ref
      end
   end

   if ( passedt.golf == "pin" ) then
      passedt.leisure = "leisurenonspecific"

      if (( passedt.name == nil ) or
          ( passedt.name == ""  )) then
         passedt.name = passedt.ref
      end
   end

   if ((  passedt.golf    == "rough" ) and
       (( passedt.natural == nil    )  or
        ( passedt.natural == ""     ))) then
      passedt.natural = "scrub"
   end

   if ((  passedt.golf    == "driving_range"  ) and
       (( passedt.leisure == nil             )  or
        ( passedt.leisure == ""              ))) then
      passedt.leisure = "pitch"
   end

   if ((  passedt.golf    == "path"  ) and
       (( passedt.highway == nil    )  or
        ( passedt.highway == ""     ))) then
      passedt.highway = "pathnarrow"
   end

   if ((  passedt.golf    == "practice"  ) and
       (( passedt.leisure == nil        )  or
        ( passedt.leisure == ""         ))) then
      passedt.leisure = "garden"
   end

-- ----------------------------------------------------------------------------
-- Playground stuff
--
-- The "leisure=nil" check here is because there are some unusual combinations
-- of "playground" tags on otherwise-rendered "leisure" things.
--
-- "landuse=playground" is a rare synonym of "leisure=playground".
-- "leisure=playground".is handled in the rendering code.
-- ----------------------------------------------------------------------------
   if ((  passedt.landuse == "playground"  ) and
       (( passedt.leisure == nil          )  or
        ( passedt.leisure == ""           ))) then
      passedt.leisure = "playground"
   end

   if (((  passedt.leisure    == nil           )   or
        (  passedt.leisure    == ""            ))  and
       ((  passedt.playground == "swing"       )   or
        (  passedt.playground == "basketswing" ))) then
      passedt.amenity = "playground_swing"
   end

   if ((( passedt.leisure    == nil         )   or
        ( passedt.leisure    == ""          ))  and
       (  passedt.playground == "structure"  )) then
      passedt.amenity = "playground_structure"
   end

   if ((( passedt.leisure    == nil             )   or
        ( passedt.leisure    == ""              ))  and
       (  passedt.playground == "climbingframe"  )) then
      passedt.amenity = "playground_climbingframe"
   end

   if ((( passedt.leisure    == nil     )   or
        ( passedt.leisure    == ""      ))  and
       (  passedt.playground == "slide"  )) then
      passedt.amenity = "playground_slide"
   end

   if ((( passedt.leisure    == nil       )   or
        ( passedt.leisure    == ""        ))  and
       (  passedt.playground == "springy"  )) then
      passedt.amenity = "playground_springy"
   end

   if ((( passedt.leisure    == nil       )   or
        ( passedt.leisure    == ""        ))  and
       (  passedt.playground == "zipwire"  )) then
      passedt.amenity = "playground_zipwire"
   end

   if ((( passedt.leisure    == nil      )   or
        ( passedt.leisure    == ""       ))  and
       (  passedt.playground == "seesaw"  )) then
      passedt.amenity = "playground_seesaw"
   end

   if ((( passedt.leisure    == nil          )   or
        ( passedt.leisure    == ""           ))  and
       (  passedt.playground == "roundabout"  )) then
      passedt.amenity = "playground_roundabout"
   end

-- ----------------------------------------------------------------------------
-- Various leisure=pitch icons
-- Note that these are also listed at the end in 
-- "Shops etc. with icons already".
-- ----------------------------------------------------------------------------
   if (( passedt.leisure == "pitch"        )  and
       ( passedt.sport   == "table_tennis" )) then
      passedt.amenity = "pitch_tabletennis"
      passedt.leisure = "unnamedpitch"
   end

   if ((  passedt.leisure == "pitch"                      )  and
       (( passedt.sport   == "association_football"      )   or
        ( passedt.sport   == "football"                  )   or
        ( passedt.sport   == "multi;soccer;basketball"   )   or
        ( passedt.sport   == "football;basketball"       )   or
        ( passedt.sport   == "football;rugby"            )   or
        ( passedt.sport   == "football;soccer"           )   or
        ( passedt.sport   == "soccer"                    )   or
        ( passedt.sport   == "soccer;archery"            )   or
        ( passedt.sport   == "soccer;athletics"          )   or
        ( passedt.sport   == "soccer;basketball"         )   or
        ( passedt.sport   == "soccer;cricket"            )   or
        ( passedt.sport   == "soccer;field_hockey"       )   or
        ( passedt.sport   == "soccer;football"           )   or
        ( passedt.sport   == "soccer;gaelic_games"       )   or
        ( passedt.sport   == "soccer;gaelic_games;rugby" )   or
        ( passedt.sport   == "soccer;hockey"             )   or
        ( passedt.sport   == "soccer;multi"              )   or
        ( passedt.sport   == "soccer;rugby"              )   or
        ( passedt.sport   == "soccer;rugby_union"        )   or
        ( passedt.sport   == "soccer;tennis"             ))) then
      passedt.amenity = "pitch_soccer"
      passedt.leisure = "unnamedpitch"
   end

   if (( passedt.leisure == "pitch"                    )  and
       (( passedt.sport  == "basketball"              )   or
        ( passedt.sport  == "basketball;soccer"       )   or
        ( passedt.sport  == "basketball;football"     )   or
        ( passedt.sport  == "basketball;multi"        )   or
        ( passedt.sport  == "basketball;netball"      )   or
        ( passedt.sport  == "basketball;tennis"       )   or
        ( passedt.sport  == "multi;basketball"        )   or
        ( passedt.sport  == "multi;basketball;soccer" ))) then
      passedt.amenity = "pitch_basketball"
      passedt.leisure = "unnamedpitch"
   end

   if ((  passedt.leisure == "pitch"                )  and
       (( passedt.sport   == "cricket"             )   or
        ( passedt.sport   == "cricket_rugby_union" )   or
        ( passedt.sport   == "cricket;soccer"      )   or
        ( passedt.sport   == "cricket_nets"        )   or
        ( passedt.sport   == "cricket_nets;multi"  ))) then
      passedt.amenity = "pitch_cricket"
      passedt.leisure = "unnamedpitch"
   end

   if (( passedt.leisure == "pitch"           )  and
       (( passedt.sport  == "skateboard"     )   or
        ( passedt.sport  == "skateboard;bmx" ))) then
      passedt.amenity = "pitch_skateboard"
      passedt.leisure = "unnamedpitch"
   end

   if ((  passedt.leisure == "pitch"                )  and
       (( passedt.sport   == "climbing"            )   or
        ( passedt.sport   == "climbing;bouldering" ))) then
      passedt.amenity = "pitch_climbing"
      passedt.leisure = "unnamedpitch"
   end

   if ((  passedt.leisure == "pitch"                )  and
       (( passedt.sport   == "rugby"               )   or
        ( passedt.sport   == "rugby;cricket"       )   or
        ( passedt.sport   == "rugby;football"      )   or
        ( passedt.sport   == "rugby;rubgy_union"   )   or
        ( passedt.sport   == "rugby;soccer"        )   or
        ( passedt.sport   == "rugby_league"        )   or
        ( passedt.sport   == "rugby_union"         )   or
        ( passedt.sport   == "rugby_union;cricket" )   or
        ( passedt.sport   == "rugby_union;soccer"  ))) then
      passedt.amenity = "pitch_rugby"
      passedt.leisure = "unnamedpitch"
   end

   if (( passedt.leisure == "pitch" )  and
       ( passedt.sport   == "chess" )) then
      passedt.amenity = "pitch_chess"
      passedt.leisure = "unnamedpitch"
   end

   if ((  passedt.leisure == "pitch"              )  and
       (( passedt.sport   == "tennis"            )   or
        ( passedt.sport   == "tennis;basketball" )   or
        ( passedt.sport   == "tennis;bowls"      )   or
        ( passedt.sport   == "tennis;hockey"     )   or
        ( passedt.sport   == "tennis;multi"      )   or
        ( passedt.sport   == "tennis;netball"    )   or
        ( passedt.sport   == "tennis;soccer"     )   or
        ( passedt.sport   == "tennis;squash"     ))) then
      passedt.amenity = "pitch_tennis"
      passedt.leisure = "unnamedpitch"
   end

   if ((  passedt.leisure == "pitch"             )  and
       (( passedt.sport   == "athletics"        )   or
        ( passedt.sport   == "athletics;soccer" )   or
        ( passedt.sport   == "long_jump"        )   or
        ( passedt.sport   == "running"          )   or
        ( passedt.sport   == "shot-put"         ))) then
      passedt.amenity = "pitch_athletics"
      passedt.leisure = "unnamedpitch"
   end

   if (( passedt.leisure == "pitch" )  and
       ( passedt.sport   == "boules" )) then
      passedt.amenity = "pitch_boules"
      passedt.leisure = "unnamedpitch"
   end

   if ((  passedt.leisure == "pitch"         )  and
       (( passedt.sport   == "bowls"        )   or
        ( passedt.sport   == "bowls;tennis" ))) then
      passedt.amenity = "pitch_bowls"
      passedt.leisure = "unnamedpitch"
   end

   if (( passedt.leisure == "pitch" )  and
       ( passedt.sport   == "croquet" )) then
      passedt.amenity = "pitch_croquet"
      passedt.leisure = "unnamedpitch"
   end

   if ((  passedt.leisure == "pitch"         )  and
       (( passedt.sport   == "cycling"      )   or
        ( passedt.sport   == "bmx"          )   or
        ( passedt.sport   == "cycling;bmx"  )   or
        ( passedt.sport   == "bmx;mtb"      )   or
        ( passedt.sport   == "bmx;cycling"  )   or
        ( passedt.sport   == "mtb"          ))) then
      passedt.amenity = "pitch_cycling"
      passedt.leisure = "unnamedpitch"
   end

   if (( passedt.leisure == "pitch" )  and
       ( passedt.sport   == "equestrian" )) then
      passedt.amenity = "pitch_equestrian"
      passedt.leisure = "unnamedpitch"
   end

   if ((  passedt.leisure == "pitch"                  )  and
       (( passedt.sport   == "gaelic_games"          )   or
        ( passedt.sport   == "gaelic_games;handball" )   or
        ( passedt.sport   == "gaelic_games;soccer"   )   or
        ( passedt.sport   == "shinty"                ))) then
      passedt.amenity = "pitch_gaa"
      passedt.leisure = "unnamedpitch"
   end

   if ((  passedt.leisure == "pitch"                  )  and
       (( passedt.sport   == "field_hockey"          )   or
        ( passedt.sport   == "field_hockey;soccer"   )   or
        ( passedt.sport   == "hockey"                )   or
        ( passedt.sport   == "hockey;soccer"         ))) then
      passedt.amenity = "pitch_hockey"
      passedt.leisure = "unnamedpitch"
   end

   if (( passedt.leisure == "pitch" )  and
       ( passedt.sport   == "multi" )) then
      passedt.amenity = "pitch_multi"
      passedt.leisure = "unnamedpitch"
   end

   if (( passedt.leisure == "pitch" )  and
       ( passedt.sport   == "netball" )) then
      passedt.amenity = "pitch_netball"
      passedt.leisure = "unnamedpitch"
   end

   if (( passedt.leisure == "pitch" )  and
       ( passedt.sport   == "polo" )) then
      passedt.amenity = "pitch_polo"
      passedt.leisure = "unnamedpitch"
   end

   if ((  passedt.leisure == "pitch"           )  and
       (( passedt.sport   == "shooting"       ) or
        ( passedt.sport   == "shooting_range" ))) then
      passedt.amenity = "pitch_shooting"
      passedt.leisure = "unnamedpitch"
   end

   if ((  passedt.leisure == "pitch"                                             )  and
       (( passedt.sport   == "baseball"                                         ) or
        ( passedt.sport   == "baseball;soccer"                                  ) or
        ( passedt.sport   == "baseball;softball"                                ) or
        ( passedt.sport   == "baseball;cricket"                                 ) or
        ( passedt.sport   == "multi;baseball"                                   ) or
        ( passedt.sport   == "baseball;lacrosse;multi"                          ) or
        ( passedt.sport   == "baseball;american_football;ice_hockey;basketball" ))) then
      passedt.amenity = "pitch_baseball"
      passedt.leisure = "unnamedpitch"
   end

-- ----------------------------------------------------------------------------
-- Railway turntables.
-- We ignore these if they're also mapped as buildings.
-- We force "area=yes" on all to handle them as area features
-- On whatever's left, we add landuse=railway to allow name display, if not 
-- already set.
-- The latter two of those are for compatibility with raster; there is vector
-- handling at extract time to explicitly extract the correct features.
-- ----------------------------------------------------------------------------
   if ( passedt.railway == "turntable" ) then
      if (( passedt.building ~= nil  )  and
          ( passedt.building ~= ""   )  and
          ( passedt.building ~= "no" )) then
         passedt.railway = nil
      else
         passedt.area = "yes"

         if ( passedt.landuse == nil ) then
            passedt.landuse = "railway"
         end
      end
   end

-- ----------------------------------------------------------------------------
-- Handle razed railways and old inclined_planes as dismantled.
-- dismantled, abandoned are now handled separately to disused in roads.mss
-- ----------------------------------------------------------------------------
   if ((( passedt["railway:historic"] == "rail"           )  or
        ( passedt.historic         == "inclined_plane" )  or
        ( passedt.historic         == "tramway"        )) and
       (( passedt.building         == nil              )  or
        ( passedt.building         == ""               )) and
       (( passedt.highway          == nil              )  or
        ( passedt.highway          == ""               )) and
       (( passedt.railway          == nil              )  or
        ( passedt.railway          == ""               )) and
       (( passedt.waterway         == nil              )  or
        ( passedt.waterway         == ""               ))) then
      passedt.railway = "abandoned"
   end

   if ( passedt.railway == "razed" ) then
      passedt.railway = "dismantled"
   end

-- ----------------------------------------------------------------------------
-- Railway construction
-- This is done mostly to make the HS2 show up.
-- ----------------------------------------------------------------------------
   if ( passedt.railway   == "proposed" ) then
      passedt.railway = "construction"
   end

-- ----------------------------------------------------------------------------
-- The "OpenRailwayMap" crowd prefer the less popular railway:preserved=yes
-- instead of railway=preserved (which has the advantage of still allowing
-- e.g. narrow_gauge in addition to rail).
-- ----------------------------------------------------------------------------
   if ( passedt["railway:preserved"] == "yes" ) then
      passedt.railway = "preserved"
   end

-- ----------------------------------------------------------------------------
-- Show preserved railway tunnels as tunnels.
-- ----------------------------------------------------------------------------
   if (( passedt.railway == "preserved" ) and
       ( passedt.tunnel  == "yes"       )) then
      passedt.railway = "rail"
   end

   if ((( passedt.railway == "miniature"    ) or
        ( passedt.railway == "narrow_gauge" )) and
       (  passedt.tunnel  == "yes"           )) then
      passedt.railway = "light_rail"
   end

-- ----------------------------------------------------------------------------
-- Goods Conveyors - render as miniature railway.
-- Also "railway=crane" which are all linear structures.
--
-- Point, linear and polygon "man_made=crane" exist.  The point and polygon 
-- ones are handled with an icon (both raster and vector), 
-- and the polygon ones also get "roof" added above.
-- Linear "man_made=crane" are shown 
-- via the "railway=miniature" tag added here.
-- ----------------------------------------------------------------------------
   if (( passedt.man_made == "goods_conveyor" ) or
       ( passedt.man_made == "crane"          ) or
       ( passedt.railway  == "crane"          )) then
      passedt.railway = "miniature"
   end

-- ----------------------------------------------------------------------------
-- Other waterway access points
-- ----------------------------------------------------------------------------
   if (( passedt.waterway   == "access_point"  ) or
       ( passedt.whitewater == "put_in"        ) or
       ( passedt.whitewater == "put_in;egress" ) or
       ( passedt.whitewater == "put_in_out"    ) or
       ( passedt.canoe      == "put_in"        )) then
      passedt.amenity = "waterway_access_point"
      passedt.leisure = nil
      passedt.sport = nil
   end

-- ----------------------------------------------------------------------------
-- In this shared lua, we just consolidate any alternative values for
-- sluice_gate, waterfall, weir, floating_barrier.
--
-- On raster, these are further consolidated into a set of tags that will
-- display as a point, line or (multi)polygon.
--
-- On vector, we output something appropriate into either "land1" (points
-- and areas) or "waterway" (lines, which may be parallel or perpendicular
-- to the actual waterway).
-- ----------------------------------------------------------------------------
   if ((  passedt.waterway     == "sluice_gate"      ) or
       (  passedt.waterway     == "sluice"           ) or
       (( passedt.waterway     == "flow_control"    )  and
        ( passedt.flow_control == "sluice_gate"     ))) then
      passedt.waterway = "sluice_gate"
   end

   if ((  passedt.waterway     == "waterfall"        ) or
       (  passedt.natural      == "waterfall"        ) or
       (  passedt.water        == "waterfall"        )) then
      passedt.waterway = "waterfall"
   end

-- ----------------------------------------------------------------------------
-- Historic canal
-- A former canal can, like an abandoned railway, still be a major
-- physical feature.
--
-- Also treat historic=moat in the same way, unless it has an area=yes tag.
-- Most closed ways for historic=moat appear to be linear ways, not areas.
-- ----------------------------------------------------------------------------
   if ((   passedt.historic              == "canal"           ) or
       (   passedt["historic:waterway"]  == "canal"           ) or
       (   passedt.historic              == "leat"            ) or
       (   passedt["disused:waterway"]   == "canal"           ) or
       (   passedt.disused               == "canal"           ) or
       (   passedt["abandoned:waterway"] == "canal"           ) or
       (   passedt.waterway              == "disused_canal"   ) or
       (   passedt.waterway              == "historic_canal"  ) or
       (   passedt.waterway              == "abandoned_canal" ) or
       (   passedt.waterway              == "former_canal"    ) or
       (   passedt["waterway:historic"]  == "canal"           ) or
       (   passedt["waterway:abandoned"] == "canal"           ) or
       (   passedt.abandoned             == "waterway=canal"  ) or
       ((  passedt.historic              == "moat"           )  and
        (( passedt.natural               == nil             )   or
         ( passedt.natural               == ""              ))  and
        (( passedt.man_made              == nil             )   or
         ( passedt.man_made              == ""              ))  and
        (( passedt.waterway              == nil             )   or
         ( passedt.waterway              == ""              ))  and
        (  passedt.area                  ~= "yes"            ))) then
      passedt.waterway = "derelict_canal"
      passedt.historic = nil
      passedt.area     = "no"
   end

-- ----------------------------------------------------------------------------
-- Use historical names if present for historical canals.
-- ----------------------------------------------------------------------------
   if ((  passedt.waterway      == "derelict_canal"  ) and
       (( passedt.name          == nil              )  or
        ( passedt.name          == ""               )) and
       (  passedt["name:historic"] ~= nil               ) and
       (  passedt["name:historic"] ~= ""                )) then
      passedt.name = passedt["name:historic"]
   end

   if ((  passedt.waterway      == "derelict_canal"  ) and
       (( passedt.name          == nil              )  or
        ( passedt.name          == ""               )) and
       (  passedt["historic:name"] ~= nil               ) and
       (  passedt["historic:name"] ~= ""                )) then
      passedt.name = passedt["historic:name"]
   end
   
-- ----------------------------------------------------------------------------
-- Display "waterway=leat" and "waterway=spillway" etc. as drain.
-- "man_made=spillway" tends to be used on areas, hence show as "natural=water".
-- ----------------------------------------------------------------------------
   if ((   passedt.waterway == "leat"        )  or
       (   passedt.waterway == "spillway"    )  or
       (   passedt.waterway == "fish_pass"   )  or
       (   passedt.waterway == "rapids"      )  or
       ((  passedt.waterway == "canal"      )   and
        (( passedt.usage    == "headrace"  )    or
         ( passedt.usage    == "spillway"  )))) then
      passedt.waterway = "drain"
   end

   if ( passedt.man_made == "spillway" ) then
      passedt.natural = "water"
      passedt.man_made = nil
   end

-- ----------------------------------------------------------------------------
-- Any remaining extant canals will be linear features, even closed loops.
-- ----------------------------------------------------------------------------
   if ( passedt.waterway == "canal" ) then
      passedt.area     = "no"
   end

-- ----------------------------------------------------------------------------
-- Apparently there are a few "waterway=brook" in the UK.  Render as stream.
-- Likewise "tidal_channel" as stream and "drainage_channel" as ditch.
-- ----------------------------------------------------------------------------
   if (( passedt.waterway == "brook"         ) or
       ( passedt.waterway == "flowline"      ) or
       ( passedt.waterway == "tidal_channel" )) then
      passedt.waterway = "stream"
   end

   if ( passedt.waterway == "drainage_channel" ) then
      passedt.waterway = "ditch"
   end

-- ----------------------------------------------------------------------------
-- Handle "natural=pond" as water.
-- ----------------------------------------------------------------------------
   if (( passedt.natural  == "pond"       ) or
       ( passedt.waterway == "dock"       ) or
       ( passedt.waterway == "mill_pond"  )) then
      passedt.natural = "water"
      passedt.waterway = nil
   end

-- ----------------------------------------------------------------------------
-- Handle "waterway=mill_pond" as water.
-- "dock" is displayed with a water fill.
-- ----------------------------------------------------------------------------
   if ( passedt.waterway == "mill_pond" ) then
      passedt.waterway = "dock"
   end

-- ----------------------------------------------------------------------------
-- Display intermittent rivers as "intriver"
-- ----------------------------------------------------------------------------
   if (( passedt.waterway     == "river"  )  and
       ( passedt.intermittent == "yes"    )) then
      passedt.waterway = "intriver"
   end

-- ----------------------------------------------------------------------------
-- Display intermittent stream as "intstream"
-- ----------------------------------------------------------------------------
   if (( passedt.waterway     == "stream"  )  and
       ( passedt.intermittent == "yes"     )) then
      passedt.waterway = "intstream"
   end

-- ----------------------------------------------------------------------------
-- Display intermittent drains as "intdrain"
-- ----------------------------------------------------------------------------
   if (( passedt.waterway     == "drain"  )  and
       ( passedt.intermittent == "yes"    )) then
      passedt.waterway = "intdrain"
   end

-- ----------------------------------------------------------------------------
-- Display intermittent ditches as "intditch"
-- ----------------------------------------------------------------------------
   if (( passedt.waterway     == "ditch"  )  and
       ( passedt.intermittent == "yes"    )) then
      passedt.waterway = "intditch"
   end

-- ----------------------------------------------------------------------------
-- Display "location=underground" waterways as tunnels.
--
-- There are currently no "location=overground" waterways that are not
-- also "man_made=pipeline".
-- ----------------------------------------------------------------------------
   if ((( passedt.waterway ~= nil           )   and
        ( passedt.waterway ~= ""            ))  and
       (( passedt.location == "underground" )   or
        ( passedt.covered  == "yes"         ))  and
       (( passedt.tunnel   == nil           )   or
        ( passedt.tunnel   == ""            ))) then
      passedt.tunnel = "yes"
   end

-- ----------------------------------------------------------------------------
-- Display "location=overground" and "location=overhead" pipelines as bridges.
-- ----------------------------------------------------------------------------
   if ((  passedt.man_made == "pipeline"    ) and
       (( passedt.location == "overground" )  or
        ( passedt.location == "overhead"   )) and
       (( passedt.bridge   == nil          )  or
        ( passedt.bridge   == ""           ))) then
      passedt.bridge = "yes"
   end

-- ----------------------------------------------------------------------------
-- Pipelines
-- We display pipelines as waterways, because there is explicit bridge handling
-- for waterways.
-- Also note that some seamarks
-- ----------------------------------------------------------------------------
   if (( passedt.man_made     == "pipeline"           ) or
       ( passedt["seamark:type"] == "pipeline_submarine" )) then
      passedt.man_made     = nil
      passedt["seamark:type"] = nil
      passedt.waterway     = "pipeline"
   end

-- ----------------------------------------------------------------------------
-- Display gantries as pipeline bridges
-- ----------------------------------------------------------------------------
   if ( passedt.man_made == "gantry" ) then
      passedt.man_made = nil
      passedt.waterway = "pipeline"
      passedt.bridge = "yes"
   end

-- ----------------------------------------------------------------------------
-- Display military bunkers
-- Historic bunkers have been dealt with higher up.
-- ----------------------------------------------------------------------------
   if ((   passedt.military == "bunker"   ) or
       ((  passedt.building == "bunker"  )  and
        (( passedt.disused  == nil      )   or
         ( passedt.disused  == ""       ))  and
        (( passedt.historic == nil      )   or
         ( passedt.historic == ""       )))) then
      passedt.man_made = "militarybunker"
      passedt.military = nil

      if (( passedt.building == nil ) or
          ( passedt.building == ""  )) then
         passedt.building = "yes"
      end
   end

-- ----------------------------------------------------------------------------
-- Supermarkets as normal buildings
-- ----------------------------------------------------------------------------
   if ((  passedt.building   == "supermarket"      ) or
       (  passedt.man_made   == "storage_tank"     ) or
       (  passedt.man_made   == "silo"             ) or
       (  passedt.man_made   == "tank"             ) or
       (  passedt.man_made   == "water_tank"       ) or
       (  passedt.man_made   == "kiln"             ) or
       (  passedt.man_made   == "gasometer"        ) or
       (  passedt.man_made   == "oil_tank"         ) or
       (  passedt.man_made   == "greenhouse"       ) or
       (  passedt.man_made   == "water_treatment"  ) or
       (  passedt.man_made   == "trickling_filter" ) or
       (  passedt.man_made   == "filter_bed"       ) or
       (  passedt.man_made   == "filtration_bed"   ) or
       (  passedt.man_made   == "waste_treatment"  ) or
       (  passedt.man_made   == "lighthouse"       ) or
       (  passedt.man_made   == "street_cabinet"   ) or
       (  passedt.man_made   == "aeroplane"        ) or
       (  passedt.man_made   == "helicopter"       )) then
      passedt.building = "yes"
   end

-- ----------------------------------------------------------------------------
-- Only show telescopes as buildings if they don't already have a landuse set.
-- Some large radio telescopes aren't large buildings.
-- ----------------------------------------------------------------------------
   if ((  passedt.man_made == "telescope"  ) and
       (( passedt.landuse  == nil         )  or
        ( passedt.landuse  == ""          ))) then
      passedt.building = "yes"
   end

-- ----------------------------------------------------------------------------
-- building=ruins is rendered as a half-dark building.
-- The wiki tries to guide building=ruins towards follies only but ruins=yes
-- "not a folly but falling down".  That doesn't match what mappers do but 
-- render both as half-dark.
-- ----------------------------------------------------------------------------
   if (((    passedt.building        ~= nil               )   and
        (    passedt.building        ~= ""                )   and
        (((  passedt.historic        == "ruins"         )     and
          (( passedt.ruins           == nil            )      or
           ( passedt.ruins           == ""             )))    or
         (   passedt.ruins           == "yes"            )    or
         (   passedt.ruins           == "barn"           )    or
         (   passedt.ruins           == "barrack"        )    or
         (   passedt.ruins           == "blackhouse"     )    or
         (   passedt.ruins           == "house"          )    or
         (   passedt.ruins           == "hut"            )    or
         (   passedt.ruins           == "farm_auxiliary" )    or
         (   passedt.ruins           == "farmhouse"      )))  or
       (     passedt["ruins:building"]  == "yes"              )  or
       (     passedt["building:ruins"]  == "yes"              )  or
       (     passedt["ruined:building"] == "yes"              )  or
       (     passedt.building        == "collapsed"        )) then
      passedt.building = "ruins"
   end
   
-- ----------------------------------------------------------------------------
-- Map man_made=monument to historic=monument (handled below).
-- ----------------------------------------------------------------------------
   if ((  passedt.man_made == "monument" )  and
       (( passedt.tourism  == nil       )   or
        ( passedt.tourism  == ""        ))) then
      passedt.historic = "monument"
      passedt.man_made = nil
   end

-- ----------------------------------------------------------------------------
-- Map man_made=geoglyph to natural=bare_rock if another natural tag such as 
-- scree is not already set
-- ----------------------------------------------------------------------------
   if ((  passedt.man_made == "geoglyph"  ) and
       (( passedt.leisure  == nil        )  or
        ( passedt.leisure  == ""         ))) then
      if (( passedt.natural  == nil ) or
          ( passedt.natural  == ""  )) then
         passedt.natural  = "bare_rock"
      end

      passedt.man_made = nil
      passedt.tourism  = nil
   end
   
-- ----------------------------------------------------------------------------
-- Things that are both towers and monuments or memorials 
-- should render as the latter.
-- ----------------------------------------------------------------------------
   if ((  passedt.man_made  == "tower"     ) and
       (( passedt.historic  == "memorial" )  or
        ( passedt.historic  == "monument" ))) then
      passedt.man_made = nil
   end

   if ((( passedt.tourism == "gallery"     )   or
        ( passedt.tourism == "museum"      ))  and
       (  passedt.amenity == "arts_centre"  )) then
      passedt.amenity = nil
   end

   if ((( passedt.tourism == "attraction"  )   or 
        ( passedt.tourism == "artwork"     )   or
        ( passedt.tourism == "yes"         ))  and
       (  passedt.amenity == "arts_centre"  )) then
      passedt.tourism = nil
   end

-- ----------------------------------------------------------------------------
-- Mineshafts
-- First make sure that we treat historic ones also tagged as man_made 
-- as historic
-- ----------------------------------------------------------------------------
   if (((( passedt["disused:man_made"] == "mine"       )  or
         ( passedt["disused:man_made"] == "mineshaft"  )  or
         ( passedt["disused:man_made"] == "mine_shaft" )) and
        (( passedt.man_made         == nil          )  or
         ( passedt.man_made         == ""           ))) or
       ((( passedt.man_made == "mine"               )  or
         ( passedt.man_made == "mineshaft"          )  or
         ( passedt.man_made == "mine_shaft"         )) and
        (( passedt.historic == "yes"                )  or
         ( passedt.historic == "mine"               )  or
         ( passedt.historic == "mineshaft"          )  or
         ( passedt.historic == "mine_shaft"         )  or
         ( passedt.historic == "mine_adit"          )  or
         ( passedt.historic == "mine_level"         )  or
         ( passedt.disused  == "yes"                )))) then
      passedt.historic = "mineshaft"
      passedt.man_made = nil
      passedt["disused:man_made"] = nil
      passedt.tourism  = nil
   end

-- ----------------------------------------------------------------------------
-- Then other spellings of man_made=mineshaft
-- ----------------------------------------------------------------------------
   if (( passedt.man_made   == "mine"       )  or
       ( passedt.industrial == "mine"       )  or
       ( passedt.man_made   == "mine_shaft" )) then
      passedt.man_made = "mineshaft"
   end

-- ----------------------------------------------------------------------------
-- and the historic equivalents
-- ----------------------------------------------------------------------------
   if (( passedt.historic == "mine_shaft"        ) or
       ( passedt.historic == "mine_adit"         ) or
       ( passedt.historic == "mine_level"        ) or
       ( passedt.historic == "mine"              )) then
      passedt.historic = "mineshaft"

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
-- Before we assume that a "historic=fort" is some sort of castle (big walls,
-- moat, that sort of thing) check that it's not prehistoric or some sort of 
-- hill fort (banks and ditches, people running around painted blue).  If it 
-- is, set "historic=archaeological_site" so it gets picked up as one below.
-- ----------------------------------------------------------------------------
   if ((  passedt.historic              == "fort"          ) and
       (( passedt.fortification_type    == "hill_fort"    )  or
        ( passedt.fortification_type    == "hillfort"     ))) then
      passedt.historic            = "archaeological_site"
      passedt.archaeological_site = "fortification"
      passedt.fortification_type  = "hill_fort"
   end

-- ----------------------------------------------------------------------------
-- Similarly, catch "historic" "ringfort"s
-- ----------------------------------------------------------------------------
   if ((( passedt.historic           == "fortification" )   and
        ( passedt.fortification_type == "ringfort"      ))  or
       (  passedt.historic           == "rath"           )) then
      passedt.historic            = "archaeological_site"
      passedt.archaeological_site = "fortification"
      passedt.fortification_type  = "ringfort"
   end

-- ----------------------------------------------------------------------------
-- Catch other archaeological fortifications.
-- ----------------------------------------------------------------------------
   if ((  passedt.historic                 == "fort"           ) and
       (( passedt.fortification_type       == "broch"         )  or
        ( passedt["historic:civilization"] == "prehistoric"   )  or
        ( passedt["historic:civilization"] == "iron_age"      )  or
        ( passedt["historic:civilization"] == "ancient_roman" ))) then
      passedt.historic            = "archaeological_site"
      passedt.archaeological_site = "fortification"
   end

-- ----------------------------------------------------------------------------
-- First, remove non-castle castles that have been tagfiddled into the data.
-- Castles go through as "historic=castle"
-- Note that archaeological sites that are castles are handled elsewhere.
-- ----------------------------------------------------------------------------
   if ((  passedt.historic    == "castle"       ) and
       (( passedt.castle_type == "stately"     )  or
        ( passedt.castle_type == "manor"       )  or
        ( passedt.castle_type == "palace"      ))) then
      passedt.historic = "manor"
   end

   if (( passedt.historic == "castle" ) or
       ( passedt.historic == "fort"   )) then
      passedt.historic = "castle"

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
-- Manors go through as "historic=manor"
-- Note that archaeological sites that are manors are handled elsewhere.
-- ----------------------------------------------------------------------------
   if (( passedt.historic == "manor"           ) or
       ( passedt.historic == "lodge"           ) or
       ( passedt.historic == "mansion"         ) or
       ( passedt.historic == "country_mansion" ) or
       ( passedt.historic == "stately_home"    ) or
       ( passedt.historic == "palace"          )) then
      passedt.historic = "manor"
      passedt.tourism = nil

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
-- Martello Towers go through as "historic=martello_tower"
-- Some other structural tags that might otherwise get shown are removed.
-- ----------------------------------------------------------------------------
   if (( passedt.historic == "martello_tower"        ) or
       ( passedt.historic == "martello_tower;bunker" ) or
       ( passedt.historic == "martello_tower;fort"   )) then
      passedt.historic = "martello_tower"
      passedt.fortification_type = nil
      passedt.man_made = nil
      passedt["tower:type"] = nil

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
-- Unless an active place of worship,
-- monasteries etc. go through as "historic=monastery"
-- "historic=ruins;ruins=monastery" are handled the same way.
-- ----------------------------------------------------------------------------
   if ((   passedt.historic == "abbey"            ) or
       (   passedt.historic == "cathedral"        ) or
       (   passedt.historic == "monastery"        ) or
       (   passedt.historic == "priory"           ) or
       ((  passedt.historic == "ruins"            )  and
        (( passedt.ruins == "abbey"              )  or
         ( passedt.ruins == "cathedral"          )  or
         ( passedt.ruins == "monastery"          )  or
         ( passedt.ruins == "priory"             )))) then
      if ( passedt.amenity == "place_of_worship" ) then
         passedt.historic = nil
      else
         passedt.historic = "monastery"

         if ((( passedt.landuse == nil )  or
              ( passedt.landuse == ""  )) and
             (( passedt.leisure == nil )  or
              ( passedt.leisure == ""  )) and
             (( passedt.natural == nil )  or
              ( passedt.natural == ""  ))) then
            passedt.landuse = "historic"
         end
      end
   end

-- ----------------------------------------------------------------------------
-- Non-historic crosses go through as "man_made=cross".  
-- See also memorial crosses below.
-- ----------------------------------------------------------------------------
   if (( passedt.man_made == "cross"         ) or
       ( passedt.man_made == "summit_cross"  ) or
       ( passedt.man_made == "wayside_cross" )) then
      passedt.man_made = "cross"
   end

-- ----------------------------------------------------------------------------
-- Various historic crosses go through as "historic=cross".  
-- See also memorial crosses below.
-- ----------------------------------------------------------------------------
   if (( passedt.historic == "wayside_cross"    ) or
       ( passedt.historic == "high_cross"       ) or
       ( passedt.historic == "cross"            ) or
       ( passedt.historic == "market_cross"     ) or
       ( passedt.historic == "tau_cross"        ) or
       ( passedt.historic == "celtic_cross"     )) then
      passedt.historic = "cross"

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
-- Historic churches go through as "historic=church", 
-- if they're not also an amenity or something else.
-- ----------------------------------------------------------------------------
   if ((( passedt.historic == "chapel"           )  or
        ( passedt.historic == "church"           )  or
        ( passedt.historic == "place_of_worship" )  or
        ( passedt.historic == "wayside_chapel"   )) and
       (( passedt.amenity  == nil                )  or
        ( passedt.amenity  == ""                 )) and
       (( passedt.shop     == nil                )  or
        ( passedt.shop     == ""                 ))) then
      passedt.historic = "church"
      passedt.building = "yes"
      passedt.tourism = nil

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
-- Historic pinfolds go through as "historic=pinfold", 
-- Some have recently been added as "historic=pound".
-- ----------------------------------------------------------------------------
   if (( passedt.historic == "pinfold" )  or
       ( passedt.amenity  == "pinfold" )  or
       ( passedt.historic == "pound"   )) then
      passedt.historic = "pinfold"

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
-- City gates go through as "historic=city_gate"
-- Note that historic=gate are generally much smaller and are not included here.
--
-- Also, there are individual icons for these:
-- "historic=battlefield", "historic=stocks" (also used for "pillory"), 
-- "historic=well", "historic=dovecote"
-- ----------------------------------------------------------------------------
   if ( passedt.historic == "pillory" ) then
      passedt.historic = "stocks"
   end

   if (( passedt.historic == "city_gate"   ) or
       ( passedt.historic == "battlefield" ) or
       ( passedt.historic == "stocks"      ) or
       ( passedt.historic == "well"        ) or
       ( passedt.historic == "dovecote"    )) then
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
-- historic=grave_yard goes through as historic=nonspecific, with fill for 
-- amenity=grave_yard if no landuse fill already.
-- ----------------------------------------------------------------------------
   if (((  passedt.historic        == "grave_yard"  )  or
        (  passedt.historic        == "cemetery"    )  or
        (  passedt["disused:amenity"] == "grave_yard"  )  or
        (( passedt.historic        == "ruins"      )   and
         ( passedt.ruins           == "grave_yard" ))) and
       (( passedt.amenity         == nil          )  or
        ( passedt.amenity         == ""           )) and
       (  passedt.landuse         ~= "cemetery"    )) then
      passedt.historic = "nonspecific"

      if ((( passedt.landuse == nil )  or
           ( passedt.landuse == ""  )) and
          (( passedt.leisure == nil )  or
           ( passedt.leisure == ""  ))) then
         passedt.landuse = "cemetery"
      end
   end

-- ----------------------------------------------------------------------------
-- Towers go through as various historic towers
-- We also send ruined towers through here.
-- ----------------------------------------------------------------------------
   if ((  passedt.historic == "tower"        ) or
       (  passedt.historic == "round_tower"  ) or
       (( passedt.historic == "ruins"       )  and
        ( passedt.ruins    == "tower"       ))) then
      passedt.man_made = nil

      if ((  passedt.historic  == "round_tower"  ) or
          ( passedt["tower:type"] == "round_tower"  ) or
          ( passedt["tower:type"] == "shot_tower"   )) then
         passedt.historic = "historicroundtower"
      else
         if ( passedt["tower:type"] == "defensive" ) then
            passedt.historic = "historicdefensivetower"
         else
            if (( passedt["tower:type"] == "observation" ) or
                ( passedt["tower:type"] == "watchtower"  )) then
               passedt.historic = "historicobservationtower"
            else
               if ( passedt["tower:type"] == "bell_tower" ) then
                  passedt.historic = "historicchurchtower"
               else
                  passedt.historic = "historicsquaretower"
               end  -- bell_tower
            end  -- observation
         end  -- defensive
      end  -- round_tower

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
-- Both kilns and lime kilns are shown with the same distinctive bottle kiln
-- shape.
-- ----------------------------------------------------------------------------
   if (( passedt.historic       == "lime_kiln" ) or
       ( passedt["ruins:man_made"] == "kiln"      )) then
      passedt.historic       = "kiln"
      passedt["ruins:man_made"] = nil
   end

-- ----------------------------------------------------------------------------
-- Show village_pump as water_pump
-- ----------------------------------------------------------------------------
   if ( passedt.historic  == "village_pump" ) then
      passedt.historic = "water_pump"
   end

-- ----------------------------------------------------------------------------
-- Send railway=water_crane through as "historic"
-- ----------------------------------------------------------------------------
   if ((( passedt.railway          == "water_crane" ) or
        ( passedt["disused:railway"]  == "water_crane" )) and
       (( passedt.historic         == nil           )  or
        ( passedt.historic         == ""            )  or
        ( passedt.historic         == "yes"         ))) then
      passedt.historic = "water_crane"
   end

-- ----------------------------------------------------------------------------
-- For aircraft without names, try and construct something
-- First use aircraft:model and/or ref.  If still no name, inscription.
-- ----------------------------------------------------------------------------
   if ((  passedt.historic == "aircraft" )  and
       (( passedt.name     == nil        )  or
        ( passedt.name     == ""         ))) then
      if (( passedt["aircraft:model"] ~= nil ) and
          ( passedt["aircraft:model"] ~= ""  )) then
         passedt.name = passedt["aircraft:model"]
      end

      if (( passedt.ref ~= nil ) and
          ( passedt.ref ~= ""  )) then
         if (( passedt.name == nil ) or
             ( passedt.name == ""  )) then
            passedt.name = passedt.ref
         else
            passedt.name = passedt.name .. " " .. passedt.ref
         end
      end

      if ((( passedt.name        == nil )   or
           ( passedt.name        == ""  ))  and
          (  passedt.inscription ~= nil  )  and
          (  passedt.inscription ~= ""   )) then
         passedt.name = passedt.inscription
      end
   end

-- ----------------------------------------------------------------------------
-- Add a building tag to specific historic items that are likely buildings 
-- Note that "historic=mill" does not have a building tag added.
-- Nor does "historic=watermill" - in some cases the whole site is tagged as
-- that.
-- ----------------------------------------------------------------------------
   if (( passedt.historic == "aircraft"           ) or
       ( passedt.historic == "ice_house"          ) or
       ( passedt.historic == "kiln"               ) or
       ( passedt.historic == "ship"               ) or
       ( passedt.historic == "tank"               ) or
       ( passedt.historic == "windmill"           )) then
      if ( passedt.ruins == "yes" ) then
         passedt.building = "roof"
      else
         passedt.building = "yes"
      end
   end

-- ----------------------------------------------------------------------------
-- Add a building tag to nonspecific historic items that are likely buildings 
-- so that buildings.mss can process it.  Some shouldn't assume buildings 
-- (e.g. "fort" below).  Some use "roof" (which I use for "nearly a building" 
-- elsewhere).  It's sent through as "nonspecific".
-- "stone" has a building tag added because some are mapped as closed ways.
-- "landuse" is cleared because it might have been set for some building types
--  above.
-- ----------------------------------------------------------------------------
   if (( passedt.historic == "baths"              ) or
       ( passedt.historic == "building"           ) or
       ( passedt.historic == "chlochan"           ) or
       ( passedt.historic == "gate_house"         ) or
       ( passedt.historic == "heritage_building"  ) or
       ( passedt.historic == "house"              ) or
       ( passedt.historic == "locomotive"         ) or
       ( passedt.historic == "protected_building" ) or
       ( passedt.historic == "residence"          ) or
       ( passedt.historic == "roundhouse"         ) or
       ( passedt.historic == "smithy"             ) or
       ( passedt.historic == "sound_mirror"       ) or
       ( passedt.historic == "standing_stone"     ) or
       ( passedt.historic == "trough"             ) or
       ( passedt.historic == "vehicle"            )) then
      if ( passedt.ruins == "yes" ) then
         passedt.building = "roof"
      else
         passedt.building = "yes"
      end

      passedt.historic = "nonspecific"
      passedt.landuse  = nil
      passedt.tourism  = nil
   end

-- ----------------------------------------------------------------------------
-- historic=wreck is usually on nodes and has its own icon
-- ----------------------------------------------------------------------------
   if ( passedt.historic == "wreck" ) then
      passedt.building = "roof"
   end

   if ( passedt.historic == "aircraft_wreck" ) then
      passedt.building = "roof"
   end

-- ----------------------------------------------------------------------------
-- Ruined buildings do not have their own icon
-- ----------------------------------------------------------------------------
   if ((  passedt.historic == "ruins"    )  and
       (  passedt.ruins    == "building" )  and
       (( passedt.barrier  == nil        )  or
        ( passedt.barrier  == ""         ))) then
      passedt.building = "roof"
      passedt.historic = "nonspecific"
   end
   
   if ((  passedt.historic == "ruins"             ) and
       (( passedt.ruins    == "church"           )  or
        ( passedt.ruins    == "place_of_worship" )  or
        ( passedt.ruins    == "wayside_chapel"   )  or
        ( passedt.ruins    == "chapel"           )) and
       (( passedt.amenity  == nil                )  or
        ( passedt.amenity  == ""                 ))) then
      passedt.building = "roof"
      passedt.historic = "church"
   end

   if ((  passedt.historic == "ruins"           ) and
       (( passedt.ruins    == "castle"         )  or
        ( passedt.ruins    == "fort"           )  or
        ( passedt.ruins    == "donjon"         )) and
       (( passedt.amenity  == nil              )  or
        ( passedt.amenity  == ""               ))) then
      passedt.historic = "historicarchcastle"
   end

-- ----------------------------------------------------------------------------
-- "historic=industrial" has been used as a modifier for all sorts.  
-- We're not interested in most of these but do display a historic dot for 
-- some.
-- ----------------------------------------------------------------------------
   if ((  passedt.historic == "industrial"  ) and
       (( passedt.building == nil          )  or
        ( passedt.building == ""           )) and
       (( passedt.man_made == nil          )  or
        ( passedt.man_made == ""           )) and
       (( passedt.waterway == nil          )  or
        ( passedt.waterway == ""           )) and
       ( passedt.name     ~= nil            ) and
       ( passedt.name     ~= ""             )) then
      passedt.historic = "nonspecific"
      passedt.tourism = nil

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
-- Some tumuli are tagged as tombs, so dig those out first.
-- They are then picked up below.
--
-- Tombs that remain go straight through unless we need to set landuse.
-- ----------------------------------------------------------------------------
   if ( passedt.historic == "tomb" ) then
      if ( passedt.tomb == "tumulus" ) then
         passedt.historic            = "archaeological_site"
         passedt.archaeological_site = "tumulus"
      else
         if ((( passedt.landuse == nil )  or
              ( passedt.landuse == ""  )) and
             (( passedt.leisure == nil )  or
              ( passedt.leisure == ""  )) and
             (( passedt.natural == nil )  or
              ( passedt.natural == ""  ))) then
            passedt.landuse = "historic"
         end
      end
   end
   
-- ----------------------------------------------------------------------------
-- The catch-all for most "sensible" historic values that are displayed with
-- a historic dot regardless of whether they have a name.
--
-- disused:landuse=cemetery goes through here rather than as 
-- historic=grave_yard above because the notes suggest that these are not 
-- visible as graveyards any more, so no graveyard fill.
-- ----------------------------------------------------------------------------   
   if ((   passedt.historic == "almshouse"                 ) or
       (   passedt.historic == "anchor"                    ) or
       (   passedt.historic == "bakery"                    ) or
       (   passedt.historic == "barrow"                    ) or
       (   passedt.historic == "battery"                   ) or
       (   passedt.historic == "bridge_site"               ) or
       (   passedt.historic == "camp"                      ) or
       (   passedt.historic == "deserted_medieval_village" ) or
       (   passedt.historic == "drinking_fountain"         ) or
       (   passedt.historic == "fortification"             ) or
       (   passedt.historic == "gate"                      ) or
       (   passedt.historic == "grinding_mill"             ) or
       (   passedt.historic == "hall"                      ) or
       (   passedt.historic == "jail"                      ) or
       (   passedt.historic == "millstone"                 ) or
       (   passedt.historic == "monastic_grange"           ) or
       (   passedt.historic == "mound"                     ) or
       (   passedt.historic == "naval_mine"                ) or
       (   passedt.historic == "oratory"                   ) or
       (   passedt.historic == "police_call_box"           ) or
       (   passedt.historic == "prison"                    ) or
       (   passedt.historic == "ruins"                     ) or
       (   passedt.historic == "sawmill"                   ) or
       (   passedt.historic == "shelter"                   ) or
       (   passedt.historic == "statue"                    ) or
       (   passedt.historic == "theatre"                   ) or
       (   passedt.historic == "toll_house"                ) or
       (   passedt.historic == "tower_house"               ) or
       (   passedt.historic == "village"                   ) or
       (   passedt.historic == "workhouse"                 ) or
       ((  passedt["disused:landuse"] == "cemetery"          )  and
        (( passedt.landuse         == nil                )   or
         ( passedt.landuse         == ""                 ))  and
        (( passedt.leisure         == nil                )   or
         ( passedt.leisure         == ""                 ))  and
        (( passedt.amenity         == nil                )   or
         ( passedt.amenity         == ""                 )))) then
      passedt.historic = "nonspecific"
      passedt.tourism = nil
      passedt["disused:landuse"] = nil

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
-- palaeolontological_site
-- ----------------------------------------------------------------------------
   if ( passedt.geological == "palaeontological_site" ) then
      passedt.historic = "palaeontological_site"
   end

-- ----------------------------------------------------------------------------
-- historic=icon shouldn't supersede amenity or tourism tags.
-- ----------------------------------------------------------------------------
   if ((  passedt.historic == "icon"  ) and
       (( passedt.amenity  == nil    )  or
        ( passedt.amenity  == ""     )) and
       (( passedt.tourism  == nil    )  or
        ( passedt.tourism  == ""     ))) then
      passedt.historic = "nonspecific"
   end

-- ----------------------------------------------------------------------------
-- Historic markers
-- ----------------------------------------------------------------------------
   if (( passedt.historic == "marker"          ) or
       ( passedt.historic == "plaque"          ) or
       ( passedt.historic == "memorial_plaque" ) or
       ( passedt.historic == "blue_plaque"     )) then
      passedt.tourism = "informationplaque"
   end

   if ( passedt.historic == "pillar" ) then
      passedt.barrier = "bollard"
      passedt.historic = nil
   end

   if ( passedt.historic == "cairn" ) then
      passedt.man_made = "cairn"
      passedt.historic = nil
   end

   if (( passedt.historic == "chimney" ) or
       ( passedt.man_made == "chimney" ) or
       ( passedt.building == "chimney" )) then
      if (( tonumber(passedt.height) or 0 ) >  50 ) then
         passedt.man_made = "bigchimney"
      else
         passedt.man_made = "chimney"
      end
      passedt.historic = nil
   end

-- ----------------------------------------------------------------------------
-- hazard=plant is fairly rare, but render as a nonspecific historic dot.
-- ----------------------------------------------------------------------------
   if ((( passedt.hazard  == "plant"                    )  or
        ( passedt.hazard  == "toxic_plant"              )) and
       (( passedt.species == "Heracleum mantegazzianum" )  or
        ( passedt.taxon   == "Heracleum mantegazzianum" ))) then
      passedt.historic = "nonspecific"
      passedt.name = "Hogweed"
   end

-- ----------------------------------------------------------------------------
-- If something has a "lock_ref", append it to "lock_name" (if it exists) or
-- "name" (if it doesn't)
-- ----------------------------------------------------------------------------
   if (( passedt.lock_ref ~= nil ) and
       ( passedt.lock_ref ~= ""  )) then
      if (( passedt.lock_name ~= nil ) and
          ( passedt.lock_name ~= ""  )) then
         passedt.lock_name = passedt.lock_name .. " (" .. passedt.lock_ref .. ")"
      else
         if (( passedt.name ~= nil ) and
             ( passedt.name ~= ""  )) then
            passedt.name = passedt.name .. " (" .. passedt.lock_ref .. ")"
         else
            passedt.lock_name = "(" .. passedt.lock_ref .. ")"
         end
      end

      passedt.lock_ref = nil
   end

-- ----------------------------------------------------------------------------
-- If something (now) has a "lock_name", use it in preference to "name".
-- ----------------------------------------------------------------------------
   if (( passedt.lock_name ~= nil ) and
       ( passedt.lock_name ~= ""  )) then
      passedt.name = passedt.lock_name
   end

-- ----------------------------------------------------------------------------
-- If set, move bridge:name to bridge_name
-- ----------------------------------------------------------------------------
   if (( passedt["bridge:name"] ~= nil ) and
       ( passedt["bridge:name"] ~= ""  )) then
      passedt.bridge_name = passedt["bridge:name"]
      passedt["bridge:name"] = nil
   end

-- ----------------------------------------------------------------------------
-- If set, move bridge_name to name
-- ----------------------------------------------------------------------------
   if (( passedt.bridge_name ~= nil ) and
       ( passedt.bridge_name ~= ""  )) then
      passedt.name = passedt.bridge_name
      passedt.bridge_name = nil
   end

-- ----------------------------------------------------------------------------
-- If set, move bridge:ref to bridge_ref
-- ----------------------------------------------------------------------------
   if (( passedt["bridge:ref"] ~= nil ) and
       ( passedt["bridge:ref"] ~= ""  )) then
      passedt.bridge_ref = passedt["bridge:ref"]
      passedt["bridge:ref"] = nil
   end

-- ----------------------------------------------------------------------------
-- If set, move canal_bridge_ref to bridge_ref
-- ----------------------------------------------------------------------------
   if (( passedt.canal_bridge_ref ~= nil ) and
       ( passedt.canal_bridge_ref ~= ""  )) then
      passedt.bridge_ref = passedt.canal_bridge_ref
      passedt.canal_bridge_ref = nil
   end

-- ----------------------------------------------------------------------------
-- If set and relevant, do something with bridge_ref
-- ----------------------------------------------------------------------------
   if ((   passedt.bridge_ref ~= nil   ) and
       (   passedt.bridge_ref ~= ""    ) and
       ((( passedt.highway    ~= nil )   and
         ( passedt.highway    ~= ""  ))  or
        (( passedt.railway    ~= nil )   and
         ( passedt.railway    ~= ""  ))  or
        (( passedt.waterway   ~= nil )   and
         ( passedt.waterway   ~= ""  )))) then
      if (( passedt.name == nil ) or
          ( passedt.name == ""  )) then
         passedt.name = "{" .. passedt.bridge_ref .. ")"
      else
         passedt.name = passedt.name .. " {" .. passedt.bridge_ref .. ")"
      end

      passedt.bridge_ref = nil
   end

-- ----------------------------------------------------------------------------
-- If set, move tunnel:name to tunnel_name
-- ----------------------------------------------------------------------------
   if (( passedt["tunnel:name"] ~= nil ) and
       ( passedt["tunnel:name"] ~= ""  )) then
      passedt.tunnel_name = passedt["tunnel:name"]
      passedt["tunnel:name"] = nil
   end

-- ----------------------------------------------------------------------------
-- If set, move tunnel_name to name
-- ----------------------------------------------------------------------------
   if (( passedt.tunnel_name ~= nil ) and
       ( passedt.tunnel_name ~= ""  )) then
      passedt.name = passedt.tunnel_name
      passedt.tunnel_name = nil
   end

-- ----------------------------------------------------------------------------
-- If something has a "tpuk_ref", use it in preference to "name".
-- It's in brackets because it's likely not signed.
-- ----------------------------------------------------------------------------
   if (( passedt.tpuk_ref ~= nil ) and
       ( passedt.tpuk_ref ~= ""  )) then
      passedt.name = "(" .. passedt.tpuk_ref .. ")"
   end

-- ----------------------------------------------------------------------------
-- Disused railway platforms
-- ----------------------------------------------------------------------------
   if (( passedt.railway == "platform" ) and
       ( passedt.disused == "yes"       )) then
      passedt.railway = nil
      passedt["disused:railway"] = "platform"
   end

-- ----------------------------------------------------------------------------
-- Suppress Underground railway platforms
-- ----------------------------------------------------------------------------
   if ((  passedt.railway     == "platform"     ) and
       (( passedt.location    == "underground" )  or
        ( passedt.underground == "yes"         )  or
        (( tonumber(passedt.layer) or 0 ) <  0 ))) then
      passedt.railway = nil
   end

-- ----------------------------------------------------------------------------
-- If railway platforms have a ref, use it.
-- ----------------------------------------------------------------------------
   if (( passedt.railway == "platform" ) and
       ( passedt.ref     ~= nil        ) and
       ( passedt.ref     ~= ""         )) then
      passedt.name = "Platform " .. passedt.ref
      passedt.ref  = nil
   end

-- ----------------------------------------------------------------------------
-- Add "water" to some "wet" features for rendering.
-- (the last part currently vector only)
-- ----------------------------------------------------------------------------
   if (( passedt.man_made   == "wastewater_reservoir"  ) or
       ( passedt.man_made   == "lagoon"                ) or
       ( passedt.man_made   == "lake"                  ) or
       ( passedt.man_made   == "reservoir"             ) or
       ( passedt.landuse    == "reservoir"             ) or
       ( passedt.landuse    == "basin"                 ) or
       ( passedt.basin      == "wastewater"            ) or
       ( passedt.natural    == "lake"                  )) then
      passedt.natural = "water"
   end

-- ----------------------------------------------------------------------------
-- Coalesce non-intermittent water into one tag.
-- ----------------------------------------------------------------------------
   if ( passedt.landuse == "reservoir"  ) then
      passedt.natural = "water"
      passedt.landuse = nil
   end

   if ( passedt.waterway == "riverbank"  ) then
      passedt.natural = "water"
      passedt.waterway = nil
   end

-- ----------------------------------------------------------------------------
-- Suppress "name" on riverbanks mapped as "natural=water"
-- ----------------------------------------------------------------------------
   if ((  passedt.natural   == "water"   ) and
       (( passedt.water     == "river"  )  or
        ( passedt.water     == "canal"  )  or
        ( passedt.water     == "stream" )  or
        ( passedt.water     == "ditch"  )  or
        ( passedt.water     == "lock"   )  or
        ( passedt.water     == "drain"  ))) then
      passedt.name = nil
   end

-- ----------------------------------------------------------------------------
-- Handle intermittent water areas.
-- ----------------------------------------------------------------------------
   if ((( passedt.natural      == "water"  )  or
        ( passedt.landuse      == "basin"  )) and
       ( passedt.intermittent == "yes"      )) then
      passedt.natural = "intermittentwater"
      passedt.landuse = nil
   end

-- ----------------------------------------------------------------------------
-- Also try and detect flood plains etc.
-- ----------------------------------------------------------------------------
   if ((   passedt.natural      == "floodplain"     ) or
       ((( passedt.flood_prone  == "yes"          )   or
         (( passedt.hazard_prone == "yes"        )    and
          ( passedt.hazard_type  == "flood"      )))  and
        (( passedt.natural      == nil            )   or
         ( passedt.natural      == ""             ))  and
        (( passedt.highway      == nil            )   or
         ( passedt.highway      == ""             ))) or
       ((( passedt.natural      == nil            )   or
         ( passedt.natural      == ""             ))  and
        (  passedt.landuse      ~= "basin"         )  and
        (( passedt.basin        == "detention"    )   or
         ( passedt.basin        == "retention"    )   or
         ( passedt.basin        == "infiltration" )   or
         ( passedt.basin        == "side_pound"   )))) then
      passedt.natural = "flood_prone"
   end

-- ----------------------------------------------------------------------------
-- Handle intermittent wetland areas.
-- ----------------------------------------------------------------------------
   if (( passedt.natural      == "wetland"  )  and
       ( passedt.intermittent == "yes"      )) then
      passedt.natural = "intermittentwetland"
   end

-- ----------------------------------------------------------------------------
-- Map wind turbines to, er, wind turbines and make sure that they don't also
-- appear as towers.
--
-- The "man_made=power" assignment is just so that a name can be easily 
-- displayed by the rendering map style.
-- ----------------------------------------------------------------------------
   if (( passedt.man_made   == "wind_turbine" ) or
       ( passedt.man_made   == "windpump"     )) then
      passedt.power        = "generator"
      passedt.power_source = "wind"
   end

   if ((  passedt.man_made         == "tower"         ) and
       (  passedt.power            == "generator"     ) and
       (( passedt.power_source     == "wind"         )  or
        ( passedt["generator:source"] == "wind"         )  or
        ( passedt["generator:method"] == "wind_turbine" )  or
        ( passedt["plant:source"]     == "wind"         )  or
        ( passedt["generator:method"] == "wind"         ))) then
      passedt.man_made = nil
   end

   if ((( passedt.man_made == nil         )  or
        ( passedt.man_made == ""          )) and
       (( passedt.power    == "generator" )  or
        ( passedt.power    == "plant"     ))) then
      if (( passedt.power_source        == "wind"         )  or
          ( passedt["generator:source"] == "wind"         )  or
          ( passedt["generator:method"] == "wind_turbine" )  or
          ( passedt["plant:source"]     == "wind"         )  or
          ( passedt["generator:method"] == "wind"         )) then
         passedt.man_made = "power_wind"
      else
          if (( passedt["generator:source"] == "tidal"        )  or
              ( passedt["generator:source"] == "wave"         )  or
              ( passedt["plant:source"]     == "tidal"        )  or
              ( passedt["plant:source"]     == "wave"         )) then
             passedt.man_made = "power_water"
         else
             passedt.man_made = "power"
         end
      end
   end

-- ----------------------------------------------------------------------------
-- Change solar panels to "roof"
-- ----------------------------------------------------------------------------
   if (( passedt.power               == "generator"    ) and
       ( passedt["generator:method"] == "photovoltaic" )) then
      passedt.power    = nil
      passedt.building = "roof"
   end

-- ----------------------------------------------------------------------------
-- Railway ventilation shaft nodes.
-- These are rendered as a stubby black tower.
-- ----------------------------------------------------------------------------
   if (( passedt.building   == "air_shaft"            ) or
       ( passedt.man_made   == "air_shaft"            ) or
       ( passedt.tunnel     == "air_shaft"            ) or
       ( passedt.historic   == "air_shaft"            ) or
       ( passedt.railway    == "ventilation_shaft"    ) or
       ( passedt.tunnel     == "ventilation_shaft"    ) or
       ( passedt.tunnel     == "ventilation shaft"    ) or
       ( passedt.building   == "ventilation_shaft"    ) or
       ( passedt.man_made   == "ventilation_shaft"    ) or
       ( passedt.building   == "vent_shaft"           ) or
       ( passedt.man_made   == "vent_shaft"           ) or
       ( passedt["tower:type"] == "vent"              ) or
       ( passedt["tower:type"] == "ventilation"       ) or
       ( passedt["tower:type"] == "ventilation_shaft" )) then
      passedt.man_made = "ventilation_shaft"

      if (( passedt.building == nil ) or
          ( passedt.building == ""  )) then
         passedt.building = "roof"
      end
   end

-- ----------------------------------------------------------------------------
-- Horse mounting blocks
-- ----------------------------------------------------------------------------
   if (( passedt.amenity   == "mounting_block"       ) or
       ( passedt.historic  == "mounting_block"       ) or
       ( passedt.amenity   == "mounting_step"        ) or
       ( passedt.amenity   == "mounting_steps"       ) or
       ( passedt.amenity   == "horse_dismount_block" )) then
      passedt.man_made = "mounting_block"
   end

-- ----------------------------------------------------------------------------
-- Water monitoring stations
-- ----------------------------------------------------------------------------
   if ((  passedt.man_made                  == "monitoring_station"  ) and
       (( passedt["monitoring:water_level"]    == "yes"                )  or
        ( passedt["monitoring:water_flow"]     == "yes"                )  or
        ( passedt["monitoring:water_velocity"] == "yes"                ))) then
      passedt.man_made = "monitoringwater"
   end

-- ----------------------------------------------------------------------------
-- Weather monitoring stations
-- ----------------------------------------------------------------------------
   if ((  passedt.man_made                  == "monitoring_station" ) and
       (  passedt["monitoring:weather"]     == "yes"                ) and
       (( passedt["weather:radar"]          == nil                 )  or
        ( passedt["weather:radar"]          == ""                  )) and
       (( passedt["monitoring:water_level"] == nil                 )  or
        ( passedt["monitoring:water_level"] == ""                  ))) then
      passedt.man_made = "monitoringweather"
   end

-- ----------------------------------------------------------------------------
-- Rainfall monitoring stations
-- ----------------------------------------------------------------------------
   if ((  passedt.man_made               == "monitoring_station" ) and
       (  passedt["monitoring:rainfall"]    == "yes"                ) and
       (( passedt["monitoring:weather"]     == nil                 )  or
        ( passedt["monitoring:weather"]     == ""                  )) and
       (( passedt["monitoring:water_level"] == nil                 )  or
        ( passedt["monitoring:water_level"] == ""                  ))) then
      passedt.man_made = "monitoringrainfall"
   end

-- ----------------------------------------------------------------------------
-- Earthquake monitoring stations
-- ----------------------------------------------------------------------------
   if (( passedt.man_made                     == "monitoring_station" ) and
       ( passedt["monitoring:seismic_activity"]  == "yes"                )) then
      passedt.man_made = "monitoringearthquake"
   end

-- ----------------------------------------------------------------------------
-- Sky brightness monitoring stations
-- ----------------------------------------------------------------------------
   if (( passedt.man_made                   == "monitoring_station" ) and
       ( passedt["monitoring:sky_brightness"]  == "yes"                )) then
      passedt.man_made = "monitoringsky"
   end

-- ----------------------------------------------------------------------------
-- Air quality monitoring stations
-- ----------------------------------------------------------------------------
   if ((  passedt.man_made                  == "monitoring_station" ) and
       (  passedt["monitoring:air_quality"] == "yes"                ) and
       (( passedt["monitoring:weather"]     == nil                 )  or
        ( passedt["monitoring:weather"]     == ""                  ))) then
      passedt.man_made = nil
      passedt.landuse = "industrial"
      if (( passedt.name == nil ) or
          ( passedt.name == ""  )) then
         passedt.name = "(air quality)"
      else
         passedt.name = passedt.name .. " (air quality)"
      end
   end

-- ----------------------------------------------------------------------------
-- Golf ball washers
-- ----------------------------------------------------------------------------
   if ( passedt.golf == "ball_washer" ) then
      passedt.man_made = "golfballwasher"
   end

-- ----------------------------------------------------------------------------
-- Advertising Columns
-- ----------------------------------------------------------------------------
   if ( passedt.advertising == "column" ) then
      passedt.tourism = "advertising_column"
   end

-- ----------------------------------------------------------------------------
-- railway=transfer_station - show as "halt"
-- This is for Manulla Junction, https://www.openstreetmap.org/node/5524753168
-- ----------------------------------------------------------------------------
   if ( passedt.railway == "transfer_station" ) then
      passedt.railway = "halt"
   end

-- ----------------------------------------------------------------------------
-- Show unspecified "public_transport=station" as "railway=halt"
-- These are normally one of amenity=bus_station, railway=station or
--  aerialway=station.  If they are none of these at least sow them as something.
-- ----------------------------------------------------------------------------
   if ((  passedt.public_transport == "station" ) and
       (( passedt.amenity          == nil      )  or
        ( passedt.amenity          == ""       )) and
       (( passedt.railway          == nil      )  or
        ( passedt.railway          == ""       )) and
       (( passedt.aerialway        == nil      )  or
        ( passedt.aerialway        == ""       ))) then
      passedt.railway          = "halt"
      passedt.public_transport = nil
   end

-- ----------------------------------------------------------------------------
-- "tourism" stations - show with brown text rather than blue.
-- ----------------------------------------------------------------------------
   if (((( passedt.railway           == "station"   )    or
         ( passedt.railway           == "halt"      ))   and
        (( passedt.usage             == "tourism"   )    or
         ( passedt.station           == "miniature" )    or
         ( passedt.tourism           == "yes"       )))  or
       (   passedt["railway:miniature"] == "station"     )) then
      passedt.amenity = "tourismstation"
      passedt.railway = nil
      passedt["railway:miniature"] = nil
   end

-- ----------------------------------------------------------------------------
-- railway=crossing - show as level crossings.
-- ----------------------------------------------------------------------------
   if ( passedt.railway == "crossing" ) then
      passedt.railway = "level_crossing"
   end

-- ----------------------------------------------------------------------------
-- Various types of traffic light controlled crossings
-- ----------------------------------------------------------------------------
   if ((( passedt.crossing == "traffic_signals"         )  or
        ( passedt.crossing == "toucan"                  )  or
        ( passedt.crossing == "puffin"                  )  or
        ( passedt.crossing == "traffic_signals;island"  )  or
        ( passedt.crossing == "traffic_lights"          )  or
        ( passedt.crossing == "island;traffic_signals"  )  or
        ( passedt.crossing == "signals"                 )  or
        ( passedt.crossing == "pegasus"                 )  or
        ( passedt.crossing == "pedestrian_signals"      )  or
        ( passedt.crossing == "light controlled"        )) and
       (( passedt.highway  == nil                       )  or
        ( passedt.highway  == ""                        ))) then
      passedt.highway = "traffic_signals"
      passedt.crossing = nil
   end

-- ----------------------------------------------------------------------------
-- highway=passing_place to turning_circle
-- Not really the same thing, but a "widening of the road" should be good 
-- enough.  
-- ----------------------------------------------------------------------------
   if ( passedt.highway == "passing_place" ) then
      passedt.highway = "turning_circle"
   end

-- ----------------------------------------------------------------------------
-- highway=escape to service
-- There aren't many escape lanes mapped, but they do exist
-- ----------------------------------------------------------------------------
   if ( passedt.highway   == "escape" ) then
      passedt.highway = "service"
      passedt.access  = "destination"
   end

-- ----------------------------------------------------------------------------
-- Render guest houses subtagged as B&B as B&B
-- ----------------------------------------------------------------------------
   if (( passedt.tourism     == "guest_house"       ) and
       ( passedt.guest_house == "bed_and_breakfast" )) then
      passedt.tourism = "bed_and_breakfast"
   end

-- ----------------------------------------------------------------------------
-- "self_catering" is increasingly common and a series of different icons are
-- used for them, based on values for whether it is:
--
-- self catering       yes or no
-- multiple occupancy  yes, no, or don't know
-- urban setting       urban, rural, or don't know
-- cheap               yes (like a hostel) or no (like a hotel)
--
-- The resulting values such as "tourism_guest_yyyy" are passed through to be 
-- rendered.
-- ----------------------------------------------------------------------------
   if (( passedt.tourism   == "self_catering"           ) or
       ( passedt.tourism   == "accommodation"           ) or
       ( passedt.tourism   == "holiday_let"             )) then
      passedt.tourism = "tourism_guest_yddd"
   end

   if ( passedt.tourism   == "apartment"               ) then
      passedt.tourism = "tourism_guest_ynyn"
   end

   if (( passedt.tourism   == "holiday_cottage"         ) or
       ( passedt.tourism   == "cottage"                 )) then
      passedt.tourism = "tourism_guest_ynnn"
   end

   if (( passedt.tourism   == "holiday_village"         ) or
       ( passedt.tourism   == "holiday_park"            ) or
       ( passedt.tourism   == "holiday_lets"            )) then
      passedt.tourism = "tourism_guest_dynd"
   end

   if ( passedt.tourism   == "spa_resort"              ) then
      passedt.tourism = "tourism_guest_nynn"
   end

   if ( passedt.tourism   == "Holiday Lodges"          ) then
      passedt.tourism = "tourism_guest_yynd"
   end

   if (( passedt.tourism   == "aparthotel"              ) or
       ( passedt.tourism   == "apartments"              )) then
      passedt.tourism = "tourism_guest_yyyn"
   end

-- ----------------------------------------------------------------------------
-- tourism=bed_and_breakfast was removed by the "style police" in
-- https://github.com/gravitystorm/openstreetmap-carto/pull/695
-- That now has its own icon.
-- Self-catering is handled above.
-- That just leaves "tourism=guest_house":
-- ----------------------------------------------------------------------------
   if ( passedt.tourism   == "guest_house"          ) then
      passedt.tourism = "tourism_guest_nydn"
   end

-- ----------------------------------------------------------------------------
-- Render alternative taggings of camp_site etc.
-- ----------------------------------------------------------------------------
   if (( passedt.tourism == "camping"                ) or
       ( passedt.tourism == "camp_site;caravan_site" )) then
      passedt.tourism = "camp_site"
   end

   if ( passedt.tourism == "caravan_site;camp_site" ) then
      passedt.tourism = "caravan_site"
   end

   if ( passedt.tourism == "adventure_holiday"  ) then
      passedt.tourism = "hostel"
   end

-- ----------------------------------------------------------------------------
-- Camp pitches - consolidate name and ref into the name.
-- ----------------------------------------------------------------------------
   if ( passedt.tourism == "camp_pitch"  ) then
      if (( passedt.name == nil ) or
          ( passedt.name == ""  )) then
         if (( passedt.ref ~= nil ) and
             ( passedt.ref ~= ""  )) then
            passedt.name = passedt.ref
         end
      else
         if (( passedt.ref ~= nil ) and
             ( passedt.ref ~= ""  )) then
            passedt.name = passedt.name .. " " .. passedt.ref
         end
      end
   end

-- ----------------------------------------------------------------------------
-- Chalets
--
-- Depending on other tags, these will be treated as singlechalet (z17)
-- or as chalet (z16).  Processing here is simpler than for Garmin as we don't
-- have to worry where on the search menu something will appear.
--
-- We assume that tourism=chalet with no building tag could be either a
-- self-contained chalet park or just one chalet.  Leave tagging as is.
--
-- We assume that tourism=chalet with a building tag is a 
-- self-contained chalet or chalet within a resort.  Change to "singlechalet".
-- ----------------------------------------------------------------------------
   if ( passedt.tourism == "chalet" ) then
      passedt.leisure = nil

      if ((( passedt.name     == nil )  or
           ( passedt.name     == ""  )) or
          (( passedt.building ~= nil )  and
           ( passedt.building ~= ""  ))) then
         passedt.tourism = "singlechalet"
      end
   end

-- ----------------------------------------------------------------------------
-- "leisure=trailhead" is an occasional mistagging for "highway=trailhead"
-- ----------------------------------------------------------------------------
   if ((  passedt.leisure == "trailhead" ) and
       (( passedt.highway == nil        )  or
        ( passedt.highway == ""         ))) then
      passedt.highway = "trailhead"
      passedt.leisure = nil
   end

-- ----------------------------------------------------------------------------
-- Trailheads appear in odd combinations, not all of which make sense.
--
-- If someone's tagged a trailhead as a locality; likely it's not really one
-- ----------------------------------------------------------------------------
   if (( passedt.highway == "trailhead" ) and
       ( passedt.place   == "locality"  )) then
      passedt.place = nil
   end

-- ----------------------------------------------------------------------------
-- If a trailhead also has a tourism tag, go with whatever tourism tag that is,
-- rather than sending it through as "informationroutemarker" below.
-- ----------------------------------------------------------------------------
   if (( passedt.highway == "trailhead" ) and
       ( passedt.tourism ~= nil         ) and
       ( passedt.tourism ~= ""          )) then
      passedt.highway = nil
   end

-- ----------------------------------------------------------------------------
-- If a trailhead has no name but an operator, use that
-- ----------------------------------------------------------------------------
   if ((  passedt.highway  == "trailhead"  ) and
       (( passedt.name     == nil         )  or
        ( passedt.name     == ""          )) and
       (  passedt.operator ~= nil          ) and
       (  passedt.operator ~= ""           )) then
      passedt.name = passedt.operator
   end

-- ----------------------------------------------------------------------------
-- If a trailhead still has no name, remove it
-- ----------------------------------------------------------------------------
   if ((  passedt.highway  == "trailhead" ) and
       (( passedt.name     == nil        )  or
        ( passedt.name     == ""         ))) then
      passedt.highway = nil
   end

-- ----------------------------------------------------------------------------
-- Render amenity=information as tourism
-- ----------------------------------------------------------------------------
   if ( passedt.amenity == "information"  ) then
      passedt.tourism = "information"
   end

-- ----------------------------------------------------------------------------
-- Various types of information - PNFS guideposts first.
-- ----------------------------------------------------------------------------
   if (( passedt.tourism    == "information"                          ) and
       (( passedt.operator  == "Peak & Northern Footpaths Society"   )  or
        ( passedt.operator  == "Peak and Northern Footpaths Society" )  or
        ( passedt.operator  == "Peak District & Northern Counties Footpaths Preservation Society" ))) then
      passedt.tourism = "informationpnfs"
   end

-- ----------------------------------------------------------------------------
-- Some information boards don't have a "tourism" tag
-- ----------------------------------------------------------------------------
   if ((  passedt.information        == "board"  ) and
       (( passedt["disused:tourism"] == nil     )  or
        ( passedt["disused:tourism"] == ""      )) and
       (( passedt["ruins:tourism"]   == nil     )  or
        ( passedt["ruins:tourism"]   == ""      )) and
       (( passedt.historic           == nil     )  or
        ( passedt.historic           == ""      ))) then
      if ( passedt.board_type == "public_transport" ) then
         passedt.tourism = "informationpublictransport"
      else
         passedt.tourism = "informationboard"
      end
   end

-- ----------------------------------------------------------------------------
-- Information boards
-- ----------------------------------------------------------------------------
   if ((   passedt.amenity     == "notice_board"                       )  or
       (   passedt.tourism     == "village_sign"                       )  or
       (   passedt.man_made    == "village_sign"                       )  or
       ((  passedt.tourism     == "information"                       )   and
        (( passedt.information == "board"                            )    or
         ( passedt.information == "board;map"                        )    or
         ( passedt.information == "citymap"                          )    or
         ( passedt.information == "departure times and destinations" )    or
         ( passedt.information == "electronic_board"                 )    or
         ( passedt.information == "estate_map"                       )    or
         ( passedt.information == "former_telephone_box"             )    or
         ( passedt.information == "hikingmap"                        )    or
         ( passedt.information == "history"                          )    or
         ( passedt.information == "hospital map"                     )    or
         ( passedt.information == "information_board"                )    or
         ( passedt.information == "interpretation"                   )    or
         ( passedt.information == "interpretive_board"               )    or
         ( passedt.information == "leaflet_board"                    )    or
         ( passedt.information == "leaflets"                         )    or
         ( passedt.information == "map and posters"                  )    or
         ( passedt.information == "map"                              )    or
         ( passedt.information == "map;board"                        )    or
         ( passedt.information == "map_board"                        )    or
         ( passedt.information == "nature"                           )    or
         ( passedt.information == "notice_board"                     )    or
         ( passedt.information == "orientation_map"                  )    or
         ( passedt.information == "sitemap"                          )    or
         ( passedt.information == "tactile_map"                      )    or
         ( passedt.information == "tactile_model"                    )    or
         ( passedt.information == "terminal"                         )    or
         ( passedt.information == "wildlife"                         )))) then
      if ( passedt.board_type == "public_transport" ) then
         passedt.tourism = "informationpublictransport"
      else
         passedt.tourism = "informationboard"
      end
   end

   if ((  passedt.amenity     == "notice_board"       )  or
       (  passedt.tourism     == "sign"               )  or
       (  passedt.emergency   == "beach_safety_sign"  )  or
       (( passedt.tourism     == "information"       )   and
        ( passedt.information == "sign"              ))) then
      if ( passedt["operator:type"] == "military" ) then
         passedt.tourism = "militarysign"
      else
         passedt.tourism = "informationsign"
      end
   end

   if ((( passedt.tourism     == "informationboard"           )   or
        ( passedt.tourism     == "informationpublictransport" )   or
        ( passedt.tourism     == "informationsign"            )   or
        ( passedt.tourism     == "militarysign"               ))  and
       (( passedt.name        == nil                          )   or
        ( passedt.name        == ""                           ))  and
       (  passedt["board:title"] ~= nil                           )  and
       (  passedt["board:title"] ~= ""                            )) then
      passedt.name = passedt["board:title"]
   end

   if (((  passedt.tourism     == "information"                       )  and
        (( passedt.information == "guidepost"                        )   or
         ( passedt.information == "fingerpost"                       )   or
         ( passedt.information == "marker"                           ))) or
       (   passedt.man_made    == "signpost"                           )) then
      if ( passedt.guide_type == "intermediary" ) then
         passedt.tourism = "informationroutemarker"
      else
         passedt.tourism = "informationmarker"
      end

      passedt.ele = nil

      if (( passedt.name ~= nil ) and
          ( passedt.name ~= ""  )) then
         passedt.ele = passedt.name
      end

      append_directions_t( passedt )
   end

   if (((  passedt.tourism     == "information"                       )   and
        (( passedt.information == "route_marker"                     )    or
         ( passedt.information == "trail_blaze"                      )))  or
       (   passedt.highway     == "trailhead"                          )) then
      passedt.tourism = "informationroutemarker"
      passedt.ele = nil

      if (( passedt.name ~= nil ) and
          ( passedt.name ~= ""  )) then
         passedt.ele = passedt.name
      end

      append_directions_t( passedt )
   end

   if ((  passedt.tourism     == "information"                       )  and
       (( passedt.information == "office"                           )   or
        ( passedt.information == "kiosk"                            )   or
        ( passedt.information == "visitor_centre"                   ))) then
      passedt.tourism = "informationoffice"
   end

   if ((  passedt.tourism     == "information"                       )  and
       (( passedt.information == "blue_plaque"                      )   or
        ( passedt.information == "plaque"                           ))) then
      passedt.tourism = "informationplaque"
   end

   if (( passedt.tourism     == "information"                       )  and
       ( passedt.information == "audioguide"                        )) then
      passedt.tourism = "informationear"
   end

-- ----------------------------------------------------------------------------
-- NCN Route markers
-- ----------------------------------------------------------------------------
   if ( passedt.ncn_milepost == "dudgeon" ) then
      passedt.tourism = "informationncndudgeon"
      passedt.name    = passedt.sustrans_ref
   end

   if ( passedt.ncn_milepost == "mccoll" ) then
      passedt.tourism = "informationncnmccoll"
      passedt.name    = passedt.sustrans_ref
   end

   if ( passedt.ncn_milepost == "mills" ) then
      passedt.tourism = "informationncnmills"
      passedt.name    = passedt.sustrans_ref
   end

   if ( passedt.ncn_milepost == "rowe" ) then
      passedt.tourism = "informationncnrowe"
      passedt.name    = passedt.sustrans_ref
   end

   if (( passedt.ncn_milepost == "unknown" )  or
       ( passedt.ncn_milepost == "yes"     )) then
      passedt.tourism = "informationncnunknown"
      passedt.name    = passedt.sustrans_ref
   end


-- ----------------------------------------------------------------------------
-- Change some common semicolon values to the first in the list.
-- ----------------------------------------------------------------------------
   if ( passedt.amenity == "bar;restaurant" ) then
      passedt.amenity = "bar"
   end

   if (( passedt.shop == "butcher;greengrocer" ) or
       ( passedt.shop == "butcher;deli"        )) then
      passedt.shop = "butcher"
   end

   if ( passedt.shop == "greengrocer;florist" ) then
      passedt.shop = "greengrocer"
   end

-- ----------------------------------------------------------------------------
-- Things that are both peaks and memorials should render as the latter.
-- ----------------------------------------------------------------------------
   if ((( passedt.natural   == "hill"     )  or
        ( passedt.natural   == "peak"     )) and
       (  passedt.historic  == "memorial"  )) then
      passedt.natural = nil
   end

-- ----------------------------------------------------------------------------
-- Things that are both peaks and cairns should render as the former.
-- ----------------------------------------------------------------------------
   if ((( passedt.natural   == "hill"         )  or
        ( passedt.natural   == "peak"         )) and
       (( passedt.man_made  == "cairn"        )  or
        ( passedt.man_made  == "survey_point" ))) then
      passedt.man_made = nil
   end

-- ----------------------------------------------------------------------------
-- Beacons - render historic ones, not radio ones.
-- ----------------------------------------------------------------------------
   if ((( passedt.man_made == "beacon"        )  or
        ( passedt.man_made == "signal_beacon" )  or
        ( passedt.landmark == "beacon"        )  or
        ( passedt.historic == "beacon"        )) and
       (( passedt.airmark  == nil             )  or
        ( passedt.airmark  == ""              )) and
       (( passedt.aeroway  == nil             )  or
        ( passedt.aeroway  == ""              )) and
       (  passedt.natural  ~= "hill"           ) and
       (  passedt.natural  ~= "peak"           )) then
      passedt.historic = "nonspecific"
   end

-- ----------------------------------------------------------------------------
-- Render historic railway stations.
-- ----------------------------------------------------------------------------
   if ((( passedt["abandoned:railway"] == "station"             )  or
        ( passedt["disused:railway"]   == "station"             )  or
        ( passedt["historic:railway"]  == "station"             )  or
        ( passedt.historic          == "railway_station"     )  or
        ( passedt.railway           == "dismantled_colliery" )  or
        ( passedt.railway           == "colliery_site"       )) and
       (  passedt.tourism           ~= "information"          ) and
       (  passedt.name              ~= nil                    )) then
      passedt.historic = "nonspecific"
   end

-- ----------------------------------------------------------------------------
-- Add landuse=military to some military things.
-- ----------------------------------------------------------------------------
   if (( passedt.military == "office"                             ) or
       ( passedt.military == "offices"                            ) or
       ( passedt.military == "barracks"                           ) or
       ( passedt.military == "naval_base"                         ) or
       ( passedt.military == "depot"                              ) or
       ( passedt.military == "registration_and_enlistment_office" ) or
       ( passedt.military == "checkpoint"                         ) or
       ( passedt.hazard   == "shooting_range"                     ) or
       ( passedt.hazard   == "shooting"                           ) or
       ( passedt.sport    == "shooting"                           ) or
       ( passedt.sport    == "shooting_range"                     ) or
       ( passedt.leisure  == "shooting_ground"                    ) or
       ( passedt.leisure  == "shooting_range"                     )) then
      passedt.landuse = "military"
   end

-- ----------------------------------------------------------------------------
-- Extract concert hall theatres as concert halls
-- ----------------------------------------------------------------------------
   if (((  passedt.amenity         == "theatre"       )  and
        (( passedt.theatre         == "concert_hall" )   or
         ( passedt["theatre:type"] == "concert_hall" ))) or
       (   passedt.amenity == "music_venue"         )) then
      passedt.amenity = "concert_hall"
   end

-- ----------------------------------------------------------------------------
-- Show natural=embankment as man_made=embankment.
-- Where it is used in UK/IE (which is rarely) it seems to be for single-sided
-- ones.
-- ----------------------------------------------------------------------------
   if ( passedt.natural == "embankment"   ) then
      passedt.man_made = "embankment"
   end

-- ----------------------------------------------------------------------------
-- man_made=embankment and natural=cliff displays as a non-sided cliff 
-- Often it's combined with highway though, and that is handled separately.
-- In that case it's passed through to the stylesheet as bridge=levee.
-- embankment handling is asymmetric for railways currently - it's checked
-- before we apply the "man_made=levee" tag, but "bridge=levee" is not applied.
-- ----------------------------------------------------------------------------
   if ((( passedt.barrier    == "flood_bank"    )  or
        ( passedt.barrier    == "bund"          )  or
        ( passedt.barrier    == "mound"         )  or
        ( passedt.barrier    == "ridge"         )  or
        ( passedt.barrier    == "embankment"    )  or
        ( passedt.man_made   == "dyke"          )  or
        ( passedt.man_made   == "levee"         )  or
        ( passedt.embankment == "yes"           )  or
        ( passedt.barrier    == "berm"          )  or
        ( passedt.natural    == "ridge"         )  or
        ( passedt.natural    == "earth_bank"    )  or
        ( passedt.natural    == "arete"         )) and
       (( passedt.highway    == nil             )  or
        ( passedt.highway    == ""              )  or
        ( passedt.highway    == "badpathwide"   )  or
        ( passedt.highway    == "badpathnarrow" )) and
       (( passedt.railway    == nil             )  or
        ( passedt.railway    == ""              )) and
       (( passedt.waterway   == nil             )  or
        ( passedt.waterway   == ""              ))) then
      passedt.man_made = "levee"
      passedt.barrier = nil
      passedt.embankment = nil
   end

-- ----------------------------------------------------------------------------
-- Re the "bridge" check below, we've already changed valid ones to "yes"
-- above.  This sets "bridge=levee" for roads on embankments.
-- ----------------------------------------------------------------------------
   if (((  passedt.barrier    == "flood_bank"     )  or
        (  passedt.man_made   == "dyke"           )  or
        (  passedt.man_made   == "levee"          )  or
        (  passedt.embankment == "yes"            )  or
        (  passedt.natural    == "ridge"          )  or
        (  passedt.natural    == "arete"          )) and
       ((( passedt.highway    ~= nil             )   and
         ( passedt.highway    ~= ""              )   and
         ( passedt.highway    ~= "badpathwide"   )   and
         ( passedt.highway    ~= "badpathnarrow" ))  or
        (( passedt.railway    ~= nil             )   and
         ( passedt.railway    ~= ""              ))  or
        (( passedt.waterway   ~= nil             )   and
         ( passedt.waterway   ~= ""              ))) and
       (   passedt.bridge     ~= "yes"             ) and
       (   passedt.tunnel     ~= "yes"             )) then
      passedt.bridge = "levee"
      passedt.barrier = nil
      passedt.man_made = nil
      passedt.embankment = nil
   end

-- ----------------------------------------------------------------------------
-- Assume "natural=hedge" should be "barrier=hedge".
-- ----------------------------------------------------------------------------
   if ( passedt.natural == "hedge" ) then
      passedt.barrier = "hedge"
   end

-- ----------------------------------------------------------------------------
-- map "fences that are really hedges" as fences.
-- ----------------------------------------------------------------------------
   if (( passedt.barrier    == "fence" ) and
       ( passedt.fence_type == "hedge" )) then
      passedt.barrier = "hedge"
   end

-- ----------------------------------------------------------------------------
-- At this point let's try and handle hedge tags on other area features as
-- linear hedges.
-- "hedge" can be either a linear or an area feature in this style.
-- "hedgeline" can only be a linear feature in this style.
-- ----------------------------------------------------------------------------
   if ((   passedt.barrier    == "hedge"              ) and
       ((( passedt.landuse    ~= nil                )   and
         ( passedt.landuse    ~= ""                 ))  or
        (( passedt.natural    ~= nil                )   and
         ( passedt.natural    ~= ""                 ))  or
        (( passedt.leisure    ~= nil                )   and
         ( passedt.leisure    ~= ""                 ))  or
        (( passedt.amenity    ~= nil                )   and
         ( passedt.amenity    ~= ""                 ))  or
        (( passedt.historic   ~= nil                )   and
         ( passedt.historic   ~= ""                 ))  or
        (( passedt.landcover  ~= nil                )   and
         ( passedt.landcover  ~= ""                 ))  or
        (( passedt.tourism    ~= nil                )   and
         ( passedt.tourism    ~= ""                 ))  or
        (  passedt.man_made   == "wastewater_plant"  )  or
        (( passedt.surface    ~= nil                )   and
         ( passedt.surface    ~= ""                 )))) then
      passedt.barrier = "hedgeline"
   end

-- ----------------------------------------------------------------------------
-- map "alleged shrubberies" as hedge areas.
-- ----------------------------------------------------------------------------
   if ((  passedt.natural == "shrubbery"  ) and
       (( passedt.barrier == nil         )  or
        ( passedt.barrier == ""          ))) then
      passedt.natural = nil
      passedt.barrier = "hedge"
      passedt.area = "yes"
   end

-- ----------------------------------------------------------------------------
-- barrier=horse_jump is used almost exclusively on ways, so map to fence.
-- Also some other barriers.
-- ----------------------------------------------------------------------------
   if (( passedt.barrier == "horse_jump"     ) or
       ( passedt.barrier == "traffic_island" ) or
       ( passedt.barrier == "wire_fence"     ) or
       ( passedt.barrier == "wood_fence"     ) or
       ( passedt.barrier == "guard_rail"     ) or
       ( passedt.barrier == "railing"        )) then
      passedt.barrier = "fence"
   end

-- ----------------------------------------------------------------------------
-- barrier=ditch; handle as waterway=ditch.
-- ----------------------------------------------------------------------------
   if ( passedt.barrier == "ditch" ) then
      passedt.waterway = "ditch"
      passedt.barrier  = nil
   end

-- ----------------------------------------------------------------------------
-- There's now a barrier=kissing_gate icon.
-- For gates, choose which of the two gate icons to used based on tagging.
-- "sally_port" is mapped to gate largely because of misuse in the data.
-- ----------------------------------------------------------------------------
   if ((  passedt.barrier   == "turnstile"              )  or
       (  passedt.barrier   == "full-height_turnstile"  )  or
       (  passedt.barrier   == "kissing_gate;gate"      )  or
       (( passedt.barrier   == "gate"                  )   and
        ( passedt.gate      == "kissing"               ))) then
      passedt.barrier = "kissing_gate"
   end

-- ----------------------------------------------------------------------------
-- gates
-- ----------------------------------------------------------------------------
   if (( passedt.barrier   == "gate"                  )  or
       ( passedt.barrier   == "swing_gate"            )  or
       ( passedt.barrier   == "footgate"              )  or
       ( passedt.barrier   == "wicket_gate"           )  or
       ( passedt.barrier   == "hampshire_gate"        )  or
       ( passedt.barrier   == "bump_gate"             )  or
       ( passedt.barrier   == "lych_gate"             )  or
       ( passedt.barrier   == "lytch_gate"            )  or
       ( passedt.barrier   == "flood_gate"            )  or
       ( passedt.barrier   == "sally_port"            )  or
       ( passedt.barrier   == "pengate"               )  or
       ( passedt.barrier   == "pengates"              )  or
       ( passedt.barrier   == "gate;stile"            )  or
       ( passedt.barrier   == "cattle_grid;gate"      )  or
       ( passedt.barrier   == "gate;kissing_gate"     )  or
       ( passedt.barrier   == "pull_apart_gate"       )  or
       ( passedt.barrier   == "snow_gate"             )) then
      if (( passedt.locked == "yes"         ) or
          ( passedt.locked == "permanently" ) or
          ( passedt.status == "locked"      ) or
          ( passedt.gate   == "locked"      )) then
         passedt.barrier = "gate_locked"
      else
         passedt.barrier = "gate"
      end
   end

-- ----------------------------------------------------------------------------
-- lift gates
-- ----------------------------------------------------------------------------
   if (( passedt.barrier    == "border_control"   ) or
       ( passedt.barrier    == "ticket_barrier"   ) or
       ( passedt.barrier    == "ticket"           ) or
       ( passedt.barrier    == "security_control" ) or
       ( passedt.barrier    == "checkpoint"       ) or
       ( passedt.industrial == "checkpoint"       ) or
       ( passedt.police     == "checkpoint"       ) or
       ( passedt.barrier    == "gatehouse"        )) then
      passedt.barrier = "lift_gate"
   end

-- ----------------------------------------------------------------------------
-- render barrier=bar as barrier=horse_stile (Norfolk)
-- ----------------------------------------------------------------------------
   if ( passedt.barrier == "bar" ) then
      passedt.barrier = "horse_stile"
   end

-- ----------------------------------------------------------------------------
-- render various cycle barrier synonyms
-- ----------------------------------------------------------------------------
   if (( passedt.barrier   == "chicane"               )  or
       ( passedt.barrier   == "squeeze"               )  or
       ( passedt.barrier   == "motorcycle_barrier"    )  or
       ( passedt.barrier   == "horse_barrier"         )  or
       ( passedt.barrier   == "a_frame"               )) then
      passedt.barrier = "cycle_barrier"
   end

-- ----------------------------------------------------------------------------
-- render various synonyms for stile as barrier=stile
-- ----------------------------------------------------------------------------
   if (( passedt.barrier   == "squeeze_stile"   )  or
       ( passedt.barrier   == "ramblers_gate"   )  or
       ( passedt.barrier   == "squeeze_point"   )  or
       ( passedt.barrier   == "step_over"       )  or
       ( passedt.barrier   == "stile;gate"      )) then
      passedt.barrier = "stile"
   end

-- ----------------------------------------------------------------------------
-- Has this stile got a dog gate?
-- ----------------------------------------------------------------------------
   if (( passedt.barrier  == "stile" ) and
       ( passedt.dog_gate == "yes"   )) then
      passedt.barrier = "dog_gate_stile"
   end

-- ----------------------------------------------------------------------------
-- remove barrier=entrance as it's not really a barrier.
-- ----------------------------------------------------------------------------
   if ( passedt.barrier   == "entrance" ) then
      passedt.barrier = nil
   end

-- ----------------------------------------------------------------------------
-- Render main entrances
-- Note that "railway=train_station_entrance" isn't shown as a subway entrance.
-- ----------------------------------------------------------------------------
   if ((( passedt.entrance         == "main"                   )  or
        ( passedt.building         == "entrance"               )  or
        ( passedt.entrance         == "entrance"               )  or
        ( passedt.public_transport == "entrance"               )  or
        ( passedt.railway          == "entrance"               )  or
        ( passedt.railway          == "train_station_entrance" )  or
        ( passedt.school           == "entrance"               )) and
       (( passedt.amenity          == nil                      )  or
        ( passedt.amenity          == ""                       )) and
       (( passedt.barrier          == nil                      )  or
        ( passedt.barrier          == ""                       )) and
       (( passedt.building         == nil                      )  or
        ( passedt.building         == ""                       )) and
       (( passedt.craft            == nil                      )  or
        ( passedt.craft            == ""                       )) and
       (( passedt.highway          == nil                      )  or
        ( passedt.highway          == ""                       )) and
       (( passedt.office           == nil                      )  or
        ( passedt.office           == ""                       )) and
       (( passedt.shop             == nil                      )  or
        ( passedt.shop             == ""                       )) and
       (( passedt.tourism          == nil                      )  or
        ( passedt.tourism          == ""                       ))) then
      passedt.amenity = "entrancemain"
   end

-- ----------------------------------------------------------------------------
-- Assign barrier=tree_row for natural=tree_row so that on raster 
-- "area" tree_rows are shown as tree rows in the "area barriers" layer.
-- ----------------------------------------------------------------------------
   if ( passedt.natural   == "tree_row" ) then
      passedt.barrier = "tree_row"
   end

-- ----------------------------------------------------------------------------
-- Render castle_wall as city_wall
-- ----------------------------------------------------------------------------
   if (( passedt.barrier   == "wall"        )  and
       ( passedt.wall      == "castle_wall" )) then
      passedt.historic = "citywalls"
   end

-- ----------------------------------------------------------------------------
-- Render lines on sports pitches
-- ----------------------------------------------------------------------------
   if ( passedt.pitch == "line" ) then
      passedt.barrier = "pitchline"
   end

-- ----------------------------------------------------------------------------
-- Climbing features (boulders, stones, etc.)
-- Deliberately only use this for outdoor features that would not otherwise
-- display, so not cliffs etc.
-- ----------------------------------------------------------------------------
   if ((( passedt.sport    == "climbing"            )  or
        ( passedt.sport    == "climbing;bouldering" )  or
        ( passedt.climbing == "boulder"             )) and
       (  passedt.natural  ~= "hill"           ) and
       (  passedt.natural  ~= "peak"           ) and
       (  passedt.natural  ~= "cliff"          ) and
       (  passedt.leisure  ~= "sports_centre"  ) and
       (  passedt.leisure  ~= "climbing_wall"  ) and
       (  passedt.shop     ~= "sports"         ) and
       (  passedt.tourism  ~= "attraction"     ) and
       (( passedt.building == nil             )  or
        ( passedt.building == ""              )) and
       (  passedt.man_made ~= "tower"          ) and
       (  passedt.barrier  ~= "wall"           ) and
       (  passedt.amenity  ~= "pitch_climbing" )) then
      passedt.natural = "climbing"
   end

-- ----------------------------------------------------------------------------
-- Big peaks and big prominent peaks
-- ----------------------------------------------------------------------------
   if ((  passedt.natural              == "peak"     ) and
       (( tonumber(passedt.ele) or 0 ) >  914        )) then
      if (( tonumber(passedt.prominence) or 0 ) == 0 ) then
         if ( passedt.munro == "yes" ) then
            passedt.prominence = "0"
         else
            passedt.prominence = passedt.ele
         end
      end
      if (( tonumber(passedt.prominence) or 0 ) >  500 ) then
         passedt.natural = "bigprompeak"
      else
         passedt.natural = "bigpeak"
      end
   end

-- ----------------------------------------------------------------------------
-- natural=fell is used for all sorts of things, but render as heath, except
-- where someone's mapped it on a footpath.
-- ----------------------------------------------------------------------------
   if ( passedt.natural == "fell" ) then
      if (( passedt.highway == nil ) or
          ( passedt.highway == ""  )) then
         passedt.natural = "heath"
      else
         passedt.natural = nil
      end
   end

-- ----------------------------------------------------------------------------
-- Do show loungers as benches.
-- ----------------------------------------------------------------------------
   if ( passedt.amenity == "lounger" ) then
      passedt.amenity = "bench"
   end

-- ----------------------------------------------------------------------------
-- Don't show "standing benches" as benches.
-- ----------------------------------------------------------------------------
   if (( passedt.amenity == "bench"          ) and
       ( passedt.bench   == "stand_up_bench" )) then
      passedt.amenity = nil
   end

-- ----------------------------------------------------------------------------
-- Get rid of landuse=conservation if we can.  It's a bit of a special case;
-- in raster maps it has a label like grass but no green fill.
-- ----------------------------------------------------------------------------
   if ((   passedt.landuse  == "conservation"   ) and
       ((( passedt.historic ~= nil            )   and
         ( passedt.historic ~= ""             ))  or
        (( passedt.leisure  ~= nil            )   and
         ( passedt.leisure  ~= ""             ))  or
        (( passedt.natural  ~= nil            )   and
         ( passedt.natural  ~= ""             )))) then
      passedt.landuse = nil
   end

-- ----------------------------------------------------------------------------
-- "wayside_shrine" and various memorial crosses.
-- ----------------------------------------------------------------------------
   if ((   passedt.historic   == "wayside_shrine"   ) or
       ((  passedt.historic   == "memorial"        )  and
        (( passedt.memorial   == "mercat_cross"   )   or
         ( passedt.memorial   == "cross"          )   or
         ( passedt.memorial   == "celtic_cross"   )   or
         ( passedt.memorial   == "cross;stone"    )))) then
      passedt.historic = "memorialcross"
   end

   if (( passedt.historic   == "memorial"     ) and
       ( passedt.memorial   == "war_memorial" )) then
      passedt.historic = "warmemorial"
   end

   if ((  passedt.historic      == "memorial"     ) and
       (( passedt.memorial      == "plaque"      )  or
        ( passedt.memorial      == "blue_plaque" )  or
        ( passedt["memorial:type"] == "plaque"      ))) then
      passedt.historic = "memorialplaque"
   end

   if ((  passedt.historic   == "memorial"         ) and
       (( passedt.memorial   == "pavement plaque" )  or
        ( passedt.memorial   == "pavement_plaque" ))) then
      passedt.historic = "memorialpavementplaque"
   end

   if ((  passedt.historic      == "memorial"  ) and
       (( passedt.memorial      == "statue"   )  or
        ( passedt["memorial:type"] == "statue"   ))) then
      passedt.historic = "memorialstatue"
   end

   if (( passedt.historic   == "memorial"    ) and
       ( passedt.memorial   == "sculpture"   )) then
      passedt.historic = "memorialsculpture"
   end

   if (( passedt.historic   == "memorial"    ) and
       ( passedt.memorial   == "stone"       )) then
      passedt.historic = "memorialstone"
   end

-- ----------------------------------------------------------------------------
-- Ogham stones mapped without other tags
-- ----------------------------------------------------------------------------
   if ( passedt.historic   == "ogham_stone" ) then
      passedt.historic = "oghamstone"
   end

-- ----------------------------------------------------------------------------
-- Stones that are not boundary stones.
-- Note that "marker=boundary_stone" are handled elsewhere.
-- ----------------------------------------------------------------------------
   if (( passedt.marker   == "stone"          ) or
       ( passedt.natural  == "stone"          ) or
       ( passedt.man_made == "stone"          ) or
       ( passedt.man_made == "standing_stone" )) then
      passedt.historic = "naturalstone"

      append_inscription_t( passedt )
   end

-- ----------------------------------------------------------------------------
-- stones and standing stones
-- The latter is intended to look proper ancient history; 
-- the former more recent,
-- See also historic=archaeological_site, especially megalith, below
-- ----------------------------------------------------------------------------
   if (( passedt.historic == "stone"         ) or
       ( passedt.historic == "bullaun_stone" )) then
      passedt.historic = "historicstone"
   end

   if ( passedt.historic   == "standing_stone" ) then
      passedt.historic = "historicstandingstone"
   end

-- ----------------------------------------------------------------------------
-- Show earthworks as archaeological rather than historic.
-- ----------------------------------------------------------------------------
   if ( passedt.historic == "earthworks"        ) then
      passedt.historic = "archaeological_site"
   end

-- ----------------------------------------------------------------------------
-- archaeological sites
--
-- The subtag of archaeological_site was traditionally site_type, but after
-- some tagfiddling to and fro was then both archaeological_site and site_type
-- and then (July 2023) just archaeological_site; I handle both.
--
-- If something is tagged as both an archaeological site and a place or a 
-- tourist attraction, lose the other tag.
-- Add historic landuse if there isn't already something 
-- that would set an area fill such as landuse or natural.
--
-- Then handle different types of archaeological sites.
-- fortification
-- tumulus
--
-- megalith / standing stone
-- The default icon for a megalith / standing stone is one standing stone.
-- Stone circles are shown as such 
-- Some groups of stones are shown with two stones.
-- ----------------------------------------------------------------------------
   if ( passedt.historic == "archaeological_site" ) then
      passedt.place = nil
      passedt.tourism = nil

      if ((( passedt.landuse                  == nil      )   or
           ( passedt.landuse                  == ""       ))  and
          (( passedt.leisure                  == nil      )   or
           ( passedt.leisure                  == ""       ))  and
          (( passedt.natural                  == nil      )   or
           ( passedt.natural                  == ""       ))  and
          (  passedt["historic:civilization"] ~= "modern"  )) then
         passedt.landuse = "historic"
      end

      if (( passedt.archaeological_site == "fortification" ) or 
          ( passedt.site_type           == "fortification" )) then
-- ----------------------------------------------------------------------------
-- Is the fortification a ringfort?
-- There are 9k of them in Ireland
-- ----------------------------------------------------------------------------
         if ( passedt.fortification_type == "ringfort" ) then
            passedt.historic = "historicringfort"
         else
-- ----------------------------------------------------------------------------
-- Is the fortification a hill fort (either spelling)?
-- Confusingly, some of these are mapped as fortification_type and some as
-- archaeological_site.
-- Also look for "hilltop_enclosure" here - see e.g. 
-- https://www.openstreetmap.org/changeset/145424438 and
-- comments in https://www.openstreetmap.org/changeset/145424213 .
-- ----------------------------------------------------------------------------
            if (( passedt.fortification_type == "hill_fort"          ) or
                ( passedt.fortification_type == "hillfort"           ) or
                ( passedt.fortification_type == "hilltop_enclosure"  )) then
               passedt.historic = "historichillfort"
            else
-- ----------------------------------------------------------------------------
-- Is the fortification a motte?
-- ----------------------------------------------------------------------------
               if (( passedt.fortification_type == "motte"             ) or
                   ( passedt.fortification_type == "motte_and_bailey"  )) then
                  passedt.historic = "historicarchmotte"
               else
-- ----------------------------------------------------------------------------
-- Is the fortification a castle?
-- Confusingly, some of these are mapped as fortification_type and some as
-- archaeological_site.
-- ----------------------------------------------------------------------------
                  if ( passedt.fortification_type == "castle" ) then
                     passedt.historic = "historicarchcastle"
                  else
-- ----------------------------------------------------------------------------
-- Is the fortification a promontory fort?
-- ----------------------------------------------------------------------------
                     if ( passedt.fortification_type == "promontory_fort" ) then
                        passedt.historic = "historicpromontoryfort"
                     else
-- ----------------------------------------------------------------------------
-- Show as a generic fortification
-- ----------------------------------------------------------------------------
                        passedt.historic = "historicfortification"
                     end  -- promontory fort
                  end  -- castle
               end  -- motte
            end  -- hill_fort
         end  -- ringfort
      else
-- ----------------------------------------------------------------------------
-- Not a fortification.  Check for tumulus
-- ----------------------------------------------------------------------------
         if ((  passedt.archaeological_site == "tumulus"  ) or 
             (  passedt.site_type           == "tumulus"  ) or
             (( passedt.archaeological_site == "tomb"    )  and
              ( passedt.tomb                == "tumulus" ))) then
            passedt.historic = "historictumulus"
         else
-- ----------------------------------------------------------------------------
-- Not a fortification or tumulus.  Check for megalith or standing stone.
-- ----------------------------------------------------------------------------
            if (( passedt.archaeological_site == "megalith"       ) or 
                ( passedt.site_type           == "megalith"       ) or
                ( passedt.archaeological_site == "standing_stone" ) or 
                ( passedt.site_type           == "standing_stone" )) then
               if (( passedt.megalith_type == "stone_circle" ) or
                   ( passedt.megalith_type == "ring_cairn"   ) or
                   ( passedt.megalith_type == "henge"        )) then
                  passedt.historic = "historicstonecircle"
               else
-- ----------------------------------------------------------------------------
-- We have a megalith or standing stone. Check megalith_type for dolmen etc.
-- ----------------------------------------------------------------------------
                  if (( passedt.megalith_type == "dolmen"          ) or
                      ( passedt.megalith_type == "long_barrow"     ) or
                      ( passedt.megalith_type == "passage_grave"   ) or
                      ( passedt.megalith_type == "court_tomb"      ) or
                      ( passedt.megalith_type == "cist"            ) or
                      ( passedt.megalith_type == "wedge_tomb"      ) or
                      ( passedt.megalith_type == "tholos"          ) or
                      ( passedt.megalith_type == "chamber"         ) or
                      ( passedt.megalith_type == "cairn"           ) or
                      ( passedt.megalith_type == "round_barrow"    ) or
                      ( passedt.megalith_type == "gallery_grave"   ) or
                      ( passedt.megalith_type == "tomb"            ) or
                      ( passedt.megalith_type == "chambered_cairn" ) or
                      ( passedt.megalith_type == "chamber_cairn"   ) or
                      ( passedt.megalith_type == "portal_tomb"     )) then
                     passedt.historic = "historicmegalithtomb"
                  else
-- ----------------------------------------------------------------------------
-- We have a megalith or standing stone. Check megalith_type for stone_row
-- ----------------------------------------------------------------------------
                     if (( passedt.megalith_type == "alignment"  ) or
                         ( passedt.megalith_type == "stone_row"  ) or
                         ( passedt.megalith_type == "stone_line" )) then
                           passedt.historic = "historicstonerow"
                     else
-- ----------------------------------------------------------------------------
-- We have a megalith or standing stone, but megalith_type says it is not a 
-- dolmen etc., stone circle or stone row.  
-- Just use the normal standing stone icon.
-- ----------------------------------------------------------------------------
                        passedt.historic = "historicstandingstone"
                     end  -- if alignment
                  end  -- if dolmen
               end  -- if stone circle
            else
-- ----------------------------------------------------------------------------
-- Not a fortification, tumulus, megalith or standing stone.
-- Check for hill fort (either spelling) or "hilltop_enclosure"
-- (see https://www.openstreetmap.org/changeset/145424213 )
-- ----------------------------------------------------------------------------
               if (( passedt.archaeological_site == "hill_fort"         ) or
                   ( passedt.site_type           == "hill_fort"         ) or
                   ( passedt.archaeological_site == "hillfort"          ) or
                   ( passedt.site_type           == "hillfort"          ) or
                   ( passedt.archaeological_site == "hilltop_enclosure" )) then
                  passedt.historic = "historichillfort"
               else
-- ----------------------------------------------------------------------------
-- Check for castle
-- Confusingly, some of these are mapped as fortification_type and some as
-- archaeological_site.
-- ----------------------------------------------------------------------------
                  if ( passedt.archaeological_site == "castle" ) then
                     passedt.historic = "historicarchcastle"
                  else
-- ----------------------------------------------------------------------------
-- Is the archaeological site a crannog?
-- ----------------------------------------------------------------------------
                     if ( passedt.archaeological_site == "crannog" ) then
                        passedt.historic = "historiccrannog"
                     else
                        if (( passedt.archaeological_site == "settlement" ) and
                            ( passedt.fortification_type  == "ringfort"   )) then
                           passedt.historic = "historicringfort"
-- ----------------------------------------------------------------------------
-- There's no code an an "else" here, just this comment:
--                      else
--
-- If set, archaeological_site is not fortification, tumulus, 
-- megalith / standing stone, hill fort, castle or settlement that is also 
-- a ringfort.  Most will not have archaeological_site set.
-- The standard icon for historic=archaeological_site will be used 
-- ----------------------------------------------------------------------------
                        end -- settlement that is also ringfort
                     end  -- crannog
                  end  -- if castle
               end  -- if hill fort
            end  -- if megalith
         end  -- if tumulus
      end  -- if fortification
   end  -- if archaeological site

   if ( passedt.historic   == "rune_stone" ) then
      passedt.historic = "runestone"
   end

   if ( passedt.place_of_worship   == "mass_rock" ) then
      passedt.amenity = nil
      passedt.historic = "massrock"
   end
end -- consolidate_lua_03_t( passedt )


function consolidate_lua_04_t( passedt )
-- ----------------------------------------------------------------------------
-- Memorial plates
-- ----------------------------------------------------------------------------
   if ((  passedt.historic      == "memorial"  ) and
       (( passedt.memorial      == "plate"    )  or
        ( passedt["memorial:type"] == "plate"    ))) then
      passedt.historic = "memorialplate"
   end

-- ----------------------------------------------------------------------------
-- Memorial benches
-- ----------------------------------------------------------------------------
   if (( passedt.historic   == "memorial"    ) and
       ( passedt.memorial   == "bench"       )) then
      passedt.historic = "memorialbench"
   end

-- ----------------------------------------------------------------------------
-- Historic graves, and memorial graves and graveyards
-- ----------------------------------------------------------------------------
   if ((   passedt.historic   == "grave"         ) or
       ((  passedt.historic   == "memorial"     )  and
        (( passedt.memorial   == "grave"       )   or
         ( passedt.memorial   == "graveyard"   )))) then
      passedt.historic = "memorialgrave"
   end

-- ----------------------------------------------------------------------------
-- Memorial obelisks
-- ----------------------------------------------------------------------------
   if ((   passedt.man_made      == "obelisk"     ) or
       (   passedt.landmark      == "obelisk"     ) or
       ((  passedt.historic      == "memorial"   ) and
        (( passedt.memorial      == "obelisk"   )  or
         ( passedt["memorial:type"] == "obelisk"   )))) then
      passedt.historic = "memorialobelisk"
   end

-- ----------------------------------------------------------------------------
-- Other memorials go straight through, even though there are some area ones.
-- We don't add "landuse=historic", even if no other landuse or natural tags
-- are set, because sometimes these overlay other landuse, such as cemetaries.
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- Render shop=newsagent as shop=convenience
-- It's near enough in meaning I think.  Likewise kiosk (bit of a stretch,
-- but nearer than anything else)
-- ----------------------------------------------------------------------------
   if (( passedt.shop   == "newsagent"               ) or
       ( passedt.shop   == "kiosk"                   ) or
       ( passedt.shop   == "forecourt"               ) or
       ( passedt.shop   == "food"                    ) or
       ( passedt.shop   == "grocery"                 ) or
       ( passedt.shop   == "grocer"                  ) or
       ( passedt.shop   == "frozen_food"             ) or
       ( passedt.shop   == "convenience;alcohol"     ) or
       ( passedt.shop   == "convenience;e-cigarette" ) or
       ( passedt.shop   == "convenience;newsagent  " ) or
       ( passedt.shop   == "newsagent;alcohol"       )) then
      passedt.shop = "convenience"
   end

-- ----------------------------------------------------------------------------
-- Render "eco" shops with their own icons
-- ----------------------------------------------------------------------------
   if ((   passedt.shop               == "zero_waste"          ) or
       (   passedt.shop               == "eco_refill"          ) or
       (   passedt.shop               == "refill"              ) or
       ((( passedt.shop               == "convenience"        )  or
         ( passedt.shop               == "general"            )  or
         ( passedt.shop               == "grocer"             )  or
         ( passedt.shop               == "grocery"            )  or
         ( passedt.shop               == "yes"                )  or
         ( passedt.shop               == "food"               )) and
        (( passedt.zero_waste         == "yes"                )  or
         ( passedt.zero_waste         == "only"               )  or
         ( passedt.bulk_purchase      == "yes"                )  or
         ( passedt.bulk_purchase      == "only"               )  or
         ( passedt.reusable_packaging == "yes"                )))) then
      passedt.shop = "ecoconv"
   end

   if ((  passedt.shop               == "supermarket"         ) and
       (( passedt.zero_waste         == "yes"                )  or
        ( passedt.zero_waste         == "only"               )  or
        ( passedt.bulk_purchase      == "yes"                )  or
        ( passedt.bulk_purchase      == "only"               )  or
        ( passedt.reusable_packaging == "yes"                ))) then
      passedt.shop = "ecosupermarket"
   end

   if ((  passedt.shop               == "greengrocer"         ) and
       (( passedt.zero_waste         == "yes"                )  or
        ( passedt.zero_waste         == "only"               )  or
        ( passedt.bulk_purchase      == "yes"                )  or
        ( passedt.bulk_purchase      == "only"               )  or
        ( passedt.reusable_packaging == "yes"                ))) then
      passedt.shop = "ecogreengrocer"
   end

-- ----------------------------------------------------------------------------
-- Render shop=variety etc. with a "pound" icon.  "variety_store" is the most 
-- popular tagging but "variety" is also used.
-- ----------------------------------------------------------------------------
   if (( passedt.shop   == "variety"       ) or
       ( passedt.shop   == "pound"         ) or
       ( passedt.shop   == "thrift"        ) or
       ( passedt.shop   == "variety_store" )) then
      passedt.shop = "discount"
   end

-- ----------------------------------------------------------------------------
-- shoe shops
-- ----------------------------------------------------------------------------
   if (( passedt.shop == "shoes"        ) or
       ( passedt.shop == "footwear"     )) then
      passedt.shop = "shoes"
   end

-- ----------------------------------------------------------------------------
-- "clothes" consolidation.  "baby_goods" is here because there will surely
-- be some clothes there!
-- ----------------------------------------------------------------------------
   if (( passedt.shop == "fashion"      ) or
       ( passedt.shop == "boutique"     ) or
       ( passedt.shop == "vintage"      ) or
       ( passedt.shop == "bridal"       ) or
       ( passedt.shop == "wedding"      ) or
       ( passedt.shop == "baby_goods"   ) or
       ( passedt.shop == "baby"         ) or
       ( passedt.shop == "dance"        ) or
       ( passedt.shop == "clothes_hire" ) or
       ( passedt.shop == "clothing"     ) or
       ( passedt.shop == "hat"          ) or
       ( passedt.shop == "hats"         ) or
       ( passedt.shop == "wigs"         )) then
      passedt.shop = "clothes"
   end

-- ----------------------------------------------------------------------------
-- "electronics"
-- Looking at the tagging of shop=electronics, there's a fair crossover with 
-- electrical.
-- ----------------------------------------------------------------------------
   if (( passedt.shop    == "electronics"             ) or
       ( passedt.craft   == "electronics_repair"      ) or
       ( passedt.shop    == "electronics_repair"      ) or
       ( passedt.amenity == "electronics_repair"      )) then
      passedt.shop = "electronics"
   end

-- ----------------------------------------------------------------------------
-- "electrical" consolidation
-- ----------------------------------------------------------------------------
   if (( passedt.shop    == "radiotechnics"           ) or
       ( passedt.shop    == "appliance"               ) or
       ( passedt.shop    == "electrical_supplies"     ) or
       ( passedt.shop    == "electrical_repair"       ) or
       ( passedt.shop    == "tv_repair"               ) or
       ( passedt.shop    == "gadget"                  ) or
       ( passedt.shop    == "appliances"              ) or
       ( passedt.shop    == "vacuum_cleaner"          ) or
       ( passedt.shop    == "sewing_machines"         ) or
       ( passedt.shop    == "domestic_appliances"     ) or
       ( passedt.shop    == "white_goods"             ) or
       ( passedt.shop    == "electricals"             ) or
       ( passedt.trade   == "electrical"              ) or
       ( passedt.name    == "City Electrical Factors" )) then
      passedt.shop = "electrical"
   end

-- ----------------------------------------------------------------------------
-- Show industrial=distributor as offices.
-- This sounds odd, but matches how this is used UK/IE
-- ----------------------------------------------------------------------------
   if ((  passedt.industrial == "distributor" ) and
       (( passedt.office     == nil          ) or
        ( passedt.office     == ""           ))) then
      passedt.office = "yes"
   end

-- ----------------------------------------------------------------------------
-- "funeral" consolidation.  All of these spellings currently in use in the UK
-- ----------------------------------------------------------------------------
   if (( passedt.shop    == "funeral"             ) or
       ( passedt.office  == "funeral_director"    ) or
       ( passedt.office  == "funeral_directors"   ) or
       ( passedt.amenity == "funeral"             ) or
       ( passedt.amenity == "funeral_directors"   ) or
       ( passedt.amenity == "undertaker"          )) then
      passedt.shop = "funeral_directors"
   end

-- ----------------------------------------------------------------------------
-- "jewellery" consolidation.  "jewelry" is in the database, until recently
-- "jewellery" was too.  The style handles "jewellery", hence the change here.
-- ----------------------------------------------------------------------------
   if (( passedt.shop  == "jewelry"                 ) or
       ( passedt.shop  == "jewelry;pawnbroker"      ) or
       ( passedt.shop  == "yes;jewelry;e-cigarette" ) or
       ( passedt.shop  == "jewelry;sunglasses"      ) or
       ( passedt.shop  == "yes;jewelry"             ) or
       ( passedt.shop  == "jewelry;art;crafts"      ) or
       ( passedt.shop  == "jewelry;fabric"          ) or
       ( passedt.shop  == "watch"                   ) or
       ( passedt.shop  == "watches"                 ) or
       ( passedt.craft == "jeweller"                ) or
       ( passedt.craft == "jewellery_repair"        ) or
       ( passedt.craft == "engraver"                )) then
      passedt.shop  = "jewellery"
      passedt.craft = nil
   end

-- ----------------------------------------------------------------------------
-- "department_store" consolidation.
-- ----------------------------------------------------------------------------
   if ( passedt.shop == "department" ) then
      passedt.shop = "department_store"
   end

-- ----------------------------------------------------------------------------
-- "catalogue shop" consolidation.
-- ----------------------------------------------------------------------------
   if ( passedt.shop == "outpost"  ) then
      passedt.shop = "catalogue"
   end

-- ----------------------------------------------------------------------------
-- man_made=flagpole
-- Non-MOD ones are passed straight through to be rendered.  MOD ones are
-- changed to flagpole_red so that they can be rendered differently.
-- ----------------------------------------------------------------------------
   if ((  passedt.man_made == "flagpole"             )  and
       (( passedt.operator == "Ministry of Defence" )   or
        ( passedt.operator == "MOD"                 ))) then
      passedt.man_made = "flagpole_red"
      passedt.operator = nil
   end

-- ----------------------------------------------------------------------------
-- Windsocks
-- ----------------------------------------------------------------------------
   if ( passedt.aeroway  == "windsock" ) then
      passedt.man_made = "windsock"
   end

-- ----------------------------------------------------------------------------
-- We're going to do some brand and operator tidying below, but first, tidy 
-- some errant names.
-- First, M&S.  The shorter of these is the more common by a country mile.
-- Also remove a duplicate long brand name at this time.
-- ----------------------------------------------------------------------------
   if ( passedt.name   == "Marks & Spencer Simply Food" ) then
      passedt.name = "M&S Simply Food"

      if ( passedt.brand   == "Marks & Spencer" ) then
         passedt.brand = nil
      end

      if ( passedt.operator   == "Marks & Spencer" ) then
         passedt.operator = nil
      end
   end

   if ( passedt.name   == "Marks & Spencer Food Hall" ) then
      passedt.name = "M&S Foodhall"

      if ( passedt.brand   == "Marks & Spencer" ) then
         passedt.brand = nil
      end

      if ( passedt.operator   == "Marks & Spencer" ) then
         passedt.operator = nil
      end
   end
   
   if ( passedt.name   == "O'Neills" ) then
      if ( passedt.brand   == "O'Neill's" ) then
         passedt.brand = nil
      end

      if ( passedt.operator   == "O'Neill's" ) then
         passedt.operator = nil
      end
   end

-- ----------------------------------------------------------------------------
-- Before potentially using brand or operator as a bracketed suffix after the
-- name, explicitly exclude some "non-brands" - "Independent", etc.
-- ----------------------------------------------------------------------------
   if (( passedt.brand   == "Independant"            ) or
       ( passedt.brand   == "Independent"            ) or
       ( passedt.brand   == "Traditional Free House" ) or
       ( passedt.brand   == "independant"            ) or
       ( passedt.brand   == "independent"            )) then
      passedt.brand = nil
   end

-- ----------------------------------------------------------------------------
-- There are some silly long brands in the database.  Remove them.
-- ----------------------------------------------------------------------------
   if (( passedt.brand ~= nil             ) and
       ( passedt.brand ~= ""              ) and
       ( string.len( passedt.brand ) > 40 )) then
      passedt.brand = nil
   end

-- ----------------------------------------------------------------------------
-- Consolidate some brands so that silly long names do not appear.
-- If the thing has no "name", let the silly long name still appear.
--
-- First, Amazon's tentacles:
-- ----------------------------------------------------------------------------
   if ((  passedt.name    ~= nil                    ) and
       (  passedt.name    ~= ""                     ) and
       (( passedt.brand   == "Amazon Hub"            ) or
        ( passedt.brand   == "Amazon Locker"         ) or
        ( passedt.brand   == "Amazon Hub Locker"     ) or
        ( passedt.brand   == "Amazon hub"            ) or
        ( passedt.brand   == "Amazon Fresh"          ))) then
      passedt.brand = "Amazon"
   end

-- ----------------------------------------------------------------------------
-- Next, Tesco.
-- Most have some sort of name, so shorten the brand on everything.
-- ----------------------------------------------------------------------------
   if (( passedt.brand   == "Tesco Extra"   ) or
       ( passedt.brand   == "Tesco Express" ) or
       ( passedt.brand   == "Tesco Bank"    )) then
      passedt.brand = "Tesco"
   end

-- ----------------------------------------------------------------------------
-- Next, Halfords.  Shorten the brand on everything.
-- ----------------------------------------------------------------------------
   if (( passedt.brand   == "Halfords Autocentre"      ) or
       ( passedt.brand   == "Halfords Garage Services" )) then
      passedt.brand = "Halfords"
   end

-- ----------------------------------------------------------------------------
-- Next, Tesla.  Shorten the brand on everything.
-- ----------------------------------------------------------------------------
   if (( passedt.brand   == "Tesla Supercharger" ) or
       ( passedt.brand   == "Tesla, Inc."        )) then
      passedt.brand = "Tesla"
   end

-- ----------------------------------------------------------------------------
-- Next, M&S.  Shorten the brand on everything.
-- ----------------------------------------------------------------------------
   if (( passedt.brand   == "M&S Simply Food" ) or
       ( passedt.brand   == "M&S Foodhall"    )) then
      passedt.brand = "M&S"
   end

-- ----------------------------------------------------------------------------
-- Explicitly exclude some "non-operators" - "Independent", etc.
-- ----------------------------------------------------------------------------
   if (( passedt.operator   == "(free_house)"            ) or
       ( passedt.operator   == "Free Brewery"            ) or
       ( passedt.operator   == "Free House"              ) or
       ( passedt.operator   == "Free house"              ) or
       ( passedt.operator   == "Free"                    ) or
       ( passedt.operator   == "Freehold"                ) or
       ( passedt.operator   == "Freehouse"               ) or
       ( passedt.operator   == "Independant"             ) or
       ( passedt.operator   == "Independent"             ) or
       ( passedt.operator   == "free house"              ) or
       ( passedt.operator   == "free"                    ) or
       ( passedt.operator   == "free_house"              ) or
       ( passedt.operator   == "freehouse"               ) or
       ( passedt.operator   == "independant"             ) or
       ( passedt.operator   == "independent free house"  ) or
       ( passedt.operator   == "independent"             )) then
      passedt.operator = nil
   end

-- ----------------------------------------------------------------------------
-- There are some silly long operators in the database.  Remove them.
-- ----------------------------------------------------------------------------
   if (( passedt.operator ~= nil             ) and
       ( passedt.operator ~= ""              ) and
       ( string.len( passedt.operator ) > 40 )) then
      passedt.operator = nil
   end

-- ----------------------------------------------------------------------------
-- Next, Tesla.  Shorten the operator on everything.
-- ----------------------------------------------------------------------------
   if (( passedt.operator   == "Tesla Motors Inc." ) or
       ( passedt.operator   == "Tesla Motors"      ) or
       ( passedt.operator   == "Tesla, Inc."       )) then
      passedt.operator = "Tesla"
   end

-- ----------------------------------------------------------------------------
-- Next, M&S.  Shorten the operator on everything.
-- ----------------------------------------------------------------------------
   if (( passedt.operator   == "M&S Simply Food" ) or
       ( passedt.operator   == "M&S Foodhall"    )) then
      passedt.operator = "M&S"
   end

-- ----------------------------------------------------------------------------
-- Handle these as bicycle_rental:
-- ----------------------------------------------------------------------------
   if ( passedt.amenity == "bicycle_parking;bicycle_rental" ) then
      passedt.amenity = "bicycle_rental"
   end

-- ----------------------------------------------------------------------------
-- If no name use brand or operator on amenity=fuel, among others.  
-- If there is brand or operator, use that with name.
-- ----------------------------------------------------------------------------
   if ((  passedt.amenity   == "atm"               ) or
       (  passedt.amenity   == "fuel"              ) or
       (  passedt.amenity   == "fuel_e"            ) or
       (  passedt.amenity   == "fuel_h"            ) or
       (  passedt.amenity   == "fuel_l"            ) or
       (  passedt.amenity   == "fuel_w"            ) or
       (  passedt.amenity   == "charging_station"  ) or
       (  passedt.amenity   == "bicycle_rental"    ) or
       (  passedt.amenity   == "scooter_rental"    ) or
       (  passedt.amenity   == "vending_machine"   ) or
       (( passedt.amenity  ~= nil                 )  and
        ( passedt.amenity  ~= ""                  )  and
        ( string.match( passedt.amenity, "pub_"  ))) or
       (  passedt.amenity   == "pub"               ) or
       (  passedt.amenity   == "cafe"              ) or
       (  passedt.amenity   == "cafe_dld"          ) or
       (  passedt.amenity   == "cafe_dnd"          ) or
       (  passedt.amenity   == "cafe_dyd"          ) or
       (  passedt.amenity   == "cafe_ydd"          ) or
       (  passedt.amenity   == "cafe_yld"          ) or
       (  passedt.amenity   == "cafe_ynd"          ) or
       (  passedt.amenity   == "cafe_yyd"          ) or
       (  passedt.amenity   == "restaurant"        ) or
       (  passedt.amenity   == "restaccomm"        ) or
       (  passedt.amenity   == "doctors"           ) or
       (  passedt.amenity   == "pharmacy"          ) or
       (  passedt.amenity   == "pharmacy_l"        ) or
       (  passedt.amenity   == "pharmacy_n"        ) or
       (  passedt.amenity   == "pharmacy_y"        ) or
       (  passedt.amenity   == "parcel_locker"     ) or
       (  passedt.amenity   == "veterinary"        ) or
       (  passedt.amenity   == "animal_boarding"   ) or
       (  passedt.amenity   == "cattery"           ) or
       (  passedt.amenity   == "kennels"           ) or
       (  passedt.amenity   == "animal_shelter"    ) or
       (  passedt.animal    == "shelter"           ) or
       (( passedt.craft      ~= nil               )  and
        ( passedt.craft      ~= ""                )) or
       (( passedt.emergency  ~= nil               )  and
        ( passedt.emergency  ~= ""                )) or
       (( passedt.industrial ~= nil               )  and
        ( passedt.industrial ~= ""                )) or
       (( passedt.man_made   ~= nil               )  and
        ( passedt.man_made   ~= ""                )) or
       (( passedt.office     ~= nil               )  and
        ( passedt.office     ~= ""                )) or
       (( passedt.shop       ~= nil               )  and
        ( passedt.shop       ~= ""                )) or
       (  passedt.tourism    == "hotel"            ) or
       (  passedt.military   == "barracks"         )) then
      if (( passedt.name == nil ) or
          ( passedt.name == ""  )) then
         if (( passedt.brand ~= nil ) and
             ( passedt.brand ~= ""  )) then
            passedt.name = passedt.brand
            passedt.brand = nil
         else
            if (( passedt.operator ~= nil ) and
                ( passedt.operator ~= ""  )) then
               passedt.name = passedt.operator
               passedt.operator = nil
            end
         end
      else
         if (( passedt.brand ~= nil                                ) and
             ( passedt.brand ~= ""                                 ) and
             ( not string.find( passedt.name, passedt.brand, 1, true )) and
             ( not string.find( passedt.brand, passedt.name, 1, true ))) then
            passedt.name = passedt.name .. " (" .. passedt.brand .. ")"
            passedt.brand = nil
         else
            if (( passedt.operator ~= nil                                ) and
                ( passedt.operator ~= ""                                 ) and
                ( not string.find( passedt.name, passedt.operator, 1, true )) and
                ( not string.find( passedt.operator, passedt.name, 1, true ))) then
               passedt.name = passedt.name .. " (" .. passedt.operator .. ")"
               passedt.operator = nil
            end
         end
      end
   end

-- ----------------------------------------------------------------------------
-- office=estate_agent.  There's now an icon for "shop", so use that.
-- Also letting_agent
-- ----------------------------------------------------------------------------
   if (( passedt.office  == "estate_agent"      ) or
       ( passedt.amenity == "estate_agent"      ) or
       ( passedt.shop    == "letting_agent"     ) or
       ( passedt.shop    == "council_house"     ) or
       ( passedt.office  == "letting_agent"     )) then
      passedt.shop = "estate_agent"
   end

-- ----------------------------------------------------------------------------
-- plant_nursery and lawnmower etc. to garden_centre
-- Add unnamedcommercial landuse to give non-building areas a background.
-- Usage suggests shop=nursery means plant_nursery.
-- ----------------------------------------------------------------------------
   if (( passedt.landuse == "plant_nursery"              ) or
       ( passedt.shop    == "plant_nursery"              ) or
       ( passedt.shop    == "plant_centre"               )) then
      passedt.landuse = "unnamedorchard"
      passedt.shop    = "garden_centre"
   end

   if (( passedt.shop    == "nursery"                    ) or
       ( passedt.shop    == "lawn_mower"                 ) or
       ( passedt.shop    == "lawnmowers"                 ) or
       ( passedt.shop    == "garden_furniture"           ) or
       ( passedt.shop    == "hot_tub"                    ) or
       ( passedt.shop    == "garden_machinery"           ) or
       ( passedt.shop    == "gardening"                  ) or
       ( passedt.shop    == "garden_equipment"           ) or
       ( passedt.shop    == "garden_tools"               ) or
       ( passedt.shop    == "garden"                     ) or
       ( passedt.shop    == "doityourself;garden_centre" ) or
       ( passedt.shop    == "garden_machines"            ) or
       ( passedt.shop    == "groundskeeping"             ) or
       ( passedt.shop    == "plants"                     ) or
       ( passedt.shop    == "garden_centre;interior_decoration;pet;toys" )) then
      passedt.landuse = "unnamedcommercial"
      passedt.shop    = "garden_centre"
   end

-- ----------------------------------------------------------------------------
-- "fast_food" consolidation of lesser used tags.  
-- Also render fish and chips etc. with a unique icon.
-- ----------------------------------------------------------------------------
   if ( passedt.shop == "fast_food" ) then
      passedt.amenity = "fast_food"
   end

   if ((  passedt.amenity == "fast_food"                            )  and
       (( passedt.cuisine == "american"                            )   or
        ( passedt.cuisine == "argentinian"                         )   or
        ( passedt.cuisine == "brazilian"                           )   or
        ( passedt.cuisine == "burger"                              )   or
        ( passedt.cuisine == "burger;chicken"                      )   or
        ( passedt.cuisine == "burger;chicken;fish_and_chips;kebab" )   or
        ( passedt.cuisine == "burger;chicken;indian;kebab;pizza"   )   or
        ( passedt.cuisine == "burger;chicken;kebab"                )   or
        ( passedt.cuisine == "burger;chicken;kebab;pizza"          )   or
        ( passedt.cuisine == "burger;chicken;pizza"                )   or
        ( passedt.cuisine == "burger;fish_and_chips"               )   or
        ( passedt.cuisine == "burger;fish_and_chips;kebab;pizza"   )   or
        ( passedt.cuisine == "burger;indian;kebab;pizza"           )   or
        ( passedt.cuisine == "burger;kebab"                        )   or
        ( passedt.cuisine == "burger;kebab;pizza"                  )   or
        ( passedt.cuisine == "burger;pizza"                        )   or
        ( passedt.cuisine == "burger;pizza;kebab"                  )   or
        ( passedt.cuisine == "burger;sandwich"                     )   or
        ( passedt.cuisine == "diner"                               )   or
        ( passedt.cuisine == "grill"                               )   or
        ( passedt.cuisine == "steak_house"                         ))) then
      passedt.amenity = "fast_food_burger"
   end

   if ((  passedt.amenity == "fast_food"               )  and
       (( passedt.cuisine == "chicken"                )   or
        ( passedt.cuisine == "chicken;burger;pizza"   )   or
        ( passedt.cuisine == "chicken;fish_and_chips" )   or
        ( passedt.cuisine == "chicken;grill"          )   or
        ( passedt.cuisine == "chicken;kebab"          )   or
        ( passedt.cuisine == "chicken;pizza"          )   or
        ( passedt.cuisine == "chicken;portuguese"     )   or
        ( passedt.cuisine == "fried_chicken"          )   or
        ( passedt.cuisine == "wings"                  ))) then
      passedt.amenity = "fast_food_chicken"
   end

   if ((  passedt.amenity == "fast_food"               )  and
       (( passedt.cuisine == "chinese"                )   or
        ( passedt.cuisine == "thai"                   )   or
        ( passedt.cuisine == "chinese;thai"           )   or
        ( passedt.cuisine == "chinese;thai;malaysian" )   or
        ( passedt.cuisine == "thai;chinese"           )   or
        ( passedt.cuisine == "asian"                  )   or
        ( passedt.cuisine == "japanese"               )   or
        ( passedt.cuisine == "japanese;sushi"         )   or
        ( passedt.cuisine == "sushi;japanese"         )   or
        ( passedt.cuisine == "japanese;korean"        )   or
        ( passedt.cuisine == "korean;japanese"        )   or
        ( passedt.cuisine == "vietnamese"             )   or
        ( passedt.cuisine == "korean"                 )   or
        ( passedt.cuisine == "ramen"                  )   or
        ( passedt.cuisine == "noodle"                 )   or
        ( passedt.cuisine == "noodle;ramen"           )   or
        ( passedt.cuisine == "malaysian"              )   or
        ( passedt.cuisine == "malaysian;chinese"      )   or
        ( passedt.cuisine == "indonesian"             )   or
        ( passedt.cuisine == "cantonese"              )   or
        ( passedt.cuisine == "chinese;cantonese"      )   or
        ( passedt.cuisine == "chinese;asian"          )   or
        ( passedt.cuisine == "oriental"               )   or
        ( passedt.cuisine == "chinese;english"        )   or
        ( passedt.cuisine == "chinese;japanese"       )   or
        ( passedt.cuisine == "sushi"                  ))) then
      passedt.amenity = "fast_food_chinese"
   end

   if ((  passedt.amenity == "fast_food"                  )  and
       (( passedt.cuisine == "coffee"                    )   or
        ( passedt.cuisine == "coffee_shop"               )   or
        ( passedt.cuisine == "coffee_shop;sandwich"      )   or
        ( passedt.cuisine == "coffee_shop;local"         )   or
        ( passedt.cuisine == "coffee_shop;regional"      )   or
        ( passedt.cuisine == "coffee_shop;cake"          )   or
        ( passedt.cuisine == "coffee_shop;sandwich;cake" )   or
        ( passedt.cuisine == "coffee_shop;breakfast"     )   or
        ( passedt.cuisine == "coffee_shop;italian"       )   or
        ( passedt.cuisine == "cake;coffee_shop"          )   or
        ( passedt.cuisine == "coffee_shop;ice_cream"     ))) then
      passedt.amenity = "fast_food_coffee"
   end

   if ((  passedt.amenity == "fast_food"                          ) and
       (( passedt.cuisine == "fish_and_chips"                    )  or
        ( passedt.cuisine == "chinese;fish_and_chips"            )  or
        ( passedt.cuisine == "fish"                              )  or
        ( passedt.cuisine == "fish_and_chips;chinese"            )  or
        ( passedt.cuisine == "fish_and_chips;indian"             )  or
        ( passedt.cuisine == "fish_and_chips;kebab"              )  or
        ( passedt.cuisine == "fish_and_chips;pizza;kebab"        )  or
        ( passedt.cuisine == "fish_and_chips;pizza;burger;kebab" )  or
        ( passedt.cuisine == "fish_and_chips;pizza"              ))) then
      passedt.amenity = "fast_food_fish_and_chips"
   end

   if ((( passedt.amenity == "fast_food"                        )  and
        ( passedt.cuisine == "ice_cream"                       )   or
        ( passedt.cuisine == "ice_cream;cake;coffee"           )   or
        ( passedt.cuisine == "ice_cream;cake;sandwich"         )   or
        ( passedt.cuisine == "ice_cream;coffee_shop"           )   or
        ( passedt.cuisine == "ice_cream;coffee;waffle"         )   or
        ( passedt.cuisine == "ice_cream;donut"                 )   or
        ( passedt.cuisine == "ice_cream;pizza"                 )   or
        ( passedt.cuisine == "ice_cream;sandwich"              )   or
        ( passedt.cuisine == "ice_cream;tea;coffee"            ))  or
       (  passedt.shop    == "ice_cream"                        )  or
       (  passedt.amenity == "ice_cream"                        )) then
      passedt.amenity = "fast_food_ice_cream"
   end

   if ((  passedt.amenity == "fast_food"            ) and
       (( passedt.cuisine == "indian"              )  or
        ( passedt.cuisine == "curry"               )  or
        ( passedt.cuisine == "nepalese"            )  or
        ( passedt.cuisine == "nepalese;indian"     )  or
        ( passedt.cuisine == "indian;nepalese"     )  or
        ( passedt.cuisine == "bangladeshi"         )  or
        ( passedt.cuisine == "indian;bangladeshi"  )  or
        ( passedt.cuisine == "bangladeshi;indian"  )  or
        ( passedt.cuisine == "indian;curry"        )  or
        ( passedt.cuisine == "indian;kebab"        )  or
        ( passedt.cuisine == "indian;kebab;burger" )  or
        ( passedt.cuisine == "indian;thai"         )  or
        ( passedt.cuisine == "curry;indian"        )  or
        ( passedt.cuisine == "pakistani"           )  or
        ( passedt.cuisine == "indian;pakistani"    )  or
        ( passedt.cuisine == "tandoori"            )  or
        ( passedt.cuisine == "afghan"              )  or
        ( passedt.cuisine == "sri_lankan"          )  or
        ( passedt.cuisine == "punjabi"             )  or
        ( passedt.cuisine == "indian;pizza"        ))) then
      passedt.amenity = "fast_food_indian"
   end

   if ((  passedt.amenity == "fast_food"             ) and
       (( passedt.cuisine == "kebab"                )  or
        ( passedt.cuisine == "kebab;pizza"          )  or
        ( passedt.cuisine == "kebab;pizza;burger"   )  or
        ( passedt.cuisine == "kebab;burger;pizza"   )  or
        ( passedt.cuisine == "kebab;burger;chicken" )  or
        ( passedt.cuisine == "kebab;burger"         )  or
        ( passedt.cuisine == "kebab;fish_and_chips" )  or
        ( passedt.cuisine == "turkish"              ))) then
      passedt.amenity = "fast_food_kebab"
   end

   if ((  passedt.amenity == "fast_food"      )  and
       (( passedt.cuisine == "pasties"       )   or
        ( passedt.cuisine == "pasty"         )   or
        ( passedt.cuisine == "cornish_pasty" )   or
        ( passedt.cuisine == "pie"           )   or
        ( passedt.cuisine == "pies"          ))) then
      passedt.amenity = "fast_food_pie"
   end

   if ((  passedt.amenity == "fast_food"                   )  and
       (( passedt.cuisine == "italian"                    )   or
        ( passedt.cuisine == "italian;pizza"              )   or
        ( passedt.cuisine == "italian_pizza"              )   or
        ( passedt.cuisine == "mediterranean"              )   or
        ( passedt.cuisine == "pasta"                      )   or
        ( passedt.cuisine == "pizza"                      )   or
        ( passedt.cuisine == "pizza;burger"               )   or
        ( passedt.cuisine == "pizza;burger;kebab"         )   or
        ( passedt.cuisine == "pizza;chicken"              )   or
        ( passedt.cuisine == "pizza;fish_and_chips"       )   or
        ( passedt.cuisine == "pizza;indian"               )   or
        ( passedt.cuisine == "pizza;italian"              )   or
        ( passedt.cuisine == "pizza;kebab"                )   or
        ( passedt.cuisine == "pizza;kebab;burger"         )   or
        ( passedt.cuisine == "pizza;kebab;burger;chicken" )   or
        ( passedt.cuisine == "pizza;kebab;chicken"        )   or
        ( passedt.cuisine == "pizza;pasta"                ))) then
      passedt.amenity = "fast_food_pizza"
   end

   if ((  passedt.amenity == "fast_food"             )  and
       (( passedt.cuisine == "sandwich"             )   or
        ( passedt.cuisine == "sandwich;bakery"      )   or
        ( passedt.cuisine == "sandwich;coffee_shop" ))) then
      passedt.amenity = "fast_food_sandwich"
   end

-- ----------------------------------------------------------------------------
-- Sundials
-- ----------------------------------------------------------------------------
   if (( passedt.amenity == "clock"   )  and
       ( passedt.display == "sundial" )) then
      passedt.amenity = "sundial"
   end

-- ----------------------------------------------------------------------------
-- Render shop=hardware stores etc. as shop=doityourself
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( passedt.shop    == "hardware"             ) or
       ( passedt.shop    == "tool_hire"            ) or
       ( passedt.shop    == "equipment_hire"       ) or
       ( passedt.shop    == "tools"                ) or
       ( passedt.shop    == "hardware_rental"      ) or
       ( passedt.shop    == "builders_merchant"    ) or
       ( passedt.shop    == "builders_merchants"   ) or
       ( passedt.shop    == "timber"               ) or
       ( passedt.shop    == "fencing"              ) or
       ( passedt.shop    == "plumbers_merchant"    ) or
       ( passedt.shop    == "building_supplies"    ) or
       ( passedt.shop    == "industrial_supplies"  ) or
       ( passedt.office  == "industrial_supplies"  ) or
       ( passedt.shop    == "plant_hire"           ) or
       ( passedt.amenity == "plant_hire;tool_hire" ) or
       ( passedt.shop    == "signs"                ) or
       ( passedt.shop    == "sign"                 ) or
       ( passedt.shop    == "signwriter"           ) or
       ( passedt.craft   == "signmaker"            ) or
       ( passedt.craft   == "roofer"               ) or
       ( passedt.shop    == "roofing"              ) or
       ( passedt.craft   == "floorer"              ) or
       ( passedt.shop    == "building_materials"   ) or
       ( passedt.craft   == "builder"              )) then
      passedt.landuse = "unnamedcommercial"
      passedt.shop    = "doityourself"
      passedt.amenity = nil
   end

-- ----------------------------------------------------------------------------
-- Consolidate "lenders of last resort" as pawnbroker
-- "money_transfer" and down from there is perhaps a bit of a stretch; 
-- as there is a distinctive pawnbroker icon, so generic is used for those.
-- ----------------------------------------------------------------------------
   if (( passedt.shop == "money"              ) or
       ( passedt.shop == "money_lender"       ) or
       ( passedt.shop == "cash"               )) then
      passedt.shop = "pawnbroker"
   end

-- ----------------------------------------------------------------------------
-- Deli is quite popular and has its own icon
-- ----------------------------------------------------------------------------
   if ( passedt.shop == "delicatessen" ) then
      passedt.shop = "deli"
   end

-- ----------------------------------------------------------------------------
-- Other money shops
-- ----------------------------------------------------------------------------
   if (( passedt.shop    == "money_transfer"      ) or
       ( passedt.shop    == "finance"             ) or
       ( passedt.office  == "finance"             ) or
       ( passedt.shop    == "financial"           ) or
       ( passedt.shop    == "mortgage"            ) or
       ( passedt.shop    == "financial_services"  ) or
       ( passedt.office  == "financial_services"  ) or
       ( passedt.office  == "financial_advisor"   ) or
       ( passedt.shop    == "financial_advisor"   ) or
       ( passedt.shop    == "financial_advisors"  ) or
       ( passedt.amenity == "financial_advice"    ) or
       ( passedt.shop    == "financial_advice"    ) or
       ( passedt.amenity == "bureau_de_change"    ) or
       ( passedt.shop    == "gold_buyer"          )) then
      passedt.shop = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- hairdresser;beauty
-- ----------------------------------------------------------------------------
   if (( passedt.shop == "hairdresser;beauty"      ) or
       ( passedt.shop == "barber"                  ) or
       ( passedt.shop == "hairdresser;e-cigarette" )) then
      passedt.shop = "hairdresser"
   end

-- ----------------------------------------------------------------------------
-- sports
-- the name is usually characteristic, but try and use an icon.
-- ----------------------------------------------------------------------------
   if (( passedt.shop   == "golf"              ) or
       ( passedt.shop   == "scuba_diving"      ) or
       ( passedt.shop   == "water_sports"      ) or
       ( passedt.shop   == "fishing"           ) or
       ( passedt.shop   == "fishing_tackle"    ) or
       ( passedt.shop   == "angling"           ) or
       ( passedt.shop   == "fitness_equipment" )) then
      passedt.shop = "sports"
   end

-- ----------------------------------------------------------------------------
-- e-cigarette
-- ----------------------------------------------------------------------------
   if (( passedt.shop   == "vaping"                            ) or
       ( passedt.shop   == "vape_shop"                         ) or
       ( passedt.shop   == "e-cigarette;beverages"             ) or
       ( passedt.shop   == "e-cigarette;computer;mobile_phone" ) or
       ( passedt.shop   == "e-cigarette;confectionery;cbd"     ) or
       ( passedt.shop   == "e-cigarette;convenience"           ) or
       ( passedt.shop   == "e-cigarette;mobile_phone"          )) then
      passedt.shop = "e-cigarette"
   end

-- ----------------------------------------------------------------------------
-- Various not-really-clothes things best rendered as clothes shops
-- ----------------------------------------------------------------------------
   if (( passedt.shop    == "tailor"                  ) or
       ( passedt.craft   == "tailor"                  ) or
       ( passedt.craft   == "dressmaker"              ) or
       ( passedt.shop    == "dressmaker"              )) then
      passedt.shop = "clothes"
   end

-- ----------------------------------------------------------------------------
-- Currently handle beauty salons etc. as just generic beauty.  Also "chemist"
-- Mostly these have names that describe the business, so less need for a
-- specific icon.
-- ----------------------------------------------------------------------------
   if (( passedt.shop         == "beauty_salon"       ) or
       ( passedt.leisure      == "spa"                ) or
       ( passedt.shop         == "spa"                ) or
       ( passedt.amenity      == "spa"                ) or
       ( passedt.tourism      == "spa"                ) or
       (( passedt.club    == "health"                )  and
        (( passedt.leisure == nil                   )   or
         ( passedt.leisure == ""                    ))  and
        (( passedt.amenity == nil                   )   or
         ( passedt.amenity == ""                    ))  and
        ( passedt.name    ~= nil                     )  and
        ( passedt.name    ~= ""                      )) or
       ( passedt.shop         == "salon"              ) or
       ( passedt.shop         == "nails"              ) or
       ( passedt.shop         == "nail_salon"         ) or
       ( passedt.shop         == "nail"               ) or
       ( passedt.shop         == "chemist"            ) or
       ( passedt.shop         == "soap"               ) or
       ( passedt.shop         == "toiletries"         ) or
       ( passedt.shop         == "beauty_products"    ) or
       ( passedt.shop         == "beauty_treatment"   ) or
       ( passedt.shop         == "perfumery"          ) or
       ( passedt.shop         == "cosmetics"          ) or
       ( passedt.shop         == "tanning"            ) or
       ( passedt.shop         == "tan"                ) or
       ( passedt.shop         == "suntan"             ) or
       ( passedt.leisure      == "tanning_salon"      ) or
       ( passedt.shop         == "health_and_beauty"  ) or
       ( passedt.shop         == "beauty;hairdresser" )) then
      passedt.shop = "beauty"
   end

-- ----------------------------------------------------------------------------
-- "Non-electrical" electronics (i.e. ones for which the "electrical" icon
-- is inappropriate).
-- ----------------------------------------------------------------------------
   if (( passedt.shop  == "security"         ) or
       ( passedt.shop  == "survey"           ) or
       ( passedt.shop  == "survey_equipment" ) or       
       ( passedt.shop  == "hifi"             )) then
      passedt.shop = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- Computer
-- ----------------------------------------------------------------------------
   if ( passedt.shop  == "computer_repair" ) then
      passedt.shop = "computer"
   end

-- ----------------------------------------------------------------------------
-- Betting Shops etc.
-- ----------------------------------------------------------------------------
   if (( passedt.shop    == "betting"             ) or
       ( passedt.amenity == "betting"             ) or
       ( passedt.shop    == "gambling"            ) or
       ( passedt.amenity == "gambling"            ) or
       ( passedt.leisure == "gambling"            ) or
       ( passedt.shop    == "lottery"             ) or
       ( passedt.amenity == "lottery"             ) or
       ( passedt.shop    == "amusements"          ) or
       ( passedt.amenity == "amusements"          ) or
       ( passedt.amenity == "amusement"           ) or
       ( passedt.leisure == "amusement_arcade"    ) or
       ( passedt.leisure == "video_arcade"        ) or
       ( passedt.leisure == "adult_gaming_centre" ) or
       ( passedt.amenity == "casino"              )) then
      passedt.shop = "bookmaker"
   end

-- ----------------------------------------------------------------------------
-- mobile_phone shops 
-- ----------------------------------------------------------------------------
   if (( passedt.shop   == "phone"                    ) or
       ( passedt.shop   == "phone_repair"             ) or
       ( passedt.shop   == "telephone"                ) or
       ( passedt.shop   == "mobile_phone_repair"      ) or
       ( passedt.shop   == "mobile_phone_accessories" ) or
       ( passedt.shop   == "mobile_phone;e-cigarette" )) then
      passedt.shop = "mobile_phone"
   end

-- ----------------------------------------------------------------------------
-- gift and other tat shops
-- ----------------------------------------------------------------------------
   if (( passedt.shop   == "souvenir"            ) or
       ( passedt.shop   == "souvenirs"           ) or
       ( passedt.shop   == "leather"             ) or
       ( passedt.shop   == "luxury"              ) or
       ( passedt.shop   == "candle"              ) or
       ( passedt.shop   == "candles"             ) or
       ( passedt.shop   == "sunglasses"          ) or
       ( passedt.shop   == "tourist"             ) or
       ( passedt.shop   == "tourism"             ) or
       ( passedt.shop   == "bag"                 ) or
       ( passedt.shop   == "handbag"             ) or
       ( passedt.shop   == "handbags"            ) or
       ( passedt.shop   == "balloon"             ) or
       ( passedt.shop   == "accessories"         ) or
       ( passedt.shop   == "beach"               ) or
       ( passedt.shop   == "surf"                ) or
       ( passedt.shop   == "magic"               ) or
       ( passedt.shop   == "joke"                ) or
       ( passedt.shop   == "party"               ) or
       ( passedt.shop   == "party_goods"         ) or
       ( passedt.shop   == "christmas"           ) or
       ( passedt.shop   == "fashion_accessories" ) or
       ( passedt.shop   == "duty_free"           ) or
       ( passedt.shop   == "crystal"             ) or
       ( passedt.shop   == "crystal_glass"       ) or
       ( passedt.shop   == "crystals"            ) or
       ( passedt.shop   == "printing_stamps"     ) or
       ( passedt.shop   == "armour"              ) or
       ( passedt.shop   == "arts_and_crafts"     )) then
      passedt.shop = "gift"
   end

-- ----------------------------------------------------------------------------
-- Various alcohol shops
-- ----------------------------------------------------------------------------
   if (( passedt.shop    == "beer"            ) or
       ( passedt.shop    == "off_licence"     ) or
       ( passedt.shop    == "off_license"     ) or
       ( passedt.shop    == "wine"            ) or
       ( passedt.shop    == "whisky"          ) or
       ( passedt.craft   == "winery"          ) or
       ( passedt.shop    == "winery"          ) or
       ( passedt.tourism == "wine_cellar"     )) then
      passedt.shop = "alcohol"
   end

   if (( passedt.shop    == "sweets"          ) or
       ( passedt.shop    == "sweet"           )) then
      passedt.shop = "confectionery"
   end

-- ----------------------------------------------------------------------------
-- Show pastry shops as bakeries
-- ----------------------------------------------------------------------------
   if ( passedt.shop == "pastry" ) then
      passedt.shop = "bakery"
   end

-- ----------------------------------------------------------------------------
-- Fresh fish shops
-- ----------------------------------------------------------------------------
   if ( passedt.shop == "fish" ) then
      passedt.shop = "seafood"
   end

   if (( passedt.shop    == "camera"             ) or
       ( passedt.shop    == "photo_studio"       ) or
       ( passedt.shop    == "photography"        ) or
       ( passedt.office  == "photography"        ) or
       ( passedt.shop    == "photographic"       ) or
       ( passedt.shop    == "photographer"       ) or
       ( passedt.craft   == "photographer"       )) then
      passedt.shop = "photo"
   end

-- ----------------------------------------------------------------------------
-- Various "homeware" shops.  The icon for these is a generic "room interior".
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( passedt.shop   == "floor"                       ) or
       ( passedt.shop   == "flooring"                    ) or
       ( passedt.shop   == "floors"                      ) or
       ( passedt.shop   == "floor_covering"              ) or
       ( passedt.shop   == "homeware"                    ) or
       ( passedt.shop   == "homewares"                   ) or
       ( passedt.shop   == "home"                        ) or
       ( passedt.shop   == "carpet"                      ) or
       ( passedt.shop   == "carpet;bed"                  ) or
       ( passedt.shop   == "rugs"                        ) or
       ( passedt.shop   == "interior_decoration"         ) or
       ( passedt.shop   == "household"                   ) or
       ( passedt.shop   == "houseware"                   ) or
       ( passedt.shop   == "bathroom_furnishing"         ) or
       ( passedt.shop   == "paint"                       ) or
       ( passedt.shop   == "curtain"                     ) or
       ( passedt.shop   == "furnishings"                 ) or
       ( passedt.shop   == "furnishing"                  ) or
       ( passedt.shop   == "fireplace"                   ) or
       ( passedt.shop   == "lighting"                    ) or
       ( passedt.shop   == "blinds"                      ) or
       ( passedt.shop   == "window_blind"                ) or
       ( passedt.shop   == "kitchenware"                 ) or
       ( passedt.shop   == "interior_design"             ) or
       ( passedt.shop   == "interior"                    ) or
       ( passedt.shop   == "interiors"                   ) or
       ( passedt.shop   == "stoves"                      ) or
       ( passedt.shop   == "stove"                       ) or
       ( passedt.shop   == "tiles"                       ) or
       ( passedt.shop   == "tile"                        ) or
       ( passedt.shop   == "ceramics"                    ) or
       ( passedt.shop   == "windows"                     ) or
       ( passedt.craft  == "window_construction"         ) or
       ( passedt.shop   == "window_construction"         ) or
       ( passedt.shop   == "frame"                       ) or
       ( passedt.shop   == "framing"                     ) or
       ( passedt.shop   == "picture_framing"             ) or
       ( passedt.shop   == "picture_framer"              ) or
       ( passedt.craft  == "framing"                     ) or
       ( passedt.shop   == "frame;restoration"           ) or
       ( passedt.shop   == "bedding"                     ) or
       ( passedt.shop   == "cookware"                    ) or
       ( passedt.shop   == "glassware"                   ) or
       ( passedt.shop   == "cookery"                     ) or
       ( passedt.shop   == "catering_supplies"           ) or
       ( passedt.shop   == "catering_equipment"          ) or
       ( passedt.craft  == "upholsterer"                 ) or
       ( passedt.shop   == "doors"                       ) or
       ( passedt.shop   == "doors;glaziery"              ) or
       ( passedt.shop   == "mirrors"                     )) then
      passedt.landuse = "unnamedcommercial"
      passedt.shop = "homeware"
   end

-- ----------------------------------------------------------------------------
-- Other "homeware-like" shops.  These get the furniture icon.
-- Some are a bit of a stretch.
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( passedt.shop   == "upholsterer"                 ) or
       ( passedt.shop   == "chair"                       ) or
       ( passedt.shop   == "luggage"                     ) or
       ( passedt.shop   == "clock"                       ) or
       ( passedt.shop   == "clocks"                      ) or
       ( passedt.shop   == "home_improvement"            ) or
       ( passedt.shop   == "decorating"                  ) or
       ( passedt.shop   == "bed;carpet"                  ) or
       ( passedt.shop   == "country_store"               ) or
       ( passedt.shop   == "equestrian"                  ) or
       ( passedt.shop   == "kitchen"                     ) or
       ( passedt.shop   == "kitchen;bathroom"            ) or
       ( passedt.shop   == "kitchen;bathroom_furnishing" ) or
       ( passedt.shop   == "bedroom"                     ) or
       ( passedt.shop   == "bathroom"                    ) or
       ( passedt.shop   == "glaziery"                    ) or
       ( passedt.craft  == "glaziery"                    ) or
       ( passedt.shop   == "glazier"                     ) or
       ( passedt.shop   == "glazing"                     ) or
       ( passedt.shop   == "stone"                       ) or
       ( passedt.shop   == "brewing"                     ) or
       ( passedt.shop   == "brewing_supplies"            ) or
       ( passedt.shop   == "gates"                       ) or
       ( passedt.shop   == "sheds"                       ) or
       ( passedt.shop   == "shed"                        ) or
       ( passedt.shop   == "ironmonger"                  ) or
       ( passedt.shop   == "furnace"                     ) or
       ( passedt.shop   == "plumbing"                    ) or
       ( passedt.shop   == "plumbing_supplies"           ) or
       ( passedt.craft  == "plumber"                     ) or
       ( passedt.craft  == "carpenter"                   ) or
       ( passedt.shop   == "carpenter"                   ) or
       ( passedt.craft  == "decorator"                   ) or
       ( passedt.shop   == "bed"                         ) or
       ( passedt.shop   == "mattress"                    ) or
       ( passedt.shop   == "waterbed"                    ) or
       ( passedt.shop   == "glass"                       ) or
       ( passedt.shop   == "garage"                      ) or
       ( passedt.shop   == "conservatory"                ) or
       ( passedt.shop   == "conservatories"              ) or
       ( passedt.shop   == "bathrooms"                   ) or
       ( passedt.shop   == "swimming_pool"               ) or
       ( passedt.shop   == "fitted_furniture"            ) or
       ( passedt.shop   == "upholstery"                  ) or
       ( passedt.shop   == "saddlery"                    )) then
      passedt.landuse = "unnamedcommercial"
      passedt.shop = "furniture"
   end

-- ----------------------------------------------------------------------------
-- Shops that sell coffee etc.
-- ----------------------------------------------------------------------------
   if (( passedt.shop    == "beverages"       ) or
       ( passedt.shop    == "coffee"          ) or
       ( passedt.shop    == "tea"             )) then
      passedt.shop = "coffee"
   end

-- ----------------------------------------------------------------------------
-- Copyshops
-- ----------------------------------------------------------------------------
   if (( passedt.shop    == "printing"       ) or
       ( passedt.shop    == "print"          ) or
       ( passedt.shop    == "printer"        )) then
      passedt.shop = "copyshop"
      passedt.amenity = nil
      passedt.craft = nil
      passedt.office = nil
   end

-- ----------------------------------------------------------------------------
-- This category used to be larger, but the values have been consolidated.
-- Difficult to do an icon for.
-- ----------------------------------------------------------------------------
   if ( passedt.shop    == "printer_ink" ) then
      passedt.shop = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- Various single food item and other food shops
-- Unnamed egg honesty boxes have been dealt with above.
-- ----------------------------------------------------------------------------
   if (( passedt.shop    == "cake"            ) or
       ( passedt.shop    == "chocolate"       ) or
       ( passedt.shop    == "milk"            ) or
       ( passedt.shop    == "cheese"          ) or
       ( passedt.shop    == "cheese;wine"     ) or
       ( passedt.shop    == "wine;cheese"     ) or
       ( passedt.shop    == "dairy"           ) or
       ( passedt.shop    == "eggs"            ) or
       ( passedt.shop    == "honey"           ) or
       ( passedt.shop    == "catering"        ) or
       ( passedt.shop    == "fishmonger"      ) or
       ( passedt.shop    == "spices"          ) or
       ( passedt.shop    == "nuts"            ) or
       ( passedt.shop    == "patisserie"      )) then
      passedt.shop = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- fabric and wool etc.
-- ----------------------------------------------------------------------------
   if (( passedt.shop   == "fabric"               ) or
       ( passedt.shop   == "linen"                ) or
       ( passedt.shop   == "household_linen"      ) or
       ( passedt.shop   == "linens"               ) or
       ( passedt.shop   == "haberdashery"         ) or
       ( passedt.shop   == "sewing"               ) or
       ( passedt.shop   == "needlecraft"          ) or
       ( passedt.shop   == "embroidery"           ) or
       ( passedt.shop   == "knitting"             ) or
       ( passedt.shop   == "wool"                 ) or
       ( passedt.shop   == "yarn"                 ) or
       ( passedt.shop   == "alteration"           ) or
       ( passedt.shop   == "textiles"             ) or
       ( passedt.shop   == "clothing_alterations" ) or
       ( passedt.craft  == "embroiderer"          )) then
      passedt.shop = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- health_food etc., and also "non-medical medical" and "woo" shops.
-- ----------------------------------------------------------------------------
   if (( passedt.shop       == "health_food"             ) or
       ( passedt.shop       == "health"                  ) or
       ( passedt.shop       == "organic"                 ) or
       ( passedt.shop       == "supplements"             ) or
       ( passedt.shop       == "nutrition_supplements"   ) or
       ( passedt.shop       == "dietary_supplements"     ) or
       ( passedt.shop       == "healthcare"              ) or
       ( passedt.shop       == "wellness"                ) or
       ( passedt.name       == "Holland and Barrett"     )) then
      if (( passedt.zero_waste         == "yes"                )  or
          ( passedt.zero_waste         == "only"               )  or
          ( passedt.bulk_purchase      == "yes"                )  or
          ( passedt.bulk_purchase      == "only"               )  or
          ( passedt.reusable_packaging == "yes"                )) then
         passedt.shop = "ecohealth_food"
      else
         passedt.shop = "health_food"
      end
   end

   if (( passedt.shop       == "alternative_medicine"    ) or
       ( passedt.shop       == "massage"                 ) or
       ( passedt.shop       == "herbalist"               ) or
       ( passedt.shop       == "herbal_medicine"         ) or
       ( passedt.shop       == "chinese_medicine"        ) or
       ( passedt.shop       == "new_age"                 ) or
       ( passedt.shop       == "psychic"                 ) or
       ( passedt.shop       == "alternative_health"      ) or
       ( passedt.healthcare == "alternative"             ) or
       ( passedt.shop       == "acupuncture"             ) or
       ( passedt.healthcare == "acupuncture"             ) or
       ( passedt.shop       == "aromatherapy"            ) or
       ( passedt.shop       == "meditation"              ) or
       ( passedt.shop       == "esoteric"                )) then
      passedt.shop = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- travel agents
-- the name is usually characteristic
-- ----------------------------------------------------------------------------
   if (( passedt.office == "travel_agent"  ) or
       ( passedt.shop   == "travel_agency" ) or
       ( passedt.shop   == "travel"        )) then
      passedt.shop = "travel_agent"
   end

-- ----------------------------------------------------------------------------
-- books and stationery
-- the name is often characteristic
-- ----------------------------------------------------------------------------
   if (( passedt.shop   == "comics"          ) or
       ( passedt.shop   == "comic"           ) or
       ( passedt.shop   == "anime"           ) or
       ( passedt.shop   == "maps"            ) or
       ( passedt.shop   == "books;music"     )) then
      passedt.shop = "books"
   end

   if ( passedt.shop   == "office_supplies" ) then
      passedt.shop = "stationery"
   end

-- ----------------------------------------------------------------------------
-- toys and games etc.
-- ----------------------------------------------------------------------------
   if (( passedt.shop   == "model"          ) or
       ( passedt.shop   == "games"          ) or
       ( passedt.shop   == "computer_games" ) or
       ( passedt.shop   == "video_games"    ) or
       ( passedt.shop   == "hobby"          ) or
       ( passedt.shop   == "fancy_dress"    )) then
      passedt.shop = "toys"
   end

-- ----------------------------------------------------------------------------
-- Art etc.
-- ----------------------------------------------------------------------------
   if (( passedt.shop   == "craft"          ) or
       ( passedt.shop   == "art_supplies"   ) or
       ( passedt.shop   == "pottery"        ) or
       ( passedt.shop   == "art;frame"      ) or
       ( passedt.craft  == "artist"         ) or
       ( passedt.craft  == "pottery"        ) or
       ( passedt.craft  == "sculptor"       )) then
      passedt.shop  = "art"
      passedt.craft = nil
   end

-- ----------------------------------------------------------------------------
-- Treat "agricultural" as "agrarian"
-- "agrarian" is then further categories below based on other tags
-- ----------------------------------------------------------------------------
   if ( passedt.shop == "agricultural" ) then
      passedt.shop = "agrarian"
   end

-- ----------------------------------------------------------------------------
-- pets and pet services
-- Normally the names are punningly characteristic (e.g. "Bark-in-Style" 
-- dog grooming).
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( passedt.shop    == "pet;garden"              ) or
       ( passedt.shop    == "aquatic"                 ) or
       ( passedt.shop    == "aquatics"                ) or
       ( passedt.shop    == "aquarium"                ) or
       ( passedt.shop    == "pet;corn"                )) then
      passedt.landuse = "unnamedcommercial"
      passedt.shop = "pet"
   end

-- ----------------------------------------------------------------------------
-- Pet and animal food
-- ----------------------------------------------------------------------------
   if (((  passedt.shop     == "agrarian"                        )  and
        (( passedt.agrarian == "feed"                           )  or
         ( passedt.agrarian == "yes"                            )  or
         ( passedt.agrarian == "feed;fertilizer;seed;pesticide" )  or
         ( passedt.agrarian == "feed;seed"                      )  or
         ( passedt.agrarian == "feed;pesticide;seed"            )  or
         ( passedt.agrarian == "feed;tools"                     )  or
         ( passedt.agrarian == "feed;tools;fuel;firewood"       ))) or
       ( passedt.shop    == "pet_supplies"            ) or
       ( passedt.shop    == "pet_care"                ) or
       ( passedt.shop    == "pet_food"                ) or
       ( passedt.shop    == "animal_feed"             )) then
      passedt.landuse = "unnamedcommercial"
      passedt.shop = "pet_food"
   end

-- ----------------------------------------------------------------------------
-- Pet grooming
-- ----------------------------------------------------------------------------
   if (( passedt.shop    == "pet_grooming"            ) or
       ( passedt.shop    == "dog_grooming"            ) or
       ( passedt.amenity == "dog_grooming"            ) or
       ( passedt.craft   == "dog_grooming"            ) or
       ( passedt.animal  == "wellness"                )) then
      passedt.landuse = "unnamedcommercial"
      passedt.shop = "pet_grooming"
   end

-- ----------------------------------------------------------------------------
-- amenity=veterinary goes through as is
-- ----------------------------------------------------------------------------
   if ( passedt.shop == "veterinary" ) then
      passedt.amenity = "veterinary"
   end

-- ----------------------------------------------------------------------------
-- Animal boarding
-- ----------------------------------------------------------------------------
   if (( passedt.amenity == "animal_boarding"         ) or
       ( passedt.amenity == "cattery"                 ) or
       ( passedt.amenity == "kennels"                 )) then
      passedt.landuse = "unnamedcommercial"
      passedt.amenity = "animal_boarding"
   end

-- ----------------------------------------------------------------------------
-- Animal shelters
-- ----------------------------------------------------------------------------
   if (( passedt.amenity == "animal_shelter"          ) or
       ( passedt.animal  == "shelter"                 )) then
      passedt.landuse = "unnamedcommercial"
      passedt.amenity = "animal_shelter"
   end

-- ----------------------------------------------------------------------------
-- Car parts
-- ----------------------------------------------------------------------------
   if ((( passedt.shop    == "trade"                       )  and
        ( passedt.trade   == "car_parts"                   )) or
       (  passedt.shop    == "car_accessories"              )  or
       (  passedt.shop    == "tyres"                        )  or
       (  passedt.shop    == "automotive"                   )  or
       (  passedt.shop    == "battery"                      )  or
       (  passedt.shop    == "batteries"                    )  or
       (  passedt.shop    == "number_plate"                 )  or
       (  passedt.shop    == "number_plates"                )  or
       (  passedt.shop    == "license_plates"               )  or
       (  passedt.shop    == "car_audio"                    )  or
       (  passedt.shop    == "motor"                        )  or
       (  passedt.shop    == "motor_spares"                 )  or
       (  passedt.shop    == "motor_accessories"            )  or
       (  passedt.shop    == "car_parts;car_repair"         )  or
       (  passedt.shop    == "bicycle;car_parts"            )  or
       (  passedt.shop    == "car_parts;bicycle"            )) then
      passedt.shop = "car_parts"
   end

-- ----------------------------------------------------------------------------
-- Shopmobility
-- Note that "shop=mobility" is something that _sells_ mobility aids, and is
-- handled as shop=nonspecific for now.
-- We handle some specific cases of shop=mobility here; the rest below.
-- ----------------------------------------------------------------------------
   if ((   passedt.amenity  == "mobility"                 ) or
       (   passedt.amenity  == "mobility_equipment_hire"  ) or
       (   passedt.amenity  == "mobility_aids_hire"       ) or
       (   passedt.amenity  == "shop_mobility"            ) or
       ((  passedt.amenity  == "social_facility"         )  and
        (  passedt.social_facility == "shopmobility"     )) or
       ((( passedt.shop     == "yes"                    )   or
         ( passedt.shop     == "mobility"               )   or
         ( passedt.shop     == "mobility_hire"          )   or
         ( passedt.building == "yes"                    )   or
         ( passedt.building == "unit"                   ))  and
        (( passedt.name     == "Shopmobility"           )   or
         ( passedt.name     == "Shop Mobility"          )))) then
      passedt.landuse = "unnamedcommercial"
      passedt.amenity = "shopmobility"
   end

-- ----------------------------------------------------------------------------
-- Music
-- ----------------------------------------------------------------------------
   if (( passedt.shop    == "music;video"             ) or
       ( passedt.shop    == "records"                 ) or
       ( passedt.shop    == "record"                  )) then
      passedt.shop = "music"
   end

-- ----------------------------------------------------------------------------
-- Motorcycle
-- ----------------------------------------------------------------------------
   if (( passedt.shop    == "motorcycle_repair"            ) or
       ( passedt.shop    == "motorcycle_parts"             ) or
       ( passedt.amenity == "motorcycle_rental"            ) or
       ( passedt.shop    == "atv"                          ) or
       ( passedt.shop    == "scooter"                      )) then
      passedt.shop = "motorcycle"
   end

-- ----------------------------------------------------------------------------
-- Tattoo
-- ----------------------------------------------------------------------------
   if (( passedt.shop    == "piercing"                ) or
       ( passedt.shop    == "tattoo;piercing"         ) or
       ( passedt.shop    == "piercing;tattoo"         ) or
       ( passedt.shop    == "body_piercing"           ) or
       ( passedt.shop    == "yes;piercing"            ) or
       ( passedt.shop    == "piercings"               )) then
      passedt.shop = "tattoo"
   end

-- ----------------------------------------------------------------------------
-- Musical Instrument
-- ----------------------------------------------------------------------------
   if ( passedt.shop    == "piano" ) then
      passedt.shop = "musical_instrument"
   end

-- ----------------------------------------------------------------------------
-- Extract ski shops as outdoor shops
-- ----------------------------------------------------------------------------
   if ( passedt.shop == "ski" ) then
      passedt.shop = "outdoor"
   end

-- ----------------------------------------------------------------------------
-- Locksmith
-- ----------------------------------------------------------------------------
   if ( passedt.craft == "locksmith" ) then
      passedt.shop = "locksmith"
   end

-- ----------------------------------------------------------------------------
-- Storage Rental
-- ----------------------------------------------------------------------------
   if (( passedt.amenity == "storage"              ) or
       ( passedt.amenity == "self_storage"         ) or
       ( passedt.office  == "storage_rental"       ) or
       ( passedt.shop    == "storage"              )) then
      passedt.shop = "storage_rental"
   end

-- ----------------------------------------------------------------------------
-- car and van rental.
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( passedt.amenity == "car_rental"                   ) or
       ( passedt.amenity == "van_rental"                   ) or
       ( passedt.amenity == "car_rental;bicycle_rental"    ) or
       ( passedt.shop    == "car_rental"                   ) or
       ( passedt.shop    == "van_rental"                   )) then
      passedt.landuse = "unnamedcommercial"
      passedt.amenity    = "car_rental"
   end

-- ----------------------------------------------------------------------------
-- Nonspecific car and related shops.
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( passedt.shop    == "caravan"                      ) or
       ( passedt.shop    == "motorhome"                    ) or
       ( passedt.shop    == "boat"                         ) or
       ( passedt.shop    == "truck"                        ) or
       ( passedt.shop    == "commercial_vehicles"          ) or
       ( passedt.shop    == "commercial_vehicle"           ) or
       ( passedt.shop    == "agricultural_vehicles"        ) or
       ((  passedt.shop    == "agrarian"                                           ) and
        (( passedt.agrarian == "agricultural_machinery"                           )  or
         ( passedt.agrarian == "machine_parts;agricultural_machinery;tools"       )  or
         ( passedt.agrarian == "agricultural_machinery;machine_parts;tools"       )  or
         ( passedt.agrarian == "agricultural_machinery;feed"                      )  or
         ( passedt.agrarian == "agricultural_machinery;machine_parts;tools;signs" )  or
         ( passedt.agrarian == "agricultural_machinery;machine_parts"             )  or
         ( passedt.agrarian == "agricultural_machinery;seed"                      )  or
         ( passedt.agrarian == "machine_parts;agricultural_machinery"             ))) or
       ( passedt.shop    == "tractor"                      ) or
       ( passedt.shop    == "tractors"                     ) or
       ( passedt.shop    == "tractor_repair"               ) or
       ( passedt.shop    == "tractor_parts"                ) or
       ( passedt.shop    == "van"                          ) or
       ( passedt.shop    == "truck_repair"                 ) or
       ( passedt.industrial == "truck_repair"              ) or
       ( passedt.shop    == "forklift_repair"              ) or
       ( passedt.shop    == "trailer"                      ) or
       ( passedt.amenity == "driving_school"               ) or
       ( passedt.shop    == "chandler"                     ) or
       ( passedt.shop    == "chandlery"                    ) or
       ( passedt.shop    == "ship_chandler"                ) or
       ( passedt.craft   == "boatbuilder"                  ) or
       ( passedt.shop    == "marine"                       ) or
       ( passedt.shop    == "boat_repair"                  )) then
      passedt.landuse = "unnamedcommercial"
      passedt.shop    = "shopnonspecific"
   end

-- ----------------------------------------------------------------------------
-- Timpson and similar shops.
-- Timpson is brand:wikidata=Q7807658, but all of those are name=Timpson.
-- ----------------------------------------------------------------------------
   if (( passedt.shop    == "shoe_repair"                        ) or
       ( passedt.shop    == "keys"                               ) or
       ( passedt.shop    == "key"                                ) or
       ( passedt.shop    == "cobblers"                           ) or
       ( passedt.shop    == "cobbler"                            ) or
       ( passedt.shop    == "key_cutting"                        ) or
       ( passedt.shop    == "key_cutting;shoe_repair"            ) or
       ( passedt.shop    == "shoe_repair;key_cutting"            ) or
       ( passedt.shop    == "locksmith;dry_cleaning;shoe_repair" ) or
       ( passedt.craft   == "key_cutter"                         ) or
       ( passedt.shop    == "key_cutter"                         ) or
       ( passedt.craft   == "shoe_repair"                        ) or
       ( passedt.craft   == "key_cutter;shoe_repair"             )) then
      passedt.landuse = "unnamedcommercial"
      passedt.shop    = "shoe_repair_etc"
   end

-- ----------------------------------------------------------------------------
-- Taxi offices
-- ----------------------------------------------------------------------------
   if (( passedt.shop    == "taxi"                    ) or
       ( passedt.office  == "taxi"                    ) or
       ( passedt.office  == "minicab"                 ) or
       ( passedt.shop    == "minicab"                 ) or
       ( passedt.amenity == "minicab"                 )) then
      passedt.landuse = "unnamedcommercial"
      passedt.amenity = "taxi_office"
      passedt.shop    = nil
      passedt.office  = nil
   end

-- ----------------------------------------------------------------------------
-- Other shops that don't have a specific icon are handled here. including
-- variations.
--
-- Shops are in this list either because they tend to have a characteristic
-- name (e.g. the various card shops), they're difficult to do an icon for
-- or they're rare.
--
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( passedt.shop    == "card"                    ) or
       ( passedt.shop    == "cards"                   ) or
       ( passedt.shop    == "greeting_card"           ) or
       ( passedt.shop    == "greeting_cards"          ) or
       ( passedt.shop    == "greetings_cards"         ) or
       ( passedt.shop    == "greetings"               ) or
       ( passedt.shop    == "card;gift"               ) or
       ( passedt.craft   == "cobbler"                 ) or
       ( passedt.craft   == "shoemaker"               ) or
       ( passedt.shop    == "shoemaker"               ) or
       ( passedt.shop    == "watch_repair"            ) or
       ( passedt.shop    == "cleaning"                ) or
       ( passedt.shop    == "collector"               ) or
       ( passedt.shop    == "coins"                   ) or
       ( passedt.shop    == "video"                   ) or
       ( passedt.shop    == "audio_video"             ) or
       ( passedt.shop    == "erotic"                  ) or
       ( passedt.shop    == "service"                 ) or
       ( passedt.shop    == "tobacco"                 ) or
       ( passedt.shop    == "tobacco;e-cigarette"     ) or
       ( passedt.shop    == "tobacconist"             ) or
       ( passedt.shop    == "ticket"                  ) or
       ( passedt.shop    == "insurance"               ) or
       ( passedt.shop    == "gallery"                 ) or
       ( passedt.tourism == "gallery"                 ) or
       ( passedt.amenity == "gallery"                 ) or
       ( passedt.amenity == "art_gallery"             ) or
       ( passedt.shop    == "plumber"                 ) or
       ( passedt.shop    == "builder"                 ) or
       ( passedt.shop    == "builders"                ) or
       ( passedt.shop    == "trophy"                  ) or
       ( passedt.shop    == "communication"           ) or
       ( passedt.shop    == "communications"          ) or
       ( passedt.shop    == "internet"                ) or
       ( passedt.amenity == "internet_cafe"           ) or
       ( passedt.shop    == "internet_cafe"           ) or
       ( passedt.shop    == "recycling"               ) or
       ( passedt.shop    == "gun"                     ) or
       ( passedt.craft   == "gunsmith"                ) or
       ( passedt.shop    == "weapons"                 ) or
       ( passedt.shop    == "pyrotechnics"            ) or
       ( passedt.shop    == "hunting"                 ) or
       ( passedt.shop    == "military_surplus"        ) or
       ( passedt.shop    == "fireworks"               ) or
       ( passedt.shop    == "auction"                 ) or
       ( passedt.shop    == "auction_house"           ) or
       ( passedt.shop    == "auctioneer"              ) or
       ( passedt.office  == "auctioneer"              ) or
       ( passedt.shop    == "livestock"               ) or
       ( passedt.shop    == "religion"                ) or
       ( passedt.shop    == "gas"                     ) or
       ( passedt.shop    == "fuel"                    ) or
       ( passedt.shop    == "energy"                  ) or
       ( passedt.shop    == "coal_merchant"           ) or
       ( passedt.amenity == "training"                ) or
       ((( passedt.amenity  == nil                  )   or
         ( passedt.amenity  == ""                   ))  and
        (( passedt.training == "dance"              )   or
         ( passedt.training == "language"           )   or
         ( passedt.training == "performing_arts"    ))) or
       ( passedt.amenity == "tutoring_centre"         ) or
       ( passedt.office  == "tutoring"                ) or
       ( passedt.shop    == "education"               ) or
       ( passedt.shop    == "ironing"                 ) or
       ( passedt.amenity == "stripclub"               ) or
       ( passedt.amenity == "courier"                 ) or
       ( passedt.shop    == "safety_equipment"        )) then
      passedt.landuse = "unnamedcommercial"
      passedt.shop = "shopnonspecific"
   end

   if (( passedt.shop    == "launderette"             ) or
       ( passedt.shop    == "dry_cleaning"            ) or
       ( passedt.shop    == "dry_cleaning;laundry"    ) or
       ( passedt.shop    == "laundry;dry_cleaning"    )) then
      passedt.landuse = "unnamedcommercial"
      passedt.shop = "laundry"
   end

-- ----------------------------------------------------------------------------
-- Stonemasons etc.
-- ----------------------------------------------------------------------------
   if (( passedt.craft   == "stonemason"        ) or
       ( passedt.shop    == "gravestone"        ) or
       ( passedt.shop    == "monumental_mason"  ) or
       ( passedt.shop    == "memorials"         )) then
      passedt.landuse = "unnamedcommercial"
      passedt.shop    = "funeral_directors"
   end

-- ----------------------------------------------------------------------------
-- Specific handling for incompletely tagged "Howdens".
-- Unfortunately there are a few of these.
-- ----------------------------------------------------------------------------
   if ((( passedt.name     == "Howdens"             )  or
        ( passedt.name     == "Howdens Joinery"     )  or
        ( passedt.name     == "Howdens Joinery Co"  )  or
        ( passedt.name     == "Howdens Joinery Co." )  or
        ( passedt.name     == "Howdens Joinery Ltd" )) and
       (( passedt.shop     == nil                   )  or
        ( passedt.shop     == ""                    )) and
       (( passedt.craft    == nil                   )  or
        ( passedt.craft    == ""                    )) and
       (( passedt.highway  == nil                   )  or
        ( passedt.highway  == ""                    )) and
       (( passedt.landuse  == nil                   )  or
        ( passedt.landuse  == ""                    )) and
       (( passedt.man_made == nil                   )  or
        ( passedt.man_made == ""                    ))) then
      passedt.shop = "trade"
   end

-- ----------------------------------------------------------------------------
-- Shops that we don't know the type of.  Things such as "hire" are here 
-- because we don't know "hire of what".
-- "wood" is here because it's used for different sorts of shops.
-- ----------------------------------------------------------------------------
   if (( passedt.shop    == "yes"                ) or
       ( passedt.craft   == "yes"                ) or
       ( passedt.shop    == "other"              ) or
       ( passedt.shop    == "hire"               ) or
       ( passedt.shop    == "rental"             ) or
       ( passedt.office  == "rental"             ) or
       ( passedt.amenity == "rental"             ) or
       ( passedt.shop    == "second_hand"        ) or
       ( passedt.shop    == "junk"               ) or
       ( passedt.shop    == "general"            ) or
       ( passedt.shop    == "general_store"      ) or
       ( passedt.shop    == "retail"             ) or
       ( passedt.shop    == "trade"              ) or
       ( passedt.shop    == "cash_and_carry"     ) or
       ( passedt.shop    == "fixme"              ) or
       ( passedt.shop    == "wholesale"          ) or
       ( passedt.shop    == "wood"               ) or
       ( passedt.shop    == "childrens"          ) or
       ( passedt.shop    == "factory_outlet"     ) or
       ( passedt.shop    == "specialist"         ) or
       ( passedt.shop    == "specialist_shop"    ) or
       ( passedt.shop    == "agrarian"           ) or
       ( passedt.shop    == "hairdresser_supply" ) or
       ( passedt.shop    == "repair"             ) or
       ( passedt.shop    == "packaging"          ) or
       ( passedt.shop    == "telecommunication"  ) or
       ( passedt.shop    == "cannabis"           ) or
       ( passedt.shop    == "hydroponics"        ) or
       ( passedt.shop    == "headshop"           ) or
       ( passedt.shop    == "skate"              ) or
       ( passedt.shop    == "ethnic"             )) then
      passedt.landuse = "unnamedcommercial"
      passedt.shop    = "shopnonspecific"
   end

   if (( passedt.amenity     == "optician"                     ) or
       ( passedt.craft       == "optician"                     ) or
       ( passedt.office      == "optician"                     ) or
       ( passedt.shop        == "optometrist"                  ) or
       ( passedt.amenity     == "optometrist"                  ) or
       ( passedt.healthcare  == "optometrist"                  )) then
      passedt.landuse = "unnamedcommercial"
      passedt.shop    = "optician"
   end

-- ----------------------------------------------------------------------------
-- chiropodists etc. - render as "nonspecific health".
-- Add unnamedcommercial landuse to give non-building areas a background.
--
-- Places that _sell_ mobility aids are in here.  Shopmobility handled
-- seperately.
-- ----------------------------------------------------------------------------
   if (( passedt.shop        == "hearing_aids"                 ) or
       ( passedt.healthcare  == "hearing_care"                 ) or
       ( passedt.shop        == "medical_supply"               ) or
       ( passedt.office      == "medical_supply"               ) or
       ( passedt.shop        == "mobility"                     ) or
       ( passedt.shop        == "mobility_scooter"             ) or
       ( passedt.shop        == "wheelchair"                   ) or
       ( passedt.shop        == "mobility_aids"                ) or
       ( passedt.shop        == "disability"                   ) or
       ( passedt.shop        == "chiropodist"                  ) or
       ( passedt.amenity     == "chiropodist"                  ) or
       ( passedt.healthcare  == "chiropodist"                  ) or
       ( passedt.amenity     == "chiropractor"                 ) or
       ( passedt.healthcare  == "chiropractor"                 ) or
       ( passedt.healthcare  == "department"                   ) or
       ( passedt.healthcare  == "diagnostics"                  ) or
       ( passedt.healthcare  == "dialysis"                     ) or
       ( passedt.shop        == "osteopath"                    ) or
       ( passedt.office      == "osteopath"                    ) or
       ( passedt.amenity     == "physiotherapist"              ) or
       ( passedt.healthcare  == "physiotherapist"              ) or
       ( passedt.healthcare  == "physiotherapist;podiatrist"   ) or
       ( passedt.shop        == "physiotherapist"              ) or
       ( passedt.healthcare  == "physiotherapy"                ) or
       ( passedt.shop        == "physiotherapy"                ) or
       ( passedt.healthcare  == "psychotherapist"              ) or
       ( passedt.healthcare  == "therapy"                      ) or
       ( passedt.healthcare  == "podiatrist"                   ) or
       ( passedt.healthcare  == "podiatrist;chiropodist"       ) or
       ( passedt.amenity     == "podiatrist"                   ) or
       ( passedt.healthcare  == "podiatry"                     ) or
       ( passedt.amenity     == "healthcare"                   ) or
       ( passedt.amenity     == "clinic"                       ) or
       ( passedt.healthcare  == "clinic"                       ) or
       ( passedt.healthcare  == "clinic;doctor"                ) or
       ( passedt.shop        == "clinic"                       ) or
       ( passedt.amenity     == "social_facility"              ) or
       ((( passedt.amenity         == nil                    )   or
         ( passedt.amenity         == ""                     ))  and
        (( passedt.social_facility == "group_home"           )   or
         ( passedt.social_facility == "nursing_home"         )   or
         ( passedt.social_facility == "assisted_living"      )   or
         ( passedt.social_facility == "care_home"            )   or
         ( passedt.social_facility == "shelter"              )   or
         ( passedt.social_facility == "day_care"             )   or
         ( passedt.social_facility == "day_centre"           )   or
         ( passedt.social_facility == "residential_home"     ))) or
       ( passedt.amenity     == "nursing_home"                 ) or
       ( passedt.healthcare  == "nursing_home"                 ) or
       ( passedt.residential == "nursing_home"                 ) or
       ( passedt.building    == "nursing_home"                 ) or
       ( passedt.amenity     == "care_home"                    ) or
       ( passedt.residential == "care_home"                    ) or
       ( passedt.amenity     == "retirement_home"              ) or
       ( passedt.amenity     == "residential_home"             ) or
       ( passedt.residential == "residential_home"             ) or
       ( passedt.amenity     == "sheltered_housing"            ) or
       ( passedt.residential == "sheltered_housing"            ) or
       ( passedt.amenity     == "childcare"                    ) or
       ( passedt.amenity     == "childrens_centre"             ) or
       ( passedt.amenity     == "preschool"                    ) or
       ( passedt.building    == "preschool"                    ) or
       ( passedt.amenity     == "nursery"                      ) or
       ( passedt.amenity     == "nursery_school"               ) or
       ( passedt.amenity     == "health_centre"                ) or
       ( passedt.healthcare  == "health_centre"                ) or
       ( passedt.building    == "health_centre"                ) or
       ( passedt.amenity     == "medical_centre"               ) or
       ( passedt.building    == "medical_centre"               ) or
       ( passedt.healthcare  == "centre"                       ) or
       ( passedt.healthcare  == "counselling"                  ) or
       ( passedt.craft       == "counsellor"                   ) or
       ( passedt.amenity     == "hospice"                      ) or
       ( passedt.healthcare  == "hospice"                      ) or
       ( passedt.healthcare  == "cosmetic"                     ) or
       ( passedt.healthcare  == "cosmetic_surgery"             ) or
       ( passedt.healthcare  == "dentures"                     ) or
       ( passedt.shop        == "dentures"                     ) or
       ( passedt.shop        == "denture"                      ) or
       ( passedt.healthcare  == "blood_donation"               ) or
       ( passedt.healthcare  == "blood_bank"                   ) or
       ( passedt.healthcare  == "sports_massage_therapist"     ) or
       ( passedt.healthcare  == "massage"                      ) or
       ( passedt.healthcare  == "rehabilitation"               ) or
       ( passedt.healthcare  == "drug_rehabilitation"          ) or
       ( passedt.healthcare  == "medical_imaging"              ) or
       ( passedt.healthcare  == "midwife"                      ) or
       ( passedt.healthcare  == "occupational_therapist"       ) or
       ( passedt.healthcare  == "speech_therapist"             ) or
       ( passedt.healthcare  == "tattoo_removal"               ) or
       ( passedt.healthcare  == "trichologist"                 ) or
       ( passedt.healthcare  == "ocular_prosthetics"           ) or
       ( passedt.healthcare  == "audiologist"                  ) or
       ( passedt.shop        == "audiologist"                  ) or
       ( passedt.healthcare  == "hearing"                      ) or
       ( passedt.healthcare  == "mental_health"                ) or
       ( passedt.amenity     == "daycare"                      )) then
      passedt.landuse = "unnamedcommercial"
      passedt.shop    = "healthnonspecific"
   end

-- ----------------------------------------------------------------------------
-- Defibrillators etc.
-- Move these to the "amenity" key to reduce the code needed to render them.
-- Ones with an non-public, non-yes access value will be rendered less opaque,
-- like other private items such as car parks.
-- ----------------------------------------------------------------------------
   if ( passedt.emergency == "defibrillator" ) then
      passedt.amenity = "defibrillator"
      if ( passedt.indoor == "yes" ) then
         passedt.access = "customers"
      end
   end

   if ((  passedt.emergency        == "life_ring"         ) or
       (  passedt.emergency        == "lifevest"          ) or
       (  passedt.emergency        == "flotation device"  ) or
       (( passedt.emergency        == "rescue_equipment" )  and
        ( passedt.rescue_equipment == "lifering"         ))) then
      passedt.amenity = "life_ring"
   end

   if ( passedt.emergency == "fire_extinguisher" ) then
      passedt.amenity = "fire_extinguisher"
   end

   if ( passedt.emergency == "fire_hydrant" ) then
      passedt.amenity = "fire_hydrant"
   end

-- ----------------------------------------------------------------------------
-- Consolidate various emergency access points.
-- A ref ot "(E)" is set if no ref exists.
-- ----------------------------------------------------------------------------
   if ((( passedt.emergency == "access_point"           )  or
        ( passedt.highway   == "emergency_access_point" )) and
       (( passedt.barrier == nil                        )  or
        ( passedt.barrier == ""                         )) and
       (( passedt.tourism == nil                        )  or
        ( passedt.tourism == ""                         ))) then
      passedt.amenity = "emergency_access_point"
      passedt.name = passedt.ref

      if (( passedt.name ~= nil ) and
          ( passedt.name ~= ""  )) then
         passedt.name = "(E)"
      end
   end

-- ----------------------------------------------------------------------------
-- Craft cider
-- Also remove tourism tag (we want to display brewery in preference to
-- attraction or museum).
-- ----------------------------------------------------------------------------
   if ((  passedt.craft   == "cider"    ) or
       (( passedt.craft   == "brewery" )  and
        ( passedt.product == "cider"   ))) then
      passedt.landuse = "unnamedcommercial"
      passedt.office  = "craftcider"
      passedt.craft  = nil
      passedt.tourism  = nil
   end

-- ----------------------------------------------------------------------------
-- Craft breweries
-- Also remove tourism tag (we want to display brewery in preference to
-- attraction or museum).
-- ----------------------------------------------------------------------------
   if (( passedt.craft == "brewery"       ) or
       ( passedt.craft == "brewery;cider" )) then
      passedt.landuse = "unnamedcommercial"
      passedt.office  = "craftbrewery"
      passedt.craft  = nil
      passedt.tourism  = nil
   end

-- ----------------------------------------------------------------------------
-- Various "printer" offices
-- ----------------------------------------------------------------------------
   if (( passedt.shop    == "printers"          ) or
       ( passedt.amenity == "printer"           ) or
       ( passedt.craft   == "printer"           ) or
       ( passedt.office  == "printer"           ) or
       ( passedt.office  == "design"            ) or
       ( passedt.craft   == "printmaker"        ) or
       ( passedt.craft   == "print_shop"        )) then
      passedt.landuse = "unnamedcommercial"
      passedt.office  = "nonspecific"
   end

-- ----------------------------------------------------------------------------
-- Various crafts that should appear as at least a nonspecific office.
-- ----------------------------------------------------------------------------
   if ((( passedt.amenity == nil                       )   or
        ( passedt.amenity == ""                        ))  and
       (( passedt.shop    == nil                       )   or
        ( passedt.shop    == ""                        ))  and
       (( passedt.tourism == nil                       )   or
        ( passedt.tourism == ""                        ))  and
       (( passedt.craft   == "agricultural_engines"    )   or
        ( passedt.craft   == "atelier"                 )   or
        ( passedt.craft   == "blacksmith"              )   or
        ( passedt.craft   == "beekeeper"               )   or
        ( passedt.craft   == "bookbinder"              )   or
        ( passedt.craft   == "carpet_layer"            )   or
        ( passedt.craft   == "cabinet_maker"           )   or
        ( passedt.craft   == "caterer"                 )   or
        ( passedt.craft   == "cleaning"                )   or
        ( passedt.craft   == "clockmaker"              )   or
        ( passedt.craft   == "confectionery"           )   or
        ( passedt.craft   == "dental_technician"       )   or
        ( passedt.craft   == "engineering"             )   or
        ( passedt.craft   == "furniture"               )   or
        ( passedt.craft   == "furniture_maker"         )   or
        ( passedt.craft   == "gardener"                )   or
        ( passedt.craft   == "handicraft"              )   or
        ( passedt.craft   == "insulation"              )   or
        ( passedt.craft   == "joiner"                  )   or
        ( passedt.craft   == "metal_construction"      )   or
        ( passedt.craft   == "painter"                 )   or
        ( passedt.craft   == "plasterer"               )   or
        ( passedt.craft   == "photographic_laboratory" )   or
        ( passedt.craft   == "saddler"                 )   or
        ( passedt.craft   == "sailmaker"               )   or
        ( passedt.craft   == "scaffolder"              )   or
        ( passedt.craft   == "tiler"                   )   or
        ( passedt.craft   == "watchmaker"              ))) then
      passedt.landuse = "unnamedcommercial"
      passedt.office  = "nonspecific"
      passedt.craft   = nil
   end

-- ----------------------------------------------------------------------------
-- Telephone Exchanges
-- ----------------------------------------------------------------------------
   if ((    passedt.man_made   == "telephone_exchange"  )  or
       (    passedt.amenity    == "telephone_exchange"  )  or
       ((   passedt.building   == "telephone_exchange" )   and
        ((( passedt.amenity    == nil                )     or
          ( passedt.amenity    == ""                 ))    and
         (( passedt.man_made   == nil                )     or
          ( passedt.man_made   == ""                 ))    and
         (( passedt.office     == nil                )     or
          ( passedt.office     == ""                 )))   or
        (   passedt.telecom    == "exchange"           ))) then
      if (( passedt.name == nil ) or
          ( passedt.name == ""  )) then
         passedt.name  = "Telephone Exchange"
      end

      passedt.office  = "nonspecific"
   end

-- ----------------------------------------------------------------------------
-- If we know that something is a building=office, and it has a name, but is
-- not already known as an amenity, office or shop, add office=nonspecific.
-- ----------------------------------------------------------------------------
   if ((  passedt.building == "office" ) and
       (  passedt.name     ~= nil      ) and
       (  passedt.name     ~= ""       ) and
       (( passedt.amenity  == nil     )  or
        ( passedt.amenity  == ""      )) and
       (( passedt.office   == nil     )  or
        ( passedt.office   == ""      )) and
       (( passedt.shop     == nil     )  or
        ( passedt.shop     == ""      ))) then
      passedt.office  = "nonspecific"
   end

-- ----------------------------------------------------------------------------
-- Offices that we don't know the type of.  
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( passedt.office     == "company"           ) or
       ( passedt.shop       == "office"            ) or
       ( passedt.amenity    == "office"            ) or
       ( passedt.office     == "private"           ) or
       ( passedt.office     == "research"          ) or
       ( passedt.office     == "office"            ) or
       ( passedt.office     == "yes"               ) or
       ( passedt.commercial == "office"            )) then
      passedt.landuse = "unnamedcommercial"
      passedt.office  = "nonspecific"
   end

-- ----------------------------------------------------------------------------
-- emergency=water_rescue is a poorly-designed key that makes it difficult to
-- tell e.g. lifeboats from lifeboat stations.
-- However, if we've got one of various buildings, it's a lifeboat station.
-- ----------------------------------------------------------------------------
   if (  passedt.emergency == "water_rescue" ) then
      if (( passedt.building  == "boathouse"        ) or
          ( passedt.building  == "commercial"       ) or
          ( passedt.building  == "container"        ) or
          ( passedt.building  == "house"            ) or
          ( passedt.building  == "industrial"       ) or
          ( passedt.building  == "lifeboat_station" ) or
          ( passedt.building  == "no"               ) or
          ( passedt.building  == "office"           ) or
          ( passedt.building  == "public"           ) or
          ( passedt.building  == "retail"           ) or
          ( passedt.building  == "roof"             ) or
          ( passedt.building  == "ruins"            ) or
          ( passedt.building  == "service"          ) or
          ( passedt.building  == "yes"              )) then
         passedt.emergency = "lifeboat_station"
      else
         if (( passedt.building                         == "ship"                ) or
             ( passedt["seamark:rescue_station:category"]  == "lifeboat_on_mooring" )) then
            passedt.amenity   = "lifeboat"
            passedt.emergency = nil
         else
            passedt.emergency = "lifeboat_station"
         end
      end
   end

-- ----------------------------------------------------------------------------
-- Handling of objects not (yet) tagfiddled to "emergency=water_rescue":
-- Sometimes lifeboats are mapped in the see separately to the 
-- lifeboat station, and sometimes they're tagged _on_ the lifeboat station.
-- If the latter, show the lifeboat station.
-- Also detect lifeboats and coastguards tagged only as seamarks.
--
-- See below for the similar but different tag "emergency=water_rescue_station"
-- which seems to be used on buildings, huts, etc. (not lifeboats).
-- ----------------------------------------------------------------------------
   if ((  passedt["seamark:rescue_station:category"] == "lifeboat_on_mooring"  ) and
       (( passedt.amenity                         == nil                   )  or
        ( passedt.amenity                         == ""                    ))) then
      passedt.amenity  = "lifeboat"
   end

   if ((  passedt["seamark:type"] == "coastguard_station"  ) and
       (( passedt.amenity      == nil                  )  or
        ( passedt.amenity      == ""                   ))) then
      passedt.amenity  = "coast_guard"
   end

   if (( passedt.amenity   == "lifeboat"         ) and
       ( passedt.emergency == "lifeboat_station" )) then
      passedt.amenity  = nil
   end

-- ----------------------------------------------------------------------------
-- Similarly, various government offices.  Job Centres first.
-- Lifeboat stations are also in here.
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if ((  passedt.amenity    == "job_centre"               ) or
       (  passedt.amenity    == "jobcentre"                ) or
       (  passedt.name       == "Jobcentre Plus"           ) or
       (  passedt.name       == "JobCentre Plus"           ) or
       (  passedt.name       == "Job Centre Plus"          ) or
       (  passedt.office     == "government"               ) or
       (  passedt.office     == "police"                   ) or
       (  passedt.police     == "offices"                  ) or
       (  passedt.police     == "car_pound"                ) or
       (  passedt.police     == "detention"                ) or
       (  passedt.police     == "range"                    ) or
       (  passedt.police     == "training_area"            ) or
       (  passedt.police     == "traffic_police"           ) or
       (  passedt.police     == "storage"                  ) or
       (  passedt.police     == "dog_unit"                 ) or
       (  passedt.police     == "horse"                    ) or
       (  passedt.government == "customs"                  ) or
       (  passedt.government == "police"                   ) or
       (  passedt.amenity    == "public_building"          ) or
       (  passedt.office     == "administrative"           ) or
       (  passedt.office     == "register"                 ) or
       (  passedt.amenity    == "register_office"          ) or
       (  passedt.office     == "council"                  ) or
       (  passedt.office     == "drainage_board"           ) or
       (  passedt.office     == "forestry"                 ) or
       (  passedt.amenity    == "courthouse"               ) or
       (  passedt.office     == "justice"                  ) or
       (  passedt.amenity    == "townhall"                 ) or
       (  passedt.amenity    == "village_hall"             ) or
       (  passedt.building   == "village_hall"             ) or
       (  passedt.amenity    == "crematorium"              ) or
       (  passedt.amenity    == "hall"                     ) or
       (  passedt.amenity    == "fire_station"             ) or
       (  passedt.emergency  == "fire_station"             ) or
       (  passedt.amenity    == "lifeboat_station"         ) or
       (  passedt.emergency  == "lifeboat_station"         ) or
       (  passedt.emergency  == "lifeguard_tower"          ) or
       (  passedt.emergency  == "water_rescue_station"     ) or
       (( passedt.emergency  == "lifeguard"               )  and
        (( passedt.lifeguard == "base"                   )   or
         ( passedt.lifeguard == "tower"                  ))) or
       (  passedt.amenity    == "coast_guard"              ) or
       (  passedt.emergency  == "coast_guard"              ) or
       (  passedt.emergency  == "ses_station"              ) or
       (  passedt.amenity    == "archive"                  ) or
       (  passedt.amenity    == "lost_property"            ) or
       (  passedt.amenity    == "lost_property_office"     )) then
      passedt.landuse = "unnamedcommercial"
      passedt.office  = "nonspecific"
      passedt.government  = nil
      passedt.tourism  = nil
   end

-- ----------------------------------------------------------------------------
-- Ambulance stations
-- ----------------------------------------------------------------------------
   if (( passedt.amenity   == "ambulance_station"       ) or
       ( passedt.emergency == "ambulance_station"       )) then
      passedt.landuse = "unnamedcommercial"
      passedt.amenity  = "ambulance_station"
   end

   if (( passedt.amenity   == "mountain_rescue"       ) or
       ( passedt.emergency == "mountain_rescue"       )) then
      passedt.landuse = "unnamedcommercial"
      passedt.amenity  = "mountain_rescue"

      if (( passedt.name == nil ) or
          ( passedt.name == ""  )) then
         passedt.name = "Mountain Rescue"
      end
   end

   if (( passedt.amenity   == "mountain_rescue_box"       ) or
       ( passedt.emergency == "rescue_box"                )) then
      passedt.amenity  = "mountain_rescue_box"

      if (( passedt.name == nil ) or
          ( passedt.name == ""  )) then
         passedt.name = "Mountain Rescue Supplies"
      end
   end

-- ----------------------------------------------------------------------------
-- Current monasteries et al go through as "amenity=monastery"
-- Note that historic=gate are generally much smaller and are not included here.
-- ----------------------------------------------------------------------------
   if (( passedt.amenity == "monastery" ) or
       ( passedt.amenity == "convent"   )) then
      passedt.amenity = "monastery"

      if (( passedt.landuse == nil ) or
          ( passedt.landuse == ""  )) then
         passedt.landuse = "unnamedcommercial"
      end
   end

-- ----------------------------------------------------------------------------
-- Non-government (commercial) offices that you might visit for a service.
-- "communication" below seems to be used for marketing / commercial PR.
-- Add unnamedcommercial landuse to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( passedt.office      == "it"                      ) or
       ( passedt.office      == "computer"                ) or
       ( passedt.office      == "consulting"              ) or
       ( passedt.office      == "construction_company"    ) or
       ( passedt.office      == "courier"                 ) or
       ( passedt.office      == "advertising"             ) or
       ( passedt.office      == "advertising_agency"      ) or
       ( passedt.amenity     == "post_depot"              ) or
       ( passedt.office      == "lawyer"                  ) or
       ( passedt.shop        == "lawyer"                  ) or
       ( passedt.amenity     == "lawyer"                  ) or
       ( passedt.shop        == "legal"                   ) or
       ( passedt.office      == "solicitor"               ) or
       ( passedt.shop        == "solicitor"               ) or
       ( passedt.amenity     == "solicitor"               ) or
       ( passedt.office      == "solicitors"              ) or
       ( passedt.amenity     == "solicitors"              ) or
       ( passedt.office      == "accountant"              ) or
       ( passedt.shop        == "accountant"              ) or
       ( passedt.office      == "accountants"             ) or
       ( passedt.amenity     == "accountants"             ) or
       ( passedt.office      == "tax_advisor"             ) or
       ( passedt.amenity     == "tax_advisor"             ) or
       ( passedt.office      == "employment_agency"       ) or
       ( passedt.shop        == "home_care"               ) or
       ( passedt.office      == "home_care"               ) or
       ( passedt.healthcare  == "home_care"               ) or
       ( passedt.shop        == "employment_agency"       ) or
       ( passedt.shop        == "employment"              ) or
       ( passedt.shop        == "jobs"                    ) or
       ( passedt.office      == "recruitment_agency"      ) or
       ( passedt.office      == "recruitment"             ) or
       ( passedt.shop        == "recruitment"             ) or
       ( passedt.office      == "insurance"               ) or
       ( passedt.office      == "architect"               ) or
       ( passedt.office      == "telecommunication"       ) or
       ( passedt.office      == "financial"               ) or
       ( passedt.office      == "newspaper"               ) or
       ( passedt.office      == "delivery"                ) or
       ( passedt.amenity     == "delivery_office"         ) or
       ( passedt.amenity     == "sorting_office"          ) or
       ( passedt.office      == "parcel"                  ) or
       ( passedt.office      == "therapist"               ) or
       ( passedt.office      == "surveyor"                ) or
       ( passedt.office      == "geodesist"               ) or
       ( passedt.office      == "marketing"               ) or
       ( passedt.office      == "graphic_design"          ) or
       ( passedt.office      == "interior_design"         ) or
       ( passedt.office      == "builder"                 ) or
       ( passedt.office      == "training"                ) or
       ( passedt.office      == "web_design"              ) or
       ( passedt.office      == "design"                  ) or
       ( passedt.shop        == "design"                  ) or
       ( passedt.office      == "communication"           ) or
       ( passedt.office      == "security"                ) or
       ( passedt.office      == "engineer"                ) or
       ( passedt.office      == "engineering"             ) or
       ( passedt.craft       == "hvac"                    ) or
       ( passedt.office      == "hvac"                    ) or
       ( passedt.shop        == "hvac"                    ) or
       ( passedt.shop        == "heating"                 ) or
       ( passedt.office      == "laundry"                 ) or
       ( passedt.amenity     == "coworking_space"         ) or
       ( passedt.office      == "coworking"               ) or
       ( passedt.office      == "coworking_space"         ) or
       ( passedt.office      == "serviced_offices"        ) or
       ( passedt.amenity     == "studio"                  ) or
       ( passedt.amenity     == "music_school"            ) or
       ( passedt.amenity     == "cooking_school"          ) or
       ( passedt.craft       == "electrician"             ) or
       ( passedt.craft       == "electrician;plumber"     ) or
       ( passedt.shop        == "machinery"               ) or
       ( passedt.shop        == "industrial"              ) or
       ( passedt.shop        == "engineering"             ) or
       ( passedt.shop        == "construction"            ) or
       ( passedt.shop        == "water"                   ) or
       ( passedt.shop        == "pest_control"            ) or
       ( passedt.office      == "electrician"             ) or
       ( passedt.shop        == "electrician"             )) then
      passedt.landuse = "unnamedcommercial"
      passedt.office = "nonspecific"
   end

-- ----------------------------------------------------------------------------
-- Other nonspecific offices.  
-- If any of the "diplomatic" ones should be shown as embassies, the "office"
-- tag will have been removed above.
-- ----------------------------------------------------------------------------
   if (( passedt.office     == "it"                      ) or
       ( passedt.office     == "ngo"                     ) or
       ( passedt.office     == "organization"            ) or
       ( passedt.office     == "diplomatic"              ) or
       ( passedt.office     == "educational_institution" ) or
       ( passedt.office     == "university"              ) or
       ( passedt.office     == "charity"                 ) or
       ((( passedt.office          == nil              )   or
         ( passedt.office          == ""               ))  and
        (( passedt.social_facility == "outreach"       )   or
         ( passedt.social_facility == "food_bank"      ))) or
       ( passedt.office     == "religion"                ) or
       ( passedt.office     == "marriage_guidance"       ) or
       ( passedt.amenity    == "education_centre"        ) or
       ( passedt.man_made   == "observatory"             ) or
       ( passedt.man_made   == "telescope"               ) or
       ( passedt.amenity    == "laboratory"              ) or
       ( passedt.healthcare == "laboratory"              ) or
       ( passedt.amenity    == "medical_laboratory"      ) or
       ( passedt.amenity    == "research_institute"      ) or
       ( passedt.office     == "political_party"         ) or
       ( passedt.office     == "politician"              ) or
       ( passedt.office     == "political"               ) or
       ( passedt.office     == "property_maintenance"    ) or
       ( passedt.office     == "quango"                  ) or
       ( passedt.office     == "association"             ) or
       ( passedt.amenity    == "advice"                  ) or
       ( passedt.amenity    == "advice_service"          )) then
      passedt.landuse = "unnamedcommercial"
      passedt.office  = "nonspecific"
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
   if (( passedt.amenity == "swimming_pool" ) and
       ( passedt.access  ~= "no"            )) then
      passedt.leisure = "leisurenonspecific"
   end

-- ----------------------------------------------------------------------------
-- Render outdoor swimming areas with blue names (if named)
-- leisure=pool is either a turkish bath, a hot spring or a private 
-- swimming pool.
-- leisure=swimming is either a mistagged swimming area or a 
-- mistagged swimming pool
-- ----------------------------------------------------------------------------
   if (( passedt.leisure == "swimming_area" ) or
       ( passedt.leisure == "pool"          ) or
       ( passedt.leisure == "swimming"      )) then
      passedt.leisure = "swimming_pool"
   end

-- ----------------------------------------------------------------------------
-- A couple of odd sports taggings:
-- ----------------------------------------------------------------------------
   if ( passedt.leisure == "sport" ) then
      if ( passedt.sport   == "golf"  ) then
         passedt.leisure = "golf_course"
      else
         passedt.leisure = "leisurenonspecific"
      end
   end

-- ----------------------------------------------------------------------------
-- Try and catch grass on horse_riding
-- ----------------------------------------------------------------------------
   if ( passedt.leisure == "horse_riding" ) then
      passedt.leisure = "leisurenonspecific"

      if ((  passedt.surface == "grass"  ) and
          (( passedt.landuse == nil     )  or
           ( passedt.landuse == ""      ))) then
         passedt.landuse = "unnamedgrass"
      end
   end

-- ----------------------------------------------------------------------------
-- If we have any named leisure=outdoor_seating left, 
-- change it to "leisurenonspecific", but don't set landuse.
-- ----------------------------------------------------------------------------
   if (( passedt.leisure == "outdoor_seating" ) and
       ( passedt.name    ~= nil               ) and
       ( passedt.name    ~= ""                )) then
      passedt.leisure = "leisurenonspecific"
   end

-- ----------------------------------------------------------------------------
-- Mazes
-- ----------------------------------------------------------------------------
   if ((( passedt.leisure    == "maze" )  or
        ( passedt.attraction == "maze" )) and
       (( passedt.historic   == nil    )  or
        ( passedt.historic   == ""     ))) then
      passedt.leisure = "leisurenonspecific"
      passedt.tourism = nil
   end

-- ----------------------------------------------------------------------------
-- Other nonspecific leisure.  We add an icon and label via "leisurenonspecific".
-- In most cases we also add unnamedcommercial landuse 
-- to give non-building areas a background.
-- ----------------------------------------------------------------------------
   if (( passedt.amenity  == "arts_centre"              ) or
       ( passedt.amenity  == "bingo"                    ) or
       ( passedt.amenity  == "boat_rental"              ) or
       ( passedt.amenity  == "brothel"                  ) or
       ( passedt.amenity  == "church_hall"              ) or
       ( passedt.amenity  == "club"                     ) or
       ( passedt.amenity  == "club_house"               ) or
       ( passedt.amenity  == "clubhouse"                ) or
       ( passedt.amenity  == "community_centre"         ) or
       ( passedt.amenity  == "community_hall"           ) or
       ( passedt.amenity  == "conference_centre"        ) or
       ( passedt.amenity  == "dancing_school"           ) or
       ( passedt.amenity  == "dojo"                     ) or
       ( passedt.amenity  == "escape_game"              ) or
       ( passedt.amenity  == "events_venue"             ) or
       ( passedt.amenity  == "exhibition_centre"        ) or
       ( passedt.amenity  == "function_room"            ) or
       ( passedt.amenity  == "gym"                      ) or
       ( passedt.amenity  == "outdoor_education_centre" ) or
       ( passedt.amenity  == "public_bath"              ) or
       ( passedt.amenity  == "scout_hall"               ) or
       ( passedt.amenity  == "scout_hut"                ) or
       ( passedt.amenity  == "social_centre"            ) or
       ( passedt.amenity  == "social_club"              ) or
       ( passedt.amenity  == "working_mens_club"        ) or
       ( passedt.amenity  == "youth_centre"             ) or
       ( passedt.amenity  == "youth_club"               ) or
       ( passedt.building == "club_house"               ) or
       ( passedt.building == "clubhouse"                ) or
       ( passedt.building == "community_centre"         ) or
       ( passedt.building == "scout_hut"                ) or
       ( passedt.club     == "scout"                    ) or
       ( passedt.club     == "scouts"                   ) or
       ( passedt.club     == "sport"                    ) or
       ((( passedt.club    == "yes"                   )   or
         ( passedt.club    == "social"                )   or
         ( passedt.club    == "freemasonry"           )   or
         ( passedt.club    == "sailing"               )   or
         ( passedt.club    == "youth"                 )   or
         ( passedt.club    == "politics"              )   or
         ( passedt.club    == "veterans"              )   or
         ( passedt.club    == "social_club"           )   or
         ( passedt.club    == "music"                 )   or
         ( passedt.club    == "working_men"           )   or
         ( passedt.club    == "yachting"              )   or
         ( passedt.club    == "tennis"                )   or
         ( passedt.club    == "army_cadets"           )   or
         ( passedt.club    == "sports"                )   or
         ( passedt.club    == "rowing"                )   or
         ( passedt.club    == "football"              )   or
         ( passedt.club    == "snooker"               )   or
         ( passedt.club    == "fishing"               )   or
         ( passedt.club    == "sea_scout"             )   or
         ( passedt.club    == "conservative"          )   or
         ( passedt.club    == "golf"                  )   or
         ( passedt.club    == "cadet"                 )   or
         ( passedt.club    == "youth_movement"        )   or
         ( passedt.club    == "bridge"                )   or
         ( passedt.club    == "bowling"               )   or
         ( passedt.club    == "air_cadets"            )   or
         ( passedt.club    == "scuba_diving"          )   or
         ( passedt.club    == "model_railway"         )   or
         ( passedt.club    == "boat"                  )   or
         ( passedt.club    == "card_games"            )   or
         ( passedt.club    == "girlguiding"           )   or
         ( passedt.club    == "guide"                 )   or
         ( passedt.club    == "photography"           )   or
         ( passedt.club    == "sea_cadets"            )   or
         ( passedt.club    == "theatre"               )   or
         ( passedt.club    == "women"                 )   or
         ( passedt.club    == "charity"               )   or
         ( passedt.club    == "bowls"                 )   or
         ( passedt.club    == "military"              )   or
         ( passedt.club    == "model_aircraft"        )   or
         ( passedt.club    == "labour_club"           )   or
         ( passedt.club    == "boxing"                )   or
         ( passedt.club    == "game"                  )   or
         ( passedt.club    == "automobile"            ))  and
        (( passedt.leisure == nil                     )   or
         ( passedt.leisure == ""                      ))  and
        (( passedt.amenity == nil                     )   or
         ( passedt.amenity == ""                      ))  and
        (( passedt.shop    == nil                     )   or
         ( passedt.shop    == ""                      ))  and
        (  passedt.name    ~= nil                      )  and
        (  passedt.name    ~= ""                       )) or
       ((  passedt.club    == "cricket"                )  and
        (( passedt.leisure == nil                     )   or
         ( passedt.leisure == ""                      ))  and
        (( passedt.amenity == nil                     )   or
         ( passedt.amenity == ""                      ))  and
        (( passedt.shop    == nil                     )   or
         ( passedt.shop    == ""                      ))  and
        (( passedt.landuse == nil                     )   or
         ( passedt.landuse == ""                      ))  and
        (( passedt.name    ~= nil                     )   and
         ( passedt.name    ~= ""                      ))) or
       ( passedt.gambling == "bingo"                    ) or
       ( passedt.leisure  == "adventure_park"           ) or
       ( passedt.leisure  == "beach_resort"             ) or
       ( passedt.leisure  == "bingo"                    ) or
       ( passedt.leisure  == "bingo_hall"               ) or
       ( passedt.leisure  == "bowling_alley"            ) or
       ( passedt.leisure  == "climbing"                 ) or
       ( passedt.leisure  == "club"                     ) or
       ( passedt.leisure  == "dance"                    ) or
       ( passedt.leisure  == "dojo"                     ) or
       ( passedt.leisure  == "escape_game"              ) or
       ( passedt.leisure  == "firepit"                  ) or
       ( passedt.leisure  == "fitness_centre"           ) or
       ( passedt.leisure  == "hackerspace"              ) or
       ( passedt.leisure  == "high_ropes_course"        ) or
       ( passedt.leisure  == "horse_riding"             ) or
       ( passedt.leisure  == "ice_rink"                 ) or
       ((  passedt.leisure == "indoor_golf"             )  and
        (( passedt.amenity == nil                      )   or
         ( passedt.amenity == ""                       ))) or
       ( passedt.leisure  == "indoor_play"              ) or
       ( passedt.leisure  == "inflatable_park"          ) or
       ( passedt.leisure  == "miniature_golf"           ) or
       ( passedt.leisure  == "resort"                   ) or
       ( passedt.leisure  == "sailing_club"             ) or
       ( passedt.leisure  == "sauna"                    ) or
       ( passedt.leisure  == "social_club"              ) or
       ( passedt.leisure  == "soft_play"                ) or
       ( passedt.leisure  == "summer_camp"              ) or
       ( passedt.leisure  == "trampoline"               ) or
       ( passedt.playground  == "trampoline"            ) or
       ( passedt.leisure  == "trampoline_park"          ) or
       ( passedt.leisure  == "water_park"               ) or
       ( passedt.leisure  == "yoga"                     ) or
       ((( passedt.leisure        == nil               )   or
         ( passedt.leisure        == ""                ))  and
        (( passedt.amenity        == nil               )   or
         ( passedt.amenity        == ""                ))  and
        (( passedt.shop           == nil               )   or
         ( passedt.shop           == ""                ))  and
        (  passedt["dance:teaching"] == "yes"              )) or
       ( passedt.name     == "Bingo Hall"               ) or
       ( passedt.name     == "Castle Bingo"             ) or
       ( passedt.name     == "Gala Bingo"               ) or
       ( passedt.name     == "Mecca Bingo"              ) or
       ( passedt.name     == "Scout Hall"               ) or
       ( passedt.name     == "Scout Hut"                ) or
       ( passedt.name     == "Scout hut"                ) or
       ( passedt.shop     == "boat_rental"              ) or
       ( passedt.shop     == "fitness"                  ) or
       ( passedt.sport    == "laser_tag"                ) or
       ( passedt.sport    == "model_aerodrome"          ) or
       ((( passedt.sport   == "yoga"                  )   or
         ( passedt.sport   == "yoga;pilates"          ))  and
        (( passedt.shop     == nil                    )   or
         ( passedt.shop     == ""                     ))  and
        (( passedt.amenity  == nil                    )   or
         ( passedt.amenity  == ""                     ))) or
       ( passedt.tourism  == "cabin"                    ) or
       ( passedt.tourism  == "resort"                   ) or
       ( passedt.tourism  == "trail_riding_station"     ) or
       ( passedt.tourism  == "wilderness_hut"           ) or
       (( passedt.building == "yes"                    )  and
        (( passedt.amenity  == nil                    )   or
         ( passedt.amenity  == ""                     ))  and
        (( passedt.leisure  == nil                    )   or
         ( passedt.leisure  == ""                     ))  and
        (  passedt.sport    ~= nil                     )  and
        (  passedt.sport    ~= ""                      ))) then
      if (( passedt.landuse == nil ) or
          ( passedt.landuse == ""  )) then
         passedt.landuse = "unnamedcommercial"
      end

      passedt.leisure = "leisurenonspecific"
      passedt["disused:amenity"] = nil
   end

-- ----------------------------------------------------------------------------
-- Some museum / leisure combinations are likely more "leisury" than "museumy"
-- ----------------------------------------------------------------------------
   if (( passedt.tourism == "museum"             ) and 
       ( passedt.leisure == "leisurenonspecific" )) then
      passedt.tourism = nil
   end

-- ----------------------------------------------------------------------------
-- Emergency phones
-- ----------------------------------------------------------------------------
   if ((( passedt.emergency == "phone" )  or
        ( passedt.railway   == "phone" )) and
       (( passedt.amenity   == nil     )  or
        ( passedt.amenity   == ""      ))) then
      passedt.amenity = "emergency_phone"
   end

-- ----------------------------------------------------------------------------
-- Let's send amenity=grave_yard and landuse=cemetery through as
-- landuse=cemetery.
-- ----------------------------------------------------------------------------
   if (( passedt.amenity == "grave_yard" ) or
       ( passedt.landuse == "grave_yard" )) then
      passedt.amenity = nil
      passedt.landuse = "cemetery"
   end

-- ----------------------------------------------------------------------------
-- A special case to check before the "vacant shops" check at the end - 
-- potentially remove disusedCamenity=grave_yard
-- ----------------------------------------------------------------------------
   if (( passedt["disused:amenity"] == "grave_yard" ) and
       ( passedt.landuse         == "cemetery"   )) then
      passedt["disused:amenity"] = nil
   end

-- ----------------------------------------------------------------------------
-- Cemeteries are separated by religion here.
-- "unnamed" is potentially set lower down.  All 6 are selected in project.mml.
--
-- There is a special case for Jehovahs Witnesses - don't use the normal Christian
-- symbol (a cross)
-- ----------------------------------------------------------------------------
   if ( passedt.landuse == "cemetery" ) then
      if ( passedt.religion == "christian" ) then
         if ( passedt.denomination == "jehovahs_witness" ) then
            passedt.landuse = "othercemetery"
         else
            passedt.landuse = "christiancemetery"
         end
      else
         if ( passedt.religion == "jewish" ) then
            passedt.landuse = "jewishcemetery"
         else
            passedt.landuse = "othercemetery"
         end
      end
   end

-- ----------------------------------------------------------------------------
-- If something has been mapped as both "area:aeroway" and "aeroway", then let
-- the latter take precedence.
-- ----------------------------------------------------------------------------
   if (( passedt.aeroway         ~= nil ) and
       ( passedt.aeroway         ~= ""  ) and
       ( passedt["area:aeroway"] ~= nil ) and
       ( passedt["area:aeroway"] ~= ""  )) then
      passedt["area:aeroway"] = nil
   end

-- ----------------------------------------------------------------------------
-- A note about "area:aeroway".  This is sometimes used for area aeroway
-- features.  Sometimes "surface=grass" is also tagged; sometimes
-- "surface=paved", sometimes neither.
--
-- In the case of grass, grass "area:aeroway"s appear to always be mapped over
-- existing grass areas, and paved "area:aeroway"s appear to be mapped among
-- well-mapped landuse areas (e.g. areas of grass).
--
-- There's therefore no need to explicitly show either grass or non-grass
-- "area:aeroway".
-- ----------------------------------------------------------------------------
   if ((  passedt["area:aeroway"] ~= nil )  and
       (  passedt["area:aeroway"] ~= ""  )) then
-- ----------------------------------------------------------------------------
-- We do however remove "landuse=runway" since that isn't a value we look for
-- and does not tell us anything that we do not know.
-- ----------------------------------------------------------------------------
      if ( passedt.landuse == "runway" ) then
         passedt.landuse = nil
      end
   end

-- ----------------------------------------------------------------------------
-- Treat heliports as aerodromes.
-- Done before the "disused" logic below and the "large/small" logic 
-- further down.
--
-- Heliports are similar to airports, except an icao code (present on many
-- more airports) can also determine that a heliport is "public".
-- ----------------------------------------------------------------------------
   if ( passedt.aeroway == "heliport" ) then
      passedt.aeroway = "aerodrome"

      if ((( passedt.iata  == nil )   or
           ( passedt.iata  == ""  ))  and
          ( passedt.icao  ~= nil   )  and
          ( passedt.icao  ~= ""    )) then
         passedt.iata = passedt.icao
      end
   end

-- ----------------------------------------------------------------------------
-- Disused aerodromes etc. - handle disused=yes.
-- ----------------------------------------------------------------------------
   if (( passedt.aeroway        == "aerodrome" ) and
       ( passedt.disused        == "yes"       )) then
      passedt.aeroway = nil
      passedt["disused:aeroway"] = "aerodrome"
   end

   if (( passedt.aeroway        == "runway" ) and
       ( passedt.disused        == "yes"       )) then
      passedt.aeroway = nil
      passedt["disused:aeroway"] = "runway"
   end

   if (( passedt.aeroway        == "taxiway" ) and
       ( passedt.disused        == "yes"       )) then
      passedt.aeroway = nil
      passedt["disused:aeroway"] = "taxiway"
   end

-- ----------------------------------------------------------------------------
-- If a quarry is disused or historic, it's still likely a hole in the ground, 
-- so render it as something.
-- However, if there's a natural tag, that should take precendence, and 
-- landuse is cleared.
-- ----------------------------------------------------------------------------
   if (((  passedt["disused:landuse"] == "quarry"   )  and
        (( passedt.landuse         == nil       )   or
         ( passedt.landuse         == ""        ))) or
       ((  passedt.historic        == "quarry"   )  and
        (( passedt.landuse         == nil       )   or
         ( passedt.landuse         == ""        ))) or
       ((  passedt.landuse         == "quarry"   )  and
        (( passedt.disused         == "yes"     )   or
         ( passedt.historic        == "yes"     )))) then
      if (( passedt.natural == nil )  or
          ( passedt.natural == ""  )) then
         passedt.landuse = "historicquarry"
      else
         passedt.landuse = nil
      end
   end

-- ----------------------------------------------------------------------------
-- Where both historic and natural might carry a name, we need to change some
-- natural tags to unnamed versions
-- ----------------------------------------------------------------------------
   if (( passedt.historic == "archaeological_site"   ) or
       ( passedt.historic == "battlefield"           ) or
       ( passedt.historic == "castle"                ) or
       ( passedt.historic == "church"                ) or
       ( passedt.historic == "historicfortification" ) or
       ( passedt.historic == "historichillfort"      ) or
       ( passedt.historic == "historicmegalithtomb"  ) or
       ( passedt.historic == "historicringfort"      ) or
       ( passedt.historic == "historicstandingstone" ) or
       ( passedt.historic == "historicstonecircle"   ) or
       ( passedt.historic == "historictumulus"       ) or
       ( passedt.historic == "manor"                 ) or
       ( passedt.historic == "memorial"              ) or
       ( passedt.historic == "memorialobelisk"       ) or
       ( passedt.historic == "monastery"             ) or
       ( passedt.historic == "mineshaft"             ) or
       ( passedt.historic == "nonspecific"           ) or
       ( passedt.leisure  == "nature_reserve"        )) then
      if ( passedt.natural == "wood" ) then
         passedt.natural = "unnamedwood"
      end

      if ( passedt.natural == "broadleaved" ) then
         passedt.natural = "unnamedbroadleaved"
      end

      if ( passedt.natural == "mixedleaved" ) then
         passedt.natural = "unnamedmixedleaved"
      end

      if ( passedt.natural == "needleleaved" ) then
         passedt.natural = "unnamedneedleleaved"
      end

      if ( passedt.natural == "heath" ) then
         passedt.natural = "unnamedheath"
      end

      if ( passedt.natural == "scrub" ) then
         passedt.natural = "unnamedscrub"
      end

      if ( passedt.natural == "mud" ) then
         passedt.natural = "unnamedmud"
      end

      if ( passedt.natural == "tidal_mud" ) then
         passedt.natural = "unnamedtidal_mud"
      end

      if ( passedt.natural == "bare_rock" ) then
         passedt.natural = "unnamedbare_rock"
      end

      if ( passedt.natural == "beach" ) then
         passedt.natural = "unnamedbeach"
      end

      if ( passedt.natural == "tidal_beach" ) then
         passedt.natural = "unnamedtidal_beach"
      end

      if ( passedt.natural == "sand" ) then
         passedt.natural = "unnamedsand"
      end

      if ( passedt.natural == "tidal_sand" ) then
         passedt.natural = "unnamedtidal_sand"
      end

      if ( passedt.natural == "wetland" ) then
         passedt.natural = "unnamedwetland"
      end

      if ( passedt.natural == "swamp" ) then
         passedt.natural = "unnamedswamp"
      end

      if ( passedt.natural == "bog" ) then
         passedt.natural = "unnamedbog"
      end

      if ( passedt.natural == "string_bog" ) then
         passedt.natural = "unnamedstring_bog"
      end

      if ( passedt.natural == "grassland" ) then
         passedt.natural = "unnamedgrassland"
      end
   end

-- ----------------------------------------------------------------------------
-- Change commercial landuse from aerodromes so that no name is displayed 
-- from that.
-- There's a similar issue with e.g. leisure=fishing / landuse=grass, which has
-- already been rewritten to "park" by now.
-- Some combinations are incompatible so we "just need to pick one".
-- ----------------------------------------------------------------------------
   if (( passedt.aeroway  == "aerodrome"             ) or
       ( passedt.historic == "archaeological_site"   ) or
       ( passedt.historic == "battlefield"           ) or
       ( passedt.historic == "castle"                ) or
       ( passedt.historic == "church"                ) or
       ( passedt.historic == "historicfortification" ) or
       ( passedt.historic == "historichillfort"      ) or
       ( passedt.historic == "historicmegalithtomb"  ) or
       ( passedt.historic == "historicringfort"      ) or
       ( passedt.historic == "historicstandingstone" ) or
       ( passedt.historic == "historicstonecircle"   ) or
       ( passedt.historic == "historictumulus"       ) or
       ( passedt.historic == "manor"                 ) or
       ( passedt.historic == "memorial"              ) or
       ( passedt.historic == "memorialobelisk"       ) or
       ( passedt.historic == "monastery"             ) or
       ( passedt.historic == "mineshaft"             ) or
       ( passedt.historic == "nonspecific"           ) or
       ( passedt.leisure  == "common"                ) or
       ( passedt.leisure  == "garden"                ) or
       ( passedt.leisure  == "nature_reserve"        ) or
       ( passedt.leisure  == "park"                  ) or
       ( passedt.leisure  == "pitch"                 ) or
       ( passedt.leisure  == "sports_centre"         ) or
       ( passedt.leisure  == "track"                 ) or
       ( passedt.tourism  == "theme_park"            )) then
      if ( passedt.landuse == "allotments" ) then
         passedt.landuse = "unnamedallotments"
      end

      if ( passedt.landuse == "christiancemetery" ) then
         passedt.landuse = "unnamedchristiancemetery"
      end

      if ( passedt.landuse == "jewishcemetery" ) then
         passedt.landuse = "unnamedjewishcemetery"
      end

      if ( passedt.landuse == "othercemetery" ) then
         passedt.landuse = "unnamedothercemetery"
      end

      if ( passedt.landuse == "commercial" ) then
         passedt.landuse = "unnamedcommercial"
      end

      if (( passedt.landuse == "construction" )  or
          ( passedt.landuse == "brownfield"   )) then
         passedt.landuse = "unnamedconstruction"
      end

      if ( passedt.landuse == "farmland" ) then
         passedt.landuse = "unnamedfarmland"
      end

      if (( passedt.landuse == "farmgrass"  )  or
          ( passedt.landuse == "greenfield" )) then
         passedt.landuse = "unnamedfarmgrass"
      end

      if ( passedt.landuse == "farmyard" ) then
         passedt.landuse = "unnamedfarmyard"
      end

      if ( passedt.landuse == "forest" ) then
         passedt.landuse = "unnamedforest"
      end

      if ( passedt.landuse == "grass" ) then
         passedt.landuse = "unnamedgrass"
      end

      if ( passedt.landuse == "industrial" ) then
         passedt.landuse = "unnamedindustrial"
      end

      if ( passedt.landuse == "landfill" ) then
         passedt.landuse = "unnamedlandfill"
      end

      if ( passedt.landuse == "meadow" ) then
         passedt.landuse = "unnamedmeadow"
      end

      if ( passedt.landuse == "wetmeadow" ) then
         passedt.landuse = "unnamedwetmeadow"
      end

      if ( passedt.landuse == "meadowwildflower" ) then
         passedt.landuse = "unnamedmeadowwildflower"
      end

      if ( passedt.landuse == "meadowperpetual" ) then
         passedt.landuse = "unnamedmeadowperpetual"
      end

      if ( passedt.landuse == "meadowtransitional" ) then
         passedt.landuse = "unnamedmeadowtransitional"
      end

      if ( passedt.landuse == "saltmarsh" ) then
         passedt.landuse = "unnamedsaltmarsh"
      end

      if ( passedt.landuse == "orchard" ) then
         passedt.landuse = "unnamedorchard"
      end

      if ( passedt.landuse  == "quarry" ) then
         passedt.landuse = "unnamedquarry"
      end

      if ( passedt.landuse  == "historicquarry" ) then
         passedt.landuse = "unnamedhistoricquarry"
      end

      if ( passedt.landuse == "residential" ) then
         passedt.landuse = "unnamedresidential"
      end
   end

-- ----------------------------------------------------------------------------
-- Aerodrome size.
-- Large public airports should have an airport icon.  Others should not.
-- ----------------------------------------------------------------------------
   if ( passedt.aeroway == "aerodrome" ) then
      if ((  passedt.iata           ~= nil          ) and
          (  passedt.iata           ~= ""           ) and
          (  passedt["aerodrome:type"] ~= "military"   ) and
          (( passedt.military       == nil         )  or
           ( passedt.military       == ""          ))) then
         passedt.aeroway = "large_aerodrome"

         if (( passedt.name == nil ) or
             ( passedt.name == ""  )) then
            passedt.name = passedt.iata
         else
            passedt.name = passedt.name .. " (" .. passedt.iata .. ")"
         end
      else
         if ((  passedt["aerodrome:type"] == "military"   ) or
             (( passedt.military       ~= nil         )  and
              ( passedt.military       ~= ""          ))) then
            passedt.aeroway = "military_aerodrome"
         end
      end
   end

-- ----------------------------------------------------------------------------
-- Grass runways
-- These are rendered less prominently.
-- ----------------------------------------------------------------------------
   if (( passedt.aeroway == "runway" ) and
       ( passedt.surface == "grass"  )) then
      passedt.aeroway = "grass_runway"
   end

   if (( passedt.aeroway == "apron"  ) and
       ( passedt.surface == "grass"  )) then
      passedt.landuse = "grass"
      passedt.aeroway = nil
   end

   if (( passedt.aeroway == "taxiway"  ) and
       ( passedt.surface == "grass"    )) then
      passedt.highway = "pathwide"
      passedt.aeroway = nil
   end


-- ----------------------------------------------------------------------------
-- Render airport parking positions as gates.
-- ----------------------------------------------------------------------------
   if ( passedt.aeroway == "parking_position" ) then
      passedt.aeroway = "gate"

      if (( passedt.ref ~= nil ) and
          ( passedt.ref ~= ""  )) then
         passedt.ref = "(" .. passedt.ref .. ")"
      end
   end

-- ----------------------------------------------------------------------------
-- Masts etc.  Consolidate various sorts of masts and towers into the "mast"
-- group.  Note that this includes "tower" temporarily, and "campanile" is in 
-- here as a sort of tower (only 2 mapped in UK currently).
-- Also remove any "tourism" tags (which may be semi-valid mapping but are
-- often just "for the renderer").
-- ----------------------------------------------------------------------------
   if ((  passedt.man_made   == "tower"    ) and
       (( passedt["tower:type"] == "cooling" )  or
        ( passedt["tower:type"] == "chimney" ))) then
      if (( tonumber(passedt.height) or 0 ) >  100 ) then
         passedt.man_made = "bigchimney"
      else
         passedt.man_made = "chimney"
      end
      passedt.tourism = nil
   end

   if (( passedt.man_made   == "tower"    ) and
       ( passedt["tower:type"] == "lighting" )) then
      passedt.man_made = "illuminationtower"
      passedt.tourism = nil
   end

   if ((   passedt.man_made           == "tower"       ) and
       ((  passedt["tower:type"]         == "defensive"  )  or
        ((( passedt["tower:type"]         == nil        )   or
          ( passedt["tower:type"]         == ""         ))   and
         ( passedt["tower:construction"] == "stone"     )))) then
      passedt.man_made = "defensivetower"
      passedt.tourism = nil
   end

   if (( passedt.man_made   == "tower"       ) and
       ( passedt["tower:type"] == "observation" )) then
      if (( tonumber(passedt.height) or 0 ) >  100 ) then
         passedt.man_made = "bigobservationtower"
      else
         passedt.man_made = "observationtower"
      end
      passedt.tourism = nil
   end

-- ----------------------------------------------------------------------------
-- Clock towers
-- ----------------------------------------------------------------------------
   if (((  passedt.man_made   == "tower"        )  and
        (( passedt["tower:type"] == "clock"       )   or
         ( passedt.building   == "clock_tower" )   or
         ( passedt.amenity    == "clock"       ))) or
       ((  passedt.amenity    == "clock"        )  and
        (  passedt.support    == "tower"        ))) then
      passedt.man_made = "clocktower"
      passedt.tourism = nil
   end

   if ((  passedt.amenity    == "clock"         )  and
       (( passedt.support    == "pedestal"     )   or
        ( passedt.support    == "pole"         )   or
        ( passedt.support    == "stone_pillar" )   or
        ( passedt.support    == "plinth"       )   or
        ( passedt.support    == "column"       ))) then
      passedt.man_made = "clockpedestal"
      passedt.tourism = nil
   end

-- ----------------------------------------------------------------------------
-- Aircraft control towers
-- ----------------------------------------------------------------------------
   if (((  passedt.man_made   == "tower"             )   and
        (( passedt["tower:type"] == "aircraft_control" )    or
         ( passedt.service    == "aircraft_control" )))  or
       (   passedt.aeroway    == "control_tower"      )) then
      passedt.man_made = "aircraftcontroltower"
      passedt.building = "yes"
      passedt.tourism = nil
   end

   if ((( passedt.man_made   == "tower"              )   or
        ( passedt.man_made   == "monitoring_station" ))  and
       (( passedt["tower:type"] == "radar"              )   or
        ( passedt["tower:type"] == "weather_radar"      ))) then
      passedt.man_made = "radartower"
      passedt.building = "yes"
      passedt.tourism = nil
   end

-- ----------------------------------------------------------------------------
-- All the domes in the UK are radomes.
-- ----------------------------------------------------------------------------
   if (( passedt.man_made               == "tower"   ) and
       (( passedt["tower:construction"] == "dome"   )  or
        ( passedt["tower:construction"] == "dish"   ))) then
      passedt.man_made = "radartower"
      passedt.building = "yes"
      passedt.tourism = nil
   end

   if ((  passedt.man_made      == "tower"                 ) and
       (( passedt["tower:type"] == "hose"                 ) or
        ( passedt["tower:type"] == "firefighter_training" ))) then
      passedt.man_made = "squaretower"
      passedt.building = "yes"
      passedt.tourism = nil
   end

   if (((  passedt.man_made         == "tower"           )  or
        (  passedt.building         == "tower"           )  or
        (  passedt["building:part"] == "yes"             )) and
       ((  passedt["tower:type"]    == "church"          )   or
        (  passedt["tower:type"]    == "square"          )   or
        (  passedt["tower:type"]    == "campanile"       )   or
        (  passedt["tower:type"]    == "bell_tower"      )   or
        (  passedt.man_made         == "campanile"       ))  and
       ((  passedt.amenity          == nil                )  or
        (  passedt.amenity          == ""                 )  or
        (  passedt.amenity          ~= "place_of_worship" ))) then
      passedt.man_made = "churchtower"
      passedt.building = "yes"
      passedt.tourism = nil
   end

   if (((  passedt.man_made         == "tower"            )  or
        (  passedt.building         == "tower"            )  or
        (  passedt["building:part"] == "yes"              )) and
       ((  passedt["tower:type"]    == "spire"            )  or
        (  passedt["tower:type"]    == "steeple"          )  or
        (  passedt["tower:type"]    == "minaret"          )  or
        (  passedt["tower:type"]    == "round"            )  or
        (  passedt["tower"]         == "round"            )) and
       ((  passedt.amenity          == nil                )  or
        (  passedt.amenity          == ""                 )  or
        (  passedt.amenity          ~= "place_of_worship" ))) then
      passedt.man_made = "churchspire"
      passedt.building = "yes"
      passedt.tourism = nil
   end

   if (( passedt.man_made == "phone_mast"           ) or
       ( passedt.man_made == "radio_mast"           ) or
       ( passedt.man_made == "communications_mast"  ) or
       ( passedt.man_made == "tower"                ) or
       ( passedt.man_made == "communications_tower" ) or
       ( passedt.man_made == "transmitter"          ) or
       ( passedt.man_made == "antenna"              ) or
       ( passedt.man_made == "mast"                 )) then
      if (( tonumber(passedt.height) or 0 ) >  300 ) then
         passedt.man_made = "bigmast"
      else
         passedt.man_made = "mast"
      end
      passedt.tourism = nil
   end

-- ----------------------------------------------------------------------------
-- Drinking water and water that's not OK for drinking
-- "amenity=drinking_water" is shown as "tap_drinking.p.20.png"
-- "amenity=nondrinking_water" is shown as "tap_nondrinking.p.20.png"
--
-- First, catch any mistagged fountains:
-- ----------------------------------------------------------------------------
   if (( passedt.amenity        == "fountain" ) and
       ( passedt.drinking_water == "yes"      )) then
      passedt.amenity = "drinking_water"
   end

   if (((( passedt.man_made == "water_tap"   )   or
         ( passedt.waterway == "water_point" ))  and
        (( passedt.amenity  == nil           )   or
         ( passedt.amenity  == ""            ))) or
       (   passedt.amenity  == "water_point"   ) or
       (   passedt.amenity  == "dish_washing"  ) or
       (   passedt.amenity  == "washing_area"  ) or
       (   passedt.amenity  == "utilities"     )) then
      if ( passedt.drinking_water == "yes" ) then
         passedt.amenity = "drinking_water"
      else
         passedt.amenity = "nondrinking_water"
      end
   end

-- ----------------------------------------------------------------------------
-- man_made=maypole
-- ----------------------------------------------------------------------------
   if ((  passedt.man_made == "maypole"   ) or
       (  passedt.man_made == "may_pole"  ) or
       (  passedt.historic == "maypole"   )) then
      passedt.man_made = "maypole"
      passedt.tourism = nil
   end

-- ----------------------------------------------------------------------------
-- highway=streetlamp
-- ----------------------------------------------------------------------------
   if ( passedt.highway == "street_lamp" ) then
      if ( passedt.lamp_type == "gaslight" ) then
         passedt.highway = "streetlamp_gas"
      else
         passedt.highway = "streetlamp_electric"
      end
   end

-- ----------------------------------------------------------------------------
-- Departure boards not associated with bus stops etc.
-- ----------------------------------------------------------------------------
   if ((( passedt.highway                       == nil                            )  or
        ( passedt.highway                       == ""                             )) and
       (( passedt.railway                       == nil                            )  or
        ( passedt.railway                       == ""                             )) and
       (( passedt.public_transport              == nil                            )  or
        ( passedt.public_transport              == ""                             )) and
       (( passedt.building                      == nil                            )  or
        ( passedt.building                      == ""                             )) and
       (( passedt.departures_board              == "realtime"                     ) or
        ( passedt.departures_board              == "timetable; realtime"          ) or
        ( passedt.departures_board              == "realtime;timetable"           ) or
        ( passedt.departures_board              == "timetable;realtime"           ) or
        ( passedt.departures_board              == "realtime_multiline"           ) or
        ( passedt.departures_board              == "realtime,timetable"           ) or
        ( passedt.departures_board              == "multiline"                    ) or
        ( passedt.departures_board              == "realtime_multiline;timetable" ) or
        ( passedt.passenger_information_display == "realtime"                     ))) then
         passedt.highway = "board_realtime"
   end

-- ----------------------------------------------------------------------------
-- If a bus stop pole exists but it's known to be disused, indicate that.
--
-- We also show bus stands as disused bus stops - they are somewhere where you
-- might expect to be able to get on a bus, but cannot.
-- ----------------------------------------------------------------------------
   if ((( passedt["disused:highway"]    == "bus_stop"  )  and
        ( passedt.physically_present == "yes"       )) or
       (  passedt.highway            == "bus_stand"  ) or
       (  passedt.amenity            == "bus_stand"  )) then
      passedt.highway = "bus_stop_disused_pole"
      passedt["disused:highway"] = nil
      passedt.amenity = nil

      if (( passedt.name ~= nil ) and
          ( passedt.name ~= ""  )) then
         passedt.ele = passedt.name
      end
   end

-- ----------------------------------------------------------------------------
-- Some people tag waste_basket on bus_stop.  We render just bus_stop.
-- ----------------------------------------------------------------------------
   if (( passedt.highway == "bus_stop"     ) and
       ( passedt.amenity == "waste_basket" )) then
      passedt.amenity = nil
   end

-- ----------------------------------------------------------------------------
-- Many "naptan:Indicator" are "opp" or "adj", but some are "Stop XYZ" or
-- various other bits and pieces.  See 
-- https://taginfo.openstreetmap.org/keys/naptan%3AIndicator#values
-- We remove overly long ones.
-- Similarly, long "ref" values.
-- ----------------------------------------------------------------------------
   if (( passedt["naptan:Indicator"] ~= nil           ) and
       ( passedt["naptan:Indicator"] ~= ""            ) and
       ( string.len( passedt["naptan:Indicator"]) > 3 )) then
      passedt["naptan:Indicator"] = nil
   end

   if (( passedt.highway == "bus_stop" ) and
       ( passedt.ref     ~= nil        ) and
       ( passedt.ref     ~= ""         ) and
       ( string.len( passedt.ref) > 3  )) then
      passedt.ref = nil
   end

-- ----------------------------------------------------------------------------
-- Concatenate a couple of names for bus stops so that the most useful ones
-- are displayed.
-- ----------------------------------------------------------------------------
   if ( passedt.highway == "bus_stop" ) then
      if (( passedt.name ~= nil ) and
          ( passedt.name ~= ""  )) then
         if (( passedt.bus_speech_output_name ~= nil                                ) and
             ( passedt.bus_speech_output_name ~= ""                                 ) and
             ( not string.find( passedt.name, passedt.bus_speech_output_name, 1, true ))) then
            passedt.name = passedt.name .. " / " .. passedt.bus_speech_output_name
         end

         if (( passedt.bus_display_name ~= nil                                ) and
             ( passedt.bus_display_name ~= ""                                 ) and
             ( not string.find( passedt.name, passedt.bus_display_name, 1, true ))) then
            passedt.name = passedt.name .. " / " .. passedt.bus_display_name
         end
      end

      if (( passedt.name == nil ) or
          ( passedt.name == ""  )) then
         if (( passedt.ref == nil ) or
             ( passedt.ref == ""  )) then
            if (( passedt["naptan:Indicator"] ~= nil )  and
                ( passedt["naptan:Indicator"] ~= ""  )) then
               passedt.name = passedt["naptan:Indicator"]
            end
         else -- ref not nil
            if (( passedt["naptan:Indicator"] == nil ) or
                ( passedt["naptan:Indicator"] == ""  )) then
               passedt.name = passedt.ref
            else
               passedt.name = passedt.ref .. " " .. passedt["naptan:Indicator"]
            end
         end
      else -- name not nil
         if (( passedt.ref == nil ) or
             ( passedt.ref == ""  )) then
            if (( passedt["naptan:Indicator"] ~= nil )  and
                ( passedt["naptan:Indicator"] ~= ""  )) then
               passedt.name = passedt.name .. " " .. passedt["naptan:Indicator"]
            end
         else -- neither name nor ref nil
            if (( passedt["naptan:Indicator"] == nil )  or
                ( passedt["naptan:Indicator"] == ""  )) then
               passedt.name = passedt.name .. " " .. passedt.ref
            else -- naptanCIndicator not nil
               passedt.name = passedt.name .. " " .. passedt.ref .. " " .. passedt["naptan:Indicator"]
            end
         end
      end

      if (( passedt.name == nil ) or
          ( passedt.name == ""  )) then
         if (( passedt.website ~= nil ) and
             ( passedt.website ~= ""  )) then
            passedt.ele = passedt.website
         end
      else -- name not nil
         if (( passedt.website == nil ) or
             ( passedt.website == ""  )) then
            passedt.ele = passedt.name
         else -- website not nil
            passedt.ele = passedt.name .. " " .. passedt.website
         end
      end

-- ----------------------------------------------------------------------------
-- Can we set a "departures_board" value based on a "timetable" value?
-- ----------------------------------------------------------------------------
      if ((( passedt.departures_board == nil         )  or
           ( passedt.departures_board == ""          )) and
          (  passedt.timetable        == "real_time"  )) then
         passedt.departures_board = "realtime"
      end

      if ((( passedt.departures_board == nil   )  or
           ( passedt.departures_board == ""    )) and
          (  passedt.timetable        == "yes"  )) then
         passedt.departures_board = "timetable"
      end

-- ----------------------------------------------------------------------------
-- Based on the other tags that are set, 
-- let's use different symbols for bus stops
-- ----------------------------------------------------------------------------
      if (( passedt.departures_board              == "realtime"                     ) or
          ( passedt.departures_board              == "timetable; realtime"          ) or
          ( passedt.departures_board              == "realtime;timetable"           ) or
          ( passedt.departures_board              == "timetable;realtime"           ) or
          ( passedt.departures_board              == "realtime_multiline"           ) or
          ( passedt.departures_board              == "realtime,timetable"           ) or
          ( passedt.departures_board              == "multiline"                    ) or
          ( passedt.departures_board              == "realtime_multiline;timetable" ) or
          ( passedt.passenger_information_display == "realtime"                     )) then
         if (( passedt["departures_board:speech_output"]              == "yes" ) or
             ( passedt["passenger_information_display:speech_output"] == "yes" )) then
            passedt.highway = "bus_stop_speech_realtime"
         else
            passedt.highway = "bus_stop_realtime"
         end
      else
         if (( passedt.departures_board              == "timetable"        ) or
             ( passedt.departures_board              == "schedule"         ) or
             ( passedt.departures_board              == "separate"         ) or
             ( passedt.departures_board              == "paper timetable"  ) or
             ( passedt.departures_board              == "yes"              ) or
             ( passedt.passenger_information_display == "timetable"        ) or
             ( passedt.passenger_information_display == "yes"              )) then
            if (( passedt["departures_board:speech_output"]              == "yes" ) or
                ( passedt["passenger_information_display:speech_output"] == "yes" )) then
               passedt.highway = "bus_stop_speech_timetable"
            else
               passedt.highway = "bus_stop_timetable"
            end
         else
            if (( passedt.flag               == "no"  ) or
                ( passedt.pole               == "no"  ) or
                ( passedt.physically_present == "no"  ) or
                ( passedt["naptan:BusStopType"] == "CUS" )) then
               passedt.highway = "bus_stop_nothing"
            else
               passedt.highway = "bus_stop_pole"
            end
         end
      end
   end

-- ----------------------------------------------------------------------------
-- Names for vacant shops
-- ----------------------------------------------------------------------------
   if ((((( passedt["disused:shop"]    ~= nil        )    and
          ( passedt["disused:shop"]    ~= ""         ))   or
         (( passedt["disused:amenity"] ~= nil        )    and
          ( passedt["disused:amenity"] ~= ""         )))  and
         (  passedt["disused:amenity"] ~= "fountain"   )  and
         (  passedt["disused:amenity"] ~= "parking"    )  and
         (( passedt.shop            == nil         )   or
          ( passedt.shop            == ""          ))  and
         (( passedt.amenity         == nil         )   or
          ( passedt.amenity         == ""          ))) or
       (    passedt.office          == "vacant"      ) or
       (    passedt.office          == "disused"     ) or
       (    passedt.shop            == "disused"     ) or
       (    passedt.shop            == "abandoned"   ) or
       ((   passedt.shop            ~= nil          )  and
        (   passedt.shop            ~= ""           )  and
        (   passedt.opening_hours   == "closed"     ))) then
      passedt.shop = "vacant"
   end

   if ( passedt.shop == "vacant" ) then
      if ((( passedt.name     == nil )  or
           ( passedt.name     == ""  )) and
          (  passedt.old_name ~= nil  ) and
          (  passedt.old_name ~= ""   )) then
         passedt.name     = passedt.old_name
         passedt.old_name = nil
      end

      if ((( passedt.name     == nil   )  or
           ( passedt.name     == ""    )) and
          (  passedt.former_name ~= nil ) and
          (  passedt.former_name ~= ""  )) then
         passedt.name     = passedt.former_name
         passedt.former_name = nil
      end

      if (( passedt.name == nil )  or
          ( passedt.name == ""  )) then
         passedt.ref = "(vacant)"
      else
         passedt.ref = "(vacant: " .. passedt.name .. ")"
         passedt.name = nil
      end
   end

-- ----------------------------------------------------------------------------
-- Remove icon for public transport and animal field shelters and render as
-- "roof" (if they are a way).
-- "roof" isn't rendered for nodes, so this has the effect of suppressing
-- public_transport shelters and shopping_cart shelters on nodes.
-- shopping_cart, parking and animal_shelter aren't really a "shelter" type 
-- that we are interested in (for humans).  There are no field or parking 
-- shelters on nodes in GB/IE.
-- ----------------------------------------------------------------------------
   if (( passedt.amenity      == "shelter"            ) and
       (( passedt.shelter_type == "public_transport" )  or
        ( passedt.shelter_type == "field_shelter"    )  or
        ( passedt.shelter_type == "shopping_cart"    )  or
        ( passedt.shelter_type == "trolley_park"     )  or
        ( passedt.shelter_type == "parking"          )  or
        ( passedt.shelter_type == "animal_shelter"   ))) then
      passedt.amenity = nil
      if (( passedt.building == nil )  or
          ( passedt.building == ""  )) then
         passedt.building = "roof"
      end
   end

  if (( passedt.amenity      == "shelter"            ) and
      ( passedt.shelter_type == "bicycle_parking"    )) then
      passedt.amenity = "bicycle_parking"
      if (( passedt.building == nil )  or
          ( passedt.building == ""  )) then
         passedt.building = "roof"
      end
   end

-- ----------------------------------------------------------------------------
-- Prevent highway=raceway from appearing in the polygon table.
-- ----------------------------------------------------------------------------
   if ( passedt.highway == "raceway" ) then
      passedt.area = "no"
   end

-- ----------------------------------------------------------------------------
-- Drop some highway areas - "track" etc. areas wherever I have seen them are 
-- garbage.
-- "footway" (pedestrian areas) and "service" (e.g. petrol station forecourts)
-- tend to be OK.  Other options tend not to occur.
-- ----------------------------------------------------------------------------
   if ((( passedt.highway == "track"          )  or
        ( passedt.highway == "leisuretrack"   )  or
        ( passedt.highway == "gallop"         )  or
        ( passedt.highway == "residential"    )  or
        ( passedt.highway == "unclassified"   )  or
        ( passedt.highway == "tertiary"       )) and
       (  passedt.area    == "yes"             )) then
      passedt.highway = nil
   end

-- ----------------------------------------------------------------------------
-- Show traffic islands as kerbs
-- ----------------------------------------------------------------------------
   if (( passedt["area:highway"] == "traffic_island" )  or
       ( passedt.landuse      == "traffic_island" )) then
      passedt.barrier = "kerb"
   end

-- ----------------------------------------------------------------------------
-- name and addr:housename
-- If a building that isn't something else has a name but no addr:housename,
-- use that there.
--
-- There are some odd combinations of "place" and "building" - we remove 
-- "place" in those cases
-- ----------------------------------------------------------------------------
   if ((  passedt.building       ~= nil   ) and
       (  passedt.building       ~= ""    ) and
       (  passedt.building       ~= "no"  ) and
       (( passedt["addr:housename"] == nil  )  or
        ( passedt["addr:housename"] == ""   )) and
       (  passedt.name           ~= nil   ) and
       (  passedt.name           ~= ""    ) and
       (( passedt.aeroway        == nil  )  or
        ( passedt.aeroway        == ""   )) and
       (( passedt.amenity        == nil  )  or
        ( passedt.amenity        == ""   )) and
       (( passedt.barrier        == nil  )  or
        ( passedt.barrier        == ""   )) and
       (( passedt.craft          == nil  )  or
        ( passedt.craft          == ""   )) and
       (( passedt.emergency      == nil  )  or
        ( passedt.emergency      == ""   )) and
       (( passedt.highway        == nil  )  or
        ( passedt.highway        == ""   )) and
       (( passedt.historic       == nil  )  or
        ( passedt.historic       == ""   )) and
       (( passedt.landuse        == nil  )  or
        ( passedt.landuse        == ""   )) and
       (( passedt.leisure        == nil  )  or
        ( passedt.leisure        == ""   )) and
       (( passedt.man_made       == nil  )  or
        ( passedt.man_made       == ""   )) and
       (( passedt.natural        == nil  )  or
        ( passedt.natural        == ""   )) and
       (( passedt.office         == nil  )  or
        ( passedt.office         == ""   )) and
       (( passedt.railway        == nil  )  or
        ( passedt.railway        == ""   )) and
       (( passedt.shop           == nil  )  or
        ( passedt.shop           == ""   )) and
       (( passedt.sport          == nil  )  or
        ( passedt.sport          == ""   )) and
       (( passedt.tourism        == nil  )  or
        ( passedt.tourism        == ""   )) and
       (( passedt.waterway       == nil  )  or
        ( passedt.waterway       == ""   ))) then
      passedt["addr:housename"] = passedt.name
      passedt.name  = nil
      passedt.place = nil
   end

-- ----------------------------------------------------------------------------
-- addr:unit
-- ----------------------------------------------------------------------------
   if (( passedt["addr:unit"] ~= nil ) and
       ( passedt["addr:unit"] ~= ""  )) then
      if (( passedt["addr:housenumber"] ~= nil ) and
          ( passedt["addr:housenumber"] ~= ""  )) then
         passedt["addr:housenumber"] = passedt["addr:unit"] .. ", " .. passedt["addr:housenumber"]
      else
         passedt["addr:housenumber"] = passedt["addr:unit"]
      end
   end

-- ----------------------------------------------------------------------------
-- Shops etc. with icons already - just add "unnamedcommercial" landuse.
-- The exception is where landuse is set to something we want to keep.
-- ----------------------------------------------------------------------------
   if (((( passedt.shop       ~= nil                 )   and
         ( passedt.shop       ~= ""                  ))  or
        (( passedt.amenity    ~= nil                 )   and
         ( passedt.amenity    ~= ""                  )   and
         ( passedt.amenity    ~= "holy_well"         )   and
         ( passedt.amenity    ~= "holy_spring"       )   and
         ( passedt.amenity    ~= "biergarten"        )   and
         ( passedt.amenity    ~= "pitch_baseball"    )   and
         ( passedt.amenity    ~= "pitch_basketball"  )   and
         ( passedt.amenity    ~= "pitch_chess"       )   and
         ( passedt.amenity    ~= "pitch_cricket"     )   and
         ( passedt.amenity    ~= "pitch_climbing"    )   and
         ( passedt.amenity    ~= "pitch_athletics"   )   and
         ( passedt.amenity    ~= "pitch_boules"      )   and
         ( passedt.amenity    ~= "pitch_bowls"       )   and
         ( passedt.amenity    ~= "pitch_croquet"     )   and
         ( passedt.amenity    ~= "pitch_cycling"     )   and
         ( passedt.amenity    ~= "pitch_equestrian"  )   and
         ( passedt.amenity    ~= "pitch_gaa"         )   and
         ( passedt.amenity    ~= "pitch_hockey"      )   and
         ( passedt.amenity    ~= "pitch_multi"       )   and
         ( passedt.amenity    ~= "pitch_netball"     )   and
         ( passedt.amenity    ~= "pitch_polo"        )   and
         ( passedt.amenity    ~= "pitch_shooting"    )   and
         ( passedt.amenity    ~= "pitch_rugby"       )   and
         ( passedt.amenity    ~= "pitch_skateboard"  )   and
         ( passedt.amenity    ~= "pitch_soccer"      )   and
         ( passedt.amenity    ~= "pitch_tabletennis" )   and
         ( passedt.amenity    ~= "pitch_tennis"      ))  or
        (  passedt.tourism    == "hotel"              )  or
        (  passedt.tourism    == "guest_house"        )  or
        (  passedt.tourism    == "viewpoint"          )  or
        (  passedt.tourism    == "museum"             )  or
        (  passedt.tourism    == "hostel"             )  or
        (  passedt.tourism    == "gallery"            )  or
        (  passedt.tourism    == "apartment"          )  or
        (  passedt.tourism    == "bed_and_breakfast"  )  or
        (  passedt.tourism    == "motel"              )  or
        (  passedt.tourism    == "theme_park"         )) and
       (   passedt.leisure    ~= "garden"              )) then
      if (( passedt.landuse == nil ) or
          ( passedt.landuse == ""  )) then
         passedt.landuse = "unnamedcommercial"
      end
   end
end -- consolidate_lua_04_t( passedt )


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


function append_accommodation_t( passedt )
   if (( passedt.accommodation ~= nil  ) and
       ( passedt.accommodation ~= ""   ) and
       ( passedt.accommodation ~= "no" )) then
      passedt.amenity = passedt.amenity .. "y"
   else
      passedt.amenity = passedt.amenity .. "n"
   end
end -- append_accommodation_t( passedt )


function append_wheelchair_t( passedt )
   if ( passedt.wheelchair == "yes" ) then
      passedt.amenity = passedt.amenity .. "y"
   else
      if ( passedt.wheelchair == "limited" ) then
         passedt.amenity = passedt.amenity .. "l"
      else
         if ( passedt.wheelchair == "no" ) then
            passedt.amenity = passedt.amenity .. "n"
         else
            passedt.amenity = passedt.amenity .. "d"
         end
      end
   end
end -- append_wheelchair_t( passedt )


function append_beer_garden_t( passedt )
   if ( passedt.beer_garden == "yes" ) then
      passedt.amenity = passedt.amenity .. "g"
   else
      if ( passedt.outdoor_seating == "yes" ) then
         passedt.amenity = passedt.amenity .. "o"
      else
         passedt.amenity = passedt.amenity .. "d"
      end
   end
end -- append_beer_garden_t( passedt )


-- ----------------------------------------------------------------------------
-- Designed to set "ele" to a new value
-- ----------------------------------------------------------------------------
function append_inscription_t( passedt )
   if (( passedt.name ~= nil ) and
       ( passedt.name ~= ""  )) then
      passedt.ele = passedt.name
   else
      passedt.ele = nil
   end

   if (( passedt.inscription ~= nil ) and
       ( passedt.inscription ~= ""  )) then
       if (( passedt.ele == nil ) or
           ( passedt.ele == ""  )) then
           passedt.ele = passedt.inscription
       else
           passedt.ele = passedt.ele .. " " .. passedt.inscription
       end
   end
end -- append_inscription_t( passedt )


-- ----------------------------------------------------------------------------
-- Designed to append any directions to an "ele" that might already have
-- "inscription" in it.
-- ----------------------------------------------------------------------------
function append_directions_t( passedt )
   if (( passedt.direction_north ~= nil ) and
       ( passedt.direction_north ~= ""  )) then
      if (( passedt.ele == nil ) or
          ( passedt.ele == ""  )) then
         passedt.ele = "N: " .. passedt.direction_north
      else
         passedt.ele = passedt.ele .. ", N: " .. passedt.direction_north
      end
   end

   if (( passedt.direction_northeast ~= nil ) and
       ( passedt.direction_northeast ~= ""  )) then
      if (( passedt.ele == nil ) or
          ( passedt.ele == ""  )) then
         passedt.ele = "NE: " .. passedt.direction_northeast
      else
         passedt.ele = passedt.ele .. ", NE: " .. passedt.direction_northeast
      end
   end

   if (( passedt.direction_east ~= nil ) and
       ( passedt.direction_east ~= ""  )) then
      if (( passedt.ele == nil ) or
          ( passedt.ele == ""  )) then
         passedt.ele = "E: " .. passedt.direction_east
      else
         passedt.ele = passedt.ele .. ", E: " .. passedt.direction_east
      end
   end

   if (( passedt.direction_southeast ~= nil ) and
       ( passedt.direction_southeast ~= ""  )) then
      if (( passedt.ele == nil ) or
          ( passedt.ele == ""  )) then
         passedt.ele = "SE: " .. passedt.direction_southeast
      else
         passedt.ele = passedt.ele .. ", SE: " .. passedt.direction_southeast
      end
   end

   if (( passedt.direction_south ~= nil ) and
       ( passedt.direction_south ~= ""  )) then
      if (( passedt.ele == nil ) or
          ( passedt.ele == ""  )) then
         passedt.ele = "S: " .. passedt.direction_south
      else
         passedt.ele = passedt.ele .. ", S: " .. passedt.direction_south
      end
   end

   if (( passedt.direction_southwest ~= nil ) and
       ( passedt.direction_southwest ~= ""  )) then
      if (( passedt.ele == nil ) or
          ( passedt.ele == ""  )) then
         passedt.ele = "SW: " .. passedt.direction_southwest
      else
         passedt.ele = passedt.ele .. ", SW: " .. passedt.direction_southwest
      end
   end

   if (( passedt.direction_west ~= nil ) and
       ( passedt.direction_west ~= ""  )) then
      if (( passedt.ele == nil ) or
          ( passedt.ele == ""  )) then
         passedt.ele = "W: " .. passedt.direction_west
      else
         passedt.ele = passedt.ele .. ", W: " .. passedt.direction_west
      end
   end

   if (( passedt.direction_northwest ~= nil ) and
       ( passedt.direction_northwest ~= ""  )) then
      if (( passedt.ele == nil ) or
          ( passedt.ele == ""  )) then
         passedt.ele = "NW: " .. passedt.direction_northwest
      else
         passedt.ele = passedt.ele .. ", NW: " .. passedt.direction_northwest
      end
   end
end -- append_directions_t( passedt )


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