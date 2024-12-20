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
       ( passedt.footCphysical    == "no"         )) then
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

end -- consolidate_lua_01_t( passedt )


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