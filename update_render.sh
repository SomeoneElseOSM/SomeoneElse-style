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
# -----------------------------------------------------------------------------
# This script works with several different geographic regions.  
# Areas within Great Britain can be processed into CY, GD and EN speaking 
# areas and are handled by the "1" versions of e.v.s.
# Ireland, if needed, needs no language processing and is is handled by the 
# "2" versions of e.v.s.
# The results are then merged together.
# ----------------------------------------------------------------------------
# What's the first file that we are interested in?
#
#file_prefix1=british-isles
file_prefix1=great-britain
file_page1=http://download.geofabrik.de/europe/${file_prefix1}.html
file_url1=http://download.geofabrik.de/europe/${file_prefix1}-latest.osm.pbf
#
#file_prefix1=england
#file_prefix1=scotland
#file_prefix1=wales
#file_page1=http://download.geofabrik.de/europe/great-britain/${file_prefix1}.html
#file_url1=http://download.geofabrik.de/europe/great-britain/${file_prefix1}-latest.osm.pbf
#
#file_prefix1=bedfordshire
#file_prefix1=berkshire
#file_prefix1=bristol
#file_prefix1=buckinghamshire
#file_prefix1=cambridgeshire
#file_prefix1=cheshire
#file_prefix1=cornwall
#file_prefix1=cumbria
#file_prefix1=derbyshire
#file_prefix1=devon
#file_prefix1=dorset
#file_prefix1=durham
#file_prefix1=east-sussex
#file_prefix1=east-yorkshire-with-hull
#file_prefix1=essex
#file_prefix1=gloucestershire
#file_prefix1=greater-london
#file_prefix1=greater-manchester
#file_prefix1=hampshire
#file_prefix1=herefordshire
#file_prefix1=hertfordshire
#file_prefix1=isle-of-wight
#file_prefix1=kent
#file_prefix1=lancashire
#file_prefix1=leicestershire
#file_prefix1=lincolnshire
#file_prefix1=merseyside
#file_prefix1=norfolk
#file_prefix1=north-yorkshire
#file_prefix1=northamptonshire
#file_prefix1=northumberland
#file_prefix1=nottinghamshire
#file_prefix1=oxfordshire
#file_prefix1=rutland
#file_prefix1=shropshire
#file_prefix1=somerset
#file_prefix1=south-yorkshire
#file_prefix1=staffordshire
#file_prefix1=suffolk
#file_prefix1=surrey
#file_prefix1=tyne-and-wear
#file_prefix1=warwickshire
#file_prefix1=west-midlands
#file_prefix1=west-sussex
#file_prefix1=west-yorkshire
#file_prefix1=wiltshire
#file_prefix1=worcestershire
#file_page1=http://download.geofabrik.de/europe/great-britain/england/${file_prefix1}.html
#file_url1=http://download.geofabrik.de/europe/great-britain/england/${file_prefix1}-latest.osm.pbf
#
#file_prefix1=new-york
#file_prefix1=oregon
#file_page1=http://download.geofabrik.de/north-america/us/${file_prefix1}.html
#file_url1=http://download.geofabrik.de/north-america/us/${file_prefix1}-latest.osm.pbf
#
#file_prefix1=argentina
#file_page1=http://download.geofabrik.de/south-america/${file_prefix1}.html
#file_url1=http://download.geofabrik.de/south-america/${file_prefix1}-latest.osm.pbf
#
# What's the second file that we are interested in?
# Note that if this is commented out, also change the "merge" below to not use it.
#
file_prefix2=ireland-and-northern-ireland
#file_prefix2=isle-of-man
file_page2=http://download.geofabrik.de/europe/${file_prefix2}.html
file_url2=http://download.geofabrik.de/europe/${file_prefix2}-latest.osm.pbf
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
cd /home/${local_user}/data
#
# When was the first target file last modified?
#
if [ "$1" = "current" ]
then
    echo "Using current data"
    ls -t | grep "${file_prefix1}_" | head -1 | sed "s/${file_prefix1}_//" | sed "s/.osm.pbf//" > last_modified1.$$
else
    wget $file_page1 -O file_page1.$$
    grep " and contains all OSM data up to " file_page1.$$ | sed "s/.*and contains all OSM data up to //" | sed "s/. File size.*//" > last_modified1.$$
    rm file_page1.$$
fi
#
file_extension1=`cat last_modified1.$$`
#
if test -e ${file_prefix1}_${file_extension1}.osm.pbf
then
    echo "File1 already downloaded"
else
    wget $file_url1 -O ${file_prefix1}_${file_extension1}.osm.pbf
fi
#
# When was the second target file last modified?
#
if [ "$1" = "current" ]
then
    ls -t | grep "${file_prefix2}_" | head -1 | sed "s/${file_prefix2}_//" | sed "s/.osm.pbf//" > last_modified2.$$
else
    wget $file_page2 -O file_page2.$$
    grep " and contains all OSM data up to " file_page2.$$ | sed "s/.*and contains all OSM data up to //" | sed "s/. File size.*//" > last_modified2.$$
    rm file_page2.$$
fi
#
file_extension2=`cat last_modified2.$$`
#
if test -e ${file_prefix2}_${file_extension2}.osm.pbf
then
    echo "File2 already downloaded"
else
    wget $file_url2 -O ${file_prefix2}_${file_extension2}.osm.pbf
fi
#
# Stop rendering to free up memory
#
/etc/init.d/renderd stop
/etc/init.d/apache2 stop
#
# Welsh, English and Scottish names need to be converted to "cy or en", "en" and "gd or en" respectively.
# First, convert a Welsh name portion intoto Welsh
#
osmosis  --read-pbf ${file_prefix1}_${file_extension1}.osm.pbf --bounding-polygon file="/home/${local_user}/src/SomeoneElse-style/welsh_areas.poly" --write-pbf welshlangpart_${file_extension1}_before.pbf
#
osmosis --read-pbf welshlangpart_${file_extension1}_before.pbf --tag-transform /home/${local_user}/src/SomeoneElse-style/transform_cy.xml --write-pbf welshlangpart_${file_extension1}_after.pbf
#
# Likewise, Scots Gaelic
#
osmosis  --read-pbf ${file_prefix1}_${file_extension1}.osm.pbf  --bounding-box left=-9.23 bottom=55.56 right=-5.7 top=59.92 --write-pbf scotsgdlangpart_${file_extension1}_before.pbf
#
osmosis --read-pbf scotsgdlangpart_${file_extension1}_before.pbf --tag-transform /home/${local_user}/src/SomeoneElse-style/transform_gd.xml --write-pbf scotsgdlangpart_${file_extension1}_after.pbf
#
# Convert the remaining file to "English"
#
osmosis --read-pbf ${file_prefix1}_${file_extension1}.osm.pbf --tag-transform /home/${local_user}/src/SomeoneElse-style/transform_en.xml --write-pbf englangpart_${file_extension1}_after.pbf
#
# Note that "file2", if we need it, does not need processing.
#
# Merge them, in such a way that the cy and gd files take precedence over the en one.
#
osmosis --read-pbf welshlangpart_${file_extension1}_after.pbf --read-pbf scotsgdlangpart_${file_extension1}_after.pbf --read-pbf englangpart_${file_extension1}_after.pbf  --read-pbf ${file_prefix2}_${file_extension2}.osm.pbf --merge --merge --merge --write-pbf  langs_${file_extension1}_merged.pbf
#
# Run osm2pgsql
#
sudo -u ${local_user} osm2pgsql --create --slim -d gis -C 2500 --number-processes 2 -S /home/${local_user}/src/openstreetmap-carto-AJT/openstreetmap-carto.style --multi-geometry --tag-transform-script /home/${local_user}/src/SomeoneElse-style/style.lua langs_${file_extension1}_merged.pbf
#
sudo -u ${local_user} osm2pgsql --append --slim -d gis -C 250 --number-processes 2 -S /home/${local_user}/src/openstreetmap-carto-AJT/openstreetmap-carto.style --multi-geometry --tag-transform-script /home/${local_user}/src/SomeoneElse-style/style.lua /home/${local_user}/src/SomeoneElse-style-legend/legend_roads.osm
#
sudo -u ${local_user} osm2pgsql --append --slim -d gis -C 250 --number-processes 2 -S /home/${local_user}/src/openstreetmap-carto-AJT/openstreetmap-carto.style --multi-geometry --tag-transform-script /home/${local_user}/src/SomeoneElse-style/style.lua /home/${local_user}/src/SomeoneElse-style-legend/generated_legend_pub.osm
#
# Tidy temporary files
#
rm welshlangpart_${file_extension1}_before.pbf welshlangpart_${file_extension1}_after.pbf englangpart_${file_extension1}_after.pbf scotsgdlangpart_${file_extension1}_before.pbf scotsgdlangpart_${file_extension1}_after.pbf langs_${file_extension1}_merged.pbf
#
# Reinitialise updating
#
rm -rf /var/lib/mod_tile/.osmosis.old
mv /var/lib/mod_tile/.osmosis /var/lib/mod_tile/.osmosis.old
sudo -u ${local_user} /home/${local_user}/src/mod_tile/openstreetmap-tiles-update-expire ${file_extension1}
pandoc /home/${local_user}/src/SomeoneElse-style/changelog.md > /var/www/html/maps/map/changelog.html
pandoc /home/${local_user}/src/SomeoneElse-map/about.md > /var/www/html/maps/map/about.html
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
rm last_modified1.$$ last_modified2.$$
rm update_render.running
#
