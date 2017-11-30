# -----------------------------------------------------------------------------
# update_carto.sh
# As per update_render.sh, but only does not reload the database - it only
# deals with changes to the carto style.
# -----------------------------------------------------------------------------
#
# The local user account we are using
#
local_user=renderaccount
#
# First things first - is another copy of the script already running?
#
cd /home/${local_user}/data
if test -e update_render.running
then
    echo update_render.running exists so exiting
    exit
else
    touch update_render.running
fi
#
# Next get the latest versions of each part of the map style
#
cd /home/${local_user}/src/SomeoneElse-style
pwd
sudo -u ${local_user} git pull
#
cd /home/${local_user}/src/SomeoneElse-style-legend
pwd
sudo -u ${local_user} git pull
#
cd /home/${local_user}/src/openstreetmap-carto-AJT
pwd
sudo -u ${local_user} git pull
carto project.mml > mapnik.xml
#
/etc/init.d/renderd restart
/etc/init.d/apache2 restart
#
rm -rf /var/lib/mod_tile/ajt/?
rm -rf /var/lib/mod_tile/ajt/??
#
# And final tidying up
#
cd /home/${local_user}/data
rm update_render.running
#
