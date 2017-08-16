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
#file_prefix=scotland
#file_prefix=wales
#file_page=http://download.geofabrik.de/europe/great-britain/${file_prefix}.html
#file_url=http://download.geofabrik.de/europe/great-britain/${file_prefix}-latest.osm.pbf
#
#file_prefix=cambridgeshire
#file_prefix=cheshire
#file_prefix=derbyshire
#file_prefix=herefordshire
#file_prefix=leicestershire
#file_prefix=nottinghamshire
#file_prefix=staffordshire
#file_prefix=worcestershire
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
# Convert a Welsh name portion to Welsh and and English portion to English
#
osmosis  --read-pbf ${file_prefix}_${file_extension}.osm.pbf  --bounding-box left=-4.82 bottom=52.02 right=-3.34 top=53.69 --write-pbf welshlangpart_${file_extension}_before.pbf
#
osmosis --read-pbf welshlangpart_${file_extension}_before.pbf --tag-transform /home/${local_user}/src/SomeoneElse-style/transform_cy.xml --write-pbf welshlangpart_${file_extension}_after.pbf
#
# Likewise, Scots Gaelic
#
osmosis  --read-pbf ${file_prefix}_${file_extension}.osm.pbf  --bounding-box left=-9.23 bottom=55.56 right=-5.7 top=59.92 --write-pbf scotsgdlangpart_${file_extension}_before.pbf
#
osmosis --read-pbf scotsgdlangpart_${file_extension}_before.pbf --tag-transform /home/${local_user}/src/SomeoneElse-style/transform_gd.xml --write-pbf scotsgdlangpart_${file_extension}_after.pbf
#
osmosis --read-pbf ${file_prefix}_${file_extension}.osm.pbf --tag-transform /home/${local_user}/src/SomeoneElse-style/transform_en.xml --write-pbf englangpart_${file_extension}_after.pbf
#
# Merge them
#
osmosis --read-pbf welshlangpart_${file_extension}_after.pbf --read-pbf englangpart_${file_extension}_after.pbf  --merge --write-pbf  langs_${file_extension}_merged.pbf
#
# Run osm2pgsql
#
sudo -u ${local_user} osm2pgsql --create --slim -d gis -C 2500 --number-processes 2 -S /home/${local_user}/src/openstreetmap-carto-AJT/openstreetmap-carto.style --multi-geometry --tag-transform-script /home/${local_user}/src/SomeoneElse-style/style.lua langs_${file_extension}_merged.pbf
#
sudo -u ${local_user} osm2pgsql --append --slim -d gis -C 250 --number-processes 2 -S /home/${local_user}/src/openstreetmap-carto-AJT/openstreetmap-carto.style --multi-geometry --tag-transform-script /home/${local_user}/src/SomeoneElse-style/style.lua /home/${local_user}/src/SomeoneElse-style-legend/legend_roads.osm
#
sudo -u ${local_user} osm2pgsql --append --slim -d gis -C 250 --number-processes 2 -S /home/${local_user}/src/openstreetmap-carto-AJT/openstreetmap-carto.style --multi-geometry --tag-transform-script /home/${local_user}/src/SomeoneElse-style/style.lua /home/${local_user}/src/SomeoneElse-style-legend/legend_pub.osm
#
# Tidy temporary files
#
rm welshlangpart_${file_extension}_before.pbf welshlangpart_${file_extension}_after.pbf englangpart_${file_extension}_after.pbf scotsgdlangpart_${file_extension}_before.pbf scotsgdlangpart_${file_extension}_after.pbf langs_${file_extension}_merged.pbf
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
