# -----------------------------------------------------------------------------
# update_render.sh
# Designed to update rendering database and related styles to latest version.
# Note that there's little error checking in here yet.  It also won't run on
# e.g. an NTFS file system, and makes a number of assumptions abot where 
# things are.
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
file_prefix=british-isles
#file_prefix=great-britain
file_page=http://download.geofabrik.de/europe/${file_prefix}.html
file_url=http://download.geofabrik.de/europe/${file_prefix}-latest.osm.pbf
#
#file_prefix=england
#file_page=http://download.geofabrik.de/europe/great-britain/england.html
#file_url=http://download.geofabrik.de/europe/great-britain/england-latest.osm.pbf
#
#file_prefix=cambridgeshire
#file_prefix=cheshire
#file_prefix=derbyshire
#file_prefix=herefordshire
#file_prefix=leicestershire
#file_prefix=nottinghamshire
#file_prefix=staffordshire
#file_page=http://download.geofabrik.de/europe/great-britain/england/${file_prefix}.html
#file_url=http://download.geofabrik.de/europe/great-britain/england/${file_prefix}-latest.osm.pbf
#
# Remove the openstreetmap-tiles-update-expire entry from the crontab.
# Note that this matches a comment on the crontab line.
#
crontab -u $local_user -l > local_user_crontab_safe.$$
grep -v "\#CONTROLLED BY update_render.sh" local_user_crontab_safe.$$ > local_user_crontab_new.$$
crontab -u $local_user local_user_crontab_new.$$
rm local_user_crontab_new.$$
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
# How much disk space are we currently using?
#
df
#
# When was the target file last modified?
#
cd /home/${local_user}/data
wget $file_page -O file_page.$$
grep " and contains all OSM data up to " file_page.$$ | sed "s/.*and contains all OSM data up to //" | sed "s/. File size.*//" > last_modified.$$
#
file_extension=`cat last_modified.$$`
#
if test -e ${file_prefix}_${file_extension}.osm.pbf
then
    echo "File already downloaded"
else
    wget $file_url -O ${file_prefix}_${file_extension}.osm.pbf
fi
#
# Stop rendering to free up memory
#
/etc/init.d/renderd stop
/etc/init.d/apache2 stop
#
# Run osm2pgsql
#
sudo -u ${local_user} osm2pgsql --create --slim -d gis -C 2500 --number-processes 2 -S /home/${local_user}/src/openstreetmap-carto-AJT/openstreetmap-carto.style --multi-geometry --tag-transform-script /home/${local_user}/src/SomeoneElse-style/style.lua /home/${local_user}/data/${file_prefix}_${file_extension}.osm.pbf
#
sudo -u ${local_user} osm2pgsql --append --slim -d gis -C 250 --number-processes 2 -S /home/${local_user}/src/openstreetmap-carto-AJT/openstreetmap-carto.style --multi-geometry --tag-transform-script /home/${local_user}/src/SomeoneElse-style/style.lua /home/${local_user}/src/SomeoneElse-style-legend/legend_roads.osm
#
sudo -u ${local_user} osm2pgsql --append --slim -d gis -C 250 --number-processes 2 -S /home/${local_user}/src/openstreetmap-carto-AJT/openstreetmap-carto.style --multi-geometry --tag-transform-script /home/${local_user}/src/SomeoneElse-style/style.lua /home/${local_user}/src/SomeoneElse-style-legend/legend_pub.osm
#
# Reinitialise updating
#
rm -rf /var/lib/mod_tile/.osmosis.old
mv /var/lib/mod_tile/.osmosis /var/lib/mod_tile/.osmosis.old
sudo -u ${local_user} /home/${local_user}/src/mod_tile/openstreetmap-tiles-update-expire ${file_extension}
/etc/init.d/renderd restart
/etc/init.d/apache2 restart
#
# Reinstate the crontab
#
crontab -u $local_user local_user_crontab_safe.$$
# 
# And final tidying up
#
date | mail -s "Database reload complete on `hostname`" ${local_user}
rm file_page.$$
rm last_modified.$$
rm update_render.running
#
