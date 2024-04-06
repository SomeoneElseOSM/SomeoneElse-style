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
end


