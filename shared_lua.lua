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
         ( passed_level   == "0"         )) and
        (( passed_layer   == nil         )  or
         ( passed_layer   == "0"         ))) then
       returned_highway = "path"
    end

    return returned_highway
end -- fix_corridors()

-- ----------------------------------------------------------------------------
-- "Different names on each side of the street" and
-- "name:en" is set by "name" is not.
-- ----------------------------------------------------------------------------
function set_name_left_right_en( passed_name, passed_name_left, passed_name_right, passed_name_en )
    local returned_name = passed_name

    if (( passed_name_left  ~= nil ) and
        ( passed_name_right ~= nil )) then
       returned_name = passed_name_left .. " / " .. passed_name_right
    end

    if (( returned_name  == nil ) and
        ( passed_name_en ~= nil )) then
       passed_name = passed_name_en
    end

    return returned_name
end
