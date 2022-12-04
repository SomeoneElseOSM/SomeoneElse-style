#!/bin/bash
# -----------------------------------------------------------------------------
# update_carto.sh
# As per update_render.sh, but only does not reload the database - it only
# deals with changes to the carto style.
# -----------------------------------------------------------------------------
#
# The local user account we are using
# "local_filesystem_user" is whichever non-root account is used to fetch from
# github.
# On Debian 11 or above and Ubuntu 21.04 and above,
# "local_renderd_user" will probably be "_renderd"
#
local_filesystem_user=ajtown
local_renderd_user=_renderd
#
# No reference to "local_database=gis3" here, but see
# "rm -rf /var/cache/renderd/tiles/ajt3/?" below.
#
# First things first - define some shared functions
#
final_tidy_up()
{
    cd /home/${local_filesystem_user}/data
    rm update_render.running
}

#
# Before anything else, is an update script for the previous database still running?
#
if [[ -f /var/cache/renderd/pyosmium.gis/call_pyosmium.running ]]
then
    echo "call_pyosmium still running; /var/cache/renderd/pyosmium.gis/call_pyosmium.running exists"
    exit 1
fi
#
# Next, is another copy of the script already running?
#
cd /home/${local_filesystem_user}/data
if test -e update_render.running
then
    echo update_render.running exists so exiting
    exit 1
else
    touch update_render.running
fi
#
# Next get the latest versions of each part of the map style.
#
# This is run from sudo without a connection to an authentication agent, 
# so it makes sense for the git config url to be "https" and the pushurl "git".  
# See https://stackoverflow.com/a/73836045/8145448
#
cd /home/${local_filesystem_user}/src/SomeoneElse-style
pwd
sudo -u ${local_filesystem_user} git pull
#
cd /home/${local_filesystem_user}/src/SomeoneElse-style-legend
pwd
sudo -u ${local_filesystem_user} git pull
#
cd /home/${local_filesystem_user}/src/openstreetmap-carto-AJT
pwd
sudo -u ${local_filesystem_user} git pull
#
# We create 3 XML files:
#
# The normal mapnik.xml, which uses database gis.
# An identical mapnik3.xml, but which uses database gis3.
#
# Also, a "novispaths" mapnik.xml, based on the very simple layers at
# https://github.com/SomeoneElseOSM/openstreetmap-carto-AJT/tree/master/novispaths
# This is a separate tile layer so that it can be used as an overlay.
#
carto project.mml > mapnik.xml
sed "s/\[gis\]/[gis3]/" mapnik.xml > mapnik3.xml
cd novispaths
carto project.mml > mapnik.xml
cd ..
#
/etc/init.d/renderd restart
/etc/init.d/apache2 restart
#
rm -rf /var/cache/renderd/tiles/ajt3/?
rm -rf /var/cache/renderd/tiles/ajt3/??
#
# And final tidying up
#
final_tidy_up
#
